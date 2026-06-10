-- ============================================
-- Gamepass Spoofer - Учебная версия
-- Принцип работы: перехват и подмена покупок
-- ВНИМАНИЕ: Работает ТОЛЬКО в играх со слабой защитой!
-- ============================================

print("Gamepass Spoofer загружен | Автор: code001")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")

-- ===== НАСТРОЙКИ (ИЗМЕНЯЙ ЗДЕСЬ) =====
-- Список геймпасов, которые будем пытаться спуфить
-- Нужно узнать реальные ID геймпасов в игре!
local GAMEPASSES_TO_SPOOF = {
    {id = 0, name = "Пример геймпаса 1"},     -- Замени ID на реальный
    {id = 0, name = "Пример геймпаса 2"},     -- Замени ID на реальный
}

-- ===== ФУНКЦИЯ: Получение ID геймпаса из окна покупки =====
local function getGamepassIdFromPrompt()
    -- Ищем открытое окно покупки геймпаса
    for _, v in pairs(game:GetService("CoreGui"):GetDescendants()) do
        if v:IsA("Frame") and v.Name:find("PurchasePrompt") then
            -- Пытаемся найти ID геймпаса в тексте
            local textElement = v:FindFirstChild("TextLabel")
            if textElement and textElement.Text then
                local text = textElement.Text
                -- Извлекаем цифры из текста (ID геймпаса)
                local id = text:match("%d+")
                if id then
                    return tonumber(id)
                end
            end
        end
    end
    return nil
end

-- ===== ФУНКЦИЯ: Подмена покупки =====
local function spoofGamepassPurchase(gamepassId)
    print("[SPOOFER] Попытка спуфинга геймпаса ID: " .. gamepassId)
    
    -- МЕТОД 1: Прямой вызов события покупки
    -- В некоторых играх есть Remote Events для покупок
    local success, result = pcall(function()
        -- Ищем Remotes в игре
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local remotes = replicatedStorage:FindFirstChild("Remotes") or replicatedStorage:FindFirstChild("Events")
        
        if remotes then
            -- Ищем remote, связанный с покупками
            for _, remote in pairs(remotes:GetChildren()) do
                local remoteName = remote.Name:lower()
                if remoteName:find("purchase") or remoteName:find("gamepass") or remoteName:find("buy") then
                    -- Пытаемся вызвать remote с ID геймпаса
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
    -- Сохраняем оригинальную функцию
    local originalPrompt = MarketplaceService.PromptGamePassPurchase
    
    -- Подменяем функцию
    MarketplaceService.PromptGamePassPurchase = function(player, passId)
        print("[SPOOFER] Перехвачена покупка геймпаса ID: " .. passId)
        
        -- Пытаемся найти и активировать бонусы в игре
        giveLocalBonuses(passId)
        
        -- Возвращаем true, чтобы игра думала, что покупка успешна
        return true
    end
    
    -- Восстанавливаем через 5 секунд
    task.delay(5, function()
        MarketplaceService.PromptGamePassPurchase = originalPrompt
    end)
end

-- ===== ФУНКЦИЯ: Выдача бонусов на клиенте =====
local function giveLocalBonuses(gamepassId)
    print("[SPOOFER] Пытаюсь активировать бонусы для геймпаса ID: " .. gamepassId)
    
    -- Ищем GUI, связанные с геймпасами
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Перебираем все элементы GUI
    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("Frame") or gui:IsA("TextButton") then
            local guiName = gui.Name:lower()
            
            -- Ищем элементы, связанные с геймпасами
            if guiName:find("gamepass") or guiName:find("vip") or guiName:find("premium") then
                -- Пытаемся активировать кнопку, если она есть
                if gui:IsA("TextButton") then
                    gui:Fire()
                    print("[SPOOFER] Активирована кнопка: " .. gui.Name)
                end
                
                -- Делаем видимыми скрытые элементы
                gui.Visible = true
            end
        end
    end
    
    -- Уведомление
    game.StarterGui:SetCore("SendNotification", {
        Title = "SPOOFER";
        Text = "Попытка активации геймпаса #" .. gamepassId;
        Duration = 3;
    })
end

-- ===== СОЗДАНИЕ GUI КНОПКИ =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GamepassSpoofer"
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 150)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "Gamepass Spoofer"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = mainFrame

local spoofButton = Instance.new("TextButton")
spoofButton.Size = UDim2.new(0, 150, 0, 40)
spoofButton.Position = UDim2.new(0.5, -75, 0, 40)
spoofButton.Text = "Spoof Gamepass"
spoofButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
spoofButton.TextColor3 = Color3.fromRGB(255, 255, 255)
spoofButton.Parent = mainFrame

-- Обработчик нажатия кнопки
spoofButton.MouseButton1Click:Connect(function()
    -- Запрашиваем ID геймпаса у пользователя
    local gamepassId = UserInputService:InputBox("Введите ID геймпаса:", "Gamepass Spoofer", "")
    
    if gamepassId and tonumber(gamepassId) then
        spoofGamepassPurchase(tonumber(gamepassId))
    else
        -- Если ID не введен, пытаемся определить автоматически
        local autoId = getGamepassIdFromPrompt()
        if autoId then
            spoofGamepassPurchase(autoId)
        else
            game.StarterGui:SetCore("SendNotification", {
                Title = "Ошибка";
                Text = "Введите ID геймпаса или откройте окно покупки";
                Duration = 3;
            })
        end
    end
end)

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 0, 40)
infoLabel.Position = UDim2.new(0, 0, 0, 90)
infoLabel.Text = "Сначала открой окно покупки геймпаса"
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.BackgroundTransparency = 1
infoLabel.TextSize = 12
infoLabel.Parent = mainFrame

print("Gamepass Spoofer GUI создан | Используй кнопку на экране")
