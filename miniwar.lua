-- ============================================
-- Gamepass Spoofer - С полем ввода ID геймпаса
-- Принцип работы: перехват и подмена покупок
-- ВНИМАНИЕ: Работает ТОЛЬКО в играх со слабой защитой!
-- ============================================

print("Gamepass Spoofer загружен | Автор: code001")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")

-- ===== ФУНКЦИЯ: Подмена покупки =====
local function spoofGamepassPurchase(gamepassId)
    print("[SPOOFER] Попытка спуфинга геймпаса ID: " .. gamepassId)
    
    -- МЕТОД 1: Прямой вызов события покупки
    local success, result = pcall(function()
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local remotes = replicatedStorage:FindFirstChild("Remotes") or replicatedStorage:FindFirstChild("Events")
        
        if remotes then
            for _, remote in pairs(remotes:GetChildren()) do
                local remoteName = remote.Name:lower()
                if remoteName:find("purchase") or remoteName:find("gamepass") or remoteName:find("buy") then
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(gamepassId)
                        print("[SPOOFER] RemoteEvent вызван: " .. remote.Name)
                    elseif remote:IsA("RemoteFunction") then
                        remote:InvokeServer(gamepassId)
                        print("[SPOOFER] RemoteFunction вызван: " .. remote.Name)
                    end
                end
            end
        end
    end)
    
    if not success then
        print("[SPOOFER] Метод 1 не сработал: " .. tostring(result))
    end
    
    -- МЕТОД 2: Перехват PromptGamePassPurchase
    local originalPrompt = MarketplaceService.PromptGamePassPurchase
    
    MarketplaceService.PromptGamePassPurchase = function(player, passId)
        print("[SPOOFER] Перехвачена покупка геймпаса ID: " .. passId)
        giveLocalBonuses(passId)
        return true
    end
    
    task.delay(5, function()
        MarketplaceService.PromptGamePassPurchase = originalPrompt
    end)
    
    -- Уведомление
    game.StarterGui:SetCore("SendNotification", {
        Title = "SPOOFER";
        Text = "Попытка активации геймпаса #" .. gamepassId;
        Duration = 3;
    })
end

-- ===== ФУНКЦИЯ: Выдача бонусов на клиенте =====
local function giveLocalBonuses(gamepassId)
    print("[SPOOFER] Пытаюсь активировать бонусы для геймпаса ID: " .. gamepassId)
    
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("Frame") or gui:IsA("TextButton") then
            local guiName = gui.Name:lower()
            if guiName:find("gamepass") or guiName:find("vip") or guiName:find("premium") then
                if gui:IsA("TextButton") then
                    gui:Fire()
                    print("[SPOOFER] Активирована кнопка: " .. gui.Name)
                end
                gui.Visible = true
            end
        end
    end
end

-- ===== СОЗДАНИЕ GUI С ПОЛЕМ ДЛЯ ВВОДА ID =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GamepassSpoofer"
screenGui.Parent = game:GetService("CoreGui")

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
mainFrame.Parent = screenGui

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "🔓 GAMEPASS SPOOFER"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.Parent = mainFrame

-- Поле для ввода ID геймпаса
local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(0.8, 0, 0, 40)
inputBox.Position = UDim2.new(0.1, 0, 0, 50)
inputBox.PlaceholderText = "Введи ID геймпаса (цифры)"
inputBox.Text = ""
inputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.TextSize = 14
inputBox.Font = Enum.Font.Gotham
inputBox.Parent = mainFrame

-- Кнопка "Спуфить"
local spoofButton = Instance.new("TextButton")
spoofButton.Size = UDim2.new(0.8, 0, 0, 45)
spoofButton.Position = UDim2.new(0.1, 0, 0, 105)
spoofButton.Text = "💉 АКТИВИРОВАТЬ ГЕЙМПАС"
spoofButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
spoofButton.TextColor3 = Color3.fromRGB(255, 255, 255)
spoofButton.TextSize = 14
spoofButton.Font = Enum.Font.GothamBold
spoofButton.Parent = mainFrame

-- Кнопка закрытия
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 16
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = mainFrame

-- Информационная строка
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 0, 25)
infoLabel.Position = UDim2.new(0, 0, 1, -30)
infoLabel.Text = "Не работает в играх с хорошей защитой"
infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
infoLabel.BackgroundTransparency = 1
infoLabel.TextSize = 11
infoLabel.Parent = mainFrame

-- ===== ОБРАБОТЧИКИ =====
spoofButton.MouseButton1Click:Connect(function()
    local gamepassId = tonumber(inputBox.Text)
    if gamepassId and gamepassId > 0 then
        spoofGamepassPurchase(gamepassId)
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "Ошибка";
            Text = "Введи правильный ID геймпаса (только цифры)!";
            Duration = 3;
        })
    end
end)

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    print("[SPOOFER] GUI закрыт")
end)

-- Перетаскивание окна
local dragging = false
local dragStart
local startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("Gamepass Spoofer GUI создан | Введи ID геймпаса и нажми кнопку")
