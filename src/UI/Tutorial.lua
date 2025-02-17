--[[
haawwkeye

Tutorial Message
--]]
--!strict

local MESSAGE_OPEN_TIME = 0.25


local TS = game:GetService("TweenService");
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local NexusVRCharacterModel = script.Parent.Parent
local TextButtonFactory = require(NexusVRCharacterModel:WaitForChild("NexusButton"):WaitForChild("Factory"):WaitForChild("TextButtonFactory")).CreateDefault(Color3.fromRGB(0, 170, 255))
TextButtonFactory:SetDefault("Theme", "RoundedCorners")
local NexusVRCore = require(ReplicatedStorage:WaitForChild("NexusVRCore")) :: any
local ScreenGui = NexusVRCore:GetResource("Container.ScreenGui")

local Tutorial = {}
Tutorial.__index = Tutorial



--[[
Creates the R6 message.
--]]
function Tutorial.new(): any
    local self = {}
    setmetatable(self, Tutorial)


    local function createController(position : UDim2 | nil, size : UDim2 | nil) : ImageLabel
        local Controller = Instance.new("ImageLabel")
        local ControllerStroke = Instance.new("ImageLabel")

        Controller.Name = "Controller"
        Controller.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Controller.BackgroundTransparency = 1
        Controller.ImageTransparency = 0.5
        Controller.Position = position or UDim2.new(0.25, 0, 0.15, 0)
        Controller.Size = size or UDim2.new(0.55, 0, 0.7, 0)
        Controller.Image = "http://www.roblox.com/asset/?id=13548990719"
        Controller.ImageColor3 = Color3.fromRGB(0, 0, 0)

        ControllerStroke.Name = "ControllerStroke"
        ControllerStroke.Parent = Controller
        ControllerStroke.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ControllerStroke.BackgroundTransparency = 1.000
        ControllerStroke.Position = UDim2.new(-0.025, 0, -0.015, 0)
        ControllerStroke.Size = UDim2.new(1, 0, 1, 0)
        ControllerStroke.Image = "http://www.roblox.com/asset/?id=13548990719"

        return Controller
    end

    --Set up the ScreenGui.
    local MessageScreenGui = ScreenGui.new()
    MessageScreenGui.ResetOnSpawn = false
    MessageScreenGui.Enabled = false
    MessageScreenGui.CanvasSize = Vector2.new(500, 500)
    MessageScreenGui.FieldOfView = 0
    MessageScreenGui.Easing = 0.25
    self.ScreenGui = MessageScreenGui

    --Create the logo and message.
    local Logo = Instance.new("ImageLabel")
    Logo.BackgroundTransparency = 1
    Logo.Size = UDim2.new(0.4, 0, 0.4, 0)
    Logo.Position = UDim2.new(0.3, 0, -0.1, 0)
    Logo.Image = "http://www.roblox.com/asset/?id=1499731139"
    Logo.Parent = MessageScreenGui:GetContainer()

    local UpperText = Instance.new("TextLabel")
    UpperText.BackgroundTransparency = 1
    UpperText.Size = UDim2.new(0.8, 0, 0.1, 0)
    UpperText.Position = UDim2.new(0.1, 0, 0.25, 0)
    UpperText.Font = Enum.Font.SourceSansBold
    UpperText.Text = "Tutorial"
    UpperText.TextScaled = true
    UpperText.TextColor3 = Color3.fromRGB(255, 255, 255)
    UpperText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    UpperText.TextStrokeTransparency = 0
    UpperText.Parent = MessageScreenGui:GetContainer()

    -- Create the Controller images
    local LeftController = createController(UDim2.new(0.1, 0, 0.625, 0), UDim2.new(0.2, 0, 0.3, 0));
    local RightController = createController(UDim2.new(0.7, 0, 0.625, 0), UDim2.new(0.2, 0, 0.3, 0));

    -- This is 100% not a good idea but I'm too lazy to find out a better way Lol
    -- Plus it works so /shrug
    local playing = false;

    local function playAnimation(rot : number, animTime : number)
        if playing or not MessageScreenGui.Enabled then return end;
        playing = true;
        
        local TI = TweenInfo.new(animTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut);
        local tween1 = TS:Create(LeftController, TI, {Rotation = rot});
        local tween2 = TS:Create(RightController, TI, {Rotation = -rot});

        tween2.Completed:Once(function()
            task.spawn(function()
                task.wait(2);
                playing = false;
                playAnimation(if rot == 180 then 0 else 180, if rot == 180 then 0.8 else 1);
            end)
        end)

        tween1:Play();
        tween2:Play();
    end

    LeftController.Parent = MessageScreenGui:GetContainer();
    RightController.Parent = MessageScreenGui:GetContainer();

    local LowerText = Instance.new("TextLabel")
    LowerText.BackgroundTransparency = 1
    LowerText.Size = UDim2.new(0.8, 0, 0.25, 0)
    LowerText.Position = UDim2.new(0.1, 0, 0.4, 0)
    LowerText.Font = Enum.Font.SourceSansBold
    LowerText.Text = "To enter the menu, flip your controllers upside down."
    LowerText.TextScaled = true
    LowerText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LowerText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    LowerText.TextStrokeTransparency = 0
    LowerText.Parent = MessageScreenGui:GetContainer()

    --Create and connect the close button.
    local CloseButton, CloseText = TextButtonFactory:Create()
    CloseButton.Size = UDim2.new(0.3, 0, 0.1, 0)
    CloseButton.Position = UDim2.new(0.35, 0, 0.7, 0)
    CloseButton.Parent = MessageScreenGui:GetContainer()
    CloseText.Text = "Ok"

    CloseButton.MouseButton1Down:Connect(function()
        self:Close()
    end)

    task.spawn(function()
        task.wait(2)
        playAnimation(180, 1)
    end)

    --Parent the message.
    MessageScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    return self
end

--[[
Sets the window open or closed.
--]]
function Tutorial:SetOpen(Open: boolean): ()
    warn(Open)
    --Determine the start and end values.
    local StartFieldOfView, EndFieldOfView = (Open and 0 or math.rad(40)), (Open and math.rad(40) or 0)

    --Show the message if it isn't visible.
    if Open then
        self.ScreenGui.Enabled = true
    end

    --Tween the field of view.
    local StartTime = tick()
    while tick() - StartTime < MESSAGE_OPEN_TIME do
        local Delta = (tick() - StartTime) / MESSAGE_OPEN_TIME
        Delta = (math.sin((Delta - 0.5) * math.pi) / 2) + 0.5
        self.ScreenGui.FieldOfView = StartFieldOfView + ((EndFieldOfView - StartFieldOfView) * Delta)
        RunService.RenderStepped:Wait()
    end

    --Hide thhe message if it is closed.
    if EndFieldOfView == 0 then
        self.ScreenGui.Enabled = false
    end
end

--[[
Opens the message.
--]]
function Tutorial:Open(): ()
    self:SetOpen(true)
end
--[[
Closes the message.
--]]
function Tutorial:Close(): ()
    self:SetOpen(false)
end



return Tutorial