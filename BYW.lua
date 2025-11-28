--BYW SCRIPIT
local noclipEnabled = false
local noclipConnection

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NoclipMenu"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local noclipBtn = Instance.new("TextButton")
noclipBtn.Name = "NoclipBtn"
noclipBtn.Size = UDim2.new(0, 50, 0, 50)
noclipBtn.Position = UDim2.new(0, 10, 0, 10)
noclipBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
noclipBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
noclipBtn.Text = "B"
noclipBtn.TextSize = 24
noclipBtn.Font = Enum.Font.GothamBold
noclipBtn.BorderSizePixel = 0
noclipBtn.Active = true
noclipBtn.Draggable = true
noclipBtn.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = noclipBtn

local function getCollisionParts(character)
    local parts = {}
    
    local r6Parts = {
        "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"
    }
    
    local r15Parts = {
        "Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "LeftHand",
        "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperLeg", "LeftLowerLeg", 
        "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot", "HumanoidRootPart"
    }
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if humanoid.RigType == Enum.HumanoidRigType.R15 then
            for _, partName in pairs(r15Parts) do
                local part = character:FindFirstChild(partName)
                if part and part:IsA("BasePart") then
                    table.insert(parts, part)
                end
            end
        else
            for _, partName in pairs(r6Parts) do
                local part = character:FindFirstChild(partName)
                if part and part:IsA("BasePart") then
                    table.insert(parts, part)
                end
            end
        end
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart and rootPart:IsA("BasePart") then
        local alreadyAdded = false
        for _, part in pairs(parts) do
            if part == rootPart then
                alreadyAdded = true
                break
            end
        end
        if not alreadyAdded then
            table.insert(parts, rootPart)
        end
    end
    
    return parts
end

local function updateNoclipButton()
    if noclipEnabled then
        noclipBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        noclipBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    else
        noclipBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        noclipBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    end
end

local function disableNoclip()
    if noclipEnabled then
        noclipEnabled = false
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character then
            wait(0.1)
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.PlatformStand = false
            end
            
            local collisionParts = getCollisionParts(character)
            
            for _, part in pairs(collisionParts) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
            
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    local isMainPart = false
                    for _, mainPart in pairs(collisionParts) do
                        if part == mainPart then
                            isMainPart = true
                            break
                        end
                    end
                    if not isMainPart then
                        part.CanCollide = false
                    end
                end
            end
        end
        
        updateNoclipButton()
    end
end

local function enableNoclip()
    if not noclipEnabled then
        noclipEnabled = true
        
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.PlatformStand = false
            end
        end
        
        noclipConnection = game:GetService("RunService").Stepped:Connect(function()
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character and noclipEnabled then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        updateNoclipButton()
    end
end

local function toggleNoclip()
    if noclipEnabled then
        disableNoclip()
    else
        enableNoclip()
    end
end

noclipBtn.MouseButton1Click:Connect(toggleNoclip)

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.N then
        toggleNoclip()
    end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("HumanoidRootPart")
    
    if noclipEnabled then
        noclipEnabled = false
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        updateNoclipButton()
    end
end)

game.Players.LocalPlayer.CharacterRemoving:Connect(function(character)
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    noclipEnabled = false
end)

print("BYW SCRIPT loaded!")
