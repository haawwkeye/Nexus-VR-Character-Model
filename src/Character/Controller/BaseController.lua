 --[[
TheNexusAvenger

Base class for controlling the local character.
--]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local NexusVRCharacterModel = require(script.Parent.Parent.Parent)
local NexusObject = NexusVRCharacterModel:GetResource("NexusInstance.NexusObject")
local CameraService = NexusVRCharacterModel:GetInstance("State.CameraService")
local CharacterService = NexusVRCharacterModel:GetInstance("State.CharacterService")
local VRInputService = NexusVRCharacterModel:GetInstance("State.VRInputService")

local BaseController = NexusObject:Extend()
BaseController:SetClassName("BaseController")



--[[
Updates the character. Returns if it changed.
--]]
function BaseController:UpdateCharacterReference()
    local LastCharacter = self.Character
    self.Character = CharacterService:GetCharacter(Players.LocalPlayer)
    if not self.Character then
        return
    end
    return LastCharacter ~= self.Character
end

--[[
Enables the controller.
--]]
function BaseController:Enable()
    if not self.Connections then self.Connections = {} end

    --Update the character and return if the character is nil.
    self:UpdateCharacterReference()
    if not self.Character then
        return
    end

    --Disable auto rotate so that the default controls work.
    self.Character.Humanoid.AutoRotate = false

    --Disable the controls.
    --Done in a loop to ensure changed controllers are disabled.
    coroutine.wrap(function()
        local ControlModule = require(Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
        while self.Character do
            ControlModule:Disable()
            wait()
        end
    end)()
end

--[[
Disables the controller.
--]]
function BaseController:Disable()
    self.Character = nil
    self.LastHeadCFrame = nil
    for _,Connection in pairs(self.Connections) do
        Connection:Disconnect()
    end
    self.Connections = nil
end

--[[
Scales the local-space input CFrame based on
the height multiplier of the character.
--]]
function BaseController:ScaleInput(InputCFrame)
    --Return the original CFrame if there is no character.
    if not self.Character then
        return InputCFrame
    end

    --Return the modified CFrame.
    return CFrame.new(InputCFrame.Position * (self.Character.ScaleValues.BodyHeightScale.Value - 1)) * InputCFrame
end

--[[
Updates the reference world CFrame.
--]]
function BaseController:UpdateCharacter()
    --Return if the character is nil.
    local CharacterChanged = self:UpdateCharacterReference()
    if not self.Character then
        return
    end
    if CharacterChanged then
        self:Enable()
    end
    self.Character.TweenComponents = false

    --Get the VR inputs.
    local VRInputs = VRInputService:GetVRInputs()
    local VRHeadCFrame = self:ScaleInput(VRInputs[Enum.UserCFrame.Head])
    local VRLeftHandCFrame,VRRightHandCFrame = self:ScaleInput(VRInputs[Enum.UserCFrame.LeftHand]),self:ScaleInput(VRInputs[Enum.UserCFrame.RightHand])

    --Offset the character by the change in the head input.
    if self.LastHeadCFrame then
        --Determine the XZ rotation of the seat, if any.
        local SeatPart = self.Character:GetHumanoidSeatPart()
        local SeatRotationXZ = CFrame.new()
        if SeatPart then
            local SeatCFrame = SeatPart.CFrame
            SeatRotationXZ = (CFrame.new(SeatCFrame.Position) * CFrame.Angles(0,math.atan2(-SeatCFrame.LookVector.X,-SeatCFrame.LookVector.Z),0)):Inverse() * SeatCFrame
        end

        --Get the new CFrame of the eyes by offsetting the position and Y axis of the change in the VR head CFrame.
        --X and Z are handled absolutely for when the player teleports.
        local CharacterEyeCFrame = self.Character.Head.Head.CFrame * self.Character.Head:GetEyesOffset()
        local InputDelta = self.LastHeadCFrame:Inverse() * VRHeadCFrame
        local HeadRotationXZ = (CFrame.new(VRHeadCFrame.Position) * CFrame.Angles(0,math.atan2(-VRHeadCFrame.LookVector.X,-VRHeadCFrame.LookVector.Z),0)):Inverse() * VRHeadCFrame
        local BaseEyesCFrameWithRotationOffset = CharacterEyeCFrame * CFrame.new(InputDelta.Position) * CFrame.Angles(0,math.atan2(-InputDelta.LookVector.X,-InputDelta.LookVector.Z),0)
        local BaseEyesPosition = CFrame.new(BaseEyesCFrameWithRotationOffset.Position)
        BaseEyesCFrameWithRotationOffset = SeatRotationXZ:Inverse() * BaseEyesCFrameWithRotationOffset
        local NewCharacterEyeCFrame = BaseEyesPosition * SeatRotationXZ * CFrame.Angles(0,math.atan2(-BaseEyesCFrameWithRotationOffset.LookVector.X,-BaseEyesCFrameWithRotationOffset.LookVector.Z),0) * HeadRotationXZ

        --Update the character.
        local HeadToLeftHandCFrame = VRHeadCFrame:Inverse() * VRLeftHandCFrame
        local HeadToRightHandCFrame = VRHeadCFrame:Inverse() * VRRightHandCFrame
        self.Character:UpdateFromInputs(NewCharacterEyeCFrame,NewCharacterEyeCFrame * HeadToLeftHandCFrame,NewCharacterEyeCFrame * HeadToRightHandCFrame)
    end
    self.LastHeadCFrame = VRHeadCFrame

    --Update the camera.
    if self.Character.Parts.HumanoidRootPart:IsDescendantOf(Workspace) then
        --Update the camera based on the character.
        --Done based on the HumanoidRootPart instead of the Head because of Motors not updating the same frame, leading to a delay.
        local HumanoidRootPartCFrame = self.Character.Parts.HumanoidRootPart.CFrame
        local LowerTorsoCFrame = HumanoidRootPartCFrame * self.Character.Attachments.HumanoidRootPart.RootRigAttachment.CFrame * self.Character.Motors.Root.Transform * self.Character.Attachments.LowerTorso.RootRigAttachment.CFrame:Inverse()
        local UpperTorsoCFrame = LowerTorsoCFrame * self.Character.Attachments.LowerTorso.WaistRigAttachment.CFrame * self.Character.Motors.Waist.Transform * self.Character.Attachments.UpperTorso.WaistRigAttachment.CFrame:Inverse()
        local HeadCFrame = UpperTorsoCFrame * self.Character.Attachments.UpperTorso.NeckRigAttachment.CFrame * self.Character.Motors.Neck.Transform * self.Character.Attachments.Head.NeckRigAttachment.CFrame:Inverse()
        CameraService:UpdateCamera(HeadCFrame * self.Character.Head:GetEyesOffset())
    else
        --Update the camera based on the last CFrame if the motors can't update (not in Workspace).
        local CurrentCameraCFrame = Workspace.CurrentCamera.CFrame
        local LastHeadCFrame = self.LastHeadCFrame or CFrame.new()
        local HeadCFrame = self:ScaleInput(VRInputService:GetVRInputs()[Enum.UserCFrame.Head])
        Workspace.CurrentCamera.CFrame = CurrentCameraCFrame * LastHeadCFrame:Inverse() * HeadCFrame
        self.LastHeadCFrame = HeadCFrame
    end
end



return BaseController