--[[
    GravityController.server.lua
    Server script that manages Zero Gravity zones in the game.
    
    Detects parts named "ZeroG_Zone" and toggles gravity for players
    entering/exiting these zones.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Wait for PhysicsUtils module
local PhysicsUtils = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PhysicsUtils"))

-- Track players in each zone to prevent duplicate toggles
local playersInZone: {[Part]: {[Player]: boolean}} = {}

--[[
    Gets the player from a hit part (checks if it's part of a character)
    @param hit BasePart - The part that was touched
    @return Player? - The player if found, nil otherwise
]]
local function getPlayerFromHit(hit: BasePart): Player?
    local character = hit:FindFirstAncestorOfClass("Model")
    if not character then
        return nil
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return nil
    end

    return Players:GetPlayerFromCharacter(character)
end

--[[
    Handles a player entering a Zero Gravity zone
    @param zone Part - The zone part
    @param player Player - The player entering
]]
local function onPlayerEnterZone(zone: Part, player: Player)
    -- Initialize zone tracking if needed
    if not playersInZone[zone] then
        playersInZone[zone] = {}
    end

    -- Skip if player is already in this zone
    if playersInZone[zone][player] then
        return
    end

    -- Mark player as in zone
    playersInZone[zone][player] = true

    -- Enable zero gravity
    local character = player.Character
    if character then
        local success = PhysicsUtils.toggleZeroGravity(character, true)
        if success then
            print(string.format("[GravityController] %s entered Zero-G zone", player.Name))
        end
    end
end

--[[
    Handles a player leaving a Zero Gravity zone
    @param zone Part - The zone part
    @param player Player - The player leaving
]]
local function onPlayerLeaveZone(zone: Part, player: Player)
    -- Skip if player wasn't tracked in this zone
    if not playersInZone[zone] or not playersInZone[zone][player] then
        return
    end

    -- Remove player from zone tracking
    playersInZone[zone][player] = nil

    -- Disable zero gravity
    local character = player.Character
    if character then
        local success = PhysicsUtils.toggleZeroGravity(character, false)
        if success then
            print(string.format("[GravityController] %s left Zero-G zone", player.Name))
        end
    end
end

--[[
    Sets up touch detection for a Zero Gravity zone
    @param zone Part - The zone part to set up
]]
local function setupZone(zone: Part)
    print(string.format("[GravityController] Setting up zone: %s", zone:GetFullName()))

    -- Initialize tracking table
    playersInZone[zone] = {}

    -- Handle players touching the zone
    zone.Touched:Connect(function(hit)
        local player = getPlayerFromHit(hit)
        if player then
            onPlayerEnterZone(zone, player)
        end
    end)

    -- Handle players leaving the zone
    zone.TouchEnded:Connect(function(hit)
        local player = getPlayerFromHit(hit)
        if player then
            onPlayerLeaveZone(zone, player)
        end
    end)
end

--[[
    Cleans up when a player leaves the game
    @param player Player - The player who left
]]
local function onPlayerRemoving(player: Player)
    -- Remove player from all zone tracking tables
    for _, zonePlayers in pairs(playersInZone) do
        zonePlayers[player] = nil
    end
end

-- Initialize: Find all existing ZeroG_Zone parts
local function initialize()
    print("[GravityController] Initializing Zero Gravity system...")

    -- Find all parts named "ZeroG_Zone" in workspace
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant.Name == "ZeroG_Zone" then
            setupZone(descendant)
        end
    end

    -- Listen for new zones added at runtime
    workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("BasePart") and descendant.Name == "ZeroG_Zone" then
            setupZone(descendant)
        end
    end)

    -- Clean up when zones are removed
    workspace.DescendantRemoving:Connect(function(descendant)
        if descendant:IsA("BasePart") and playersInZone[descendant] then
            -- Disable gravity for all players in this zone
            for player in pairs(playersInZone[descendant]) do
                local character = player.Character
                if character then
                    PhysicsUtils.toggleZeroGravity(character, false)
                end
            end
            playersInZone[descendant] = nil
        end
    end)

    -- Clean up player tracking when they leave
    Players.PlayerRemoving:Connect(onPlayerRemoving)

    print("[GravityController] Zero Gravity system ready!")
end

-- Start the system
initialize()
