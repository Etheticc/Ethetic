-- Script 1
getgenv().stile = {
    script_key = {
        script_key="yes",
    },
    hitbox_expander = {
        Enabled = false,
        Size = 30,
        Color = Color3.fromRGB(250, 127, 139),
        Transparency = 0.0,
    },
    Visuals = {
        Self = {
            Enabled = true,
            ForceField_Chams = true,
            Color = Color3.fromRGB(250, 127, 139),
            Held_ForceField_Chams = true,
            Held_Color = Color3.fromRGB(250, 127, 139),
        },
    },
}

local loaderGui = Instance.new("ScreenGui")
loaderGui.IgnoreGuiInset = true
loaderGui.ResetOnSpawn = false
loaderGui.Parent = game.Players.LocalPlayer.PlayerGui

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = game.Lighting

local imageLabel = Instance.new("ImageLabel")
imageLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
imageLabel.Position = UDim2.new(0.25, 0, 0.25, 0)
imageLabel.BackgroundTransparency = 1
imageLabel.Image = "https://www.roblox.com/asset/?id=99974320084668"  -- Use direct URL here
imageLabel.ImageTransparency = 0  -- Ensure it's visible
imageLabel.ScaleType = Enum.ScaleType.Fit
imageLabel.Parent = loaderGui

print("Loading...")

local fadeInInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local fadeOutInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local blurTween = game:GetService("TweenService"):Create(blur, fadeInInfo, { Size = 24 })
blurTween:Play()

local fadeInTween = game:GetService("TweenService"):Create(imageLabel, fadeInInfo, { ImageTransparency = 0 })
fadeInTween:Play()

task.wait(5)

local blurRemoveTween = game:GetService("TweenService"):Create(blur, fadeOutInfo, { Size = 0 })
local fadeOutTween = game:GetService("TweenService"):Create(imageLabel, fadeOutInfo, { ImageTransparency = 1 })

fadeOutTween:Play()
blurRemoveTween:Play()

fadeOutTween.Completed:Connect(function()
    loaderGui:Destroy()
    blur:Destroy()
end)

task.delay(5, function()
    local targetPlayer = nil
    local isExpanderActive = false

    local function getClosestPlayerToCursor()
        local mouse = game.Players.LocalPlayer:GetMouse()
        local closestPlayer = nil
        local shortestDistance = math.huge

        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local character = player.Character
                local rootPart = character.HumanoidRootPart

                local worldToScreen, onScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    local distance = (Vector2.new(worldToScreen.X, worldToScreen.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    if distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end

        return closestPlayer
    end

    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if input.KeyCode == Enum.KeyCode.E then
            isExpanderActive = not isExpanderActive

            if isExpanderActive then
                targetPlayer = getClosestPlayerToCursor()
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local humanoidRootPart = targetPlayer.Character.HumanoidRootPart
                    pcall(function()
                        humanoidRootPart.Shape = Enum.PartType.Ball
                        humanoidRootPart.Size = Vector3.new(getgenv().stile.hitbox_expander.Size, getgenv().stile.hitbox_expander.Size, getgenv().stile.hitbox_expander.Size)
                        humanoidRootPart.Transparency = getgenv().stile.hitbox_expander.Transparency
                        humanoidRootPart.Color = getgenv().stile.hitbox_expander.Color
                        humanoidRootPart.Material = Enum.Material.ForceField
                        humanoidRootPart.CanCollide = false
                    end)
                end
            else
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local humanoidRootPart = targetPlayer.Character.HumanoidRootPart
                    pcall(function()
                        humanoidRootPart.Size = Vector3.new(2, 2, 1) -- Reset to default size
                        humanoidRootPart.Transparency = 0 -- Reset transparency
                        humanoidRootPart.Material = Enum.Material.Plastic -- Reset material
                        humanoidRootPart.CanCollide = true -- Reset collision
                    end)
                end
                targetPlayer = nil
            end
        end
    end)

    if getgenv().stile.Visuals.Self.Enabled then
        local genv = {}
        genv.player = game.Players.LocalPlayer

        genv.applyForceFieldToModel = function(model, color)
            for _, desc in pairs(model:GetDescendants()) do
                if desc:IsA("BasePart") then
                    desc.Material = Enum.Material.ForceField
                    desc.Color = color
                    desc.CanCollide = false
                end
            end
        end

        genv.setupCharacter = function(character)
            genv.applyForceFieldToModel(character, getgenv().stile.Visuals.Self.Color)

            character.ChildAdded:Connect(function(child)
                if child:IsA("Tool") then
                    genv.applyForceFieldToModel(child, getgenv().stile.Visuals.Self.Held_Color)
                end
            end)
            for _, child in pairs(character:GetChildren()) do
                if child:IsA("Tool") then
                    genv.applyForceFieldToModel(child, getgenv().stile.Visuals.Self.Held_Color)
                end
            end
        end

        genv.player.CharacterAdded:Connect(function(character)
            genv.setupCharacter(character)
        end)

        if genv.player.Character then
            genv.setupCharacter(genv.player.Character)
        end
    end

    if getgenv().stile.Watermark.Enabled then
        local function createFloatingText(character)
            local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
            
            if torso then
                local billboardGui = Instance.new("BillboardGui")
                billboardGui.Size = UDim2.new(0, 24, 0, 24)
                billboardGui.Adornee = torso
                billboardGui.AlwaysOnTop = true
                billboardGui.Parent = character

                local textOutline = Instance.new("TextLabel")
                textOutline.Size = UDim2.new(1, 2, 1, 2)
                textOutline.BackgroundTransparency = 1
                textOutline.Text = getgenv().stile.Watermark.Text
                textOutline.TextScaled = true
                textOutline.TextColor3 = Color3.fromRGB(0, 0, 0)
                textOutline.Font = getgenv().stile.Watermark.Font
                textOutline.TextStrokeTransparency = getgenv().stile.Watermark.OutlineTransparency
                textOutline.Parent = billboardGui

                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = getgenv().stile.Watermark.Text
                textLabel.TextSize = getgenv().stile.Watermark.TextSize
                textLabel.TextScaled = true
                textLabel.TextColor3 = Color3.fromRGB(209, 206, 255)
                textLabel.Font = getgenv().stile.Watermark.Font
                textLabel.TextStrokeTransparency = getgenv().stile.Watermark.TextTransparency
                textLabel.Parent = billboardGui
            end
        end

        local Players = game:GetService("Players")
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                if player ~= game.Players.LocalPlayer then
                    createFloatingText(character)
                end
            end)
        end)

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                createFloatingText(player.Character)
            end
        end
    end
end)

local lighting = game:GetService("Lighting")

-- Set the fog properties
lighting.FogStart = 50
lighting.FogEnd = 700
lighting.FogColor = Color3.fromRGB(255, 182, 182)  -- Lightish red color

-- Added Script
local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local minHeight = 10 -- Minimum height to prevent teleporting into the ground

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Q then
        local targetPosition = mouse.Hit.p
        local rayOrigin = targetPosition + Vector3.new(0, 50, 0) -- Start the ray 50 studs above the target
        local rayDirection = Vector3.new(0, -100, 0) -- Ray goes downward

        -- Cast a ray down to find the ground level
        local ray = workspace:Raycast(rayOrigin, rayDirection)

        if ray then
            -- If the ray hits something, set the target to that hit point
            targetPosition = ray.Position
        else
            -- If the ray doesn't hit anything, ensure the position is above the minimum height
            if targetPosition.Y < minHeight then
                targetPosition = Vector3.new(targetPosition.X, minHeight, targetPosition.Z)
            end
        end

        -- Teleport the player to the adjusted position
        player.Character:MoveTo(targetPosition)
    end
end)

-- Additional Spinning Script
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = game:GetService("Workspace").CurrentCamera

-- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local spinning = true
local spinSpeed = 240    -- Speed of rotation (degrees per second)
local spinHeight = 10   -- Height offset
local spinDistance = 23 -- Distance from the target
local targetCharacter = nil

-- Function to get the closest character to the cursor
local function getClosestCharacter()
    local closestDistance = math.huge
    local closestChar = nil
    local mousePos = player:GetMouse().Hit.p

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local charPos = otherPlayer.Character.HumanoidRootPart.Position
            local distance = (charPos - mousePos).Magnitude

            if distance < closestDistance then
                closestDistance = distance
                closestChar = otherPlayer.Character
            end
        end
    end

    return closestChar
end

-- Toggle spin when "G" is pressed
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.G then
        spinning = not spinning
        if spinning then
            targetCharacter = getClosestCharacter()
            if targetCharacter then
                -- Lock the camera to the target when spinning starts
                Camera.CameraType = Enum.CameraType.Scriptable
            end
        else
            -- Stop spinning and reset camera when toggled off
            Camera.CameraType = Enum.CameraType.Custom
        end
    end
end)

-- Main spinning logic
RunService.Heartbeat:Connect(function()
    if spinning and targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") then
        -- Apply rotation logic around the target
        local angle = math.rad(spinSpeed * tick())  -- Use tick to update the angle over time
        local xOffset = math.cos(angle) * spinDistance
        local zOffset = math.sin(angle) * spinDistance
        local yOffset = spinHeight

        -- Calculate the new position relative to the target
        local targetPosition = targetCharacter.HumanoidRootPart.Position
        local newPos = targetPosition + Vector3.new(xOffset, yOffset, zOffset)

        -- Update the player's position and rotation to spin around the target
        humanoidRootPart.CFrame = CFrame.new(newPos, targetPosition)

        -- Lock the camera to follow the spinning character
        Camera.CFrame = CFrame.new(humanoidRootPart.Position, targetPosition)
    end
end)

-- Color to apply to the parts
local targetColor = Color3.new(30/255, 30/255, 30/255)
local originalState = {}
local isToggled = false

-- Function to determine if a part belongs to a character
local function isCharacterPart(part)
    if part:IsDescendantOf(game.Players) then
        return true
    end
    return false
end

-- Function to save the original state of a part
local function saveOriginalState(part)
    if not originalState[part] then
        originalState[part] = {
            Color = part.Color,
            Textures = {}
        }
        for _, child in ipairs(part:GetChildren()) do
            if child:IsA("Texture") or child:IsA("Decal") then
                table.insert(originalState[part].Textures, child:Clone())
            end
        end
    end
end

-- Function to restore the original state of a part
local function restoreOriginalState(part)
    if originalState[part] then
        part.Color = originalState[part].Color
        -- Clear existing textures and decals
        for _, child in ipairs(part:GetChildren()) do
            if child:IsA("Texture") or child:IsA("Decal") then
                child:Destroy()
            end
        end
        -- Restore original textures and decals
        for _, texture in ipairs(originalState[part].Textures) do
            texture.Parent = part
        end
    end
end

-- Function to process a part
local function processPart(part, toggle)
    if part:IsA("BasePart") and not isCharacterPart(part) then
        if toggle then
            saveOriginalState(part)
            -- Remove textures
            for _, child in ipairs(part:GetChildren()) do
                if child:IsA("Texture") or child:IsA("Decal") then
                    child:Destroy()
                end
            end
            -- Set color
            part.Color = targetColor
        else
            restoreOriginalState(part)
        end
    end
end

-- Process all parts in the game
local function processWorkspace(toggle)
    for _, obj in ipairs(workspace:GetDescendants()) do
        processPart(obj, toggle)
    end
end

-- Toggle functionality
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.P then
        isToggled = not isToggled
        processWorkspace(isToggled)
    end
end)

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local toggle = false

local function getClosestPlayerToCursor()
    local mouseLocation = UserInputService:GetMouseLocation()
    local screenRay = Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)

    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local rootPart = character.HumanoidRootPart

            local worldToScreen, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            if onScreen then
                local distance = (Vector2.new(worldToScreen.X, worldToScreen.Y) - mouseLocation).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end

    return closestPlayer
end


-- Define the target teleport location
local teleportLocation = Vector3.new(339.40, 112.50, -682.03)

-- Get the player
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Wait for the humanoid to exist
local humanoid = character:WaitForChild("Humanoid")

-- Initialize lastHealth to the player's current health
local lastHealth = humanoid.Health

-- Function to monitor health changes
local function onHealthChanged(health)
    if health < lastHealth then -- Only teleport if health is decreasing
        -- Teleport the character to the specified location
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(teleportLocation)
        end
    end
    -- Update lastHealth to current health
    lastHealth = health
end

-- Connect the HealthChanged event to the function
humanoid.HealthChanged:Connect(onHealthChanged)
