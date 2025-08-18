--!strict

-- Add invisible walls around a designer-placed part `Workspace.BoundsArea`.
-- If absent, fall back to `Workspace.Floor`. If still absent, create a default BoundsArea.

local function getBoundsFrame()
    local area = workspace:FindFirstChild("BoundsArea")
    if area and area:IsA("BasePart") then
        return area.CFrame, area.Size
    end
    local floor = workspace:FindFirstChild("Floor")
    if floor and floor:IsA("BasePart") then
        return floor.CFrame, floor.Size
    end
    -- Create a default BoundsArea for convenience
    local default = Instance.new("Part")
    default.Name = "BoundsArea"
    default.Anchored = true
    default.CanCollide = false
    default.Transparency = 0.9
    default.Size = Vector3.new(300, 1, 300)
    default.Position = Vector3.new(0, 0.5, 0)
    default.Parent = workspace
    return default.CFrame, default.Size
end

local function ensureBounds()
    local cf, size = getBoundsFrame()
    if not cf then return end
    local margin = 2
    local height = 60
    local thickness = 2
    local walls = workspace:FindFirstChild("Bounds")
    if not walls then
        walls = Instance.new("Folder")
        walls.Name = "Bounds"
        walls.Parent = workspace
    end
    local function wall(name: string, c: CFrame, s: Vector3)
        local existing = walls:FindFirstChild(name)
        if existing and existing:IsA("BasePart") then existing:Destroy() end
        local part = Instance.new("Part")
        part.Name = name
        part.Anchored = true
        part.CanCollide = true
        part.Transparency = 1
        part.CFrame = c
        part.Size = s
        part.Parent = walls
    end
    -- Left/Right
    wall("Bound_Left", cf * CFrame.new(-(size.X/2 + margin), height/2, 0), Vector3.new(thickness, height, size.Z + 2*margin))
    wall("Bound_Right", cf * CFrame.new( (size.X/2 + margin), height/2, 0), Vector3.new(thickness, height, size.Z + 2*margin))
    -- Front/Back
    wall("Bound_Front", cf * CFrame.new(0, height/2,  (size.Z/2 + margin)), Vector3.new(size.X + 2*margin, height, thickness))
    wall("Bound_Back", cf * CFrame.new(0, height/2, -(size.Z/2 + margin)), Vector3.new(size.X + 2*margin, height, thickness))
end

ensureBounds()


