--All animations
local m1Anim = Instance.new("Animation") --Left Punch
m1Anim.AnimationId = "rbxassetid://7001862390"
local m2Anim = Instance.new("Animation") --Right Punch
m2Anim.AnimationId = "rbxassetid://7001866799"
local m3Anim = Instance.new("Animation") --Left Kick
m3Anim.AnimationId = "rbxassetid://7001868682" 
local m4Anim = Instance.new("Animation") --Right Kick
m4Anim.AnimationId = "rbxassetid://7001871361" 
 
local char = script.Parent
 
local humanoid = char:WaitForChild("Humanoid")
 
 
local uis = game:GetService("UserInputService")
 
 
local debounce = false
local isAnimationPlaying = false
 
 
local loadedAnimation
local currentAnimationId
 
 
local remoteEvent = game.ReplicatedStorage.OnSuccessfulHit
 
 
uis.InputBegan:Connect(function(input, gameProcessed) --Handles all the attacks
    
    if gameProcessed or isAnimationPlaying then return end
 
    
    if input.KeyCode == Enum.KeyCode.Q then
        
        
        isAnimationPlaying = true
        currentAnimationId = m1Anim.AnimationId
        
        loadedAnimation = humanoid:LoadAnimation(m1Anim)
        
        loadedAnimation:Play()
        
        
    elseif input.KeyCode == Enum.KeyCode.E then
        
        
        isAnimationPlaying = true
        currentAnimationId = m2Anim.AnimationId
        
        loadedAnimation = humanoid:LoadAnimation(m2Anim)
        
        loadedAnimation:Play()
        
        
    elseif input.KeyCode == Enum.KeyCode.Z then
        
        
        isAnimationPlaying = true
        currentAnimationId = m3Anim.AnimationId
        
        loadedAnimation = humanoid:LoadAnimation(m3Anim)
        
        loadedAnimation:Play()
        
        
    elseif input.KeyCode == Enum.KeyCode.C then
        
        
        isAnimationPlaying = true
        currentAnimationId = m4Anim.AnimationId
        
        loadedAnimation = humanoid:LoadAnimation(m4Anim)
        
        loadedAnimation:Play()
        
    elseif input.KeyCode == Enum.KeyCode.LeftShift then --Guarding
        print("Gaurd Anim Incomplete")
    end
    
    if loadedAnimation then 
        
        
        loadedAnimation.Stopped:Wait()
        
        isAnimationPlaying = false
    end
end)
 
 
humanoid.Touched:Connect(function(hit, bodyPart)
    
    if not isAnimationPlaying or debounce then return end
    
    local charOfHitPlayer = hit.Parent
    local humanoidOfHitPlayer = charOfHitPlayer:FindFirstChild("Humanoid")
    
    if not humanoidOfHitPlayer then return end
    
    debounce = true
    
    
    if currentAnimationId == m1Anim.AnimationId and bodyPart.Name == "LeftHand" then
        
        remoteEvent:FireServer(humanoidOfHitPlayer)
            
    elseif currentAnimationId == m2Anim.AnimationId and bodyPart.Name == "RightHand" then
        
        remoteEvent:FireServer(humanoidOfHitPlayer)
        
    elseif currentAnimationId == m3Anim.AnimationId and bodyPart.Name == "LeftFoot" then
        
        remoteEvent:FireServer(humanoidOfHitPlayer)
        
    elseif currentAnimationId == m4Anim.AnimationId and bodyPart.Name == "RightFoot" then
        
        remoteEvent:FireServer(humanoidOfHitPlayer)
    end
    
    wait(0.1)
    
    debounce = false
end)