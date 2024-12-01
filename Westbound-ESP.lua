local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local ESPEnabled = false
local ESPTransparency = 0.5
local ESPUpdateDelay = 0.1

local function getRoot(part)
    return part:IsA("Model") and part.PrimaryPart or part:FindFirstChildWhichIsA("BasePart") or part
end

local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function createESP(plr)
    -- Destroy any existing ESP for this player
    local existingFolder = CoreGui:FindFirstChild(plr.Name .. "_ESP")
    if existingFolder then
        existingFolder:Destroy()
    end

    local ESPholder = Instance.new("Folder")
    ESPholder.Name = plr.Name .. "_ESP"
    ESPholder.Parent = CoreGui

    local function createAdornment(part)
        local a = Instance.new("BoxHandleAdornment")
        a.Name = plr.Name
        a.Parent = ESPholder
        a.Adornee = part
        a.AlwaysOnTop = true
        a.ZIndex = 10
        a.Size = part.Size
        a.Transparency = ESPTransparency
        a.Color = plr.TeamColor or Color3.fromRGB(255, 255, 255) -- Default white if no team color
        return a
    end

    -- Wait for the player's character and its humanoid to load
    repeat wait(ESPUpdateDelay) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")

    -- Create adornments for all BaseParts in the character
    for _, part in pairs(plr.Character:GetChildren()) do
        if part:IsA("BasePart") then
            createAdornment(part)
        end
    end

    -- Add a BillboardGui above the player's head
    if plr.Character and plr.Character:FindFirstChild("Head") then
        local BillboardGui = Instance.new("BillboardGui")
        local TextLabel = Instance.new("TextLabel")

        BillboardGui.Adornee = plr.Character.Head
        BillboardGui.Name = plr.Name
        BillboardGui.Parent = ESPholder
        BillboardGui.Size = UDim2.new(0, 100, 0, 150)
        BillboardGui.StudsOffset = Vector3.new(0, 1, 0)
        BillboardGui.AlwaysOnTop = true

        TextLabel.Parent = BillboardGui
        TextLabel.BackgroundTransparency = 1
        TextLabel.Position = UDim2.new(0, 0, 0, -50)
        TextLabel.Size = UDim2.new(0, 100, 0, 100)
        TextLabel.Font = Enum.Font.SourceSansSemibold
        TextLabel.TextSize = 20
        TextLabel.TextColor3 = Color3.new(1, 1, 1)
        TextLabel.TextStrokeTransparency = 0
        TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom

        -- Determine the player's team to display
        local function getTeamName()
            if plr.Team then
                return plr.Team.Name
            elseif plr:GetAttribute("Team") then
                return plr:GetAttribute("Team")
            else
                return "No Team"
            end
        end

        -- Continuously update the ESP text
        local function espLoop()
            if CoreGui:FindFirstChild(plr.Name .. "_ESP") then
                if plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid") and Players.LocalPlayer.Character then
                    local pos = math.floor((getRoot(Players.LocalPlayer.Character).Position - getRoot(plr.Character).Position).magnitude)
                    TextLabel.Text = 'Name: ' .. plr.Name .. ' | Team: ' .. getTeamName() .. ' | Health: ' .. round(plr.Character:FindFirstChildOfClass('Humanoid').Health, 1) .. ' | Studs: ' .. pos
                end
            end
        end

        RunService.RenderStepped:Connect(espLoop)
    end
end

local function onPlayerAdded(plr)
    -- Create ESP when the player joins or respawns
    plr.CharacterAdded:Connect(function()
        createESP(plr)
    end)

    -- Recreate ESP when the player's team changes
    plr:GetPropertyChangedSignal("Team"):Connect(function()
        if ESPEnabled then
            createESP(plr)
        end
    end)

    -- Handle custom team attribute changes
    if plr:GetAttribute("Team") then
        plr.AttributeChanged:Connect(function(attributeName)
            if attributeName == "Team" and ESPEnabled then
                createESP(plr)
            end
        end)
    end
end

local function toggleESP()
    ESPEnabled = not ESPEnabled
    for _, plr in pairs(Players:GetPlayers()) do
        createESP(plr)
    end
end

-- Connect to existing players and new players
for _, plr in pairs(Players:GetPlayers()) do
    onPlayerAdded(plr)
end
Players.PlayerAdded:Connect(onPlayerAdded)

-- Call toggleESP() to activate/deactivate ESP
toggleESP()
