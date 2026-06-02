-- Initializing GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DandyAutofarmGui"

-- Skillcheck Bypass
game.ReplicatedStorage.Events.SkillcheckUpdate.OnClientInvoke = function()
    return "supercomplete"
end

-- Safe Zone Platform
local SafeZonePart = Instance.new("Part", workspace)
SafeZonePart.Size = Vector3.new(20, 1, 20)
SafeZonePart.Position = Vector3.new(5000, 5000, 5000)
SafeZonePart.Anchored = true
SafeZonePart.Transparency = 0.5
SafeZonePart.Name = "SafeZonePlatform"
local SafeZonePos = CFrame.new(5000, 5000.6, 5000)

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 260)
Frame.Position = UDim2.new(0.5, -125, 0.5, -130)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BackgroundTransparency = 0.2
Frame.Active, Frame.Draggable = true, true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

-- Updated Title
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.Text = "Dandy’s World Autofarm V2 - made by seann"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 10

-- Added Subtitle
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

-- Cycler UI
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

local SpotterPhrases = {
    "Looks like we’ve got spotted!\nLet’s hide, shall we?",
    "Not dealing with THAT twisted.",
    "Sigh.. we got spotted again.",
    "Pretty cozy for a safe zone, is it not?\nStay on that platform, yeah?\nThe void isn’t all that welcoming.",
    "hidehidehidehidehidehide",
    "You’re safe here."
}

local IgnoreList = {
    ["RazzleDazzleMonster"] = true, 
    ["SquirmMonster"] = true,
    ["RodgerMonster"] = true
}

-- Cycler Logic
local function FormatTrinket(val)
    if val == "VeeRemote" then return "vee's remote" end
    return val:gsub("(%u)", " %1"):gsub("^%s+", ""):lower()
end

local function GetSpecialPhrase()
    local playerFolder = workspace:FindFirstChild("InGamePlayers") and workspace.InGamePlayers:FindFirstChild(LocalPlayer.Name)
    local charName = (playerFolder and playerFolder:FindFirstChild("Config") and playerFolder.Config:FindFirstChild("CharacterName")) and playerFolder.Config.CharacterName.Value or "unknown"
    local t1 = (playerFolder and playerFolder:FindFirstChild("Trinkets") and playerFolder.Trinkets:FindFirstChild("Trinket1")) and FormatTrinket(playerFolder.Trinkets.Trinket1.Value) or "nothing"
    local t2 = (playerFolder and playerFolder:FindFirstChild("Trinkets") and playerFolder.Trinkets:FindFirstChild("Trinket2")) and FormatTrinket(playerFolder.Trinkets.Trinket2.Value) or "nothing"
    
    local formattedChar = charName:gsub("(%u)", " %1"):gsub("^%s+", ""):lower()
    return "never thought i'd see a " .. formattedChar .. " with " .. t1 .. " and " .. t2 .. " using my autofarm.. oh well!"
end

local function GetRandomMonster()
    local room = workspace:FindFirstChild("CurrentRoom")
    if room then
        local monsters = {}
        for _, map in pairs(room:GetChildren()) do
            local mFolder = map:FindFirstChild("Monsters")
            if mFolder then
                for _, m in pairs(mFolder:GetChildren()) do
                    local cleanName = m.Name:gsub("Monster", "")
                    table.insert(monsters, cleanName)
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
        local phrases = {
            "auto vote card coming in never",
            "you're gonna encounter twisted dandy a shit ton of times because i never implemented a function to buy from dandy lmao",
            "don't be disrespectful, go give Twisted " .. monster .. " a big hug.",
            "i already know the autofarm doesn't pick up heals im gonna implement it eventually ok",
            "what, can't play the game normally? that's too bad..",
            "i'm scared.",
            GetSpecialPhrase()
        }
        CyclerLabel.Text = phrases[math.random(1, #phrases)]
        task.wait(math.random(15, 20))
    end
end)

-- Autofarm Functions
local function IsDangerNear(pos)
    local room = workspace:FindFirstChild("CurrentRoom")
    if not room then return false end
    for _, map in pairs(room:GetChildren()) do
        local mFolder = map:FindFirstChild("Monsters")
        if mFolder then
            for _, m in pairs(mFolder:GetChildren()) do
                if not IgnoreList[m.Name] and m:FindFirstChild("HumanoidRootPart") and (m.HumanoidRootPart.Position - pos).Magnitude < 40 then
                    return true
                end
            end
        end
    end
    return false
end

task.spawn(function()
    while true do
        if Enabled then
            local event = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and game.ReplicatedStorage.Events:FindFirstChild("SprintEvent")
            if event then event:FireServer(true) end
        end
        task.wait(25)
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
                    if cv and (cv.Value == LocalPlayer.Name or (cv:IsA("ObjectValue") and cv.Value and cv.Value.Name == LocalPlayer.Name)) then
                        return true
                    end
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
            -- 1. CRITICAL PRIORITY: Escape Logic
            if IsBeingChased() then
                Log(SpotterPhrases[math.random(1, #SpotterPhrases)])
                AbortExtractions()
                SafeTeleport(CFrame.new(SafeZonePos.Position + Vector3.new(0, 2, 0)))
                repeat task.wait(0.2) until not IsBeingChased()
                task.wait(2)
                continue
            end

            -- 2. Normal Operations
            local Room = workspace:FindFirstChild("CurrentRoom")
            local Info = workspace:FindFirstChild("Info")
            FloorLabel.Text = "Floor: " .. (Info and Info:FindFirstChild("Floor") and Info.Floor.Value or "?")
            
            for _, child in pairs(ListContainer:GetChildren()) do if not child:IsA("UIListLayout") then child:Destroy() end end
            
            local foundMonsters = false
            if Room then
                for _, map in pairs(Room:GetChildren()) do
                    local mFolder = map:FindFirstChild("Monsters")
                    if mFolder then
                        for _, m in pairs(mFolder:GetChildren()) do
                            local l = Instance.new("TextLabel", ListContainer)
                            l.Text = m.Name
                            l.TextColor3 = Color3.fromRGB(255, 100, 100)
                            l.BackgroundTransparency = 1
                            l.Size = UDim2.new(1, 0, 0, 15)
                            foundMonsters = true
                        end
                    end
                end
            end
            
            if not foundMonsters then
                local l = Instance.new("TextLabel", ListContainer)
                l.Text = "There aren’t any twisteds\nin the elevator, silly!"
                l.TextColor3 = Color3.fromRGB(255, 100, 100)
                l.BackgroundTransparency = 1
                l.Size = UDim2.new(1, 0, 0, 30) -- Increased height to accommodate 2 lines
                l.TextWrapped = true
            end

            if Info and Info:FindFirstChild("Panic") and Info.Panic.Value == true then
                Log("It's panic mode!\nTo the elevator we go...")
                local elev = workspace:FindFirstChild("Elevators") and workspace.Elevators:FindFirstChild("Elevator")
                if elev and elev:FindFirstChild("Base") then SafeTeleport(elev.Base.CFrame) end
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
                                    SafeTeleport(CFrame.new(item:GetPivot().Position + Vector3.new(0, 3, 0)))
                                    fireproximityprompt(p)
                                    Log("Collecting capsules\nor whatever this shit pmo")
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
                                if p and p.Enabled and not IsDangerNear(g:GetPivot().Position) then
                                    gen = g break 
                                end
                            end
                        end
                    end
                    if gen then
                        SafeTeleport(CFrame.new(gen:GetPivot().Position + Vector3.new(0, 3, 0)))
                        task.wait(0.3)
                        fireproximityprompt(gen:FindFirstChildWhichIsA("ProximityPrompt", true))
                        Log("Extracting...")
                    else
                        Log("Looking at the horizon\nof generators, be patient.")
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

loadstring(game:HttpGet("https://raw.githubusercontent.com/alihusam078588-web/Twilight-zone-loader/refs/heads/main/squirm.lua"))()

loadstring(game:HttpGet("https://raw.githubusercontent.com/thatONEworldthatihate/afkshit/refs/heads/main/afk.lua"))()
