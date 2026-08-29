-- This script was generated using MoonVeil 2.0.23 [https://moonveil.cc]
local StarterGui=game:GetService"StarterGui"
local rawNamecall
if getrawmetatable and hookmetamethod then
    local gmt=getrawmetatable(game)
    rawNamecall=hookmetamethod(game,"__namecall",function(self,...)
        local method=getnamecallmethod()
        local args={
            ...
        }
        if(method=="SetCore"or method=="SetCoreGuiEnabled")and args[1]=="SendNotification"then
            return nil
        end
        return rawNamecall(self,...)
    end)
end
pcall(function()
    local CoreGui=game:GetService"CoreGui"
    local RobloxGui=CoreGui:FindFirstChild"RobloxGui"
    if RobloxGui then
        local NotificationFrame=RobloxGui:FindFirstChild"NotificationFrame"
        if NotificationFrame then
            NotificationFrame.ChildAdded:Connect(function(child)
                task.wait()
                child:Destroy()
            end)
            for _,child in pairs(NotificationFrame:GetChildren())do
                child:Destroy()
            end
        end
    end
end)
local WindUI=loadstring(game:HttpGet"https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")()
task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/christmas-cookie/extensions/refs/heads/main/arcademachine",true))()
    end)
end)
WindUI:AddTheme{
    Name="PurpleTheme",
    Accent=Color3 .fromRGB(147,51,234),
    Outline=Color3 .fromRGB(88,28,135),
    Text=Color3 .fromRGB(255,255,255),
    PlaceholderText=Color3 .fromRGB(168,85,247),
    Background=Color3 .fromRGB(18,10,28),
    Secondary=Color3 .fromRGB(28,15,45),
    Tertiary=Color3 .fromRGB(38,20,60)
}
local Window=Window or WindUI:CreateWindow{
    Title="VoidExtractor",
    Icon="rbxassetid://133208797975838",
    Author="@seanthedoll on discord",
    Folder="VoidExtractor_DW",
    Size=UDim2 .fromOffset(450,300),
    Transparent=true,
    Theme="PurpleTheme",
    SideBarWidth=140,
    HasOutline=false,
    ToggleOutline=false,
    Key=Enum.KeyCode.Space
}
Window:Tag{
    Title="1.0-beta4",
    Color=Color3 .fromRGB(192,132,252)
}
local HasNotifiedClose=false
Window.OnClose=Window.OnClose or function()
end
task.spawn(function()
    local UserInputService=game:GetService"UserInputService"
    UserInputService.InputBegan:Connect(function(input,gameProcessed)
        if input.KeyCode==Enum.KeyCode.Space then
            if Window.Enabled and not HasNotifiedClose then
                HasNotifiedClose=true
                WindUI:Notify{
                    Title="VoidExtractor",
                    Content="Press Space to re-open the UI!",
                    Duration=5
                }
            end
        end
    end)
end)
local MainTab=Window:Tab{
    Title="Main",
    Icon="house"
}
MainTab:Select()
MainTab:Paragraph{
    Title="Notice",
    Desc="This is a very experimental autofarm for Dandy\226\128\153s World. Please report any bugs you encounter to the developer!"
}
local Players=game:GetService"Players"
local ReplicatedStorage=game:GetService"ReplicatedStorage"
local LocalPlayer=Players.LocalPlayer
local Enabled=false
local DefaultGravity=workspace.Gravity
local SprintThread=nil
local IgnoreList={
    ["RazzleDazzleMonster"]=true,
    ["SquirmMonster"]=true,
    ["RodgerMonster"]=true,
    ["WaxwellMonster"]=true,
    ["BlottMonster"]=true
}
local PriorityItems={
    ["ResearchCapsule"]=true,
    ["Tape"]=true,
    ["Bandage"]=true,
    ["HealthKit"]=true
}
local MainToons={
    ["Astro"]=true,
    ["Bobette"]=true,
    ["Shelly"]=true,
    ["Sprout"]=true,
    ["Gourdy"]=true,
    ["Bassie"]=true,
    ["Pebble"]=true,
    ["Vee"]=true
}
local function SafeTeleport(targetCFrame)
    local char=LocalPlayer.Character
    if char and char:FindFirstChild"HumanoidRootPart"then
        char:PivotTo(targetCFrame)
    end
end
local function IsPlayerExtracting()
    local inGamePlayers=workspace:FindFirstChild"InGamePlayers"
    if inGamePlayers then
        local pData=inGamePlayers:FindFirstChild(LocalPlayer.Name)
        if pData and pData:FindFirstChild"Decoding"then
            return pData.Decoding.Value=="Generator"
        end
    end
    return false
end
local function IsBeingChased()
    local room=workspace:FindFirstChild"CurrentRoom"
    if not room then
        return false
    end
    for _,map in pairs(room:GetChildren())do
        local mFolder=map:FindFirstChild"Monsters"
        if mFolder then
            for _,m in pairs(mFolder:GetChildren())do
                if not IgnoreList[m.Name]then
                    local cv=m:FindFirstChild"ChasingValue"
                    if cv and(cv.Value==LocalPlayer.Name or(cv:IsA"ObjectValue"and cv.Value and cv.Value.Name==LocalPlayer.Name))then
                        return true
                    end
                end
            end
        end
    end
    return false
end
local function IsDangerNear(pos)
    local room=workspace:FindFirstChild"CurrentRoom"
    if not room then
        return false
    end
    for _,map in pairs(room:GetChildren())do
        local mFolder=map:FindFirstChild"Monsters"
        if mFolder then
            for _,m in pairs(mFolder:GetChildren())do
                if not IgnoreList[m.Name]and m:FindFirstChild"HumanoidRootPart"then
                    if(m.HumanoidRootPart.Position-pos).Magnitude<35 then
                        return true
                    end
                end
            end
        end
    end
    return false
end
local function AbortExtractions()
    local room=workspace:FindFirstChild"CurrentRoom"
    if not room then
        return
    end
    for _,map in pairs(room:GetChildren())do
        local gens=map:FindFirstChild"Generators"
        if gens then
            for _,gen in pairs(gens:GetChildren())do
                local stats=gen:FindFirstChild"Stats"
                local stopRemote=stats and stats:FindFirstChild"StopInteracting"
                if stopRemote then
                    stopRemote:FireServer"Stop"
                end
            end
        end
    end
end
local function UseInventoryItem(slotName)
    local char=LocalPlayer.Character
    if char then
        local inv=char:FindFirstChild"Inventory"
        local slotObj=inv and inv:FindFirstChild(slotName)
        local itemEvent=ReplicatedStorage:FindFirstChild"Events"and ReplicatedStorage.Events:FindFirstChild"ItemEvent"
        if slotObj and itemEvent then
            local args={
                char,
                slotObj
            }
            itemEvent:InvokeServer(unpack(args))
        end
    end
end
local function AreAllInventorySlotsFull()
    local inGamePlayers=workspace:FindFirstChild"InGamePlayers"
    local pData=inGamePlayers and inGamePlayers:FindFirstChild(LocalPlayer.Name)
    local invFolder=pData and pData:FindFirstChild"Inventory"
    if not invFolder then
        return false
    end
    local slot1=invFolder:FindFirstChild"Slot1"and invFolder.Slot1 .Value
    local slot2=invFolder:FindFirstChild"Slot2"and invFolder.Slot2 .Value
    local slot3=invFolder:FindFirstChild"Slot3"and invFolder.Slot3 .Value
    local function isValidItem(val)
        return val~=nil and val~=""and val~="None"
    end
    if isValidItem(slot1)and isValidItem(slot2)and isValidItem(slot3)then
        return true
    end
    return false
end
local function HandleHealthAndItems()
    local char=LocalPlayer.Character
    local hum=char and char:FindFirstChildOfClass"Humanoid"
    if not hum then
        return
    end
    local currentHealth=math.floor(hum.Health)
    local inGamePlayers=workspace:FindFirstChild"InGamePlayers"
    local pData=inGamePlayers and inGamePlayers:FindFirstChild(LocalPlayer.Name)
    if not pData then
        return
    end
    local toonName=pData:GetAttribute"ToonName"or""
    local invFolder=pData:FindFirstChild"Inventory"
    if not invFolder then
        return
    end
    local slots={
        Slot1=invFolder:FindFirstChild"Slot1"and invFolder.Slot1 .Value or"",
        Slot2=invFolder:FindFirstChild"Slot2"and invFolder.Slot2 .Value or"",
        Slot3=invFolder:FindFirstChild"Slot3"and invFolder.Slot3 .Value or""
    }
    local targetSlot=nil
    if MainToons[toonName]then
        if currentHealth<=1 then
            for slotName,val in pairs(slots)do
                if val=="HealthKit"or val=="Bandage"then
                    targetSlot=slotName
                    break
                end
            end
        end
    elseif toonName=="Soulvester"then
        if currentHealth==3 then
            for slotName,val in pairs(slots)do
                if val=="Bandage"then
                    targetSlot=slotName
                    break
                end
            end
        elseif currentHealth<=2 then
            if currentHealth==1 then
                for slotName,val in pairs(slots)do
                    if val=="HealthKit"then
                        targetSlot=slotName
                        break
                    end
                end
                if not targetSlot then
                    for slotName,val in pairs(slots)do
                        if val=="Bandage"then
                            targetSlot=slotName
                            break
                        end
                    end
                end
            elseif currentHealth==2 then
                for slotName,val in pairs(slots)do
                    if val=="Bandage"then
                        targetSlot=slotName
                        break
                    end
                end
            end
        end
    else
        if currentHealth==2 then
            for slotName,val in pairs(slots)do
                if val=="Bandage"then
                    targetSlot=slotName
                    break
                end
            end
        elseif currentHealth==1 then
            for slotName,val in pairs(slots)do
                if val=="HealthKit"then
                    targetSlot=slotName
                    break
                end
            end
            if not targetSlot then
                for slotName,val in pairs(slots)do
                    if val=="Bandage"then
                        targetSlot=slotName
                        break
                    end
                end
            end
        end
    end
    if targetSlot then
        UseInventoryItem(targetSlot)
    end
end
local function RunAutoFarm()
    task.spawn(function()
        while Enabled do
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild"HumanoidRootPart"
            HandleHealthAndItems()
            if IsBeingChased()or(hrp and IsDangerNear(hrp.Position))then
                local abortTask=task.spawn(function()
                    while IsBeingChased()or(hrp and IsDangerNear(hrp.Position))do
                        AbortExtractions()
                        task.wait(0.1)
                    end
                end)
                repeat
                    local randomX=math.random(-5000,5000)
                    local randomZ=math.random(-5000,5000)
                    if char and hrp then
                        hrp.AssemblyLinearVelocity=Vector3 .zero
                        hrp.AssemblyAngularVelocity=Vector3 .zero
                        char:PivotTo(CFrame.new(randomX,99999,randomZ))
                    end
                    task.wait(0.1)
                until not IsBeingChased()and not(hrp and IsDangerNear(hrp.Position))
                task.wait(3)
                continue
            end
            local Info=workspace:FindFirstChild"Info"
            if Info and Info:FindFirstChild"Panic"and Info.Panic.Value==true then
                local elev=workspace:FindFirstChild"Elevators"and workspace.Elevators:FindFirstChild"Elevator"
                if elev and elev:FindFirstChild"Base"then
                    SafeTeleport(elev.Base.CFrame)
                end
                task.wait(0.5)
                continue
            end
            local Room=workspace:FindFirstChild"CurrentRoom"
            local activePriorityItems=PriorityItems
            if AreAllInventorySlotsFull()then
                activePriorityItems={
                    ["ResearchCapsule"]=true,
                    ["Tape"]=true
                }
            end
            local foundItem=false
            if Room then
                for _,map in pairs(Room:GetChildren())do
                    local itemsFolder=map:FindFirstChild"Items"
                    if itemsFolder then
                        for _,item in pairs(itemsFolder:GetChildren())do
                            if activePriorityItems[item.Name]then
                                local promptHolder=item:FindFirstChild"Prompt"
                                local prompt=promptHolder and promptHolder:FindFirstChild"ProximityPrompt"
                                if prompt and prompt.Enabled and not IsDangerNear(item:GetPivot().Position)then
                                    SafeTeleport(item:GetPivot()*CFrame.new(0,-3.5,0))
                                    if fireproximityprompt then
                                        fireproximityprompt(prompt)
                                    end
                                    foundItem=true
                                    task.wait(0.05)
                                    break
                                end
                            end
                        end
                    end
                    if foundItem then
                        break
                    end
                end
            end
            if foundItem then
                continue
            end
            if not IsPlayerExtracting()and Room then
                local targetGen,targetPrompt=nil,nil
                for _,map in pairs(Room:GetChildren())do
                    local gens=map:FindFirstChild"Generators"
                    if gens then
                        for _,g in pairs(gens:GetChildren())do
                            local p=g:FindFirstChildWhichIsA("ProximityPrompt",true)
                            if p and p.Enabled and not IsDangerNear(g:GetPivot().Position)then
                                targetGen=g
                                targetPrompt=p
                                break
                            end
                        end
                    end
                    if targetGen then
                        break
                    end
                end
                if targetGen and targetPrompt then
                    SafeTeleport(targetGen:GetPivot()*CFrame.new(0,3,0))
                    task.wait(0.1)
                    if not IsBeingChased()and not IsDangerNear(targetGen:GetPivot().Position)and targetPrompt.Enabled then
                        fireproximityprompt(targetPrompt)
                    end
                end
            end
            task.wait(0.2)
        end
    end)
end
local AutofarmToggle=MainTab:Toggle{
    Title="Autofarm",
    Desc="Enables the autofarm!",
    Value=false,
    Callback=function(Value)
        Enabled=Value
        if Enabled then
            workspace.Gravity=0
            local SkillEvent=ReplicatedStorage:FindFirstChild"Events"and ReplicatedStorage.Events:FindFirstChild"SkillcheckUpdate"
            if SkillEvent then
                SkillEvent.OnClientInvoke=function()
                    return"supercomplete"
                end
            end
            RunAutoFarm()
            SprintThread=task.spawn(function()
                local lp=game.Players.LocalPlayer
                local rs=game:GetService"ReplicatedStorage"
                local sprintEvent=rs:WaitForChild"Events":WaitForChild"SprintEvent"
                local isSprinting=false
                while Enabled and task.wait(0.2)do
                    local stats=workspace:FindFirstChild"InGamePlayers"and workspace.InGamePlayers:FindFirstChild(lp.Name)and workspace.InGamePlayers[lp.Name]:FindFirstChild"Stats"and workspace.InGamePlayers[lp.Name].Stats:FindFirstChild"CurrentStamina"
                    if stats then
                        local stam=stats.Value
                        if not isSprinting and(stam>20)then
                            sprintEvent:FireServer(true)
                            isSprinting=true
                        elseif isSprinting and(stam<20)then
                            sprintEvent:FireServer(false)
                            isSprinting=false
                        elseif not isSprinting and(stam>=40)then
                            sprintEvent:FireServer(true)
                            isSprinting=true
                        end
                    end
                end
            end)
        else
            workspace.Gravity=DefaultGravity
            local SkillEvent=ReplicatedStorage:FindFirstChild"Events"and ReplicatedStorage.Events:FindFirstChild"SkillcheckUpdate"
            if SkillEvent then
                SkillEvent.OnClientInvoke=nil
            end
            if SprintThread then
                task.cancel(SprintThread)
                SprintThread=nil
            end
            pcall(function()
                ReplicatedStorage.Events.SprintEvent:FireServer(false)
            end)
        end
    end
}
local VirtualUser=game:GetService"VirtualUser"
local AntiIdleToggle=MainTab:Toggle{
    Title="Anti-Idle",
    Desc="Prevents you from getting kicked for inactivity.",
    Value=true,
    Callback=function(Value)
        if Value then
            _G.AntiIdleConnection=LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2 .new())
            end)
        else
            if _G.AntiIdleConnection then
                _G.AntiIdleConnection:Disconnect()
                _G.AntiIdleConnection=nil
            end
        end
    end
}
local EpilepsyToggle=MainTab:Toggle{
    Title="Epilepsy Helper",
    Desc="Fixes the camera onto the void to avoid flickering imagery.",
    Value=false,
    Callback=function(Value)
        local cam=workspace.CurrentCamera
        if Value then
            cam.CameraType=Enum.CameraType.Scriptable
            cam.CFrame=CFrame.new(0,99999,0)
            _G.EpilepsyConnection=game:GetService"RunService".RenderStepped:Connect(function()
                if cam.CameraType~=Enum.CameraType.Scriptable then
                    cam.CameraType=Enum.CameraType.Scriptable
                end
                cam.CFrame=CFrame.new(0,99999,0)
            end)
        else
            if _G.EpilepsyConnection then
                _G.EpilepsyConnection:Disconnect()
                _G.EpilepsyConnection=nil
            end
            cam.CameraType=Enum.CameraType.Custom
            cam.CameraSubject=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass"Humanoid"
        end
    end
}
