--[[
TheNexusAvenger

Loads Nexus VR Character Model.
--]]
--!nocheck

--Client should send replication at 30hz.
--A buffer is added in case this rate is exceeded
--briefly, such as an unstable connection.
local REPLICATION_RATE_LIMIT = 35



local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local StarterPlayer = game:GetService("StarterPlayer")

local Settings = require(script:WaitForChild("State"):WaitForChild("Settings")).GetInstance()
local RateLimiter = require(script:WaitForChild("State"):WaitForChild("RateLimiter"))

local NexusVRCharacterModel = {}

-- Convert the string into a instance (hopefully works)
function ConvertToInstance(str : string) : Instance | nil
    local inst = nil;
    local success, err = pcall(function()
        local base = game;
        local list = str:split(".");
        for _, v in pairs(list) do
            base = base[v]
        end
        inst = base;
    end)

    return if not success then nil else inst;
end

function setupChar(plr)
	local char = plr.Character;
	local isEnabled = Settings:GetSetting("Appearance.EnableOverheadGui");
	local Parent = ConvertToInstance(Settings:GetSetting("Appearance.OverheadGuiParent"));

	print(isEnabled, typeof(isEnabled), Parent, typeof(Parent));

	if isEnabled and (Parent ~= nil and typeof(Parent) == "Instance" and Parent:IsA("BillboardGui")) then
		-- This should be an BillboardGui unless the developer changed it...
		-- Fixed by adding a Instance type check
		local head = char:WaitForChild("Head");
		if head:FindFirstChild(Parent.Name) == nil then
			local gui : BillboardGui = Parent:Clone();
			
			gui.PlayerToHideFrom = plr;
			gui.Adornee = head;
			gui.Parent = head;
		end
	end
	
	wait(0.1) -- force wait to make sure it's loaded. That and to give the client some time to wait for the event

	ReplicatedStorage:WaitForChild("VREnabled"):FireClient(plr);
end


--[[
Sets the configuration to use. Intended to be
run once by the server.
--]]
function NexusVRCharacterModel:SetConfiguration(Configuration: any): ()
    --Create the value.
    local ConfigurationValue = script:FindFirstChild("Configuration")
    if not ConfigurationValue then
        ConfigurationValue = Instance.new("StringValue")
        ConfigurationValue.Name = "Configuration"
        ConfigurationValue.Parent = script
    end

    --Store the configuration.
    ConfigurationValue.Value = HttpService:JSONEncode(Configuration)
    Settings:SetDefaults(Configuration)
end

--[[
Loads Nexus VR Character Model.
--]]
function NexusVRCharacterModel:Load(): ()
    --Return if a version is already loaded.
    if ReplicatedStorage:FindFirstChild("NexusVRCharacterModel") then
        return
    end

    local VREnabledRemote = Instance.new("RemoteEvent");
    VREnabledRemote.Name = "VREnabled";

    VREnabledRemote.OnServerEvent:Connect(function(plr)
        -- We want to overide the char so wait until it's loaded before you replace it
        local char = plr.Character or plr.CharacterAdded:Wait();
        local oldChar = char;

        -- This should be Humanoid so don't worry about that
        if char:WaitForChild("Humanoid").RigType ~= Enum.HumanoidRigType.R6 then return setupChar(plr) end;

        local charDesc = game.Players:GetHumanoidDescriptionFromUserId(plr.CharacterAppearanceId)
        char = game.Players:CreateHumanoidModelFromDescription(charDesc, Enum.HumanoidRigType.R15)

        -- PrimaryPart shouldn't be nil so no need to worry about that
        char:PivotTo(oldChar.PrimaryPart.CFrame)

        char.Name = plr.Name
        plr.Character = char
        char.Parent = workspace
        oldChar:Destroy()

        setupChar(plr)
    end)

    VREnabledRemote.Parent = ReplicatedStorage;

    --Rename and move the script to ReplicatedStorage.
    script.Name = "NexusVRCharacterModel"
    script:WaitForChild("NexusVRCore").Parent = ReplicatedStorage
    script.Parent = ReplicatedStorage;

    --Output any warnings.
    (require(ReplicatedStorage:WaitForChild("NexusVRCharacterModel"):WaitForChild("Util"):WaitForChild("Warnings")) :: any)()

    --Set up the client scripts.
    local NexusVRCharacterModelClientLoader = script:WaitForChild("NexusVRCharacterModelClientLoader")
    for _,Player in pairs(Players:GetPlayers()) do
        task.spawn(function()
            --Create and store a ScreenGui with the script.
            --This prevents the script disappearing on respawn.
            local ScreenGui = Instance.new("ScreenGui")
            ScreenGui.ResetOnSpawn = false
            ScreenGui.Name = "NexusVRCharacterModelClientLoader"
            NexusVRCharacterModelClientLoader:Clone().Parent = ScreenGui
            ScreenGui.Parent = Player:WaitForChild("PlayerGui")
        end)
    end
    NexusVRCharacterModelClientLoader:Clone().Parent = StarterPlayer:WaitForChild("StarterPlayerScripts")

    --Set up replication.
    local ReadyPlayers = {}
    local UpdateRateLimiter = RateLimiter.new(REPLICATION_RATE_LIMIT)

    local UpdateInputsEvent = Instance.new("RemoteEvent")
    UpdateInputsEvent.Name = "UpdateInputs"
    UpdateInputsEvent.Parent = script

    local ReplicationReadyEvent = Instance.new("RemoteEvent")
    ReplicationReadyEvent.Name = "ReplicationReady"
    ReplicationReadyEvent.Parent = script

    UpdateInputsEvent.OnServerEvent:Connect(function(Player,HeadCFrame,LeftHandCFrame,RightHandCFrame)
        --Ignore the input if 3 CFrames aren't given.
        if typeof(HeadCFrame) ~= "CFrame" then return end
        if typeof(LeftHandCFrame) ~= "CFrame" then return end
        if typeof(RightHandCFrame) ~= "CFrame" then return end

        --Ignore if the rate limit was reached.
        if UpdateRateLimiter:RateLimitReached(Player) then return end

        --Replicate the CFrames to the other players.
        for _,OtherPlayer in Players:GetPlayers() do
            if Player ~= OtherPlayer and ReadyPlayers[OtherPlayer] then
                UpdateInputsEvent:FireClient(OtherPlayer,Player,HeadCFrame,LeftHandCFrame,RightHandCFrame)
            end
        end
    end)

    ReplicationReadyEvent.OnServerEvent:Connect(function(Player)
        ReadyPlayers[Player] = true
    end)

    Players.PlayerRemoving:Connect(function(Player)
        ReadyPlayers[Player] = nil
    end)

    --Load Nexus VR Backpack.
    if Settings:GetSetting("Extra.NexusVRBackpackEnabled") ~= false then
        (require(10728805649) :: any)()
    end
end




NexusVRCharacterModel.Api = (require(script:WaitForChild("Api")) :: any)()
return NexusVRCharacterModel