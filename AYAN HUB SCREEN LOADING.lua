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
screenGui.Name = "AyanuHubGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Helper function to clear previous UI elements
local function clearCurrentUI()
    for _, child in ipairs(screenGui:GetChildren()) do
        child:Destroy()
    end
end

-- Variables to store inputs
local selectedGender = ""
local enteredName = ""
local enteredGang = ""
local targetName = "NONE"

-- Forward Declarations
local showFullLoadingScreen, showGenderScreen, showNameScreen, showGangScreen, showTargetScreen, showTargetInputScreen, executeAndLoad

-- 0. FULL SCREEN AYANU HUB LOADING SCREEN
function showFullLoadingScreen()
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
    titleLabel.Text = "AYANU HUB"
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
        barFill:TweenSize(UDim2.new(0.4, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.6, true)
        statusLabel.Text = "Bypassing security..."
        task.wait(0.7)
        barFill:TweenSize(UDim2.new(0.8, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.6, true)
        statusLabel.Text = "Loading user interface..."
        task.wait(0.7)
        barFill:TweenSize(UDim2.new(1, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5, true)
        statusLabel.Text = "READY"
        task.wait(0.5)
        showGenderScreen()
    end)
end

-- 1. GENDER SCREEN
function showGenderScreen()
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

-- 3. GANG NAME SCREEN
function showGangScreen()
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
    title.Text = "ENTER YOUR GANG NAME"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 70)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Your gang name will be used in the script"
    subtitle.TextColor3 = Color3.fromRGB(170, 170, 170)
    subtitle.TextSize = 13
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = mainFrame
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0, 340, 0, 45)
    textBox.Position = UDim2.new(0, 20, 0, 110)
    textBox.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    textBox.PlaceholderText = "Enter your gang name..."
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
            enteredGang = textBox.Text
            showTargetScreen()
        end
    end)
end

-- 4. TARGET YES/NO SCREEN
function showTargetScreen()
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
    screenGui:Destroy()
    
    task.spawn(function()
        task.wait(0.3)
        sendChatMessage("SCRIPT BY " .. string.upper(enteredName) .. " THE KING OF THE SERVER")
        task.wait(0.8)
        sendChatMessage("💥@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@AYANHUB LOADED...💥")
        task.wait(0.8)
        sendChatMessage(string.upper(enteredGang) .. " ON TOP 👌😍 BEST GANG EVER " .. string.upper(enteredGang) .. " X AYNU ⛩️🥷")
        task.wait(0.8)
        if targetName ~= "NONE" then
            sendChatMessage("👽 " .. string.upper(targetName) .. " YOUR PAPA 😍 " .. string.upper(enteredName) .. " NE APNA AYAN HUB LOAD KRLIYA 👽⛩️, ENJOY THE SHOW 👌")
        end
        
        -- Load GitHub script using universal http loader
        task.wait(0.5)
        pcall(function()
            local success, scriptContent = pcall(function()
                return universalHttpGet("https://raw.githubusercontent.com/ayanjaveed503-a11y/AYAN-HUB2/refs/heads/main/AYANUU%20HUB%20PROT.lua")
            end)
            if success and scriptContent then
                loadstring(scriptContent)()
            end
        end)
    end)
end

-- Start execution
showFullLoadingScreen()
