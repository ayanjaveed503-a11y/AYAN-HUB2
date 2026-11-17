-- // AYANUU Edition Dedicated to Life Together 🏡 RP
-- // Developer: AYANUU (+V0_L5)
-- // Universal All-Executor Support

local LIFE_TOGETHER_PLACE_ID = 11732688484
if game.PlaceId ~= LIFE_TOGETHER_PLACE_ID then
    print("[Blue VIP]: The script works in Life Together as well as other maps.")
end

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local VIM = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local P, R, LP = game:GetService("Players"), game:GetService("RunService"), game:GetService("Players").LocalPlayer

local parentGui = (gethui and gethui()) or (CoreGui:FindFirstChild("CoreGui") and CoreGui) or LP:WaitForChild("PlayerGui")

local s = tick()
local playerJoinTimes = {}

for _, pl in ipairs(P:GetPlayers()) do
    playerJoinTimes[pl] = tick()
end
P.PlayerAdded:Connect(function(pl)
    playerJoinTimes[pl] = tick()
end)
P.PlayerRemoving:Connect(function(pl)
    playerJoinTimes[pl] = nil
end)

local function FPT(x)
    local d = math.floor(x / 86400)
    local h = math.floor((x % 86400) / 3600)
    local m = math.floor((x % 3600) / 60)
    local ss = math.floor(x % 60)
    if d > 0 then
        return d .. "d " .. h .. "h " .. m .. "m " .. ss .. "s"
    elseif h > 0 then
        return h .. "h " .. m .. "m " .. ss .. "s"
    else
        return m .. "m " .. ss .. "s"
    end
end

local pt = Instance.new("StringValue", LP)
pt.Name = "PlayTimeText"
pt.Value = FPT(0)

task.spawn(function()
    while true do 
        task.wait(1)
        pt.Value = FPT(math.floor(tick() - s))
    end 
end)

local g = Instance.new("ScreenGui", parentGui)
g.Name = "BlueL5xlilrVIP_LifeTogether"
g.ResetOnSpawn = false

-- Main Frame
local m = Instance.new("Frame", g)
m.Size = UDim2.new(0, 600, 0, 420)
m.Position = UDim2.new(.2, 0, .18, 0)
m.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
m.BackgroundTransparency = 0.2
m.Active = true 
Instance.new("UICorner", m).CornerRadius = UDim.new(0, 14)

local fireGlow = Instance.new("UIStroke", m)
fireGlow.Thickness = 3.5
fireGlow.Color = Color3.fromRGB(0, 140, 255)

-- Main Title Bar
local t = Instance.new("TextLabel", m)
t.Size = UDim2.new(0, 520, 0, 42)
t.Position = UDim2.new(0, 10, 0, -50)
t.BackgroundColor3 = Color3.fromRGB(10, 30, 60)
t.TextColor3 = Color3.new(1, 1, 1)
t.Font = Enum.Font.SourceSansBold 
t.TextSize = 18
t.Text = "🏡 Life Together | HUB MADE BY AYANUU "
t.Active = true
Instance.new("UICorner", t).CornerRadius = UDim.new(0, 8)

local titleStroke = Instance.new("UIStroke", t)
titleStroke.Thickness = 2
titleStroke.Color = Color3.fromRGB(0, 180, 255)

local dragging, dragInput, dragStart, startPos
local function applyDragging(obj)
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = m.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
end

applyDragging(m)
applyDragging(t)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        m.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Floating Button with Icon Only
local tg = Instance.new("TextButton", g)
tg.Size = UDim2.new(0, 65, 0, 65)
tg.Position = UDim2.new(0.5, -32, 0, 12)
tg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
tg.Text = ""
Instance.new("UICorner", tg).CornerRadius = UDim.new(0, 14)
local tgStroke = Instance.new("UIStroke", tg)
tgStroke.Thickness = 3
tgStroke.Color = Color3.fromRGB(0, 140, 255)

local tgImage = Instance.new("ImageLabel", tg)
tgImage.Size = UDim2.new(1, -8, 1, -8)
tgImage.Position = UDim2.new(0.5, 0, 0.5, 0)
tgImage.AnchorPoint = Vector2.new(0.5, 0.5)
tgImage.BackgroundTransparency = 1
tgImage.Image = "rbxassetid://125157479493186"
tgImage.ZIndex = 3
Instance.new("UICorner", tgImage).CornerRadius = UDim.new(0, 10)

tg.Active = true
tg.Draggable = true

local vis = true
tg.MouseButton1Click:Connect(function()
    vis = not vis
    m.Visible = vis
end)

-- Sidebar Menu
local mn = Instance.new("ScrollingFrame", m)
mn.Size = UDim2.new(0, 150, 1, 0)
mn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mn.BackgroundTransparency = 0.4
mn.ZIndex = 2
mn.CanvasSize = UDim2.new(0, 0, 0, 820)
mn.ScrollBarThickness = 3
Instance.new("UICorner", mn).CornerRadius = UDim.new(0, 12)

-- Main Options Container
local c = Instance.new("Frame", m)
c.Size = UDim2.new(1, -150, 1, 0)
c.Position = UDim2.new(0, 150, 0, 0)
c.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
c.BackgroundTransparency = 0.4
c.ZIndex = 2
Instance.new("UICorner", c).CornerRadius = UDim.new(0, 12)
applyDragging(c)

local sections = {}
local rgbElements = {}
local softRgbElements = {}

local customGuiColor = Color3.fromRGB(0, 140, 255)
local customBgColor = Color3.fromRGB(15, 15, 15)
local useGuiSliderColor = false
local useBgSliderColor = false
local rainbowGuiActive = false
local rainbowBgActive = false

local function SwitchSection(sectionName)
    for name, frame in pairs(sections) do
        frame.Visible = (name == sectionName)
    end
end

local function CreateSection(name, canvasHeight)
    if sections[name] then return sections[name] end
    local sf = Instance.new("ScrollingFrame", c)
    sf.Name = name
    sf.Size = UDim2.new(0, 435, 0, 390)
    sf.Position = UDim2.new(0, 10, 0, 15)
    sf.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    sf.BackgroundTransparency = 0.5
    sf.CanvasSize = UDim2.new(0, 0, 0, canvasHeight or 500)
    sf.ScrollBarThickness = 4
    sf.ZIndex = 3
    Instance.new("UICorner", sf).CornerRadius = UDim.new(0, 10)
    sf.Visible = false
    
    local sectionBlueBg = Instance.new("TextLabel", sf)
    sectionBlueBg.Size = UDim2.new(1, 0, 1, 0)
    sectionBlueBg.Position = UDim2.new(0, 0, 0, 50)
    sectionBlueBg.BackgroundTransparency = 1
    sectionBlueBg.Text = "AYANUU"
    sectionBlueBg.TextColor3 = Color3.fromRGB(0, 140, 255)
    sectionBlueBg.TextTransparency = 0.9
    sectionBlueBg.Font = Enum.Font.FredokaOne
    sectionBlueBg.TextSize = 100
    sectionBlueBg.ZIndex = 0
    
    sections[name] = sf
    return sf
end

local function B(tx, y, secName)
    local b = Instance.new("TextButton", mn)
    b.Size = UDim2.new(1, -12, 0, 42)
    b.Position = UDim2.new(0, 6, 0, 10 + (y * 48))
    b.BackgroundColor3 = Color3.fromRGB(15, 30, 50)
    b.BackgroundTransparency = 0.3
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold 
    b.TextSize = 16 
    b.Text = tx 
    b.ZIndex = 3
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    
    local bStroke = Instance.new("UIStroke", b)
    bStroke.Thickness = 1.5
    bStroke.Color = Color3.fromRGB(0, 140, 255)
    table.insert(rgbElements, {Type = "Stroke", Obj = bStroke})
    
    b.MouseButton1Click:Connect(function()
        SwitchSection(secName)
    end)
    return b 
end

local tb = B("target", 0, "Target")
local shield1B = B("Shield", 1, "Shield1")
local shield2B = B("AntiBang", 2, "Shield2")
local playerTabBtn = B("Player", 3, "Player")
local flingAllB = B("Fling All", 4, "FlingAll")
local allSpamB = B("All Spam", 5, "AllSpam")
local mastScriptB = B("Script", 6, "MastScript")
local lifeTogetherB = B("Life Together", 7, "LifeTogether")
local tmb = B("Player List & Time", 8, "PlayTime")
local ab = B("Anti-AFK", 9, "AFK")
local fpsBtn = B("Enhanced FPS", 10, "FPS")
local rjB = B("Rejoin", 11, "Rejoin")
local notesB = B("Notes", 12, "Notes")
local themeB = B("Theme", 13, "Theme")
local feedbackB = B("Feedback", 14, "Feedback")

local function CreateToggleSwitch(parent, text, yPos, callback, initialState)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -20, 0, 44)
    container.Position = UDim2.new(0, 10, 0, yPos)
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    container.BackgroundTransparency = 0.35
    container.ZIndex = 4
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

    local containerStroke = Instance.new("UIStroke", container)
    containerStroke.Thickness = 1
    containerStroke.Color = Color3.fromRGB(0, 140, 255)
    table.insert(rgbElements, {Type = "Stroke", Obj = containerStroke})

    local lbl = Instance.new("TextLabel", container)
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.ZIndex = 4

    local toggleBg = Instance.new("TextButton", container)
    toggleBg.Size = UDim2.new(0, 52, 0, 26)
    toggleBg.Position = UDim2.new(1, -60, 0.5, -13)
    toggleBg.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    toggleBg.Text = ""
    toggleBg.ZIndex = 4
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(0, 13)

    local circle = Instance.new("Frame", toggleBg)
    circle.Size = UDim2.new(0, 22, 0, 22)
    circle.Position = UDim2.new(0, 2, 0.5, -11)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    circle.ZIndex = 5
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local state = false

    local function setStateUI(val, noCallback)
        state = val
        if state then
            toggleBg.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            circle:TweenPosition(UDim2.new(1, -24, 0.5, -11), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        else
            toggleBg.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            circle:TweenPosition(UDim2.new(0, 2, 0.5, -11), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        end
        if not noCallback then
            callback(state)
        end
    end

    if initialState then
        setStateUI(true, true)
    end

    toggleBg.MouseButton1Click:Connect(function()
        setStateUI(not state)
    end)

    return container, setStateUI, lbl
end

task.spawn(function()
    local hue = 0
    local waveTimer = 0
    while true do
        hue = (tick() % 6) / 6
        waveTimer = (tick() * 2) % (math.pi * 2)
        
        local rgbColor = Color3.fromHSV(hue, 0.9, 1)
        local bgRgbColor = Color3.fromHSV(hue, 0.4, 0.15)
        local softRgbColor = Color3.fromHSV(hue, 0.5, 0.8)
        
        local waveR = math.sin(waveTimer) * 0.15 + 0.15
        local waveG = math.sin(waveTimer + 1.5) * 0.3 + 0.5
        local waveB = math.sin(waveTimer + 3.0) * 0.2 + 0.8
        local seaWaveColor = Color3.new(waveR, waveG, waveB)
        
        local activeGuiColor = rainbowGuiActive and rgbColor or (useGuiSliderColor and customGuiColor or Color3.fromRGB(0, 140, 255))
        local activeBgColor = rainbowBgActive and rgbColor or (useBgSliderColor and customBgColor or Color3.fromRGB(15, 15, 15))
        
        pcall(function()
            fireGlow.Color = activeGuiColor
            m.BackgroundColor3 = activeBgColor
            titleStroke.Color = seaWaveColor
        end)
        
        for _, item in ipairs(rgbElements) do
            pcall(function()
                if item.Type == "Stroke" then
                    item.Obj.Color = activeGuiColor
                elseif item.Type == "Frame" then
                    item.Obj.BackgroundColor3 = bgRgbColor
                end
            end)
        end
        
        for _, item in ipairs(softRgbElements) do
            pcall(function()
                if item.Type == "Stroke" then
                    item.Obj.Color = softRgbColor
                elseif item.Type == "TextColor" then
                    item.Obj.TextColor3 = softRgbColor
                end
            end)
        end
        
        task.wait(0.05)
    end
end)

local function createLoadstringButton(parent, text, yPos, url)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 38)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.BackgroundTransparency = 0.35
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Text = text
    btn.ZIndex = 5
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(function()
        pcall(function() loadstring(game:HttpGet(url))() end)
    end)
    return btn
end

-- 1. Targeting Section
local sf = CreateSection("Target", 830)
sf.Visible = true

local tt2 = Instance.new("TextLabel", sf)
tt2.Size = UDim2.new(1, 0, 0, 32)
tt2.BackgroundColor3 = Color3.fromRGB(0, 30, 60)
tt2.BackgroundTransparency = 0.35
tt2.TextColor3 = Color3.new(1, 1, 1)
tt2.Font = Enum.Font.SourceSansBold 
tt2.TextSize = 15
tt2.Text = " $ ZM $ # AYANUU # + My Roblox Sec Account AYANUU160 Script Developer"
tt2.ZIndex = 4
table.insert(softRgbElements, {Type = "TextColor", Obj = tt2})

local tt2Stroke = Instance.new("UIStroke", tt2)
tt2Stroke.Thickness = 1.5
table.insert(rgbElements, {Type = "Stroke", Obj = tt2Stroke})

local bx = Instance.new("TextBox", sf)
bx.Size = UDim2.new(1, -20, 0, 42)
bx.Position = UDim2.new(0, 10, 0, 42)
bx.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
bx.BackgroundTransparency = 0.35
bx.TextColor3 = Color3.fromRGB(255, 255, 255)
bx.Font = Enum.Font.SourceSansBold 
bx.TextSize = 16
bx.Text = ""
bx.PlaceholderText = "Search or enter target name here..."
bx.PlaceholderColor3 = Color3.fromRGB(200, 200, 200)
bx.ClearTextOnFocus = false
bx.ZIndex = 4
Instance.new("UICorner", bx).CornerRadius = UDim.new(0, 6)
table.insert(rgbElements, {Type = "Frame", Obj = bx})

local targetPlayerListFrame = Instance.new("ScrollingFrame", sf)
targetPlayerListFrame.Size = UDim2.new(1, -20, 0, 90)
targetPlayerListFrame.Position = UDim2.new(0, 10, 0, 90)
targetPlayerListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
targetPlayerListFrame.BackgroundTransparency = 0.35
targetPlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
targetPlayerListFrame.ScrollBarThickness = 4
targetPlayerListFrame.ZIndex = 5
Instance.new("UICorner", targetPlayerListFrame).CornerRadius = UDim.new(0, 8)

local targetInfoBox = Instance.new("Frame", sf)
targetInfoBox.Size = UDim2.new(1, -20, 0, 105)
targetInfoBox.Position = UDim2.new(0, 10, 0, 198)
targetInfoBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
targetInfoBox.BackgroundTransparency = 0.35
targetInfoBox.ZIndex = 4
Instance.new("UICorner", targetInfoBox).CornerRadius = UDim.new(0, 10)
table.insert(rgbElements, {Type = "Frame", Obj = targetInfoBox})

local av = Instance.new("ImageLabel", targetInfoBox)
av.Size = UDim2.new(0, 85, 0, 85)
av.Position = UDim2.new(0, 10, 0, 10)
av.BackgroundColor3 = Color3.fromRGB(0, 60, 120)
av.Visible = false
av.ZIndex = 5
Instance.new("UICorner", av).CornerRadius = UDim.new(0, 10)

local nm = Instance.new("TextLabel", targetInfoBox)
nm.Size = UDim2.new(0, 310, 0, 38)
nm.Position = UDim2.new(0, 108, 0, 12)
nm.BackgroundTransparency = 1
nm.TextColor3 = Color3.new(1, 1, 1)
nm.Font = Enum.Font.SourceSansBold 
nm.TextSize = 20 
nm.TextXAlignment = Enum.TextXAlignment.Left
nm.ZIndex = 5

local st = Instance.new("TextLabel", targetInfoBox)
st.Size = UDim2.new(0, 310, 0, 38)
st.Position = UDim2.new(0, 108, 0, 54)
st.BackgroundTransparency = 1
st.Font = Enum.Font.SourceSansBold 
st.TextSize = 18 
st.Text = "Status: Waiting to enter target..."
st.TextColor3 = Color3.fromRGB(255, 255, 255)
st.TextXAlignment = Enum.TextXAlignment.Left
st.ZIndex = 5

local gotoTargetBtn = Instance.new("TextButton", sf)
gotoTargetBtn.Size = UDim2.new(1, -20, 0, 35)
gotoTargetBtn.Position = UDim2.new(0, 10, 0, 310)
gotoTargetBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
gotoTargetBtn.TextColor3 = Color3.new(1, 1, 1)
gotoTargetBtn.Font = Enum.Font.SourceSansBold
gotoTargetBtn.TextSize = 15
gotoTargetBtn.Text = "📍 Goto Target Player"
gotoTargetBtn.ZIndex = 4
Instance.new("UICorner", gotoTargetBtn).CornerRadius = UDim.new(0, 6)

gotoTargetBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local targetPlr = lockedPlayer
        if not targetPlr or not targetPlr.Parent then
            local currentName = bx.Text:gsub("%s+", ""):lower()
            for _, pl in ipairs(P:GetPlayers()) do
                if pl ~= LP and (pl.Name:lower() == currentName or pl.DisplayName:lower() == currentName) then
                    targetPlr = pl
                    break
                end
            end
        end

        if targetPlr and targetPlr.Character then
            local tHrp = targetPlr.Character:FindFirstChild("HumanoidRootPart")
            local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if tHrp and myHrp then
                myHrp.CFrame = tHrp.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end)
end)

local lockedPlayer = nil
local lockedUserId = nil
local lockedPlayerName = ""
local wasEverInServer = false

local mouthbangActive = false
local bangActive = false
local frontsitActive = false
local frontheadsitActive = false
local blackBacksitActive = false
local orbitActive = false
local aimbotActive = false
local espActive = false
local viewActive = false

local setUIMouth, setUIBang, setUIFrontSit, setUIFrontHead, setUIBlackBacksit, setUIOrbit, setUIAimbot, setUIEsp, setUIView

local function updateTargetSearch()
    local textVal = bx.Text:gsub("%s+", "")
    local query = textVal:lower()
    
    if query == "" then
        lockedPlayer = nil
        lockedUserId = nil
        lockedPlayerName = ""
        wasEverInServer = false
        av.Visible = false
        av.Image = ""
        nm.Text = ""
        st.Text = "Status: Waiting to enter target..."
        st.TextColor3 = Color3.fromRGB(255, 255, 255)
        return
    end

    local foundPlr = nil
    for _, pl in ipairs(P:GetPlayers()) do
        if pl ~= LP then
            local pName = pl.Name:lower()
            local pDisp = pl.DisplayName:lower()
            if pName == query or pDisp == query or pName:sub(1, #query) == query or pDisp:sub(1, #query) == query then
                foundPlr = pl
                break
            end
        end
    end
    
    if foundPlr then
        lockedPlayer = foundPlr
        lockedUserId = foundPlr.UserId
        lockedPlayerName = foundPlr.Name
        wasEverInServer = true
        
        pcall(function()
            local th = P:GetUserThumbnailAsync(lockedUserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
            av.Image = th 
            av.Visible = true 
        end)
        nm.Text = lockedPlayerName
        st.Text = "🟢 Player Online…"
        st.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        if wasEverInServer and lockedPlayerName ~= "" then
            lockedPlayer = nil
            st.Text = "🔴 Player Left"
            st.TextColor3 = Color3.fromRGB(255, 50, 50)
        else
            lockedPlayer = nil
            lockedUserId = nil
            wasEverInServer = false
            av.Visible = false
            av.Image = ""
            nm.Text = ""
            st.Text = "🟡 No player found with this name"
            st.TextColor3 = Color3.fromRGB(255, 200, 0)
        end
    end
end

bx:GetPropertyChangedSignal("Text"):Connect(function()
    wasEverInServer = false
    lockedPlayerName = ""
    updateTargetSearch()
end)

local function refreshTargetPlayerList()
    for _, child in ipairs(targetPlayerListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local yPos = 0
    for _, pl in ipairs(P:GetPlayers()) do
        if pl ~= LP then
            local pBtn = Instance.new("TextButton", targetPlayerListFrame)
            pBtn.Size = UDim2.new(1, -10, 0, 28)
            pBtn.Position = UDim2.new(0, 5, 0, yPos)
            pBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            pBtn.TextColor3 = Color3.new(1, 1, 1)
            pBtn.Font = Enum.Font.SourceSansBold
            pBtn.TextSize = 14
            pBtn.Text = pl.Name .. " (" .. pl.DisplayName .. ")"
            pBtn.ZIndex = 6
            Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)
            
            pBtn.MouseButton1Click:Connect(function()
                bx.Text = pl.Name
                updateTargetSearch()
            end)
            yPos = yPos + 32
        end
    end
    targetPlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

task.spawn(function()
    while true do
        task.wait(3)
        pcall(refreshTargetPlayerList)
    end
end)
task.spawn(refreshTargetPlayerList)

R.Heartbeat:Connect(function()
    pcall(function()
        local activeTarget = lockedPlayer
        if not activeTarget or activeTarget.Parent ~= P then
            local currentName = bx.Text:gsub("%s+", ""):lower()
            if currentName ~= "" then
                for _, pl in ipairs(P:GetPlayers()) do
                    if pl ~= LP and (pl.Name:lower() == currentName or pl.DisplayName:lower() == currentName) then
                        activeTarget = pl
                        break
                    end
                end
            end
        end

        if not activeTarget or not activeTarget.Character or not activeTarget.Character:FindFirstChild("HumanoidRootPart") then return end
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end

        local myChar = LP.Character
        local hum = myChar:FindFirstChildOfClass("Humanoid")
        local hrp = myChar.HumanoidRootPart
        local tHrp = activeTarget.Character.HumanoidRootPart

        if mouthbangActive then
            if hum then hum.PlatformStand = true end
            hrp.CFrame = tHrp.CFrame * CFrame.new(0, 2.2, -0.6) * CFrame.Angles(0, math.rad(180), 0)
        elseif bangActive then
            if hum then hum.PlatformStand = true end
            local tTick = tick() * 30
            hrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 1.2 + math.sin(tTick)*0.4) * CFrame.Angles(0, 0, 0)
        elseif frontsitActive then
            if hum then hum.PlatformStand = true end
            hrp.CFrame = tHrp.CFrame * CFrame.new(0, 1.5, -0.8)
        elseif frontheadsitActive then
            if hum then hum.PlatformStand = true end
            hrp.CFrame = tHrp.CFrame * CFrame.new(0, 2.3, 0)
        elseif blackBacksitActive then
            if hum then hum.PlatformStand = true end
            hrp.CFrame = tHrp.CFrame * CFrame.new(0, 0.5, 1.2) * CFrame.Angles(0, 0, 0)
        elseif orbitActive then
            local angle = tick() * 6
            local radius = 5
            local offset = Vector3.new(math.cos(angle) * radius, 2, math.sin(angle) * radius)
            hrp.CFrame = CFrame.new(tHrp.Position + offset, tHrp.Position)
        end

        if aimbotActive and activeTarget.Character:FindFirstChild("Head") then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, activeTarget.Character.Head.Position)
        end
    end)
end)

R.RenderStepped:Connect(function()
    local activeTarget = lockedPlayer
    if not activeTarget or activeTarget.Parent ~= P then
        local currentName = bx.Text:gsub("%s+", ""):lower()
        if currentName ~= "" then
            for _, pl in ipairs(P:GetPlayers()) do
                if pl ~= LP and (pl.Name:lower() == currentName or pl.DisplayName:lower() == currentName) then
                    activeTarget = pl
                    break
                end
            end
        end
    end

    if viewActive and activeTarget and activeTarget.Character then
        local cam = workspace.CurrentCamera
        local humanoid = activeTarget.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then cam.CameraSubject = humanoid end
    end

    if espActive then
        for _, pl in ipairs(P:GetPlayers()) do
            if pl ~= LP and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = pl.Character.HumanoidRootPart
                local billboard = hrp:FindFirstChild("RedESPTag")
                if not billboard then
                    billboard = Instance.new("BillboardGui")
                    billboard.Name = "RedESPTag"
                    billboard.Size = UDim2.new(0, 100, 0, 40)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = hrp

                    local txt = Instance.new("TextLabel", billboard)
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.TextColor3 = Color3.fromRGB(0, 140, 255)
                    txt.Font = Enum.Font.SourceSansBold
                    txt.TextSize = 14
                    txt.Text = pl.Name
                end
            end
        end
    else
        for _, pl in ipairs(P:GetPlayers()) do
            if pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                local bb = pl.Character.HumanoidRootPart:FindFirstChild("RedESPTag")
                if bb then bb:Destroy() end
            end
        end
    end
end)

_, setUIMouth = CreateToggleSwitch(sf, "Mouthbang", 355, function(state)
    mouthbangActive = state
    if state then
        bangActive = false; if setUIBang then setUIBang(false, true) end
        frontsitActive = false; if setUIFrontSit then setUIFrontSit(false, true) end
        frontheadsitActive = false; if setUIFrontHead then setUIFrontHead(false, true) end
        blackBacksitActive = false; if setUIBlackBacksit then setUIBlackBacksit(false, true) end
        orbitActive = false; if setUIOrbit then setUIOrbit(false, true) end
    else
        pcall(function() LP.Character.Humanoid.PlatformStand = false end)
    end
end, false)

_, setUIBang = CreateToggleSwitch(sf, "Bang (Back)", 403, function(state)
    bangActive = state
    if state then
        mouthbangActive = false; if setUIMouth then setUIMouth(false, true) end
        frontsitActive = false; if setUIFrontSit then setUIFrontSit(false, true) end
        frontheadsitActive = false; if setUIFrontHead then setUIFrontHead(false, true) end
        blackBacksitActive = false; if setUIBlackBacksit then setUIBlackBacksit(false, true) end
        orbitActive = false; if setUIOrbit then setUIOrbit(false, true) end
    else
        pcall(function() LP.Character.Humanoid.PlatformStand = false end)
    end
end, false)

_, setUIFrontSit = CreateToggleSwitch(sf, "Front Sit", 451, function(state)
    frontsitActive = state
    if state then
        mouthbangActive = false; if setUIMouth then setUIMouth(false, true) end
        bangActive = false; if setUIBang then setUIBang(false, true) end
        frontheadsitActive = false; if setUIFrontHead then setUIFrontHead(false, true) end
        blackBacksitActive = false; if setUIBlackBacksit then setUIBlackBacksit(false, true) end
        orbitActive = false; if setUIOrbit then setUIOrbit(false, true) end
    else
        pcall(function() LP.Character.Humanoid.PlatformStand = false end)
    end
end, false)

_, setUIFrontHead = CreateToggleSwitch(sf, "Front Headsit", 499, function(state)
    frontheadsitActive = state
    if state then
        mouthbangActive = false; if setUIMouth then setUIMouth(false, true) end
        bangActive = false; if setUIBang then setUIBang(false, true) end
        frontsitActive = false; if setUIFrontSit then setUIFrontSit(false, true) end
        blackBacksitActive = false; if setUIBlackBacksit then setUIBlackBacksit(false, true) end
        orbitActive = false; if setUIOrbit then setUIOrbit(false, true) end
    else
        pcall(function() LP.Character.Humanoid.PlatformStand = false end)
    end
end, false)

_, setUIBlackBacksit = CreateToggleSwitch(sf, "Black Backsit", 547, function(state)
    blackBacksitActive = state
    if state then
        mouthbangActive = false; if setUIMouth then setUIMouth(false, true) end
        bangActive = false; if setUIBang then setUIBang(false, true) end
        frontsitActive = false; if setUIFrontSit then setUIFrontSit(false, true) end
        frontheadsitActive = false; if setUIFrontHead then setUIFrontHead(false, true) end
        orbitActive = false; if setUIOrbit then setUIOrbit(false, true) end
    else
        pcall(function() LP.Character.Humanoid.PlatformStand = false end)
    end
end, false)

_, setUIOrbit = CreateToggleSwitch(sf, "Orbit Target", 595, function(state)
    orbitActive = state
    if state then
        mouthbangActive = false; if setUIMouth then setUIMouth(false, true) end
        bangActive = false; if setUIBang then setUIBang(false, true) end
        frontsitActive = false; if setUIFrontSit then setUIFrontSit(false, true) end
        frontheadsitActive = false; if setUIFrontHead then setUIFrontHead(false, true) end
        blackBacksitActive = false; if setUIBlackBacksit then setUIBlackBacksit(false, true) end
    end
end, false)

_, setUIAimbot = CreateToggleSwitch(sf, "Aimbot", 643, function(state)
    aimbotActive = state
end, false)

_, setUIEsp = CreateToggleSwitch(sf, "ESP", 691, function(state)
    espActive = state
end, false)

_, setUIView = CreateToggleSwitch(sf, "View / Unview", 739, function(state)
    viewActive = state
    if not state then
        workspace.CurrentCamera.CameraSubject = LP.Character:FindFirstChildOfClass("Humanoid")
    end
end, false)

-- 2. Shield Section
local shield1FF = CreateSection("Shield1", 350)
local s1Header = Instance.new("TextLabel", shield1FF)
s1Header.Size = UDim2.new(1, -20, 0, 36)
s1Header.Position = UDim2.new(0, 10, 0, 10)
s1Header.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
s1Header.TextColor3 = Color3.new(1, 1, 1)
s1Header.Font = Enum.Font.SourceSansBold 
s1Header.TextSize = 17
s1Header.Text = "🛡️ Shield System & Antisit V2"
s1Header.ZIndex = 4
Instance.new("UICorner", s1Header).CornerRadius = UDim.new(0, 6)

local Toggles1 = { AntiSit = false, AntiVoid = false, AntiFling = false, AntiTPKill = false, AntiGlitch = false, AntiSitV2 = false }
local SafePoint = Vector3.new(0, 15, 0)
local lastPos = nil

local function createShield1Switch(txt, order, key)
    CreateToggleSwitch(shield1FF, txt, 56 + (order * 46), function(state)
        Toggles1[key] = state
        if not state and key == "AntiSit" then
            pcall(function() LP.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end)
        end
    end, false)
end

createShield1Switch("Smart Anti-Sit", 0, "AntiSit")
createShield1Switch("Anti-Void", 1, "AntiVoid")
createShield1Switch("Anti-Fling", 2, "AntiFling")
createShield1Switch("Anti-Teleport Kill", 3, "AntiTPKill")
createShield1Switch("Anti-Glitch", 4, "AntiGlitch")

CreateToggleSwitch(shield1FF, "Anti sit on off (antisitv2)", 288, function(v)
    Toggles1.AntiSitV2 = v
    task.spawn(function()
        while Toggles1.AntiSitV2 and task.wait() do
            pcall(function()
                game.Players.LocalPlayer.Character.Humanoid.Sit = true
            end)
        end
    end)
end, false)

-- 3. AntiBang Section
local shield2FF = CreateSection("Shield2", 750)
local s2Header = Instance.new("TextLabel", shield2FF)
s2Header.Size = UDim2.new(1, -20, 0, 36)
s2Header.Position = UDim2.new(0, 10, 0, 10)
s2Header.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
s2Header.TextColor3 = Color3.new(1, 1, 1)
s2Header.Font = Enum.Font.SourceSansBold 
s2Header.TextSize = 17
s2Header.Text = "🛡️ AntiBang & Loadstrings"
s2Header.ZIndex = 4
Instance.new("UICorner", s2Header).CornerRadius = UDim.new(0, 6)

local Toggles2 = { AntiBangCustom = false }

local antiBangContainer = CreateToggleSwitch(shield2FF, "Anti bang on off (Custom Speed)", 56, function(v)
    Toggles2.AntiBangCustom = v
end, false)

local speedAbBox = Instance.new("TextBox", shield2FF)
speedAbBox.Size = UDim2.new(0, 75, 0, 24)
speedAbBox.Position = UDim2.new(1, -125, 0, 66)
speedAbBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
speedAbBox.TextColor3 = Color3.fromRGB(255, 255, 0)
speedAbBox.Font = Enum.Font.SourceSansBold
speedAbBox.TextSize = 12
speedAbBox.Text = "0.1"
speedAbBox.PlaceholderText = "Speed"
speedAbBox.ZIndex = 6
Instance.new("UICorner", speedAbBox).CornerRadius = UDim.new(0, 6)

task.spawn(function()
    while true do
        if Toggles2.AntiBangCustom then
            pcall(function()
                local speedVal = tonumber(speedAbBox.Text) or 0.1
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 1000, 0)
                    task.wait(speedVal)
                    char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, -1000, 0)
                    task.wait(speedVal)
                end
            end)
        end
        task.wait(0.05)
    end
end)

createLoadstringButton(shield2FF, "🛡️ BEST ANTIBANG EVER", 110, "https://pastebin.com/raw/80Nva2Fj")
createLoadstringButton(shield2FF, "🛡️ AntiBangV2", 158, "https://scriptblox.com/raw/Universal-Script-Anti-Bang-48256")
createLoadstringButton(shield2FF, "🛡️ AntiBang Script 3", 206, "Aapki_Teesri_Script_Ka_Link")
createLoadstringButton(shield2FF, "🛡️ AntiBang Script 4", 254, "Aapki_Chauthi_Script_Ka_Link")
createLoadstringButton(shield2FF, "🛡️ AntiBang Script 5", 302, "Aapki_Paanchv_Script_Ka_Link")
createLoadstringButton(shield2FF, "🛡️ AntiBang Script 6", 350, "Aapki_Chhathi_Script_Ka_Link")
createLoadstringButton(shield2FF, "🛡️ AntiBang Script 7", 398, "Aapki_Saatv_Script_Ka_Link")
createLoadstringButton(shield2FF, "🛡️ AntiBang Script 8", 446, "Aapki_Aathv_Script_Ka_Link")
createLoadstringButton(shield2FF, "🛡️ AntiBang Script 9", 494, "Aapki_Nauv_Script_Ka_Link")
createLoadstringButton(shield2FF, "🛡️ AntiBang Script 10", 542, "Aapki_Dasv_Script_Ka_Link")
createLoadstringButton(shield2FF, "🛡️ AntiBang Script 11", 590, "Aapki_Gyarahv_Script_Ka_Link")
createLoadstringButton(shield2FF, "🛡️ AntiBang Script 12", 638, "Aapki_Barahv_Script_Ka_Link")
createLoadstringButton(shield2FF, "🛡️ AntiBang Script 13", 686, "Aapki_Terahv_Script_Ka_Link")

R.Heartbeat:Connect(function()
    pcall(function()
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        local pos = hrp.Position
        local vel = hrp.AssemblyLinearVelocity.Magnitude

        if pos.Y > 5 and pos.Y < 300 then SafePoint = pos end

        if Toggles1.AntiSit then
            hum.Sit = false
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        end
        if Toggles1.AntiFling and vel > 80 then hrp.AssemblyLinearVelocity = Vector3.zero end
        if Toggles1.AntiTPKill and lastPos and (pos - lastPos).Magnitude > 200 then hrp.CFrame = CFrame.new(SafePoint) end
        lastPos = pos
        if Toggles1.AntiVoid and pos.Y < -25 then hrp.CFrame = CFrame.new(SafePoint) end
        if Toggles1.AntiGlitch and vel > 120 then hrp.CFrame = hrp.CFrame + Vector3.new(0, 3, 0) end
    end)
end)

-- 4. Player Section
local playerFF = CreateSection("Player", 550)

local playerHeader = Instance.new("TextLabel", playerFF)
playerHeader.Size = UDim2.new(1, -20, 0, 36)
playerHeader.Position = UDim2.new(0, 10, 0, 10)
playerHeader.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
playerHeader.TextColor3 = Color3.new(1, 1, 1)
playerHeader.Font = Enum.Font.SourceSansBold 
playerHeader.TextSize = 17
playerHeader.Text = "👑 Player Control & Mobile Fly"
playerHeader.ZIndex = 4
Instance.new("UICorner", playerHeader).CornerRadius = UDim.new(0, 6)

local mobileFlyActive = false
CreateToggleSwitch(playerFF, "Mobile Fly (ON/OFF)", 56, function(state)
    mobileFlyActive = state
    if mobileFlyActive then
        task.spawn(function()
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.new(0, 0, 0)
            while mobileFlyActive and char and char.Parent do
                local cam = workspace.CurrentCamera
                local moveDir = Vector3.new(0,0,0)
                local uis = game:GetService("UserInputService")
                if uis:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                bv.Velocity = moveDir * 50
                task.wait()
            end
            bv:Destroy()
        end)
    end
end, false)

local speedBoxContainer = Instance.new("Frame", playerFF)
speedBoxContainer.Size = UDim2.new(1, -20, 0, 44)
speedBoxContainer.Position = UDim2.new(0, 10, 0, 104)
speedBoxContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
speedBoxContainer.BackgroundTransparency = 0.35
speedBoxContainer.ZIndex = 4
Instance.new("UICorner", speedBoxContainer).CornerRadius = UDim.new(0, 8)

local speedLbl = Instance.new("TextLabel", speedBoxContainer)
speedLbl.Size = UDim2.new(0, 120, 1, 0)
speedLbl.Position = UDim2.new(0, 12, 0, 0)
speedLbl.BackgroundTransparency = 1
speedLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLbl.Font = Enum.Font.SourceSansBold
speedLbl.TextSize = 15
speedLbl.TextXAlignment = Enum.TextXAlignment.Left
speedLbl.Text = "WalkSpeed"
speedLbl.ZIndex = 4

local speedInput = Instance.new("TextBox", speedBoxContainer)
speedInput.Size = UDim2.new(0, 150, 0, 30)
speedInput.Position = UDim2.new(1, -160, 0.5, -15)
speedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 0)
speedInput.Font = Enum.Font.SourceSansBold
speedInput.TextSize = 15
speedInput.Text = "16"
speedInput.ClearTextOnFocus = false
speedInput.ZIndex = 5
Instance.new("UICorner", speedInput).CornerRadius = UDim.new(0, 6)

speedInput.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    local val = tonumber(speedInput.Text)
    if val then pcall(function() LP.Character.Humanoid.WalkSpeed = val end) end
end)

local jumpBoxContainer = Instance.new("Frame", playerFF)
jumpBoxContainer.Size = UDim2.new(1, -20, 0, 44)
jumpBoxContainer.Position = UDim2.new(0, 10, 0, 152)
jumpBoxContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
jumpBoxContainer.BackgroundTransparency = 0.35
jumpBoxContainer.ZIndex = 4
Instance.new("UICorner", jumpBoxContainer).CornerRadius = UDim.new(0, 8)

local jumpLbl = Instance.new("TextLabel", jumpBoxContainer)
jumpLbl.Size = UDim2.new(0, 120, 1, 0)
jumpLbl.Position = UDim2.new(0, 12, 0, 0)
jumpLbl.BackgroundTransparency = 1
jumpLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpLbl.Font = Enum.Font.SourceSansBold
jumpLbl.TextSize = 15
jumpLbl.TextXAlignment = Enum.TextXAlignment.Left
jumpLbl.Text = "JumpPower"
jumpLbl.ZIndex = 4

local jumpInput = Instance.new("TextBox", jumpBoxContainer)
jumpInput.Size = UDim2.new(0, 150, 0, 30)
jumpInput.Position = UDim2.new(1, -160, 0.5, -15)
jumpInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
jumpInput.TextColor3 = Color3.fromRGB(255, 255, 0)
jumpInput.Font = Enum.Font.SourceSansBold
jumpInput.TextSize = 15
jumpInput.Text = "50"
jumpInput.ClearTextOnFocus = false
jumpInput.ZIndex = 5
Instance.new("UICorner", jumpInput).CornerRadius = UDim.new(0, 6)

jumpInput.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    local val = tonumber(jumpInput.Text)
    if val then pcall(function() LP.Character.Humanoid.UseJumpPower = true LP.Character.Humanoid.JumpPower = val end) end
end)

local infJumpActive = false
CreateToggleSwitch(playerFF, "Infinite Jump", 200, function(state) infJumpActive = state end, false)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJumpActive then pcall(function() LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end) end
end)

local noclipActive = false
CreateToggleSwitch(playerFF, "Noclip", 248, function(state) noclipActive = state end, false)

R.Stepped:Connect(function()
    if noclipActive then
        pcall(function()
            for _, part in pairs(LP.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
    end
end)

CreateToggleSwitch(playerFF, "ESP (Player Tab)", 296, function(state)
    espActive = state
end, false)

local flingContainer = Instance.new("Frame", playerFF)
flingContainer.Size = UDim2.new(1, -20, 0, 94)
flingContainer.Position = UDim2.new(0, 10, 0, 348)
flingContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
flingContainer.BackgroundTransparency = 0.35
flingContainer.ZIndex = 4
Instance.new("UICorner", flingContainer).CornerRadius = UDim.new(0, 8)

local flingToggleBtn = Instance.new("TextButton", flingContainer)
flingToggleBtn.Size = UDim2.new(0.62, 0, 0, 36)
flingToggleBtn.Position = UDim2.new(0, 10, 0, 10)
flingToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
flingToggleBtn.TextColor3 = Color3.new(1, 1, 1)
flingToggleBtn.Font = Enum.Font.SourceSansBold
flingToggleBtn.TextSize = 15
flingToggleBtn.Text = "OFF"
flingToggleBtn.ZIndex = 5
Instance.new("UICorner", flingToggleBtn).CornerRadius = UDim.new(0, 8)

local flingPowerInput = Instance.new("TextBox", flingContainer)
flingPowerInput.Size = UDim2.new(0.32, 0, 0, 36)
flingPowerInput.Position = UDim2.new(1, -112, 0, 10)
flingPowerInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
flingPowerInput.TextColor3 = Color3.fromRGB(255, 255, 255)
flingPowerInput.Font = Enum.Font.SourceSansBold
flingPowerInput.TextSize = 14
flingPowerInput.Text = "100000"
flingPowerInput.PlaceholderText = "Power"
flingPowerInput.ZIndex = 5
Instance.new("UICorner", flingPowerInput).CornerRadius = UDim.new(0, 8)

local flingTitleLbl = Instance.new("TextLabel", flingContainer)
flingTitleLbl.Size = UDim2.new(1, -20, 0, 28)
flingTitleLbl.Position = UDim2.new(0, 10, 0, 56)
flingTitleLbl.BackgroundTransparency = 1
flingTitleLbl.TextColor3 = Color3.fromRGB(0, 180, 255)
flingTitleLbl.Font = Enum.Font.SourceSansBold
flingTitleLbl.TextSize = 13
flingTitleLbl.Text = "Walkfling (Muffins Fling Engine)"
flingTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
flingTitleLbl.ZIndex = 5

local muffinsActive = false
flingToggleBtn.MouseButton1Click:Connect(function()
    muffinsActive = not muffinsActive
    flingToggleBtn.Text = muffinsActive and "FLINGING..." or "OFF"
    if not muffinsActive then flingToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200) end
end)

R.PostSimulation:Connect(function()
    if muffinsActive then
        flingToggleBtn.BackgroundColor3 = Color3.fromHSV(tick() % 3 / 3, 0.6, 0.8)
        for _, player in pairs(P:GetPlayers()) do
            if player ~= LP and player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LP.Character.HumanoidRootPart
            local strength = tonumber(flingPowerInput.Text) or 100000
            local oldV = hrp.Velocity
            hrp.Velocity = Vector3.new(strength, strength, strength)
            for _, v in pairs(LP.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
            R.RenderStepped:Wait()
            hrp.Velocity = oldV
        end
    end
end)

-- 5. Fling All Tab
local flingAllFF = CreateSection("FlingAll", 420)
local faHeader = Instance.new("TextLabel", flingAllFF)
faHeader.Size = UDim2.new(1, -20, 0, 36)
faHeader.Position = UDim2.new(0, 10, 0, 10)
faHeader.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
faHeader.TextColor3 = Color3.new(1, 1, 1)
faHeader.Font = Enum.Font.SourceSansBold 
faHeader.TextSize = 17
faHeader.Text = "💀 Fling All & Target Selector"
faHeader.ZIndex = 4
Instance.new("UICorner", faHeader).CornerRadius = UDim.new(0, 6)

local faSearchBox = Instance.new("TextBox", flingAllFF)
faSearchBox.Size = UDim2.new(1, -20, 0, 35)
faSearchBox.Position = UDim2.new(0, 10, 0, 54)
faSearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
faSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
faSearchBox.Font = Enum.Font.SourceSansBold
faSearchBox.TextSize = 14
faSearchBox.Text = ""
faSearchBox.PlaceholderText = "Search player to target..."
faSearchBox.ZIndex = 5
Instance.new("UICorner", faSearchBox).CornerRadius = UDim.new(0, 6)

local faPlayerScroll = Instance.new("ScrollingFrame", flingAllFF)
faPlayerScroll.Size = UDim2.new(1, -20, 0, 130)
faPlayerScroll.Position = UDim2.new(0, 10, 0, 95)
faPlayerScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
faPlayerScroll.BackgroundTransparency = 0.35
faPlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
faPlayerScroll.ScrollBarThickness = 4
faPlayerScroll.ZIndex = 5
Instance.new("UICorner", faPlayerScroll).CornerRadius = UDim.new(0, 8)

local selectedFlingTargets = {}
local function refreshFlingAllList()
    for _, child in ipairs(faPlayerScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    local query = faSearchBox.Text:lower()
    local yPos = 0
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= LP then
            local pName = p.Name:lower()
            local pDisp = p.DisplayName:lower()
            if query == "" or pName:find(query) or pDisp:find(query) then
                local entry = Instance.new("Frame", faPlayerScroll)
                entry.Size = UDim2.new(1, -10, 0, 30)
                entry.Position = UDim2.new(0, 5, 0, yPos)
                entry.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                entry.ZIndex = 6
                Instance.new("UICorner", entry).CornerRadius = UDim.new(0, 4)

                local cb = Instance.new("TextButton", entry)
                cb.Size = UDim2.new(0, 20, 0, 20)
                cb.Position = UDim2.new(0, 5, 0.5, -10)
                cb.BackgroundColor3 = selectedFlingTargets[p] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(60, 60, 60)
                cb.Text = selectedFlingTargets[p] and "✓" or ""
                cb.TextColor3 = Color3.new(1, 1, 1)
                cb.Font = Enum.Font.SourceSansBold
                cb.TextSize = 14
                cb.ZIndex = 7
                Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 4)

                local lbl = Instance.new("TextLabel", entry)
                lbl.Size = UDim2.new(1, -35, 1, 0)
                lbl.Position = UDim2.new(0, 32, 0, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
                lbl.Font = Enum.Font.SourceSansBold
                lbl.TextSize = 13
                lbl.Text = p.Name .. " (" .. p.DisplayName .. ")"
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.ZIndex = 7

                cb.MouseButton1Click:Connect(function()
                    if selectedFlingTargets[p] then
                        selectedFlingTargets[p] = nil
                        cb.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                        cb.Text = ""
                    else
                        selectedFlingTargets[p] = true
                        cb.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
                        cb.Text = "✓"
                    end
                end)

                yPos = yPos + 34
            end
        end
    end
    faPlayerScroll.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

faSearchBox:GetPropertyChangedSignal("Text"):Connect(refreshFlingAllList)
task.spawn(function()
    while true do
        task.wait(3)
        pcall(refreshFlingAllList)
    end
end)
task.spawn(refreshFlingAllList)

local startFlingAllBtn = Instance.new("TextButton", flingAllFF)
startFlingAllBtn.Size = UDim2.new(1, -20, 0, 38)
startFlingAllBtn.Position = UDim2.new(0, 10, 0, 235)
startFlingAllBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
startFlingAllBtn.TextColor3 = Color3.new(1, 1, 1)
startFlingAllBtn.Font = Enum.Font.SourceSansBold
startFlingAllBtn.TextSize = 15
startFlingAllBtn.Text = "START FLING SELECTED / ALL"
startFlingAllBtn.ZIndex = 5
Instance.new("UICorner", startFlingAllBtn).CornerRadius = UDim.new(0, 8)

local stopFlingAllBtn = Instance.new("TextButton", flingAllFF)
stopFlingAllBtn.Size = UDim2.new(1, -20, 0, 38)
stopFlingAllBtn.Position = UDim2.new(0, 10, 0, 279)
stopFlingAllBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
stopFlingAllBtn.TextColor3 = Color3.new(1, 1, 1)
stopFlingAllBtn.Font = Enum.Font.SourceSansBold
stopFlingAllBtn.TextSize = 15
stopFlingAllBtn.Text = "STOP FLING ALL"
stopFlingAllBtn.ZIndex = 5
Instance.new("UICorner", stopFlingAllBtn).CornerRadius = UDim.new(0, 8)

local flingAllActive = false
startFlingAllBtn.MouseButton1Click:Connect(function()
    flingAllActive = true
    task.spawn(function()
        while flingAllActive do
            local targetsToFling = {}
            for p, _ in pairs(selectedFlingTargets) do
                if p and p.Parent then table.insert(targetsToFling, p) end
            end
            if #targetsToFling == 0 then
                for _, p in pairs(P:GetPlayers()) do
                    if p ~= LP then table.insert(targetsToFling, p) end
                end
            end

            for _, p in ipairs(targetsToFling) do
                if not flingAllActive then break end
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        local hrp = p.Character.HumanoidRootPart
                        local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                        if myHrp then
                            myHrp.CFrame = hrp.CFrame
                            myHrp.Velocity = Vector3.new(9e7, 9e7, 9e7)
                        end
                    end)
                    task.wait(0.1)
                end
            end
            task.wait(0.5)
        end
    end)
end)

stopFlingAllBtn.MouseButton1Click:Connect(function()
    flingAllActive = false
end)

-- 6. All Spam Section (Clean & Merged without All-Execute button)
local allSpamFF = CreateSection("AllSpam", 1000)
local asHeader = Instance.new("TextLabel", allSpamFF)
asHeader.Size = UDim2.new(1, -20, 0, 36)
asHeader.Position = UDim2.new(0, 10, 0, 10)
asHeader.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
asHeader.TextColor3 = Color3.new(1, 1, 1)
asHeader.Font = Enum.Font.SourceSansBold 
asHeader.TextSize = 17
asHeader.Text = "📢 Spammers & GitHub Custom Slots"
asHeader.ZIndex = 4
Instance.new("UICorner", asHeader).CornerRadius = UDim.new(0, 6)

createLoadstringButton(allSpamFF, "AYAN SPAMMER", 56, "https://raw.githubusercontent.com/ayanjaveed503-a11y/EVERYONE-SCRIPT/refs/heads/main/AYAN%20SPAMMER")
createLoadstringButton(allSpamFF, "BUNNY SPAMMER", 104, "https://raw.githubusercontent.com/ayanjaveed503-a11y/AYAN-SPAM/refs/heads/main/TALHA%20SPAMMER.lua")
createLoadstringButton(allSpamFF, "TALHA SPAMMER", 152, "https://raw.githubusercontent.com/ayanjaveed503-a11y/AYAN-SPAM/refs/heads/main/TALHA%20SPAMMER.lua")
createLoadstringButton(allSpamFF, "MEHDI SPAMMER", 200, "https://raw.githubusercontent.com/ayanjaveed503-a11y/EVERYONE-SCRIPT/refs/heads/main/MEHDI%20SPAM.txt")
createLoadstringButton(allSpamFF, "ARHAN SPAMMER", 248, "https://raw.githubusercontent.com/ayanjaveed503-a11y/EVERYONE-SCRIPT/refs/heads/main/ARHAN%20SPAM.txt")
createLoadstringButton(allSpamFF, "SAMRAT SPAMMER", 296, "https://raw.githubusercontent.com/ayanjaveed503-a11y/EVERYONE-SCRIPT/refs/heads/main/SAMRAT%20SPAM.txt")
createLoadstringButton(allSpamFF, "TRIO SPAMMER", 344, "https://raw.githubusercontent.com/ayanjaveed503-a11y/EVERYONE-SCRIPT/refs/heads/main/TRIO%20SPAM%20.txt")
createLoadstringButton(allSpamFF, "MIKEY SPAMMER", 392, "https://raw.githubusercontent.com/MuddyyXScripts/MIKEY-SPAMMER-V1/refs/heads/main/ObfuscatedByMonKFuscate.luau%20(5).txt")
createLoadstringButton(allSpamFF, "BUNNY SPAMMERV2", 440, "https://raw.githubusercontent.com/ayanjaveed503-a11y/AYAN-SPAM/refs/heads/main/BUNNY%20SPAM.txt")

local extraLabel = Instance.new("TextLabel", allSpamFF)
extraLabel.Size = UDim2.new(1, -20, 0, 28)
extraLabel.Position = UDim2.new(0, 10, 0, 488)
extraLabel.BackgroundTransparency = 1
extraLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
extraLabel.Font = Enum.Font.SourceSansBold
extraLabel.TextSize = 14
extraLabel.Text = "--- 10 GitHub Custom Spam Slots ---"
extraLabel.TextXAlignment = Enum.TextXAlignment.Left

createLoadstringButton(allSpamFF, "📢 GitHub Spam Slot 1", 524, "GitHub_Link_1_Yahan_Paste_Karein")
createLoadstringButton(allSpamFF, "📢 GitHub Spam Slot 2", 572, "GitHub_Link_2_Yahan_Paste_Karein")
createLoadstringButton(allSpamFF, "📢 GitHub Spam Slot 3", 620, "GitHub_Link_3_Yahan_Paste_Karein")
createLoadstringButton(allSpamFF, "📢 GitHub Spam Slot 4", 668, "GitHub_Link_4_Yahan_Paste_Karein")
createLoadstringButton(allSpamFF, "📢 GitHub Spam Slot 5", 716, "GitHub_Link_5_Yahan_Paste_Karein")
createLoadstringButton(allSpamFF, "📢 GitHub Spam Slot 6", 764, "GitHub_Link_6_Yahan_Paste_Karein")
createLoadstringButton(allSpamFF, "📢 GitHub Spam Slot 7", 812, "GitHub_Link_7_Yahan_Paste_Karein")
createLoadstringButton(allSpamFF, "📢 GitHub Spam Slot 8", 860, "GitHub_Link_8_Yahan_Paste_Karein")
createLoadstringButton(allSpamFF, "📢 GitHub Spam Slot 9", 908, "GitHub_Link_9_Yahan_Paste_Karein")
createLoadstringButton(allSpamFF, "📢 GitHub Spam Slot 10", 956, "GitHub_Link_10_Yahan_Paste_Karein")

-- 7. Script Section
local mastScriptFF = CreateSection("MastScript", 550)
local msHeader = Instance.new("TextLabel", mastScriptFF)
msHeader.Size = UDim2.new(1, -20, 0, 36)
msHeader.Position = UDim2.new(0, 10, 0, 10)
msHeader.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
msHeader.TextColor3 = Color3.new(1, 1, 1)
msHeader.Font = Enum.Font.SourceSansBold 
msHeader.TextSize = 17
msHeader.Text = "🔥 Script Section & Loadstrings"
msHeader.ZIndex = 4
Instance.new("UICorner", msHeader).CornerRadius = UDim.new(0, 6)

createLoadstringButton(mastScriptFF, "GAZE EMOTE", 56, "https://raw.githubusercontent.com/Gazer-Ha/Gaze-stuff/refs/heads/main/Gaze%20emote")
createLoadstringButton(mastScriptFF, "ZAYN CHAT-MOBILE", 104, "https://raw.githubusercontent.com/ZaynBoss01/ZAYN/refs/heads/main/Zayn-Roblox")
createLoadstringButton(mastScriptFF, "GLOBAL CHAT-PC", 152, "https://gist.githubusercontent.com/josh19mark-sys/276fd3c0ad985fe2476f6ce333b4354f/raw/a29997b49f6279e3c0a2564737bb020e7a885cb6/gistfile1.txt")
createLoadstringButton(mastScriptFF, "MUSIC PLAYER", 200, "https://api.aurorax.site/files/v5/loaders/fdc766682032eea1cd25a1b7a976d621")
createLoadstringButton(mastScriptFF, "ZM CHAT SOON-PC/MOBILE", 248, "https://raw.githubusercontent.com/MuddyyXScrds/main/ObfuscatedByMonKFuscate.luau%20(5).txt")
createLoadstringButton(mastScriptFF, "INFINITE YIELD", 296, "Aapki_Chhathi_Script_Ka_Link")
createLoadstringButton(mastScriptFF, "📜 Script Hub soon 7", 344, "Aapki_Saatv_Script_Ka_Link")
createLoadstringButton(mastScriptFF, "📜 Script Hub soon 8", 392, "Aapki_Aathv_Script_Ka_Link")
createLoadstringButton(mastScriptFF, "📜 Script Hub soon 9", 440, "Aapki_Nauv_Script_Ka_Link")
createLoadstringButton(mastScriptFF, "📜 Script Hub soon 10", 488, "Aapki_Dasv_Script_Ka_Link")

-- 8. Life Together Section
local lifeTogetherFF = CreateSection("LifeTogether", 550)

local lockScreen = Instance.new("Frame", lifeTogetherFF)
lockScreen.Size = UDim2.new(1, 0, 1, 0)
lockScreen.Position = UDim2.new(0, 0, 0, 0)
lockScreen.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
lockScreen.BackgroundTransparency = 0.35
lockScreen.ZIndex = 10
Instance.new("UICorner", lockScreen).CornerRadius = UDim.new(0, 8)

local lockTitle = Instance.new("TextLabel", lockScreen)
lockTitle.Size = UDim2.new(1, -20, 0, 40)
lockTitle.Position = UDim2.new(0, 10, 0, 25)
lockTitle.BackgroundTransparency = 1
lockTitle.TextColor3 = Color3.fromRGB(0, 150, 255)
lockTitle.Font = Enum.Font.SourceSansBold
lockTitle.TextSize = 18
lockTitle.Text = "🔒 Life Together is Locked"
lockTitle.ZIndex = 11

local passBox = Instance.new("TextBox", lockScreen)
passBox.Size = UDim2.new(1, -60, 0, 42)
passBox.Position = UDim2.new(0, 30, 0, 75)
passBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
passBox.TextColor3 = Color3.fromRGB(255, 255, 255)
passBox.Font = Enum.Font.SourceSansBold
passBox.TextSize = 16
passBox.Text = ""
passBox.PlaceholderText = "Enter PIN Code ..."
passBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
passBox.ClearTextOnFocus = false
passBox.ZIndex = 11
Instance.new("UICorner", passBox).CornerRadius = UDim.new(0, 8)

local passStatus = Instance.new("TextLabel", lockScreen)
passStatus.Size = UDim2.new(1, -20, 0, 30)
passStatus.Position = UDim2.new(0, 10, 0, 125)
passStatus.BackgroundTransparency = 1
passStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
passStatus.Font = Enum.Font.SourceSansBold
passStatus.TextSize = 14
passStatus.Text = "Type password and press Enter"
passStatus.ZIndex = 11

local ltContent = Instance.new("ScrollingFrame", lifeTogetherFF)
ltContent.Size = UDim2.new(1, 0, 1, 0)
ltContent.Position = UDim2.new(0, 0, 0, 0)
ltContent.BackgroundTransparency = 1
ltContent.CanvasSize = UDim2.new(0, 0, 0, 550)
ltContent.ScrollBarThickness = 4
ltContent.Visible = false
ltContent.ZIndex = 4

local ltHeader = Instance.new("TextLabel", ltContent)
ltHeader.Size = UDim2.new(1, -20, 0, 36)
ltHeader.Position = UDim2.new(0, 10, 0, 10)
ltHeader.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
ltHeader.TextColor3 = Color3.new(1, 1, 1)
ltHeader.Font = Enum.Font.SourceSansBold 
ltHeader.TextSize = 17
ltHeader.Text = "🏡 Life Together & Loadstrings"
ltHeader.ZIndex = 5
Instance.new("UICorner", ltHeader).CornerRadius = UDim.new(0, 6)

createLoadstringButton(ltContent, "🏠 Life Together Script 1", 56, "Aapki_Pehli_Script_Ka_Link")
createLoadstringButton(ltContent, "🏠 Life Together Script 2", 104, "Aapki_Doosri_Script_Ka_Link")
createLoadstringButton(ltContent, "🏠 Life Together Script 3", 152, "Aapki_Teesri_Script_Ka_Link")
createLoadstringButton(ltContent, "🏠 Life Together Script 4", 200, "Aapki_Chauthi_Script_Ka_Link")
createLoadstringButton(ltContent, "🏠 Life Together Script 5", 248, "Aapki_Paanchv_Script_Ka_Link")
createLoadstringButton(ltContent, "🏠 Life Together Script 6", 296, "Aapki_Chhathi_Script_Ka_Link")
createLoadstringButton(ltContent, "🏠 Life Together Script 7", 344, "Aapki_Saatv_Script_Ka_Link")
createLoadstringButton(ltContent, "🏠 Life Together Script 8", 392, "Aapki_Aathv_Script_Ka_Link")
createLoadstringButton(ltContent, "🏠 Life Together Script 9", 440, "Aapki_Nauv_Script_Ka_Link")
createLoadstringButton(ltContent, "🏠 Life Together Script 10", 488, "Aapki_Dasv_Script_Ka_Link")

passBox.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    if passBox.Text == "9900" then
        lockScreen.Visible = false
        ltContent.Visible = true
    else
        passStatus.Text = "❌ Incorrect Password! Try again."
        passStatus.TextColor3 = Color3.fromRGB(255, 50, 50)
        passBox.Text = ""
    end
end)

-- 9. Player List & Game Time Section
local ptFF = CreateSection("PlayTime", 600)
local ptHeader = Instance.new("TextLabel", ptFF)
ptHeader.Size = UDim2.new(1, -20, 0, 36)
ptHeader.Position = UDim2.new(0, 10, 0, 10)
ptHeader.BackgroundColor3 = Color3.fromRGB(0, 60, 120)
ptHeader.TextColor3 = Color3.new(1, 1, 1)
ptHeader.Font = Enum.Font.SourceSansBold 
ptHeader.TextSize = 16
ptHeader.Text = "👥 Player List & Server Time Tracker"
ptHeader.ZIndex = 4
Instance.new("UICorner", ptHeader).CornerRadius = UDim.new(0, 6)

local myTimeLabel = Instance.new("TextLabel", ptFF)
myTimeLabel.Size = UDim2.new(1, -20, 0, 38)
myTimeLabel.Position = UDim2.new(0, 10, 0, 52)
myTimeLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
myTimeLabel.BackgroundTransparency = 0.35
myTimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
myTimeLabel.Font = Enum.Font.FredokaOne
myTimeLabel.TextSize = 15
myTimeLabel.ZIndex = 4
Instance.new("UICorner", myTimeLabel).CornerRadius = UDim.new(0, 8)

task.spawn(function()
    while ptFF and ptFF.Parent do 
        task.wait(1)
        myTimeLabel.Text = "⏱️ My Session: " .. pt.Value 
    end 
end)

local plSearchBox = Instance.new("TextBox", ptFF)
plSearchBox.Size = UDim2.new(1, -20, 0, 35)
plSearchBox.Position = UDim2.new(0, 10, 0, 98)
plSearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
plSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
plSearchBox.Font = Enum.Font.SourceSansBold
plSearchBox.TextSize = 14
plSearchBox.Text = ""
plSearchBox.PlaceholderText = "Search player in server..."
plSearchBox.ZIndex = 5
Instance.new("UICorner", plSearchBox).CornerRadius = UDim.new(0, 6)

local plScrollList = Instance.new("ScrollingFrame", ptFF)
plScrollList.Size = UDim2.new(1, -20, 0, 230)
plScrollList.Position = UDim2.new(0, 10, 0, 140)
plScrollList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
plScrollList.BackgroundTransparency = 0.35
plScrollList.CanvasSize = UDim2.new(0, 0, 0, 0)
plScrollList.ScrollBarThickness = 4
plScrollList.ZIndex = 5
Instance.new("UICorner", plScrollList).CornerRadius = UDim.new(0, 8)

local function refreshServerPlayerList()
    for _, child in ipairs(plScrollList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    local query = plSearchBox.Text:lower()
    local yPos = 0
    for _, p in ipairs(P:GetPlayers()) do
        local pName = p.Name:lower()
        local pDisp = p.DisplayName:lower()
        if query == "" or pName:find(query) or pDisp:find(query) then
            local entry = Instance.new("Frame", plScrollList)
            entry.Size = UDim2.new(1, -10, 0, 36)
            entry.Position = UDim2.new(0, 5, 0, yPos)
            entry.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            entry.ZIndex = 6
            Instance.new("UICorner", entry).CornerRadius = UDim.new(0, 6)

            local pInfoLbl = Instance.new("TextLabel", entry)
            pInfoLbl.Size = UDim2.new(1, -10, 1, 0)
            pInfoLbl.Position = UDim2.new(0, 8, 0, 0)
            pInfoLbl.BackgroundTransparency = 1
            pInfoLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            pInfoLbl.Font = Enum.Font.SourceSansBold
            pInfoLbl.TextSize = 13
            
            local joinTick = playerJoinTimes[p] or tick()
            local timePlaying = tick() - joinTick
            pInfoLbl.Text = p.Name .. " (" .. p.DisplayName .. ") | Time: " .. FPT(math.floor(timePlaying))
            pInfoLbl.TextXAlignment = Enum.TextXAlignment.Left
            pInfoLbl.ZIndex = 7

            yPos = yPos + 40
        end
    end
    plScrollList.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

plSearchBox:GetPropertyChangedSignal("Text"):Connect(refreshServerPlayerList)
task.spawn(function()
    while true do
        task.wait(1)
        pcall(refreshServerPlayerList)
    end
end)

-- 10. Anti-AFK Section
local afkFF = CreateSection("AFK", 230)

local afkMain = Instance.new("Frame", afkFF)
afkMain.Size = UDim2.new(1, -20, 0, 175)
afkMain.Position = UDim2.new(0, 10, 0, 10)
afkMain.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
afkMain.BackgroundTransparency = 0.35
afkMain.BorderSizePixel = 0
afkMain.ZIndex = 4
Instance.new("UICorner", afkMain).CornerRadius = UDim.new(0, 12)

local afkStroke = Instance.new("UIStroke", afkMain)
afkStroke.Color = Color3.fromRGB(0, 100, 200)
afkStroke.Thickness = 1.5

local RainContainer = Instance.new("Frame", afkMain)
RainContainer.Size = UDim2.new(1, 0, 1, 0)
RainContainer.BackgroundTransparency = 1
RainContainer.ZIndex = 4

local function SpawnRainDrop()
    local drop = Instance.new("Frame")
    local startX = math.random(0, 240)
    local dropLength = math.random(10, 20)
    local dropSpeed = math.random(6, 12) / 10

    drop.Size = UDim2.new(0, 2, 0, dropLength)
    drop.Position = UDim2.new(0, startX, 0, -dropLength)
    drop.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    drop.BackgroundTransparency = math.random(3, 6) / 10
    drop.BorderSizePixel = 0
    drop.ZIndex = 5
    drop.Parent = RainContainer

    local tween = TweenService:Create(drop, TweenInfo.new(dropSpeed, Enum.EasingStyle.Linear), {
        Position = UDim2.new(0, startX - math.random(8, 15), 1, dropLength)
    })
    tween:Play()
    tween.Completed:Connect(function() drop:Destroy() end)
end

task.spawn(function()
    while afkMain and afkMain.Parent do
        SpawnRainDrop()
        task.wait(0.05)
    end
end)

local Header = Instance.new("Frame", afkMain)
Header.BackgroundTransparency = 1
Header.Position = UDim2.new(0, 0, 0, 8)
Header.Size = UDim2.new(1, 0, 0, 26)
Header.ZIndex = 5

local UserImage = Instance.new("ImageLabel", Header)
UserImage.BackgroundTransparency = 1
UserImage.Position = UDim2.new(0, 10, 0, 0)
UserImage.Size = UDim2.new(0, 24, 0, 24)
UserImage.ZIndex = 5
Instance.new("UICorner", UserImage).CornerRadius = UDim.new(1, 0)
pcall(function()
    UserImage.Image = P:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
end)

local TitleLabel = Instance.new("TextLabel", Header)
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 40, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "AYANUU AFK"
TitleLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.FredokaOne
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 5

local TimerLabel = Instance.new("TextLabel", afkMain)
TimerLabel.Size = UDim2.new(1, 0, 0, 26)
TimerLabel.Position = UDim2.new(0, 0, 0, 38)
TimerLabel.BackgroundTransparency = 1
TimerLabel.Text = "000:00:00"
TimerLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
TimerLabel.TextSize = 20
TimerLabel.Font = Enum.Font.Code
TimerLabel.ZIndex = 5

local DayLabel = Instance.new("TextLabel", afkMain)
DayLabel.Size = UDim2.new(1, 0, 0, 18)
DayLabel.Position = UDim2.new(0, 0, 0, 66)
DayLabel.BackgroundTransparency = 1
DayLabel.Text = "day : 0"
DayLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
DayLabel.TextSize = 13
DayLabel.Font = Enum.Font.SourceSansBold
DayLabel.ZIndex = 5

local SavesLabel = Instance.new("TextLabel", afkMain)
SavesLabel.Size = UDim2.new(1, 0, 0, 18)
SavesLabel.Position = UDim2.new(0, 0, 0, 88)
SavesLabel.BackgroundTransparency = 1
SavesLabel.Text = "Kicks Prevented: 0"
SavesLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
SavesLabel.TextSize = 12
SavesLabel.Font = Enum.Font.SourceSansBold
SavesLabel.ZIndex = 5

local StatusLabel = Instance.new("TextLabel", afkMain)
StatusLabel.Size = UDim2.new(1, 0, 0, 18)
StatusLabel.Position = UDim2.new(0, 0, 0, 110)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Anti-AFK: Active"
StatusLabel.TextColor3 = Color3.fromRGB(80, 220, 80)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.ZIndex = 5

local afkToggleContainer, setAfkState = CreateToggleSwitch(afkMain, "Toggle AFK Engine", 136, function(state)
    StatusLabel.Text = state and "Anti-AFK: Active" or "Anti-AFK: Paused"
    StatusLabel.TextColor3 = state and Color3.fromRGB(80, 220, 80) or Color3.fromRGB(220, 80, 80)
end, true)
afkToggleContainer.ZIndex = 6

local kicksSaved = 0
LP.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0, 0))
    pcall(function()
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
    kicksSaved += 1
    SavesLabel.Text = "Kicks Prevented: " .. kicksSaved
end)

local startTime = tick()
task.spawn(function()
    while true do
        local elapsedTime = tick() - startTime
        local hours = math.floor(elapsedTime / 3600)
        local minutes = math.floor((elapsedTime % 3600) / 60)
        local seconds = math.floor(elapsedTime % 60)
        local days = math.floor(elapsedTime / 86400)
        
        TimerLabel.Text = string.format("%03d:%02d:%02d", hours, minutes, seconds)
        DayLabel.Text = "day : " .. days
        
        task.wait(1)
    end
end)

-- 11. Enhanced FPS Section
local fpsFF = CreateSection("FPS", 220)
local titleLbl = Instance.new("TextLabel", fpsFF)
titleLbl.Size = UDim2.new(1, 0, 0, 28)
titleLbl.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
titleLbl.TextColor3 = Color3.new(1, 1, 1)
titleLbl.Font = Enum.Font.SourceSansBold 
titleLbl.TextSize = 14
titleLbl.Text = "📊 Enhanced FPS & Boosters"
titleLbl.ZIndex = 4

local fpsLbl = Instance.new("TextLabel", fpsFF)
fpsLbl.Size = UDim2.new(1, -20, 0, 30)
fpsLbl.Position = UDim2.new(0, 10, 0, 34)
fpsLbl.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
fpsLbl.BackgroundTransparency = 0.35
fpsLbl.TextColor3 = Color3.fromRGB(0, 255, 0)
fpsLbl.Font = Enum.Font.SourceSansBold 
fpsLbl.TextSize = 14
fpsLbl.Text = "FPS: Measuring..."
fpsLbl.ZIndex = 4
Instance.new("UICorner", fpsLbl).CornerRadius = UDim.new(0, 6)

createLoadstringButton(fpsFF, "⚡ Ultra Antilag+antifire", 72, "https://scriptblox.com/raw/Universal-Script-Extra-Antilag-(Open-source)-229552")
createLoadstringButton(fpsFF, "⚡ Antilag", 114, "https://scriptblox.com/raw/Universal-Script-Antilag-by-DaMieN-172219")
createLoadstringButton(fpsFF, "⚡ Fps Booster", 156, "https://scriptblox.com/raw/Universal-Script-Optiz-FpsBooster-60070")

task.spawn(function()
    local lastTick = tick()
    local frameCount = 0
    R.RenderStepped:Connect(function()
        if not fpsFF or not fpsFF.Parent then return end
        frameCount += 1
        if tick() - lastTick >= 0.75 then
            local currentFPS = math.floor((frameCount / (tick() - lastTick)) + 0.5)
            frameCount = 0
            lastTick = tick()
            fpsLbl.Text = "FPS: " .. currentFPS
        end
    end)
end)

-- 12. Rejoin Section
local rjFF = CreateSection("Rejoin", 200)
local rjBtn = Instance.new("TextButton", rjFF)
rjBtn.Size = UDim2.new(1, -20, 0, 50)
rjBtn.Position = UDim2.new(0, 10, 0, 30)
rjBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
rjBtn.TextColor3 = Color3.new(1, 1, 1)
rjBtn.Font = Enum.Font.FredokaOne
rjBtn.TextSize = 18
rjBtn.Text = "🚀 Rejoin Server Now"
rjBtn.ZIndex = 5
Instance.new("UICorner", rjBtn).CornerRadius = UDim.new(0, 8)

rjBtn.MouseButton1Click:Connect(function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
end)

-- 13. Notes Section
local notesFF = CreateSection("Notes", 520)
local notesHeader = Instance.new("TextLabel", notesFF)
notesHeader.Size = UDim2.new(1, -20, 0, 36)
notesHeader.Position = UDim2.new(0, 10, 0, 10)
notesHeader.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
notesHeader.TextColor3 = Color3.new(1, 1, 1)
notesHeader.Font = Enum.Font.SourceSansBold 
notesHeader.TextSize = 17
notesHeader.Text = "📜 Panel Complete Features Guide"
notesHeader.ZIndex = 4
Instance.new("UICorner", notesHeader).CornerRadius = UDim.new(0, 6)

local notesScroll = Instance.new("ScrollingFrame", notesFF)
notesScroll.Size = UDim2.new(1, -20, 0, 440)
notesScroll.Position = UDim2.new(0, 10, 0, 56)
notesScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
notesScroll.BackgroundTransparency = 0.35
notesScroll.CanvasSize = UDim2.new(0, 0, 0, 550)
notesScroll.ScrollBarThickness = 4
notesScroll.ZIndex = 4
Instance.new("UICorner", notesScroll).CornerRadius = UDim.new(0, 8)

local notesBody = Instance.new("TextLabel", notesScroll)
notesBody.Size = UDim2.new(1, -15, 1, 0)
notesBody.Position = UDim2.new(0, 10, 0, 0)
notesBody.BackgroundTransparency = 1
notesBody.TextColor3 = Color3.fromRGB(255, 255, 255)
notesBody.Font = Enum.Font.SourceSansBold
notesBody.TextSize = 13
notesBody.TextXAlignment = Enum.TextXAlignment.Left
notesBody.TextYAlignment = Enum.TextYAlignment.Top
notesBody.TextWrapped = true
notesBody.Text = [[
• TARGETING: Search player name/display, View online status, Thumbnail preview, Goto Target Player, Mouthbang, Back Bang, Front Sit, Front Headsit, Black Backsit, Orbit Target, Aimbot, ESP, View/Unview.
• SHIELD: Smart Anti-Sit, Anti-Void, Anti-Fling, Anti-Teleport Kill, Anti-Glitch, Anti-Sit V2.
• ANTIBANG: Custom Speed AntiBang protection & 13 loadstring slots.
• PLAYER: Mobile Fly (ON/OFF), WalkSpeed, JumpPower, Infinite Jump, Noclip, ESP, Walkfling (Muffins Fling Engine).
• FLING ALL: Live Search Box + Interactive Player List Checkboxes + Start/Stop Fling Selected/All.
• ALL SPAM & 10 INDIVIDUAL SLOTS: Individual spam buttons + 10 separate GitHub loadstring slots.
• LIFE TOGETHER: PIN-locked exclusive map scripts with loadstring slots.
• PLAYER LIST & TIME: Live server player search + individual session/game time tracker.
• ANTI-AFK: Ayanuu AFK engine with custom rain UI, timer, and Kicks Prevented counter.
• ENHANCED FPS: Live FPS counter and Ultra Antilag, Antilag, Fps Booster.
• REJOIN: Instant server rejoin button.
• THEME & FEEDBACK: GUI outline & background color sliders, Rainbow GUI & Background toggles, Icon Image Slots, and MockAPI Feedback submission.
]]
notesBody.ZIndex = 5

-- 14. Theme Tab (With GUI Outline, GUI Background Slider, Rainbow GUI & Background options)
local themeFF = CreateSection("Theme", 1550)
local themeHeader = Instance.new("TextLabel", themeFF)
themeHeader.Size = UDim2.new(1, -20, 0, 36)
themeHeader.Position = UDim2.new(0, 10, 0, 10)
themeHeader.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
themeHeader.TextColor3 = Color3.new(1, 1, 1)
themeHeader.Font = Enum.Font.SourceSansBold 
themeHeader.TextSize = 17
themeHeader.Text = "🎨 Theme & Customization"
themeHeader.ZIndex = 4
Instance.new("UICorner", themeHeader).CornerRadius = UDim.new(0, 6)

-- 1. GUI Outline Color Slider
local guiColorTitle = Instance.new("TextLabel", themeFF)
guiColorTitle.Size = UDim2.new(1, -20, 0, 24)
guiColorTitle.Position = UDim2.new(0, 10, 0, 56)
guiColorTitle.BackgroundTransparency = 1
guiColorTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
guiColorTitle.Font = Enum.Font.SourceSansBold
guiColorTitle.TextSize = 14
guiColorTitle.Text = "GUI Outline Color Slider (Black to RGB):"
guiColorTitle.TextXAlignment = Enum.TextXAlignment.Left

local guiColorBar = Instance.new("TextButton", themeFF)
guiColorBar.Size = UDim2.new(1, -20, 0, 28)
guiColorBar.Position = UDim2.new(0, 10, 0, 82)
guiColorBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
guiColorBar.AutoButtonColor = false
guiColorBar.Text = ""
guiColorBar.ZIndex = 5
Instance.new("UICorner", guiColorBar).CornerRadius = UDim.new(0, 6)

local guiBarGradient = Instance.new("UIGradient", guiColorBar)
guiBarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
})

local guiThumb = Instance.new("Frame", guiColorBar)
guiThumb.Size = UDim2.new(0, 14, 1, 4)
guiThumb.Position = UDim2.new(0, 0, 0, -2)
guiThumb.BackgroundColor3 = Color3.new(1, 1, 1)
guiThumb.ZIndex = 6
Instance.new("UICorner", guiThumb).CornerRadius = UDim.new(0, 4)

local draggingGuiCol = false
guiColorBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingGuiCol = true
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingGuiCol = false
        draggingBgCol = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if draggingGuiCol and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mousePos = input.Position.X
        local barPos = guiColorBar.AbsolutePosition.X
        local barSize = guiColorBar.AbsoluteSize.X
        local relX = math.clamp((mousePos - barPos) / barSize, 0, 1)
        
        guiThumb.Position = UDim2.new(relX, -7, 0, -2)
        useGuiSliderColor = true
        rainbowGuiActive = false
        if relX == 0 then
            customGuiColor = Color3.fromRGB(0, 0, 0)
        else
            customGuiColor = Color3.fromHSV(relX, 1, 1)
        end
    end
end)

-- 2. GUI Background Color Slider
local bgColorTitle = Instance.new("TextLabel", themeFF)
bgColorTitle.Size = UDim2.new(1, -20, 0, 24)
bgColorTitle.Position = UDim2.new(0, 10, 0, 126)
bgColorTitle.BackgroundTransparency = 1
bgColorTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
bgColorTitle.Font = Enum.Font.SourceSansBold
bgColorTitle.TextSize = 14
bgColorTitle.Text = "GUI Background Color Slider (Black to RGB):"
bgColorTitle.TextXAlignment = Enum.TextXAlignment.Left

local bgColorBar = Instance.new("TextButton", themeFF)
bgColorBar.Size = UDim2.new(1, -20, 0, 28)
bgColorBar.Position = UDim2.new(0, 10, 0, 152)
bgColorBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
bgColorBar.AutoButtonColor = false
bgColorBar.Text = ""
bgColorBar.ZIndex = 5
Instance.new("UICorner", bgColorBar).CornerRadius = UDim.new(0, 6)

local bgBarGradient = Instance.new("UIGradient", bgColorBar)
bgBarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
})

local bgThumb = Instance.new("Frame", bgColorBar)
bgThumb.Size = UDim2.new(0, 14, 1, 4)
bgThumb.Position = UDim2.new(0, 0, 0, -2)
bgThumb.BackgroundColor3 = Color3.new(1, 1, 1)
bgThumb.ZIndex = 6
Instance.new("UICorner", bgThumb).CornerRadius = UDim.new(0, 4)

local draggingBgCol = false
bgColorBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingBgCol = true
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if draggingBgCol and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mousePos = input.Position.X
        local barPos = bgColorBar.AbsolutePosition.X
        local barSize = bgColorBar.AbsoluteSize.X
        local relX = math.clamp((mousePos - barPos) / barSize, 0, 1)
        
        bgThumb.Position = UDim2.new(relX, -7, 0, -2)
        useBgSliderColor = true
        rainbowBgActive = false
        if relX == 0 then
            customBgColor = Color3.fromRGB(0, 0, 0)
        else
            customBgColor = Color3.fromHSV(relX, 1, 1)
        end
    end
end)

local sizeTitle = Instance.new("TextLabel", themeFF)
sizeTitle.Size = UDim2.new(1, -20, 0, 24)
sizeTitle.Position = UDim2.new(0, 10, 0, 192)
sizeTitle.BackgroundTransparency = 1
sizeTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
sizeTitle.Font = Enum.Font.SourceSansBold
sizeTitle.TextSize = 14
sizeTitle.Text = "GUI Size (Width, Height):"
sizeTitle.TextXAlignment = Enum.TextXAlignment.Left

local sizeBox = Instance.new("TextBox", themeFF)
sizeBox.Size = UDim2.new(1, -20, 0, 35)
sizeBox.Position = UDim2.new(0, 10, 0, 218)
sizeBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
sizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
sizeBox.Font = Enum.Font.SourceSansBold
sizeBox.TextSize = 14
sizeBox.Text = "600, 420"
sizeBox.ZIndex = 5
Instance.new("UICorner", sizeBox).CornerRadius = UDim.new(0, 6)

sizeBox.FocusLost:Connect(function(enter)
    if enter then
        local w, h = string.match(sizeBox.Text, "(%d+)%s*,%s*(%d+)")
        if w and h then
            m.Size = UDim2.new(0, tonumber(w), 0, tonumber(h))
        end
    end
end)

local iconImgTitle = Instance.new("TextLabel", themeFF)
iconImgTitle.Size = UDim2.new(1, -20, 0, 24)
iconImgTitle.Position = UDim2.new(0, 10, 0, 270)
iconImgTitle.BackgroundTransparency = 1
iconImgTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
iconImgTitle.Font = Enum.Font.SourceSansBold
iconImgTitle.TextSize = 14
iconImgTitle.Text = "Floating Icon Image Slots (1 - 10):"
iconImgTitle.TextXAlignment = Enum.TextXAlignment.Left

local iconAssetIds = {
    "rbxassetid://125157479493186",
    "rbxassetid://116161784313166",
    "rbxassetid://6023426915",
    "rbxassetid://1851912648",
    "rbxassetid://6034293931",
    "rbxassetid://6034294025",
    "rbxassetid://6031094678",
    "rbxassetid://6031097225",
    "rbxassetid://6031097277",
    "rbxassetid://6034293855"
}

for i = 1, 10 do
    local iconImgBtn = Instance.new("TextButton", themeFF)
    iconImgBtn.Size = UDim2.new(1, -20, 0, 28)
    iconImgBtn.Position = UDim2.new(0, 10, 0, 300 + ((i - 1) * 33))
    iconImgBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    iconImgBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconImgBtn.Font = Enum.Font.SourceSansBold
    iconImgBtn.TextSize = 13
    iconImgBtn.Text = "Load Icon Image Slot " .. i
    iconImgBtn.ZIndex = 5
    Instance.new("UICorner", iconImgBtn).CornerRadius = UDim.new(0, 6)
    
    iconImgBtn.MouseButton1Click:Connect(function()
        tgImage.Image = iconAssetIds[i]
    end)
end

CreateToggleSwitch(themeFF, "Rainbow GUI Mode", 640, function(state)
    rainbowGuiActive = state
    if state then useGuiSliderColor = false end
end, false)

CreateToggleSwitch(themeFF, "Rainbow GUI Background Mode", 688, function(state)
    rainbowBgActive = state
    if state then useBgSliderColor = false end
end, false)

local destroyGuiBtn = Instance.new("TextButton", themeFF)
destroyGuiBtn.Size = UDim2.new(1, -20, 0, 38)
destroyGuiBtn.Position = UDim2.new(0, 10, 0, 744)
destroyGuiBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
destroyGuiBtn.TextColor3 = Color3.new(1, 1, 1)
destroyGuiBtn.Font = Enum.Font.SourceSansBold
destroyGuiBtn.TextSize = 15
destroyGuiBtn.Text = "🗑️ Destroy GUI (Remove)"
destroyGuiBtn.ZIndex = 5
Instance.new("UICorner", destroyGuiBtn).CornerRadius = UDim.new(0, 8)

destroyGuiBtn.MouseButton1Click:Connect(function()
    g:Destroy()
end)

-- 15. Feedback Tab
local feedbackFF = CreateSection("Feedback", 450)
local fbHeader = Instance.new("TextLabel", feedbackFF)
fbHeader.Size = UDim2.new(1, -20, 0, 36)
fbHeader.Position = UDim2.new(0, 10, 0, 10)
fbHeader.BackgroundColor3 = Color3.fromRGB(0, 120, 150)
fbHeader.TextColor3 = Color3.new(1, 1, 1)
fbHeader.Font = Enum.Font.SourceSansBold 
fbHeader.TextSize = 17
fbHeader.Text = "💬 Send Feedback to AYANUU"
fbHeader.ZIndex = 4
Instance.new("UICorner", fbHeader).CornerRadius = UDim.new(0, 6)

local fbNoticeLbl = Instance.new("TextLabel", feedbackFF)
fbNoticeLbl.Size = UDim2.new(1, -20, 0, 55)
fbNoticeLbl.Position = UDim2.new(0, 10, 0, 52)
fbNoticeLbl.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
fbNoticeLbl.BackgroundTransparency = 0.35
fbNoticeLbl.TextColor3 = Color3.fromRGB(0, 200, 255)
fbNoticeLbl.Font = Enum.Font.SourceSansBold
fbNoticeLbl.TextSize = 12
fbNoticeLbl.Text = "AGAR APKO YE SCRIPT PASAND AAYI FEEDBACK DENA OUR AGAR KISI OUR APNI SCRIPT YA SPAM ADD KARVANE HO TO SCRIPT BHEJ DO APNI AGAR KOI BUGS HO TO BATA DENA"
fbNoticeLbl.TextWrapped = true
fbNoticeLbl.TextXAlignment = Enum.TextXAlignment.Left
fbNoticeLbl.TextYAlignment = Enum.TextYAlignment.Top
fbNoticeLbl.ZIndex = 5
Instance.new("UICorner", fbNoticeLbl).CornerRadius = UDim.new(0, 6)

local fbTextBox = Instance.new("TextBox", feedbackFF)
fbTextBox.Size = UDim2.new(1, -20, 0, 90)
fbTextBox.Position = UDim2.new(0, 10, 0, 114)
fbTextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
fbTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
fbTextBox.Font = Enum.Font.SourceSansBold
fbTextBox.TextSize = 14
fbTextBox.Text = ""
fbTextBox.PlaceholderText = "Type your feedback, script submission or bug report here..."
fbTextBox.ClearTextOnFocus = false
fbTextBox.MultiLine = true
fbTextBox.TextWrapped = true
fbTextBox.TextYAlignment = Enum.TextYAlignment.Top
fbTextBox.ZIndex = 5
Instance.new("UICorner", fbTextBox).CornerRadius = UDim.new(0, 8)

local fbSubmitBtn = Instance.new("TextButton", feedbackFF)
fbSubmitBtn.Size = UDim2.new(1, -20, 0, 40)
fbSubmitBtn.Position = UDim2.new(0, 10, 0, 212)
fbSubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
fbSubmitBtn.TextColor3 = Color3.new(1, 1, 1)
fbSubmitBtn.Font = Enum.Font.SourceSansBold
fbSubmitBtn.TextSize = 15
fbSubmitBtn.Text = "📤 Submit Feedback"
fbSubmitBtn.ZIndex = 5
Instance.new("UICorner", fbSubmitBtn).CornerRadius = UDim.new(0, 8)

local fbStatus = Instance.new("TextLabel", feedbackFF)
fbStatus.Size = UDim2.new(1, -20, 0, 30)
fbStatus.Position = UDim2.new(0, 10, 0, 258)
fbStatus.BackgroundTransparency = 1
fbStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
fbStatus.Font = Enum.Font.SourceSansBold
fbStatus.TextSize = 14
fbStatus.Text = ""
fbStatus.ZIndex = 5

local MOCKAPI_URL = "https://6aef2e43b9925b27ce16b743.mockapi.io/v1/:endpoint"
local feedbackCount = 0
local cooldownActive = false

fbSubmitBtn.MouseButton1Click:Connect(function()
    local feedbackText = fbTextBox.Text
    if feedbackText == "" then
        fbStatus.Text = "⚠️ Please write something first!"
        fbStatus.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end

    if cooldownActive then
        fbStatus.Text = "⏳ Cooldown active! Please wait before sending more."
        fbStatus.TextColor3 = Color3.fromRGB(255, 150, 0)
        return
    end

    fbSubmitBtn.Text = "Sending..."
    task.spawn(function()
        local success, response = pcall(function()
            local data = {
                player = LP.Name,
                userId = LP.UserId,
                message = feedbackText,
                timestamp = os.date("%Y-%m-%d %H:%M:%S")
            }
            local jsonBody = HttpService:JSONEncode(data)
            return HttpService:PostAsync(MOCKAPI_URL, jsonBody, Enum.HttpContentType.ApplicationJson)
        end)

        if success then
            feedbackCount = feedbackCount + 1
            fbStatus.Text = "✅ Thank you! Feedback recorded successfully."
            fbStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
            fbTextBox.Text = ""

            if feedbackCount >= 2 then
                cooldownActive = true
                for i = 50, 1, -1 do
                    fbSubmitBtn.Text = "Cooldown: " .. i .. "s"
                    task.wait(1)
                end
                feedbackCount = 0
                cooldownActive = false
            end
        else
            fbStatus.Text = "❌ Failed to send. Check HTTP requests!"
            fbStatus.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
        fbSubmitBtn.Text = "📤 Submit Feedback"
    end)
end)
