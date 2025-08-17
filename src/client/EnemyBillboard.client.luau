--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local zoomValue: NumberValue? = ReplicatedStorage:FindFirstChild("CameraHeight") :: any

local function styleBillboard(bb: BillboardGui)
    bb.Size = UDim2.new(0, 64, 0, 10)
    bb.StudsOffset = Vector3.new(0, 2.2, 0)
    bb.AlwaysOnTop = true
    -- Optional: scale with zoom to reduce clutter when zoomed out
    local scale = math.clamp((100 - zoomValue.Value) / 60, 0.6, 1.0)
    bb.Size = UDim2.new(0, math.floor(64 * scale + 0.5), 0, math.floor(10 * scale + 0.5))
end

local function ensureBillboardFor(model: Model)
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local head = model:FindFirstChild("Head")
    if not head or not head:IsA("BasePart") then return end
    local existing: BillboardGui? = model:FindFirstChild("EnemyBillboard") :: any
    local bb: BillboardGui
    if existing and existing:IsA("BillboardGui") then
        bb = existing
    else
        bb = Instance.new("BillboardGui")
        bb.Name = "EnemyBillboard"
        bb.Parent = head
        -- name label removed to reduce clutter
        local barFrame = Instance.new("Frame")
        barFrame.Name = "HPBar"
        barFrame.Size = UDim2.new(1, 0, 1, 0)
        barFrame.Position = UDim2.new(0, 0, 0, 0)
        barFrame.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
        barFrame.BorderSizePixel = 0
        barFrame.Parent = bb
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(0, 3)
        barCorner.Parent = barFrame

        local fill = Instance.new("Frame")
        fill.Name = "Fill"
        fill.Size = UDim2.new(1, 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(80, 220, 80)
        fill.BorderSizePixel = 0
        fill.Parent = barFrame
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 3)
        fillCorner.Parent = fill
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(20, 40, 20)
        stroke.Thickness = 1
        stroke.Parent = barFrame

        humanoid.HealthChanged:Connect(function(h)
            local ratio = math.clamp(h / humanoid.MaxHealth, 0, 1)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
        end)
    end

    -- Style or restyle
    styleBillboard(bb)
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local head = model:FindFirstChild("Head")
    if not head or not head:IsA("BasePart") then return end

    -- Visibility by zoom and restyle on change
    local function applyVisibilityAndStyle()
        bb.Enabled = true
        styleBillboard(bb)
    end
    if zoomValue and zoomValue:IsA("NumberValue") then
        zoomValue.Changed:Connect(applyVisibilityAndStyle)
    end
    applyVisibilityAndStyle()
end

workspace.ChildAdded:Connect(function(child)
    if child:IsA("Model") and child.Name == "Enemy" then
        task.defer(function()
            ensureBillboardFor(child)
        end)
    end
end)

for _, child in ipairs(workspace:GetChildren()) do
    if child:IsA("Model") and child.Name == "Enemy" then
        ensureBillboardFor(child)
    end
end


