-- Initializing GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DandyAutofarmGui"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 260)
Frame.Position = UDim2.new(0.5, -125, 0.5, -130)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BackgroundTransparency = 0.2
Frame.Active, Frame.Draggable = true, true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Text = "Dandy’s World Autofarm V1 - made by seann"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 10

local FloorLabel = Instance.new("TextLabel", Frame)
FloorLabel.Size, FloorLabel.Position = UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 25)
FloorLabel.Text = "Floor: ..."
FloorLabel.TextColor3 = Color3.new(1,1,1)
FloorLabel.BackgroundTransparency = 1

local ListContainer = Instance.new("ScrollingFrame", Frame)
ListContainer.Size, ListContainer.Position = UDim2.new(1, -20, 0, 60), UDim2.new(0, 10, 0, 45)
ListContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ListContainer.BackgroundTransparency = 0.5
local UIList = Instance.new("UIListLayout", ListContainer)

local Toggle = Instance.new("TextButton", Frame)
Toggle.Size, Toggle.Position = UDim2.new(0, 220, 0, 25), UDim2.new(0, 15, 0, 110)
Toggle.Text = "Autofarm: OFF"
Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Toggle.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 8)

local StatusLog = Instance.new("TextLabel", Frame)
StatusLog.Size, StatusLog.Position = UDim2.new(1, -20, 0, 90), UDim2.new(0, 10, 0, 140)
StatusLog.Text = "Status: Idle"
StatusLog.TextColor3 = Color3.new(1,1,1)
StatusLog.BackgroundTransparency = 1

local Enabled = false
local LocalPlayer = game.Players.LocalPlayer
local SafeZone = CFrame.new(5000, 5000, 5000)

local function Log(msg) StatusLog.Text = tostring(msg) end

-- Sprint Loop
task.spawn(function()
    while true do
        if Enabled then
            local event = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and game.ReplicatedStorage.Events:FindFirstChild("SprintEvent")
            if event then event:FireServer(true) end
        end
        task.wait(45)
    end
end)

local function AbortExtractions()
    local room = workspace:FindFirstChild("CurrentRoom")
    if not room then return end
    for _, map in pairs(room:GetChildren()) do
        local gens = map:FindFirstChild("Generators")
        if gens then
            for _, gen in pairs(gens:GetChildren()) do
                local stopRemote = gen:FindFirstChild("Stats") and gen.Stats:FindFirstChild("StopInteracting")
                if stopRemote then stopRemote:FireServer("Stop") end
            end
        end
    end
end

-- Checks if any monster is within 30 studs of a position
local function IsDangerNear(pos)
    local room = workspace:FindFirstChild("CurrentRoom")
    if not room then return false end
    for _, map in pairs(room:GetChildren()) do
        local mFolder = map:FindFirstChild("Monsters")
        if mFolder then
            for _, m in pairs(mFolder:GetChildren()) do
                if m:FindFirstChild("HumanoidRootPart") and (m.HumanoidRootPart.Position - pos).Magnitude < 30 then
                    return true
                end
            end
        end
    end
    return false
end

local function SafeTeleport(targetCFrame)
    if (LocalPlayer.Character:GetPivot().Position - targetCFrame.Position).Magnitude > 5 then
        LocalPlayer.Character:PivotTo(targetCFrame)
    end
end

local function RunAutoFarm()
    task.spawn(function()
        while Enabled do
            local Room = workspace:FindFirstChild("CurrentRoom")
            
            -- Priority: Monsters
            local isChased = false
            if Room then
                for _, map in pairs(Room:GetChildren()) do
                    local mFolder = map:FindFirstChild("Monsters")
                    if mFolder then
                        for _, m in pairs(mFolder:GetChildren()) do
                            local cv = m:FindFirstChild("ChasingValue")
                            if cv and (cv.Value == LocalPlayer.Name or (cv:IsA("ObjectValue") and cv.Value and cv.Value.Name == LocalPlayer.Name)) then
                                isChased = true
                            end
                        end
                    end
                end
            end

            if isChased then
                Log("SPOTTED! Hiding...")
                AbortExtractions()
                SafeTeleport(SafeZone)
                repeat task.wait(0.2) until not isChased
                task.wait(5)
            elseif Room then
                local gen = nil
                -- Scan for generator with no nearby monsters
                for _, map in pairs(Room:GetChildren()) do
                    local gens = map:FindFirstChild("Generators")
                    if gens then
                        for _, g in pairs(gens:GetChildren()) do
                            local p = g:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if p and p.Enabled and not IsDangerNear(g:GetPivot().Position) then
                                gen = g break 
                            end
                        end
                    end
                end

                if gen then
                    Log("Extracting...")
                    SafeTeleport(gen:GetPivot())
                    fireproximityprompt(gen:FindFirstChildWhichIsA("ProximityPrompt", true))
                    task.wait(2) -- Allow some extraction time
                    AbortExtractions() -- Stop after burst
                    Log("Returning to Safe Zone...")
                    SafeTeleport(SafeZone)
                    task.wait(2)
                else
                    Log("Scanning/Danger near all machines...")
                end
            end
            task.wait(0.5)
        end
    end)
end

Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    Toggle.Text = Enabled and "Autofarm: ON" or "Autofarm: OFF"
    if Enabled then RunAutoFarm() end
end)
