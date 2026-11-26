-- Universal Executor Compatibility Script (Delta, Arceus X, Fluxus, Codex, iOS Executors, etc.)
-- Created for Ayan / ZM

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")

local HUB_ATTR_NAME = "AyanHubLiveUser"
local HUB_TAG_TEXT = "AYANUU HUB"

-- Universal httpGet function supporting Android, PC & iOS executors
local function universalHttpGet(url)
    if syn and syn.request then
        return syn.request({Url = url, Method = "GET"}).Body
    elseif fluxus and fluxus.request then
        return fluxus.request({Url = url, Method = "GET"}).Body
    elseif request then
        return request({Url = url, Method = "GET"}).Body
    elseif http_request then
        return http_request({Url = url, Method = "GET"}).Body
    elseif http and http.request then
        return http.request({Url = url, Method = "GET"}).Body
    else
        return game:HttpGet(url)
    end
end

-- Function to send chat message reliably across all executors
local function sendChatMessage(msg)
    pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local channels = TextChatService:FindFirstChild("TextChannels")
            if channels and channels:FindFirstChild("RBXGeneral") then
                channels.RBXGeneral:SendAsync(msg)
            end
        else
            local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if chatEvents and chatEvents:FindFirstChild("SayMessageRequest") then
                chatEvents.SayMessageRequest:FireServer(msg, "All")
            end
        end
    end)
end

-- Helper to clear target profile if target player leaves
local function clearTargetProfile()
    _G.TargetPlayerObj = nil
    _G.SelectedTarget = nil
    _G.TargetName = nil
end

-- Create ScreenGui securely
local persistentGui = playerGui:FindFirstChild("AyanHubPersistentGui")
if persistentGui then
    persistentGui:Destroy()
end
persistentGui = Instance.new("ScreenGui")
persistentGui.Name = "AyanHubPersistentGui"
persistentGui.ResetOnSpawn = false
persistentGui.IgnoreGuiInset = true
persistentGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
persistentGui.DisplayOrder = 120
persistentGui.Parent = playerGui

local introGui = playerGui:FindFirstChild("AyanHubIntroGui")
if introGui then
    introGui:Destroy()
end
introGui = Instance.new("ScreenGui")
introGui.Name = "AyanHubIntroGui"
introGui.ResetOnSpawn = false
introGui.IgnoreGuiInset = true
introGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
introGui.DisplayOrder = 130
introGui.Parent = playerGui

-- State variables
local selectedGender = ""
local enteredName = "USER"
local enteredGang1 = ""
local enteredGang2 = ""
local targetName = "NONE"
local isSkippingIntro = false
local hasLoadedMainHub = false
local tagsEnabled = true

-- Bottom-Right Notification System
local notifyCard = Instance.new("Frame")
notifyCard.Name = "BottomRightNotifyCard"
notifyCard.Size = UDim2.new(0, 310, 0, 62)
notifyCard.Position = UDim2.new(1, 330, 1, -82)
notifyCard.BackgroundColor3 = Color3.fromRGB(16, 15, 26)
notifyCard.BorderSizePixel = 0
notifyCard.ZIndex = 100
notifyCard.Parent = persistentGui
Instance.new("UICorner", notifyCard).CornerRadius = UDim.new(0, 12)

local notifyStroke = Instance.new("UIStroke")
notifyStroke.Color = Color3.fromRGB(115, 255, 175)
notifyStroke.Thickness = 2
notifyStroke.Parent = notifyCard

local notifyAccent = Instance.new("Frame")
notifyAccent.Size = UDim2.new(0, 5, 1, -14)
notifyAccent.Position = UDim2.new(0, 8, 0, 7)
notifyAccent.BackgroundColor3 = Color3.fromRGB(115, 255, 175)
notifyAccent.BorderSizePixel = 0
notifyAccent.ZIndex = 101
notifyAccent.Parent = notifyCard
Instance.new("UICorner", notifyAccent).CornerRadius = UDim.new(1, 0)

local notifyTitle = Instance.new("TextLabel")
notifyTitle.Size = UDim2.new(1, -28, 0, 22)
notifyTitle.Position = UDim2.new(0, 20, 0, 8)
notifyTitle.BackgroundTransparency = 1
notifyTitle.Text = ""
notifyTitle.TextColor3 = Color3.fromRGB(115, 255, 175)
notifyTitle.TextSize = 14
notifyTitle.TextXAlignment = Enum.TextXAlignment.Left
notifyTitle.Font = Enum.Font.GothamBold
notifyTitle.ZIndex = 101
notifyTitle.Parent = notifyCard

local notifySub = Instance.new("TextLabel")
notifySub.Size = UDim2.new(1, -28, 0, 20)
notifySub.Position = UDim2.new(0, 20, 0, 30)
notifySub.BackgroundTransparency = 1
notifySub.Text = ""
notifySub.TextColor3 = Color3.fromRGB(235, 235, 245)
notifySub.TextSize = 13
notifySub.TextXAlignment = Enum.TextXAlignment.Left
notifySub.TextTruncate = Enum.TextTruncate.AtEnd
notifySub.Font = Enum.Font.Gotham
notifySub.ZIndex = 101
notifySub.Parent = notifyCard

local notifyQueue = {}
local isShowingNotify = false

local function runNotifyQueue()
    if isShowingNotify or #notifyQueue == 0 then return end
    if not persistentGui or not persistentGui.Parent then return end
    isShowingNotify = true
    
    local item = table.remove(notifyQueue, 1)
    local accentColor = item.isJoin and Color3.fromRGB(80, 255, 150) or Color3.fromRGB(255, 95, 110)
    
    notifyTitle.Text = item.title
    notifyTitle.TextColor3 = accentColor
    notifySub.Text = item.detail
    notifyStroke.Color = accentColor
    notifyAccent.BackgroundColor3 = accentColor
    
    local slideIn = TweenService:Create(notifyCard, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingStyle.Out), {
        Position = UDim2.new(1, -326, 1, -82)
    })
    slideIn:Play()
    slideIn.Completed:Wait()
    
    task.wait(2.4)
    
    local slideOut = TweenService:Create(notifyCard, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingStyle.In), {
        Position = UDim2.new(1, 330, 1, -82)
    })
    slideOut:Play()
    slideOut.Completed:Wait()
    
    isShowingNotify = false
    runNotifyQueue()
end

local function showBottomRightNotify(titleText, detailText, isJoin)
    table.insert(notifyQueue, {
        title = titleText,
        detail = detailText,
        isJoin = isJoin
    })
    task.spawn(runNotifyQueue)
end

-- Live Hub Users Tag System (Only shows on players actively using this hub)
local function removePlayerTag(targetPlr)
    if targetPlr.Character then
        local head = targetPlr.Character:FindFirstChild("Head")
        if head then
            local existing = head:FindFirstChild("AyanHubLiveTag")
            if existing then
                existing:Destroy()
            end
        end
    end
end

local function applyPlayerTag(targetPlr)
    if not tagsEnabled or not targetPlr:GetAttribute(HUB_ATTR_NAME) then
        removePlayerTag(targetPlr)
        return
    end
    
    local character = targetPlr.Character
    if not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end
    
    removePlayerTag(targetPlr)
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "AyanHubLiveTag"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 235, 0, 58)
    billboard.StudsOffset = Vector3.new(0, 2.7, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 120
    billboard.Parent = head
    
    local pill = Instance.new("Frame")
    pill.Name = "TagPill"
    pill.Size = UDim2.new(1, 0, 1, 0)
    pill.BackgroundColor3 = Color3.fromRGB(14, 13, 22)
    pill.BorderSizePixel = 0
    pill.Parent = billboard
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2.4
    stroke.Parent = pill
    
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 255, 165)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 130, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(225, 95, 255))
    })
    grad.Parent = stroke
    
    local avatarHolder = Instance.new("Frame")
    avatarHolder.Size = UDim2.new(0, 42, 0, 42)
    avatarHolder.Position = UDim2.new(0, 8, 0.5, -21)
    avatarHolder.BackgroundColor3 = Color3.fromRGB(28, 26, 40)
    avatarHolder.BorderSizePixel = 0
    avatarHolder.Parent = pill
    Instance.new("UICorner", avatarHolder).CornerRadius = UDim.new(1, 0)
    
    local avatarStroke = Instance.new("UIStroke")
    avatarStroke.Color = Color3.fromRGB(165, 120, 255)
    avatarStroke.Thickness = 1.6
    avatarStroke.Parent = avatarHolder
    
    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Size = UDim2.new(1, 0, 1, 0)
    avatarImg.BackgroundTransparency = 1
    avatarImg.Parent = avatarHolder
    Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(1, 0)
    
    task.spawn(function()
        local ok, content = pcall(function()
            return Players:GetUserThumbnailAsync(targetPlr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok and content and avatarImg.Parent then
            avatarImg.Image = content
        end
    end)
    
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -62, 0, 22)
    nameLbl.Position = UDim2.new(0, 56, 0, 7)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = string.upper(targetPlr.Name)
    nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLbl.TextSize = 15
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Font = Enum.Font.GothamBlack
    nameLbl.Parent = pill
    
    local subLbl = Instance.new("TextLabel")
    subLbl.Size = UDim2.new(1, -62, 0, 18)
    subLbl.Position = UDim2.new(0, 56, 0, 28)
    subLbl.BackgroundTransparency = 1
    subLbl.Text = HUB_TAG_TEXT
    subLbl.TextColor3 = Color3.fromRGB(115, 255, 175)
    subLbl.TextSize = 13
    subLbl.TextXAlignment = Enum.TextXAlignment.Left
    subLbl.Font = Enum.Font.GothamBold
    subLbl.Parent = pill
end

local function refreshAllLiveUserTags()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr:GetAttribute(HUB_ATTR_NAME) then
            applyPlayerTag(plr)
        else
            removePlayerTag(plr)
        end
    end
end

local function markLocalPlayerAsLiveUser()
    player:SetAttribute(HUB_ATTR_NAME, true)
    refreshAllLiveUserTags()
end

local function hookPlayerTag(plr)
    plr:GetAttributeChangedSignal(HUB_ATTR_NAME):Connect(function()
        if plr:GetAttribute(HUB_ATTR_NAME) then
            applyPlayerTag(plr)
        else
            removePlayerTag(plr)
        end
    end)
    plr.CharacterAdded:Connect(function()
        task.wait(0.25)
        if plr:GetAttribute(HUB_ATTR_NAME) then
            applyPlayerTag(plr)
        end
    end)
    if plr:GetAttribute(HUB_ATTR_NAME) and plr.Character then
        applyPlayerTag(plr)
    end
end

for _, plr in ipairs(Players:GetPlayers()) do
    hookPlayerTag(plr)
end

-------------------------------------------------------------------
-- PLAYER JOIN/LEAVE LISTENERS & NOTIFICATIONS
-------------------------------------------------------------------
Players.PlayerAdded:Connect(function(plr)
    hookPlayerTag(plr)
    showBottomRightNotify("Player Joined", plr.DisplayName .. " (@" .. plr.Name .. ")", true)
end)

Players.PlayerRemoving:Connect(function(plr)
    showBottomRightNotify("Player Left", plr.DisplayName .. " (@" .. plr.Name .. ")", false)
    if _G.TargetPlayerObj == plr then
        clearTargetProfile()
    end
end)

-- Top-Right Tags Box with ON/OFF Toggle + ❌ Remove Button
local tagsContainer = Instance.new("Frame")
tagsContainer.Name = "TagsContainer"
tagsContainer.Size = UDim2.new(0, 146, 0, 36)
tagsContainer.Position = UDim2.new(1, -160, 0, 14)
tagsContainer.BackgroundColor3 = Color3.fromRGB(22, 20, 34)
tagsContainer.BorderSizePixel = 0
tagsContainer.ZIndex = 90
tagsContainer.Parent = persistentGui
Instance.new("UICorner", tagsContainer).CornerRadius = UDim.new(0, 10)

local tagsContainerStroke = Instance.new("UIStroke")
tagsContainerStroke.Color = Color3.fromRGB(115, 255, 175)
tagsContainerStroke.Thickness = 1.6
tagsContainerStroke.Parent = tagsContainer

local tagsToggleBtn = Instance.new("TextButton")
tagsToggleBtn.Name = "TagsToggleButton"
tagsToggleBtn.Size = UDim2.new(1, -30, 1, 0)
tagsToggleBtn.Position = UDim2.new(0, 0, 0, 0)
tagsToggleBtn.BackgroundTransparency = 1
tagsToggleBtn.Text = "TAGS: ON"
tagsToggleBtn.TextColor3 = Color3.fromRGB(115, 255, 175)
tagsToggleBtn.TextSize = 13
tagsToggleBtn.Font = Enum.Font.GothamBold
tagsToggleBtn.ZIndex = 91
tagsToggleBtn.Parent = tagsContainer

local closeTagsBtn = Instance.new("TextButton")
closeTagsBtn.Name = "RemoveTagsBoxButton"
closeTagsBtn.Size = UDim2.new(0, 24, 0, 24)
closeTagsBtn.Position = UDim2.new(1, -27, 0.5, -12)
closeTagsBtn.BackgroundColor3 = Color3.fromRGB(42, 22, 34)
closeTagsBtn.Text = "❌"
closeTagsBtn.TextColor3 = Color3.fromRGB(255, 110, 125)
closeTagsBtn.TextSize = 12
closeTagsBtn.Font = Enum.Font.GothamBold
closeTagsBtn.ZIndex = 92
closeTagsBtn.Parent = tagsContainer
Instance.new("UICorner", closeTagsBtn).CornerRadius = UDim.new(1, 0)

tagsToggleBtn.MouseButton1Click:Connect(function()
    tagsEnabled = not tagsEnabled
    if tagsEnabled then
        tagsToggleBtn.Text = "TAGS: ON"
        tagsToggleBtn.TextColor3 = Color3.fromRGB(115, 255, 175)
        tagsContainerStroke.Color = Color3.fromRGB(115, 255, 175)
    else
        tagsToggleBtn.Text = "TAGS: OFF"
        tagsToggleBtn.TextColor3 = Color3.fromRGB(255, 105, 125)
        tagsContainerStroke.Color = Color3.fromRGB(255, 105, 125)
    end
    refreshAllLiveUserTags()
end)

closeTagsBtn.MouseButton1Click:Connect(function()
    tagsContainer:Destroy()
end)

-- Forward Declarations
local showFullLoadingScreen, showGenderScreen, showNameScreen, showGangScreen, showTargetScreen, showTargetInputScreen, executeAndLoad, loadMainHubScript

-- Load GitHub script directly (only once)
function loadMainHubScript()
    if hasLoadedMainHub then return end
    hasLoadedMainHub = true
    markLocalPlayerAsLiveUser()
    
    pcall(function()
        local success, scriptContent = pcall(function()
            return universalHttpGet("https://raw.githubusercontent.com/ayanjaveed503-a11y/AYAN-HUB2/refs/heads/main/AYAN%20HUB%20PROTECT.lua")
        end)
        if success and scriptContent then
            loadstring(scriptContent)()
        end
    end)
end

-- Fixed Top-Center Skip Intro Button
local skipBtn = Instance.new("TextButton")
skipBtn.Name = "SkipIntroButton"
skipBtn.Size = UDim2.new(0, 152, 0, 38)
skipBtn.Position = UDim2.new(0.5, -76, 0, 14)
skipBtn.BackgroundColor3 = Color3.fromRGB(26, 22, 42)
skipBtn.Text = "SKIP INTRO ➔"
skipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
skipBtn.TextSize = 14
skipBtn.Font = Enum.Font.GothamBold
skipBtn.ZIndex = 95
skipBtn.Parent = persistentGui
Instance.new("UICorner", skipBtn).CornerRadius = UDim.new(0, 10)

local skipStroke = Instance.new("UIStroke")
skipStroke.Color = Color3.fromRGB(150, 105, 255)
skipStroke.Thickness = 1.6
skipStroke.Parent = skipBtn

skipBtn.MouseButton1Click:Connect(function()
    if isSkippingIntro then return end
    isSkippingIntro = true
    skipBtn.Visible = false
    if introGui then
        introGui:Destroy()
    end
    loadMainHubScript()
end)

-- Helper function to clear intro UI elements
local function clearCurrentUI()
    if not introGui or not introGui.Parent then return end
    for _, child in ipairs(introGui:GetChildren()) do
        child:Destroy()
    end
end

-- 0. FULL SCREEN LOADING SCREEN
function showFullLoadingScreen()
    if isSkippingIntro then return end
    clearCurrentUI()
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
    bg.Parent = introGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 420, 0, 220)
    mainFrame.Position = UDim2.new(0.5, -210, 0.5, -110)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = bg
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = " AYANUU HUB LOADING"
    titleLabel.TextColor3 = Color3.fromRGB(140, 100, 255)
    titleLabel.TextSize = 28
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame
    
    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, 0, 0, 20)
    subLabel.Position = UDim2.new(0, 0, 0, 60)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = "PREMIUM EDITION"
    subLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    subLabel.TextSize = 13
    subLabel.Font = Enum.Font.GothamBold
    subLabel.Parent = mainFrame
    
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0, 340, 0, 8)
    barBg.Position = UDim2.new(0.5, -170, 0, 115)
    barBg.BackgroundColor3 = Color3.fromRGB(35, 30, 45)
    barBg.Parent = mainFrame
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
    
    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
    barFill.Parent = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 30)
    statusLabel.Position = UDim2.new(0, 0, 0, 145)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Initializing files..."
    statusLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    statusLabel.TextSize = 13
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = mainFrame
    
    task.spawn(function()
        task.wait(0.5)
        if isSkippingIntro then return end
        barFill:TweenSize(UDim2.new(0.4, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.6, true)
        statusLabel.Text = "Bypassing security..."
        task.wait(0.7)
        if isSkippingIntro then return end
        barFill:TweenSize(UDim2.new(0.8, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.6, true)
        statusLabel.Text = "Loading user interface..."
        task.wait(0.7)
        if isSkippingIntro then return end
        barFill:TweenSize(UDim2.new(1, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5, true)
        statusLabel.Text = "READY"
        task.wait(0.5)
        if isSkippingIntro then return end
        showGenderScreen()
    end)
end

-- 1. GENDER SCREEN
function showGenderScreen()
    if isSkippingIntro then return end
    clearCurrentUI()
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 380, 0, 260)
    mainFrame.Position = UDim2.new(0.5, -190, 0.5, -130)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.Parent = introGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "SELECT BOY OR GIRL"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 70)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Your intro message depends on this"
    subtitle.TextColor3 = Color3.fromRGB(170, 170, 170)
    subtitle.TextSize = 13
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = mainFrame
    
    local boyBtn = Instance.new("TextButton")
    boyBtn.Size = UDim2.new(0, 160, 0, 80)
    boyBtn.Position = UDim2.new(0, 20, 0, 110)
    boyBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 220)
    boyBtn.Text = "♂ BOY"
    boyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    boyBtn.TextSize = 18
    boyBtn.Font = Enum.Font.GothamBold
    boyBtn.Parent = mainFrame
    Instance.new("UICorner", boyBtn).CornerRadius = UDim.new(0, 12)
    
    boyBtn.MouseButton1Click:Connect(function()
        selectedGender = "Boy"
        showNameScreen()
    end)
    
    local girlBtn = Instance.new("TextButton")
    girlBtn.Size = UDim2.new(0, 160, 0, 80)
    girlBtn.Position = UDim2.new(0, 200, 0, 110)
    girlBtn.BackgroundColor3 = Color3.fromRGB(210, 50, 120)
    girlBtn.Text = "♀ GIRL"
    girlBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    girlBtn.TextSize = 18
    girlBtn.Font = Enum.Font.GothamBold
    girlBtn.Parent = mainFrame
    Instance.new("UICorner", girlBtn).CornerRadius = UDim.new(0, 12)
    
    girlBtn.MouseButton1Click:Connect(function()
        selectedGender = "Girl"
        showNameScreen()
    end)
end

-- 2. NAME SCREEN
function showNameScreen()
    if isSkippingIntro then return end
    clearCurrentUI()
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 380, 0, 260)
    mainFrame.Position = UDim2.new(0.5, -190, 0.5, -130)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.Parent = introGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "ENTER YOUR NAME"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 70)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Your name will be used in the script"
    subtitle.TextColor3 = Color3.fromRGB(170, 170, 170)
    subtitle.TextSize = 13
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = mainFrame
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0, 340, 0, 45)
    textBox.Position = UDim2.new(0, 20, 0, 110)
    textBox.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    textBox.PlaceholderText = "Enter your name..."
    textBox.Text = ""
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 16
    textBox.Font = Enum.Font.Gotham
    textBox.Parent = mainFrame
    Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 10)
    
    local enterBtn = Instance.new("TextButton")
    enterBtn.Size = UDim2.new(0, 340, 0, 45)
    enterBtn.Position = UDim2.new(0, 20, 0, 170)
    enterBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 220)
    enterBtn.Text = "ENTER ➔"
    enterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    enterBtn.TextSize = 16
    enterBtn.Font = Enum.Font.GothamBold
    enterBtn.Parent = mainFrame
    Instance.new("UICorner", enterBtn).CornerRadius = UDim.new(0, 10)
    
    enterBtn.MouseButton1Click:Connect(function()
        if textBox.Text ~= "" then
            enteredName = textBox.Text
            showGangScreen()
        end
    end)
end

-- 3. GANG NAME SCREEN (SIDE BY SIDE 2 BOXES)
function showGangScreen()
    if isSkippingIntro then return end
    clearCurrentUI()
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 420, 0, 260)
    mainFrame.Position = UDim2.new(0.5, -210, 0.5, -130)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.Parent = introGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "ENTER YOUR GANG NAMES"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 70)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Enter Gang 1 and Gang 2 names side by side"
    subtitle.TextColor3 = Color3.fromRGB(170, 170, 170)
    subtitle.TextSize = 13
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = mainFrame
    
    local gangBox1 = Instance.new("TextBox")
    gangBox1.Size = UDim2.new(0, 185, 0, 45)
    gangBox1.Position = UDim2.new(0, 20, 0, 110)
    gangBox1.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    gangBox1.PlaceholderText = "Gang 1 name..."
    gangBox1.Text = ""
    gangBox1.TextColor3 = Color3.fromRGB(255, 255, 255)
    gangBox1.TextSize = 15
    gangBox1.Font = Enum.Font.Gotham
    gangBox1.Parent = mainFrame
    Instance.new("UICorner", gangBox1).CornerRadius = UDim.new(0, 10)
    
    local gangBox2 = Instance.new("TextBox")
    gangBox2.Size = UDim2.new(0, 185, 0, 45)
    gangBox2.Position = UDim2.new(0, 215, 0, 110)
    gangBox2.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    gangBox2.PlaceholderText = "Gang 2 name..."
    gangBox2.Text = ""
    gangBox2.TextColor3 = Color3.fromRGB(255, 255, 255)
    gangBox2.TextSize = 15
    gangBox2.Font = Enum.Font.Gotham
    gangBox2.Parent = mainFrame
    Instance.new("UICorner", gangBox2).CornerRadius = UDim.new(0, 10)
    
    local enterBtn = Instance.new("TextButton")
    enterBtn.Size = UDim2.new(0, 380, 0, 45)
    enterBtn.Position = UDim2.new(0, 20, 0, 170)
    enterBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 220)
    enterBtn.Text = "ENTER ➔"
    enterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    enterBtn.TextSize = 16
    enterBtn.Font = Enum.Font.GothamBold
    enterBtn.Parent = mainFrame
    Instance.new("UICorner", enterBtn).CornerRadius = UDim.new(0, 10)
    
    enterBtn.MouseButton1Click:Connect(function()
        if gangBox1.Text ~= "" then
            enteredGang1 = gangBox1.Text
            enteredGang2 = gangBox2.Text
            showTargetScreen()
        end
    end)
end

-- 4. TARGET YES/NO SCREEN
function showTargetScreen()
    if isSkippingIntro then return end
    clearCurrentUI()
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 380, 0, 260)
    mainFrame.Position = UDim2.new(0.5, -190, 0.5, -130)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.Parent = introGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "DO YOU HAVE A TARGET?"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 70)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "YES opens target box, NO skips it"
    subtitle.TextColor3 = Color3.fromRGB(170, 170, 170)
    subtitle.TextSize = 13
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = mainFrame
    
    local yesBtn = Instance.new("TextButton")
    yesBtn.Size = UDim2.new(0, 160, 0, 80)
    yesBtn.Position = UDim2.new(0, 20, 0, 110)
    yesBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    yesBtn.Text = "YES"
    yesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    yesBtn.TextSize = 18
    yesBtn.Font = Enum.Font.GothamBold
    yesBtn.Parent = mainFrame
    Instance.new("UICorner", yesBtn).CornerRadius = UDim.new(0, 12)
    
    yesBtn.MouseButton1Click:Connect(function()
        showTargetInputScreen()
    end)
    
    local noBtn = Instance.new("TextButton")
    noBtn.Size = UDim2.new(0, 160, 0, 80)
    noBtn.Position = UDim2.new(0, 200, 0, 110)
    noBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    noBtn.Text = "NO"
    noBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    noBtn.TextSize = 18
    noBtn.Font = Enum.Font.GothamBold
    noBtn.Parent = mainFrame
    Instance.new("UICorner", noBtn).CornerRadius = UDim.new(0, 12)
    
    noBtn.MouseButton1Click:Connect(function()
        targetName = "NONE"
        executeAndLoad()
    end)
end

-- 4.1 TARGET INPUT SCREEN
function showTargetInputScreen()
    if isSkippingIntro then return end
    clearCurrentUI()
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 380, 0, 260)
    mainFrame.Position = UDim2.new(0.5, -190, 0.5, -130)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.Parent = introGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "ENTER TARGET NAME"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 70)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Type target name (e.g. TALHA)"
    subtitle.TextColor3 = Color3.fromRGB(170, 170, 170)
    subtitle.TextSize = 13
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = mainFrame
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0, 340, 0, 45)
    textBox.Position = UDim2.new(0, 20, 0, 110)
    textBox.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    textBox.PlaceholderText = "Enter target name..."
    textBox.Text = ""
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 16
    textBox.Font = Enum.Font.Gotham
    textBox.Parent = mainFrame
    Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 10)
    
    local enterBtn = Instance.new("TextButton")
    enterBtn.Size = UDim2.new(0, 340, 0, 45)
    enterBtn.Position = UDim2.new(0, 20, 0, 170)
    enterBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 220)
    enterBtn.Text = "CONFIRM TARGET ➔"
    enterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    enterBtn.TextSize = 16
    enterBtn.Font = Enum.Font.GothamBold
    enterBtn.Parent = mainFrame
    Instance.new("UICorner", enterBtn).CornerRadius = UDim.new(0, 10)
    
    enterBtn.MouseButton1Click:Connect(function()
        if textBox.Text ~= "" then
            targetName = textBox.Text
            executeAndLoad()
        end
    end)
end

-- 5. DIRECT CHAT SPAM & UNIVERSAL GITHUB LOADSTRING
function executeAndLoad()
    if isSkippingIntro then return end
    skipBtn.Visible = false
    if introGui then
        introGui:Destroy()
    end
    
    markLocalPlayerAsLiveUser()
    
    local userUpper = string.upper(enteredName)
    local targetUpper = string.upper(targetName)
    
    task.spawn(function()
        task.wait(0.3)
        if isSkippingIntro then return end
        
        if selectedGender == "Girl" then
            sendChatMessage("🎀@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" .. userUpper .. "HUB LOADED...🎀")
            task.wait(0.8)
            if isSkippingIntro then return end
            sendChatMessage("🌺SCRIPT BY " .. userUpper .. " THE QUEEN OF THE SERVER🌺")
            task.wait(0.8)
            if isSkippingIntro then return end
            
            local gangDisplay = string.upper(enteredGang1)
            if enteredGang2 ~= "" then
                gangDisplay = string.upper(enteredGang1) .. " X " .. string.upper(enteredGang2)
            end
            sendChatMessage(gangDisplay .. " ON TOP 👌😍 BEST GANG EVER " .. gangDisplay .. " ⛩️🥷")
            task.wait(0.8)
            if isSkippingIntro then return end
            
            if targetName ~= "NONE" then
                sendChatMessage("👺" .. userUpper .. " HUB LOAD KARLIA " .. targetUpper .. " AP TUMARI PITI PITI HOGI 👺⛩️ ENJOY THE SHOW ⛩️")
            end
        else
            sendChatMessage("SCRIPT BY " .. userUpper .. " THE KING OF THE SERVER")
            task.wait(0.8)
            if isSkippingIntro then return end
            sendChatMessage("💥@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" .. userUpper .. "HUB LOADED...💥")
            task.wait(0.8)
            if isSkippingIntro then return end
            
            local gangDisplay = string.upper(enteredGang1)
            if enteredGang2 ~= "" then
                gangDisplay = string.upper(enteredGang1) .. " X " .. string.upper(enteredGang2)
            end
            sendChatMessage(gangDisplay .. " ON TOP 👌😍 BEST GANG EVER " .. gangDisplay .. " ⛩️🥷")
            task.wait(0.8)
            if isSkippingIntro then return end
            
            if targetName ~= "NONE" then
                sendChatMessage("👽 " .. targetUpper .. " YOUR PAPA 😍 " .. userUpper .. " NE APNA " .. userUpper .. " HUB LOAD KRLIYA 👽⛩️, ENJOY THE SHOW 👌")
            end
        end
        
        task.wait(0.5)
        loadMainHubScript()
    end)
end

-- Start execution
showFullLoadingScreen()
