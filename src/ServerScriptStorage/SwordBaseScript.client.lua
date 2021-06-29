local blade = script.Parent.SwordBlade
local CanAttack = true
local comboCheck = false
local comboCountDown = 0
local combo = 0

blade.Touched:Connect(function(p)
    if p.Parent:FindFirstChild("Humanoid") then
        if CanAttack == true then
            CanAttack = false
            comboCountDown += 3 --adds 3 seconds to the countdown
            if combo >= 7 then --number of hits it takes to get a finisher
                combo = "finisher"
            elseif combo = "finisher" then
                combo = 1 -- resets the combo counter
            else
                combo += 1 --adds 1 combo to the combo counter
            end
            game.ReplicatedStorage.OnSuccessfulHit(game.Players.LocalPlayer, p.Humanoid, combo) --Sword Damage
            if comboCheck == false then
                coroutine.resume(SwordComboCallback)
            end)
            script.Parent.Handle.Hit:Play() --Sword Sound
            wait(0.1) --Cooldown
            CanAttack = true
        end
    end
end)
--couroutine used to keep track of combo time
local SwordComboCallback = coroutine.create(function()
    comboCheck = true
    repeat
    comboCountDown - 0.02
    until comboCountDown == 0
    comboCheck = false
end)
