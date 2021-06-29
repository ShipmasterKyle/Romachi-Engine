local remoteEvent = game.ReplicatedStorage.OnSuccessfulHit

remoteEvent.OnServerEvent:Connect(function(plr, humanoidHit, combo) --get Player, hit's humanoid, and the combo counter if any.
    if combo then --checks if theres a combo
        if combo == 1 then --Combo starter. No combo multiplayer.
            humanoidHit:TakeDamage(10) --Defult damage
        elseif not combo = "finisher" then --actual combos
            humanoidHit:TakeDamage(5*combo)--combos let you deal more damage
        elseif combo = "finisher" then --combo finisher.
            humanoidHit:TakeDamage(100) --Deals 100 damage as the combo finisher.
        end
    else
        humanoidHit:TakeDamage(10) --if no combo then deal normal damage
    end
end)