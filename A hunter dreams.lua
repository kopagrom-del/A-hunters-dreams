local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer

print("Загрузка скрипта...")

-- ==================== GUI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "QuestFarm"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 350)
frame.Position = UDim2.new(0.5, -160, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(100, 100, 255)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
title.Text = "🗡️ Quest Auto Farm"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

local btnFarm = Instance.new("TextButton")
btnFarm.Size = UDim2.new(0.9, 0, 0, 40)
btnFarm.Position = UDim2.new(0.05, 0, 0, 50)
btnFarm.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
btnFarm.Text = "Auto Farm: OFF"
btnFarm.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFarm.TextScaled = true
btnFarm.Font = Enum.Font.GothamBold
btnFarm.Parent = frame

local btnFarmCorner = Instance.new("UICorner")
btnFarmCorner.CornerRadius = UDim.new(0, 8)
btnFarmCorner.Parent = btnFarm

local btnESP = Instance.new("TextButton")
btnESP.Size = UDim2.new(0.9, 0, 0, 40)
btnESP.Position = UDim2.new(0.05, 0, 0, 100)
btnESP.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
btnESP.Text = "ESP: OFF"
btnESP.TextColor3 = Color3.fromRGB(255, 255, 255)
btnESP.TextScaled = true
btnESP.Font = Enum.Font.GothamBold
btnESP.Parent = frame

local btnESPCorner = Instance.new("UICorner")
btnESPCorner.CornerRadius = UDim.new(0, 8)
btnESPCorner.Parent = btnESP

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
statusLabel.Position = UDim2.new(0.05, 0, 0, 150)
statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
statusLabel.Text = "Статус: Ожидание"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = frame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = statusLabel

local questInfo = Instance.new("TextLabel")
questInfo.Size = UDim2.new(0.9, 0, 0, 30)
questInfo.Position = UDim2.new(0.05, 0, 0, 185)
questInfo.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
questInfo.Text = "Квест: -"
questInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
questInfo.TextScaled = true
questInfo.Font = Enum.Font.Gotham
questInfo.Parent = frame

local questInfoCorner = Instance.new("UICorner")
questInfoCorner.CornerRadius = UDim.new(0, 6)
questInfoCorner.Parent = questInfo

local progressInfo = Instance.new("TextLabel")
progressInfo.Size = UDim2.new(0.9, 0, 0, 30)
progressInfo.Position = UDim2.new(0.05, 0, 0, 220)
progressInfo.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
progressInfo.Text = "Прогресс: -"
progressInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
progressInfo.TextScaled = true
progressInfo.Font = Enum.Font.Gotham
progressInfo.Parent = frame

local progressInfoCorner = Instance.new("UICorner")
progressInfoCorner.CornerRadius = UDim.new(0, 6)
progressInfoCorner.Parent = progressInfo

local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(0.9, 0, 0, 25)
hint.Position = UDim2.new(0.05, 0, 0, 270)
hint.BackgroundTransparency = 1
hint.Text = "RightShift - скрыть меню"
hint.TextColor3 = Color3.fromRGB(150, 150, 150)
hint.TextScaled = true
hint.Font = Enum.Font.Gotham
hint.Parent = frame

print("GUI создан")

local autoFarmEnabled = false
local espEnabled = false

-- ==================== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ====================
local function getPosition(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.Position end
        local ok, pivot = pcall(function() return obj:GetPivot().Position end)
        if ok then return pivot end
    end
    return nil
end

local function teleportTo(pos)
    local char = Player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    pcall(function()
        hrp.CFrame = CFrame.new(pos)
    end)
    return true
end

-- ==================== ПОЛУЧЕНИЕ КВЕСТА ====================
local function getActiveQuestText()
    local playerGui = Player:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    local questUI = playerGui:FindFirstChild("QuestUI")
    if not questUI then return nil end
    local frameQ = questUI:FindFirstChild("Frame")
    if not frameQ then return nil end
    local questName = frameQ:FindFirstChild("QuestName")
    if not questName then return nil end
    
    local contentText = questName:FindFirstChild("ContentText")
    if contentText and contentText.Value then
        return contentText.Value
    end
    
    if questName.Text and questName.Text ~= "" then
        return questName.Text
    end
    
    return nil
end

local function parseQuest(questText)
    if not questText then return nil end
    
    local huntCount, huntMob = questText:match("[Hh]unt%s+(%d+)%s+(%w+)")
    if huntCount and huntMob then
        return {
            type = "hunt",
            count = tonumber(huntCount),
            mob = huntMob:lower(),
            rawText = questText
        }
    end
    
    local defeatThe = questText:match("[Dd]efeat%s+[Tt]he%s+(%w+)")
    if defeatThe then
        return {
            type = "defeat_the",
            mob = defeatThe:lower(),
            rawText = questText
        }
    end
    
    local defeatCount, defeatMob = questText:match("[Dd]efeat%s+(%d+)%s+(%w+)")
    if defeatCount and defeatMob then
        return {
            type = "defeat",
            count = tonumber(defeatCount),
            mob = defeatMob:lower(),
            rawText = questText
        }
    end
    
    return {type = "unknown", rawText = questText}
end

-- ==================== ПОИСК КВЕСТОВЫХ БУМАГ ====================
local function findQuestPapers()
    local papers = {}
    local map = Workspace:FindFirstChild("Map")
    if not map then return papers end
    local questBoards = map:FindFirstChild("QuestBoards")
    if not questBoards then return papers end
    
    for _, board in pairs(questBoards:GetChildren()) do
        if string.find(board.Name:lower(), "questboard") then
            local questPapers = board:FindFirstChild("Quest_Papers")
            if questPapers then
                for _, paper in pairs(questPapers:GetChildren()) do
                    local name = paper.Name
                    if name == "7" or name == "8" or name == "9" then
                        table.insert(papers, paper)
                    end
                end
            end
        end
    end
    return papers
end

local function getQuestStars(name)
    if name == "9" then return 5
    elseif name == "8" then return 4
    elseif name == "7" then return 4
    else return 0 end
end

local function clickPaper(paper)
    if not paper or not paper.Parent then return false end
    local cd = paper:FindFirstChild("ClickDetector")
    if cd then
        pcall(function() fireclickdetector(cd) end)
        task.wait(0.5)
        return true
    end
    local parent = paper.Parent
    if parent then
        cd = parent:FindFirstChild("ClickDetector")
        if cd then
            pcall(function() fireclickdetector(cd) end)
            task.wait(0.5)
            return true
        end
    end
    return false
end

local function clickCancelQuest()
    local playerGui = Player:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    local questUI = playerGui:FindFirstChild("QuestUI")
    if not questUI then return false end
    for _, gui in pairs(questUI:GetDescendants()) do
        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            local text = gui.Text:lower()
            if string.find(text, "cancel") then
                pcall(function() gui:Click() end)
                task.wait(0.5)
                return true
            end
        end
    end
    return false
end

-- ==================== ПОИСК МОБОВ ПО ВСЕЙ КАРТЕ ====================
local function findMobs(mobType)
    local mobs = {}
    mobType = mobType:lower()
    
    -- Ищем ВЕЗДЕ по всей карте через GetDescendants
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= Player.Character then
            local name = obj.Name:lower()
            if name == mobType or string.find(name, mobType, 1, true) then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    table.insert(mobs, obj)
                end
            end
        end
    end
    
    return mobs
end

-- ==================== СТАБИЛЬНЫЙ ПОЛЁТ ПОД МОБОМ ====================
-- Функция для плавного перемещения к позиции (без резких телепортов)
local function flyTo(targetPos, hrp, speed)
    speed = speed or 80 -- Скорость полёта (stud/сек)
    local currentPos = hrp.Position
    local direction = (targetPos - currentPos)
    local distance = direction.Magnitude
    
    if distance < 0.5 then
        -- Уже на месте, просто держим позицию
        hrp.CFrame = CFrame.new(currentPos, currentPos + Vector3.new(0, 0, -1))
        return true
    end
    
    -- Ограничиваем шаг чтобы не было резких скачков
    local step = math.min(distance, speed * 0.016) -- 0.016 = ~60 FPS
    local newPos = currentPos + direction.Unit * step
    hrp.CFrame = CFrame.new(newPos, targetPos)
    return false
end

-- Основная функция атаки со стабильным полётом
local function attackWithStableFlight(mob, offsetBelow)
    if not mob or not mob.Parent then return false, nil end
    
    local hum = mob:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false, nil end
    
    local char = Player.Character
    if not char then return false, nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false, nil end
    
    local mobPart = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso") or mob:FindFirstChild("UpperTorso")
    if not mobPart then
        for _, part in pairs(mob:GetDescendants()) do
            if part:IsA("BasePart") then
                mobPart = part
                break
            end
        end
    end
    if not mobPart then return false, nil end
    
    -- Позиция ПОД мобом
    local targetPos = mobPart.Position - Vector3.new(0, offsetBelow, 0)
    
    -- Плавный полёт к цели
    local arrived = flyTo(targetPos, hrp, 100)
    
    -- Бьём если рядом
    local dist = (hrp.Position - mobPart.Position).Magnitude
    if dist < 8 then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function() tool:Activate() end)
        end
    end
    
    return true, dist
end

-- ==================== ПРОГРЕСС ====================
local function getQuestProgress()
    local playerStats = Player:FindFirstChild("Player_Stats")
    if playerStats then
        local questProgress = playerStats:FindFirstChild("Quest_Progress")
        if questProgress then
            return questProgress.Value
        end
    end
    return 0
end

-- ==================== ФАРМ HUNT СО СТАБИЛЬНЫМ ПОЛЁТОМ ====================
local function farmHuntQuest(questData)
    local mobType = questData.mob
    local targetCount = questData.count
    local offsetBelow = 2 -- Летим на 2 единицы ПОД мобом
    
    statusLabel.Text = "Фарм: Hunt " .. targetCount .. " " .. mobType
    questInfo.Text = "Квест: " .. questData.rawText
    
    local currentTarget = nil -- Текущая цель для стабильности
    
    while autoFarmEnabled do
        task.wait(0.016) -- ~60 FPS для плавности
        
        local currentProgress = getQuestProgress()
        progressInfo.Text = "Прогресс: " .. currentProgress .. "/" .. targetCount
        
        if currentProgress >= targetCount then
            statusLabel.Text = "Квест выполнен!"
            return true
        end
        
        -- Если текущая цель мертва или её нет - ищем новую
        if not currentTarget or not currentTarget.Parent then
            currentTarget = nil
        else
            local hum = currentTarget:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then
                currentTarget = nil
            end
        end
        
        -- Если нет цели - ищем ближайшего
        if not currentTarget then
            local mobs = findMobs(mobType)
            if #mobs == 0 then
                statusLabel.Text = "Поиск: " .. mobType
                task.wait(0.5)
                continue
            end
            
            -- Сортируем по расстоянию
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            table.sort(mobs, function(a, b)
                local posA = getPosition(a)
                local posB = getPosition(b)
                if not posA or not posB or not hrp then return false end
                return (posA - hrp.Position).Magnitude < (posB - hrp.Position).Magnitude
            end)
            
            currentTarget = mobs[1]
            statusLabel.Text = "Лечу к: " .. mobType
            
            -- ТЕЛЕПОРТИРУЕМСЯ ПОД МОБА ОДИН РАЗ если он далеко
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local mobPos = getPosition(currentTarget)
            if hrp and mobPos then
                local dist = (hrp.Position - mobPos).Magnitude
                if dist > 50 then
                    -- Далеко - телепорт под моба
                    teleportTo(mobPos - Vector3.new(0, offsetBelow, 0))
                end
            end
        end
        
        -- Стабильно летим под текущей целью и бьём
        if currentTarget then
            local success, dist = attackWithStableFlight(currentTarget, offsetBelow)
            if success and dist then
                statusLabel.Text = "Бью: " .. mobType .. " (" .. string.format("%.1f", dist) .. ")"
            end
        end
    end
    
    return false
end

-- ==================== ФАРМ DEFEAT THE ====================
local function farmDefeatTheQuest(questData)
    local mobType = questData.mob
    local offsetBelow = 3 -- Под боссом чуть ниже
    
    statusLabel.Text = "Фарм: Defeat The " .. mobType
    questInfo.Text = "Квест: " .. questData.rawText
    progressInfo.Text = "Прогресс: 0/1"
    
    local currentTarget = nil
    
    while autoFarmEnabled do
        task.wait(0.016)
        
        -- Проверяем цель
        if not currentTarget or not currentTarget.Parent then
            currentTarget = nil
        else
            local hum = currentTarget:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then
                statusLabel.Text = "Цель убита!"
                task.wait(1)
                return true
            end
        end
        
        if not currentTarget then
            local mobs = findMobs(mobType)
            if #mobs == 0 then
                statusLabel.Text = "Поиск: The " .. mobType
                task.wait(0.5)
                continue
            end
            
            currentTarget = mobs[1]
            statusLabel.Text = "Лечу к: The " .. mobType
            
            -- Телепорт если далеко
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local mobPos = getPosition(currentTarget)
            if hrp and mobPos then
                local dist = (hrp.Position - mobPos).Magnitude
                if dist > 50 then
                    teleportTo(mobPos - Vector3.new(0, offsetBelow, 0))
                end
            end
        end
        
        if currentTarget then
            local success, dist = attackWithStableFlight(currentTarget, offsetBelow)
            if success and dist then
                statusLabel.Text = "Бью The " .. mobType .. " (" .. string.format("%.1f", dist) .. ")"
            end
        end
    end
    
    return false
end

-- ==================== ОСНОВНОЙ ЦИКЛ ====================
local function autoFarmLoop()
    while autoFarmEnabled do
        task.wait(0.5)
        
        local questText = getActiveQuestText()
        if not questText then
            statusLabel.Text = "Ищу квест..."
            questInfo.Text = "Квест: поиск"
            progressInfo.Text = "Прогресс: -"
            
            local papers = findQuestPapers()
            if #papers == 0 then
                statusLabel.Text = "Бумажек нет"
                task.wait(3)
                continue
            end
            
            table.sort(papers, function(a, b)
                return getQuestStars(a.Name) > getQuestStars(b.Name)
            end)
            
            local best = papers[1]
            statusLabel.Text = "Беру: " .. best.Name .. "★"
            
            if clickPaper(best) then
                statusLabel.Text = "Взят: " .. best.Name .. "★"
                task.wait(1.5)
            else
                statusLabel.Text = "Ошибка взятия"
                task.wait(2)
            end
            continue
        end
        
        local questData = parseQuest(questText)
        if not questData then
            statusLabel.Text = "Неизвестный квест, отменяю"
            clickCancelQuest()
            task.wait(1.5)
            continue
        end
        
        if questData.type == "hunt" then
            if questData.mob == "boar" or questData.mob == "wolf" then
                farmHuntQuest(questData)
            else
                statusLabel.Text = "Не Boar/Wolf, отменяю"
                clickCancelQuest()
                task.wait(1.5)
            end
            
        elseif questData.type == "defeat_the" then
            if questData.mob == "bandit" or questData.mob == "mafia" or questData.mob == "fighter" then
                farmDefeatTheQuest(questData)
            else
                statusLabel.Text = "Не тот The mob, отменяю"
                clickCancelQuest()
                task.wait(1.5)
            end
            
        elseif questData.type == "defeat" then
            statusLabel.Text = "Defeat X, отменяю"
            clickCancelQuest()
            task.wait(1.5)
            
        else
            statusLabel.Text = "Неизвестный тип, отменяю"
            clickCancelQuest()
            task.wait(1.5)
        end
    end
    
    statusLabel.Text = "Автофарм остановлен"
    questInfo.Text = "Квест: -"
    progressInfo.Text = "Прогресс: -"
end

-- ==================== КНОПКИ ====================
btnFarm.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    
    if autoFarmEnabled then
        btnFarm.Text = "Auto Farm: ON"
        btnFarm.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        task.spawn(autoFarmLoop)
    else
        btnFarm.Text = "Auto Farm: OFF"
        btnFarm.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    end
end)

btnESP.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    
    if espEnabled then
        btnESP.Text = "ESP: ON"
        btnESP.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= Player.Character then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if hum then
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = Color3.fromRGB(255, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Parent = obj
                end
            end
        end
    else
        btnESP.Text = "ESP: OFF"
        btnESP.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local highlight = obj:FindFirstChildOfClass("Highlight")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        frame.Visible = not frame.Visible
    end
end)

print("✅ Скрипт загружен!")
