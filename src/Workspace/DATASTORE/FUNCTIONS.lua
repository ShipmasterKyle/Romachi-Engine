--|| SERVICES ||--
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

--|| LOCALISE ||--
local random = Random
local Pairs = pairs
local Script = script
local Require = require
local Int = Instance
local Pcall = pcall
local TypeOf = typeof

local suffixes = {"K", "M", "B", "T", "Q", "Qu", "S", "Se", "O", "N", "D"}
local randomSeed = random.new()

local module = {
	lookAt = function(target, eye)
		local forwardVector = (eye - target).Unit
        local upVector = Vector3.new(0, 1, 0)
        -- You have to remember the right hand rule or google search to get this right
        local rightVector = forwardVector:Cross(upVector)
        local upVector2 = rightVector:Cross(forwardVector)
     
        return CFrame.fromMatrix(eye, rightVector, upVector2)
	end,
	deepTableCopy = function(Table)
		local newTable = {}
		
		local function copy(ParentTable, OriginalTable)
			for i, v in Pairs(OriginalTable) do
				if typeof(v) == "table" then
					ParentTable[i] = {}
					copy(ParentTable[i], v)
				else
					ParentTable[i] = v
				end
			end
		end
		
		copy(newTable, Table)
		return newTable
	end,
	createRayHitbox = function(Data)
		coroutine.wrap(function()
			local x, y, z = Data.x, Data.y, Data.z
			local Speed, Lifetime, Firetime = Data.Speed, Data.Lifetime, Data.Firetime
			local Projectile, MouseHit = Data.Projectile, Data.MouseHit
			local hit, pos
			local posOffsets = Data.Offsets
			
			repeat wait(x/2 / Speed)
				for i = 1, #posOffsets do
					local startPos = Projectile.Position + posOffsets[i]
					local endPos = Projectile.Position + (MouseHit.p - Projectile.Position).Unit * x
					local ray = Ray.new(startPos, (endPos - startPos).Unit * x)
					hit, pos = game.Workspace:FindPartOnRayWithIgnoreList(ray, {game.Workspace.World.Visuals})
				end
			until tick() - Firetime >= Lifetime or hit do end
			if hit then
				local Humanoid
				if hit.Parent:FindFirstChild("Humanoid") then
					Humanoid = hit.Parent.Humanoid
				elseif hit.Parent.Parent:FindFirstChild("Humanoid") then
					Humanoid = hit.Parent.Parent.Humanoid
				end
				
				if Humanoid then
					Data.Function1({
						Hit = hit,
						Pos = pos,
						Hum = Humanoid	
					})
				else
					Data.Function2({
						Hit = hit,
						Pos = pos,
					})
				end
			end
		end)()
	end,
	screenShake = function(hum, intensity, shake, drag)
		coroutine.wrap(function()
			for i = 1, shake do
				local x,y,z = randomSeed:NextNumber()*intensity, randomSeed:NextNumber()*intensity, randomSeed:NextNumber()*intensity
				local shakeTween = TweenService:Create(hum, TweenInfo.new(0.125, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, true), {CameraOffset = Vector3.new(x,y,z)})
				shakeTween:Play()
				shakeTween:Destroy()
				wait(drag)
			end
			local Return = TweenService:Create(hum, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CameraOffset = Vector3.new(0,0,0)})
			Return:Play()
			Return:Destroy()
		end)()
	end,
	toSuffixString = function(n)
		for i = #suffixes, 1, -1 do
			local v = math.pow(10, i * 3)
			if n >= v then
				return ("%.0f"):format(n / v) .. suffixes[i]
			end
		end
		return tostring(n)
	end,
	isAlive = function(Model)
		if Model and Model.PrimaryPart
		and Model:FindFirstChild("Humanoid")
		and Model.Humanoid:IsDescendantOf(game.Workspace)
		and Model.Humanoid.Health > 0 then
			return true
		end
		return false
	end,
	createVisualRay = function(startPos, endPos)
		local beam = Int.new("Part")
	    beam.Anchored = true
	    beam.Locked = true
	    beam.CanCollide = false
		beam.Parent = game.Workspace
	    
	    local distance = (startPos - endPos).Magnitude
	    beam.Size = Vector3.new(0.3, 0.3, distance)
	    beam.CFrame = CFrame.new(startPos, endPos)*CFrame.new(0, 0, -distance / 2)
	end,
	generateRandomNumber = function(startNumber, endNumber, Offset)
		return math.random(startNumber, endNumber) * Offset
	end,
	toHMS = function(s)
		return ("%02i:%02i:%02i"):format(s/60^2, s/60%60, s%60)
	end,
	getPlayerPlatform = function()
    	if (GuiService:IsTenFootInterface()) then
        	return "Console"
    	elseif (UserInputService.TouchEnabled and not UserInputService.MouseEnabled) then
        	return "Mobile"
	    else
       		return "Desktop"
    	end
	end,
	new = function(instance, properties)
		local newInstance = Int.new(instance)
		for property, value in Pairs(properties) do
			newInstance[property] = value
		end
		return newInstance
	end,
	getObjFromValue = function(value)
		if TypeOf(value) == "number" then
			return "NumberValue"
		elseif TypeOf(value) == "boolean" then
			return "BoolValue"
		elseif TypeOf(value) == "string" then
			return "StringValue"
		end
	end,
}

module.compareTables = function(table1, table2)
	--> Loops through table1
	for i, v in Pairs(table1) do
		-- If the value is a table
		if TypeOf(v) == "table" then
			-- Compare table2's index with this table (comparing both subtables)
			if not module.compareTables(table2[i], v) then
				--> If it's not the same then the tables aren't equal
				return false
			end 
		--> If the value is not a table
		else
			--> If the value isn't equaal to the index of table2	
			if v ~= table2[i] then
				--> It's not the same
				return false
			end
		end
	end
	--> If all the other conditions don't get triggered it's the same
	return true
end

return module
