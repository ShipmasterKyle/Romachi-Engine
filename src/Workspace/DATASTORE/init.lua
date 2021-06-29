
--[[
	Please read instructions
--]]

--|| SERVICES ||--
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

--|| MODULES ||--
local FUNCTIONS = require(script.FUNCTIONS)
local PROPERTIES = require(script.PROPERTIES)
local INITIALDATA = require(script.INITIALDATA)
local TIMEWIDGET = require(workspace.TimeStuff.TimeWidget)

--|| VARIABLES ||--
local Datastore = DataStoreService:GetDataStore(PROPERTIES.DATASTORE)

local serverLog = {}
local serverData = {}
local module = {}

module.setupData = function(Player)
	serverLog[Player] = {
		lastSave = tick(),
		dataLoaded = false	
	}
	
	serverData[Player] = {}
end

module.endData = function(Player)
	serverLog[Player] = nil
	serverData[Player] = nil
end

function module:createNewBranch(name, data)
	local newFolder = FUNCTIONS.new("Folder", {
		Name = name,
		Parent = self
	})
	
	for stat, value in pairs(data) do
		if typeof(value) == "table" then
			module.createNewBranch(newFolder, stat, value)
		else
			FUNCTIONS.new(FUNCTIONS.getObjFromValue(value), {
				Name = stat,
				Value = value,
				Parent = newFolder
			})
		end
	end
end

function module:loadDataFromTable(data)
	for stat, value in pairs(data) do
		if self:FindFirstChild(stat) then
			if typeof(value) == "table" then
				module.loadDataFromTable(self[stat], value)
			else
				self[stat].Value = value
			end
		end
	end
end

function module:convertFolderToTableValue()
	local c = self:GetChildren()
	local newTable = {}
	for i = 1, #c do
		if c[i]:IsA("Folder") then
			newTable[c[i].Name] = module.convertFolderToTableValue(c[i])
		else
			newTable[c[i].Name] = c[i].Value
		end
	end
	return newTable
end

module.saveData = function(Player)
	--> Conditions to not save
	if not PROPERTIES.SAVE then
		warn("[DATASTORE]: SAVING DATA IS DISABLED | PLEASE CHANGE THIS IF THIS WAS UNINTENTIONAL")
		return 
	end
	
	if not PROPERTIES.STUDIO_SAVE and RunService:IsStudio() then
		warn("[DATASTORE]: SAVING DATA IN STUDIO IS DISABLED | PLEASE CHANGE THIS IF THIS WAS UNINTENTIONAL")
		return
	end
	
	if not serverLog[Player] or not serverLog[Player].dataLoaded then
		--> We don't want to be saving if their data hasn't even loaded
		return
	end

	local suc, err, att, data = nil, nil, 0, FUNCTIONS.deepTableCopy(serverData[Player])
	
	local pChildren = Player:GetChildren()
	for i = 1, #pChildren do
		if pChildren[i]:IsA("Folder") then
			
			if data[pChildren[i].Name] then
				data[pChildren[i].Name] = module.convertFolderToTableValue(pChildren[i])
			end
		end
	end

	coroutine.wrap(function()
		repeat wait(1)
			att = att + 1
			suc, err = pcall(function()
				Datastore:SetAsync(Player.UserId, data)
			end)
		until suc or att >= PROPERTIES.ATTEMPTS do end

		if suc then
			print("[DATASTORE]: SERVER SAVED "..Player.Name.."'s DATA")
			if serverLog[Player] and serverLog[Player].lastSave then
				serverLog[Player].lastSave = tick()
			end
		else
			warn("[DATASTORE]: AN ERROR HAS OCCURED WHILE SAVING "..Player.Name.."'s DATA! RETRYING LATER. ("..att.."): "..err)
		end
	end)()
end

module.createData = function(Player, Data)
	for i = 1, #INITIALDATA do
		if INITIALDATA[i][2] then
			module.createNewBranch(Player, INITIALDATA[i][1], INITIALDATA[i][3])
			serverData[Player][INITIALDATA[i][1]] = FUNCTIONS.deepTableCopy(INITIALDATA[i][3])
		elseif not INITIALDATA[i][2] then
			--> Log via Table
			serverData[Player][INITIALDATA[i][1]] = FUNCTIONS.deepTableCopy(INITIALDATA[i][3])
		end
	end

	if Data then
		local cChildren = Player:GetChildren()
		for i = 1, #cChildren do
			if cChildren[i]:IsA("Folder") and Data[cChildren[i].Name] then
				module.loadDataFromTable(cChildren[i], Data[cChildren[i].Name])
			end
		end
		serverData[Player] = FUNCTIONS.deepTableCopy(Data)
	else

	end
	serverLog[Player].dataLoaded = true
	serverLog[Player].lastSave = tick()
	print("[DATASTORE]: Loaded "..Player.Name.."'s Data")
end

module.loadData = function(Player)
	--> Conditions 
	if not PROPERTIES.LOAD then
		warn("[DATASTORE]: LOADING DATA HAS BEEN DISABLED : PLEASE CHANGE THIS IF THIS WAS UNINTENDED")
		module.createData(Player, nil)
		return
	end
	
	if not PROPERTIES.STUDIO_LOAD and RunService:IsStudio() then
		warn("[DATASTORE]: LOADING DATA IN STUDIO HAS BEEN DISABLED : PLEASE CHANGE THIS IF THIS WAS UNINTENDED")
		module.createData(Player, nil)
		return
	end
	
	local suc, err, att, data = nil, nil, 0, nil
	
	coroutine.wrap(function()
		repeat wait(1)
			att = att + 1
			suc, err = pcall(function()
				data = Datastore:GetAsync(Player.UserId)
			end)
		until suc or att >= PROPERTIES.ATTEMPTS do end
		
		if suc then
			module.createData(Player,data)
		else
			warn("[DATASTORE]: AN ERROR OCCURED WHILE LOADING DATA : "..err)
			Player:Kick("[DATASTORE]: An error occured while loading your data; please try again later.")
		end
	end)()
end

module.getData = function(Player)
	if serverLog[Player] and serverLog[Player].dataLoaded then
		return serverData[Player]
	end
end

--> Auto Save (Will run if SAVE is on at all)
if PROPERTIES.SAVE then
	if PROPERTIES.AUTO_SAVE then
		coroutine.wrap(function()
			while true do
				wait(PROPERTIES.INTERVAL / 10)
				
				for Player, _ in pairs(serverData) do
					if tick() - serverLog[Player].lastSave >= PROPERTIES.INTERVAL then
						module.saveData(Player)
					end
				end
			end
		end)()
	end

	--> When game shutdowns
	if PROPERTIES.SAFE_SAVE then
		game:BindToClose(function()
			for Player, _ in pairs(serverData) do
				module.saveData(Player)
			end
		end)
	end
end

return module
