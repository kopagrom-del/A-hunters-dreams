local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local VU = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "QuestFarm"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 280)
frame.Position = UDim2.new(0.5, -160, 0.5, -140)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 215, 0)
frame.Active = true
frame.Draggable = true
frame.Visible = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "QUEST FARM [R-SHIFT]"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local function MakeButton(text, y, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.Text = text
    btn.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(255, 215, 0)
    btn.Parent = frame
    return btn
end

local btnESP = MakeButton("ESP: ON", 45, Color3.fromRGB(0, 255, 0))
local btnFarm = MakeButton("Auto Farm: OFF", 90, Color3.fromRGB(255, 255, 255))
local btnQuest = MakeButton("Quest 4-5★: ON", 135, Color3.fromRGB(0, 255, 0))

local status = Instance.new("TextLabel")
status.Size = UDim2.new(0.9, 0, 0, 25)
status.Position = UDim2.new(0.05, 0, 0, 180)
status.BackgroundTransparency = 1
status.Text = "Готов"
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.Parent = frame

local questInfo = Instance.new("TextLabel")
questInfo.Size = UDim2.new(0.9, 0, 0, 25)
questInfo.Position = UDim2.new(0.05, 0, 0, 205)
questInfo.BackgroundTransparency = 1
questInfo.Text = "Квест: нет"
questInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
questInfo.Font = Enum.Font.Gotham
questInfo.TextSize = 11
questInfo.Parent = frame

local progressInfo = Instance.new("TextLabel")
progressInfo.Size = UDim2.new(0.9, 0, 0, 25)
progressInfo.Position = UDim2.new(0.05, 0, 0, 230)
progressInfo.BackgroundTransparency = 1
progressInfo.Text = "Прогресс: 0/0"
progressInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
progressInfo.Font = Enum.Font.Gotham
progressInfo.TextSize = 11
progressInfo.Parent = frame

local State = {
    ESP = true,
    AutoFarm = false,
    QuestFarm = true,
    IsFarming = false
}
local ESP_Table = {}
local FarmThread = nil

local function getPosition(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") or obj:IsA("UnionOperation") then
        return obj.Position
    elseif obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.Position end
        return obj:GetPivot().Position
    end
    local success, pos = pcall(function() return obj:GetPivot().Position end)
    if success then return pos end
    return nil
end

local function getCFrame(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") or obj:IsA("UnionOperation") then
        return obj.CFrame
    elseif obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.CFrame end
        return obj:GetPivot()
    end
    local success, cf = pcall(function() return obj:GetPivot() end)
    if success then return cf end
    return nil
end

local function teleportTo(pos)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    pcall(function()
        hrp.CFrame = CFrame.new(pos)
    end)
    
    pcall(function()
        TweenService:Create(hrp, TweenInfo.new(0.1), {CFrame = CFrame.new(pos)}):Play()
    end)
    
    pcall(function()
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(400000, 400000, 400000)
        bv.Velocity = (pos - hrp.Position).Unit * 500
        bv.Parent = hrp
        wait(0.1)
        bv:Destroy()
    end)
    
    return true
end

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

-- ==================== ИСПРАВЛЕННЫЙ ПАРСИНГ КВЕСТА ====================
local function getActiveQuest()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    local questUI = playerGui:FindFirstChild("QuestUI")
    if not questUI then return nil end
    
    local frame = questUI:FindFirstChild("Frame")
    if not frame then return nil end
    
    local questName = frame:FindFirstChild("QuestName")
    if not questName then return nil end
    
    local text = questName.Text
    if text == "" or text == "QUEST" then return nil end
    
    -- Парсим: "Hunt 10 Boar", "Defeat The Bandit", "Defeat 5 Wolf" и т.д.
    local lowerText = text:lower()
    local count, target = nil, nil
    
    -- Паттерн: Hunt/Defeat + число + цель (без "The")
    local huntPattern = text:match("[Hh]unt%s+(%d+)%s+([%w%s]+)")
    local defeatPattern = text:match("[Dd]efeat%s+(%d+)%s+([%w%s]+)")
    
    -- Паттерн с "The": "Defeat The Bandit" — отдельно обрабатываем
    local thePattern = text:match("[Dd]efeat%s+[Tt]he%s+([%w%s]+)")
    
    count, target = huntPattern or defeatPattern
    
    if thePattern and not count then
        -- Это квест в единственном числе: "Defeat The Bandit"
        target = thePattern
        count = "1"
    end
    
    if not count or not target then return nil end
    
    target = target:gsub("%s+$", "")
    
    local mobType = target:lower()
    if string.find(mobType, "boar") then mobType = "boar"
    elseif string.find(mobType, "wolf") then mobType = "wolf"
    elseif string.find(mobType, "bear") then mobType = "bear"
    elseif string.find(mobType, "mafia") then mobType = "mafia"
    elseif string.find(mobType, "bandit") then mobType = "bandit"
    elseif string.find(mobType, "fighter") then mobType = "fighter"
    elseif string.find(mobType, "thug") then mobType = "thug"
    else mobType = "unknown"
    end
    
    local playerStats = LocalPlayer:FindFirstChild("Player_Stats")
    local current = 0
    local total = tonumber(count) or 10
    
    if playerStats then
        local questProgress = playerStats:FindFirstChild("Quest_Progress")
        if questProgress then
            current = questProgress.Value
        end
    end
    
    return {
        mobType = mobType,
        targetName = target,
        total = total,
        current = current,
        rawText = text,
        hasThe = thePattern ~= nil -- флаг: квест с "The" (единственное число)
    }
end

-- ==================== ПРОВЕРКА: ЕДИНСТВЕННОЕ ЧИСЛО ====================
local function isSingleTargetQuest(questData)
    if not questData then return false end
    local lowerText = questData.rawText:lower()
    -- Если текст содержит "The" перед целью — это единственный моб
    if string.find(lowerText, "defeat the bandit") or 
       string.find(lowerText, "defeat the mafia") or 
       string.find(lowerText, "defeat the fighter") or
       string.find(lowerText, "hunt the") then
        return true
    end
    return false
end

local function clickPaper(paper)
    if not paper or not paper.Parent then return false end
    
    local cd = paper:FindFirstChild("ClickDetector")
    if cd then
        pcall(function() fireclickdetector(cd) end)
        wait(0.5)
        return true
    end
    
    local parent = paper.Parent
    if parent then
        cd = parent:FindFirstChild("ClickDetector")
        if cd then
            pcall(function() fireclickdetector(cd) end)
            wait(0.5)
            return true
        end
    end
    
    if parent and parent.Parent then
        cd = parent.Parent:FindFirstChild("ClickDetector")
        if cd then
            pcall(function() fireclickdetector(cd) end)
            wait(0.5)
            return true
        end
    end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local paperCF = getCFrame(paper)
        if paperCF then
            local oldCF = hrp.CFrame
            teleportTo(paperCF.Position + Vector3.new(0, 0, 2))
            wait(0.4)
            
            local pos = getPosition(paper)
            if pos then
                local screenPos = workspace.CurrentCamera:WorldToViewportPoint(pos)
                VU:CaptureController()
                VU:ClickButton1(Vector2.new(screenPos.X, screenPos.Y))
                wait(0.3)
            end
            
            teleportTo(oldCF.Position)
            return true
        end
    end
    return false
end

local function clickCancelQuest()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    
    local questUI = playerGui:FindFirstChild("QuestUI")
    if not questUI then return false end
    
    for _, gui in pairs(questUI:GetDescendants()) do
        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            local text = gui.Text:lower()
            if string.find(text, "cancel") or string.find(text, "отмен") then
                gui:Click()
                wait(0.5)
                return true
            end
        end
    end
    return false
end

-- ==================== ИСПРАВЛЕННЫЙ ПОИСК МОБОВ ====================
local function findMobs(mobType)
    local mobs = {}
    mobType = mobType:lower()
    
    -- Папки где лежат мобы (по твоим скриншотам)
    local foldersToCheck = {
        Workspace,
        Workspace:FindFirstChild("Fx"),        -- Boar лежат тут
        Workspace:FindFirstChild("Assets"),    -- Bandit лежат тут
        Workspace:FindFirstChild("Mobs"),
        Workspace:FindFirstChild("Enemies"),
        Workspace:FindFirstChild("NPCs"),
        Workspace:FindFirstChild("Map"),
    }
    
    for _, folder in pairs(foldersToCheck) do
        if folder then
            for _, obj in pairs(folder:GetDescendants()) do
                if obj:IsA("Model") and obj ~= LocalPlayer.Character then
                    local name = obj.Name:lower()
                    -- Точное совпадение ИЛИ содержит в имени
                    if name == mobType or string.find(name, mobType, 1, true) then
                        local hum = obj:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            table.insert(mobs, obj)
                        end
                    end
                end
            end
        end
    end
    
    return mobs
end

local function lookAt(hrp, targetPos)
    local direction = (targetPos - hrp.Position).Unit
    hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(direction.X, 0, direction.Z))
end

-- ==================== ИСПРАВЛЕННОЕ УБИЙСТВО МОБА ====================
local function killMob(mob)
    if not mob or not mob.Parent then return false end
    
    local hum = mob:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    -- Находим часть моба для позиционирования
    local mobHRP = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso") or mob:FindFirstChild("UpperTorso")
    if not mobHRP then
        for _, part in pairs(mob:GetDescendants()) do
            if part:IsA("BasePart") then
                mobHRP = part
                break
            end
        end
    end
    if not mobHRP then return false end
    
    local tool = char:FindFirstChildOfClass("Tool")
    
    -- Летим над мобом и бьём, пока не умрёт
    while hum and hum.Parent and hum.Health > 0 do
        local mobPos = mobHRP.Position
        local hoverPos = mobPos + Vector3.new(0, 6, 0) -- ~1.5-2 шага над мобом
        
        teleportTo(hoverPos)
        lookAt(hrp, mobPos)
        
        if tool then
            pcall(function() tool:Activate() end)
        else
            -- Бьём руками (для мобильных)
            VU:CaptureController()
            VU:Button1Down(Vector2.new(0, 0))
            wait(0.05)
            VU:Button1Up(Vector2.new(0, 0))
        end
        
        wait(0.1)
    end
    
    wait(0.2)
    return true
end

local function farmQuest(questData)
    if not questData then return false end
    
    if questData.mobType == "unknown" then
        status.Text = "Неизвестный квест"
        questInfo.Text = "Отменяю"
        clickCancelQuest()
        wait(1)
        return false
    end
    
    State.IsFarming = true
    status.Text = "Фарм: " .. questData.targetName
    questInfo.Text = "Квест: " .. questData.targetName
    progressInfo.Text = "Прогресс: " .. questData.current .. "/" .. questData.total
    
    while State.AutoFarm do
        task.wait(0.2)
        
        local currentQuest = getActiveQuest()
        if currentQuest then
            questData.current = currentQuest.current
            progressInfo.Text = "Прогресс: " .. currentQuest.current .. "/" .. currentQuest.total
            
            if currentQuest.current >= currentQuest.total then
                status.Text = "Квест выполнен!"
                State.IsFarming = false
                return true
            end
        else
            break
        end
        
        local mobs = findMobs(questData.mobType)
        if #mobs == 0 then
            status.Text = "Мобы не найдены: " .. questData.mobType
            task.wait(1)
            continue
        end
        
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        table.sort(mobs, function(a, b)
            local posA = getPosition(a)
            local posB = getPosition(b)
            if not posA or not posB or not hrp then return false end
            return (posA - hrp.Position).Magnitude < (posB - hrp.Position).Magnitude
        end)
        
        local mob = mobs[1]
        status.Text = "Атакую: " .. questData.mobType .. " (" .. #mobs .. ")"
        
        if killMob(mob) then
            wait(0.2)
        else
            wait(0.1)
        end
    end
    
    State.IsFarming = false
    return false
end

local function autoFarmLoop()
    while State.AutoFarm do
        task.wait(0.5)
        
        local activeQuest = getActiveQuest()
        
        if activeQuest then
            -- ==================== ЕДИНСТВЕННОЕ ЧИСЛО — ОТМЕНЯЕМ ====================
            if isSingleTargetQuest(activeQuest) then
                status.Text = "Единичный моб, отменяю..."
                questInfo.Text = "Отмена: " .. activeQuest.targetName
                clickCancelQuest()
                wait(1.5)
                continue
            end
            
            if activeQuest.current < activeQuest.total then
                farmQuest(activeQuest)
            elseif activeQuest.current >= activeQuest.total then
                status.Text = "Квест выполнен!"
                questInfo.Text = "Квест: выполнен"
                progressInfo.Text = "Прогресс: " .. activeQuest.current .. "/" .. activeQuest.total
                task.wait(2)
            end
        else
            if State.IsFarming then
                State.IsFarming = false
            end
            
            status.Text = "Ищу квест..."
            questInfo.Text = "Квест: поиск"
            progressInfo.Text = "Прогресс: -"
            
            local papers = findQuestPapers()
            if #papers == 0 then
                status.Text = "Бумажек нет"
                task.wait(3)
                continue
            end
            
            table.sort(papers, function(a, b)
                return getQuestStars(a.Name) > getQuestStars(b.Name)
            end)
            
            local best = papers[1]
            local stars = getQuestStars(best.Name)
            
            status.Text = "Беру: " .. best.Name .. "★"
            
            if clickPaper(best) then
                status.Text = "Взят: " .. best.Name .. "★"
                task.wait(1)
            else
                status.Text = "Ошибка взятия"
                task.wait(2)
            end
        end
    end
    
    status.Text = "Автофарм остановлен"
    questInfo.Text = "Квест: -"
    progressInfo.Text = "Прогресс: -"
end

btnESP.MouseButton1Click:Connect(function()
    State.ESP = not State.ESP
    btnESP.Text = State.ESP and "ESP: ON" or "ESP: OFF"
    btnESP.TextColor3 = State.ESP and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    for _, data in pairs(ESP_Table) do
        if data.Highlight then data.Highlight.Enabled = State.ESP end
        if data.Billboard then data.Billboard.Enabled = State.ESP end
    end
end)

btnFarm.MouseButton1Click:Connect(function()
    State.AutoFarm = not State.AutoFarm
    btnFarm.Text = State.AutoFarm and "Auto Farm: ON" or "Auto Farm: OFF"
    btnFarm.TextColor3 = State.AutoFarm and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
    
    if State.AutoFarm then
        if FarmThread then task.cancel(FarmThread) end
        FarmThread = task.spawn(autoFarmLoop)
    else
        if FarmThread then
            task.cancel(FarmThread)
            FarmThread = nil
        end
        State.IsFarming = false
    end
end)

btnQuest.MouseButton1Click:Connect(function()
    State.QuestFarm = not State.QuestFarm
    btnQuest.Text = State.QuestFarm and "Quest 4-5★: ON" or "Quest 4-5★: OFF"
    btnQuest.TextColor3 = State.QuestFarm and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        frame.Visible = not frame.Visible
    end
end)

local function createESP(obj)
    if ESP_Table[obj] then return end
    if not obj or not obj.Parent then return end
    
    local h = Instance.new("Highlight")
    h.FillColor = Color3.fromRGB(255, 215, 0)
    h.OutlineColor = Color3.fromRGB(255, 255, 255)
    h.Enabled = State.ESP
    h.Parent = obj
    
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 100, 0, 25)
    bb.AlwaysOnTop = true
    bb.Enabled = State.ESP
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.Parent = obj
    
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 1, 0)
    t.BackgroundTransparency = 1
    t.Text = "📄 " .. obj.Name .. "★ (" .. getQuestStars(obj.Name) .. "★)"
    t.TextColor3 = Color3.fromRGB(255, 215, 0)
    t.TextScaled = true
    t.Font = Enum.Font.GothamBold
    t.Parent = bb
    
    ESP_Table[obj] = {Highlight = h, Billboard = bb, Parent then return end
    
    local h = Instance.new("Highlight")
    h.FillColor = Color3.fromRGB(255, 215, 0)
    h.OutlineColor = Color3.fromRGB(255, 255, 255)
    h.Enabled = State.ESP
    h.Parent = obj
    
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 100, 0, 25)
    bb.AlwaysOnTop = true
    bb.Enabled = State.ESP
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.Parent = obj
    
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 1, 0)
    t.BackgroundTransparency = 1
    t.Text = "📄 " .. obj.Name .. "★ (" .. getQuestStars(obj.Name) .. "★)"
    t.TextColor3 = Color3.fromRGB(255, 215, 0)
    t.TextScaled = true
    t.Font = Enum.Font.GothamBold
    t.Parent = bb
    
    ESP_Table[obj] = {Highlight = h, Billboard = bb, Part = obj}
end

local function cleanupESP()
    for obj, data in pairs(ESP_Table) do
        if not obj or not obj.Parent then
            if data.Highlight then data.Highlight:Destroy() end
            if data.Billboard then data.Billboard:Destroy() end
            ESP_Table[obj] = nil
        end
    end
end

task.spawn(function()
    while true do
        task.wait(2)
        cleanupESP()
        local papers = findQuestPapers()
        for _, p in pairs(papers) do
            createESP(p)
        end
    end
end)

print("✅ Quest Farm загружен")
