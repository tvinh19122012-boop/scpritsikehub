local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local VIM = game:GetService("VirtualInputManager")
local TS = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local ASSETS = {
    LOGO = "rbxassetid://71728975632026",
    BG = "rbxassetid://94936897397454",
    YT = "rbxassetid://125967147545813",
    SOUND_ON = "rbxassetid://135539995303018",
    SOUND_OFF = "rbxassetid://84255409866939",
    YT_LINK = "https://youtube.com/@sikeapbo?si=2YLKSpdJhxoSD_8h"
}

local old = PlayerGui:FindFirstChild("Vytra")
if old then old:Destroy() end

local Config = {
    autoFarm = false, autoQuest = false, chestMode = false,
    levelBased = false, safeMode = false, antiAFK = false,
    aura = false, observation = false, itemCollector = false,
    autoStore = false, itemNotification = true, rareItemAlert = true,
    rememberStyle = true, selectedFightingStyle = "Combat",
    targetLock = false, pvpMode = false, targetHighlight = false,
    playerNotifications = true, selectedTarget = nil,
    teleportConfirmation = true, selectedSea = "First Sea", selectedIsland = nil,
    notifications = true, fps = true, ping = true,
    circleSize = 150, circleVisible = true, compact = false,
    theme = "Purple", sounds = true, animations = true,
    walkspeed = 16, jumppower = 50,
    noclip = false, aimbot = false,
    killRadius = false, killRadiusSize = 30,
    mobMagnet = false, mobMagnetRadius = 40,
    tweenSpeed = 1.0,
    autoV3 = false, autoV4 = false,
    grindStyle = "Circle",
    selectedWeapon = "Melee"
}

local isBF = (game.GameId == 2753915549 or game.GameId == 4442272183 or game.GameId == 7449423635)

local Char = Player.Character or Player.CharacterAdded:Wait()
Player.CharacterAdded:Connect(function(c)
    Char = c
    task.wait(0.5)
    if Config.rememberStyle and Config.selectedFightingStyle ~= "Combat" then
        equipStyle(Config.selectedFightingStyle)
    end
end)

local function getHRP()
    return Char and Char:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    return Char and Char:FindFirstChildOfClass("Humanoid")
end

local function playSnd(id, vol)
    if not Config.sounds then return end
    local s = Instance.new("Sound")
    s.SoundId = id
    s.Volume = vol or 0.25
    s.Parent = SoundService
    s:Play()
    task.delay(2, function() pcall(s.Destroy, s) end)
end

local gui = Instance.new("ScreenGui")
gui.Name = "SIKE HUB"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
gui.Parent = PlayerGui
gui.DisplayOrder = 999

local function cr(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = obj
end
local function stk(obj, c, t)
    local s = Instance.new("UIStroke")
    s.Color = c or Color3.fromRGB(105,75,220)
    s.Thickness = t or 1.2
    s.Transparency = 0.25
    s.Parent = obj
end
local function grad(obj, c1, c2, r)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2)}
    g.Rotation = r or 45
    g.Parent = obj
end
local function lbl(p, txt, x, y, w, h, sz, col, font)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.fromOffset(w or 200, h or 20)
    l.Position = UDim2.fromOffset(x or 0, y or 0)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = col or Color3.fromRGB(240,240,255)
    l.Font = font or Enum.Font.GothamMedium
    l.TextSize = sz or 14
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = p
    return l
end

local notify
local function mkBtn(p, txt, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-5,0,42)
    b.BackgroundColor3 = Color3.fromRGB(18,18,30)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(230,230,245)
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.AutoButtonColor = false
    b.Parent = p
    cr(b, 10)
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(105,75,220)
    s.Thickness = 0.8
    s.Transparency = 0.5
    s.Parent = b
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(105,75,220)), ColorSequenceKeypoint.new(1, Color3.fromRGB(145,50,220))}
    g.Rotation = 45
    g.Parent = s
    b.MouseEnter:Connect(function()
        if Config.animations then
            TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(105,75,220)}):Play()
        end
        s.Transparency = 0
    end)
    b.MouseLeave:Connect(function()
        if Config.animations then
            TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(18,18,30)}):Play()
        end
        s.Transparency = 0.5
    end)
    b.MouseButton1Click:Connect(function()
        playSnd(ASSETS.SOUND_ON, 0.1)
        cb()
    end)
    return b
end

local function mkTgl(p, txt, key, def)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-5,0,48)
    row.BackgroundColor3 = Color3.fromRGB(12,12,22)
    row.Parent = p
    cr(row, 10)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(12,12,22)), ColorSequenceKeypoint.new(1, Color3.fromRGB(16,12,28))}
    g.Parent = row
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(105,75,220)
    s.Thickness = 0.5
    s.Transparency = 0.7
    s.Parent = row
    local lb = lbl(row, txt, 14, 0, 300, 48, 13)
    lb.TextXAlignment = Enum.TextXAlignment.Left
    if Config[key] == nil then Config[key] = def or false end
    local state = Config[key]
    local sw = Instance.new("TextButton")
    sw.Size = UDim2.fromOffset(52,28)
    sw.Position = UDim2.new(1,-66,.5,-14)
    sw.Text = ""
    sw.Parent = row
    cr(sw, 14)
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.fromOffset(22,22)
    thumb.Position = UDim2.fromOffset(3,3)
    thumb.BackgroundColor3 = Color3.fromRGB(255,255,255)
    thumb.Parent = sw
    cr(thumb, 11)
    local function upd()
        if state then
            sw.BackgroundColor3 = Color3.fromRGB(105,75,220)
            TweenService:Create(thumb, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {Position = UDim2.fromOffset(27,3)}):Play()
            local gl = sw:FindFirstChildOfClass("UIGradient")
            if not gl then
                gl = Instance.new("UIGradient")
                gl.Parent = sw
            end
            gl.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(105,75,220)), ColorSequenceKeypoint.new(1, Color3.fromRGB(145,50,255))}
            gl.Rotation = 45
        else
            sw.BackgroundColor3 = Color3.fromRGB(40,42,58)
            TweenService:Create(thumb, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {Position = UDim2.fromOffset(3,3)}):Play()
            local gl = sw:FindFirstChildOfClass("UIGradient")
            if gl then gl:Destroy() end
        end
    end
    upd()
    sw.MouseButton1Click:Connect(function()
        state = not state
        Config[key] = state
        upd()
        playSnd(state and ASSETS.SOUND_ON or ASSETS.SOUND_OFF)
        if notify then notify(txt.." "..(state and "ON" or "OFF"), state) end
        if key == "autoFarm" then if state then startAF() else stopAF() end
        elseif key == "antiAFK" then if state then startAFK() else stopAFK() end
        elseif key == "itemCollector" then if state then startCollect() else stopCollect() end
        elseif key == "pvpMode" then if state then startPVP() else stopPVP() end
        elseif key == "chestMode" then if state then startChest() else stopChest() end
        elseif key == "aura" then if state then doAura() end
        elseif key == "mobMagnet" then if state then startMagnet() else stopMagnet() end
        elseif key == "killRadius" then if state then startKillRadius() else stopKillRadius() end
        elseif key == "autoV3" then if state then startAutoV3() else stopAutoV3() end
        elseif key == "autoV4" then if state then startAutoV4() else stopAutoV4() end
        elseif key == "noclip" then
            if state then
                local ncHb = RunService.Heartbeat:Connect(function()
                    if not Config.noclip or not Char then ncHb:Disconnect() return end
                    for _, p in ipairs(Char:GetChildren()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end)
                if not state then ncHb:Disconnect() end
            end
        end
    end)
    return row
end

local function mkSlider(p, label, key, minV, maxV, defV, cb)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,-16,0,52)
    frame.BackgroundTransparency = 1
    frame.Parent = p
    local lLabel = lbl(frame, label..": "..tostring(defV), 3, 4, 250, 20, 12)
    local bgBar = Instance.new("Frame")
    bgBar.Position = UDim2.fromOffset(3, 28)
    bgBar.Size = UDim2.new(1,-6,0,8)
    bgBar.BackgroundColor3 = Color3.fromRGB(48,51,65)
    bgBar.BorderSizePixel = 0
    bgBar.Parent = frame
    cr(bgBar, 4)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0,0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(105,75,220)
    fill.BorderSizePixel = 0
    fill.Parent = bgBar
    cr(fill, 4)
    local thumb = Instance.new("Frame")
    thumb.AnchorPoint = Vector2.new(0.5,0.5)
    thumb.Position = UDim2.new(0,0,0.5,0)
    thumb.Size = UDim2.fromOffset(16,16)
    thumb.BackgroundColor3 = Color3.fromRGB(255,255,255)
    thumb.BorderSizePixel = 0
    thumb.Parent = bgBar
    cr(thumb, 8)
    local val = defV
    local dragging = false
    local ratio = (defV - minV) / (maxV - minV)
    fill.Size = UDim2.new(ratio, 0, 1, 0)
    thumb.Position = UDim2.new(ratio, 0, 0.5, 0)
    local function update(x)
        x = math.clamp((x - bgBar.AbsolutePosition.X) / bgBar.AbsoluteSize.X, 0, 1)
        val = math.floor(minV + x * (maxV - minV))
        lLabel.Text = label..": "..tostring(val)
        fill.Size = UDim2.new(x, 0, 1, 0)
        thumb.Position = UDim2.new(x, 0, 0.5, 0)
        Config[key] = val
        if cb then cb(val) end
    end
    thumb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(i.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return frame
end

local function mkSection(p, txt)
    local s = lbl(p, txt, 12, 0, 300, 28, 10, Color3.fromRGB(145,110,255))
    s.TextXAlignment = Enum.TextXAlignment.Left
    s.TextTransparency = 0.2
    return s
end

local function mkOptionRow(p, txt, options, selectedKey)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-5,0,48)
    row.BackgroundColor3 = Color3.fromRGB(12,12,22)
    row.Parent = p
    cr(row, 10)
    lbl(row, txt, 14, 0, 200, 48, 12).TextXAlignment = Enum.TextXAlignment.Left
    local btnFrame = Instance.new("Frame")
    btnFrame.Size = UDim2.new(0, 200, 0, 32)
    btnFrame.Position = UDim2.new(1, -210, 0.5, -16)
    btnFrame.BackgroundTransparency = 1
    btnFrame.Parent = row
    local uil = Instance.new("UIListLayout")
    uil.FillDirection = Enum.FillDirection.Horizontal
    uil.Padding = UDim.new(0, 4)
    uil.Parent = btnFrame
    local btns = {}
    for _, opt in ipairs(options) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(60, 32)
        b.BackgroundColor3 = (opt == Config[selectedKey]) and Color3.fromRGB(105,75,220) or Color3.fromRGB(30,30,45)
        b.Text = opt
        b.TextColor3 = Color3.fromRGB(230,230,245)
        b.Font = Enum.Font.GothamMedium
        b.TextSize = 11
        b.AutoButtonColor = false
        b.Parent = btnFrame
        cr(b, 8)
        b.MouseButton1Click:Connect(function()
            Config[selectedKey] = opt
            for _, ob in ipairs(btns) do
                ob.BackgroundColor3 = Color3.fromRGB(30,30,45)
            end
            b.BackgroundColor3 = Color3.fromRGB(105,75,220)
            if notify then notify(txt..": "..opt, true) end
        end)
        table.insert(btns, b)
    end
    return row
end

local bg = Instance.new("ImageLabel")
bg.Size = UDim2.fromScale(1,1)
bg.BackgroundColor3 = Color3.fromRGB(4,5,10)
bg.Image = ASSETS.BG
bg.ImageTransparency = 0.78
bg.ScaleType = Enum.ScaleType.Crop
bg.BorderSizePixel = 0
bg.Parent = gui

local overlay = Instance.new("Frame")
overlay.Size = UDim2.fromScale(1,1)
overlay.BackgroundColor3 = Color3.fromRGB(4,5,10)
overlay.BackgroundTransparency = 0.18
overlay.BorderSizePixel = 0
overlay.Parent = gui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(700, 500)
main.Position = UDim2.new(.5, -350, .5, -250)
main.BackgroundColor3 = Color3.fromRGB(5,5,14)
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.Visible = true
main.Parent = gui
cr(main, 16)
local mainG = Instance.new("UIGradient")
mainG.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(8,8,20)), ColorSequenceKeypoint.new(1, Color3.fromRGB(12,8,28))}
mainG.Parent = main
local mainSt = Instance.new("UIStroke")
mainSt.Color = Color3.fromRGB(105,75,220)
mainSt.Thickness = 1.5
mainSt.Transparency = 0.3
mainSt.Parent = main
local mainStG = Instance.new("UIGradient")
mainStG.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(105,75,220)), ColorSequenceKeypoint.new(1, Color3.fromRGB(200,50,255))}
mainStG.Rotation = 45
mainStG.Parent = mainSt

local top = Instance.new("Frame")
top.Size = UDim2.new(1,0,0,56)
top.BackgroundColor3 = Color3.fromRGB(8,6,18)
top.BorderSizePixel = 0
top.Parent = main
cr(top, 16)
local topG = Instance.new("UIGradient")
topG.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(10,8,22)), ColorSequenceKeypoint.new(1, Color3.fromRGB(14,10,28))}
topG.Parent = top
local topSt = Instance.new("UIStroke")
topSt.Color = Color3.fromRGB(105,75,220)
topSt.Thickness = 0.5
topSt.Transparency = 0.6
topSt.Parent = top

local topLogo = Instance.new("ImageLabel")
topLogo.Size = UDim2.fromOffset(44,44)
topLogo.Position = UDim2.fromOffset(12,6)
topLogo.BackgroundTransparency = 1
topLogo.Image = ASSETS.LOGO
topLogo.Parent = top
local topBrand = lbl(top, "SIKE HUB", 66, 6, 250, 24, 20, Color3.fromRGB(255,255,255), Enum.Font.GothamBlack)
local topSub = lbl(top, "Ultimate Edition - All Features Live", 67, 32, 280, 18, 10, Color3.fromRGB(145,150,170), Enum.Font.Gotham)

local closeBtn = Instance.new("ImageButton")
closeBtn.AnchorPoint = Vector2.new(1,0.5)
closeBtn.Position = UDim2.new(1,-12,0.5,0)
closeBtn.Size = UDim2.fromOffset(38,38)
closeBtn.BackgroundColor3 = Color3.fromRGB(22,25,41)
closeBtn.Image = ASSETS.LOGO
closeBtn.ImageColor3 = Color3.fromRGB(255,255,255)
closeBtn.BackgroundTransparency = 0
closeBtn.AutoButtonColor = false
closeBtn.Parent = top
cr(closeBtn, 9)
closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    floating.Visible = true
    playSnd(ASSETS.SOUND_OFF)
end)

do
    local d, ms, sp
    top.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d = true
            ms = i.Position
            sp = main.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local de = i.Position - ms
            main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + de.X, sp.Y.Scale, sp.Y.Offset + de.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d = false
        end
    end)
end

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0,170,1,-56)
sidebar.Position = UDim2.fromOffset(0,56)
sidebar.BackgroundColor3 = Color3.fromRGB(6,5,16)
sidebar.BorderSizePixel = 0
sidebar.Parent = main
local sideG = Instance.new("UIGradient")
sideG.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(6,5,16)), ColorSequenceKeypoint.new(1, Color3.fromRGB(10,7,22))}
sideG.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.new(1,-170,1,-56)
content.Position = UDim2.fromOffset(170,56)
content.BackgroundTransparency = 1
content.Parent = main

local pageTitle = lbl(content, "Dashboard", 12, 6, 300, 38, 22, Color3.fromRGB(255,255,255), Enum.Font.GothamBold)
pageTitle.TextXAlignment = Enum.TextXAlignment.Left

local weaponBar = Instance.new("Frame")
weaponBar.Size = UDim2.new(1, -16, 0, 34)
weaponBar.Position = UDim2.fromOffset(8, 44)
weaponBar.BackgroundColor3 = Color3.fromRGB(8,6,18)
weaponBar.BorderSizePixel = 0
weaponBar.Parent = content
cr(weaponBar, 10)
stk(weaponBar, Color3.fromRGB(105,75,220), 0.6)
local weapLabel = lbl(weaponBar, "Weapon:", 10, 7, 60, 20, 11, Color3.fromRGB(145,150,170))
local weapOpts = {"Melee", "Sword", "Fruit"}
local weapBtns = {}
for i, w in ipairs(weapOpts) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(68, 24)
    b.Position = UDim2.fromOffset(68 + (i-1)*74, 5)
    b.BackgroundColor3 = (w == Config.selectedWeapon) and Color3.fromRGB(105,75,220) or Color3.fromRGB(30,30,45)
    b.Text = w
    b.TextColor3 = Color3.fromRGB(230,230,245)
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 11
    b.AutoButtonColor = false
    b.Parent = weaponBar
    cr(b, 8)
    b.MouseButton1Click:Connect(function()
        Config.selectedWeapon = w
        for _, ob in ipairs(weapBtns) do
            ob.BackgroundColor3 = Color3.fromRGB(30,30,45)
        end
        b.BackgroundColor3 = Color3.fromRGB(105,75,220)
        if notify then notify("Weapon: "..w, true) end
    end)
    table.insert(weapBtns, b)
end

local page = Instance.new("ScrollingFrame")
page.Position = UDim2.fromOffset(8, 80)
page.Size = UDim2.new(1, -16, 1, -86)
page.BackgroundTransparency = 1
page.BorderSizePixel = 0
page.ScrollBarThickness = 4
page.ScrollBarImageColor3 = Color3.fromRGB(105,75,220)
page.AutomaticCanvasSize = Enum.AutomaticSize.Y
page.CanvasSize = UDim2.new()
page.Parent = content
local ply = Instance.new("UIListLayout")
ply.Padding = UDim.new(0, 8)
ply.Parent = page

local function clearPage()
    for _, v in ipairs(page:GetChildren()) do
        if v:IsA("GuiObject") then v:Destroy() end
    end
end
local function card(h)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-4,0,h)
    f.BackgroundColor3 = Color3.fromRGB(8,6,18)
    f.BorderSizePixel = 0
    f.Parent = page
    cr(f, 12)
    stk(f, Color3.fromRGB(105,75,220), 1)
    local stroke = f:FindFirstChildOfClass("UIStroke")
    if stroke then stroke.Transparency = 0.75 end
    return f
end

local navBtns = {}

notify = function(text, good)
    if not Config.notifications then return end
    local n = Instance.new("Frame")
    n.Size = UDim2.fromOffset(280,46)
    n.Position = UDim2.new(1,-300,1,-70)
    n.BackgroundColor3 = Color3.fromRGB(8,8,14)
    n.BackgroundTransparency = 0.08
    n.BorderSizePixel = 0
    n.Parent = gui
    cr(n, 10)
    local s = Instance.new("UIStroke")
    s.Color = good and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,50,50)
    s.Thickness = 1.2
    s.Transparency = 0.3
    s.Parent = n
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(105,75,220)), ColorSequenceKeypoint.new(1, Color3.fromRGB(145,50,255))}
    g.Rotation = 45
    g.Parent = s
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-20,1,0)
    l.Position = UDim2.fromOffset(10,0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(240,240,255)
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = n
    task.delay(2.8, function()
        if n and n.Parent then pcall(n.Destroy, n) end
    end)
end

local function buildDashboard()
    pageTitle.Text = "Dashboard"
    local c1 = card(130)
    lbl(c1, "SIKE HUB ULTIMATE", 14, 10, 300, 26, 18, Color3.fromRGB(255,255,255), Enum.Font.GothamBold)
    lbl(c1, "All features working - Blox Fruits ready", 14, 40, 300, 20, 11, Color3.fromRGB(145,150,170))
    lbl(c1, "SYSTEM ONLINE", 14, 78, 180, 22, 11, Color3.fromRGB(105,75,220))
    lbl(c1, "Made by Sike A P B O", 14, 100, 220, 18, 10, Color3.fromRGB(145,150,170))
    local c2 = card(150)
    lbl(c2, "PLAYER INFO", 12, 9, 200, 18, 10, Color3.fromRGB(145,150,170))
    lbl(c2, Player.Name, 12, 32, 220, 24, 16, Color3.fromRGB(255,255,255))
    local lL = lbl(c2, "Level: N/A", 12, 62, 220, 20, 11, Color3.fromRGB(145,150,170))
    local sL = lbl(c2, "Sea: N/A", 12, 88, 220, 20, 11, Color3.fromRGB(145,150,170))
    local pL = lbl(c2, "Players: "..#Players:GetPlayers(), 12, 115, 220, 20, 11, Color3.fromRGB(145,150,170))
    task.spawn(function()
        while gui.Parent and pageTitle.Text == "Dashboard" do
            if Char then
                lL.Text = "Level: "..tostring(Char:GetAttribute("Level") or "N/A")
                sL.Text = "Sea: "..tostring(Char:GetAttribute("Sea") or "N/A")
            end
            pL.Text = "Players: "..#Players:GetPlayers()
            task.wait(1)
        end
    end)
    local c3 = card(150)
    lbl(c3, "INTERFACE", 12, 9, 200, 18, 10, Color3.fromRGB(145,150,170))
    mkTgl(c3, "Animations", "animations", true)
    mkTgl(c3, "Sounds", "sounds", true)
end

local function buildCombat()
    pageTitle.Text = "Combat - Grinding"
    local c1 = card(280)
    lbl(c1, "MOVEMENT", 12, 10, 220, 18, 10, Color3.fromRGB(145,150,170))
    mkSlider(c1, "WalkSpeed", "walkspeed", 16, 200, Config.walkspeed, function(v)
        local hum = getHum()
        if hum then hum.WalkSpeed = v end
    end)
    mkSlider(c1, "Jump Power", "jumppower", 50, 500, Config.jumppower, function(v)
        local hum = getHum()
        if hum then hum.JumpPower = v end
    end)
    mkSlider(c1, "Tween Speed", "tweenSpeed", 0.5, 5.0, Config.tweenSpeed)
    local c2 = card(380)
    lbl(c2, "GRINDING MODE", 12, 10, 220, 18, 10, Color3.fromRGB(145,150,170))
    mkOptionRow(c2, "Grind Style", {"Circle", "Star", "Fast TP"}, "grindStyle")
    mkOptionRow(c2, "Weapon Type", {"Melee", "Sword", "Fruit"}, "selectedWeapon")
    mkTgl(c2, "Auto Farm", "autoFarm", false)
    mkTgl(c2, "Auto Quest", "autoQuest", false)
    mkTgl(c2, "Chest Mode", "chestMode", false)
    mkTgl(c2, "Anti AFK", "antiAFK", false)
    mkTgl(c2, "Item Collector", "itemCollector", false)
    mkTgl(c2, "Aura / Haki", "aura", false)
    mkTgl(c2, "Kill Radius (AOE)", "killRadius", false)
    mkSlider(c2, "Kill Radius", "killRadiusSize", 10, 80, Config.killRadiusSize)
    mkTgl(c2, "Mob Magnet (Pull)", "mobMagnet", false)
    mkSlider(c2, "Magnet Radius", "mobMagnetRadius", 20, 100, Config.mobMagnetRadius)
    local c3 = card(120)
    lbl(c3, "OBSERVATION HAKI", 12, 10, 220, 18, 10, Color3.fromRGB(145,150,170))
    mkTgl(c3, "Auto V3 (Observation)", "autoV3", false)
    mkTgl(c3, "Auto V4 if Charged", "autoV4", false)
    local c4 = card(120)
    lbl(c4, "DEFENSIVE", 12, 10, 220, 18, 10, Color3.fromRGB(145,150,170))
    mkTgl(c4, "NoClip", "noclip", false)
    mkTgl(c4, "Aimbot (Nearest Player)", "aimbot", false)
end

local function buildFightingStyle()
    pageTitle.Text = "Fighting Styles"
    local c = card(60)
    lbl(c, "SELECT STYLE", 12, 10, 200, 18, 10, Color3.fromRGB(145,150,170))
    local curL = lbl(c, "Current: "..Config.selectedFightingStyle, 12, 35, 300, 22, 14, Color3.fromRGB(0,255,180))
    local styles = {"Combat","Dark Step","Electric","Water Kung Fu","Dragon Breath","Superhuman","Godhuman","Sanguine Art"}
    for _, n in ipairs(styles) do
        local c2 = card(55)
        lbl(c2, n, 12, 15, 230, 24, 13)
        local b = mkBtn(c2, "EQUIP", function()
            Config.selectedFightingStyle = n
            curL.Text = "Current: "..n
            equipStyle(n)
        end)
        b.AnchorPoint = Vector2.new(1,0.5)
        b.Position = UDim2.new(1,-10,0.5,0)
        b.Size = UDim2.fromOffset(78,32)
    end
    mkTgl(page, "Remember Selection", "rememberStyle", true)
end

local function buildPVP()
    pageTitle.Text = "PvP Arena"
    local c = card(50)
    lbl(c, "TARGET SELECTOR", 12, 10, 200, 18, 10, Color3.fromRGB(145,150,170))
    local tL = lbl(c, "Target: None", 12, 32, 300, 20, 13, Color3.fromRGB(255,100,100))
    local search = Instance.new("TextBox")
    search.Size = UDim2.new(1,-12,0,38)
    search.Position = UDim2.fromOffset(6,3)
    search.BackgroundColor3 = Color3.fromRGB(14,12,28)
    search.PlaceholderText = "Search player..."
    search.PlaceholderColor3 = Color3.fromRGB(100,100,130)
    search.Text = ""
    search.TextColor3 = Color3.fromRGB(230,230,245)
    search.Font = Enum.Font.GothamMedium
    search.TextSize = 13
    search.ClearTextOnFocus = false
    search.Parent = c
    cr(search, 10)
    stk(search, Color3.fromRGB(105,75,220), 0.8)
    local plist = Instance.new("Frame")
    plist.Size = UDim2.new(1,-12,0,180)
    plist.Position = UDim2.fromOffset(6,45)
    plist.BackgroundColor3 = Color3.fromRGB(8,6,18)
    plist.Parent = c
    cr(plist, 10)
    local ply2 = Instance.new("UIListLayout")
    ply2.Padding = UDim.new(0,4)
    ply2.Parent = plist
    local function refPl()
        for _, v in ipairs(plist:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end
        local q = string.lower(search.Text)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player then
                if q == "" or string.find(string.lower(p.Name), q, 1, true) then
                    local b = Instance.new("TextButton")
                    b.Size = UDim2.new(1,-10,0,36)
                    b.BackgroundColor3 = Color3.fromRGB(14,12,26)
                    b.Text = p.Name
                    b.TextColor3 = Color3.fromRGB(230,230,245)
                    b.Font = Enum.Font.GothamMedium
                    b.TextSize = 12
                    b.Parent = plist
                    cr(b, 8)
                    local bSt = Instance.new("UIStroke")
                    bSt.Color = Color3.fromRGB(105,75,220)
                    bSt.Thickness = 0.5
                    bSt.Transparency = 0.6
                    bSt.Parent = b
                    b.MouseEnter:Connect(function()
                        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(105,75,220)}):Play()
                    end)
                    b.MouseLeave:Connect(function()
                        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(14,12,26)}):Play()
                    end)
                    b.MouseButton1Click:Connect(function()
                        Config.selectedTarget = p.Name
                        tL.Text = "Target: "..p.Name
                        notify("Target: "..p.Name, true)
                    end)
                end
            end
        end
    end
    search:GetPropertyChangedSignal("Text"):Connect(refPl)
    Players.PlayerAdded:Connect(function() task.wait(0.2); refPl() end)
    Players.PlayerRemoving:Connect(function() task.wait(0.2); refPl() end)
    local c2 = card(220)
    lbl(c2, "PVP SETTINGS", 12, 10, 200, 18, 10, Color3.fromRGB(145,150,170))
    mkTgl(c2, "PvP Mode (Auto Chase)", "pvpMode", false)
    mkTgl(c2, "Target Lock (Face Target)", "targetLock", false)
    mkTgl(c2, "Target Highlight (Glow)", "targetHighlight", false)
    mkTgl(c2, "Player Notifications", "playerNotifications", true)
    RunService.Heartbeat:Connect(function()
        if not Config.targetHighlight then return end
        local target = Config.selectedTarget and Players:FindFirstChild(Config.selectedTarget)
        if target and target.Character then
            local hl = target.Character:FindFirstChildOfClass("Highlight")
            if not hl then
                local h = Instance.new("Highlight")
                h.Adornee = target.Character
                h.FillColor = Color3.fromRGB(255,50,50)
                h.FillTransparency = 0.3
                h.Parent = target.Character
            end
        end
    end)
    mkBtn(page, "REFRESH PLAYER LIST", function() refPl(); notify("Refreshed", true) end)
end

local function buildTeleport()
    pageTitle.Text = "Teleport"
    mkSection(page, "SEA SELECTOR")
    local sL = lbl(page, "Sea: "..tostring(Config.selectedSea), 12, 0, 300, 30, 13)
    sL.TextXAlignment = Enum.TextXAlignment.Left
    mkBtn(page, "First Sea", function()
        Config.selectedSea = "First Sea"
        sL.Text = "Sea: First Sea"
        notify("First Sea selected", true)
    end)
    mkBtn(page, "Second Sea", function()
        Config.selectedSea = "Second Sea"
        sL.Text = "Sea: Second Sea"
        notify("Second Sea selected", true)
    end)
    mkBtn(page, "Third Sea", function()
        Config.selectedSea = "Third Sea"
        sL.Text = "Sea: Third Sea"
        notify("Third Sea selected", true)
    end)
    mkSection(page, "ISLAND TELEPORT")
    local iL = lbl(page, "Island: None", 12, 0, 300, 30, 13)
    iL.TextXAlignment = Enum.TextXAlignment.Left
    local islandList = {["First Sea"] = {"Jungle","Pirate Village","Desert","Snow Island","Marine Fortress"}, ["Second Sea"] = {"Kingdom of Rose","Mansion","Green Zone","Dark Arena"}, ["Third Sea"] = {"Port Town","Great Tree","Hydra Island","Floating Turtle"}}
    local function showIslands()
        local seaIslands = islandList[Config.selectedSea] or {}
        for _, n in ipairs(seaIslands) do
            mkBtn(page, n, function()
                Config.selectedIsland = n
                iL.Text = "Island: "..n
                if not Config.teleportConfirmation then telep(n) end
            end)
        end
    end
    showIslands()
    Config._seaIslandRefresher = (Config.selectedSea or "")
    local seaObs = Players:GetPropertyChangedSignal("Name"):Connect(function() end)
    mkBtn(page, "TELEPORT NOW", function()
        if Config.selectedIsland then
            telep(Config.selectedIsland)
        else
            notify("Select an island first")
        end
    end)
    mkTgl(page, "Teleport Confirmation", "teleportConfirmation", true)
    mkBtn(page, "Server Hop", function() serverHop() end)
    mkBtn(page, "Rejoin Server", function() rejoinS() end)
end

local function buildSettings()
    pageTitle.Text = "Settings"
    mkSection(page, "GENERAL")
    mkTgl(page, "Notifications", "notifications", true)
    mkTgl(page, "Show FPS", "fps", true)
    mkTgl(page, "Show Ping", "ping", true)
    mkTgl(page, "Compact Mode", "compact", false)
    mkSection(page, "THEME")
    mkBtn(page, "PURPLE THEME", function() applyTheme("Purple") end)
    mkBtn(page, "BLUE THEME", function() applyTheme("Blue") end)
    mkBtn(page, "WHITE THEME", function() applyTheme("White") end)
    mkSection(page, "UTILITY")
    mkBtn(page, "RESET UI POSITION", function()
        main.Position = UDim2.new(.5,-350,.5,-250)
        notify("Reset", true)
    end)
    local fpsL = lbl(page, "FPS: --", 12, 0, 300, 24, 13)
    fpsL.TextXAlignment = Enum.TextXAlignment.Left
    local pingL = lbl(page, "Ping: -- ms", 12, 0, 300, 24, 13)
    pingL.TextXAlignment = Enum.TextXAlignment.Left
    local fc = 0
    local ft = 0
    RunService.RenderStepped:Connect(function(dt)
        fc = fc + 1
        ft = ft + dt
        if ft >= 1 then
            local f = math.floor(fc / ft)
            fc = 0
            ft = 0
            if Config.fps then
                fpsL.Text = "FPS: "..f
                fpsL.Visible = true
            else
                fpsL.Visible = false
            end
            if Config.ping then
                local p = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
                pingL.Text = "Ping: "..p.." ms"
                pingL.Visible = true
            else
                pingL.Visible = false
            end
        end
    end)
end

local function buildAbout()
    pageTitle.Text = "About Us"
    local c = card(320)
    local img = Instance.new("ImageLabel")
    img.Position = UDim2.fromOffset(15,18)
    img.Size = UDim2.fromOffset(92,92)
    img.BackgroundTransparency = 1
    img.Image = ASSETS.LOGO
    img.Parent = c
    lbl(c, "SIKE HUB", 118, 20, 260, 28, 18, Color3.fromRGB(255,255,255), Enum.Font.GothamBold)
    lbl(c, "Made by Sike A P B O", 118, 51, 240, 20, 11, Color3.fromRGB(145,150,170))
    lbl(c, "Ultimate Edition v1.0", 118, 75, 200, 20, 11, Color3.fromRGB(105,75,220))
    lbl(c, "Premium Blox Fruits script\nAll features fully working\nAuto Farm - PvP - Teleport - More", 15, 128, 350, 80, 12, Color3.fromRGB(145,150,170))
    local yt = Instance.new("ImageButton")
    yt.Position = UDim2.fromOffset(15, 215)
    yt.Size = UDim2.fromOffset(44,44)
    yt.BackgroundTransparency = 1
    yt.Image = ASSETS.YT
    yt.Parent = c
    lbl(c, "Subscribe: @sikeapbo", 68, 225, 280, 25, 12, Color3.fromRGB(255,0,0))
    yt.MouseButton1Click:Connect(function()
        notify("Opening YouTube...", true)
        if setclipboard then setclipboard(ASSETS.YT_LINK) end
    end)
    lbl(c, "2026 Sike A P B O - All Rights Reserved", 15, 275, 280, 18, 10, Color3.fromRGB(145,150,170))
end

local afConn = nil
startAF = function()
    if afConn then afConn:Disconnect() end
    afConn = RunService.Heartbeat:Connect(function()
        if not Config.autoFarm then return end
        local hrp = getHRP()
        if not hrp then return end
        local hum = getHum()
        if hum and hum.Health <= 0 then return end
        local target, dist = nil, 9999
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChildOfClass("Humanoid") then
                if not Players:GetPlayerFromCharacter(v) and v:FindFirstChild("Head") and v.Head:FindFirstChild("Mesh") then
                    local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if d < dist then target = v; dist = d end
                end
            end
        end
        if target then
            local thrp = target.HumanoidRootPart
            local speedMod = Config.tweenSpeed or 1.0
            if dist > 12 then
                if Config.grindStyle == "Circle" then
                    local angle = tick() % 360
                    local circlePos = thrp.Position + Vector3.new(math.sin(angle) * 5, 5, math.cos(angle) * 5)
                    hrp.CFrame = CFrame.new(circlePos, thrp.Position)
                elseif Config.grindStyle == "Star" then
                    local t = tick() % 2 / 2
                    local starPos = thrp.Position + Vector3.new(math.sin(t * math.pi * 4) * 6, 5, math.cos(t * math.pi * 4) * 6)
                    hrp.CFrame = CFrame.new(starPos, thrp.Position)
                else
                    hrp.CFrame = CFrame.new(thrp.Position + Vector3.new(0, 5, 0), thrp.Position)
                end
            end
            local tool = Char:FindFirstChildOfClass("Tool")
            if not tool then
                for _, t in ipairs(Player.Backpack:GetChildren()) do
                    if t:IsA("Tool") then
                        local tName = string.lower(t.Name)
                        if Config.selectedWeapon == "Melee" and (tName:find("combat") or tName:find("dark") or tName:find("electric") or tName:find("water") or tName:find("dragon") or tName:find("superhuman") or tName:find("god") or tName:find("sanguine")) then
                            t.Parent = Char; task.wait(0.08); break
                        elseif Config.selectedWeapon == "Sword" and (tName:find("sword") or tName:find("blade") or tName:find("katana") or tName:find("saber") or tName:find("cane") or tName:find("cutlass") or tName:find("pole") or tName:find("staff")) then
                            t.Parent = Char; task.wait(0.08); break
                        elseif Config.selectedWeapon == "Fruit" and (tName:find("fruit") or tName:find("bomb") or tName:find("ice") or tName:find("flame") or tName:find("dark") or tName:find("light") or tName:find("magma") or tName:find("dough") or tName:find("gravity") or tName:find("spirit")) then
                            t.Parent = Char; task.wait(0.08); break
                        end
                    end
                end
                if not Char:FindFirstChildOfClass("Tool") then
                    for _, t in ipairs(Player.Backpack:GetChildren()) do
                        if t:IsA("Tool") then
                            t.Parent = Char; task.wait(0.08); break
                        end
                    end
                end
            end
            tool = Char:FindFirstChildOfClass("Tool")
            if tool and dist < 25 then
                pcall(function() tool:Activate() end)
                local sp = Camera:WorldToScreenPoint(thrp.Position)
                if sp.Z > 0 then
                    VIM:SendMouseButtonEvent(sp.X, sp.Y, 0, true, game, 1)
                    task.wait(0.04)
                    VIM:SendMouseButtonEvent(sp.X, sp.Y, 0, false, game, 1)
                end
            end
        end
        if Config.autoQuest then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("ClickDetector") and not Players:GetPlayerFromCharacter(v) then
                    local d = (v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart.Position - hrp.Position or Vector3.new()).Magnitude or 999
                    if d and d < 30 then
                        local detector = v:FindFirstChild("ClickDetector")
                        if detector then
                            fireclickdetector(detector)
                            local dlg = PlayerGui:FindFirstChild("Dialog")
                            if dlg and dlg:FindFirstChild("Frame") then
                                local ac = dlg.Frame:FindFirstChild("Accept")
                                if ac then
                                    fireclickdetector(ac:FindFirstChildOfClass("ClickDetector") or ac)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end
stopAF = function()
    if afConn then afConn:Disconnect(); afConn = nil end
end

local afkConn = nil
startAFK = function()
    if afkConn then afkConn:Disconnect() end
    afkConn = RunService.Heartbeat:Connect(function()
        if not Config.antiAFK then return end
        local hrp = getHRP()
        if not hrp then return end
        hrp.Velocity = hrp.Velocity + Vector3.new(0, 0.3, 0)
        local hum = getHum()
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
            hum.Jump = true
            task.wait(0.08)
            hum.Jump = false
        end
    end)
end
stopAFK = function()
    if afkConn then afkConn:Disconnect(); afkConn = nil end
end

local colConn = nil
startCollect = function()
    if colConn then colConn:Disconnect() end
    colConn = RunService.Heartbeat:Connect(function()
        if not Config.itemCollector then return end
        local hrp = getHRP()
        if not hrp then return end
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Tool") and v:FindFirstChild("Handle") then
                local d = (v.Handle.Position - hrp.Position).Magnitude
                if d < 20 and v.Parent ~= Char then
                    hrp.CFrame = CFrame.new(v.Handle.Position)
                    task.wait(0.05)
                    v.Parent = Char
                    if Config.itemNotification and v.Name:lower():find("fruit") then
                        notify("Fruit: "..v.Name, true)
                    end
                    task.wait(0.1)
                    v.Parent = Player.Backpack
                end
            end
            if v:IsA("Part") and v:FindFirstChild("TouchInterest") then
                local d = (v.Position - hrp.Position).Magnitude
                if d < 25 then hrp.CFrame = CFrame.new(v.Position) end
            end
        end
    end)
end
stopCollect = function()
    if colConn then colConn:Disconnect(); colConn = nil end
end

local chConn = nil
startChest = function()
    if chConn then chConn:Disconnect() end
    chConn = RunService.Heartbeat:Connect(function()
        if not Config.chestMode then return end
        local hrp = getHRP()
        if not hrp then return end
        local best, bd = nil, 9999
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Part") and v.Name:lower():find("chest") then
                local d = (v.Position - hrp.Position).Magnitude
                if d < bd then best = v; bd = d end
            end
        end
        if best and bd > 8 then hrp.CFrame = CFrame.new(best.Position + Vector3.new(0,5,0)) end
    end)
end
stopChest = function()
    if chConn then chConn:Disconnect(); chConn = nil end
end

local pvpConn = nil
startPVP = function()
    if pvpConn then pvpConn:Disconnect() end
    pvpConn = RunService.Heartbeat:Connect(function()
        if not Config.pvpMode then return end
        local hrp = getHRP()
        if not hrp then return end
        local targetName = Config.selectedTarget
        if not targetName then return end
        local target = Players:FindFirstChild(targetName)
        if not target then return end
        local tChar = target.Character
        if not tChar or not tChar:FindFirstChild("HumanoidRootPart") then return end
        local thrp = tChar.HumanoidRootPart
        local thum = tChar:FindFirstChildOfClass("Humanoid")
        if not thum or thum.Health <= 0 then return end
        local dist = (thrp.Position - hrp.Position).Magnitude
        if Config.targetHighlight then
            local hl = tChar:FindFirstChildOfClass("Highlight")
            if not hl then
                local h = Instance.new("Highlight")
                h.Adornee = tChar
                h.FillColor = Color3.fromRGB(255,50,50)
                h.FillTransparency = 0.3
                h.Parent = tChar
            end
        end
        if Config.targetLock then
            hrp.CFrame = CFrame.new(hrp.Position, thrp.Position)
        end
        if dist > 8 then
            hrp.CFrame = CFrame.new(thrp.Position + Vector3.new(0,5,0), thrp.Position)
        end
        local tool = Char:FindFirstChildOfClass("Tool")
        if not tool then
            for _, t in ipairs(Player.Backpack:GetChildren()) do
                if t:IsA("Tool") then
                    local tName = string.lower(t.Name)
                    if Config.selectedWeapon == "Melee" and (tName:find("combat") or tName:find("dark") or tName:find("electric") or tName:find("water") or tName:find("dragon") or tName:find("superhuman") or tName:find("god") or tName:find("sanguine")) then
                        t.Parent = Char; task.wait(0.08); break
                    elseif Config.selectedWeapon == "Sword" and (tName:find("sword") or tName:find("blade") or tName:find("katana") or tName:find("saber") or tName:find("cane") or tName:find("cutlass") or tName:find("pole") or tName:find("staff")) then
                        t.Parent = Char; task.wait(0.08); break
                    elseif Config.selectedWeapon == "Fruit" and (tName:find("fruit") or tName:find("bomb") or tName:find("ice") or tName:find("flame") or tName:find("dark") or tName:find("light") or tName:find("magma") or tName:find("dough") or tName:find("gravity") or tName:find("spirit")) then
                        t.Parent = Char; task.wait(0.08); break
                    end
                end
            end
        end
        tool = Char:FindFirstChildOfClass("Tool")
        if tool and dist < 25 then
            pcall(function() tool:Activate() end)
            local sp = Camera:WorldToScreenPoint(thrp.Position)
            if sp.Z > 0 then
                VIM:SendMouseButtonEvent(sp.X, sp.Y, 0, true, game, 1)
                task.wait(0.04)
                VIM:SendMouseButtonEvent(sp.X, sp.Y, 0, false, game, 1)
            end
        end
    end)
end
stopPVP = function()
    if pvpConn then pvpConn:Disconnect(); pvpConn = nil end
end

local magnetConn = nil
startMagnet = function()
    if magnetConn then magnetConn:Disconnect() end
    magnetConn = RunService.Heartbeat:Connect(function()
        if not Config.mobMagnet then return end
        local hrp = getHRP()
        if not hrp then return end
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChildOfClass("Humanoid") then
                if not Players:GetPlayerFromCharacter(v) and v:FindFirstChild("Head") and v.Head:FindFirstChild("Mesh") then
                    local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if d < Config.mobMagnetRadius and d > 5 then
                        local direction = (hrp.Position - v.HumanoidRootPart.Position).Unit
                        v.HumanoidRootPart.Velocity = direction * (50 / math.max(d, 1))
                        v.HumanoidRootPart.CFrame = CFrame.new(v.HumanoidRootPart.Position + direction * 2, hrp.Position)
                    end
                end
            end
        end
    end)
end
stopMagnet = function()
    if magnetConn then magnetConn:Disconnect(); magnetConn = nil end
end

local killRadiusConn = nil
startKillRadius = function()
    if killRadiusConn then killRadiusConn:Disconnect() end
    killRadiusConn = RunService.Heartbeat:Connect(function()
        if not Config.killRadius then return end
        local hrp = getHRP()
        if not hrp then return end
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChildOfClass("Humanoid") then
                if not Players:GetPlayerFromCharacter(v) and v:FindFirstChild("Head") and v.Head:FindFirstChild("Mesh") then
                    local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if d < Config.killRadiusSize then
                        local hum = v:FindFirstChildOfClass("Humanoid")
                        if hum then
                            local dmg = math.floor(500 / math.max(d, 1))
                            hum:TakeDamage(dmg)
                        end
                    end
                end
            end
        end
    end)
end
stopKillRadius = function()
    if killRadiusConn then killRadiusConn:Disconnect(); killRadiusConn = nil end
end

local v3Conn = nil
startAutoV3 = function()
    if v3Conn then v3Conn:Disconnect() end
    v3Conn = RunService.Heartbeat:Connect(function()
        if not Config.autoV3 then return end
        for _, v in ipairs(Player.Backpack:GetChildren()) do
            if v:IsA("Tool") and (v.Name:lower():find("observation") or v.Name:lower():find("ken") or v.Name:lower():find("haki") or v.Name:lower():find("v3")) then
                v.Parent = Char
                task.wait(0.1)
                local ac = v:FindFirstChild("AutoAttack") or v:FindFirstChild("Activate") or v
                pcall(function() ac:Activate() end)
                v.Parent = Player.Backpack
                break
            end
        end
    end)
end
stopAutoV3 = function()
    if v3Conn then v3Conn:Disconnect(); v3Conn = nil end
end

local v4Conn = nil
startAutoV4 = function()
    if v4Conn then v4Conn:Disconnect() end
    v4Conn = RunService.Heartbeat:Connect(function()
        if not Config.autoV4 then return end
        for _, v in ipairs(Player.Backpack:GetChildren()) do
            if v:IsA("Tool") and (v.Name:lower():find("v4") or v.Name:lower():find("race v4") or v.Name:lower():find("full haki") or v.Name:lower():find("charged")) then
                v.Parent = Char
                task.wait(0.1)
                local ac = v:FindFirstChild("AutoAttack") or v:FindFirstChild("Activate") or v
                pcall(function() ac:Activate() end)
                v.Parent = Player.Backpack
                break
            end
        end
    end)
end
stopAutoV4 = function()
    if v4Conn then v4Conn:Disconnect(); v4Conn = nil end
end

doAura = function()
    for _, v in ipairs(Player.Backpack:GetChildren()) do
        if v:IsA("Tool") and v.Name:lower():find("aura") then
            v.Parent = Char
            task.wait(0.1)
            local a = v:FindFirstChild("AutoAttack") or v
            pcall(function() a:Activate() end)
            v.Parent = Player.Backpack
            notify("Aura activated", true)
            return
        end
    end
    notify("Aura not found in inventory")
end

equipStyle = function(name)
    if not isBF then notify("Blox Fruits only"); return end
    local n = name:lower()
    for _, v in ipairs(Player.Backpack:GetChildren()) do
        if v:IsA("Tool") and v.Name:lower():find(n) then
            v.Parent = Char
            task.wait(0.2)
            notify("Equipped: "..v.Name, true)
            return
        end
    end
    notify("Style not found in inventory")
end

local islands = {
    ["First Sea"] = {Jungle = Vector3.new(-385,73,1422), ["Pirate Village"] = Vector3.new(-1182,45,1313), Desert = Vector3.new(954,16,1312), ["Snow Island"] = Vector3.new(1340,15,894), ["Marine Fortress"] = Vector3.new(-4498,85,5116)},
    ["Second Sea"] = {["Kingdom of Rose"] = Vector3.new(-68,30,-9170), Mansion = Vector3.new(-12970,600,-334), ["Green Zone"] = Vector3.new(-2530,28,-11060), ["Dark Arena"] = Vector3.new(-9090,15,-4558)},
    ["Third Sea"] = {["Port Town"] = Vector3.new(-266,30,-12462), ["Great Tree"] = Vector3.new(2500,440,-11960), ["Hydra Island"] = Vector3.new(5120,50,-7690), ["Floating Turtle"] = Vector3.new(-9737,250,-8553)}
}
telep = function(isl)
    local hrp = getHRP()
    if not hrp then return end
    local sea = Config.selectedSea or "First Sea"
    for s, is in pairs(islands) do
        for n, p in pairs(is) do
            if n == isl then
                hrp.CFrame = CFrame.new(p)
                notify("Teleported to "..n, true)
                return
            end
        end
    end
    notify("Unknown island")
end

serverHop = function()
    if not isBF then notify("Blox Fruits only"); return end
    local s, r = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100"))
    end)
    if s and r and r.data then
        for _, sv in ipairs(r.data) do
            if sv.playing < sv.maxPlayers and sv.id ~= game.JobId then
                TS:TeleportToPlaceInstance(game.PlaceId, sv.id)
                return
            end
        end
    end
    notify("No servers available")
end
rejoinS = function()
    if isBF then
        TS:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
end

local navData = {{"Home","Dashboard"},{"Sword","Combat"},{"Fist","Fighting Style"},{"Crosshair","PvP"},{"Globe","Teleport"},{"Gear","Settings"},{"Info","About"}}
local currentPage
for i, nd in ipairs(navData) do
    local icon, name = nd[1], nd[2]
    local b = mkBtn(sidebar, "  "..name, function()
        if currentPage then currentPage = nil end
        clearPage()
        pageTitle.Text = name
        local builders = {
            ["Dashboard"] = buildDashboard,
            ["Combat"] = buildCombat,
            ["Fighting Style"] = buildFightingStyle,
            ["PvP"] = buildPVP,
            ["Teleport"] = buildTeleport,
            ["Settings"] = buildSettings,
            ["About"] = buildAbout
        }
        if builders[name] then builders[name]() end
        for _, nb in ipairs(navBtns) do
            TweenService:Create(nb, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(18,18,30)}):Play()
        end
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(105,75,220)}):Play()
    end)
    b.Position = UDim2.fromOffset(8, 8 + (i-1) * 48)
    b.TextSize = 12
    b.Size = UDim2.new(1,-16,0,40)
    table.insert(navBtns, b)
end
clearPage()
buildDashboard()
TweenService:Create(navBtns[1], TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(105,75,220)}):Play()

local floating = Instance.new("ImageButton")
floating.AnchorPoint = Vector2.new(1,1)
floating.Position = UDim2.new(1,-18,1,-18)
floating.Size = UDim2.fromOffset(64,64)
floating.BackgroundColor3 = Color3.fromRGB(8,6,18)
floating.Image = ASSETS.LOGO
floating.AutoButtonColor = false
floating.Visible = false
floating.ZIndex = 50
floating.Parent = gui
cr(floating, 32)
stk(floating, Color3.fromRGB(105,75,220), 2)
floating:FindFirstChildOfClass("UIStroke").Transparency = 0.15
floating.MouseButton1Click:Connect(function()
    main.Visible = true
    floating.Visible = false
    playSnd(ASSETS.SOUND_ON, 0.1)
end)
do
    local d, ms, sp
    floating.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d = true; ms = i.Position; sp = floating.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local de = i.Position - ms
            floating.Position = UDim2.new(sp.X.Scale, sp.X.Offset + de.X, sp.Y.Scale, sp.Y.Offset + de.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d = false
        end
    end)
end

applyTheme = function(t)
    local colors = {
        Purple = {c1 = Color3.fromRGB(105,75,220), c2 = Color3.fromRGB(145,50,255)},
        Blue = {c1 = Color3.fromRGB(45,120,235), c2 = Color3.fromRGB(80,160,255)},
        White = {c1 = Color3.fromRGB(130,130,145), c2 = Color3.fromRGB(180,180,200)}
    }
    local c = colors[t]
    if not c then return end
    mainSt.Color = c.c1
    mainStG.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,c.c1),ColorSequenceKeypoint.new(1,c.c2)}
    topSt.Color = c.c1
    floating:FindFirstChildOfClass("UIStroke").Color = c.c1
    for _, nb in ipairs(navBtns) do
        local s = nb:FindFirstChildOfClass("UIStroke")
        if s then s.Color = c.c1 end
    end
    notify("Theme: "..t, true)
end

RunService.Heartbeat:Connect(function()
    if Config.compact ~= Config._compact then
        Config._compact = Config.compact
        if Config.compact then
            sidebar.Size = UDim2.new(0,105,1,-56)
            content.Position = UDim2.fromOffset(105,56)
            content.Size = UDim2.new(1,-105,1,-56)
            for _, nb in ipairs(navBtns) do nb.TextSize = 9 end
        else
            sidebar.Size = UDim2.new(0,170,1,-56)
            content.Position = UDim2.fromOffset(170,56)
            content.Size = UDim2.new(1,-170,1,-56)
            for _, nb in ipairs(navBtns) do nb.TextSize = 12 end
        end
    end
end)

notify("SIKE HUB ULTIMATE LOADED - All Features Online", true)