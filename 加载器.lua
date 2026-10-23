--[[
    DELTA // LOADER
    —— 三角洲战术风格加载动画 + 远程脚本加载器
    适用：Roblox 执行器环境（客户端）
]]

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")

-- 目标脚本
local SCRIPT_URL = "https://raw.githubusercontent.com/cheng2026-tech/8.90-/refs/heads/main/大肥鱼脚本8.90版本.lua"

local ACCENT = Color3.fromRGB(0, 255, 200)
local DIM    = Color3.fromRGB(0, 180, 150)

local player = Players.LocalPlayer
local pg     = player:WaitForChild("PlayerGui")

-- 清理旧 GUI
local old = pg:FindFirstChild("DeltaLoaderGui")
if old then old:Destroy() end

------------------------------------------------------------------
-- GUI 构建
------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "DeltaLoaderGui"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 9999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = pg

-- 背景
local bg = Instance.new("Frame")
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = Color3.fromRGB(4, 10, 12)
bg.BackgroundTransparency = 1
bg.BorderSizePixel = 0
bg.Parent = gui
TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 0.06}):Play()

-- 扫描线
local scanHolder = Instance.new("Frame")
scanHolder.Size = UDim2.fromScale(1, 1)
scanHolder.BackgroundTransparency = 1
scanHolder.Parent = bg

for i = 1, 36 do
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.fromScale(0, i / 36)
    line.BackgroundColor3 = ACCENT
    line.BackgroundTransparency = 0.93
    line.BorderSizePixel = 0
    line.Parent = scanHolder
end

-- 上下边框
for _, y in ipairs({0, 1}) do
    local bar = Instance.new("Frame")
    bar.AnchorPoint = Vector2.new(0, y)
    bar.Position = UDim2.fromScale(0, y)
    bar.Size = UDim2.new(1, 0, 0, 2)
    bar.BackgroundColor3 = ACCENT
    bar.BackgroundTransparency = 0.4
    bar.BorderSizePixel = 0
    bar.Parent = bg
end

-- 四角瞄准框（从外向内收拢）
local function makeCorner(ax, ay)
    local holder = Instance.new("Frame")
    holder.AnchorPoint = Vector2.new(ax, ay)
    holder.Position = UDim2.new(ax, ax == 0 and 120 or -120, ay, ay == 0 and 120 or -120)
    holder.Size = UDim2.fromOffset(80, 80)
    holder.BackgroundTransparency = 1
    holder.Parent = bg

    local h = Instance.new("Frame")
    h.AnchorPoint = Vector2.new(ax, ay)
    h.Position = UDim2.fromScale(ax, ay)
    h.Size = UDim2.fromOffset(80, 2)
    h.BackgroundColor3 = ACCENT
    h.BorderSizePixel = 0
    h.Parent = holder

    local v = Instance.new("Frame")
    v.AnchorPoint = Vector2.new(ax, ay)
    v.Position = UDim2.fromScale(ax, ay)
    v.Size = UDim2.fromOffset(2, 80)
    v.BackgroundColor3 = ACCENT
    v.BorderSizePixel = 0
    v.Parent = holder

    TweenService:Create(holder,
        TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        { Position = UDim2.new(ax, ax == 0 and 44 or -44, ay, ay == 0 and 44 or -44) }
    ):Play()
end

makeCorner(0, 0)
makeCorner(1, 0)
makeCorner(0, 1)
makeCorner(1, 1)

-- 中心容器
local center = Instance.new("Frame")
center.AnchorPoint = Vector2.new(0.5, 0.5)
center.Position = UDim2.fromScale(0.5, 0.44)
center.Size = UDim2.fromOffset(280, 280)
center.BackgroundTransparency = 1
center.Parent = bg

-- 虚线雷达环
local ringHolder = Instance.new("Frame")
ringHolder.AnchorPoint = Vector2.new(0.5, 0.5)
ringHolder.Position = UDim2.fromScale(0.5, 0.5)
ringHolder.Size = UDim2.fromOffset(280, 280)
ringHolder.BackgroundTransparency = 1
ringHolder.Parent = center

for i = 1, 16 do
    local ang = math.rad(i / 16 * 360)
    local tick = Instance.new("Frame")
    tick.AnchorPoint = Vector2.new(0.5, 0.5)
    tick.Position = UDim2.new(0.5, math.cos(ang) * 128, 0.5, math.sin(ang) * 128)
    tick.Size = UDim2.fromOffset(2, 10)
    tick.Rotation = math.deg(ang) + 90
    tick.BackgroundColor3 = ACCENT
    tick.BackgroundTransparency = 0.3
    tick.BorderSizePixel = 0
    tick.Parent = ringHolder
end

-- 旋转菱形
local diamondHolder = Instance.new("Frame")
diamondHolder.AnchorPoint = Vector2.new(0.5, 0.5)
diamondHolder.Position = UDim2.fromScale(0.5, 0.5)
diamondHolder.Size = UDim2.fromOffset(240, 240)
diamondHolder.BackgroundTransparency = 1
diamondHolder.Parent = center

local diamond = Instance.new("Frame")
diamond.AnchorPoint = Vector2.new(0.5, 0.5)
diamond.Position = UDim2.fromScale(0.5, 0.5)
diamond.Size = UDim2.fromOffset(110, 110)
diamond.BackgroundTransparency = 1
diamond.Rotation = 45
diamond.Parent = diamondHolder

local dStroke = Instance.new("UIStroke")
dStroke.Thickness = 2
dStroke.Color = ACCENT
dStroke.Parent = diamond

-- 等边三角形
local triHolder = Instance.new("Frame")
triHolder.AnchorPoint = Vector2.new(0.5, 0.5)
triHolder.Position = UDim2.fromScale(0.5, 0.5)
triHolder.Size = UDim2.fromOffset(240, 240)
triHolder.BackgroundTransparency = 1
triHolder.Parent = center

local R = 44
local edges = {
    { dx = 0.433 * R,  dy = -0.25 * R, rot = 60 },
    { dx = 0,          dy = 0.5 * R,   rot = 0  },
    { dx = -0.433 * R, dy = -0.25 * R, rot = -60 },
}

for _, e in ipairs(edges) do
    local side = Instance.new("Frame")
    side.AnchorPoint = Vector2.new(0.5, 0.5)
    side.Position = UDim2.new(0.5, e.dx, 0.5, e.dy)
    side.Size = UDim2.fromOffset(R * math.sqrt(3), 2)
    side.Rotation = e.rot
    side.BackgroundColor3 = ACCENT
    side.BorderSizePixel = 0
    side.Parent = triHolder
end

-- 标题
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.Position = UDim2.new(0, 0, 0, 24)
title.BackgroundTransparency = 1
title.Font = Enum.Font.Code
title.TextSize = 20
title.TextColor3 = ACCENT
title.Text = "◢  DELTA // LOADER  ◣"
title.Parent = bg

-- 状态文字
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 20)
status.Position = UDim2.new(0, 0, 1, -92)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Code
status.TextSize = 14
status.TextColor3 = DIM
status.Text = "[ INITIALIZING ]"
status.Parent = bg

-- 百分比
local pct = Instance.new("TextLabel")
pct.AnchorPoint = Vector2.new(0.5, 1)
pct.Position = UDim2.new(0.5, 0, 1, -66)
pct.Size = UDim2.fromOffset(200, 16)
pct.BackgroundTransparency = 1
pct.Font = Enum.Font.Code
pct.TextSize = 12
pct.TextColor3 = ACCENT
pct.Text = "0%"
pct.Parent = bg

-- 进度条
local barBg = Instance.new("Frame")
barBg.AnchorPoint = Vector2.new(0.5, 0)
barBg.Position = UDim2.new(0.5, 0, 1, -52)
barBg.Size = UDim2.new(0.4, 0, 0, 4)
barBg.BackgroundColor3 = ACCENT
barBg.BackgroundTransparency = 0.85
barBg.BorderSizePixel = 0
barBg.Parent = bg

local barFill = Instance.new("Frame")
barFill.Size = UDim2.fromScale(0, 1)
barFill.BackgroundColor3 = ACCENT
barFill.BorderSizePixel = 0
barFill.Parent = barBg

-- 旋转动画驱动
local spin = 0
local renderConn = RunService.RenderStepped:Connect(function(dt)
    spin += dt
    diamondHolder.Rotation = spin * 60
    triHolder.Rotation     = -spin * 45
    ringHolder.Rotation    = spin * 25
end)

local function setProgress(p)
    p = math.clamp(p, 0, 1)
    barFill.Size = UDim2.fromScale(p, 1)
    pct.Text = string.format("%d%%", math.floor(p * 100))
end

local function setStatus(s)
    status.Text = s
end

------------------------------------------------------------------
-- 加载逻辑
------------------------------------------------------------------
local fetchDone, fetchOk, fetchRes = false, false, nil

task.spawn(function()
    local ok, res = pcall(function()
        return game:HttpGet(SCRIPT_URL)
    end)
    fetchOk, fetchRes = ok, res
    fetchDone = true
end)

-- 进度 / 状态推进
local statuses = {
    "[ INITIALIZING ]",
    "[ FETCHING PAYLOAD ]",
    "[ VERIFYING INTEGRITY ]",
    "[ INJECTING ]",
}

task.spawn(function()
    local total   = 3.6
    local elapsed = 0
    local step    = 0.03
    local lastStage = 0

    while elapsed < total do
        elapsed += step
        local p = elapsed / total
        local stage = math.min(#statuses, math.floor(p * #statuses) + 1)
        if stage ~= lastStage then
            setStatus(statuses[stage])
            lastStage = stage
        end
        setProgress(p)
        task.wait(step)
    end
end)

-- 等待抓取（带超时保护）
local waited = 0
while not fetchDone and waited < 15 do
    task.wait(0.1)
    waited += 0.1
end

if not fetchDone then
    fetchOk, fetchRes = false, "请求超时"
end

setStatus("[ STANDBY ]")
setProgress(1)
task.wait(0.3)

------------------------------------------------------------------
-- 收尾动画
------------------------------------------------------------------
renderConn:Disconnect()

local flash = Instance.new("Frame")
flash.Size = UDim2.fromScale(1, 1)
flash.BackgroundColor3 = Color3.new(1, 1, 1)
flash.BackgroundTransparency = 1
flash.BorderSizePixel = 0
flash.ZIndex = 50
flash.Parent = gui

local t1 = TweenService:Create(flash, TweenInfo.new(0.18), { BackgroundTransparency = 0 })
t1:Play()
t1.Completed:Wait()

TweenService:Create(flash, TweenInfo.new(0.45), { BackgroundTransparency = 1 }):Play()
TweenService:Create(bg,    TweenInfo.new(0.45), { BackgroundTransparency = 1 }):Play()
task.wait(0.5)
gui:Destroy()

------------------------------------------------------------------
-- 执行脚本
------------------------------------------------------------------
if not fetchOk then
    warn("[DELTA LOADER] 脚本获取失败: " .. tostring(fetchRes))
    return
end

if not fetchRes or #fetchRes < 100 then
    warn("[DELTA LOADER] 获取到的脚本内容异常")
    return
end

local fn, err = loadstring(fetchRes)
if not fn then
    warn("[DELTA LOADER] 编译失败: " .. tostring(err))
    return
end

local ok, runErr = pcall(fn)
if not ok then
    warn("[DELTA LOADER] 执行出错: " .. tostring(runErr))
end
