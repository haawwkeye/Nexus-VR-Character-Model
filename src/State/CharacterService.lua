--[[
TheNexusAvenger

Manages VR characters.
--]]
--!strict

local Players = game:GetService("Players")

local NexusVRCharacterModel = script.Parent.Parent
local Character = require(NexusVRCharacterModel:WaitForChild("Character"))

local CharacterService = {}
CharacterService.__index = CharacterService

export type CharacterService = {
    new: () -> (CharacterService),

    GetCharacter: (self: CharacterService, Player: Player) -> (any?), --TODO: Add Character type.
}



--[[
Creates a character service.
--]]
function CharacterService.new(): CharacterService
    --Create the object.
    local self = {
        Characters = {},
    }
    setmetatable(self, CharacterService)

    --Connect clearing players.
    Players.PlayerRemoving:Connect(function(Player)
        self.Characters[Player] = nil
    end)

    --Return the object.
    return (self :: any) :: CharacterService
end

--[[
Returns the VR character for a player.
--]]
function CharacterService:GetCharacter(Player: Player): any? --TODO: Add Character type.
    --Return if the character is nil.
    if not Player.Character then
        return nil
    end

    --Create the VR character if it isn't valid.
    if not self.Characters[Player] or self.Characters[Player].Character ~= Player.Character then
        self.Characters[Player] = {
            Character = Player.Character,
            VRCharacter = Character.new(Player.Character),
        }
    end

    --Return the stored character.
    return self.Characters[Player].VRCharacter
end



return (CharacterService :: any) :: CharacterService