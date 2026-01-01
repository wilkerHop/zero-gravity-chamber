--[[
    PhysicsUtils.lua
    Shared module for Zero Gravity Chamber physics manipulation.
    
    Uses VectorForce (modern API) instead of deprecated BodyForce.
    Force is applied via an Attachment on the HumanoidRootPart.
]]

local PhysicsUtils = {}

-- Constants
local FORCE_NAME = "ZeroGravityForce"
local ATTACHMENT_NAME = "ZeroGravityAttachment"

--[[
    Toggles zero gravity for a character.
    
    @param character Model - The player's character model
    @param state boolean - true to enable zero gravity, false to disable
    @return boolean - Success status
]]
function PhysicsUtils.toggleZeroGravity(character: Model, state: boolean): boolean
    -- Validate character
    if not character then
        warn("[PhysicsUtils] No character provided")
        return false
    end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        warn("[PhysicsUtils] Character missing HumanoidRootPart")
        return false
    end

    -- Handle disable case
    if not state then
        local existingForce = humanoidRootPart:FindFirstChild(FORCE_NAME)
        if existingForce then
            existingForce:Destroy()
        end

        local existingAttachment = humanoidRootPart:FindFirstChild(ATTACHMENT_NAME)
        if existingAttachment then
            existingAttachment:Destroy()
        end

        return true
    end

    -- Prevent duplicate forces
    if humanoidRootPart:FindFirstChild(FORCE_NAME) then
        return true -- Already has zero gravity
    end

    -- Create attachment for VectorForce
    local attachment = Instance.new("Attachment")
    attachment.Name = ATTACHMENT_NAME
    attachment.Parent = humanoidRootPart

    -- Calculate counteracting force
    -- Force = mass * gravity (upward to counteract downward gravity)
    local mass = humanoidRootPart.AssemblyMass
    local gravityForce = workspace.Gravity * mass

    -- Create VectorForce to counteract gravity
    local vectorForce = Instance.new("VectorForce")
    vectorForce.Name = FORCE_NAME
    vectorForce.Attachment0 = attachment
    vectorForce.Force = Vector3.new(0, gravityForce, 0)
    vectorForce.ApplyAtCenterOfMass = true
    vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
    vectorForce.Parent = humanoidRootPart

    return true
end

--[[
    Checks if a character currently has zero gravity enabled.
    
    @param character Model - The player's character model
    @return boolean - true if zero gravity is active
]]
function PhysicsUtils.hasZeroGravity(character: Model): boolean
    if not character then
        return false
    end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return false
    end

    return humanoidRootPart:FindFirstChild(FORCE_NAME) ~= nil
end

return PhysicsUtils
