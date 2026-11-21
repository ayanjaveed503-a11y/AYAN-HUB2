--// AYANUU HUB - WindUI Interface

local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

local Window = WindUI:CreateWindow({
    Title = "AYANUU HUB",
    Icon = "crown",
    Author = "AYANUU 👑",
    Folder = "AYANUUHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 180,
    ScrollBarEnabled = true,
})

--// SERVICES & GLOBAL VARIABLES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local TargetPlayer = nil
local BangSpeed = 1
local CustomSpeed = 16
local CustomJumpPower = 50
local WalkingFlingConnection = nil
local NoclipConnection = nil
local InfJumpConnection = nil
local TargetVisualConnection = nil
local AllVisualConnection = nil
local AimbotRenderConnection = nil
local MobileFlyActive = false
local MobileFlyGui = nil
local MobileFlyUp = false
local MobileFlyDown = false

local SelectedThemeColor = Color3.fromRGB(220, 40, 60)

local Toggles = {
    Bang = false,
    MouthBang = false,
    Headsit = false,
    FrontHeadsit = false,
    Orbit = false,
    WalkingFling = false,
    Noclip = false,
    InfJump = false,
    AntiBangV2 = false,
    AntiFling = false,
    AntiSit = false,
    AntiAFK = false,
    ESP = false,
    Aimbot = false,
    TracerLine = false,
    ESPAll = false,
    TraceAll = false
}

--// FPS COUNTER
local CurrentFPS = 60
do
    local frameCount = 0
    local lastTick = tick()
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        local elapsed = now - lastTick
        if elapsed >= 0.5 then
            CurrentFPS = math.floor((frameCount / elapsed) + 0.5)
            frameCount = 0
            lastTick = now
        end
    end)
end

--// REJOIN & SERVER HOP FUNCTIONS
local function RejoinCurrentServer()
    pcall(function()
        if #Players:GetPlayers() <= 1 then
            LocalPlayer:Kick("\nRejoining server...")
            task.wait(0.2)
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)
end

local function ServerHop()
    WindUI:Notify({
        Title = "SERVER HOP 🌐",
        Content = "Searching for another server...",
        Duration = 3,
    })

    task.spawn(function()
        local cursor = ""
        local hops = 0
        while hops < 10 do
            hops = hops + 1
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor ~= "" then
                url = url .. "&cursor=" .. cursor
            end

            local ok, res = pcall(function()
                return game:HttpGet(url)
            end)

            if ok and res then
                local decoded
                pcall(function()
                    decoded = HttpService:JSONDecode(res)
                end)

                if decoded and decoded.data then
                    for _, srv in ipairs(decoded.data) do
                        if tostring(srv.id) ~= tostring(game.JobId)
                        and tonumber(srv.playing)
                        and tonumber(srv.maxPlayers)
                        and srv.playing < srv.maxPlayers then
                            pcall(function()
                                TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, LocalPlayer)
                            end)
                            return
                        end
                    end
                    if decoded.nextPageCursor then
                        cursor = tostring(decoded.nextPageCursor)
                    else
                        break
                    end
                else
                    break
                end
            else
                break
            end
            task.wait(0.25)
        end

        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end)
end

--// PLAYER JOIN TIME TRACKER
local PlayerJoinTimes = {}

local function RecordPlayerJoin(plr)
    if plr and not PlayerJoinTimes[plr] then
        PlayerJoinTimes[plr] = tick()
    end
end

for _, plr in ipairs(Players:GetPlayers()) do
    RecordPlayerJoin(plr)
end

Players.PlayerAdded:Connect(RecordPlayerJoin)
Players.PlayerRemoving:Connect(function(plr)
    PlayerJoinTimes[plr] = nil
end)

local function FormatPlaytime(seconds)
    seconds = math.max(0, math.floor(seconds or 0))
    local hrs = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    if hrs > 0 then
        return string.format("%02dh %02dm %02ds", hrs, mins, secs)
    else
        return string.format("%02dm %02ds", mins, secs)
    end
end

local function PlayClickSound()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://6895079853"
        sound.Volume = 0.5
        sound.Parent = game:GetService("SoundService")
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end)
end

local function GetPlayer(name)
    if not name or name == "" then return nil end
    name = name:lower()

    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #name) == name
        or p.DisplayName:lower():sub(1, #name) == name then
            return p
        end
    end

    return nil
end

local function ApplyThemeColor(color)
    SelectedThemeColor = color
    pcall(function()
        if Window and Window.SetTheme then
            Window:SetTheme("Dark")
        end
    end)
    WindUI:Notify({
        Title = "THEME UPDATED 🎨",
        Content = string.format("Color set to RGB(%d, %d, %d)", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)),
        Duration = 2,
    })
end

--// TARGET ESP & TRACER DRAWING OBJECTS
local EspBox = Drawing.new("Square")
EspBox.Visible = false
EspBox.Thickness = 2
EspBox.Filled = false
EspBox.Color = Color3.fromRGB(255, 50, 50)

local EspTag = Drawing.new("Text")
EspTag.Visible = false
EspTag.Size = 15
EspTag.Center = true
EspTag.Outline = true
EspTag.Color = Color3.fromRGB(255, 255, 255)

local TracerDraw = Drawing.new("Line")
TracerDraw.Visible = false
TracerDraw.Thickness = 2
TracerDraw.Color = Color3.fromRGB(255, 60, 60)

local function UpdateTargetVisualLoops()
    if TargetVisualConnection then
        TargetVisualConnection:Disconnect()
        TargetVisualConnection = nil
    end

    if Toggles.ESP or Toggles.TracerLine then
        TargetVisualConnection = RunService.RenderStepped:Connect(function()
            Camera = Workspace.CurrentCamera
            local tp = TargetPlayer
            local tChar = tp and tp.Character
            local tRoot = tChar and (tChar:FindFirstChild("HumanoidRootPart") or tChar:FindFirstChild("Head"))
            local tHead = tChar and tChar:FindFirstChild("Head")

            if not (tp and tp.Parent and tChar and tRoot) then
                EspBox.Visible = false
                EspTag.Visible = false
                TracerDraw.Visible = false
                return
            end

            local rootPos, onScreen = Camera:WorldToViewportPoint(tRoot.Position)
            if not onScreen then
                EspBox.Visible = false
                EspTag.Visible = false
                TracerDraw.Visible = false
                return
            end

            if Toggles.ESP then
                local headPos = tHead and Camera:WorldToViewportPoint(tHead.Position + Vector3.new(0, 0.6, 0)) or Vector3.new(rootPos.X, rootPos.Y - 35, 0)
                local footPos = Camera:WorldToViewportPoint(tRoot.Position - Vector3.new(0, 3, 0))
                local height = math.max(16, math.abs(headPos.Y - footPos.Y))
                local width = height * 0.6

                EspBox.Size = Vector2.new(width, height)
                EspBox.Position = Vector2.new(rootPos.X - width / 2, headPos.Y)
                EspBox.Color = SelectedThemeColor
                EspBox.Visible = true

                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local dist = myRoot and math.floor((myRoot.Position - tRoot.Position).Magnitude) or 0
                EspTag.Text = tp.DisplayName .. " (" .. dist .. "m)"
                EspTag.Position = Vector2.new(rootPos.X, headPos.Y - 18)
                EspTag.Visible = true
            else
                EspBox.Visible = false
                EspTag.Visible = false
            end

            if Toggles.TracerLine then
                TracerDraw.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                TracerDraw.To = Vector2.new(rootPos.X, rootPos.Y)
                TracerDraw.Color = SelectedThemeColor
                TracerDraw.Visible = true
            else
                TracerDraw.Visible = false
            end
        end)
    else
        EspBox.Visible = false
        EspTag.Visible = false
        TracerDraw.Visible = false
    end
end

--// ESPALL & TRACEALL SYSTEM
local AllPlayerDrawings = {}

local function ClearAllPlayerDrawings()
    for player, objs in pairs(AllPlayerDrawings) do
        pcall(function()
            if objs.Box then objs.Box:Remove() end
            if objs.Tag then objs.Tag:Remove() end
            if objs.Tracer then objs.Tracer:Remove() end
        end)
        AllPlayerDrawings[player] = nil
    end
end

local function GetOrCreatePlayerDrawing(player)
    if AllPlayerDrawings[player] then
        return AllPlayerDrawings[player]
    end
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1.8
    box.Filled = false
    box.Color = SelectedThemeColor

    local tag = Drawing.new("Text")
    tag.Visible = false
    tag.Size = 14
    tag.Center = true
    tag.Outline = true
    tag.Color = Color3.fromRGB(255, 255, 255)

    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Thickness = 1.5
    tracer.Color = SelectedThemeColor

    local entry = { Box = box, Tag = tag, Tracer = tracer }
    AllPlayerDrawings[player] = entry
    return entry
end

Players.PlayerRemoving:Connect(function(player)
    if AllPlayerDrawings[player] then
        pcall(function()
            AllPlayerDrawings[player].Box:Remove()
            AllPlayerDrawings[player].Tag:Remove()
            AllPlayerDrawings[player].Tracer:Remove()
        end)
        AllPlayerDrawings[player] = nil
    end
end)

local function UpdateAllVisualLoops()
    if AllVisualConnection then
        AllVisualConnection:Disconnect()
        AllVisualConnection = nil
    end

    if not (Toggles.ESPAll or Toggles.TraceAll) then
        ClearAllPlayerDrawings()
        return
    end

    AllVisualConnection = RunService.RenderStepped:Connect(function()
        Camera = Workspace.CurrentCamera
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local objs = GetOrCreatePlayerDrawing(plr)
                local char = plr.Character
                local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head"))
                local head = char and char:FindFirstChild("Head")

                if not (plr.Parent and char and root) then
                    objs.Box.Visible = false
                    objs.Tag.Visible = false
                    objs.Tracer.Visible = false
                else
                    local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if not onScreen then
                        objs.Box.Visible = false
                        objs.Tag.Visible = false
                        objs.Tracer.Visible = false
                    else
                        if Toggles.ESPAll then
                            local headPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.6, 0)) or Vector3.new(rootPos.X, rootPos.Y - 35, 0)
                            local footPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                            local height = math.max(14, math.abs(headPos.Y - footPos.Y))
                            local width = height * 0.6

                            objs.Box.Size = Vector2.new(width, height)
                            objs.Box.Position = Vector2.new(rootPos.X - width / 2, headPos.Y)
                            objs.Box.Color = SelectedThemeColor
                            objs.Box.Visible = true

                            local dist = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or 0
                            objs.Tag.Text = plr.DisplayName .. " (" .. dist .. "m)"
                            objs.Tag.Position = Vector2.new(rootPos.X, headPos.Y - 16)
                            objs.Tag.Visible = true
                        else
                            objs.Box.Visible = false
                            objs.Tag.Visible = false
                        end

                        if Toggles.TraceAll then
                            objs.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            objs.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                            objs.Tracer.Color = SelectedThemeColor
                            objs.Tracer.Visible = true
                        else
                            objs.Tracer.Visible = false
                        end
                    end
                end
            end
        end
    end)
end

local function SetAimbot(state)
    Toggles.Aimbot = state
    if AimbotRenderConnection then
        AimbotRenderConnection:Disconnect()
        AimbotRenderConnection = nil
    end

    if state then
        AimbotRenderConnection = RunService.RenderStepped:Connect(function()
            if not Toggles.Aimbot then return end
            local tp = TargetPlayer
            local tChar = tp and tp.Character
            local aimPart = tChar and (tChar:FindFirstChild("Head") or tChar:FindFirstChild("HumanoidRootPart"))
            if tp and tp.Parent and aimPart then
                Camera = Workspace.CurrentCamera
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPart.Position)
            end
        end)
    end
end

--// ANTI-FLING & RING SYSTEM (TOGGLE ONLY, NO EXTRA GUI)
local AntiFlingHeartbeatConn = nil
local AntiFlingPlayerConns = {}
local AntiFlingCharConns = {}
local AntiFlingDetectionRadius = 25
local AntiFlingMaxSafeVelocity = 80

local function DisableCharCollisions(character)
    local function disableCollide(part)
        if Toggles.AntiFling and part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    for _, part in ipairs(character:GetChildren()) do
        disableCollide(part)
    end

    local childAddedConn = character.ChildAdded:Connect(disableCollide)
    local steppedConn = RunService.Stepped:Connect(function()
        if Toggles.AntiFling and character:IsDescendantOf(Workspace) then
            for _, part in ipairs(character:GetChildren()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)

    table.insert(AntiFlingCharConns, childAddedConn)
    table.insert(AntiFlingCharConns, steppedConn)
end

local function SecureFlingPart(part, hrpPosition, myChar)
    if not part:IsA("BasePart") or part.Anchored or part:IsDescendantOf(myChar) then
        return
    end

    local distance = (part.Position - hrpPosition).Magnitude
    if distance <= AntiFlingDetectionRadius then
        local vel = part.AssemblyLinearVelocity.Magnitude
        local rotVel = part.AssemblyAngularVelocity.Magnitude

        if vel > AntiFlingMaxSafeVelocity or rotVel > AntiFlingMaxSafeVelocity then
            part.CanCollide = false
            part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            pcall(function()
                part.CFrame = part.CFrame + Vector3.new(0, 500, 0)
            end)
        end
    end
end

local function SetCustomAntiFling(state)
    Toggles.AntiFling = state

    if AntiFlingHeartbeatConn then
        AntiFlingHeartbeatConn:Disconnect()
        AntiFlingHeartbeatConn = nil
    end
    for _, conn in pairs(AntiFlingPlayerConns) do
        pcall(function() conn:Disconnect() end)
    end
    AntiFlingPlayerConns = {}

    for _, conn in pairs(AntiFlingCharConns) do
        pcall(function() conn:Disconnect() end)
    end
    AntiFlingCharConns = {}

    if not state then
        return
    end

    local function trackPlayer(player)
        if player == LocalPlayer then return end
        local conn = player.CharacterAdded:Connect(DisableCharCollisions)
        if player.Character then
            DisableCharCollisions(player.Character)
        end
        AntiFlingPlayerConns[player] = conn
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        trackPlayer(plr)
    end

    table.insert(AntiFlingCharConns, Players.PlayerAdded:Connect(trackPlayer))
    table.insert(AntiFlingCharConns, Players.PlayerRemoving:Connect(function(plr)
        if AntiFlingPlayerConns[plr] then
            AntiFlingPlayerConns[plr]:Disconnect()
            AntiFlingPlayerConns[plr] = nil
        end
    end))

    AntiFlingHeartbeatConn = RunService.Heartbeat:Connect(function()
        if not Toggles.AntiFling then return end
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local hrp = myChar:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local hrpPos = hrp.Position

        for _, item in ipairs(Workspace:GetChildren()) do
            if item:IsA("BasePart") then
                SecureFlingPart(item, hrpPos, myChar)
            elseif item:IsA("Model") and not Players:GetPlayerFromCharacter(item) then
                for _, part in ipairs(item:GetDescendants()) do
                    if part:IsA("BasePart") then
                        SecureFlingPart(part, hrpPos, myChar)
                    end
                end
            end
        end
    end)
end

local function OpenMultiFlingGui()
    local coreGui = (typeof(gethui) == "function" and gethui()) or CoreGui
    if coreGui:FindFirstChild("AYANUUMultiFlingGUI") then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "AYANUU HUB",
            Text = "Multi Fling GUI is already open!",
            Duration = 3
        })
        return
    end

    task.spawn(function()
        local Player = Players.LocalPlayer

        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "MONKMultiFlingGUI"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.Parent = coreGui

        local MainFrame = Instance.new("Frame")
        MainFrame.Size = UDim2.new(0, 320, 0, 370)
        MainFrame.Position = UDim2.new(0.5, -160, 0.5, -185)
        MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        MainFrame.BorderSizePixel = 0
        MainFrame.Active = true
        MainFrame.Draggable = true
        MainFrame.Parent = ScreenGui
        Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

        local MinFrame = Instance.new("Frame")
        MinFrame.Size = UDim2.new(0, 240, 0, 35)
        MinFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        MinFrame.BorderSizePixel = 0
        MinFrame.Active = true
        MinFrame.Visible = false
        MinFrame.Parent = ScreenGui
        Instance.new("UICorner", MinFrame).CornerRadius = UDim.new(0, 8)

        local MinLabel = Instance.new("TextLabel")
        MinLabel.Size = UDim2.new(1, -40, 1, 0)
        MinLabel.Position = UDim2.new(0, 10, 0, 0)
        MinLabel.BackgroundTransparency = 1
        MinLabel.Text = "MONK MULTI FLING GUI"
        MinLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        MinLabel.Font = Enum.Font.GothamBold
        MinLabel.TextSize = 12
        MinLabel.TextXAlignment = Enum.TextXAlignment.Left
        MinLabel.Parent = MinFrame

        local OpenButton = Instance.new("TextButton")
        OpenButton.Size = UDim2.new(0, 25, 0, 25)
        OpenButton.Position = UDim2.new(1, -30, 0, 5)
        OpenButton.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        OpenButton.BorderSizePixel = 0
        OpenButton.Text = "+"
        OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        OpenButton.Font = Enum.Font.GothamBold
        OpenButton.TextSize = 18
        OpenButton.Parent = MinFrame
        Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(0, 6)

        local TitleBar = Instance.new("Frame")
        TitleBar.Size = UDim2.new(1, 0, 0, 35)
        TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        TitleBar.BorderSizePixel = 0
        TitleBar.Parent = MainFrame
        Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -40, 1, 0)
        Title.Position = UDim2.new(0, 10, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = "AYANUU HUB MULTI FLING✨"
        Title.TextColor3 = Color3.fromRGB(255, 50, 50)
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 14
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = TitleBar

        local MinimizeButton = Instance.new("TextButton")
        MinimizeButton.Position = UDim2.new(1, -35, 0, 5)
        MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
        MinimizeButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        MinimizeButton.BorderSizePixel = 0
        MinimizeButton.Text = "-"
        MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        MinimizeButton.Font = Enum.Font.GothamBold
        MinimizeButton.TextSize = 18
        MinimizeButton.Parent = TitleBar
        Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 6)

        local StatusLabel = Instance.new("TextLabel")
        StatusLabel.Position = UDim2.new(0, 10, 0, 45)
        StatusLabel.Size = UDim2.new(1, -20, 0, 20)
        StatusLabel.BackgroundTransparency = 1
        StatusLabel.Text = "Select targets to fling"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        StatusLabel.Font = Enum.Font.GothamSemibold
        StatusLabel.TextSize = 14
        StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
        StatusLabel.Parent = MainFrame

        local SelectionFrame = Instance.new("Frame")
        SelectionFrame.Position = UDim2.new(0, 10, 0, 72)
        SelectionFrame.Size = UDim2.new(1, -20, 0, 218)
        SelectionFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        SelectionFrame.BorderSizePixel = 0
        SelectionFrame.Parent = MainFrame
        Instance.new("UICorner", SelectionFrame).CornerRadius = UDim.new(0, 6)

        local PlayerScrollFrame = Instance.new("ScrollingFrame")
        PlayerScrollFrame.Position = UDim2.new(0, 5, 0, 5)
        PlayerScrollFrame.Size = UDim2.new(1, -10, 1, -10)
        PlayerScrollFrame.BackgroundTransparency = 1
        PlayerScrollFrame.BorderSizePixel = 0
        PlayerScrollFrame.ScrollBarThickness = 4
        PlayerScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 50)
        PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        PlayerScrollFrame.Parent = SelectionFrame

        local StartButton = Instance.new("TextButton")
        StartButton.Position = UDim2.new(0, 10, 0, 300)
        StartButton.Size = UDim2.new(0.5, -15, 0, 30)
        StartButton.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        StartButton.BorderSizePixel = 0
        StartButton.Text = "START FLING"
        StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        StartButton.Font = Enum.Font.GothamBold
        StartButton.TextSize = 13
        StartButton.Parent = MainFrame
        Instance.new("UICorner", StartButton).CornerRadius = UDim.new(0, 6)

        local StopButton = Instance.new("TextButton")
        StopButton.Position = UDim2.new(0.5, 5, 0, 300)
        StopButton.Size = UDim2.new(0.5, -15, 0, 30)
        StopButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        StopButton.BorderSizePixel = 0
        StopButton.Text = "STOP FLING"
        StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        StopButton.Font = Enum.Font.GothamBold
        StopButton.TextSize = 13
        StopButton.Parent = MainFrame
        Instance.new("UICorner", StopButton).CornerRadius = UDim.new(0, 6)

        local SelectAllButton = Instance.new("TextButton")
        SelectAllButton.Position = UDim2.new(0, 10, 0, 335)
        SelectAllButton.Size = UDim2.new(0.5, -15, 0, 25)
        SelectAllButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        SelectAllButton.BorderSizePixel = 0
        SelectAllButton.Text = "SELECT ALL"
        SelectAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        SelectAllButton.Font = Enum.Font.Gotham
        SelectAllButton.TextSize = 12
        SelectAllButton.Parent = MainFrame
        Instance.new("UICorner", SelectAllButton).CornerRadius = UDim.new(0, 6)

        local DeselectAllButton = Instance.new("TextButton")
        DeselectAllButton.Position = UDim2.new(0.5, 5, 0, 335)
        DeselectAllButton.Size = UDim2.new(0.5, -15, 0, 25)
        DeselectAllButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        DeselectAllButton.BorderSizePixel = 0
        DeselectAllButton.Text = "DESELECT ALL"
        DeselectAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        DeselectAllButton.Font = Enum.Font.Gotham
        DeselectAllButton.TextSize = 12
        DeselectAllButton.Parent = MainFrame
        Instance.new("UICorner", DeselectAllButton).CornerRadius = UDim.new(0, 6)

        local SelectedTargets = {}
        local PlayerCheckboxes = {}
        local FlingActive = false

        local function CountSelectedTargets()
            local count = 0
            for _ in pairs(SelectedTargets) do count = count + 1 end
            return count
        end

        local function UpdateStatus()
            local count = CountSelectedTargets()
            StatusLabel.Text = FlingActive and ("Flinging " .. count .. " target(s) 💀") or (count .. " target(s) selected")
        end

        local function RefreshPlayerList()
            for _, child in pairs(PlayerScrollFrame:GetChildren()) do
                child:Destroy()
            end
            PlayerCheckboxes = {}
            local PlayerList = Players:GetPlayers()
            table.sort(PlayerList, function(a, b) return a.Name:lower() < b.Name:lower() end)
            local yPosition = 0
            for _, p in ipairs(PlayerList) do
                if p ~= Player then
                    local PlayerEntry = Instance.new("Frame")
                    PlayerEntry.Size = UDim2.new(1, -5, 0, 30)
                    PlayerEntry.Position = UDim2.new(0, 0, 0, yPosition)
                    PlayerEntry.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    PlayerEntry.BorderSizePixel = 0
                    PlayerEntry.Parent = PlayerScrollFrame
                    Instance.new("UICorner", PlayerEntry).CornerRadius = UDim.new(0, 4)

                    local Checkmark = Instance.new("TextLabel")
                    Checkmark.Size = UDim2.new(0, 24, 1, 0)
                    Checkmark.BackgroundTransparency = 1
                    Checkmark.Text = SelectedTargets[p.Name] and "✓" or ""
                    Checkmark.TextColor3 = Color3.fromRGB(50, 255, 50)
                    Checkmark.TextSize = 14
                    Checkmark.Font = Enum.Font.GothamBold
                    Checkmark.Parent = PlayerEntry

                    local NameLabel = Instance.new("TextLabel")
                    NameLabel.Size = UDim2.new(1, -30, 1, 0)
                    NameLabel.Position = UDim2.new(0, 28, 0, 0)
                    NameLabel.BackgroundTransparency = 1
                    NameLabel.Text = p.DisplayName .. " (@" .. p.Name .. ")"
                    NameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                    NameLabel.TextSize = 13
                    NameLabel.Font = Enum.Font.Gotham
                    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
                    NameLabel.Parent = PlayerEntry

                    local ClickArea = Instance.new("TextButton")
                    ClickArea.Size = UDim2.new(1, 0, 1, 0)
                    ClickArea.BackgroundTransparency = 1
                    ClickArea.Text = ""
                    ClickArea.Parent = PlayerEntry

                    ClickArea.MouseButton1Click:Connect(function()
                        if SelectedTargets[p.Name] then
                            SelectedTargets[p.Name] = nil
                            Checkmark.Text = ""
                        else
                            SelectedTargets[p.Name] = p
                            Checkmark.Text = "✓"
                        end
                        UpdateStatus()
                    end)
                    PlayerCheckboxes[p.Name] = Checkmark
                    yPosition = yPosition + 35
                end
            end
            PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition)
        end

        StartButton.MouseButton1Click:Connect(function()
            if FlingActive or CountSelectedTargets() == 0 then return end
            FlingActive = true
            UpdateStatus()
            task.spawn(function()
                while FlingActive do
                    for _, p in pairs(SelectedTargets) do
                        if not FlingActive then break end
                        if p and p.Parent and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local char = Player.Character
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            local tHrp = p.Character.HumanoidRootPart
                            if hrp and tHrp then
                                local oldPos = hrp.CFrame
                                local bv = Instance.new("BodyVelocity", hrp)
                                bv.Velocity = Vector3.new(9e7, 9e7, 9e7)
                                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                                for _ = 1, 15 do
                                    if not FlingActive then break end
                                    hrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, math.random(-2, 2))
                                    task.wait(0.05)
                                end
                                bv:Destroy()
                                hrp.CFrame = oldPos
                            end
                        end
                    end
                    task.wait(0.2)
                end
            end)
        end)

        StopButton.MouseButton1Click:Connect(function()
            FlingActive = false
            UpdateStatus()
        end)

        SelectAllButton.MouseButton1Click:Connect(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= Player then
                    SelectedTargets[p.Name] = p
                    if PlayerCheckboxes[p.Name] then PlayerCheckboxes[p.Name].Text = "✓" end
                end
            end
            UpdateStatus()
        end)

        DeselectAllButton.MouseButton1Click:Connect(function()
            SelectedTargets = {}
            for _, mark in pairs(PlayerCheckboxes) do
                mark.Text = ""
            end
            UpdateStatus()
        end)

        MinimizeButton.MouseButton1Click:Connect(function()
            MainFrame.Visible = false
            MinFrame.Position = UDim2.new(0, MainFrame.AbsolutePosition.X, 0, MainFrame.AbsolutePosition.Y)
            MinFrame.Visible = true
        end)

        OpenButton.MouseButton1Click:Connect(function()
            MinFrame.Visible = false
            MainFrame.Position = UDim2.new(0, MinFrame.AbsolutePosition.X, 0, MinFrame.AbsolutePosition.Y)
            MainFrame.Visible = true
        end)

        Players.PlayerAdded:Connect(RefreshPlayerList)
        Players.PlayerRemoving:Connect(function(p)
            SelectedTargets[p.Name] = nil
            RefreshPlayerList()
            UpdateStatus()
        end)

        RefreshPlayerList()
        UpdateStatus()
    end)
end

local function ToggleAyanuuAFK(state)
    local TweenService = game:GetService("TweenService")
    local VirtualUser = game:GetService("VirtualUser")

    if CoreGui:FindFirstChild("AYANUU_ANTIAFK_Timer") then
        CoreGui.AYANUU_AFK_Timer:Destroy()
    end

    if not state then
        return
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AYANUU_ANTIAFK_Timer"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 260, 0, 185)
    MainFrame.Position = UDim2.new(0.5, -130, 0.5, -92)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 12)

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Color3.fromRGB(100, 15, 15)
    MainStroke.Thickness = 1.5

    local RainContainer = Instance.new("Frame", MainFrame)
    RainContainer.Size = UDim2.new(1, 0, 1, 0)
    RainContainer.BackgroundTransparency = 1

    local function SpawnRainDrop()
        local drop = Instance.new("Frame")
        local startX = math.random(0, 260)
        local dropLength = math.random(10, 20)
        local dropSpeed = math.random(6, 12) / 10

        drop.Size = UDim2.new(0, 2, 0, dropLength)
        drop.Position = UDim2.new(0, startX, 0, -dropLength)
        drop.BackgroundColor3 = Color3.fromRGB(220, 20, 40)
        drop.BackgroundTransparency = math.random(3, 6) / 10
        drop.BorderSizePixel = 0
        drop.Parent = RainContainer

        local gradient = Instance.new("UIGradient", drop)
        gradient.Rotation = 90
        gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 60)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 0, 0))
        }

        local tween = TweenService:Create(drop, TweenInfo.new(dropSpeed, Enum.EasingStyle.Linear), {
            Position = UDim2.new(0, startX - math.random(8, 15), 1, dropLength)
        })
        tween:Play()
        tween.Completed:Connect(function() drop:Destroy() end)
    end

    task.spawn(function()
        while MainFrame and MainFrame.Parent and Toggles.AntiAFK do
            SpawnRainDrop()
            task.wait(0.05)
        end
    end)

    local Header = Instance.new("Frame", MainFrame)
    Header.BackgroundTransparency = 1
    Header.Position = UDim2.new(0, 0, 0, 10)
    Header.Size = UDim2.new(1, 0, 0, 30)
    Header.ZIndex = 2

    local UserImage = Instance.new("ImageLabel", Header)
    UserImage.BackgroundTransparency = 1
    UserImage.Position = UDim2.new(0, 12, 0, 0)
    UserImage.Size = UDim2.new(0, 26, 0, 26)
    UserImage.ZIndex = 2
    Instance.new("UICorner", UserImage).CornerRadius = UDim.new(1, 0)
    pcall(function()
        UserImage.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)

    local TitleLabel = Instance.new("TextLabel", Header)
    TitleLabel.Size = UDim2.new(1, -45, 1, 0)
    TitleLabel.Position = UDim2.new(0, 45, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "AYANUU AFK"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 40, 40)
    TitleLabel.TextSize = 15
    TitleLabel.Font = Enum.Font.FredokaOne
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 2

    local TimerLabel = Instance.new("TextLabel", MainFrame)
    TimerLabel.Size = UDim2.new(1, 0, 0, 30)
    TimerLabel.Position = UDim2.new(0, 0, 0, 45)
    TimerLabel.BackgroundTransparency = 1
    TimerLabel.Text = "000:00:00"
    TimerLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
    TimerLabel.TextSize = 22
    TimerLabel.Font = Enum.Font.Code
    TimerLabel.ZIndex = 2

    local DayLabel = Instance.new("TextLabel", MainFrame)
    DayLabel.Size = UDim2.new(1, 0, 0, 20)
    DayLabel.Position = UDim2.new(0, 0, 0, 75)
    DayLabel.BackgroundTransparency = 1
    DayLabel.Text = "day : 0"
    DayLabel.TextColor3 = Color3.fromRGB(220, 150, 150)
    DayLabel.TextSize = 14
    DayLabel.Font = Enum.Font.SourceSansBold
    DayLabel.ZIndex = 2

    local SavesLabel = Instance.new("TextLabel", MainFrame)
    SavesLabel.Size = UDim2.new(1, 0, 0, 20)
    SavesLabel.Position = UDim2.new(0, 0, 0, 105)
    SavesLabel.BackgroundTransparency = 1
    SavesLabel.Text = "Kicks Prevented: 0"
    SavesLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    SavesLabel.TextSize = 13
    SavesLabel.Font = Enum.Font.SourceSansBold
    SavesLabel.ZIndex = 2

    local StatusLabel = Instance.new("TextLabel", MainFrame)
    StatusLabel.Size = UDim2.new(1, 0, 0, 20)
    StatusLabel.Position = UDim2.new(0, 0, 0, 135)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Anti-AFK: Active"
    StatusLabel.TextColor3 = Color3.fromRGB(80, 220, 80)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.SourceSansBold
    StatusLabel.ZIndex = 2

    local kicksSaved = 0

    local idleConn = LocalPlayer.Idled:Connect(function()
        if not Toggles.AntiAFK then return end
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        kicksSaved = kicksSaved + 1
        SavesLabel.Text = "Kicks Prevented: " .. kicksSaved
    end)

    local startTime = tick()
    task.spawn(function()
        while Toggles.AntiAFK and ScreenGui.Parent do
            local elapsedTime = tick() - startTime
            local hours = math.floor(elapsedTime / 3600)
            local minutes = math.floor((elapsedTime % 3600) / 60)
            local seconds = math.floor(elapsedTime % 60)
            local days = math.floor(elapsedTime / 86400)

            TimerLabel.Text = string.format("%03d:%02d:%02d", hours, minutes, seconds)
            DayLabel.Text = "day : " .. days

            task.wait(1)
        end
        if idleConn then
            idleConn:Disconnect()
        end
    end)
end

local function SetMobileFly(state)
    MobileFlyActive = state
    MobileFlyUp = false
    MobileFlyDown = false

    local coreGui = (typeof(gethui) == "function" and gethui()) or CoreGui
    if coreGui:FindFirstChild("AYANUU_MobileFly_GUI") then
        coreGui.AYANUU_MobileFly_GUI:Destroy()
    end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if not state then
        if hrp then
            if hrp:FindFirstChild("AyanuuFlyGyro") then hrp.AyanuuFlyGyro:Destroy() end
            if hrp:FindFirstChild("AyanuuFlyVel") then hrp.AyanuuFlyVel:Destroy() end
        end
        if hum then
            hum.PlatformStand = false
        end
        return
    end

    if not hrp or not hum then return end

    MobileFlyGui = Instance.new("ScreenGui")
    MobileFlyGui.Name = "AYANUU_MobileFly_GUI"
    MobileFlyGui.ResetOnSpawn = false
    MobileFlyGui.Parent = coreGui

    local UpBtn = Instance.new("TextButton")
    UpBtn.Size = UDim2.new(0, 64, 0, 44)
    UpBtn.Position = UDim2.new(0.82, 0, 0.55, 0)
    UpBtn.BackgroundColor3 = Color3.fromRGB(35, 160, 75)
    UpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    UpBtn.Font = Enum.Font.GothamBold
    UpBtn.TextSize = 14
    UpBtn.Text = "UP"
    UpBtn.Active = true
    UpBtn.Draggable = true
    UpBtn.Parent = MobileFlyGui
    Instance.new("UICorner", UpBtn).CornerRadius = UDim.new(0, 8)

    local DownBtn = Instance.new("TextButton")
    DownBtn.Size = UDim2.new(0, 64, 0, 44)
    DownBtn.Position = UDim2.new(0.82, 0, 0.65, 0)
    DownBtn.BackgroundColor3 = Color3.fromRGB(185, 45, 45)
    DownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DownBtn.Font = Enum.Font.GothamBold
    DownBtn.TextSize = 14
    DownBtn.Text = "DOWN"
    DownBtn.Active = true
    DownBtn.Draggable = true
    DownBtn.Parent = MobileFlyGui
    Instance.new("UICorner", DownBtn).CornerRadius = UDim.new(0, 8)

    UpBtn.MouseButton1Down:Connect(function() MobileFlyUp = true end)
    UpBtn.MouseButton1Up:Connect(function() MobileFlyUp = false end)
    DownBtn.MouseButton1Down:Connect(function() MobileFlyDown = true end)
    DownBtn.MouseButton1Up:Connect(function() MobileFlyDown = false end)

    local bg = Instance.new("BodyGyro")
    bg.Name = "AyanuuFlyGyro"
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = hrp.CFrame
    bg.Parent = hrp

    local bv = Instance.new("BodyVelocity")
    bv.Name = "AyanuuFlyVel"
    bv.velocity = Vector3.new(0, 0, 0)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp

    task.spawn(function()
        while MobileFlyActive do
            pcall(function()
                local c = LocalPlayer.Character
                local root = c and c:FindFirstChild("HumanoidRootPart")
                local h = c and c:FindFirstChildOfClass("Humanoid")
                if not root or not h then return end

                h.PlatformStand = true
                local camCF = Workspace.CurrentCamera.CFrame
                local moveDir = h.MoveDirection
                local flySpeed = math.max(CustomSpeed, 35)
                local vel = Vector3.zero

                if moveDir.Magnitude > 0 then
                    local forward = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
                    local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
                    vel = vel + (forward * moveDir.Z + right * moveDir.X) * flySpeed
                end

                if MobileFlyUp then
                    vel = vel + Vector3.new(0, flySpeed * 0.85, 0)
                elseif MobileFlyDown then
                    vel = vel - Vector3.new(0, flySpeed * 0.85, 0)
                end

                bv.velocity = vel
                bg.cframe = camCF
            end)
            task.wait()
        end

        pcall(function()
            local c = LocalPlayer.Character
            local root = c and c:FindFirstChild("HumanoidRootPart")
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if root then
                if root:FindFirstChild("AyanuuFlyGyro") then root.AyanuuFlyGyro:Destroy() end
                if root:FindFirstChild("AyanuuFlyVel") then root.AyanuuFlyVel:Destroy() end
            end
            if h then
                h.PlatformStand = false
            end
        end)
    end)
end

--// 1. HOME TAB
local HomeTab = Window:Tab({
    Title = "HOME",
    Icon = "home",
})

HomeTab:Paragraph({
    Title = "AYANUU 👑 HUB",
    Desc = "MADE BY AYANUU 👑 | ID: ZM_AYANUUSCRIPTS",
})

HomeTab:Paragraph({
    Title = "STATUS",
    Desc = "AYANUU HUB LOADED & READY",
})

--// 2. TARGET TAB
local TargetTab = Window:Tab({
    Title = "TARGET",
    Icon = "crosshair",
})

local SelectedTargetParagraph = TargetTab:Paragraph({
    Title = "SELECTED TARGET",
    Desc = "None (Type name or pick from Bandon Ki List)",
})

local function SetTargetPlayer(p)
    TargetPlayer = p
    if p then
        SelectedTargetParagraph:SetDesc("Target: " .. p.DisplayName .. " (@" .. p.Name .. ")")
    else
        SelectedTargetParagraph:SetDesc("None (Type name or pick from Bandon Ki List)")
    end
end

TargetTab:Input({
    Title = "TARGET NAME",
    Desc = "Enter player name or display name",
    Placeholder = "Username...",
    Callback = function(value)
        local found = GetPlayer(value)
        SetTargetPlayer(found)
    end,
})

TargetTab:Input({
    Title = "SPEED",
    Desc = "Default: 1",
    Placeholder = "1",
    Callback = function(value)
        BangSpeed = tonumber(value) or 1
    end,
})

TargetTab:Button({
    Title = "GOTO TARGET",
    Desc = "Teleport to target",
    Callback = function()
        PlayClickSound()
        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = TargetPlayer.Character.HumanoidRootPart.CFrame
        end
    end,
})

TargetTab:Toggle({
    Title = "VIEW TARGET",
    Desc = "Spectate target player",
    Value = false,
    Callback = function(value)
        PlayClickSound()
        if value and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Humanoid") then
            Workspace.CurrentCamera.CameraSubject = TargetPlayer.Character.Humanoid
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
            end
        end
    end,
})

TargetTab:Toggle({
    Title = "ESP",
    Desc = "Box & distance ESP on selected target",
    Value = false,
    Callback = function(value)
        PlayClickSound()
        Toggles.ESP = value
        UpdateTargetVisualLoops()
    end,
})

TargetTab:Toggle({
    Title = "AIMBOT",
    Desc = "Lock camera aim onto selected target",
    Value = false,
    Callback = function(value)
        PlayClickSound()
        SetAimbot(value)
    end,
})

TargetTab:Toggle({
    Title = "TRACER LINE",
    Desc = "Draw tracer line to selected target",
    Value = false,
    Callback = function(value)
        PlayClickSound()
        Toggles.TracerLine = value
        UpdateTargetVisualLoops()
    end,
})

TargetTab:Toggle({
    Title = "ORBIT",
    Desc = "Orbit around target",
    Value = false,
    Callback = function(value)
        PlayClickSound()
        Toggles.Orbit = value
        task.spawn(function()
            local angle = 0
            while Toggles.Orbit and task.wait() do
                pcall(function()
                    angle = angle + (0.2 * BangSpeed)
                    LocalPlayer.Character.HumanoidRootPart.CFrame =
                        TargetPlayer.Character.HumanoidRootPart.CFrame *
                        CFrame.Angles(0, angle, 0) *
                        CFrame.new(0, 0, 5)
                end)
            end
        end)
    end,
})

TargetTab:Toggle({
    Title = "BANG",
    Desc = "Bang target",
    Value = false,
    Callback = function(value)
        PlayClickSound()
        Toggles.Bang = value
        task.spawn(function()
            while Toggles.Bang and task.wait() do
                pcall(function()
                    LocalPlayer.Character.HumanoidRootPart.CFrame =
                        TargetPlayer.Character.HumanoidRootPart.CFrame *
                        CFrame.new(0, 0, 1.1 + math.sin(tick() * (BangSpeed * 20)) * 0.8)
                end)
            end
        end)
    end,
})

TargetTab:Toggle({
    Title = "MOUTH BANG",
    Desc = "Mouth bang target",
    Value = false,
    Callback = function(value)
        PlayClickSound()
        Toggles.MouthBang = value
        task.spawn(function()
            while Toggles.MouthBang and task.wait() do
                pcall(function()
                    LocalPlayer.Character.HumanoidRootPart.CFrame =
                        TargetPlayer.Character.Head.CFrame *
                        CFrame.new(0, 0.2, -1.2 - math.sin(tick() * (BangSpeed * 20)) * 0.8) *
                        CFrame.Angles(0, math.pi, 0)
                end)
            end
        end)
    end,
})

TargetTab:Toggle({
    Title = "HEADSIT",
    Desc = "Sit on target head",
    Value = false,
    Callback = function(value)
        PlayClickSound()
        Toggles.Headsit = value
        task.spawn(function()
            while Toggles.Headsit and task.wait() do
                pcall(function()
                    LocalPlayer.Character.HumanoidRootPart.CFrame =
                        TargetPlayer.Character.Head.CFrame *
                        CFrame.new(0, 0.5 + math.sin(tick() * (BangSpeed * 20)) * 0.5, 0)
                end)
            end
        end)
    end,
})

TargetTab:Toggle({
    Title = "FRONTHEADSIT",
    Desc = "Front headsit on target",
    Value = false,
    Callback = function(value)
        PlayClickSound()
        Toggles.FrontHeadsit = value
        task.spawn(function()
            while Toggles.FrontHeadsit and task.wait() do
                pcall(function()
                    LocalPlayer.Character.HumanoidRootPart.CFrame =
                        TargetPlayer.Character.Head.CFrame *
                        CFrame.new(0, 0.4, -0.2 - math.sin(tick() * (BangSpeed * 25)) * 0.5) *
                        CFrame.Angles(0, math.pi, 0)
                end)
            end
        end)
    end,
})

--// BANDON KI LIST (SERVER PLAYER LIST)
TargetTab:Paragraph({
    Title = "BANDON KI LIST",
    Desc = "Click any player below to set them as target:",
})

local PlayerListButtons = {}

local function RebuildBandonKiList()
    for _, btn in pairs(PlayerListButtons) do
        pcall(function()
            btn:Destroy()
        end)
    end
    PlayerListButtons = {}

    local list = Players:GetPlayers()
    table.sort(list, function(a, b) return a.Name:lower() < b.Name:lower() end)

    for _, p in ipairs(list) do
        if p ~= LocalPlayer then
            local b = TargetTab:Button({
                Title = p.DisplayName .. " (@" .. p.Name .. ")",
                Desc = "Select as target",
                Callback = function()
                    PlayClickSound()
                    SetTargetPlayer(p)
                    WindUI:Notify({
                        Title = "TARGET SELECTED",
                        Content = "Target set to @" .. p.Name,
                        Duration = 2,
                    })
                end,
            })
            table.insert(PlayerListButtons, b)
        end
    end
end
RebuildBandonKiList()

Players.PlayerAdded:Connect(function()
    task.wait(0.2)
    RebuildBandonKiList()
end)

Players.PlayerRemoving:Connect(function(p)
    if TargetPlayer == p then
        SetTargetPlayer(nil)
    end
    RebuildBandonKiList()
end)

--// 3. PLAYER TAB
local PlayerTab = Window:Tab({
    Title = "PLAYER",
    Icon = "user",
})

PlayerTab:Input({
    Title = "SPEED",
    Desc = "Set custom WalkSpeed (Default: 16)",
    Placeholder = "16",
    Callback = function(value)
        local num = tonumber(value)
        if num then
            CustomSpeed = num
            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = CustomSpeed
                end
            end)
        end
    end,
})

PlayerTab:Input({
    Title = "JUMP POWER",
    Desc = "Set custom JumpPower (Default: 50)",
    Placeholder = "50",
    Callback = function(value)
        local num = tonumber(value)
        if num then
            CustomJumpPower = num
            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.UseJumpPower = true
                    hum.JumpPower = CustomJumpPower
                end
            end)
        end
    end,
})

PlayerTab:Toggle({
    Title = "INFINITE JUMP ON/OFF",
    Desc = "Toggle infinite jump",
    Value = false,
    Callback = function(value)
        PlayClickSound()
        Toggles.InfJump = value
        if InfJumpConnection then
            InfJumpConnection:Disconnect()
            InfJumpConnection = nil
        end
        if value then
            InfJumpConnection = UserInputService.JumpRequest:Connect(function()
                if Toggles.InfJump and LocalPlayer.Character then
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        end
    end,
})

PlayerTab:Toggle({
    Title = "NOCLIP ON/OFF",
    Desc = "Walk through walls",
    Value = false,
    Callback = function(value)
        PlayClickSound()
        Toggles.Noclip = value
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
        if value then
            NoclipConnection = RunService.Stepped:Connect(function()
                if Toggles.Noclip and LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    end,
})

PlayerTab:Toggle({
    Title = "FLY MOBILE ON/OFF",
    Desc = "Mobile fly controls with UP / DOWN buttons",
    Value = false,
    Callback = function(value)
        PlayClickSound()
        SetMobileFly(value)
    end,
})

PlayerTab:Toggle({
    Title = "ESPALL ON/OFF",
    Desc = "Box & distance ESP for all players",
    Value = false,
    Callback = function(value)
        PlayClickSound()
        Toggles.ESPAll = value
        UpdateAllVisualLoops()
    end,
})

PlayerTab:Toggle({
    Title = "TRACEALL ON/OFF",
    Desc = "Tracer lines to all players",
    Value = false,
    Callback = function(value)
        PlayClickSound()
        Toggles.TraceAll = value
        UpdateAllVisualLoops()
    end,
})

--// 4. SHIELD TAB
local ShieldTab = Window:Tab({
    Title = "SHIELD",
    Icon = "shield",
})

ShieldTab:Button({
    Title = "OP MULTI FLING GUI 💀",
    Desc = "Click to activate the Ultimate Multi Fling Panel!",
    Callback = function()
        PlayClickSound()
        OpenMultiFlingGui()
    end,
})

ShieldTab:Toggle({
    Title = "Anti sit on off",
    Desc = "Toggle sit state",
    Value = false,
    Callback = function(v)
        PlayClickSound()
        Toggles.AntiSit = v
        spawn(function()
            while Toggles.AntiSit and task.wait() do
                pcall(function()
                    game.Players.LocalPlayer.Character.Humanoid.Sit = true
                end)
            end
        end)
    end,
})

ShieldTab:Toggle({
    Title = "ANTIFLING",
    Desc = "Toggle Anti-Fling & Ring protection ON/OFF",
    Value = false,
    Callback = function(value)
        PlayClickSound()
        SetCustomAntiFling(value)
    end,
})

ShieldTab:Toggle({
    Title = "WALKFLING",
    Desc = "Fling players when walking into them",
    Value = false,
    Callback = function(value)
        PlayClickSound()
        Toggles.WalkingFling = value
        if value then
            WalkingFlingConnection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if not Toggles.WalkingFling then return end
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            for _, part in pairs(player.Character:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end

                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local oldV = hrp.Velocity
                        hrp.Velocity = Vector3.new(100000, 100000, 100000)
                        RunService.RenderStepped:Wait()
                        hrp.Velocity = oldV
                    end
                end)
            end)
        else
            if WalkingFlingConnection then
                WalkingFlingConnection:Disconnect()
                WalkingFlingConnection = nil
            end
        end
    end,
})

ShieldTab:Toggle({
    Title = "ANTIAFK ON/OFF",
    Desc = "Toggle AYANUU AFK GUI & Anti-AFK protection",
    Value = false,
    Callback = function(value)
        PlayClickSound()
        Toggles.AntiAFK = value
        ToggleAyanuuAFK(value)
    end,
})

--// 5. ANTIBANG TAB (5 INDIVIDUAL LOADSTRINGS)
local AntiBangTab = Window:Tab({
    Title = "ANTIBANG",
    Icon = "shield-alert",
})

AntiBangTab:Toggle({
    Title = "ANTIBANG V2",
    Desc = "Teleport Anti-Bang V2 toggle",
    Value = false,
    Callback = function(value)
        PlayClickSound()
        Toggles.AntiBangV2 = value
        task.spawn(function()
            while Toggles.AntiBangV2 do
                pcall(function()
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    local groundCFrame = hrp.CFrame

                    hrp.CFrame = groundCFrame * CFrame.new(0, 1000, 0)
                    task.wait(0.1)
                    if not Toggles.AntiBangV2 then return end

                    hrp.CFrame = groundCFrame
                    task.wait(0.1)
                    if not Toggles.AntiBangV2 then return end

                    hrp.CFrame = groundCFrame * CFrame.new(0, -1000, 0)
                    task.wait(0.1)
                    if not Toggles.AntiBangV2 then return end

                    hrp.CFrame = groundCFrame
                    task.wait(0.1)
                end)
            end
        end)
    end,
})

AntiBangTab:Button({
    Title = "BEST ANTIBANG",
    Desc = "Execute AntiBang script 1",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://pastebin.com/raw/80Nva2Fj"))()
    end,
})

AntiBangTab:Button({
    Title = "ONECLICK ANTIBANG",
    Desc = "Execute AntiBang script 2",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Anti-Bang-48256"))()
    end,
})

AntiBangTab:Button({
    Title = "ANTIBANG LOADSTRING 3",
    Desc = "Execute AntiBang script 3",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/antibang3/main/script.lua"))()
    end,
})

AntiBangTab:Button({
    Title = "ANTIBANG LOADSTRING 4",
    Desc = "Execute AntiBang script 4",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/antibang4/main/script.lua"))()
    end,
})

AntiBangTab:Button({
    Title = "ANTIBANG LOADSTRING 5",
    Desc = "Execute AntiBang script 5",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/antibang5/main/script.lua"))()
    end,
})

--// 6. BANG TAB (6 INDIVIDUAL LOADSTRINGS)
local BangTab = Window:Tab({
    Title = "BANG",
    Icon = "flame",
})

BangTab:Button({
    Title = "BANG LOADSTRING 1",
    Desc = "Execute Bang script 1",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/bang1/main/script.lua"))()
    end,
})

BangTab:Button({
    Title = "BANG LOADSTRING 2",
    Desc = "Execute Bang script 2",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/bang2/main/script.lua"))()
    end,
})

BangTab:Button({
    Title = "BANG LOADSTRING 3",
    Desc = "Execute Bang script 3",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/bang3/main/script.lua"))()
    end,
})

BangTab:Button({
    Title = "BANG LOADSTRING 4",
    Desc = "Execute Bang script 4",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/bang4/main/script.lua"))()
    end,
})

BangTab:Button({
    Title = "BANG LOADSTRING 5",
    Desc = "Execute Bang script 5",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/bang5/main/script.lua"))()
    end,
})

BangTab:Button({
    Title = "BANG LOADSTRING 6",
    Desc = "Execute Bang script 6",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/bang6/main/script.lua"))()
    end,
})

--// 7. EMOTE TAB (5 INDIVIDUAL LOADSTRINGS)
local EmoteTab = Window:Tab({
    Title = "EMOTE",
    Icon = "sparkles",
})

EmoteTab:Button({
    Title = "GAZE EMOTE",
    Desc = "Execute Emote script 1",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Gazer-Ha/Gaze-stuff/refs/heads/main/Gaze%20emote"))()
    end,
})

EmoteTab:Button({
    Title = "EMOTE LOADSTRING 2",
    Desc = "Execute Emote script 2",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/emote2/main/script.lua"))()
    end,
})

EmoteTab:Button({
    Title = "EMOTE LOADSTRING 3",
    Desc = "Execute Emote script 3",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/emote3/main/script.lua"))()
    end,
})

EmoteTab:Button({
    Title = "EMOTE LOADSTRING 4",
    Desc = "Execute Emote script 4",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/emote4/main/script.lua"))()
    end,
})

EmoteTab:Button({
    Title = "EMOTE LOADSTRING 5",
    Desc = "Execute Emote script 5",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/emote5/main/script.lua"))()
    end,
})

--// 8. ALL SPAMMER TAB (15 INDIVIDUAL LOADSTRINGS)
local AllSpammerTab = Window:Tab({
    Title = "ALL SPAMMER",
    Icon = "message-square",
})

AllSpammerTab:Button({
    Title = "AYANUU SPAMMER",
    Desc = "Execute Spammer script 1",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ayanjaveed503-a11y/EVERYONE-SCRIPT/refs/heads/main/AYAN%20SPAMMER"))()
    end,
})

AllSpammerTab:Button({
    Title = "BUNNY SPAMMER",
    Desc = "Execute Spammer script 2",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ayanjaveed503-a11y/AYAN-SPAM/refs/heads/main/"))()
    end,
})

AllSpammerTab:Button({
    Title = "TALHA SPAMMER",
    Desc = "Execute Spammer script 3",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ayanjaveed503-a11y/AYAN-SPAM/refs/heads/main/TALHA%20SPAMMER.lua"))()
    end,
})

AllSpammerTab:Button({
    Title = "MEHDI SPAMMER",
    Desc = "Execute Spammer script 4",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ayanjaveed503-a11y/EVERYONE-SCRIPT/refs/heads/main/MEHDI%20SPAM.txt"))()
    end,
})

AllSpammerTab:Button({
    Title = "ARHAN SPAMMER",
    Desc = "Execute Spammer script 5",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ayanjaveed503-a11y/EVERYONE-SCRIPT/refs/heads/main/ARHAN%20SPAM.txt"))()
    end,
})

AllSpammerTab:Button({
    Title = "SAMRAT SPAMMER",
    Desc = "Execute Spammer script 6",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ayanjaveed503-a11y/EVERYONE-SCRIPT/refs/heads/main/SAMRAT%20SPAM.txt"))()
    end,
})

AllSpammerTab:Button({
    Title = "TRIO SPAMMER",
    Desc = "Execute Spammer script 7",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ayanjaveed503-a11y/EVERYONE-SCRIPT/refs/heads/main/TRIO%20SPAM%20.txt"))()
    end,
})

AllSpammerTab:Button({
    Title = "MIKEY SPAMMER",
    Desc = "Execute Spammer script 8",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MuddyyXScripts/MIKEY-SPAMMER-V1/refs/heads/main/ObfuscatedByMonKFuscate.luau%20(5).txt"))()
    end,
})

AllSpammerTab:Button({
    Title = "BUNNY SPAMMER 2",
    Desc = "Execute Spammer script 9",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ayanjaveed503-a11y/AYAN-SPAM/refs/heads/main/BUNNY%20SPAM.txt"))()
    end,
})

AllSpammerTab:Button({
    Title = "SPAMMER LOADSTRING 10",
    Desc = "Execute Spammer script 10",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/spammer10/main/script.lua"))()
    end,
})

AllSpammerTab:Button({
    Title = "SPAMMER LOADSTRING 11",
    Desc = "Execute Spammer script 11",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/spammer11/main/script.lua"))()
    end,
})

AllSpammerTab:Button({
    Title = "SPAMMER LOADSTRING 12",
    Desc = "Execute Spammer script 12",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/spammer12/main/script.lua"))()
    end,
})

AllSpammerTab:Button({
    Title = "SPAMMER LOADSTRING 13",
    Desc = "Execute Spammer script 13",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/spammer13/main/script.lua"))()
    end,
})

AllSpammerTab:Button({
    Title = "SPAMMER LOADSTRING 14",
    Desc = "Execute Spammer script 14",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/spammer14/main/script.lua"))()
    end,
})

AllSpammerTab:Button({
    Title = "SPAMMER LOADSTRING 15",
    Desc = "Execute Spammer script 15",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/spammer15/main/script.lua"))()
    end,
})

--// 9. SCRIPT TAB (10 INDIVIDUAL LOADSTRINGS)
local ScriptTab = Window:Tab({
    Title = "SCRIPT",
    Icon = "code",
})

ScriptTab:Button({
    Title = "ZAYN CHAT",
    Desc = "Execute Script 1",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ZaynBoss01/ZAYN/refs/heads/main/Zayn-Roblox"))()
    end,
})

ScriptTab:Button({
    Title = "GLOBAL CHAT",
    Desc = "Execute Script 2",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://gist.githubusercontent.com/josh19mark-sys/276fd3c0ad985fe2476f6ce333b4354f/raw/a29997b49f6279e3c0a2564737bb020e7a885cb6/gistfile1.txt"))()
    end,
})

ScriptTab:Button({
    Title = "SONG PLAYER",
    Desc = "Execute Script 3",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://api.aurorax.site/files/v5/loaders/fdc766682032eea1cd25a1b7a976d621"))()
    end,
})

ScriptTab:Button({
    Title = "SCRIPT LOADSTRING 4",
    Desc = "Execute Script 4",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/script4/main/script.lua"))()
    end,
})

ScriptTab:Button({
    Title = "SCRIPT LOADSTRING 5",
    Desc = "Execute Script 5",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/script5/main/script.lua"))()
    end,
})

ScriptTab:Button({
    Title = "SCRIPT LOADSTRING 6",
    Desc = "Execute Script 6",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/script6/main/script.lua"))()
    end,
})

ScriptTab:Button({
    Title = "SCRIPT LOADSTRING 7",
    Desc = "Execute Script 7",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/script7/main/script.lua"))()
    end,
})

ScriptTab:Button({
    Title = "SCRIPT LOADSTRING 8",
    Desc = "Execute Script 8",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/script8/main/script.lua"))()
    end,
})

ScriptTab:Button({
    Title = "SCRIPT LOADSTRING 9",
    Desc = "Execute Script 9",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/script9/main/script.lua"))()
    end,
})

ScriptTab:Button({
    Title = "SCRIPT LOADSTRING 10",
    Desc = "Execute Script 10",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/script10/main/script.lua"))()
    end,
})

--// 10. LIFE TOGETHER TAB (PASSWORD 9900)
local LifeTogetherTab = Window:Tab({
    Title = "LIFE TOGETHER 🔒",
    Icon = "lock",
})

local TabPassword = "9900"
local EnteredPassword = ""
local IsUnlocked = false

local LockInfo = LifeTogetherTab:Paragraph({
    Title = "🔒 LIFE TOGETHER LOCKED",
    Desc = "Enter password (9900) below to unlock Life Together scripts.",
})

local PassInput = LifeTogetherTab:Input({
    Title = "ENTER PASSWORD",
    Desc = "Type 9900 to unlock",
    Placeholder = "Password...",
    Callback = function(value)
        EnteredPassword = value
    end,
})

local UnlockBtn
UnlockBtn = LifeTogetherTab:Button({
    Title = "UNLOCK TAB 🔓",
    Desc = "Verify password",
    Callback = function()
        PlayClickSound()
        if IsUnlocked then return end

        if EnteredPassword == TabPassword then
            IsUnlocked = true
            WindUI:Notify({
                Title = "AYANUU HUB 👑",
                Content = "Life Together Unlocked!",
                Duration = 3,
            })

            pcall(function()
                LockInfo:Destroy()
                PassInput:Destroy()
                UnlockBtn:Destroy()
            end)

            LifeTogetherTab:Button({
                Title = "AYANUU PREMIUM OUTFIT COPIER 🤩",
                Desc = "Click to open the outfit copier GUI",
                Callback = function()
                    PlayClickSound()
                    loadstring(game:HttpGet(("https://raw.githubusercontent.com/ayanjaveed503-a11y/AYAN-OUTFIT-STEALER/refs/heads/main/AYAN%20OUTFIT%20STEALER"), true))()
                end,
            })

            LifeTogetherTab:Button({
                Title = "AYANUU 👹 ULTIMATE TRAPPING 🌪️",
                Desc = "Click to open the Ultimate Pyramid Trap GUI",
                Callback = function()
                    PlayClickSound()
                    loadstring(game:HttpGet(("https://raw.githubusercontent.com/ayanjaveed503-a11y/AYAN-HUB-TRAP-CHAIR/refs/heads/main/AYAN%20HUB%20TRAP%20CHAIR"), true))()
                end,
            })
        else
            WindUI:Notify({
                Title = "WRONG PASSWORD ❌",
                Content = "Incorrect password! Try again.",
                Duration = 3,
            })
        end
    end,
})

--// 11. THEME TAB (CHANGE COLOR)
local ThemeTab = Window:Tab({
    Title = "THEME",
    Icon = "palette",
})

local ThemePresets = {
    { Name = "CRIMSON RED ❤️", Color = Color3.fromRGB(220, 40, 60) },
    { Name = "OCEAN BLUE 💙", Color = Color3.fromRGB(40, 130, 240) },
    { Name = "EMERALD GREEN 💚", Color = Color3.fromRGB(40, 200, 110) },
    { Name = "ROYAL PURPLE 💜", Color = Color3.fromRGB(155, 70, 245) },
    { Name = "GOLD CROWN 👑", Color = Color3.fromRGB(245, 185, 35) },
}

for _, preset in ipairs(ThemePresets) do
    ThemeTab:Button({
        Title = preset.Name,
        Desc = "Change hub & ESP/tracer accent color",
        Callback = function()
            PlayClickSound()
            ApplyThemeColor(preset.Color)
        end,
    })
end

ThemeTab:Input({
    Title = "CUSTOM RGB COLOR",
    Desc = "Enter R,G,B (example: 255,0,120)",
    Placeholder = "255, 0, 120",
    Callback = function(value)
        local r, g, b = value:match("^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*$")
        if r and g and b then
            ApplyThemeColor(Color3.fromRGB(
                math.clamp(tonumber(r) or 0, 0, 255),
                math.clamp(tonumber(g) or 0, 0, 255),
                math.clamp(tonumber(b) or 0, 0, 255)
            ))
        end
    end,
})

--// 12. FEEDBACK TAB (1 LOADSTRING)
local FeedbackTab = Window:Tab({
    Title = "FEEDBACK",
    Icon = "message-circle",
})

FeedbackTab:Button({
    Title = "FEEDBACK soon",
    Desc = "Open feedback script",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/feedback/main/script.lua"))()
    end,
})

--// 13. GAME SCRIPT TAB
local GameScriptTab = Window:Tab({
    Title = "GAME SCRIPT",
    Icon = "gamepad-2",
})

GameScriptTab:Button({
    Title = "RIVALS SCRIPT",
    Desc = "Load Rivals script",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/rivals-script/main/script.lua"))()
    end,
})

GameScriptTab:Button({
    Title = "LIFE TOGETHER SCRIPT",
    Desc = "Load Life Together script",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/life-together-script/main/script.lua"))()
    end,
})

GameScriptTab:Button({
    Title = "FREE FIRE / UNIVERSAL SCRIPT",
    Desc = "Load game script",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/game-script-3/main/script.lua"))()
    end,
})

GameScriptTab:Button({
    Title = "EXTRA GAME SCRIPT 4",
    Desc = "Load extra game script",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/game-script-4/main/script.lua"))()
    end,
})

--// 14. FPS TAB (LIVE FPS + 3 INDIVIDUAL LOADSTRINGS)
local FpsTab = Window:Tab({
    Title = "FPS",
    Icon = "zap",
})

local FpsDisplayParagraph = FpsTab:Paragraph({
    Title = "YOUR FPS",
    Desc = "FPS: " .. tostring(CurrentFPS),
})

local function UpdateFpsDisplay()
    pcall(function()
        FpsDisplayParagraph:SetDesc("Current FPS: " .. tostring(CurrentFPS))
    end)
end

FpsTab:Button({
    Title = "REFRESH FPS",
    Desc = "Update current FPS reading",
    Callback = function()
        PlayClickSound()
        UpdateFpsDisplay()
    end,
})

FpsTab:Button({
    Title = "ULTRA ANTILAG+ANTIFIRE",
    Desc = "Execute FPS boost script 1",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Extra-Antilag-(Open-source)-229552"))()
    end,
})

FpsTab:Button({
    Title = "ANTILAG",
    Desc = "Execute FPS boost script 2",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Antilag-by-DaMieN-172219"))()
    end,
})

FpsTab:Button({
    Title = "FPS BOOSTER",
    Desc = "Execute FPS boost script 3",
    Callback = function()
        PlayClickSound()
        loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Optiz-FpsBooster-60070"))()
    end,
})

task.spawn(function()
    while Window do
        UpdateFpsDisplay()
        task.wait(0.5)
    end
end)

--// 15. PLAYERTIME TAB
local PlayerTimeTab = Window:Tab({
    Title = "PLAYERTIME",
    Icon = "clock",
})

local PlayerTimeParagraph = PlayerTimeTab:Paragraph({
    Title = "SERVER PLAYTIME",
    Desc = "Loading player times...",
})

local function RefreshPlaytimeDisplay()
    local list = Players:GetPlayers()
    table.sort(list, function(a, b)
        local ta = PlayerJoinTimes[a] or tick()
        local tb = PlayerJoinTimes[b] or tick()
        return ta < tb
    end)

    local lines = {}
    for _, plr in ipairs(list) do
        local joinedAt = PlayerJoinTimes[plr] or tick()
        local elapsed = tick() - joinedAt
        table.insert(lines, string.format("• %s (@%s): %s", plr.DisplayName, plr.Name, FormatPlaytime(elapsed)))
    end

    if #lines == 0 then
        PlayerTimeParagraph:SetDesc("No players found.")
    else
        PlayerTimeParagraph:SetDesc(table.concat(lines, "\n"))
    end
end

PlayerTimeTab:Button({
    Title = "REFRESH PLAYTIME NOW",
    Desc = "Update all players' time in game",
    Callback = function()
        PlayClickSound()
        RefreshPlaytimeDisplay()
    end,
})

RefreshPlaytimeDisplay()

task.spawn(function()
    while Window do
        RefreshPlaytimeDisplay()
        task.wait(1)
    end
end)

--// 16. REJOIN TAB (REJOIN & SERVER HOP)
local RejoinTab = Window:Tab({
    Title = "REJOIN",
    Icon = "refresh-cw",
})

RejoinTab:Button({
    Title = "REJOIN SERVER 🔄",
    Desc = "Rejoin current server",
    Callback = function()
        PlayClickSound()
        RejoinCurrentServer()
    end,
})

RejoinTab:Button({
    Title = "SERVER HOP 🌐",
    Desc = "Hop to a different server",
    Callback = function()
        PlayClickSound()
        ServerHop()
    end,
})

--// NOTIFICATION & AUTO CHAT
WindUI:Notify({
    Title = "AYANUU HUB",
    Content = "AYANUU HUB LOADED! 💀",
    Duration = 5,
})

task.spawn(function()
    local chatMsg = "-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-AYANUU HUB LOADED 😎 Made by AYANUU 😋 (🏴ZERO MERCY 💀)"
    pcall(function()
        if game:GetService("TextChatService").ChatVersion == Enum.ChatVersion.TextChatService then
            game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(chatMsg)
        else
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(chatMsg, "All")
        end
    end)
end)
