--[[
TheNexusAvenger

Loads Nexus VR Character Model.
GitHub: TheNexusAvenger/Nexus-VR-Character-Model
--]]

local headGui = script:WaitForChild("VRHeadGui", 3);
if headGui == nil then
    headGui = {}
    function headGui:GetFullName()
        return nil
    end
end

local Configuration = {
    Appearance = {
        -- Should we force R15 if they use R6?
        -- This might break your game so make sure the game supports R15 before enabling this
        -- Plus this loads the character like a morth so it might not trigger character added idk
        -- Haven't tested that
        ForceR15ForR6 = true,

        -- Should there be an OverheadGui?
        -- This is the VRHeadGui if you want to edit it
        -- if missing there just won't be an Gui
        EnableOverheadGui = true,
        OverheadGuiParent = headGui:GetFullName(),

        -- This is for the Roblox Value.
		-- I might attempt to make a custom version that's better but for now might be better to just wait for roblox.
		-- When true, a VR player's view fades to black when their head collides with an object.
		-- This property prevents players from being able to see through walls while in VR.
        -- Disabling this will fix the screen going black randomly when you collide with something.
        -- https://devforum.roblox.com/t/vr-screen-becomes-black-due-to-non-transparent-character/2215099
		FadeOutViewOnCollision = true,

        --Transparency of the character when in first person.
        LocalCharacterTransparency = 0.5,

        --If true, arms will be allowed to disconnect.
        --Recommended to be true locally so that the controllers match the hands,
        --and false for other players so that arms appear normal.
        LocalAllowArmDisconnection = true,
        NonLocalAllowArmDisconnection = true,

        --Maximum angle the neck can turn before the torso turns.
        MaxNeckRotation = math.rad(35),
        MaxNeckSeatedRotation = math.rad(60),

        --Maximum angle the neck can tilt before the torso tilts.
        MaxNeckTilt = math.rad(60),

        --Maximum angle the center of the torso can bend.
        MaxTorsoBend = math.rad(10),
    },
    Camera = {
        --Options for the camera that can be enabled by the user.
        EnabledCameraOptions = {
            "Default",
            "ThirdPersonTrack",
        },

        --Default camera option.
        DefaultCameraOption = "Default",
    },
    Movement = {
        --Movement methods that can be enabled by the user.
        EnabledMovementMethods = {
            "Teleport",
            "SmoothLocomotion",
            --"None", --Disables controls but still allows character updates. Intended for stationary games or momentarily freezing players.
        },

        --Default movement method.
        DefaultMovementMethod = "Teleport",

        --Blur effect for snap turning and teleports.
        SnapTeleportBlur = true,
    },
    Menu = {
        --If true, a gesture will be active for opening
        --the Nexus VR Character Model menu. If you manually
        --set this to false, you will lock players from being
        --able to change camera options, movement options,
        --recallibration, and chat.
        MenuToggleGestureActive = true,
    },
    Output = {
        --To suppress warnings from Nexus VR Character Model
        --where supported (missing configuration entries),
        --the names of the warnings can be added here.
        --Add "All" to suppress all warnings.
        SuppressWarnings = {},

        --If true, clients can check the client output to see
        --if Nexus VR Character Model is loaded. In order for
        --the message to appear, the client must hold down Ctrl
        --(left or right) when opening the F9 developer console.
        AllowClientToOutputLoadedMessage = true,
    },
    Extra = {
        --If true, Nexus VR Backpack (https://github.com/TheNexusAvenger/Nexus-VR-Backpack)
        --will be inserted into the game and loaded. This replaces
        --the default Roblox backpack.
        NexusVRBackpackEnabled = true,
        -- If true, VirtualKeyboard (https://github.com/haawwkeye/VirtualKeyboard)
        -- will be load the VirtualKeyboard that's in CoreGui (with some fixes to make it work better)
        -- Certain elements like the "Voice to Text" will not work
        -- I have no idea what else to say here so yea that's it
        VirtualKeyboard = true,
    },
}



--Load the Nexus VR Character Model module.
local NexusVRCharacterModelModule
local MainModule = script:FindFirstChild("MainModule")
if MainModule then
    NexusVRCharacterModelModule = require(MainModule)
else
    -- This is the default as I'm not planning on make a model for now
    -- aka MainModule is required
    NexusVRCharacterModelModule = require(10728814921)
end

--Load Nexus VR Character Model.
NexusVRCharacterModelModule:SetConfiguration(Configuration)
NexusVRCharacterModelModule:Load()