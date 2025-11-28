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

local Noclip = nil
local Clip = nil

function noclip()
    Clip = false
    local function Nocl()
        if Clip == false and game.Players.LocalPlayer.Character ~= nil then
            for _,v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if v:IsA('BasePart') and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end
        wait(0.21)
    end
    Noclip = game:GetService('RunService').Stepped:Connect(Nocl)
end

function clip()
    if Noclip then Noclip:Disconnect() end
    Clip = true
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
        clip()
        updateNoclipButton()
    end
end

local function enableNoclip()
    if not noclipEnabled then
        noclipEnabled = true
        noclip()
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
        clip()
        updateNoclipButton()
    end
end)

game.Players.LocalPlayer.CharacterRemoving:Connect(function(character)
    clip()
    noclipEnabled = false
end)

print("BYW SCRIPT loaded!")
