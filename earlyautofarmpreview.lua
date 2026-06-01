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

local function Log(msg) StatusLog.Text = tostring(msg) end

-- Sprint Loop
task.spawn(function()
    while true do
        if Enabled then
            local args = {true}
            local event = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and game.ReplicatedStorage.Events:FindFirstChild("SprintEvent")
            if event then event:FireServer(unpack(args)) end
        end
        task.wait(45)
    end
end)

local function AbortExtractions()
    local room = workspace:FindFirstChild("CurrentRoom")
    if room then
        for _, map in pairs(room:GetChildren()) do
            local gens = map:FindFirstChild("Generators")
            if gens then
                for _, gen in pairs(gens:GetChildren()) do
                    local remote = gen:FindFirstChild("Stats") and gen.Stats:FindFirstChild("StopInteracting")
                    if remote then remote:FireServer("Stop") end
                end
            end
        end
    end
end

local function IsBeingChased()
    local room = workspace:FindFirstChild("CurrentRoom")
    if room then
        for _, map in pairs(room:GetChildren()) do
            local mFolder = map:FindFirstChild("Monsters")
            if mFolder then
                for _, m in pairs(mFolder:GetChildren()) do
                    local cv = m:FindFirstChild("ChasingValue")
                    if cv and (cv.Value == LocalPlayer.Name or (cv:IsA("ObjectValue") and cv.Value and cv.Value.Name == LocalPlayer.Name)) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function RunAutoFarm()
    task.spawn(function()
        while Enabled do
            local Room = workspace:FindFirstChild("CurrentRoom")
            local Info = workspace:FindFirstChild("Info")
            FloorLabel.Text = "Floor: " .. (Info and Info:FindFirstChild("Floor") and Info.Floor.Value or "?")
            
            for _, child in pairs(ListContainer:GetChildren()) do if not child:IsA("UIListLayout") then child:Destroy() end end
            if Room then
                for _, map in pairs(Room:GetChildren()) do
                    local mFolder = map:FindFirstChild("Monsters")
                    if mFolder then
                        for _, m in pairs(mFolder:GetChildren()) do
                            local l = Instance.new("TextLabel", ListContainer)
                            l.Text = m.Name
                            l.TextColor3 = Color3.new(1, 0, 0)
                            l.BackgroundTransparency = 1
                            l.Size = UDim2.new(1, 0, 0, 15)
                        end
                    end
                end
            end

            if IsBeingChased() then
                Log("SPOTTED! Hiding...")
                AbortExtractions()
                LocalPlayer.Character:PivotTo(CFrame.new(5000, 5000, 5000))
                repeat task.wait(0.2) until not IsBeingChased()
                task.wait(3) 
            elseif Info and Info:FindFirstChild("Panic") and Info.Panic.Value == true then
                Log("Panic! To elevator...")
                local elev = workspace:FindFirstChild("Elevators") and workspace.Elevators:FindFirstChild("Elevator")
                if elev and elev:FindFirstChild("Base") then LocalPlayer.Character:PivotTo(elev.Base.CFrame) end
            elseif Room then
                local collected = false
                for _, map in pairs(Room:GetChildren()) do
                    local items = map:FindFirstChild("Items")
                    if items then
                        for _, item in pairs(items:GetChildren()) do
                            if item.Name == "ResearchCapsule" then
                                local p = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if p then
                                    p.HoldDuration = 0
                                    LocalPlayer.Character:PivotTo(item:GetPivot() + Vector3.new(0, 1, 0))
                                    fireproximityprompt(p)
                                    Log("Collecting Capsule...")
                                    collected = true
                                end
                            end
                        end
                    end
                end

                if not collected then
                    local gen = nil
                    for _, map in pairs(Room:GetChildren()) do
                        local gens = map:FindFirstChild("Generators")
                        if gens then
                            for _, g in pairs(gens:GetChildren()) do
                                local p = g:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if p and p.Enabled then gen = g break end
                            end
                        end
                    end
                    if gen then
                        LocalPlayer.Character:PivotTo(gen:GetPivot())
                        fireproximityprompt(gen:FindFirstChildWhichIsA("ProximityPrompt", true))
                        Log("Extracting...")
                    else
                        Log("All tasks complete.")
                    end
                end
            end
            task.wait(0.2)
        end
    end)
end

Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    Toggle.Text = Enabled and "Autofarm: ON" or "Autofarm: OFF"
    if Enabled then RunAutoFarm() end
end)
