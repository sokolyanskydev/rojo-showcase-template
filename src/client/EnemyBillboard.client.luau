--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local zoomValue: NumberValue = ReplicatedStorage:WaitForChild("CameraHeight") :: any

local function ensureBillboardFor(model: Model)
    if model:FindFirstChild("EnemyBillboard") then return end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local head = model:FindFirstChild("Head")
    if not head or not head:IsA("BasePart") then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "EnemyBillboard"
    bb.Size = UDim2.new(0, 100, 0, 24)
    bb.StudsOffset = Vector3.new(0, 2.2, 0)
    bb.AlwaysOnTop = true
    bb.Parent = head

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, 0, 0, 14)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Enemy"
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 12
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.Parent = bb

    local barFrame = Instance.new("Frame")
    barFrame.Name = "HPBar"
    barFrame.Size = UDim2.new(1, 0, 0, 8)
    barFrame.Position = UDim2.new(0, 0, 0, 14)
    barFrame.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
    barFrame.BorderSizePixel = 0
    barFrame.Parent = bb
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 4)
    barCorner.Parent = barFrame

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
    fill.BorderSizePixel = 0
    fill.Parent = barFrame
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(20, 40, 20)
    stroke.Thickness = 1
    stroke.Parent = barFrame

    humanoid.HealthChanged:Connect(function(h)
        local ratio = math.clamp(h / humanoid.MaxHealth, 0, 1)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
    end)

    -- Visibility by zoom
    local function applyVisibility()
        bb.Enabled = zoomValue.Value <= 90
    end
    zoomValue.Changed:Connect(applyVisibility)
    applyVisibility()
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


