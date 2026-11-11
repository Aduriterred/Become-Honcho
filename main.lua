local player = game.Players.LocalPlayer
local modelId = 104515922403348
local heightOffset = 3
local idleAnimationId = 101907348895136
local runAnimationId = 100466662502744
local landingAnimationId = 91194170893496
local landingSoundId = 82613796053949
local impactSoundId = 74149238738530
local ambienceSoundIds = {105438678078526, 92139743699536, 82618476532926}
local landingCooldown = 10
local toolGripOffset = CFrame.new(0, -0.4, 0) * CFrame.Angles(math.rad(180), math.rad(0), math.rad(90))
local isThirdPerson = false

if _G.morphCleanup then
    pcall(_G.morphCleanup)
end

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Credits",
    Text = "Made by MorthenHubber. Credit if you use it",
    Duration = 5
})

task.wait(0.5)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Speed Bypass",
    Text = "Use mspaint's or vynixus speed bypass and set speed to 45",
    Duration = 10
})

local function loadModel()
    local objects = game:GetObjects("rbxassetid://" .. modelId)
    return objects[1]
end

local morph = loadModel()
if not morph then return end

local originalCharacter = player.Character
if not originalCharacter or not originalCharacter:FindFirstChild("HumanoidRootPart") then
    return
end
local originalRootPart = originalCharacter:FindFirstChild("HumanoidRootPart")
local originalHumanoid = originalCharacter:FindFirstChildWhichIsA("Humanoid")
local originalHeadPart = originalCharacter:FindFirstChild("Head")
if not originalRootPart or not originalHumanoid then return end

local originalWalkSpeed = originalHumanoid.WalkSpeed
local originalJumpPower = originalHumanoid.JumpPower
local originalJumpHeight = originalHumanoid.JumpHeight
local lastLandingTime = 0

local morphHumanoid = morph:FindFirstChildWhichIsA("Humanoid")
if morphHumanoid then morphHumanoid:Destroy() end

for _, part in ipairs(morph:GetDescendants()) do
    if part:IsA("BasePart") then
        part.Anchored = false
        part.CanCollide = false
    end
end

local morphRootPart = morph:FindFirstChild("HumanoidRootPart", true) or morph:FindFirstChild("RootPart", true)
if not morphRootPart then
    morphRootPart = Instance.new("Part")
    morphRootPart.Name = "HumanoidRootPart"
    morphRootPart.Size = Vector3.new(2, 1, 1)
    morphRootPart.Anchored = false
    morphRootPart.CanCollide = false
    morphRootPart.Parent = morph
end
morph.PrimaryPart = morphRootPart

local morphHeadPart = morph:FindFirstChild("Head", true)
if not morphHeadPart then
    morphHeadPart = Instance.new("Part")
    morphHeadPart.Name = "Head"
    morphHeadPart.Size = Vector3.new(1, 1, 1)
    morphHeadPart.Anchored = false
    morphHeadPart.CanCollide = false
    morphHeadPart.Parent = morph
end

morph.Parent = workspace

for _, part in ipairs(originalCharacter:GetDescendants()) do
    if part:IsA("BasePart") then
        part.Transparency = 1
        part.CanCollide = false
    end
end

local rootWeld = Instance.new("Weld")
rootWeld.Part0 = originalRootPart
rootWeld.Part1 = morphRootPart
rootWeld.C0 = CFrame.new(0, heightOffset, 0)
rootWeld.Parent = originalRootPart

local headWeld = Instance.new("Weld")
if originalHeadPart then
    headWeld.Part0 = originalHeadPart
else
    headWeld.Part0 = originalRootPart
end
headWeld.Part1 = morphHeadPart
local headWeldOffset = morphHeadPart.Position - (originalHeadPart and originalHeadPart.Position or originalRootPart.Position)
headWeld.C0 = CFrame.new(headWeldOffset)
headWeld.Parent = headWeld.Part0

local camera = workspace.CurrentCamera
if not camera then return end

camera.CameraType = Enum.CameraType.Scriptable

local runService = game:GetService("RunService")

local enforceLoop = runService.RenderStepped:Connect(function()
    if rootWeld and rootWeld.Parent then
        rootWeld.C0 = CFrame.new(0, heightOffset, 0)
    end

    if morphHeadPart and morphHeadPart:IsDescendantOf(workspace) then
        local lookVector = camera.CFrame.LookVector
        local upVector = camera.CFrame.UpVector
        local headPos = morphHeadPart.Position
        
        if isThirdPerson then
            local camPos = headPos - (lookVector * 12) + Vector3.new(0, 2, 0)
            camera.CFrame = CFrame.lookAt(camPos, headPos, upVector)
        else
            local offset = Vector3.new(0, 0.2, -0.5)
            local targetPosition = morphHeadPart.CFrame:PointToWorldSpace(offset)
            camera.CFrame = CFrame.lookAt(targetPosition, targetPosition + lookVector, upVector)
        end
    end

    local morphRightHand = morph:FindFirstChild("RightHand", true)
    local morphLeftHand = morph:FindFirstChild("LeftHand", true)

    if originalCharacter and morphRightHand then
        for _, tool in ipairs(originalCharacter:GetChildren()) do
            if tool:IsA("Tool") then
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    local defaultGrip = handle:FindFirstChild("RightGrip")
                    if defaultGrip then
                        if defaultGrip:IsA("Motor6D") then
                            defaultGrip.Enabled = false
                        else
                            defaultGrip:Destroy()
                        end
                    end
                    local defaultLeftGrip = handle:FindFirstChild("LeftGrip")
                    if defaultLeftGrip then
                        if defaultLeftGrip:IsA("Motor6D") then
                            defaultLeftGrip.Enabled = false
                        else
                            defaultLeftGrip:Destroy()
                        end
                    end

                    local morphWeld = handle:FindFirstChild("MorphWeld")
                    if not morphWeld then
                        morphWeld = Instance.new("Weld")
                        morphWeld.Name = "MorphWeld"
                        morphWeld.Part0 = morphRightHand
                        morphWeld.Part1 = handle
                        morphWeld.C0 = toolGripOffset
                        morphWeld.Parent = handle
                    elseif morphWeld.Part0 ~= morphRightHand then
                        morphWeld.Part0 = morphRightHand
                    end
                end
            end
        end
    end
end)

local animationController = morph:FindFirstChildWhichIsA("AnimationController") or morph:FindFirstChild("AnimationController", true)
if not animationController then
    animationController = Instance.new("AnimationController", morph)
end
local animator = morph:FindFirstChildWhichIsA("Animator") or (animationController and animationController:FindFirstChildWhichIsA("Animator"))
if not animator then
    animator = Instance.new("Animator", animationController)
end

local function createAnimation(animationId)
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. animationId
    return animation
end

local function playAnimation(animationObject, looped)
    local track = animator:LoadAnimation(animationObject)
    if track then
        track.Looped = looped or false
        track:Play()
    end
    return track
end

local function createSound(soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    return sound
end

local function playSound(soundObject)
    if not soundObject then return end
    soundObject.Parent = morph or workspace
    soundObject:Play()
end

local idleAnimation = createAnimation(idleAnimationId)
local runAnimation = createAnimation(runAnimationId)
local landingAnimation = createAnimation(landingAnimationId)

local landingSound = createSound(landingSoundId)
local impactSound = createSound(impactSoundId)

local ambienceSounds = {}
for i, id in ipairs(ambienceSoundIds) do
    local sound = createSound(id)
    sound.Looped = true
    ambienceSounds[i] = sound
end

local footstepsSound = nil
for _, child in ipairs(morph:GetDescendants()) do
    if child:IsA("Sound") and child.Name == "Footsteps" then
        footstepsSound = child
        break
    end
end

local currentAmbience = nil
local movementEnabled = false
local runTrack = nil
local idleTrack = nil
local landingTrack = nil
local lastMoveState = nil

local function replayLanding()
    if tick() - lastLandingTime < landingCooldown then
        return
    end
    lastLandingTime = tick()

    if landingTrack then landingTrack:Stop() end
    landingTrack = playAnimation(landingAnimation, false)
    playSound(landingSound)
    playSound(impactSound)
    movementEnabled = false

    originalHumanoid.WalkSpeed = 0
    originalHumanoid.JumpPower = 0
    if originalHumanoid.JumpHeight then
        originalHumanoid.JumpHeight = 0
    end

    if landingTrack then
        landingTrack.Stopped:Connect(function()
            originalHumanoid.WalkSpeed = originalWalkSpeed
            originalHumanoid.JumpPower = originalJumpPower
            if originalHumanoid.JumpHeight then
                originalHumanoid.JumpHeight = originalJumpHeight
            end
            movementEnabled = true
            if not runTrack or not runTrack.IsPlaying then
                idleTrack = playAnimation(idleAnimation, true)
            end
        end)
    else
        originalHumanoid.WalkSpeed = originalWalkSpeed
        originalHumanoid.JumpPower = originalJumpPower
        if originalHumanoid.JumpHeight then
            originalHumanoid.JumpHeight = originalJumpHeight
        end
        movementEnabled = true
    end
end

local userInputService = game:GetService("UserInputService")
local keySoundMap = {}
local ambienceKeys = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.V}
for i, key in ipairs(ambienceKeys) do
    if ambienceSounds[i] then
        keySoundMap[key] = ambienceSounds[i]
    end
end

local inputConnection = userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode
        local sound = keySoundMap[key]
        if sound then
            if currentAmbience == sound then
                sound:Stop()
                currentAmbience = nil
            else
                if currentAmbience then currentAmbience:Stop() end
                playSound(sound)
                currentAmbience = sound
            end
            return
        end
        if key == Enum.KeyCode.B then
            replayLanding()
        elseif key == Enum.KeyCode.L then
            isThirdPerson = not isThirdPerson
        end
    end
end)

replayLanding()

local movementLoop = runService.RenderStepped:Connect(function()
    if not movementEnabled then return end
    local moveDirection = originalHumanoid.MoveDirection
    if not moveDirection then return end
    local moving = moveDirection.Magnitude > 0.1

    if moving then
        if lastMoveState ~= "run" then
            if idleTrack then idleTrack:Stop() end
            runTrack = playAnimation(runAnimation, true)
            lastMoveState = "run"
        end
        if footstepsSound and not footstepsSound.IsPlaying then
            footstepsSound:Play()
        end
    else
        if lastMoveState ~= "idle" then
            if runTrack then runTrack:Stop() end
            idleTrack = playAnimation(idleAnimation, true)
            lastMoveState = "idle"
        end
        if footstepsSound and footstepsSound.IsPlaying then
            footstepsSound:Stop()
        end
    end
end)

_G.morphCleanup = function()
    if inputConnection then inputConnection:Disconnect() end
    if enforceLoop then enforceLoop:Disconnect() end
    if movementLoop then movementLoop:Disconnect() end
    if currentAmbience then currentAmbience:Stop() end
    if landingTrack then landingTrack:Stop() end
    if runTrack then runTrack:Stop() end
    if idleTrack then idleTrack:Stop() end
    if footstepsSound then footstepsSound:Stop() end
    
    if camera then
        camera.CameraType = Enum.CameraType.Custom
    end
    
    if originalCharacter then
        for _, part in ipairs(originalCharacter:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
                part.CanCollide = true
            end
        end
    end
    
    if morph then 
        morph:Destroy() 
    end
    
    _G.morphCleanup = nil
end
