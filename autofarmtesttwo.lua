-- Initializing GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DandyAutofarmGui"

-- Skillcheck Bypass
game.ReplicatedStorage.Events.SkillcheckUpdate.OnClientInvoke = function()
    return "supercomplete"
end

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 260)
Frame.Position = UDim2.new(0.5, -125, 0.5, -130)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BackgroundTransparency = 0.2
Frame.Active, Frame.Draggable = true, true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.Text = "sean's DW Autofarm"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 10

local VersionLabel = Instance.new("TextLabel", Frame)
VersionLabel.Size = UDim2.new(0, 60, 0, 15)
VersionLabel.Position = UDim2.new(1, -70, 0, 5)
VersionLabel.Text = "Version 0.1.1"
VersionLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Font = Enum.Font.Code
VersionLabel.TextSize = 8

local Subtitle = Instance.new("TextLabel", Frame)
Subtitle.Size = UDim2.new(1, 0, 0, 15)
Subtitle.Position = UDim2.new(0, 0, 0, 20)
Subtitle.Text = "credits to olivia and ali_hhjjj from the bookclub discord server"
Subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
Subtitle.BackgroundTransparency = 1
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 8

local FloorLabel = Instance.new("TextLabel", Frame)
FloorLabel.Size, FloorLabel.Position = UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 35)
FloorLabel.Text = "Floor: ..."
FloorLabel.TextColor3 = Color3.new(1,1,1)
FloorLabel.BackgroundTransparency = 1

local ListContainer = Instance.new("ScrollingFrame", Frame)
ListContainer.Size, ListContainer.Position = UDim2.new(1, -20, 0, 60), UDim2.new(0, 10, 0, 55)
ListContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ListContainer.BackgroundTransparency = 0.5
local UIList = Instance.new("UIListLayout", ListContainer)

local Toggle = Instance.new("TextButton", Frame)
Toggle.Size, Toggle.Position = UDim2.new(0, 220, 0, 25), UDim2.new(0, 15, 0, 120)
Toggle.Text = "Autofarm: OFF"
Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Toggle.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 8)

local StatusLog = Instance.new("TextLabel", Frame)
StatusLog.Size, StatusLog.Position = UDim2.new(1, -20, 0, 90), UDim2.new(0, 10, 0, 150)
StatusLog.Text = "Status: Idle"
StatusLog.TextColor3 = Color3.new(1,1,1)
StatusLog.BackgroundTransparency = 1

local CyclerLabel = Instance.new("TextLabel", Frame)
CyclerLabel.Size = UDim2.new(1, -20, 0, 30)
CyclerLabel.Position = UDim2.new(0, 10, 0, 220)
CyclerLabel.BackgroundTransparency = 1
CyclerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CyclerLabel.Font = Enum.Font.Code
CyclerLabel.TextSize = 9
CyclerLabel.TextWrapped = true

local Enabled = false
local LocalPlayer = game.Players.LocalPlayer

local function Log(msg) StatusLog.Text = tostring(msg) end

-- Healing Logic
local function HandleHealing()
    local inv = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Inventory")
    if not inv then return end
    
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum and hum.Health < hum.MaxHealth then
        for i = 1, 3 do
            local slot = inv:FindFirstChild("Slot" .. i)
            if slot and (slot.Value == "HealthKit" or slot.Value == "Bandage") then
                game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ItemEvent"):InvokeServer({
                    LocalPlayer.Character,
                    slot
                })
                break
            end
        end
    end
end

local function HasEmptySlot()
    local inv = workspace:FindFirstChild("InGamePlayers") and workspace.InGamePlayers:FindFirstChild(LocalPlayer.Name) and workspace.InGamePlayers[LocalPlayer.Name]:FindFirstChild("Inventory")
    if inv then
        for i = 1, 3 do
            local slot = inv:FindFirstChild("Slot" .. i)
            if slot and slot.Value == "None" then return true end
        end
    end
    return false
end

local SpotterPhrases = {"Looks like we’ve got spotted!\nLet’s hide, shall we?", "Not dealing with THAT twisted.", "Sigh.. we got spotted again.", "Pretty cozy up in the void, is it not?", "hidehidehidehidehidehide", "You’re safe here."}
local IgnoreList = {["RazzleDazzleMonster"] = true, ["SquirmMonster"] = true, ["RodgerMonster"] = true}

local function GetRandomMonster()
    local room = workspace:FindFirstChild("CurrentRoom")
    if room then
        local monsters = {}
        for _, map in pairs(room:GetChildren()) do
            local mFolder = map:FindFirstChild("Monsters")
            if mFolder then
                for _, m in pairs(mFolder:GetChildren()) do
                    table.insert(monsters, m.Name:gsub("Monster", ""))
                end
            end
        end
        if #monsters > 0 then return monsters[math.random(1, #monsters)] end
    end
    return "Twisted"
end

task.spawn(function()
    while true do
        local monster = GetRandomMonster()
        local phrases = {"auto vote card coming in never", "you're gonna encounter twisted dandy a shit ton of times", "go give Twisted " .. monster .. " a big hug, they need it.", "i'm scared.", "ok", "hi", "???? why????? wh y????"}
        CyclerLabel.Text = phrases[math.random(1, #phrases)]
        task.wait(math.random(15))
    end
end)

local function AbortExtractions()
    local room = workspace:FindFirstChild("CurrentRoom")
    if not room then return end
    for _, map in pairs(room:GetChildren()) do
        local gens = map:FindFirstChild("Generators")
        if gens then
            for _, gen in gens:GetChildren() do
                local stats = gen:FindFirstChild("Stats")
                local stopRemote = stats and stats:FindFirstChild("StopInteracting")
                if stopRemote then stopRemote:FireServer("Stop") end
            end
        end
    end
end

local function IsBeingChased()
    local room = workspace:FindFirstChild("CurrentRoom")
    if not room then return false end
    for _, map in pairs(room:GetChildren()) do
        local mFolder = map:FindFirstChild("Monsters")
        if mFolder then
            for _, m in pairs(mFolder:GetChildren()) do
                if not IgnoreList[m.Name] then
                    local cv = m:FindFirstChild("ChasingValue")
                    if cv and (cv.Value == LocalPlayer.Name or (cv:IsA("ObjectValue") and cv.Value and cv.Value.Name == LocalPlayer.Name)) then return true end
                end
            end
        end
    end
    return false
end

local function SafeTeleport(targetCFrame)
    if (LocalPlayer.Character:GetPivot().Position - targetCFrame.Position).Magnitude > 5 then LocalPlayer.Character:PivotTo(targetCFrame) end
end

local function RunAutoFarm()
    task.spawn(function()
        while Enabled do
            if IsBeingChased() then
                Log(SpotterPhrases[math.random(1, #SpotterPhrases)])
                for i=1, 5 do AbortExtractions() task.wait(0.1) end
                workspace.Gravity = 0
                SafeTeleport(CFrame.new(0, 10000, 0))
                repeat task.wait(0.2) until not IsBeingChased()
                task.wait(4)
                workspace.Gravity = 196.2
                continue
            end
            
            HandleHealing()
            local Room = workspace:FindFirstChild("CurrentRoom")
            local Info = workspace:FindFirstChild("Info")
            FloorLabel.Text = "Floor: " .. (Info and Info:FindFirstChild("Floor") and Info.Floor.Value or "?")
            for _, child in pairs(ListContainer:GetChildren()) do if not child:IsA("UIListLayout") then child:Destroy() end end
            if Room then
                local collected = false
                for _, map in pairs(Room:GetChildren()) do
                    local items = map:FindFirstChild("Items")
                    if items then
                        for _, item in pairs(items:GetChildren()) do
                            local isHeal = (item.Name == "HealthKit" or item.Name == "Bandage")
                            if item.Name == "ResearchCapsule" or (isHeal and HasEmptySlot()) then
                                local p = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if p then
                                    p.HoldDuration = 0
                                    SafeTeleport(CFrame.new(item:GetPivot().Position + Vector3.new(0, 3, 0)))
                                    fireproximityprompt(p)
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
                        SafeTeleport(CFrame.new(gen:GetPivot().Position + Vector3.new(0, 3, 0)))
                        task.wait(0.3)
                        if not IsBeingChased() then
                            fireproximityprompt(gen:FindFirstChildWhichIsA("ProximityPrompt", true))
                            Log("Extracting...")
                        end
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
    workspace.Gravity = 196.2
    if Enabled then RunAutoFarm() end
end)

loadstring(game:HttpGet("https://raw.githubusercontent.com/alihusam078588-web/Twilight-zone-loader/refs/heads/main/squirm.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/thatONEworldthatihate/afkshit/refs/heads/main/afk.lua"))()
