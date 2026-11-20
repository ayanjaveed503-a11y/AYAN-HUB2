-- Universal Executor Compatibility Script (Delta, Arceus X, Fluxus, Codex, etc.)
-- Created for Ayan / ZM

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Universal httpGet function supporting all executors
local function universalHttpGet(url)
    if syn and syn.request then
        return syn.request({Url = url, Method = "GET"}).Body
    elseif fluxus and fluxus.request then
        return fluxus.request({Url = url, Method = "GET"}).Body
    elseif request then
        return request({Url = url, Method = "GET"}).Body
    elseif http_request then
        return http_request({Url = url, Method = "GET"}).Body
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

-- Create ScreenGui securely
local playerGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomUserHubGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Helper function to clear previous UI elements (keeps top Skip Intro bar)
local function clearCurrentUI()
    for _, child in ipairs(screenGui:GetChildren()) do
        if child.Name ~= "SkipIntroTopBar" then
            child:Destroy()
        end
    end
end

-- Variables to store inputs
local selectedGender = ""
local enteredName = "USER"
local enteredGang1 = ""
local enteredGang2 = ""
local targetName = "NONE"
local isSkippingIntro = false

-- Forward Declarations
local showFullLoadingScreen, showGenderScreen, showNameScreen, showGangScreen, showTargetScreen, showTargetInputScreen, executeAndLoad, loadMainHubScript

-- Load GitHub script directly
function loadMainHubScript()
    pcall(function()
        local success, scriptContent = pcall(function()
            return universalHttpGet("https://raw.githubusercontent.com/ayanjaveed503-a11y/AYAN-HUB2/refs/heads/main/AYAN%20HUB%20PROTECT.lua")
        end)
        if success and scriptContent then
            loadstring(scriptContent)()
        end
    end)
end

-- Create Top Skip Intro Option (Silent Load)
local function createSkipIntroBar()
    if screenGui:FindFirstChild("SkipIntroTopBar") then return end
    
    local topBar = Instance.new("Frame")
    topBar.Name = "SkipIntroTopBar"
    topBar.Size = UDim2.new(0, 150, 0, 38)
    topBar.Position = UDim2.new(0.5, -75, 0, 14)
    topBar.BackgroundColor3 = Color3.fromRGB(25, 22, 38)
    topBar.ZIndex = 20
    topBar.Parent = screenGui
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(140, 100, 255)
    stroke.Thickness = 1.5
    stroke.Parent = topBar
    
    local skipBtn = Instance.new("TextButton")
    skipBtn.Size = UDim2.new(1, 0, 1, 0)
    skipBtn.BackgroundTransparency = 1
    skipBtn.Text = "SKIP INTRO ➔"
    skipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
   ent = topBar
    
    skipBtn.MouseButton1Click:Connect(function()
        if isSkippingIntro then return end
        isSkippingIntro = true
        screenGui:Destroy()
        loadMainHubScript()
    end)
end

createSkipIntroBar()

-- 0. FULL SCREEN LOADING SCREEN
function showFullLoadingScreen()
    if isSkippingIntro then return end
    clearCurrentUI()
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
    bg.Parent = screenGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 420, 0, 220)
    mainFrame.Position = UDim2.new(0.5, -210, 0.5, -110)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = bg
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "HUB LOADING"
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
    mainFrame.Parent = screenGui
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
    mainFrame.Parent = screenGui
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
    mainFrame.Parent = screenGui
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
    mainFrame.Parent = screenGui
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
    mainFrame.Parent = screenGui
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
    screenGui:Destroy()
    
    local userUpper = string.upper(enteredName)
    local targetUpper = string.upper(targetName)
    
    task.spawn(function()
        task.wait(0.3)
        
        if selectedGender == "Girl" then
            sendChatMessage("🎀@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" .. userUpper .. "HUB LOADED...🎀")
            task.wait(0.8)
            sendChatMessage("🌺SCRIPT BY " .. userUpper .. " THE QUEEN OF THE SERVER🌺")
            task.wait(0.8)
            
            local gangDisplay = string.upper(enteredGang1)
            if enteredGang2 ~= "" then
                gangDisplay = string.upper(enteredGang1) .. " X " .. string.upper(enteredGang2)
            end
            sendChatMessage(gangDisplay .. " ON TOP 👌😍 BEST GANG EVER " .. gangDisplay .. " ⛩️🥷")
            task.wait(0.8)
            
            if targetName ~= "NONE" then
                sendChatMessage("👺" .. userUpper .. " HUB LOAD KARLIA " .. targetUpper .. " AP TUMARI PITI PITI HOGI 👺⛩️ ENJOY THE SHOW ⛩️")
            end
        else
            sendChatMessage("SCRIPT BY " .. userUpper .. " THE KING OF THE SERVER")
            task.wait(0.8)
            sendChatMessage("💥@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" .. userUpper .. "HUB LOADED...💥")
            task.wait(0.8)
            
            local gangDisplay = string.upper(enteredGang1)
            if enteredGang2 ~= "" then
                gangDisplay = string.upper(enteredGang1) .. " X " .. string.upper(enteredGang2)
            end
            sendChatMessage(gangDisplay .. " ON TOP 👌😍 BEST GANG EVER " .. gangDisplay .. " ⛩️🥷")
            task.wait(0.8)
            
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
