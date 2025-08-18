--!strict

-- Add invisible walls around the floor to keep NPCs from flying off the map.

local function ensureBounds()
    local floor = workspace:FindFirstChild("Floor")
    if not floor or not floor:IsA("BasePart") then return end
    local cf, size = floor.CFrame, floor.Size
    local margin = 2
    local height = 50
    local thickness = 1
    local walls = workspace:FindFirstChild("Bounds")
    if not walls then
        walls = Instance.new("Folder")
        walls.Name = "Bounds"
        walls.Parent = workspace
    end
    local function wall(name: string, c: CFrame, s: Vector3)
        local p = workspace:FindFirstChild(name)
        if p and p:IsA("Part") then p:Destroy() end
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


