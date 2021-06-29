--[[
    Run this in the command line to get remote events. Then delete this script
]]

local events = {
    "OnSuccessfulHit",
    "OnSwordHit",
}

for i, v in ipairs(events) do 
    local event = Instance.new("RemoteEvent")
    event.Name = v
    event.Parent = game.ReplicatedStorage
end