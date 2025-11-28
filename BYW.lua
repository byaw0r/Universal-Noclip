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

-- Функция для получения всех коллизионных частей персонажа
local function getCollisionParts(character)
    local parts = {}
    
    -- Основные части для R6
    local r6Parts = {
        "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"
    }
    
    -- Основные части для R15
    local r15Parts = {
        "Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "LeftHand",
        "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperLeg", "LeftLowerLeg", 
        "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot", "HumanoidRootPart"
    }
    
    -- Проверяем тип аватара
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
            -- R6 или другие типы
            for _, partName in pairs(r6Parts) do
                local part = character:FindFirstChild(partName)
                if part and part:IsA("BasePart") then
                    table.insert(parts, part)
                end
            end
        end
    end
    
    -- Добавляем HumanoidRootPart если его еще нет
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
        noclipBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Зеленый при вкл
        noclipBtn.TextColor3 = Color3.fromRGB(0, 0, 0) -- Черный текст
    else
        noclipBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Белый при выкл
        noclipBtn.TextColor3 = Color3.fromRGB(0, 0, 0) -- Черный текст
    end
end

local function disableNoclip()
    if noclipEnabled then
        noclipEnabled = false
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        -- Восстанавливаем коллизию с правильной логикой
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character then
            -- Ждем немного перед восстановлением
            wait(0.05)
            
            -- Получаем только основные коллизионные части
            local collisionParts = getCollisionParts(character)
            
            -- Восстанавливаем коллизию только для основных частей
            for _, part in pairs(collisionParts) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
            
            -- Для всех остальных частей (аксессуары и т.д.) оставляем коллизию выключенной
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
        noclipConnection = game:GetService("RunService").Stepped:Connect(function()
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character and noclipEnabled then
                -- Отключаем коллизию для всех частей
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

-- Подключение кнопки
noclipBtn.MouseButton1Click:Connect(toggleNoclip)

-- Бинд клавиши N для ПК
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- Игнорируем если в чате и т.д.
    
    if input.KeyCode == Enum.KeyCode.N then
        toggleNoclip()
    end
end)

-- Обработка перерождения персонажа
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("HumanoidRootPart")
    
    -- При перерождении всегда выключаем noclip
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
