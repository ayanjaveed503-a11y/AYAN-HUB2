local players = game:GetService("Players")
local httpService = game:GetService("HttpService")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local coreGui = game:GetService("CoreGui")
local localPlayer = players.LocalPlayer

local FEEDBACK_URL = "https://6aef2e43b9925b27ce16b743.mockapi.io/v1/Feedback"

local function GetFeedbackGuiParent()
	local parentObj = nil
	pcall(function()
		if typeof(gethui) == "function" then
			parentObj = gethui()
		end
	end)
	if not parentObj then
		pcall(function()
			local f = Instance.new("Folder")
			f.Parent = coreGui
			f:Destroy()
			parentObj = coreGui
		end)
	end
	if not parentObj then
		parentObj = localPlayer:WaitForChild("PlayerGui")
	end
	return parentObj
end

local function PostFeedbackPayload(messageText, ratingNum)
	local cleaned = tostring(messageText or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if cleaned == "" then
		return false, "Pehle koi feedback message likhein!"
	end
	if #cleaned > 500 then
		return false, "Message 500 characters se kam rakhein."
	end

	local payload = {
		username = localPlayer.Name,
		displayName = localPlayer.DisplayName,
		userId = localPlayer.UserId,
		placeId = game.PlaceId,
		jobId = tostring(game.JobId),
		rating = tostring(tonumber(ratingNum) or 5),
		message = cleaned,
		sentAt = os.date("!%Y-%m-%dT%H:%M:%SZ"),
	}

	local encoded = httpService:JSONEncode(payload)
	local headers = {
		["Content-Type"] = "application/json",
	}

	local ok, res = pcall(function()
		local reqFunc = (typeof(request) == "function" and request)
			or (typeof(http_request) == "function" and http_request)
			or (syn and typeof(syn.request) == "function" and syn.request)

		if reqFunc then
			return reqFunc({
				Url = FEEDBACK_URL,
				Method = "POST",
				Headers = headers,
				Body = encoded,
			})
		else
			return httpService:RequestAsync({
				Url = FEEDBACK_URL,
				Method = "POST",
				Headers = headers,
				Body = encoded,
			})
		end
	end)

	if not ok then
		return false, "Request fail: " .. tostring(res)
	end

	local code = res and (res.StatusCode or res.Status)
	if code and tonumber(code) and (tonumber(code) < 200 or tonumber(code) >= 300) then
		return false, "Server error: " .. tostring(code)
	end

	return true, "Feedback send ho gaya! Shukriya."
end

local function OpenAyanuuFeedbackGui()
	local parentGui = GetFeedbackGuiParent()
	local existing = parentGui:FindFirstChild("AYANUU_Feedback_GUI")
	if existing then
		existing:Destroy()
	end

	local selectedRating = 5
	local lastSentTick = 0

	local gui = Instance.new("ScreenGui")
	gui.Name = "AYANUU_Feedback_GUI"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = parentGui

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 326, 0, 305)
	mainFrame.Position = UDim2.new(0.5, -163, 0.5, -152)
	mainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
	mainFrame.BackgroundTransparency = 0.05
	mainFrame.BorderSizePixel = 0
	mainFrame.Active = true
	mainFrame.Parent = gui
	Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)

	local stroke = Instance.new("UIStroke", mainFrame)
	stroke.Color = Color3.fromRGB(220, 40, 60)
	stroke.Thickness = 1.5
	stroke.Transparency = 0.25

	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 38)
	topBar.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
	topBar.BorderSizePixel = 0
	topBar.Parent = mainFrame
	Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 14)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -46, 1, 0)
	titleLabel.Position = UDim2.new(0, 14, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "👑 AYANUU HUB FEEDBACK"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 13
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = topBar

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 26, 0, 26)
	closeBtn.Position = UDim2.new(1, -33, 0.5, -13)
	closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 60)
	closeBtn.Text = "×"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 16
	closeBtn.BorderSizePixel = 0
	closeBtn.Parent = topBar
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

	closeBtn.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)

	-- Top Message Banner
	local infoCard = Instance.new("Frame")
	infoCard.Name = "InfoBanner"
	infoCard.Size = UDim2.new(1, -24, 0, 56)
	infoCard.Position = UDim2.new(0, 12, 0, 44)
	infoCard.BackgroundColor3 = Color3.fromRGB(28, 22, 26)
	infoCard.BorderSizePixel = 0
	infoCard.Parent = mainFrame
	Instance.new("UICorner", infoCard).CornerRadius = UDim.new(0, 10)

	local infoStroke = Instance.new("UIStroke", infoCard)
	infoStroke.Color = Color3.fromRGB(220, 40, 60)
	infoStroke.Thickness = 1
	infoStroke.Transparency = 0.5

	local infoLabel = Instance.new("TextLabel")
	infoLabel.Size = UDim2.new(1, -16, 1, -8)
	infoLabel.Position = UDim2.new(0, 8, 0, 4)
	infoLabel.BackgroundTransparency = 1
	infoLabel.Text = "Script achi lage to 5 ⭐ zaroor dein! Bugs ho to batayein main fix kar dunga, new options ke suggestions dein & kisi ko apni spam script add karwani ho to yahan message bhejein."
	infoLabel.TextColor3 = Color3.fromRGB(240, 225, 228)
	infoLabel.Font = Enum.Font.GothamMedium
	infoLabel.TextSize = 10
	infoLabel.TextWrapped = true
	infoLabel.TextXAlignment = Enum.TextXAlignment.Left
	infoLabel.TextYAlignment = Enum.TextYAlignment.Center
	infoLabel.Parent = infoCard

	local ratingTitle = Instance.new("TextLabel")
	ratingTitle.Size = UDim2.new(1, -24, 0, 16)
	ratingTitle.Position = UDim2.new(0, 12, 0, 106)
	ratingTitle.BackgroundTransparency = 1
	ratingTitle.Text = "RATING (5 ⭐ ZAROOR DEIN):"
	ratingTitle.TextColor3 = Color3.fromRGB(255, 205, 95)
	ratingTitle.Font = Enum.Font.GothamBold
	ratingTitle.TextSize = 11
	ratingTitle.TextXAlignment = Enum.TextXAlignment.Left
	ratingTitle.Parent = mainFrame

	local ratingRow = Instance.new("Frame")
	ratingRow.Size = UDim2.new(1, -24, 0, 30)
	ratingRow.Position = UDim2.new(0, 12, 0, 124)
	ratingRow.BackgroundTransparency = 1
	ratingRow.Parent = mainFrame

	local ratingLayout = Instance.new("UIListLayout", ratingRow)
	ratingLayout.FillDirection = Enum.FillDirection.Horizontal
	ratingLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	ratingLayout.Padding = UDim.new(0, 7)

	local ratingButtons = {}
	local function RefreshRatingButtons()
		for starVal, btn in pairs(ratingButtons) do
			if starVal == selectedRating then
				btn.BackgroundColor3 = Color3.fromRGB(220, 40, 60)
				btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			else
				btn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
				btn.TextColor3 = Color3.fromRGB(185, 185, 195)
			end
		end
	end

	for i = 1, 5 do
		local rBtn = Instance.new("TextButton")
		rBtn.Size = UDim2.new(0, 54, 1, 0)
		rBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
		rBtn.Text = tostring(i) .. " ⭐"
		rBtn.TextColor3 = Color3.fromRGB(185, 185, 195)
		rBtn.Font = Enum.Font.GothamBold
		rBtn.TextSize = 11
		rBtn.BorderSizePixel = 0
		rBtn.Parent = ratingRow
		Instance.new("UICorner", rBtn).CornerRadius = UDim.new(0, 8)
		ratingButtons[i] = rBtn

		rBtn.MouseButton1Click:Connect(function()
			selectedRating = i
			RefreshRatingButtons()
		end)
	end
	RefreshRatingButtons()

	local msgBox = Instance.new("TextBox")
	msgBox.Size = UDim2.new(1, -24, 0, 72)
	msgBox.Position = UDim2.new(0, 12, 0, 161)
	msgBox.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
	msgBox.Text = ""
	msgBox.PlaceholderText = "Bug, new option suggestion ya apni spam script ka message yahan likhein..."
	msgBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	msgBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 145)
	msgBox.Font = Enum.Font.Gotham
	msgBox.TextSize = 11
	msgBox.TextWrapped = true
	msgBox.MultiLine = true
	msgBox.ClearTextOnFocus = false
	msgBox.TextXAlignment = Enum.TextXAlignment.Left
	msgBox.TextYAlignment = Enum.TextYAlignment.Top
	msgBox.BorderSizePixel = 0
	msgBox.Parent = mainFrame
	Instance.new("UICorner", msgBox).CornerRadius = UDim.new(0, 10)

	local msgPad = Instance.new("UIPadding", msgBox)
	msgPad.PaddingTop = UDim.new(0, 8)
	msgPad.PaddingBottom = UDim.new(0, 8)
	msgPad.PaddingLeft = UDim.new(0, 10)
	msgPad.PaddingRight = UDim.new(0, 10)

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(1, -24, 0, 16)
	statusLabel.Position = UDim2.new(0, 12, 0, 238)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "Ready to send (5 ⭐ recommended)"
	statusLabel.TextColor3 = Color3.fromRGB(165, 165, 180)
	statusLabel.Font = Enum.Font.GothamMedium
	statusLabel.TextSize = 11
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Parent = mainFrame

	local submitBtn = Instance.new("TextButton")
	submitBtn.Size = UDim2.new(1, -24, 0, 34)
	submitBtn.Position = UDim2.new(0, 12, 0, 259)
	submitBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 60)
	submitBtn.Text = "SEND FEEDBACK 📩"
	submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	submitBtn.Font = Enum.Font.GothamBold
	submitBtn.TextSize = 12
	submitBtn.BorderSizePixel = 0
	submitBtn.Parent = mainFrame
	Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 10)

	local sending = false
	submitBtn.MouseButton1Click:Connect(function()
		if sending then return end

		local now = tick()
		if now - lastSentTick < 10 then
			statusLabel.Text = "10s cooldown active, thoda rukhein."
			statusLabel.TextColor3 = Color3.fromRGB(255, 185, 65)
			return
		end

		sending = true
		submitBtn.Text = "SENDING..."
		statusLabel.Text = "Feedback bheja ja raha hai..."
		statusLabel.TextColor3 = Color3.fromRGB(180, 180, 200)

		task.spawn(function()
			local ok, info = PostFeedbackPayload(msgBox.Text, selectedRating)
			sending = false
			submitBtn.Text = "SEND FEEDBACK 📩"

			if ok then
				lastSentTick = tick()
				msgBox.Text = ""
				statusLabel.Text = info
				statusLabel.TextColor3 = Color3.fromRGB(80, 225, 120)
				if typeof(NotifyHub) == "function" then
					NotifyHub("FEEDBACK SENT ✅", info, 3, "check-circle")
				end
			else
				statusLabel.Text = info
				statusLabel.TextColor3 = Color3.fromRGB(255, 95, 95)
				if typeof(NotifyHub) == "function" then
					NotifyHub("FEEDBACK ERROR ⚠️", info, 3, "alert-triangle")
				end
			end
		end)
	end)

	-- Dragging support (Mouse + Touch)
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil

	topBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	topBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	userInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	-- Smooth open animation
	mainFrame.Size = UDim2.new(0, 280, 0, 255)
	tweenService:Create(mainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 326, 0, 305),
	}):Play()
end

OpenAyanuuFeedbackGui()
