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

print("✅ GUI создан")

local autoFarmEnabled = false
local espEnabled = false

-- ==================== БЕЗОПАСНЫЕ ФУНКЦИИ ====================
local function getSafePosition(obj)
    if not obj then return nil end
    
    -- Пробуем разные способы получить позицию
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        if obj.PrimaryPart then
            return obj.PrimaryPart.Position
        end
        local hrp = obj:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:IsA("BasePart") then
            return hrp.Position
        end
        local torso = obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso")
        if torso and torso:IsA("BasePart") then
            return torso.Position
        end
    end
    
    return nil
end

local function teleportToSafe(pos)
    if not pos then return false end
    
    local char = Player.Character
    if not char then return false end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    -- Защита от провала под карту
    local safeY = math.max(pos.Y, 1)
    local safePos = Vector3.new(pos.X, safeY, pos.Z)
    
    local success, err = pcall(function()
        hrp.CFrame = CFrame.new(safePos)
    end)
    
    if success then
        return true
    else
        warn("⚠️ Ошибка телепорта:", err)
        return false
    end
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

-- ==================== ПОИСК МОБОВ ====================
local function findMobs(mobType)
    local mobs = {}
    mobType = mobType:lower()
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= Player.Character then
            local name = obj.Name:lower()
            
            if name == mobType or string.find(name, mobType, 1, true) then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if not hum then hum = obj:FindFirstChild("Humanoid") end
                
                if hum and hum.Health and hum.Health > 0 then
                    -- Проверяем что можем получить позицию
                    local pos = getSafePosition(obj)
                    if pos then
                        table.insert(mobs, obj)
                    end
                end
            end
        end
    end
    
    return mobs
end

-- ==================== ТЕЛЕПОРТ + ПЛАВНЫЙ ПОЛЁТ ====================
local currentFlightTarget = nil
local lastTeleportTime = 0

-- Мгновенный телепорт к цели
local function teleportToMob(mob, offsetBelow)
    if not mob then return false end
    
    local mobPos = getSafePosition(mob)
    if not mobPos then return false end
    
    -- Позиция под мобом
    local targetPos = Vector3.new(mobPos.X, mobPos.Y - offsetBelow, mobPos.Z)
    targetPos = Vector3.new(targetPos.X, math.max(targetPos.Y, 1), targetPos.Z)
    
    -- ТЕЛЕПОРТИРУЕМСЯ
    local success = teleportToSafe(targetPos)
    
    if success then
        -- Поворачиваемся к мобу
        local char = Player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(hrp.Position, mobPos)
            end
        end
    end
    
    return success
end

-- Плавная корректировка позиции (для полёта рядом с мобом)
local function adjustPosition(mob, offsetBelow)
    if not mob then return end
    
    local mobPos = getSafePosition(mob)
    if not mobPos then return end
    
    local char = Player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local targetPos = Vector3.new(mobPos.X, mobPos.Y - offsetBelow, mobPos.Z)
    targetPos = Vector3.new(targetPos.X, math.max(targetPos.Y, 1), targetPos.Z)
    
    local currentPos = hrp.Position
    local distance = (targetPos - currentPos).Magnitude
    
    -- Если далеко - телепорт, если близко - плавное движение
    if distance > 15 then
        -- Слишком далеко - телепорт
        teleportToMob(mob, offsetBelow)
    elseif distance > 0.5 then
        -- Близко - плавное движение
        local direction = (targetPos - currentPos).Unit
        local speed = 50 -- Скорость полёта
        local newPos = currentPos + direction * math.min(distance, speed * 0.016)
        
        hrp.CFrame = CFrame.new(newPos, mobPos)
    end
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

-- ==================== АТАКА ====================
local function attackMob(mob)
    if not mob then return end
    
    local char = Player.Character
    if not char then return end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        pcall(function() tool:Activate() end)
    end
end

-- ==================== ФАРМ HUNT ====================
local function farmHuntQuest(questData)
    local mobType = questData.mob
    local targetCount = questData.count
    local offsetBelow = 0.5
    
    statusLabel.Text = "Фарм: Hunt " .. targetCount .. " " .. mobType
    questInfo.Text = "Квест: " .. questData.rawText
    
    local currentTarget = nil
    local lastTargetCheck = 0
    
    while autoFarmEnabled do
        task.wait(0.016)
        
        local currentProgress = getQuestProgress()
        progressInfo.Text = "Прогресс: " .. currentProgress .. "/" .. targetCount
        
        if currentProgress >= targetCount then
            statusLabel.Text = "Квест выполнен!"
            return true
        end
        
        -- Проверяем текущую цель
        if currentTarget then
            if not currentTarget.Parent then
                currentTarget = nil
            else
                local hum = currentTarget:FindFirstChildOfClass("Humanoid")
                if not hum then hum = currentTarget:FindFirstChild("Humanoid") end
                if not hum or hum.Health <= 0 then
                    currentTarget = nil
                end
            end
        end
        
        -- Ищем новую цель если нужно
        if not currentTarget then
            local mobs = findMobs(mobType)
            if #mobs == 0 then
                statusLabel.Text = "Поиск: " .. mobType
                task.wait(0.3)
                continue
            end
            
            -- Сортируем по расстоянию
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local myPos = hrp and getSafePosition(char)
            
            table.sort(mobs, function(a, b)
                local posA = getSafePosition(a)
                local posB = getSafePosition(b)
                if not posA or not posB or not myPos then return false end
                return (posA - myPos).Magnitude < (posB - myPos).Magnitude
            end)
            
            currentTarget = mobs[1]
            statusLabel.Text = "ТЕЛЕПОРТ к: " .. mobType
            
            -- МГНОВЕННЫЙ ТЕЛЕПОРТ к новой цели
            teleportToMob(currentTarget, offsetBelow)
        end
        
        -- ПЛАВНЫЙ ПОЛЁТ и атака
        if currentTarget then
            adjustPosition(currentTarget, offsetBelow)
            attackMob(currentTarget)
            
            local mobPos = getSafePosition(currentTarget)
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if mobPos and hrp then
                local dist = (mobPos - hrp.Position).Magnitude
                statusLabel.Text = "Бью: " .. mobType .. " (" .. string.format("%.1f", dist) .. ")"
            end
        end
    end
    
    return false
end

-- ==================== ФАРМ DEFEAT THE ====================
local function farmDefeatTheQuest(questData)
    local mobType = questData.mob
    local offsetBelow = 1
    
    statusLabel.Text = "Фарм: Defeat The " .. mobType
    questInfo.Text = "Квест: " .. questData.rawText
    progressInfo.Text = "Прогресс: 0/1"
    
    local currentTarget = nil
    
    while autoFarmEnabled do
        task.wait(0.016)
        
        if currentTarget then
            if not currentTarget.Parent then
                currentTarget = nil
            else
                local hum = currentTarget:FindFirstChildOfClass("Humanoid")
                if not hum then hum = currentTarget:FindFirstChild("Humanoid") end
                if not hum or hum.Health <= 0 then
                    statusLabel.Text = "Цель убита!"
                    task.wait(1)
                    return true
                end
            end
        end
        
        if not currentTarget then
            local mobs = findMobs(mobType)
            if #mobs == 0 then
                statusLabel.Text = "Поиск: The " .. mobType
                task.wait(0.3)
                continue
            end
            
            currentTarget = mobs[1]
            statusLabel.Text = "ТЕЛЕПОРТ к: The " .. mobType
            
            teleportToMob(currentTarget, offsetBelow)
        end
        
        if currentTarget then
            adjustPosition(currentTarget, offsetBelow)
            attackMob(currentTarget)
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
                if not hum then hum = obj:FindFirstChild("Humanoid") end
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

print("✅ Скрипт загружен! Телепорт + плавный полёт")
