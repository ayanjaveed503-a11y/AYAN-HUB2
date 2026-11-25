--// AYANUU HUB - Trio Kings WindUI Style (All Separate Tabs)

local players = game:GetService("Players")
local workspaceService = game:GetService("Workspace")
local tweenService = game:GetService("TweenService")
local httpService = game:GetService("HttpService")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local teleportService = game:GetService("TeleportService")
local lightingService = game:GetService("Lighting")
local coreGui = game:GetService("CoreGui")
local localPlayer = players.LocalPlayer
local Camera = workspaceService.CurrentCamera

local windui = loadstring(game:HttpGet("https://raw.githubusercontent.com/nxvap/windui/refs/heads/main/1.6.54.lua"))()

local window = windui:CreateWindow({
	Title = "👑 AYANUU HUB Client ( Universal ) 👑",
	Author = "AYANUU 👑 · " .. localPlayer.DisplayName,
	Icon = "crown",
	Size = UDim2.fromOffset(540, 420),
	Transparent = true,
	Theme = "Dark",
	HideSearchBar = false,
	User = { Enabled = true },
	OpenButton = {
		Title = "👑 AYANUU HUB 👑",
		Icon = "crown",
		CornerRadius = UDim.new(0, 15),
		StrokeThickness = 2,
		Enabled = true,
		Draggable = true,
		Color = ColorSequence.new(Color3.fromHex("000000"), Color3.fromHex("DC283C")),
	},
})

local function NotifyHub(title, content, duration, icon)
	windui:Notify({
		Title = title,
		Content = content,
		Duration = duration or 3,
		Icon = icon or "crown",
	})
end

--// SERVICES & GLOBAL VARIABLES
local TargetPlayer = nil
local BangSpeed = 1
local CustomHugUfoAnimId = "88712283515515"
local CustomSpeed = 16
local CustomJumpPower = 50
local fovPlayer = 70
local PreviousServerJobId = nil
local JoinByServerIdInput = ""

local WalkingFlingConnection = nil
local NoclipConnection = nil
local InfJumpConnection = nil
local TargetVisualConnection = nil
local AllVisualConnection = nil
local AimbotRenderConnection = nil
local MobileFlyActive = false

--// TELEPORT TAB VARIABLES
local TeleportMode = "Instant"
local SavedLocations = {}
local CheckpointCFrame = nil
local AutoRespawnCheckpoint = false
local CheckpointRespawnConn = nil
local DefaultMaxZoom = localPlayer.CameraMaxZoomDistance or 400
local DefaultMinZoom = localPlayer.CameraMinZoomDistance or 0.5

--// TOOL TAB VARIABLES
local LightingLevel = 3
local FreeCamSpeed = 80
local SpinToolSpeed = 5
local FreeCamConn = nil
local FreeCamInputConn = nil
local FreeCamYaw = 0
local FreeCamPitch = 0
local SpinToolConn = nil
local NoCamClipConn = nil
local ShiftLockRenderConn = nil
local ShiftLockRespawnConn = nil
local InvisibleHeartbeatConn = nil
local InvisibleRespawnConn = nil
local InvisibleParts = {}
local JerkRespawnConn = nil
local F3xLoaded = false
local F3xTrackedGuis = {}
local SavedFogStart = lightingService.FogStart
local SavedFogEnd = lightingService.FogEnd
local SavedBrightness = lightingService.Brightness
local SavedGlobalShadows = lightingService.GlobalShadows
local SavedAmbient = lightingService.Ambient
local SavedOutdoorAmbient = lightingService.OutdoorAmbient
local SavedClockTime = lightingService.ClockTime
local SavedGeographicLatitude = lightingService.GeographicLatitude

--// SAFE SPOT VARIABLES
local SafeSpotGui = nil
local SafeSpotBaseplate = nil
local teleported = false
local originalPosition = nil

local SelectedThemeColor = Color3.fromRGB(220, 40, 60)

local Toggles = {
	Bang = false,
	MouthBang = false,
	FrontBang = false,
	MouthSuck = false,
	Suck = false,
	Hug = false,
	Ufo = false,
	Follow = false,
	TargetJerk = false,
	Headsit = false,
	FrontHeadsit = false,
	Orbit = false,
	WalkingFling = false,
	Noclip = false,
	InfJump = false,
	InfiniteZoom = false,
	NoCameraClip = false,
	LightingBoost = false,
	FullBrightness = false,
	NoFog = false,
	FreeCam = false,
	TpTool = false,
	JerkTool = false,
	F3xHideTool = false,
	ShiftLock = false,
	Invisibility = false,
	SpinTool = false,
	AntiBangV2 = false,
	AntiFling = false,
	AntiSit = false,
	AntiAFK = false,
	ESP = false,
	Aimbot = false,
	TracerLine = false,
	ESPAll = false,
	TraceAll = false,
}

--// BACKGROUND ANIMATION SYSTEM FOR TARGET ACTIONS
local ActiveTargetAnimTrack = nil
local ActiveTargetAnimId = nil
local ActiveTargetAnimSpeed = 1
local TargetAnimWatchConn = nil
local TargetAnimRespawnConn = nil

local function CleanAnimId(rawId, fallbackId)
	local digits = tostring(rawId or ""):match("%d+")
	if digits and digits ~= "" then
		return digits
	end
	return tostring(fallbackId)
end

local function HasAnyActiveTargetAction()
	return Toggles.Bang
		or Toggles.MouthBang
		or Toggles.FrontBang
		or Toggles.MouthSuck
		or Toggles.Suck
		or Toggles.Hug
		or Toggles.Ufo
end

local function StopTargetAnimation()
	ActiveTargetAnimId = nil
	if TargetAnimWatchConn then
		TargetAnimWatchConn:Disconnect()
		TargetAnimWatchConn = nil
	end
	if TargetAnimRespawnConn then
		TargetAnimRespawnConn:Disconnect()
		TargetAnimRespawnConn = nil
	end
	if ActiveTargetAnimTrack then
		pcall(function()
			ActiveTargetAnimTrack:Stop(0.1)
			ActiveTargetAnimTrack:Destroy()
		end)
		ActiveTargetAnimTrack = nil
	end
end

local function AttachTargetAnimTrack()
	if not ActiveTargetAnimId or not HasAnyActiveTargetAction() then return end

	if ActiveTargetAnimTrack then
		pcall(function()
			ActiveTargetAnimTrack:Stop(0.05)
			ActiveTargetAnimTrack:Destroy()
		end)
		ActiveTargetAnimTrack = nil
	end

	pcall(function()
		local char = localPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hum then return end

		local animator = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 3)
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. tostring(ActiveTargetAnimId)

		local track = animator and animator:LoadAnimation(anim) or hum:LoadAnimation(anim)
		track.Priority = Enum.AnimationPriority.Action4
		track.Looped = true
		track:Play(0.1)
		track:AdjustSpeed(ActiveTargetAnimSpeed or 1)
		ActiveTargetAnimTrack = track

		if TargetAnimWatchConn then
			TargetAnimWatchConn:Disconnect()
			TargetAnimWatchConn = nil
		end

		TargetAnimWatchConn = runService.Heartbeat:Connect(function()
			if not ActiveTargetAnimId or not HasAnyActiveTargetAction() then return end
			local curTrack = ActiveTargetAnimTrack
			if curTrack then
				pcall(function()
					if not curTrack.IsPlaying then
						curTrack.Looped = true
						curTrack.Priority = Enum.AnimationPriority.Action4
						curTrack:Play(0.05)
					end
					curTrack:AdjustSpeed(math.clamp(BangSpeed or ActiveTargetAnimSpeed or 1, 0.5, 4))
				end)
			end
		end)
	end)
end

local function PlayTargetAnimation(animId, speed)
	StopTargetAnimation()
	ActiveTargetAnimId = CleanAnimId(animId, 88712283515515)
	ActiveTargetAnimSpeed = speed or 1
	AttachTargetAnimTrack()

	TargetAnimRespawnConn = localPlayer.CharacterAdded:Connect(function()
		if not ActiveTargetAnimId or not HasAnyActiveTargetAction() then return end
		task.wait(0.35)
		AttachTargetAnimTrack()
	end)
end

local function IsR15Character(plr)
	local char = plr and plr.Character
	local hum = char and char:FindFirstChildWhichIsA("Humanoid")
	return hum and hum.RigType == Enum.HumanoidRigType.R15
end

--// FPS COUNTER
local CurrentFPS = 60
do
	local frameCount = 0
	local lastTick = tick()
	runService.RenderStepped:Connect(function()
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

--// PREVIOUS SERVER TRACKING (FILE / QUEUE)
local PrevServerFile = "AYANUU_HUB_PrevServer_" .. tostring(game.PlaceId) .. ".json"

local function SavePreviousServerInfo(prevJobId)
	if not prevJobId or prevJobId == "" then return end
	PreviousServerJobId = prevJobId
	pcall(function()
		if typeof(writefile) == "function" then
			writefile(PrevServerFile, httpService:JSONEncode({
				placeId = game.PlaceId,
				previousJobId = prevJobId,
				savedAt = os.time(),
			}))
		end
	end)
end

local function LoadPreviousServerInfo()
	pcall(function()
		if typeof(isfile) == "function" and typeof(readfile) == "function" and isfile(PrevServerFile) then
			local raw = readfile(PrevServerFile)
			local data = httpService:JSONDecode(raw)
			if data and tonumber(data.placeId) == tonumber(game.PlaceId) and type(data.previousJobId) == "string" and data.previousJobId ~= "" then
				if data.previousJobId ~= tostring(game.JobId) then
					PreviousServerJobId = data.previousJobId
				end
			end
		end
	end)
end
LoadPreviousServerInfo()

local function CopyTextToClipboard(txt)
	local copied = false
	pcall(function()
		if typeof(setclipboard) == "function" then
			setclipboard(tostring(txt))
			copied = true
		elseif typeof(toclipboard) == "function" then
			toclipboard(tostring(txt))
			copied = true
		end
	end)
	return copied
end

--// REJOIN, PREVIOUS SERVER, JOIN BY ID & SERVER HOP FUNCTIONS
local function RejoinCurrentServer()
	pcall(function()
		SavePreviousServerInfo(tostring(game.JobId))
		if #players:GetPlayers() <= 1 then
			localPlayer:Kick("\nRejoining server...")
			task.wait(0.2)
			teleportService:Teleport(game.PlaceId, localPlayer)
		else
			teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
		end
	end)
end

local function ReturnToPreviousServer()
	if not PreviousServerJobId or PreviousServerJobId == "" then
		NotifyHub("PREVIOUS SERVER ⚠️", "No previous server ID saved yet! Hop or rejoin first.", 3, "alert-triangle")
		return
	end

	if tostring(PreviousServerJobId) == tostring(game.JobId) then
		NotifyHub("PREVIOUS SERVER ℹ️", "You are already in that server!", 3, "info")
		return
	end

	NotifyHub("RETURN TO PREVIOUS SERVER ⏪", "Joining previous server: " .. tostring(PreviousServerJobId):sub(1, 12) .. "...", 3, "history")
	pcall(function()
		teleportService:TeleportToPlaceInstance(game.PlaceId, tostring(PreviousServerJobId), localPlayer)
	end)
end

local function JoinByServerId(jobIdStr)
	local cleaned = tostring(jobIdStr or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if cleaned == "" then
		NotifyHub("JOIN BY SERVER ID ⚠️", "Please paste a valid Server JobId first!", 3, "alert-triangle")
		return
	end

	SavePreviousServerInfo(tostring(game.JobId))
	NotifyHub("JOIN BY SERVER ID 🔗", "Teleporting to server ID...", 3, "link")
	pcall(function()
		teleportService:TeleportToPlaceInstance(game.PlaceId, cleaned, localPlayer)
	end)
end

local function ServerHop()
	NotifyHub("SERVER HOP 🌐", "Searching for another server...", 3, "globe")
	SavePreviousServerInfo(tostring(game.JobId))

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
					decoded = httpService:JSONDecode(res)
				end)

				if decoded and decoded.data then
					for _, srv in ipairs(decoded.data) do
						if tostring(srv.id) ~= tostring(game.JobId)
						and tonumber(srv.playing)
						and tonumber(srv.maxPlayers)
						and srv.playing < srv.maxPlayers then
							pcall(function()
								teleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, localPlayer)
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
			teleportService:Teleport(game.PlaceId, localPlayer)
		end)
	end)
end

--// TELEPORT MODE & LOCATION TELEPORTATION
local function TeleportCharacterToCFrame(targetCF)
	local char = localPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp or not targetCF then return end

	if TeleportMode == "Smooth" then
		local dist = (hrp.Position - targetCF.Position).Magnitude
		local duration = math.clamp(dist / 120, 0.12, 0.85)
		local tween = tweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = targetCF
		})
		tween:Play()
	else
		hrp.CFrame = targetCF
	end
end

local function SetInfiniteZoom(state)
	Toggles.InfiniteZoom = state
	if state then
		localPlayer.CameraMaxZoomDistance = math.huge
		localPlayer.CameraMinZoomDistance = 0.5
	else
		localPlayer.CameraMaxZoomDistance = DefaultMaxZoom
		localPlayer.CameraMinZoomDistance = DefaultMinZoom
	end
end

--// TOOL TAB FUNCTIONS
local function ApplyLightingState(enabled)
	pcall(function()
		if enabled then
			lightingService.Brightness = math.clamp(LightingLevel * 1.2, 0.5, 10)
			lightingService.GlobalShadows = false
			lightingService.Ambient = Color3.fromRGB(190, 190, 190)
			lightingService.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
		elseif Toggles.FullBrightness then
			lightingService.Brightness = 5
			lightingService.GlobalShadows = false
			lightingService.Ambient = Color3.new(1, 1, 1)
			lightingService.OutdoorAmbient = Color3.new(1, 1, 1)
		else
			lightingService.Brightness = SavedBrightness
			lightingService.GlobalShadows = SavedGlobalShadows
			lightingService.Ambient = SavedAmbient
			lightingService.OutdoorAmbient = SavedOutdoorAmbient
		end
	end)
end

local function SetFullBrightness(state)
	Toggles.FullBrightness = state
	pcall(function()
		if state then
			lightingService.Brightness = 5
			lightingService.GlobalShadows = false
			lightingService.Ambient = Color3.new(1, 1, 1)
			lightingService.OutdoorAmbient = Color3.new(1, 1, 1)
			lightingService.ClockTime = 14
		elseif Toggles.LightingBoost then
			ApplyLightingState(true)
		else
			lightingService.Brightness = SavedBrightness
			lightingService.GlobalShadows = SavedGlobalShadows
			lightingService.Ambient = SavedAmbient
			lightingService.OutdoorAmbient = SavedOutdoorAmbient
			lightingService.ClockTime = SavedClockTime
			lightingService.GeographicLatitude = SavedGeographicLatitude
		end
	end)
end

local function ApplyNoFogState(enabled)
	pcall(function()
		if enabled then
			lightingService.FogStart = 1e6
			lightingService.FogEnd = 1e6
			for _, inst in ipairs(lightingService:GetDescendants()) do
				if inst:IsA("Atmosphere") then
					inst:SetAttribute("SavedDensity", inst.Density)
					inst.Density = 0
				end
			end
		else
			lightingService.FogStart = SavedFogStart
			lightingService.FogEnd = SavedFogEnd
			for _, inst in ipairs(lightingService:GetDescendants()) do
				if inst:IsA("Atmosphere") then
					local prevDensity = inst:GetAttribute("SavedDensity")
					if prevDensity ~= nil then
						inst.Density = prevDensity
					end
				end
			end
		end
	end)
end

local function SetNoCameraClip(state)
	Toggles.NoCameraClip = state
	if NoCamClipConn then
		NoCamClipConn:Disconnect()
		NoCamClipConn = nil
	end

	if state then
		pcall(function()
			localPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
		end)
		NoCamClipConn = runService.RenderStepped:Connect(function()
			if not Toggles.NoCameraClip then return end
			pcall(function()
				localPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
				local char = localPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				local cam = workspaceService.CurrentCamera
				if hrp and cam then
					cam.CameraType = Enum.CameraType.Custom
					cam.CameraSubject = char:FindFirstChildOfClass("Humanoid") or hrp
				end
			end)
		end)
	else
		pcall(function()
			localPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
		end)
	end
end

local function SetFreeCam(state)
	Toggles.FreeCam = state
	if FreeCamConn then
		FreeCamConn:Disconnect()
		FreeCamConn = nil
	end
	if FreeCamInputConn then
		FreeCamInputConn:Disconnect()
		FreeCamInputConn = nil
	end

	local cam = workspaceService.CurrentCamera
	local char = localPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	if state then
		if hum then hum.PlatformStand = true end
		if hrp then hrp.Anchored = true end
		if cam then
			local _, yRot, xRot = cam.CFrame:ToEulerAnglesYXZ()
			FreeCamYaw = yRot
			FreeCamPitch = xRot
			cam.CameraType = Enum.CameraType.Scriptable
		end

		FreeCamInputConn = userInputService.InputChanged:Connect(function(input, gameProcessed)
			if not Toggles.FreeCam then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local delta = input.Delta
				local sensitivity = (input.UserInputType == Enum.UserInputType.Touch) and 0.005 or 0.0035
				FreeCamYaw = FreeCamYaw - (delta.X * sensitivity)
				FreeCamPitch = math.clamp(FreeCamPitch - (delta.Y * sensitivity), math.rad(-89), math.rad(89))
			end
		end)

		FreeCamConn = runService.RenderStepped:Connect(function(dt)
			if not Toggles.FreeCam then return end
			cam = workspaceService.CurrentCamera
			if not cam then return end

			local rotCF = CFrame.fromEulerAnglesYXZ(FreeCamPitch, FreeCamYaw, 0)
			local speed = math.max(10, tonumber(FreeCamSpeed) or 80)
			local moveVec = Vector3.zero

			if userInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + rotCF.LookVector end
			if userInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - rotCF.LookVector end
			if userInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + rotCF.RightVector end
			if userInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - rotCF.RightVector end
			if userInputService:IsKeyDown(Enum.KeyCode.E) or userInputService:IsKeyDown(Enum.KeyCode.Space) then
				moveVec = moveVec + Vector3.new(0, 1, 0)
			end
			if userInputService:IsKeyDown(Enum.KeyCode.Q) or userInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				moveVec = moveVec - Vector3.new(0, 1, 0)
			end

			local myChar = localPlayer.Character
			local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
			if myHum and myHum.MoveDirection.Magnitude > 0 and moveVec.Magnitude == 0 then
				local md = myHum.MoveDirection
				local camForward = rotCF.LookVector
				local camRight = rotCF.RightVector
				local forwardAmount = (-md.Z)
				local rightAmount = md.X
				moveVec = (camForward * forwardAmount) + (camRight * rightAmount)
			end

			local currentPos = cam.CFrame.Position
			if moveVec.Magnitude > 0 then
				currentPos = currentPos + (moveVec.Unit * speed * dt)
			end
			cam.CFrame = CFrame.new(currentPos) * rotCF
		end)
	else
		pcall(function()
			userInputService.MouseBehavior = Enum.MouseBehavior.Default
		end)
		if cam then
			cam.CameraType = Enum.CameraType.Custom
			if hum then cam.CameraSubject = hum end
		end
		if hrp then hrp.Anchored = false end
		if hum then hum.PlatformStand = false end
	end
end

local function SetTpTool(state)
	Toggles.TpTool = state
	local backpack = localPlayer:FindFirstChildOfClass("Backpack") or localPlayer:WaitForChild("Backpack")
	local existing = backpack:FindFirstChild("TP Tool") or (localPlayer.Character and localPlayer.Character:FindFirstChild("TP Tool"))
	if existing then
		pcall(function() existing:Destroy() end)
	end
	if not state then return end

	local tool = Instance.new("Tool")
	tool.Name = "TP Tool"
	tool.RequiresHandle = false
	tool.CanBeDropped = false
	tool.Activated:Connect(function()
		local mouse = localPlayer:GetMouse()
		local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
		if mouse and mouse.Hit and hrp then
			hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
		end
	end)
	tool.Parent = backpack
end

--// F3X HIDE TOOL SYSTEM
local function GetGuiContainers()
	local containers = {}
	pcall(function()
		if typeof(gethui) == "function" then
			table.insert(containers, gethui())
		end
	end)
	pcall(function()
		table.insert(containers, coreGui)
	end)
	pcall(function()
		local pg = localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild("PlayerGui", 3)
		if pg then
			table.insert(containers, pg)
		end
	end)
	return containers
end

local function SnapshotScreenGuis()
	local map = {}
	for _, parentObj in ipairs(GetGuiContainers()) do
		for _, child in ipairs(parentObj:GetChildren()) do
			if child:IsA("ScreenGui") and child.Name ~= "FlyCardGui" and child.Name ~= "AYANUU_ANTIAFK_Timer" and child.Name ~= "AYANUUMultiFlingGUI" and child.Name ~= "TeleportGui" then
				map[child] = true
			end
		end
	end
	return map
end

local function SetF3xGuisVisible(visible)
	for guiObj in pairs(F3xTrackedGuis) do
		if guiObj and guiObj.Parent then
			pcall(function()
				guiObj.Enabled = visible
			end)
		end
	end
end

local function SetF3xHideTool(state)
	Toggles.F3xHideTool = state
	if state then
		if not F3xLoaded then
			local beforeMap = SnapshotScreenGuis()
			local ok, err = pcall(function()
				loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/refs/heads/main/f3x.lua"))()
			end)
			if not ok then
				Toggles.F3xHideTool = false
				NotifyHub("F3X ERROR ❌", tostring(err), 3, "x-circle")
				return
			end
			F3xLoaded = true
			task.wait(0.35)

			F3xTrackedGuis = {}
			for _, parentObj in ipairs(GetGuiContainers()) do
				for _, child in ipairs(parentObj:GetChildren()) do
					if child:IsA("ScreenGui") and not beforeMap[child] then
						local titleLower = child.Name:lower()
						if titleLower:find("f3x") or titleLower:find("building") or true then
							F3xTrackedGuis[child] = true
						end
					end
				end
			end
		end
		SetF3xGuisVisible(true)
	else
		SetF3xGuisVisible(false)
	end
end

--// JERK TOOL (CUSTOM ANIMATION SYSTEM)
local function SetJerkTool(state)
	Toggles.JerkTool = state
	if JerkRespawnConn then
		JerkRespawnConn:Disconnect()
		JerkRespawnConn = nil
	end

	local backpack = localPlayer:FindFirstChildOfClass("Backpack") or localPlayer:WaitForChild("Backpack")
	local existing = backpack:FindFirstChild("Jerk") or (localPlayer.Character and localPlayer.Character:FindFirstChild("Jerk"))
	if existing then
		pcall(function() existing:Destroy() end)
	end

	if not state then return end

	local speaker = localPlayer
	local char = speaker.Character or speaker.CharacterAdded:Wait()
	local humanoid = char:FindFirstChildWhichIsA("Humanoid")
	if not humanoid or not backpack then return end

	local tool = Instance.new("Tool")
	tool.Name = "Jerk"
	tool.ToolTip = "in the stripped club. straight up \"jorking it\" . and by \"it\" , haha, well. let's justr say. My peanits."
	tool.RequiresHandle = false
	tool.Parent = backpack

	local jorkin = false
	local track = nil
	local running = true

	local function stopTomfoolery()
		jorkin = false
		if track then
			pcall(function() track:Stop() end)
			track = nil
		end
	end

	tool.Equipped:Connect(function() jorkin = true end)
	tool.Unequipped:Connect(stopTomfoolery)
	tool.Destroying:Connect(function()
		running = false
		stopTomfoolery()
	end)
	humanoid.Died:Connect(function()
		running = false
		stopTomfoolery()
	end)

	task.spawn(function()
		while running and Toggles.JerkTool and task.wait() do
			if not jorkin then continue end

			local currentHum = speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid")
			if not currentHum then continue end

			local isR15 = IsR15Character(speaker)
			if not track then
				local anim = Instance.new("Animation")
				anim.AnimationId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653"
				track = currentHum:LoadAnimation(anim)
			end

			track:Play()
			track:AdjustSpeed(isR15 and 0.7 or 0.65)
			track.TimePosition = 0.6
			task.wait(0.1)
			while jorkin and running and Toggles.JerkTool and track and track.TimePosition < (not isR15 and 0.65 or 0.7) do
				task.wait(0.1)
			end
			if track then
				pcall(function() track:Stop() end)
				track = nil
			end
		end
		stopTomfoolery()
	end)

	JerkRespawnConn = localPlayer.CharacterAdded:Connect(function()
		running = false
		stopTomfoolery()
		task.wait(0.4)
		if Toggles.JerkTool then
			SetJerkTool(true)
		end
	end)
end

--// SHIFT LOCK (NO GUI, DIRECT ON/OFF TOGGLE)
local function ApplyShiftLockState(enabled)
	local char = localPlayer.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if enabled then
		humanoid.CameraOffset = Vector3.new(1.7, 0.5, 0)
		humanoid.AutoRotate = false
	else
		humanoid.CameraOffset = Vector3.new(0, 0, 0)
		humanoid.AutoRotate = true
	end
end

local function SetShiftLock(state)
	Toggles.ShiftLock = state

	if ShiftLockRenderConn then
		ShiftLockRenderConn:Disconnect()
		ShiftLockRenderConn = nil
	end
	if ShiftLockRespawnConn then
		ShiftLockRespawnConn:Disconnect()
		ShiftLockRespawnConn = nil
	end

	if state then
		ApplyShiftLockState(true)

		ShiftLockRenderConn = runService.RenderStepped:Connect(function()
			if not Toggles.ShiftLock then return end
			local char = localPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local cam = workspaceService.CurrentCamera
			if hrp and cam then
				local _, y = cam.CFrame:ToEulerAnglesYXZ()
				hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, y, 0)
			end
		end)

		ShiftLockRespawnConn = localPlayer.CharacterAdded:Connect(function()
			task.wait(0.5)
			if Toggles.ShiftLock then
				ApplyShiftLockState(true)
			end
		end)
	else
		ApplyShiftLockState(false)
	end
end

--// INVISIBILITY (NO GUI, DIRECT ON/OFF TOGGLE)
local function CollectInvisibleParts(char)
	InvisibleParts = {}
	if not char then return end
	for _, obj in ipairs(char:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Transparency == 0 then
			table.insert(InvisibleParts, obj)
		end
	end
end

local function SetPartsTransparency(trans)
	for _, part in ipairs(InvisibleParts) do
		if part and part.Parent then
			pcall(function()
				part.Transparency = trans
			end)
		end
	end
end

local function SetInvisibility(state)
	Toggles.Invisibility = state

	if InvisibleHeartbeatConn then
		InvisibleHeartbeatConn:Disconnect()
		InvisibleHeartbeatConn = nil
	end
	if InvisibleRespawnConn then
		InvisibleRespawnConn:Disconnect()
		InvisibleRespawnConn = nil
	end

	if state then
		local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
		char:WaitForChild("Humanoid")
		char:WaitForChild("HumanoidRootPart")
		CollectInvisibleParts(char)
		SetPartsTransparency(0.5)

		InvisibleHeartbeatConn = runService.Heartbeat:Connect(function()
			if not Toggles.Invisibility then return end
			local c = localPlayer.Character
			local hum = c and c:FindFirstChildOfClass("Humanoid")
			local rootPart = c and c:FindFirstChild("HumanoidRootPart")
			if hum and rootPart then
				local cf = rootPart.CFrame
				local camOffset = hum.CameraOffset
				local hidden = cf * CFrame.new(0, -200000, 0)
				rootPart.CFrame = hidden
				hum.CameraOffset = hidden:ToObjectSpace(CFrame.new(cf.Position)).Position
				runService.RenderStepped:Wait()
				if Toggles.Invisibility and rootPart and rootPart.Parent then
					rootPart.CFrame = cf
					hum.CameraOffset = camOffset
				end
			end
		end)

		InvisibleRespawnConn = localPlayer.CharacterAdded:Connect(function(newChar)
			task.wait(0.3)
			if Toggles.Invisibility then
				newChar:WaitForChild("Humanoid")
				newChar:WaitForChild("HumanoidRootPart")
				CollectInvisibleParts(newChar)
				SetPartsTransparency(0.5)
			end
		end)
	else
		SetPartsTransparency(0)
		local char = localPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.CameraOffset = Vector3.new(0, 0, 0)
		end
	end
end

local function SetSpinTool(state)
	Toggles.SpinTool = state
	if SpinToolConn then
		SpinToolConn:Disconnect()
		SpinToolConn = nil
	end

	if state then
		SpinToolConn = runService.RenderStepped:Connect(function(dt)
			if not Toggles.SpinTool then return end
			pcall(function()
				local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					local rotSpeed = math.max(1, tonumber(SpinToolSpeed) or 5) * 3.5
					hrp.CFrame = hrp.CFrame * CFrame.Angles(0, rotSpeed * dt, 0)
				end
			end)
		end)
	end
end

local function SetAutoRespawnCheckpoint(state)
	AutoRespawnCheckpoint = state
	if CheckpointRespawnConn then
		CheckpointRespawnConn:Disconnect()
		CheckpointRespawnConn = nil
	end

	if state then
		CheckpointRespawnConn = localPlayer.CharacterAdded:Connect(function(newChar)
			if not AutoRespawnCheckpoint or not CheckpointCFrame then return end
			task.spawn(function()
				local hrp = newChar:WaitForChild("HumanoidRootPart", 10)
				task.wait(0.25)
				if AutoRespawnCheckpoint and CheckpointCFrame and hrp then
					hrp.CFrame = CheckpointCFrame
				end
			end)
		end)
	end
end

--// PLAYER JOIN TIME TRACKER
local PlayerJoinTimes = {}

local function RecordPlayerJoin(plr)
	if plr and not PlayerJoinTimes[plr] then
		PlayerJoinTimes[plr] = tick()
	end
end

for _, plr in ipairs(players:GetPlayers()) do
	RecordPlayerJoin(plr)
end

players.PlayerAdded:Connect(RecordPlayerJoin)
players.PlayerRemoving:Connect(function(plr)
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

	for _, p in pairs(players:GetPlayers()) do
		if p.Name:lower():sub(1, #name) == name
		or p.DisplayName:lower():sub(1, #name) == name then
			return p
		end
	end

	return nil
end

--// LIVE GUI + DRAWING ACCENT COLOR SYSTEM
local AllPlayerDrawings = {}
local EspBox = nil
local TracerDraw = nil

local function TintGuiDescendants(rootObj, color)
	if not rootObj then return end
	for _, inst in ipairs(rootObj:GetDescendants()) do
		pcall(function()
			if inst:IsA("UIStroke") then
				inst.Color = color
			elseif inst:IsA("UIListLayout") or inst:IsA("UIGridLayout") or inst:IsA("UICorner") or inst:IsA("UIPadding") then
				-- skip
			elseif inst:IsA("Frame") or inst:IsA("TextButton") or inst:IsA("ScrollingFrame") then
				local bg = inst.BackgroundColor3
				local isDarkNeutral = (math.abs(bg.R - bg.G) < 0.05 and math.abs(bg.G - bg.B) < 0.05 and bg.R < 0.25)
				if not isDarkNeutral and inst.Name ~= "MainFrame" and inst.Name ~= "SelectionFrame" then
					inst.BackgroundColor3 = color
				end
			end
		end)
	end
end

local function ApplyThemeColor(color)
	SelectedThemeColor = color

	pcall(function()
		if windui and windui.SetTheme then
			windui:SetTheme("Dark")
		end
	end)

	pcall(function()
		local parentGui = (typeof(gethui) == "function" and gethui()) or coreGui
		for _, gui in ipairs(parentGui:GetChildren()) do
			if gui:IsA("ScreenGui") and gui.Name ~= "FlyCardGui" then
				TintGuiDescendants(gui, color)
			end
		end
		for _, gui in ipairs(coreGui:GetChildren()) do
			if gui:IsA("ScreenGui") and gui.Name ~= "FlyCardGui" then
				TintGuiDescendants(gui, color)
			end
		end
	end)

	pcall(function()
		if EspBox then EspBox.Color = color end
		if TracerDraw then TracerDraw.Color = color end
		for _, objs in pairs(AllPlayerDrawings) do
			if objs.Box then objs.Box.Color = color end
			if objs.Tracer then objs.Tracer.Color = color end
		end
	end)

	NotifyHub(
		"THEME UPDATED 🎨",
		string.format("Color set to RGB(%d, %d, %d)", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)),
		2,
		"palette"
	)
end

--// TARGET ESP & TRACER DRAWING OBJECTS
EspBox = Drawing.new("Square")
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

TracerDraw = Drawing.new("Line")
TracerDraw.Visible = false
TracerDraw.Thickness = 2
TracerDraw.Color = Color3.fromRGB(255, 60, 60)

local function UpdateTargetVisualLoops()
	if TargetVisualConnection then
		TargetVisualConnection:Disconnect()
		TargetVisualConnection = nil
	end

	if Toggles.ESP or Toggles.TracerLine then
		TargetVisualConnection = runService.RenderStepped:Connect(function()
			Camera = workspaceService.CurrentCamera
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

				local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
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

players.PlayerRemoving:Connect(function(player)
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

	AllVisualConnection = runService.RenderStepped:Connect(function()
		Camera = workspaceService.CurrentCamera
		local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

		for _, plr in ipairs(players:GetPlayers()) do
			if plr ~= localPlayer then
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
		AimbotRenderConnection = runService.RenderStepped:Connect(function()
			if not Toggles.Aimbot then return end
			local tp = TargetPlayer
			local tChar = tp and tp.Character
			local aimPart = tChar and (tChar:FindFirstChild("Head") or tChar:FindFirstChild("HumanoidRootPart"))
			if tp and tp.Parent and aimPart then
				Camera = workspaceService.CurrentCamera
				Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPart.Position)
			end
		end)
	end
end

--// ANTI-FLING SYSTEM
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
	local steppedConn = runService.Stepped:Connect(function()
		if Toggles.AntiFling and character:IsDescendantOf(workspaceService) then
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
		if player == localPlayer then return end
		local conn = player.CharacterAdded:Connect(DisableCharCollisions)
		if player.Character then
			DisableCharCollisions(player.Character)
		end
		AntiFlingPlayerConns[player] = conn
	end

	for _, plr in ipairs(players:GetPlayers()) do
		trackPlayer(plr)
	end

	table.insert(AntiFlingCharConns, players.PlayerAdded:Connect(trackPlayer))
	table.insert(AntiFlingCharConns, players.PlayerRemoving:Connect(function(plr)
		if AntiFlingPlayerConns[plr] then
			AntiFlingPlayerConns[plr]:Disconnect()
			AntiFlingPlayerConns[plr] = nil
		end
	end))

	AntiFlingHeartbeatConn = runService.Heartbeat:Connect(function()
		if not Toggles.AntiFling then return end
		local myChar = localPlayer.Character
		if not myChar then return end
		local hrp = myChar:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local hrpPos = hrp.Position

		for _, item in ipairs(workspaceService:GetChildren()) do
			if item:IsA("BasePart") then
				SecureFlingPart(item, hrpPos, myChar)
			elseif item:IsA("Model") and not players:GetPlayerFromCharacter(item) then
				for _, part in ipairs(item:GetDescendants()) do
					if part:IsA("BasePart") then
						SecureFlingPart(part, hrpPos, myChar)
					end
				end
			end
		end
	end)
end

--// MULTI FLING GUI
local function OpenMultiFlingGui()
	local targetGuiParent = (typeof(gethui) == "function" and gethui()) or coreGui
	if targetGuiParent:FindFirstChild("AYANUUMultiFlingGUI") then
		NotifyHub("AYANUU HUB", "Multi Fling GUI is already open!", 3, "shield")
		return
	end

	task.spawn(function()
		local Player = players.LocalPlayer

		local ScreenGui = Instance.new("ScreenGui")
		ScreenGui.Name = "AYANUUMultiFlingGUI"
		ScreenGui.ResetOnSpawn = false
		ScreenGui.Parent = targetGuiParent

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
		MinLabel.Text = "AYANUU MULTI FLING GUI"
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
			local PlayerList = players:GetPlayers()
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
			for _, p in ipairs(players:GetPlayers()) do
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

		players.PlayerAdded:Connect(RefreshPlayerList)
		players.PlayerRemoving:Connect(function(p)
			SelectedTargets[p.Name] = nil
			RefreshPlayerList()
			UpdateStatus()
		end)

		RefreshPlayerList()
		UpdateStatus()
	end)
end

--// ANTI-AFK TIMER GUI
local function ToggleAyanuuAFK(state)
	local VirtualUser = game:GetService("VirtualUser")

	if coreGui:FindFirstChild("AYANUU_ANTIAFK_Timer") then
		coreGui.AYANUU_ANTIAFK_Timer:Destroy()
	end

	if not state then
		return
	end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "AYANUU_ANTIAFK_Timer"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = coreGui

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

		local tween = tweenService:Create(drop, TweenInfo.new(dropSpeed, Enum.EasingStyle.Linear), {
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
		UserImage.Image = players:GetUserThumbnailAsync(localPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
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

	local idleConn = localPlayer.Idled:Connect(function()
		if not Toggles.AntiAFK then return end
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new(0, 0))
		pcall(function()
			if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
				localPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
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

--// CUSTOM FLY CARD GUI (FROM Fly.lua)
local CustomFlyGui = nil
local CustomFlyActive = false
local CustomFlyLocked = false
local CustomFlyBaseSpeed = 52
local CustomFlySpeed = 52
local CustomFlyStrafeSpeed = 68
local CustomFlyVerticalSpeed = 45
local CustomFlySmoothness = 12
local CustomFlyBodyGyro, CustomFlyBodyVel
local CustomFlyCurrentVel = Vector3.zero
local CustomFlyRenderConn = nil
local CustomFlyKeyConn = nil
local CustomFlyDragConn = nil

local function getFlyRootAndHum()
	local char = localPlayer.Character
	if not char then return nil, nil end
	return char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid")
end

local function getFlyGuiParent()
	local ok, cg = pcall(function() return coreGui end)
	if ok and cg then
		local testOk = pcall(function()
			local f = Instance.new("Folder")
			f.Parent = cg
			f:Destroy()
		end)
		if testOk then return cg end
	end
	return localPlayer:WaitForChild("PlayerGui")
end

local function startCustomFly()
	local root, hum = getFlyRootAndHum()
	if not root or not hum then return end

	CustomFlyActive = true
	hum.PlatformStand = false
	CustomFlyCurrentVel = root.AssemblyLinearVelocity

	if CustomFlyBodyGyro then CustomFlyBodyGyro:Destroy() end
	if CustomFlyBodyVel then CustomFlyBodyVel:Destroy() end

	CustomFlyBodyGyro = Instance.new("BodyGyro")
	CustomFlyBodyGyro.P = 3500
	CustomFlyBodyGyro.D = 350
	CustomFlyBodyGyro.MaxTorque = Vector3.new(0, 9e5, 0)
	CustomFlyBodyGyro.CFrame = root.CFrame
	CustomFlyBodyGyro.Parent = root

	CustomFlyBodyVel = Instance.new("BodyVelocity")
	CustomFlyBodyVel.Velocity = CustomFlyCurrentVel
	CustomFlyBodyVel.MaxForce = Vector3.new(9e5, 9e5, 9e5)
	CustomFlyBodyVel.Parent = root
end

local function stopCustomFly()
	CustomFlyActive = false
	CustomFlyCurrentVel = Vector3.zero
	if CustomFlyBodyGyro then CustomFlyBodyGyro:Destroy() CustomFlyBodyGyro = nil end
	if CustomFlyBodyVel then CustomFlyBodyVel:Destroy() CustomFlyBodyVel = nil end

	local _, hum = getFlyRootAndHum()
	if hum then
		hum.PlatformStand = false
		hum:ChangeState(Enum.HumanoidStateType.Freefall)
	end
end

local function destroyCustomFlyGui()
	stopCustomFly()
	if CustomFlyRenderConn then CustomFlyRenderConn:Disconnect() CustomFlyRenderConn = nil end
	if CustomFlyKeyConn then CustomFlyKeyConn:Disconnect() CustomFlyKeyConn = nil end
	if CustomFlyDragConn then CustomFlyDragConn:Disconnect() CustomFlyDragConn = nil end

	local parentTarget = getFlyGuiParent()
	if parentTarget:FindFirstChild("FlyCardGui") then
		parentTarget.FlyCardGui:Destroy()
	end
	if CustomFlyGui and CustomFlyGui.Parent then
		CustomFlyGui:Destroy()
	end
	CustomFlyGui = nil
end

local function createCustomFlyGui()
	destroyCustomFlyGui()
	CustomFlyLocked = false

	local parentTarget = getFlyGuiParent()
	local gui = Instance.new("ScreenGui")
	gui.Name = "FlyCardGui"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = parentTarget
	CustomFlyGui = gui

	local mainCard = Instance.new("Frame")
	mainCard.Name = "MainCard"
	mainCard.Size = UDim2.new(0, 58, 0, 102)
	mainCard.Position = UDim2.new(0.80, 0, 0.25, 0)
	mainCard.BackgroundColor3 = Color3.fromRGB(43, 38, 40)
	mainCard.BackgroundTransparency = 0.08
	mainCard.BorderSizePixel = 0
	mainCard.Active = true
	mainCard.Parent = gui

	Instance.new("UICorner", mainCard).CornerRadius = UDim.new(0, 12)

	local cardStroke = Instance.new("UIStroke", mainCard)
	cardStroke.Color = Color3.fromRGB(255, 255, 255)
	cardStroke.Transparency = 0.88
	cardStroke.Thickness = 1

	local bgPlaneEmoji = Instance.new("TextLabel")
	bgPlaneEmoji.Name = "BackgroundPlaneEmoji"
	bgPlaneEmoji.Size = UDim2.new(1, 0, 1, 0)
	bgPlaneEmoji.Position = UDim2.new(0, 0, 0, -4)
	bgPlaneEmoji.BackgroundTransparency = 1
	bgPlaneEmoji.Text = "✈️"
	bgPlaneEmoji.TextScaled = true
	bgPlaneEmoji.TextTransparency = 0.72
	bgPlaneEmoji.Font = Enum.Font.GothamBold
	bgPlaneEmoji.ZIndex = 1
	bgPlaneEmoji.Parent = mainCard

	local topHint = Instance.new("TextLabel")
	topHint.Name = "ShiftFLabel"
	topHint.Size = UDim2.new(1, -2, 0, 15)
	topHint.Position = UDim2.new(0, 1, 0, 3)
	topHint.BackgroundTransparency = 1
	topHint.Text = "Shift F"
	topHint.TextColor3 = Color3.fromRGB(185, 175, 178)
	topHint.Font = Enum.Font.GothamBold
	topHint.TextSize = 10
	topHint.ZIndex = 2
	topHint.Parent = mainCard

	local flyToggleBtn = Instance.new("TextButton")
	flyToggleBtn.Name = "FlyToggle"
	flyToggleBtn.Size = UDim2.new(1, -6, 0, 48)
	flyToggleBtn.Position = UDim2.new(0, 3, 0, 20)
	flyToggleBtn.BackgroundTransparency = 1
	flyToggleBtn.Text = ""
	flyToggleBtn.AutoButtonColor = false
	flyToggleBtn.ZIndex = 3
	flyToggleBtn.Parent = mainCard

	local statusDot = Instance.new("Frame")
	statusDot.Name = "StatusDot"
	statusDot.Size = UDim2.new(0, 10, 0, 10)
	statusDot.Position = UDim2.new(0.5, -5, 0.5, -5)
	statusDot.BackgroundColor3 = Color3.fromRGB(120, 120, 125)
	statusDot.BorderSizePixel = 0
	statusDot.ZIndex = 3
	statusDot.Parent = flyToggleBtn
	Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

	local speedBox = Instance.new("TextBox")
	speedBox.Name = "SpeedBox"
	speedBox.Size = UDim2.new(1, -8, 0, 20)
	speedBox.Position = UDim2.new(0, 4, 1, -24)
	speedBox.BackgroundColor3 = Color3.fromRGB(24, 21, 23)
	speedBox.BorderSizePixel = 0
	speedBox.Text = tostring(CustomFlyBaseSpeed)
	speedBox.PlaceholderText = "Speed"
	speedBox.TextColor3 = Color3.fromRGB(245, 245, 245)
	speedBox.PlaceholderColor3 = Color3.fromRGB(135, 130, 132)
	speedBox.Font = Enum.Font.GothamBold
	speedBox.TextSize = 10
	speedBox.ClearTextOnFocus = false
	speedBox.ZIndex = 3
	speedBox.Parent = mainCard
	Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 6)

	local speedStroke = Instance.new("UIStroke", speedBox)
	speedStroke.Color = Color3.fromRGB(255, 255, 255)
	speedStroke.Transparency = 0.85
	speedStroke.Thickness = 1

	local lockBtn = Instance.new("TextButton")
	lockBtn.Name = "LockButton"
	lockBtn.Size = UDim2.new(0, 20, 0, 20)
	lockBtn.Position = UDim2.new(1, -8, 0, -8)
	lockBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
	lockBtn.BorderSizePixel = 0
	lockBtn.Text = "🔓"
	lockBtn.TextSize = 10
	lockBtn.Font = Enum.Font.GothamBold
	lockBtn.ZIndex = 5
	lockBtn.Parent = mainCard
	Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(1, 0)

	local function updateVisualState()
		if CustomFlyActive then
			statusDot.BackgroundColor3 = Color3.fromRGB(45, 215, 95)
			bgPlaneEmoji.TextTransparency = 0.45
		else
			statusDot.BackgroundColor3 = Color3.fromRGB(120, 120, 125)
			bgPlaneEmoji.TextTransparency = 0.72
		end

		if CustomFlyLocked then
			lockBtn.Text = "🔒"
			cardStroke.Color = Color3.fromRGB(255, 195, 55)
			cardStroke.Transparency = 0.55
		else
			lockBtn.Text = "🔓"
			cardStroke.Color = Color3.fromRGB(255, 255, 255)
			cardStroke.Transparency = 0.88
		end
	end

	local function toggleFlyState()
		if CustomFlyActive then
			stopCustomFly()
		else
			startCustomFly()
		end
		updateVisualState()
	end

	flyToggleBtn.MouseButton1Click:Connect(toggleFlyState)

	lockBtn.MouseButton1Click:Connect(function()
		CustomFlyLocked = not CustomFlyLocked
		updateVisualState()
	end)

	local function applySpeed(val)
		local num = tonumber(val)
		if num then
			num = math.clamp(num, 5, 500)
			CustomFlyBaseSpeed = num
			CustomFlySpeed = num
			CustomFlyStrafeSpeed = math.round(num * 1.3)
			CustomFlyVerticalSpeed = math.round(num * 0.86)
			speedBox.Text = tostring(num)
		else
			speedBox.Text = tostring(CustomFlyBaseSpeed)
		end
	end

	speedBox.FocusLost:Connect(function()
		applySpeed(speedBox.Text)
	end)

	CustomFlyKeyConn = userInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or not MobileFlyActive then return end
		if input.KeyCode == Enum.KeyCode.F and userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			toggleFlyState()
		end
	end)

	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil

	mainCard.InputBegan:Connect(function(input)
		if CustomFlyLocked then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainCard.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	mainCard.InputChanged:Connect(function(input)
		if CustomFlyLocked then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	CustomFlyDragConn = userInputService.InputChanged:Connect(function(input)
		if CustomFlyLocked or not dragging or not MobileFlyActive then return end
		if input == dragInput then
			local delta = input.Position - dragStart
			mainCard.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	updateVisualState()

	CustomFlyRenderConn = runService.RenderStepped:Connect(function(dt)
		if not MobileFlyActive or not CustomFlyActive then return end
		local root, hum = getFlyRootAndHum()
		local cam = workspaceService.CurrentCamera
		if not root or not hum or not cam or not CustomFlyBodyGyro or not CustomFlyBodyVel then return end

		local moveDir = hum.MoveDirection
		local targetVel = Vector3.zero

		if moveDir.Magnitude > 0 then
			local forward = cam.CFrame.LookVector
			local flatForward = Vector3.new(forward.X, 0, forward.Z)
			if flatForward.Magnitude > 0 then flatForward = flatForward.Unit end

			local right = cam.CFrame.RightVector
			local flatRight = Vector3.new(right.X, 0, right.Z)
			if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end

			local forwardInput = moveDir:Dot(flatForward)
			local rightInput = moveDir:Dot(flatRight)

			local yVel = 0
			if forwardInput < -0.05 then
				local pullBackAmount = math.abs(forwardInput)
				local camLiftFactor = math.clamp(0.65 + math.max(forward.Y, 0), 0.65, 1.5)
				yVel = yVel + (pullBackAmount * CustomFlyVerticalSpeed * camLiftFactor)
			elseif forwardInput > 0.05 then
				yVel = yVel + (forward.Y * forwardInput * CustomFlyVerticalSpeed)
			end

			targetVel = (flatForward * forwardInput * CustomFlySpeed)
				+ (flatRight * rightInput * CustomFlyStrafeSpeed)
				+ Vector3.new(0, yVel, 0)
		end

		if hum.Jump then
			targetVel = targetVel + Vector3.new(0, CustomFlyVerticalSpeed, 0)
		end

		local alpha = math.clamp(dt * CustomFlySmoothness, 0, 1)
		CustomFlyCurrentVel = CustomFlyCurrentVel:Lerp(targetVel, alpha)
		CustomFlyBodyVel.Velocity = CustomFlyCurrentVel

		local lookFlat = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
		if lookFlat.Magnitude > 0.01 then
			local targetCFrame = CFrame.lookAt(root.Position, root.Position + lookFlat)
			CustomFlyBodyGyro.CFrame = CustomFlyBodyGyro.CFrame:Lerp(targetCFrame, math.clamp(dt * (CustomFlySmoothness * 1.2), 0, 1))
		end
	end)
end

local function SetMobileFly(state)
	MobileFlyActive = state
	if state then
		createCustomFlyGui()
	else
		destroyCustomFlyGui()
	end
end

--// =========================================================================
--// 1. HOME TAB
--// =========================================================================
local HomeTab = window:Tab({
	Title = "HOME",
	Icon = "home",
})

HomeTab:Section({ Title = "HOME", Icon = "home", Opened = true })

HomeTab:Image({
	Image = "https://raw.githubusercontent.com/ayanjaveed503-a11y/AYAN-HUB2/refs/heads/main/1795334480744.png",
	AspectRatio = "16:9",
	Radius = 9,
})

HomeTab:Space()

HomeTab:Section({
	Title = "👑 AYANUU HUB Client Universal 👑",
	TextSize = 24,
	FontWeight = Enum.FontWeight.SemiBold,
})

HomeTab:Space()

HomeTab:Paragraph({
	Title = "👑 AYANUU HUB 👑",
	Desc = "👑 MADE BY AYANUU 👑 | ID: ZM_AYANUU | INSTA ID: ",
	Icon = "crown",
})

HomeTab:Paragraph({
	Title = "STATUS",
	Desc = "AYANUU HUB LOADED & READY",
	Icon = "check-circle",
})

HomeTab:Space()

HomeTab:Section({
	Title = [[
👑AYANUU HUB👑, Multilingual and multifunctional client, offering a variety of options for you.
Developed by AYANUU 👑 ROBLOX ID: AYANUU160 INSTA ID:  ]],
	TextSize = 15,
	TextTransparency = 0.35,
	FontWeight = Enum.FontWeight.Medium,
})

--// =========================================================================
--// 2. TARGET TAB
--// =========================================================================
local TargetTab = window:Tab({
	Title = "TARGET",
	Icon = "crosshair",
})

TargetTab:Section({ Title = "Select Target", Icon = "user-check", Opened = true })

local SelectedTargetParagraph = TargetTab:Paragraph({
	Title = "SELECTED TARGET",
	Desc = "None (Type name or pick from dropdown)",
})

local function SetTargetPlayer(p)
	TargetPlayer = p
	if p then
		SelectedTargetParagraph:SetDesc("Target: " .. p.DisplayName .. " (@" .. p.Name .. ")")
	else
		SelectedTargetParagraph:SetDesc("None (Type name or pick from dropdown)")
	end
end

local function BuildPlayerValues()
	local list = {}
	for _, plr in ipairs(players:GetPlayers()) do
		if plr ~= localPlayer then
			table.insert(list, plr.Name)
		end
	end
	if #list == 0 then
		table.insert(list, "No player available")
	end
	return list
end

local TargetDropdown = TargetTab:Dropdown({
	Title = "SELECT PLAYER (DROPDOWN)",
	Values = BuildPlayerValues(),
	Value = BuildPlayerValues()[1],
	Callback = function(value)
		if not value or value == "No player available" then
			SetTargetPlayer(nil)
			return
		end
		local found = GetPlayer(value)
		SetTargetPlayer(found)
		if found then
			NotifyHub("TARGET SELECTED", "Target set to @" .. found.Name, 2, "user-check")
		end
	end,
})

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
	Icon = "navigation",
	Callback = function()
		PlayClickSound()
		if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
			localPlayer.Character.HumanoidRootPart.CFrame = TargetPlayer.Character.HumanoidRootPart.CFrame
		end
	end,
})

TargetTab:Toggle({
	Title = "FOLLOW",
	Desc = "Follow selected target player",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		Toggles.Follow = value
		if value then
			task.spawn(function()
				while Toggles.Follow and task.wait() do
					pcall(function()
						local myChar = localPlayer.Character
						local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
						local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
						local tHrp = TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
						if myHrp and tHrp then
							local followPos = (tHrp.CFrame * CFrame.new(0, 0, 3)).Position
							if myHum and myHum.MoveTo then
								myHum:MoveTo(followPos)
							end
							if (myHrp.Position - followPos).Magnitude > 14 then
								myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 3)
							end
						end
					end)
				end
			end)
		end
	end,
})

TargetTab:Section({ Title = "Preview & Visuals", Icon = "eye", Opened = true })

TargetTab:Toggle({
	Title = "VIEW TARGET",
	Desc = "Spectate target player",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		if value and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Humanoid") then
			workspaceService.CurrentCamera.CameraSubject = TargetPlayer.Character.Humanoid
		else
			if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
				workspaceService.CurrentCamera.CameraSubject = localPlayer.Character.Humanoid
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

TargetTab:Section({ Title = "Special Actions", Icon = "flame", Opened = true })

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
					localPlayer.Character.HumanoidRootPart.CFrame =
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
		if value then
			PlayTargetAnimation(105919095840646, math.clamp(BangSpeed, 0.5, 4))
			task.spawn(function()
				while Toggles.Bang and task.wait() do
					pcall(function()
						localPlayer.Character.HumanoidRootPart.CFrame =
							TargetPlayer.Character.HumanoidRootPart.CFrame *
							CFrame.new(0, 0, 1.1 + math.sin(tick() * (BangSpeed * 20)) * 0.8)
					end)
				end
				if not HasAnyActiveTargetAction() then
					StopTargetAnimation()
				end
			end)
		else
			if not HasAnyActiveTargetAction() then
				StopTargetAnimation()
			end
		end
	end,
})

TargetTab:Toggle({
	Title = "MOUTH BANG",
	Desc = "Mouth bang target",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		Toggles.MouthBang = value
		if value then
			PlayTargetAnimation(105919095840646, math.clamp(BangSpeed, 0.5, 4))
			task.spawn(function()
				while Toggles.MouthBang and task.wait() do
					pcall(function()
						localPlayer.Character.HumanoidRootPart.CFrame =
							TargetPlayer.Character.Head.CFrame *
							CFrame.new(0, 0.2, -1.2 - math.sin(tick() * (BangSpeed * 20)) * 0.8) *
							CFrame.Angles(0, math.pi, 0)
					end)
				end
				if not HasAnyActiveTargetAction() then
					StopTargetAnimation()
				end
			end)
		else
			if not HasAnyActiveTargetAction() then
				StopTargetAnimation()
			end
		end
	end,
})

TargetTab:Toggle({
	Title = "FRONT BANG",
	Desc = "Stand in front of target facing them",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		Toggles.FrontBang = value
		if value then
			PlayTargetAnimation(105919095840646, math.clamp(BangSpeed, 0.5, 4))
			task.spawn(function()
				while Toggles.FrontBang and task.wait() do
					pcall(function()
						localPlayer.Character.HumanoidRootPart.CFrame =
							TargetPlayer.Character.HumanoidRootPart.CFrame *
							CFrame.new(0, 0, -1.2 - math.sin(tick() * (BangSpeed * 20)) * 0.7) *
							CFrame.Angles(0, math.pi, 0)
					end)
				end
				if not HasAnyActiveTargetAction() then
					StopTargetAnimation()
				end
			end)
		else
			if not HasAnyActiveTargetAction() then
				StopTargetAnimation()
			end
		end
	end,
})

TargetTab:Toggle({
	Title = "SUCK",
	Desc = "Suck target",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		Toggles.Suck = value
		if value then
			PlayTargetAnimation(105919095840646, math.clamp(BangSpeed, 0.5, 4))
			task.spawn(function()
				while Toggles.Suck and task.wait() do
					pcall(function()
						localPlayer.Character.HumanoidRootPart.CFrame =
							TargetPlayer.Character.HumanoidRootPart.CFrame *
							CFrame.new(0, 0, -1.35) *
							CFrame.Angles(0, 0, 0)
					end)
				end
				if not HasAnyActiveTargetAction() then
					StopTargetAnimation()
				end
			end)
		else
			if not HasAnyActiveTargetAction() then
				StopTargetAnimation()
			end
		end
	end,
})

TargetTab:Toggle({
	Title = "MOUTH SUCK",
	Desc = "Stand in front facing target",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		Toggles.MouthSuck = value
		if value then
			PlayTargetAnimation(105919095840646, math.clamp(BangSpeed, 0.5, 4))
			task.spawn(function()
				while Toggles.MouthSuck and task.wait() do
					pcall(function()
						localPlayer.Character.HumanoidRootPart.CFrame =
							TargetPlayer.Character.HumanoidRootPart.CFrame *
							CFrame.new(0, 0, -1.15 - math.sin(tick() * (BangSpeed * 16)) * 0.15) *
							CFrame.Angles(0, math.pi, 0)
					end)
				end
				if not HasAnyActiveTargetAction() then
					StopTargetAnimation()
				end
			end)
		else
			if not HasAnyActiveTargetAction() then
				StopTargetAnimation()
			end
		end
	end,
})

TargetTab:Button({
	Title = "COPY HUG / UFO ANIM ID 📋",
	Desc = "Copy custom ID: " .. CustomHugUfoAnimId,
	Icon = "copy",
	Callback = function()
		PlayClickSound()
		local ok = CopyTextToClipboard(CustomHugUfoAnimId)
		if ok then
			NotifyHub("COPIED ID 📋", "Copied animation ID: " .. CustomHugUfoAnimId, 2, "check")
		else
			NotifyHub("ANIMATION ID 📋", CustomHugUfoAnimId, 3, "copy")
		end
	end,
})

TargetTab:Input({
	Title = "HUG & UFO CUSTOM ANIM ID",
	Desc = "Paste or enter ID for HUG & UFO",
	Placeholder = "88712283515515",
	Callback = function(value)
		CustomHugUfoAnimId = CleanAnimId(value, "88712283515515")
		if HasAnyActiveTargetAction() and (Toggles.Hug or Toggles.Ufo) then
			PlayTargetAnimation(CustomHugUfoAnimId, math.clamp(BangSpeed, 0.5, 3))
		end
	end,
})

TargetTab:Toggle({
	Title = "HUG",
	Desc = "Hug close to target with custom ID",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		Toggles.Hug = value
		if value then
			local chosenId = CleanAnimId(CustomHugUfoAnimId, "88712283515515")
			PlayTargetAnimation(chosenId, math.clamp(BangSpeed, 0.5, 3))
			task.spawn(function()
				while Toggles.Hug and task.wait() do
					pcall(function()
						localPlayer.Character.HumanoidRootPart.CFrame =
							TargetPlayer.Character.HumanoidRootPart.CFrame *
							CFrame.new(0, 0, -1.25) *
							CFrame.Angles(0, math.pi, 0)
					end)
				end
				if not HasAnyActiveTargetAction() then
					StopTargetAnimation()
				end
			end)
		else
			if not HasAnyActiveTargetAction() then
				StopTargetAnimation()
			end
		end
	end,
})

TargetTab:Toggle({
	Title = "UFO",
	Desc = "Hover over target head with custom ID",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		Toggles.Ufo = value
		if value then
			local chosenId = CleanAnimId(CustomHugUfoAnimId, "91775556867736")
			PlayTargetAnimation(chosenId, math.clamp(BangSpeed, 0.5, 3))
			task.spawn(function()
				while Toggles.Ufo and task.wait() do
					pcall(function()
						local tChar = TargetPlayer and TargetPlayer.Character
						local anchorPart = tChar and (tChar:FindFirstChild("Head") or tChar:FindFirstChild("HumanoidRootPart"))
						local myHrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
						if anchorPart and myHrp then
							myHrp.CFrame = anchorPart.CFrame * CFrame.new(0, 2.2, 0)
						end
					end)
				end
				if not HasAnyActiveTargetAction() then
					StopTargetAnimation()
				end
			end)
		else
			if not HasAnyActiveTargetAction() then
				StopTargetAnimation()
			end
		end
	end,
})

TargetTab:Toggle({
	Title = "TARGET JERK",
	Desc = "Stand back in front of target and toggle Jerk ON/OFF",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		Toggles.TargetJerk = value
		if value then
			task.spawn(function()
				local jerkTrack = nil
				local function clearJerkTrack()
					if jerkTrack then
						pcall(function() jerkTrack:Stop() end)
						jerkTrack = nil
					end
				end

				while Toggles.TargetJerk and task.wait() do
					pcall(function()
						local myChar = localPlayer.Character
						local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
						local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
						local tHrp = TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart")

						if myHrp and tHrp then
							myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, -1.85) * CFrame.Angles(0, math.pi, 0)
						end

						if myHum then
							local isR15 = IsR15Character(localPlayer)
							local expectedId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653"
							if not jerkTrack or jerkTrack.Animation.AnimationId ~= expectedId then
								clearJerkTrack()
								local anim = Instance.new("Animation")
								anim.AnimationId = expectedId
								jerkTrack = myHum:LoadAnimation(anim)
							end

							jerkTrack:Play()
							jerkTrack:AdjustSpeed(isR15 and 0.7 or 0.65)
							jerkTrack.TimePosition = 0.6
							task.wait(0.1)
							while Toggles.TargetJerk and jerkTrack and jerkTrack.TimePosition < (not isR15 and 0.65 or 0.7) do
								pcall(function()
									local c = localPlayer.Character
									local r = c and c:FindFirstChild("HumanoidRootPart")
									local tr = TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
									if r and tr then
										r.CFrame = tr.CFrame * CFrame.new(0, 0, -1.85) * CFrame.Angles(0, math.pi, 0)
									end
								end)
								task.wait(0.05)
							end
							clearJerkTrack()
						end
					end)
				end
				clearJerkTrack()
			end)
		end
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
					localPlayer.Character.HumanoidRootPart.CFrame =
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
					localPlayer.Character.HumanoidRootPart.CFrame =
						TargetPlayer.Character.Head.CFrame *
						CFrame.new(0, 0.4, -0.2 - math.sin(tick() * (BangSpeed * 25)) * 0.5) *
						CFrame.Angles(0, math.pi, 0)
				end)
			end
		end)
	end,
})

players.PlayerAdded:Connect(function()
	task.wait(0.2)
	pcall(function()
		if TargetDropdown and TargetDropdown.Refresh then
			TargetDropdown:Refresh(BuildPlayerValues())
		end
	end)
end)

players.PlayerRemoving:Connect(function(p)
	if TargetPlayer == p then
		SetTargetPlayer(nil)
	end
	pcall(function()
		if TargetDropdown and TargetDropdown.Refresh then
			TargetDropdown:Refresh(BuildPlayerValues())
		end
	end)
end)

--// =========================================================================
--// 3. PLAYER TAB
--// =========================================================================
local PlayerTab = window:Tab({
	Title = "PLAYER",
	Icon = "user",
})

PlayerTab:Section({ Title = "Player", Icon = "user", Opened = true })

PlayerTab:Slider({
	Title = "SPEED",
	Step = 1,
	Value = { Min = 1, Max = 500, Default = 16 },
	Callback = function(value)
		CustomSpeed = value
		pcall(function()
			local hum = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
			if hum then
				hum.WalkSpeed = CustomSpeed
			end
		end)
	end,
})

PlayerTab:Slider({
	Title = "JUMP POWER",
	Step = 1,
	Value = { Min = 1, Max = 500, Default = 50 },
	Callback = function(value)
		CustomJumpPower = value
		pcall(function()
			local hum = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
			if hum then
				hum.UseJumpPower = true
				hum.JumpPower = CustomJumpPower
			end
		end)
	end,
})

PlayerTab:Slider({
	Title = "GRAVITY",
	Step = 1,
	Value = { Min = 1, Max = 500, Default = 196 },
	Callback = function(value)
		workspaceService.Gravity = value
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
			InfJumpConnection = userInputService.JumpRequest:Connect(function()
				if Toggles.InfJump and localPlayer.Character then
					local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
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
			NoclipConnection = runService.Stepped:Connect(function()
				if Toggles.Noclip and localPlayer.Character then
					for _, part in pairs(localPlayer.Character:GetDescendants()) do
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
	Title = "FLY ON/OFF",
	Desc = "Show/Hide custom Fly GUI (Shift + F)",
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

local ResetPlayerBtn
ResetPlayerBtn = PlayerTab:Button({
	Title = "RESET VALUES",
	Icon = "chevron-right",
	Callback = function()
		PlayClickSound()
		CustomSpeed = 16
		CustomJumpPower = 50
		pcall(function()
			local hum = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
			if hum then
				hum.WalkSpeed = 16
				hum.JumpPower = 50
			end
		end)
		workspaceService.Gravity = 196.2
		Toggles.InfJump = false
		if ResetPlayerBtn and ResetPlayerBtn.Highlight then
			ResetPlayerBtn:Highlight()
		end
	end,
})

PlayerTab:Section({ Title = "Change FOV", Icon = "eye", Opened = false })

PlayerTab:Input({
	Title = "FOV PLAYER",
	Desc = "Change the fov",
	Placeholder = "70",
	Callback = function(value)
		fovPlayer = tonumber(value) or 70
	end,
})

PlayerTab:Button({
	Title = "ADJUST FOV",
	Icon = "chevron-right",
	Callback = function()
		PlayClickSound()
		local currentCamera = workspaceService.CurrentCamera
		if currentCamera and typeof(fovPlayer) == "number" then
			currentCamera.FieldOfView = fovPlayer
		end
	end,
})

--// =========================================================================
--// 4. SHIELD TAB
--// =========================================================================
local ShieldTab = window:Tab({
	Title = "SHIELD",
	Icon = "shield",
})

ShieldTab:Section({ Title = "Shield & Fling", Icon = "shield", Opened = true })

ShieldTab:Toggle({
	Title = "SAFE SPOT",
	Desc = "Create safe spot baseplate & toggle TP / BACK button",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		local player = game:GetService("Players").LocalPlayer
		local UserInputService = game:GetService("UserInputService")

		if value then
			local teleportPosition = Vector3.new(5000, 1000, 5000)
			local baseplateSize = Vector3.new(100, 1, 100)
			local baseplatePosition = teleportPosition - Vector3.new(0, 5, 0)

			SafeSpotBaseplate = Instance.new("Part")
			SafeSpotBaseplate.Size = baseplateSize
			SafeSpotBaseplate.Position = baseplatePosition
			SafeSpotBaseplate.Anchored = true
			SafeSpotBaseplate.BrickColor = BrickColor.new("Earth green")
			SafeSpotBaseplate.Parent = workspace

			local playerGui = player:WaitForChild("PlayerGui")
			SafeSpotGui = Instance.new("ScreenGui")
			SafeSpotGui.Name = "TeleportGui"
			SafeSpotGui.ResetOnSpawn = false
			SafeSpotGui.Parent = playerGui

			local teleportButton = Instance.new("TextButton")
			teleportButton.Size = UDim2.new(0, 50, 0, 50)
			teleportButton.Position = UDim2.new(0, 150, 0, 10)
			teleportButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
			teleportButton.Text = "TP"
			teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			teleportButton.Font = Enum.Font.GothamBold
			teleportButton.TextSize = 20
			teleportButton.Parent = SafeSpotGui

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 8)
			corner.Parent = teleportButton

			local dragging, dragInput, dragStart, startPos

			teleportButton.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					dragStart = input.Position
					startPos = teleportButton.Position

					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
						end
					end)
				end
			end)

			teleportButton.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					dragInput = input
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if input == dragInput and dragging then
					local delta = input.Position - dragStart
					teleportButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				end
			end)

			teleportButton.MouseButton1Click:Connect(function()
				if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					local humanoidRootPart = player.Character.HumanoidRootPart

					if not teleported then
						originalPosition = humanoidRootPart.Position
						humanoidRootPart.CFrame = CFrame.new(teleportPosition)
						teleported = true
						teleportButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
						teleportButton.Text = "BACK"
					else
						if originalPosition then
							humanoidRootPart.CFrame = CFrame.new(originalPosition)
						end
						teleported = false
						teleportButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
						teleportButton.Text = "TP"
					end
				end
			end)
		else
			if SafeSpotGui then
				SafeSpotGui:Destroy()
				SafeSpotGui = nil
			end
			if SafeSpotBaseplate then
				SafeSpotBaseplate:Destroy()
				SafeSpotBaseplate = nil
			end

			if teleported and player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				if originalPosition then
					player.Character.HumanoidRootPart.CFrame = CFrame.new(originalPosition)
				end
				teleported = false
			end
		end
	end,
})

ShieldTab:Button({
	Title = "OP MULTI FLING GUI 💀",
	Desc = "Click to activate the Ultimate Multi Fling Panel!",
	Icon = "wind",
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
		task.spawn(function()
			while Toggles.AntiSit and task.wait() do
				pcall(function()
					localPlayer.Character.Humanoid.Sit = true
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
			WalkingFlingConnection = runService.Heartbeat:Connect(function()
				pcall(function()
					if not Toggles.WalkingFling then return end
					for _, player in pairs(players:GetPlayers()) do
						if player ~= localPlayer and player.Character then
							for _, part in pairs(player.Character:GetDescendants()) do
								if part:IsA("BasePart") then
									part.CanCollide = false
								end
							end
						end
					end

					local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
					if hrp then
						local oldV = hrp.Velocity
						hrp.Velocity = Vector3.new(100000, 100000, 100000)
						runService.RenderStepped:Wait()
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

--// =========================================================================
--// 5. ANTIBANG TAB
--// =========================================================================
local AntiBangTab = window:Tab({
	Title = "ANTIBANG",
	Icon = "shield-alert",
})

AntiBangTab:Section({ Title = "AntiBang Scripts", Icon = "shield-alert", Opened = true })

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
					local hrp = localPlayer.Character.HumanoidRootPart
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

local AntiBangList = {
	{ Title = "BEST ANTIBANG", Desc = "Execute AntiBang script 1", Url = "https://pastebin.com/raw/80Nva2Fj" },
	{ Title = "ONECLICK ANTIBANG", Desc = "Execute AntiBang script 2", Url = "https://scriptblox.com/raw/Universal-Script-Anti-Bang-48256" },
	{ Title = "ANTIBANG LOADSTRING 3", Desc = "Execute AntiBang script 3", Url = "https://raw.githubusercontent.com/your-username/antibang3/main/script.lua" },
	{ Title = "ANTIBANG LOADSTRING 4", Desc = "Execute AntiBang script 4", Url = "https://raw.githubusercontent.com/your-username/antibang4/main/script.lua" },
	{ Title = "ANTIBANG LOADSTRING 5", Desc = "Execute AntiBang script 5", Url = "https://raw.githubusercontent.com/your-username/antibang5/main/script.lua" },
}

for _, item in ipairs(AntiBangList) do
	AntiBangTab:Button({
		Title = item.Title,
		Desc = item.Desc,
		Icon = "shield-alert",
		Callback = function()
			PlayClickSound()
			loadstring(game:HttpGet(item.Url))()
		end,
	})
end

--// =========================================================================
--// 6. BANG TAB
--// =========================================================================
local BangTab = window:Tab({
	Title = "BANG",
	Icon = "flame",
})

BangTab:Section({ Title = "Bang Scripts", Icon = "flame", Opened = true })

local BangScriptList = {
	{ Title = "BACK BANG", Desc = "Execute Bang script 1", Url = "https://raw.githubusercontent.com/ayanjaveed503-a11y/All-Resources/refs/heads/main/Bang.lua" },
	{ Title = "MOUTH BANG", Desc = "Execute Bang script 2", Url = "https://raw.githubusercontent.com/ayanjaveed503-a11y/All-Resources/refs/heads/main/mouthbang.lua" },
	{ Title = "MULTI BANG", Desc = "Execute Bang script 3", Url = "https://raw.githubusercontent.com/ayanjaveed503-a11y/All-Resources/refs/heads/main/Multi%20bang.lua" },
	{ Title = "UNLIMITED TARGET BANG", Desc = "Execute Bang script 4", Url = "https://raw.githubusercontent.com/ayanjaveed503-a11y/All-Resources/refs/heads/main/Unlimited%20target%20bang.lua" },
	{ Title = "BANG LOADSTRING 5", Desc = "Execute Bang script 5", Url = "https://raw.githubusercontent.com/your-username/bang5/main/script.lua" },
	{ Title = "BANG LOADSTRING 6", Desc = "Execute Bang script 6", Url = "https://raw.githubusercontent.com/your-username/bang6/main/script.lua" },
}

for _, bangItem in ipairs(BangScriptList) do
	BangTab:Button({
		Title = bangItem.Title,
		Desc = bangItem.Desc,
		Icon = "flame",
		Callback = function()
			PlayClickSound()
			loadstring(game:HttpGet(bangItem.Url))()
		end,
	})
end

--// =========================================================================
--// 7. EMOTE TAB
--// =========================================================================
local EmoteTab = window:Tab({
	Title = "EMOTE",
	Icon = "sparkles",
})

EmoteTab:Section({ Title = "Emote Scripts", Icon = "sparkles", Opened = true })

local EmoteList = {
	{ Title = "GAZE EMOTE", Desc = "Execute Emote script 1", Url = "https://raw.githubusercontent.com/Gazer-Ha/Gaze-stuff/refs/heads/main/Gaze%20emote" },
	{ Title = "EMOTE LOADSTRING 2", Desc = "Execute Emote script 2", Url = "https://raw.githubusercontent.com/your-username/emote2/main/script.lua" },
	{ Title = "EMOTE LOADSTRING 3", Desc = "Execute Emote script 3", Url = "https://raw.githubusercontent.com/your-username/emote3/main/script.lua" },
	{ Title = "EMOTE LOADSTRING 4", Desc = "Execute Emote script 4", Url = "https://raw.githubusercontent.com/your-username/emote4/main/script.lua" },
	{ Title = "EMOTE LOADSTRING 5", Desc = "Execute Emote script 5", Url = "https://raw.githubusercontent.com/your-username/emote5/main/script.lua" },
}

for _, item in ipairs(EmoteList) do
	EmoteTab:Button({
		Title = item.Title,
		Desc = item.Desc,
		Icon = "sparkles",
		Callback = function()
			PlayClickSound()
			loadstring(game:HttpGet(item.Url))()
		end,
	})
end

--// =========================================================================
--// 8. ALL SPAMMER TAB
--// =========================================================================
local AllSpammerTab = window:Tab({
	Title = "ALL SPAMMER",
	Icon = "message-square",
})

AllSpammerTab:Section({ Title = "All Spammer Scripts", Icon = "message-square", Opened = true })

local SpammerList = {
	{ Title = "AYANUU SPAMMER", Desc = "Execute Spammer script 1", Url = "https://raw.githubusercontent.com/ayanjaveed503-a11y/EVERYONE-SCRIPT/refs/heads/main/AYAN%20SPAMMER" },
	{ Title = "BUNNY SPAMMER", Desc = "Execute Spammer script 2", Url = "https://raw.githubusercontent.com/ayanjaveed503-a11y/AYAN-SPAM/refs/heads/main/" },
	{ Title = "TALHA SPAMMER", Desc = "Execute Spammer script 3", Url = "https://raw.githubusercontent.com/ayanjaveed503-a11y/AYAN-SPAM/refs/heads/main/TALHA%20SPAMMER.lua" },
	{ Title = "MEHDI SPAMMER", Desc = "Execute Spammer script 4", Url = "https://raw.githubusercontent.com/ayanjaveed503-a11y/EVERYONE-SCRIPT/refs/heads/main/MEHDI%20SPAM.txt" },
	{ Title = "ARHAN SPAMMER", Desc = "Execute Spammer script 5", Url = "https://raw.githubusercontent.com/ayanjaveed503-a11y/EVERYONE-SCRIPT/refs/heads/main/ARHAN%20SPAM.txt" },
	{ Title = "SAMRAT SPAMMER", Desc = "Execute Spammer script 6", Url = "https://raw.githubusercontent.com/ayanjaveed503-a11y/EVERYONE-SCRIPT/refs/heads/main/SAMRAT%20SPAM.txt" },
	{ Title = "TRIO SPAMMER", Desc = "Execute Spammer script 7", Url = "https://raw.githubusercontent.com/ayanjaveed503-a11y/EVERYONE-SCRIPT/refs/heads/main/TRIO%20SPAM%20.txt" },
	{ Title = "MIKEY SPAMMER", Desc = "Execute Spammer script 8", Url = "https://raw.githubusercontent.com/MuddyyXScripts/MIKEY-SPAMMER-V1/refs/heads/main/ObfuscatedByMonKFuscate.luau%20(5).txt" },
	{ Title = "BUNNY SPAMMER 2", Desc = "Execute Spammer script 9", Url = "https://raw.githubusercontent.com/ayanjaveed503-a11y/AYAN-SPAM/refs/heads/main/BUNNY%20SPAM.txt" },
	{ Title = "SPAMMER LOADSTRING 10", Desc = "Execute Spammer script 10", Url = "https://raw.githubusercontent.com/your-username/spammer10/main/script.lua" },
	{ Title = "SPAMMER LOADSTRING 11", Desc = "Execute Spammer script 11", Url = "https://raw.githubusercontent.com/your-username/spammer11/main/script.lua" },
	{ Title = "SPAMMER LOADSTRING 12", Desc = "Execute Spammer script 12", Url = "https://raw.githubusercontent.com/your-username/spammer12/main/script.lua" },
	{ Title = "SPAMMER LOADSTRING 13", Desc = "Execute Spammer script 13", Url = "https://raw.githubusercontent.com/your-username/spammer13/main/script.lua" },
	{ Title = "SPAMMER LOADSTRING 14", Desc = "Execute Spammer script 14", Url = "https://raw.githubusercontent.com/your-username/spammer14/main/script.lua" },
	{ Title = "SPAMMER LOADSTRING 15", Desc = "Execute Spammer script 15", Url = "https://raw.githubusercontent.com/your-username/spammer15/main/script.lua" },
}

for _, item in ipairs(SpammerList) do
	AllSpammerTab:Button({
		Title = item.Title,
		Desc = item.Desc,
		Icon = "message-square",
		Callback = function()
			PlayClickSound()
			loadstring(game:HttpGet(item.Url))()
		end,
	})
end

--// =========================================================================
--// 9. SCRIPT TAB
--// =========================================================================
local ScriptTab = window:Tab({
	Title = "SCRIPT",
	Icon = "code",
})

ScriptTab:Section({ Title = "Universal Scripts", Icon = "code", Opened = true })

local ScriptList = {
	{ Title = "ZAYN CHAT", Desc = "Execute Script 1", Url = "https://raw.githubusercontent.com/ZaynBoss01/ZAYN/refs/heads/main/Zayn-Roblox" },
	{ Title = "GLOBAL CHAT", Desc = "Execute Script 2", Url = "https://gist.githubusercontent.com/josh19mark-sys/276fd3c0ad985fe2476f6ce333b4354f/raw/a29997b49f6279e3c0a2564737bb020e7a885cb6/gistfile1.txt" },
	{ Title = "SONG PLAYER", Desc = "Execute Script 3", Url = "https://api.aurorax.site/files/v5/loaders/fdc766682032eea1cd25a1b7a976d621" },
	{ Title = "SCRIPT LOADSTRING 4", Desc = "Execute Script 4", Url = "https://raw.githubusercontent.com/your-username/script4/main/script.lua" },
	{ Title = "SCRIPT LOADSTRING 5", Desc = "Execute Script 5", Url = "https://raw.githubusercontent.com/your-username/script5/main/script.lua" },
	{ Title = "SCRIPT LOADSTRING 6", Desc = "Execute Script 6", Url = "https://raw.githubusercontent.com/your-username/script6/main/script.lua" },
	{ Title = "SCRIPT LOADSTRING 7", Desc = "Execute Script 7", Url = "https://raw.githubusercontent.com/your-username/script7/main/script.lua" },
	{ Title = "SCRIPT LOADSTRING 8", Desc = "Execute Script 8", Url = "https://raw.githubusercontent.com/your-username/script8/main/script.lua" },
	{ Title = "SCRIPT LOADSTRING 9", Desc = "Execute Script 9", Url = "https://raw.githubusercontent.com/your-username/script9/main/script.lua" },
	{ Title = "SCRIPT LOADSTRING 10", Desc = "Execute Script 10", Url = "https://raw.githubusercontent.com/your-username/script10/main/script.lua" },
}

for _, item in ipairs(ScriptList) do
	ScriptTab:Button({
		Title = item.Title,
		Desc = item.Desc,
		Icon = "code",
		Callback = function()
			PlayClickSound()
			loadstring(game:HttpGet(item.Url))()
		end,
	})
end

--// =========================================================================
--// 10. LIFE TOGETHER TAB (PASSWORD 9900)
--// =========================================================================
local LifeTogetherTab = window:Tab({
	Title = "LIFE TOGETHER 🔒",
	Icon = "lock",
})

LifeTogetherTab:Section({ Title = "Life Together (Locked)", Icon = "lock", Opened = true })

local TabPassword = "8899"
local EnteredPassword = ""
local IsUnlocked = false

local LockInfo = LifeTogetherTab:Paragraph({
	Title = "🔒 LIFE TOGETHER LOCKED",
	Desc = "Enter password below to unlock Life Together scripts.",
})

local PassInput = LifeTogetherTab:Input({
	Title = "ENTER PASSWORD",
	Desc = "Type to unlock",
	Placeholder = "Password...",
	Callback = function(value)
		EnteredPassword = value
	end,
})

local UnlockBtn
UnlockBtn = LifeTogetherTab:Button({
	Title = "UNLOCK TAB 🔓",
	Desc = "Verify password",
	Icon = "key-round",
	Callback = function()
		PlayClickSound()
		if IsUnlocked then return end

		if EnteredPassword == TabPassword then
			IsUnlocked = true
			NotifyHub("AYANUU HUB 👑", "Life Together Unlocked!", 3, "unlock")

			pcall(function()
				LockInfo:Destroy()
				PassInput:Destroy()
				UnlockBtn:Destroy()
			end)

			LifeTogetherTab:Button({
				Title = "AYANUU PREMIUM OUTFIT COPIER ",
				Desc = "Click to open the outfit copier GUI",
				Icon = "sparkles",
				Callback = function()
					PlayClickSound()
					loadstring(game:HttpGet(("https://raw.githubusercontent.com/ayanjaveed503-a11y/AYAN-OUTFIT-STEALER/refs/heads/main/AYAN%20OUTFIT%20STEALER%20TESTING"), true))()
				end,
			})

			LifeTogetherTab:Button({
				Title = "AYANUU OUTFIT MANAGER",
				Desc = "Click to open",
				Icon = "sparkles",
				Callback = function()
					PlayClickSound()
					loadstring(game:HttpGet(("https://raw.githubusercontent.com/ayanjaveed503-a11y/AYAN-OUTFIT-STEALER/refs/heads/main/OUTFIT%20MANAGER"), true))()
				end,
			})

			LifeTogetherTab:Button({
				Title = "COVER MAP",
				Desc = "Click to open ",
				Icon = "sparkles",
				Callback = function()
					PlayClickSound()
					loadstring(game:HttpGet(("https://raw.githubusercontent.com/MANASMCPE/AUTH0R/refs/heads/main/mapCover.lua"), true))()
				end,
			})

			LifeTogetherTab:Button({
				Title = "MAP DESTROYER-code",
				Desc = "Click to open",
				Icon = "sparkles",
				Callback = function()
					PlayClickSound()
					loadstring(game:HttpGet(("https://raw.githubusercontent.com/ayanjaveed503-a11y/MAP-DESTROYER-/refs/heads/main/MAP%20DESTROYER.LUA"), true))()
				end,
			})

			LifeTogetherTab:Button({
				Title = "PLAYER RESIZE",
				Desc = "Click to open ",
				Icon = "sparkles",
				Callback = function()
					PlayClickSound()
					loadstring(game:HttpGet(("https://raw.githubusercontent.com/MANASMCPE/AUTH0R/refs/heads/main/size-resizer.lua"), true))()
				end,
			})

			LifeTogetherTab:Button({
				Title = "TRAP CHAIR",
				Desc = "Click to open ",
				Icon = "sparkles",
				Callback = function()
					PlayClickSound()
					loadstring(game:HttpGet(("https://raw.githubusercontent.com/ayanjaveed503-a11y/AYAN-HUB-TRAP-CHAIds/main/AYAN%20HUB%20TRAP%20CHAIR"), true))()
				end,
			})
		else
			NotifyHub("WRONG PASSWORD ❌", "Incorrect password! Try again.", 3, "x-circle")
		end
	end,
})

--// =========================================================================
--// 11. THEME TAB
--// =========================================================================
local ThemeTab = window:Tab({
	Title = "THEME",
	Icon = "palette",
})

ThemeTab:Section({ Title = "Theme & Accent Color", Icon = "palette", Opened = true })

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
		Icon = "palette",
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

--// =========================================================================
--// 12. FEEDBACK TAB
--// =========================================================================
local FeedbackTab = window:Tab({
	Title = "FEEDBACK",
	Icon = "message-circle",
})

FeedbackTab:Section({ Title = "Feedback", Icon = "message-circle", Opened = true })

FeedbackTab:Button({
	Title = "FEEDBACK soon",
	Desc = "Open feedback script",
	Icon = "message-circle",
	Callback = function()
		PlayClickSound()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/feedback/main/script.lua"))()
	end,
})

--// =========================================================================
--// 13. GAME SCRIPT TAB
--// =========================================================================
local GameScriptTab = window:Tab({
	Title = "GAME SCRIPT",
	Icon = "gamepad-2",
})

GameScriptTab:Section({ Title = "Game Scripts", Icon = "gamepad-2", Opened = true })

local GameScripts = {
	{ Title = "RIVALS SCRIPT", Desc = "Load Rivals script", Url = "https://raw.githubusercontent.com/your-username/rivals-script/main/script.lua" },
	{ Title = "LIFE TOGETHER SCRIPT", Desc = "Load Life Together script", Url = "https://raw.githubusercontent.com/your-username/life-together-script/main/script.lua" },
	{ Title = "FREE FIRE / UNIVERSAL SCRIPT", Desc = "Load game script", Url = "https://raw.githubusercontent.com/your-username/game-script-3/main/script.lua" },
	{ Title = "EXTRA GAME SCRIPT 4", Desc = "Load extra game script", Url = "https://raw.githubusercontent.com/your-username/game-script-4/main/script.lua" },
}

for _, item in ipairs(GameScripts) do
	GameScriptTab:Button({
		Title = item.Title,
		Desc = item.Desc,
		Icon = "gamepad-2",
		Callback = function()
			PlayClickSound()
			loadstring(game:HttpGet(item.Url))()
		end,
	})
end

--// =========================================================================
--// 14. FPS TAB
--// =========================================================================
local FpsTab = window:Tab({
	Title = "FPS",
	Icon = "zap",
})

FpsTab:Section({ Title = "FPS & Antilag", Icon = "zap", Opened = true })

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
	Icon = "refresh-cw",
	Callback = function()
		PlayClickSound()
		UpdateFpsDisplay()
	end,
})

FpsTab:Button({
	Title = "ULTRA ANTILAG+ANTIFIRE",
	Desc = "Execute FPS boost script 1",
	Icon = "zap",
	Callback = function()
		PlayClickSound()
		loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Extra-Antilag-(Open-source)-229552"))()
	end,
})

FpsTab:Button({
	Title = "ANTILAG",
	Desc = "Execute FPS boost script 2",
	Icon = "zap",
	Callback = function()
		PlayClickSound()
		loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Antilag-by-DaMieN-172219"))()
	end,
})

FpsTab:Button({
	Title = "FPS BOOSTER",
	Desc = "Execute FPS boost script 3",
	Icon = "zap",
	Callback = function()
		PlayClickSound()
		loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Optiz-FpsBooster-60070"))()
	end,
})

task.spawn(function()
	while window do
		UpdateFpsDisplay()
		task.wait(0.5)
	end
end)

--// =========================================================================
--// 15. PLAYERTIME TAB
--// =========================================================================
local PlayerTimeTab = window:Tab({
	Title = "PLAYERTIME",
	Icon = "clock",
})

PlayerTimeTab:Section({ Title = "Server Playtime", Icon = "clock", Opened = true })

local PlayerTimeParagraph = PlayerTimeTab:Paragraph({
	Title = "SERVER PLAYTIME",
	Desc = "Loading player times...",
})

local function RefreshPlaytimeDisplay()
	local list = players:GetPlayers()
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
	Icon = "clock",
	Callback = function()
		PlayClickSound()
		RefreshPlaytimeDisplay()
	end,
})

RefreshPlaytimeDisplay()

task.spawn(function()
	while window do
		RefreshPlaytimeDisplay()
		task.wait(1)
	end
end)

--// =========================================================================
--// 16. TELEPORT TAB
--// =========================================================================
local TeleportTab = window:Tab({
	Title = "TELEPORT",
	Icon = "map-pin",
})

TeleportTab:Section({ Title = "Teleport Mode", Icon = "zap", Opened = true })

local TeleportModeParagraph = TeleportTab:Paragraph({
	Title = "TELEPORT MODE",
	Desc = "⚡ Instant",
})

TeleportTab:Button({
	Title = "SWITCH TELEPORT MODE",
	Desc = "Switch between Instant and Smooth teleport",
	Icon = "repeat",
	Callback = function()
		PlayClickSound()
		if TeleportMode == "Instant" then
			TeleportMode = "Smooth"
			TeleportModeParagraph:SetDesc("🌊 Smooth")
		else
			TeleportMode = "Instant"
			TeleportModeParagraph:SetDesc("⚡ Instant")
		end
		NotifyHub("TELEPORT MODE", "Mode switched to " .. TeleportMode, 2, "zap")
	end,
})

TeleportTab:Section({ Title = "Saved Locations", Icon = "bookmark", Opened = true })

local LocationNameInputValue = ""

TeleportTab:Input({
	Title = "SAVE CURRENT LOCATION",
	Desc = "Enter location name",
	Placeholder = "Location name...",
	Callback = function(value)
		LocationNameInputValue = tostring(value or "")
	end,
})

local SavedLocationsParagraph = TeleportTab:Paragraph({
	Title = "SAVED LOCATIONS (0 📌)",
	Desc = "No saved locations yet.",
})

local SavedLocationButtons = {}

local function RefreshSavedLocationsUI()
	SavedLocationsParagraph:SetTitle("SAVED LOCATIONS (" .. tostring(#SavedLocations) .. " 📌)")
	for _, btn in ipairs(SavedLocationButtons) do
		pcall(function() btn:Destroy() end)
	end
	SavedLocationButtons = {}

	if #SavedLocations == 0 then
		SavedLocationsParagraph:SetDesc("No saved locations yet.")
		return
	end

	local summaryLines = {}
	for idx, loc in ipairs(SavedLocations) do
		table.insert(summaryLines, string.format("%d. %s", idx, loc.Name))
		local goBtn = TeleportTab:Button({
			Title = "TP: " .. loc.Name,
			Desc = "Teleport to saved location",
			Icon = "navigation",
			Callback = function()
				PlayClickSound()
				TeleportCharacterToCFrame(loc.CFrame)
				NotifyHub("TELEPORTED 📍", "Went to " .. loc.Name, 2, "navigation")
			end,
		})
		table.insert(SavedLocationButtons, goBtn)
	end
	SavedLocationsParagraph:SetDesc(table.concat(summaryLines, "\n"))
end

TeleportTab:Button({
	Title = "SAVE LOCATION 💾",
	Desc = "Save your current position",
	Icon = "save",
	Callback = function()
		PlayClickSound()
		local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then
			NotifyHub("ERROR ⚠️", "Character root not found!", 2, "alert-triangle")
			return
		end

		local locName = LocationNameInputValue:gsub("^%s+", ""):gsub("%s+$", "")
		if locName == "" then
			locName = "Location " .. tostring(#SavedLocations + 1)
		end

		table.insert(SavedLocations, {
			Name = locName,
			CFrame = hrp.CFrame,
		})
		RefreshSavedLocationsUI()
		NotifyHub("LOCATION SAVED 📌", "Saved '" .. locName .. "'", 2, "bookmark")
	end,
})

TeleportTab:Section({ Title = "Checkpoint", Icon = "flag", Opened = true })

local CheckpointStatusParagraph = TeleportTab:Paragraph({
	Title = "CHECKPOINT STATUS",
	Desc = "No checkpoint saved",
})

TeleportTab:Button({
	Title = "SAVE CHECKPOINT 💾",
	Desc = "Save respawn checkpoint at current position",
	Icon = "save",
	Callback = function()
		PlayClickSound()
		local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			CheckpointCFrame = hrp.CFrame
			CheckpointStatusParagraph:SetDesc("Checkpoint saved at current position ✅")
			NotifyHub("CHECKPOINT SAVED 💾", "Checkpoint set!", 2, "flag")
		end
	end,
})

TeleportTab:Toggle({
	Title = "AUTO RESPAWN AT CHECKPOINT",
	Desc = "Automatically teleport back to checkpoint on respawn",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		SetAutoRespawnCheckpoint(value)
	end,
})

--// =========================================================================
--// 17. TOOL TAB
--// =========================================================================
local ToolTab = window:Tab({
	Title = "TOOL",
	Icon = "wrench",
})

ToolTab:Section({ Title = "Visual & Camera Tools", Icon = "eye", Opened = true })

ToolTab:Slider({
	Title = "LIGHTING VALUE",
	Step = 1,
	Value = { Min = 1, Max = 10, Default = 3 },
	Callback = function(value)
		LightingLevel = tonumber(value) or 3
		if Toggles.LightingBoost then
			ApplyLightingState(true)
		end
	end,
})

ToolTab:Toggle({
	Title = "LIGHTING",
	Desc = "Apply lighting brightness & remove shadows",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		Toggles.LightingBoost = value
		ApplyLightingState(value)
	end,
})

ToolTab:Toggle({
	Title = "FULL BRIGHTNESS",
	Desc = "Max brightness & full map visibility (ON/OFF)",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		SetFullBrightness(value)
	end,
})

ToolTab:Toggle({
	Title = "NO FOG",
	Desc = "Remove map fog & atmosphere haze",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		Toggles.NoFog = value
		ApplyNoFogState(value)
	end,
})

ToolTab:Toggle({
	Title = "NO CAMERA CLIP",
	Desc = "See through walls with camera (ON/OFF)",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		SetNoCameraClip(value)
	end,
})

ToolTab:Toggle({
	Title = "INFINITE ZOOM",
	Desc = "Unlock camera zoom distance (ON/OFF)",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		SetInfiniteZoom(value)
	end,
})

ToolTab:Slider({
	Title = "FREECAM SPEED",
	Step = 5,
	Value = { Min = 10, Max = 250, Default = 80 },
	Callback = function(value)
		FreeCamSpeed = tonumber(value) or 80
	end,
})

ToolTab:Toggle({
	Title = "FREECAM",
	Desc = "Free fly camera with touch/mouse rotation (WASD + E/Q)",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		SetFreeCam(value)
	end,
})

ToolTab:Section({ Title = "Tools & Actions", Icon = "wrench", Opened = true })

ToolTab:Toggle({
	Title = "TP TOOL",
	Desc = "Give TP Tool to teleport where you tap/click",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		SetTpTool(value)
	end,
})

ToolTab:Toggle({
	Title = "F3X HIDE TOOL",
	Desc = "Show/Hide F3X script UI (ON/OFF)",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		SetF3xHideTool(value)
	end,
})

ToolTab:Toggle({
	Title = "JERK TOOL",
	Desc = "Give Jerk animation tool (R6 & R15)",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		SetJerkTool(value)
	end,
})

ToolTab:Toggle({
	Title = "SHIFT LOCK",
	Desc = "Toggle Shift Lock camera & character alignment (ON/OFF)",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		SetShiftLock(value)
	end,
})

ToolTab:Toggle({
	Title = "INVISIBILITY",
	Desc = "Toggle FE Invisibility without extra GUI (ON/OFF)",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		SetInvisibility(value)
	end,
})

ToolTab:Slider({
	Title = "SPIN TOOL SPEED",
	Step = 1,
	Value = { Min = 1, Max = 50, Default = 5 },
	Callback = function(value)
		SpinToolSpeed = tonumber(value) or 5
	end,
})

ToolTab:Toggle({
	Title = "SPIN TOOL",
	Desc = "Spin character continuously (ON/OFF)",
	Value = false,
	Callback = function(value)
		PlayClickSound()
		SetSpinTool(value)
	end,
})

--// =========================================================================
--// 18. REJOIN TAB
--// =========================================================================
local RejoinTab = window:Tab({
	Title = "REJOIN",
	Icon = "refresh-cw",
})

RejoinTab:Section({ Title = "Server Actions", Icon = "refresh-cw", Opened = true })

local CurrentJobIdParagraph = RejoinTab:Paragraph({
	Title = "CURRENT SERVER ID",
	Desc = tostring(game.JobId),
})

local PrevServerParagraph = RejoinTab:Paragraph({
	Title = "PREVIOUS SERVER ID",
	Desc = PreviousServerJobId and tostring(PreviousServerJobId) or "None saved yet",
})

local function SyncServerIdsDisplay()
	pcall(function()
		CurrentJobIdParagraph:SetDesc(tostring(game.JobId))
		PrevServerParagraph:SetDesc(PreviousServerJobId and tostring(PreviousServerJobId) or "None saved yet")
	end)
end

RejoinTab:Button({
	Title = "REJOIN SERVER 🔄",
	Desc = "Rejoin same server",
	Icon = "refresh-cw",
	Callback = function()
		PlayClickSound()
		RejoinCurrentServer()
	end,
})

RejoinTab:Button({
	Title = "RETURN TO PREVIOUS SERVER ⏪",
	Desc = "Go back to your previous server",
	Icon = "history",
	Callback = function()
		PlayClickSound()
		ReturnToPreviousServer()
	end,
})

RejoinTab:Button({
	Title = "SERVER HOP 🌐",
	Desc = "Find a different server",
	Icon = "globe",
	Callback = function()
		PlayClickSound()
		ServerHop()
	end,
})

RejoinTab:Button({
	Title = "COPY CURRENT SERVER ID 📋",
	Desc = tostring(game.JobId),
	Icon = "copy",
	Callback = function()
		PlayClickSound()
		local ok = CopyTextToClipboard(tostring(game.JobId))
		if ok then
			NotifyHub("COPIED 📋", "Current Server JobId copied to clipboard!", 3, "check")
		else
			NotifyHub("SERVER ID 📋", tostring(game.JobId), 5, "copy")
		end
	end,
})

RejoinTab:Input({
	Title = "JOIN BY SERVER ID 🔗",
	Desc = "Paste JobId here",
	Placeholder = "Paste JobId here...",
	Callback = function(value)
		JoinByServerIdInput = tostring(value or "")
	end,
})

RejoinTab:Button({
	Title = "JOIN SERVER ID (GO) 🚀",
	Desc = "Join the entered Server JobId",
	Icon = "log-in",
	Callback = function()
		PlayClickSound()
		JoinByServerId(JoinByServerIdInput)
	end,
})

SyncServerIdsDisplay()

--// SELECT FIRST TAB & NOTIFY
window:SelectTab(1)

NotifyHub("AYANUU HUB", "AYANUU HUB LOADED! 💀", 5, "crown")

task.spawn(function()
	local chatMsg = "-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-AYANUU HUB LOADED 🔥 MADE BY AYANUU 🔥 🏴ZERO MERCY 🏴-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-"
	pcall(function()
		if game:GetService("TextChatService").ChatVersion == Enum.ChatVersion.TextChatService then
			game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(chatMsg)
		else
			replicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(chatMsg, "All")
		end
	end)
end)
