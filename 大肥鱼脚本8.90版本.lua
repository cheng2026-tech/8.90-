local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local function DBLoadLocalAsset(path)
    local loader = getcustomasset or getsynasset
    if type(loader) ~= "function" then return "" end
    if type(isfile) == "function" then
        local ok, exists = pcall(isfile, path)
        if ok and not exists then return "" end
    end
    local ok, asset = pcall(loader, path)
    if ok and type(asset) == "string" then return asset end
    return ""
end
local DBSharedLogoAsset = DBLoadLocalAsset("DB_SCRIPT_D_LOGO_TRANSPARENT.png")
local DBAnchorIconAsset = DBLoadLocalAsset("DB_ANCHOR_SWAP_ICON_V141.png")
local DBPanelAdjustIconAsset = DBLoadLocalAsset("DB_PANEL_ADJUST_ICON_V147.png")
local DBMoveFourWayAsset = DBLoadLocalAsset("DB_MOVE_FOUR_WAY_V95.png")
if not game:IsLoaded() then
    game.Loaded:Wait()
end
local LocalPlayer = Players.LocalPlayer
local __dbWaitStart = os.clock()
while not LocalPlayer and (os.clock() - __dbWaitStart) < 12 do
task.wait(0.10)
LocalPlayer = Players.LocalPlayer
end
if not LocalPlayer then
error("[大肥鱼] LocalPlayer 未准备好")
end

local function GetViewport()
local cam = workspace.CurrentCamera
if not cam then cam = workspace:WaitForChild("CurrentCamera", 2) end
return cam and cam.ViewportSize or Vector2.new(1920, 1080)
end
local viewport = GetViewport()
local baseW, baseH = 550, 370
local panelWidth = math.clamp(viewport.X * 0.62, 380, baseW)
local panelHeight = math.clamp(panelWidth * (baseH / baseW), 260, baseH)
local BUTTON_SIZE = 56
local FLOATING_WIDTH = 150
local FLOATING_HEIGHT = 42
local FLOATING_DRAG_WIDTH = 42
local CORNER_RADIUS = 16
local ANIMATION_TIME = 0.35
local MIN_PANEL_WIDTH = 360
local MIN_PANEL_HEIGHT = 250
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "DB_Panel_Fixed"
MainGui.ResetOnSpawn = false
MainGui.IgnoreGuiInset = true
MainGui.DisplayOrder = 999
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local __dbPlayerGui = LocalPlayer:WaitForChild("PlayerGui", 12)
if not __dbPlayerGui then
error("[大肥鱼] PlayerGui 未准备好")
end
MainGui.Parent = __dbPlayerGui
local IntroGui = Instance.new("Frame")
IntroGui.Name = "DB_Intro"
IntroGui.Size = UDim2.fromScale(1, 1)
IntroGui.Position = UDim2.fromScale(0, 0)
IntroGui.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
IntroGui.BackgroundTransparency = 1
IntroGui.BorderSizePixel = 0
IntroGui.ZIndex = 10000
IntroGui.Active = true
IntroGui.ClipsDescendants = true
IntroGui.Parent = MainGui

local IntroRandom = Random.new()
local function IntroTween(obj, duration, props, style, direction)
    local tween = TweenService:Create(
        obj,
        TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
        props
    )
    tween:Play()
    return tween
end

local BallLayer = Instance.new("Frame")
BallLayer.Name = "BallLayer"
BallLayer.Size = UDim2.fromScale(1, 1)
BallLayer.BackgroundTransparency = 1
BallLayer.BorderSizePixel = 0
BallLayer.ClipsDescendants = true
BallLayer.ZIndex = 10001
BallLayer.Parent = IntroGui

local BallColors = {
    Color3.fromRGB(255, 92, 123), Color3.fromRGB(255, 172, 89),
    Color3.fromRGB(255, 228, 105), Color3.fromRGB(90, 236, 164),
    Color3.fromRGB(80, 218, 255), Color3.fromRGB(102, 148, 255),
    Color3.fromRGB(174, 112, 255), Color3.fromRGB(255, 112, 220)
}
local Balls = {}
local function CreateIntroBall(index)
    local size = IntroRandom:NextInteger(5, 12)
    local ball = Instance.new("Frame")
    ball.Name = "Ball_" .. index
    ball.AnchorPoint = Vector2.new(0.5, 0.5)
    ball.Size = UDim2.fromOffset(size, size)
    ball.Position = UDim2.fromScale(IntroRandom:NextNumber(0.025, 0.975), IntroRandom:NextNumber(0.04, 0.96))
    ball.BackgroundColor3 = BallColors[IntroRandom:NextInteger(1, #BallColors)]
    ball.BackgroundTransparency = 1
    ball.BorderSizePixel = 0
    ball.ZIndex = 10001
    ball.Parent = BallLayer
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ball
    ball:SetAttribute("VisibleTransparency", IntroRandom:NextNumber(0.28, 0.56))
    table.insert(Balls, ball)
    task.spawn(function()
        while ball.Parent and IntroGui.Parent do
            local moveTween = IntroTween(
                ball,
                IntroRandom:NextNumber(1.35, 2.65),
                {Position = UDim2.fromScale(IntroRandom:NextNumber(-0.025, 1.025), IntroRandom:NextNumber(-0.025, 1.025))},
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut
            )
            moveTween.Completed:Wait()
            task.wait(IntroRandom:NextNumber(0.03, 0.14))
        end
    end)
end
for i = 1, 36 do CreateIntroBall(i) end

local introViewport = GetViewport()
local introCenter = Vector2.new(introViewport.X / 2, introViewport.Y * 0.43)

local IntroLogo = Instance.new("ImageLabel")
IntroLogo.Name = "DB_IntroBrandLogo"
IntroLogo.AnchorPoint = Vector2.new(0.5, 0.5)
IntroLogo.Position = UDim2.fromOffset(introCenter.X - 57, introCenter.Y)
IntroLogo.Size = UDim2.fromOffset(88, 88)
IntroLogo.BackgroundTransparency = 1
IntroLogo.BorderSizePixel = 0
IntroLogo.Image = DBSharedLogoAsset
IntroLogo.ImageTransparency = DBSharedLogoAsset ~= "" and 1 or 1
IntroLogo.ScaleType = Enum.ScaleType.Fit
IntroLogo.ZIndex = 10011
IntroLogo.Parent = IntroGui

local IntroLogoFallback = Instance.new("TextLabel")
IntroLogoFallback.AnchorPoint = Vector2.new(0.5, 0.5)
IntroLogoFallback.Position = IntroLogo.Position
IntroLogoFallback.Size = IntroLogo.Size
IntroLogoFallback.BackgroundTransparency = 1
IntroLogoFallback.Text = "鱼"
IntroLogoFallback.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroLogoFallback.TextTransparency = 1
IntroLogoFallback.TextSize = 30
IntroLogoFallback.Font = Enum.Font.GothamBlack
IntroLogoFallback.ZIndex = 10010
IntroLogoFallback.Visible = DBSharedLogoAsset == ""
IntroLogoFallback.Parent = IntroGui

local DBGroup = Instance.new("Frame")
DBGroup.Name = "DBEnchantLogo"
DBGroup.AnchorPoint = Vector2.new(0.5, 0.5)
DBGroup.Position = UDim2.fromOffset(introCenter.X + 46, introCenter.Y)
DBGroup.Size = UDim2.fromOffset(180, 130)
DBGroup.BackgroundTransparency = 1
DBGroup.ZIndex = 10005
DBGroup.Parent = IntroGui

local DBScale = Instance.new("UIScale")
DBScale.Scale = 0.86
DBScale.Parent = DBGroup

local function MakeIntroDBLayer(name, offset, size, color, z)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.Position = UDim2.new(0.5, offset.X, 0.5, offset.Y)
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = "鱼"
    label.TextColor3 = color
    label.TextTransparency = 1
    label.TextStrokeTransparency = 1
    label.TextSize = size
    label.Font = Enum.Font.GothamBlack
    label.ZIndex = z
    label.Parent = DBGroup
    return label
end
local DBShadow = MakeIntroDBLayer("DBShadow", Vector2.new(3, 4), 84, Color3.fromRGB(0, 0, 0), 10005)
local DBGlowViolet = MakeIntroDBLayer("DBGlowViolet", Vector2.zero, 88, Color3.fromRGB(255, 255, 255), 10006)
DBGlowViolet.TextStrokeColor3 = Color3.fromRGB(175, 225, 255)
local DBGlowIce = MakeIntroDBLayer("DBGlowIce", Vector2.zero, 86, Color3.fromRGB(170, 232, 255), 10007)
DBGlowIce.TextStrokeColor3 = Color3.fromRGB(112, 210, 255)
local DBText = MakeIntroDBLayer("DBText", Vector2.zero, 84, Color3.fromRGB(255, 255, 255), 10009)
local SweepText = MakeIntroDBLayer("SweepText", Vector2.zero, 84, Color3.fromRGB(255, 255, 255), 10010)
SweepText.TextTransparency = 0
local SweepGradient = Instance.new("UIGradient")
SweepGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(205, 238, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(165, 225, 255))
})
SweepGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.42, 1),
    NumberSequenceKeypoint.new(0.50, 0.10), NumberSequenceKeypoint.new(0.58, 1),
    NumberSequenceKeypoint.new(1, 1)
})
SweepGradient.Offset = Vector2.new(-1.2, 0)
SweepGradient.Rotation = 18
SweepGradient.Parent = SweepText

local WelcomeText = Instance.new("TextLabel")
WelcomeText.Name = "WelcomeText"
WelcomeText.AnchorPoint = Vector2.new(0.5, 1)
WelcomeText.Position = UDim2.new(0.5, 0, 0.94, 0)
WelcomeText.Size = UDim2.new(0.9, 0, 0, 32)
WelcomeText.BackgroundTransparency = 1
WelcomeText.Text = "欢迎：" .. LocalPlayer.Name
WelcomeText.TextColor3 = Color3.fromRGB(255, 255, 255)
WelcomeText.TextTransparency = 1
WelcomeText.TextSize = 16
WelcomeText.Font = Enum.Font.GothamMedium
WelcomeText.TextXAlignment = Enum.TextXAlignment.Center
WelcomeText.ZIndex = 10008
WelcomeText.Parent = IntroGui

local CurtainIn = IntroTween(IntroGui, 0.30, {BackgroundTransparency = 0.25})
for _, ball in ipairs(Balls) do
    IntroTween(ball, IntroRandom:NextNumber(0.22, 0.40), {BackgroundTransparency = ball:GetAttribute("VisibleTransparency") or 0.42})
end
CurtainIn.Completed:Wait()
if DBSharedLogoAsset ~= "" then
    IntroTween(IntroLogo, 0.34, {ImageTransparency = 0})
else
    IntroTween(IntroLogoFallback, 0.34, {TextTransparency = 0})
end
IntroTween(DBShadow, 0.34, {TextTransparency = 0.64, TextStrokeTransparency = 0.78})
IntroTween(DBGlowViolet, 0.40, {TextTransparency = 0.72, TextStrokeTransparency = 0.70})
IntroTween(DBGlowIce, 0.40, {TextTransparency = 0.76, TextStrokeTransparency = 0.74})
IntroTween(DBText, 0.40, {TextTransparency = 0})
IntroTween(DBScale, 0.50, {Scale = 1}, Enum.EasingStyle.Back)
IntroTween(WelcomeText, 0.36, {TextTransparency = 0})

local sweepAlive = true
task.spawn(function()
    while sweepAlive and SweepGradient.Parent do
        SweepGradient.Offset = Vector2.new(-1.2, 0)
        local sw = IntroTween(SweepGradient, 0.66, {Offset = Vector2.new(1.2, 0)}, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
        sw.Completed:Wait()
    end
end)

task.wait(3.00)
sweepAlive = false

local introFade = IntroTween(IntroGui, 0.42, {BackgroundTransparency = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
if DBSharedLogoAsset ~= "" then
    IntroTween(IntroLogo, 0.30, {ImageTransparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
else
    IntroTween(IntroLogoFallback, 0.30, {TextTransparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
end
IntroTween(DBText, 0.30, {TextTransparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
IntroTween(DBShadow, 0.30, {TextTransparency = 1, TextStrokeTransparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
IntroTween(DBGlowIce, 0.30, {TextTransparency = 1, TextStrokeTransparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
IntroTween(DBGlowViolet, 0.30, {TextTransparency = 1, TextStrokeTransparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
IntroTween(SweepText, 0.30, {TextTransparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
IntroTween(WelcomeText, 0.28, {TextTransparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
for _, ball in ipairs(Balls) do
    if ball.Parent then
        IntroTween(ball, 0.36, {BackgroundTransparency = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    end
end
introFade.Completed:Wait()

DBGroup.Visible = false
WelcomeText.Visible = false
BallLayer.Visible = false
IntroGui.Active = false

local State = {
PanelPosition = nil,
ButtonPosition = nil,
Animating = false,
Minimized = false,
CurrentCategory = "通用",
ButtonHidden = false,
HideSide = "none"
}
local function ClampPosition(pos, size)
local vp =
GetViewport()
local hx =
size.X / 2
local hy =
size.Y / 2
local keepX =
math.min(
96,
size.X * 0.32
)
local keepY =
math.min(
76,
size.Y * 0.32
)
return Vector2.new(
math.clamp(
pos.X,
keepX - hx,
vp.X - keepX + hx
),
math.clamp(
pos.Y,
keepY - hy,
vp.Y - keepY + hy
)
)
end
local UI = {
Panel = Color3.fromRGB(0, 0, 0),
Button = Color3.fromRGB(12, 12, 14),
ButtonHover = Color3.fromRGB(25, 25, 29),
Text = Color3.fromRGB(255, 255, 255),
SubText = Color3.fromRGB(205, 205, 210)
}
local RAINBOW_FLOW = ColorSequence.new({
ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 82, 126)),
ColorSequenceKeypoint.new(0.14, Color3.fromRGB(255, 178, 78)),
ColorSequenceKeypoint.new(0.28, Color3.fromRGB(255, 246, 112)),
ColorSequenceKeypoint.new(0.43, Color3.fromRGB(102, 255, 176)),
ColorSequenceKeypoint.new(0.58, Color3.fromRGB(86, 230, 255)),
ColorSequenceKeypoint.new(0.72, Color3.fromRGB(126, 138, 255)),
ColorSequenceKeypoint.new(0.86, Color3.fromRGB(236, 92, 255)),
ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 82, 126))
})
local DB_DEEP_RAINBOW_FLOW = ColorSequence.new({
ColorSequenceKeypoint.new(0.00, Color3.fromRGB(224, 42, 92)),
ColorSequenceKeypoint.new(0.14, Color3.fromRGB(232, 132, 42)),
ColorSequenceKeypoint.new(0.28, Color3.fromRGB(220, 198, 55)),
ColorSequenceKeypoint.new(0.43, Color3.fromRGB(50, 205, 128)),
ColorSequenceKeypoint.new(0.58, Color3.fromRGB(38, 184, 224)),
ColorSequenceKeypoint.new(0.72, Color3.fromRGB(82, 92, 220)),
ColorSequenceKeypoint.new(0.86, Color3.fromRGB(194, 55, 220)),
ColorSequenceKeypoint.new(1.00, Color3.fromRGB(224, 42, 92))
})
local function AddCorner(obj, radius)
local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0, radius)
c.Parent = obj
return c
end
local function StartRainbowFlow(parent, duration, transparency)
local grad = Instance.new("UIGradient")
grad.Name = "RainbowFlow"
grad.Color = RAINBOW_FLOW
grad.Transparency = transparency or NumberSequence.new(0)
grad.Rotation = -180
grad.Parent = parent
local tw = TweenService:Create(
grad,
TweenInfo.new(
duration or 2.0,
Enum.EasingStyle.Linear,
Enum.EasingDirection.InOut,
-1,
false,
0
),
{Rotation = 180}
)
tw:Play()
return grad, tw
end
local function AddRainbowBorder(
obj,
thickness,
transparency,
speed
)
thickness = thickness or 0.9
local flowSpeed = speed or 1.95
local stroke =
Instance.new(
"UIStroke"
)
stroke.Name =
"DB_RainbowMain"
stroke.ApplyStrokeMode =
Enum.ApplyStrokeMode.Border
stroke.Thickness =
thickness
stroke.Color =
Color3.new(
1,
1,
1
)
stroke.Transparency =
transparency
or 0.01
stroke.LineJoinMode =
Enum.LineJoinMode.Round
stroke.Parent =
obj
local grad =
StartRainbowFlow(
stroke,
flowSpeed
)
return stroke,
grad
end
local DB_ENCHANT_BLUE =
Color3.fromRGB(
60,
155,
255
)
local DB_ENCHANT_CYAN =
Color3.fromRGB(
105,
230,
255
)
local DB_ENCHANT_WHITE =
Color3.fromRGB(
248,
252,
255
)
local DB_ENCHANT_PURPLE =
Color3.fromRGB(
160,
105,
255
)
local DB_ENCHANT_SEQUENCE =
ColorSequence.new({
ColorSequenceKeypoint.new(
0.00,
DB_ENCHANT_BLUE
),
ColorSequenceKeypoint.new(
0.18,
DB_ENCHANT_CYAN
),
ColorSequenceKeypoint.new(
0.38,
DB_ENCHANT_WHITE
),
ColorSequenceKeypoint.new(
0.58,
DB_ENCHANT_PURPLE
),
ColorSequenceKeypoint.new(
0.78,
DB_ENCHANT_CYAN
),
ColorSequenceKeypoint.new(
1.00,
DB_ENCHANT_BLUE
)
})
local DBVisualSettings
local function AddDBEnchantedBorder(
obj,
thickness,
auraEnabled
)
thickness = thickness or 0.9
for _, child in ipairs(obj:GetChildren()) do
if child.Name == "DB_EnchantMain"
or child.Name == "DB_EnchantCrystal"
or child.Name == "DB_InternalPlainStroke" then
child:Destroy()
end
end
local stroke = Instance.new("UIStroke")
stroke.Name = "DB_InternalPlainStroke"
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Thickness = thickness
stroke.Color = Color3.fromRGB(255, 255, 255)
local baseTransparency = 0.50
stroke:SetAttribute("DB_BaseTransparency", baseTransparency)
local bordersEnabled = true
if DBVisualSettings
and DBVisualSettings.ButtonBordersEnabled ~= nil
and obj:IsA("TextButton") then
bordersEnabled = DBVisualSettings.ButtonBordersEnabled
end
stroke.Transparency = bordersEnabled and baseTransparency or 1
stroke.LineJoinMode = Enum.LineJoinMode.Round
stroke.Parent = obj
return stroke, nil, nil
end
local function AddDBEnchantedText(
label,
stronger
)
for _, child in ipairs(
label:GetChildren()
) do
if child:IsA("UIGradient") then
child:Destroy()
end
end
label.TextColor3 =
Color3.fromRGB(
255,
255,
255
)
label.TextStrokeTransparency = 1
return nil
end
local function AddDBEnchantedDust(
parent,
options
)
options =
options
or {}
local count =
options.Count
or 14
local minSize =
options.MinSize
or 1
local maxSize =
options.MaxSize
or 3
local zIndex =
options.ZIndex
or (
(parent.ZIndex or 1)
+ 1
)
local minTransparency =
options.MinTransparency
or 0.46
local maxTransparency =
options.MaxTransparency
or 0.82
local drift =
options.Drift
or 0.020
local clusterCount =
math.max(
1,
options.ClusterCount
or 3
)
local holder =
Instance.new(
"Frame"
)
holder.Name =
"DB_EnchantDust"
holder.BackgroundTransparency = 1
holder.BorderSizePixel = 0
holder.Size = UDim2.fromScale(1, 1)
holder.ClipsDescendants = true
holder.ZIndex = zIndex
holder.Parent = parent
local rng =
Random.new()
local clusters = {}
for i = 1, clusterCount do
clusters[i] =
Vector2.new(
rng:NextNumber(
0.10,
0.90
),
rng:NextNumber(
0.10,
0.90
)
)
end
local colors = {
DB_ENCHANT_WHITE,
DB_ENCHANT_CYAN,
Color3.fromRGB(
220,
244,
255
),
Color3.fromRGB(
195,
225,
255
),
Color3.fromRGB(
190,
170,
255
)
}
local function clamp01(v)
return math.max(
0.02,
math.min(
0.98,
v
)
)
end
local function pickPosition()
if rng:NextNumber() < 0.77 then
local cluster =
clusters[
rng:NextInteger(
1,
#clusters
)
]
return Vector2.new(
clamp01(
cluster.X
+ rng:NextNumber(
-0.18,
0.18
)
),
clamp01(
cluster.Y
+ rng:NextNumber(
-0.16,
0.16
)
)
)
end
return Vector2.new(
rng:NextNumber(
0.03,
0.97
),
rng:NextNumber(
0.03,
0.97
)
)
end
for i = 1, count do
local dot =
Instance.new(
"Frame"
)
local size =
rng:NextInteger(
minSize,
maxSize
)
local diamond =
(
i % 4 == 0
)
dot.AnchorPoint =
Vector2.new(
0.5,
0.5
)
dot.Size =
UDim2.fromOffset(
size,
size
)
local startPos =
pickPosition()
dot.Position =
UDim2.fromScale(
startPos.X,
startPos.Y
)
dot.BackgroundColor3 =
colors[
rng:NextInteger(
1,
#colors
)
]
dot.BackgroundTransparency =
rng:NextNumber(
minTransparency,
maxTransparency
)
dot.BorderSizePixel = 0
dot.ZIndex = zIndex
dot.Rotation =
diamond
and 45
or 0
dot.Parent = holder
if not diamond then
local corner =
Instance.new(
"UICorner"
)
corner.CornerRadius =
UDim.new(
1,
0
)
corner.Parent = dot
end
task.spawn(function()
while dot.Parent
and holder.Parent do
local basePos =
pickPosition()
dot.Position =
UDim2.fromScale(
basePos.X,
basePos.Y
)
dot.Size =
UDim2.fromOffset(
size,
size
)
dot.BackgroundTransparency =
rng:NextNumber(
minTransparency,
maxTransparency
)
local goalPos =
UDim2.fromScale(
clamp01(
basePos.X
+ rng:NextNumber(
-drift,
drift
)
),
clamp01(
basePos.Y
+ rng:NextNumber(
-drift,
drift
)
)
)
TweenService:Create(
dot,
TweenInfo.new(
rng:NextNumber(
0.95,
2.25
),
Enum.EasingStyle.Sine,
Enum.EasingDirection.InOut
),
{
Position = goalPos,
BackgroundTransparency = 0.97,
Size = UDim2.fromOffset(
size + rng:NextInteger(
0,
2
),
size + rng:NextInteger(
0,
2
)
),
Rotation =
(
diamond
and 45
or 0
)
+ rng:NextInteger(
-22,
22
)
}
):Play()
task.wait(
rng:NextNumber(
0.60,
1.35
)
)
end
end)
end
return holder
end
local Panel = Instance.new("CanvasGroup")
Panel.Name = "Panel"
Panel.AnchorPoint = Vector2.new(0.5, 0.5)
Panel.Size = UDim2.fromOffset(panelWidth, panelHeight)
local __DBInitialViewport =
GetViewport()
Panel.Position =
UDim2.fromOffset(
__DBInitialViewport.X / 2,
__DBInitialViewport.Y / 2
)
Panel.BackgroundTransparency = 1
Panel.GroupTransparency = 0
Panel.GroupColor3 = Color3.fromRGB(255, 255, 255)
Panel.BorderSizePixel = 0
Panel.Active = false
Panel.Visible = false
Panel.Parent = MainGui
local DBStartupScale = Instance.new("UIScale")
DBStartupScale.Name = "DB_StartupScale"
DBStartupScale.Scale = 0.78
DBStartupScale.Parent = Panel
local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Position = UDim2.fromOffset(2, 2)
Body.Size = UDim2.new(1, -4, 1, -4)
Body.BackgroundColor3 = UI.Panel
Body.BackgroundTransparency = 1
Body.BorderSizePixel = 0
Body.Active = false
Body.ClipsDescendants = true
Body.ZIndex = 2
Body.Parent = Panel
AddCorner(Body, CORNER_RADIUS)
local PanelBorder, PanelBorderGradient
do
local borderHost = Instance.new("Frame")
borderHost.Name = "DB_OuterRainbowBorderHost"
borderHost.Position = UDim2.fromOffset(3, 3)
borderHost.Size = UDim2.new(1, -6, 1, -6)
borderHost.BackgroundTransparency = 1
borderHost.BorderSizePixel = 0
borderHost.Active = false
borderHost.ClipsDescendants = false
borderHost.ZIndex = 980
borderHost.Parent = Panel
AddCorner(borderHost, math.max(1, CORNER_RADIUS - 1))
PanelBorder, PanelBorderGradient = AddRainbowBorder(
borderHost,
2.62,
0.012,
2.75
)
PanelBorderGradient.Color = DB_DEEP_RAINBOW_FLOW
PanelBorder.Enabled = true
borderHost.Visible = true
end
local DBWallpaper = {
CurrentIndex = 1,
Transparency = 0.45,
Assets = {},
TintColor = Color3.fromRGB(255, 255, 255),
Brightness = 1.00,
}
do
local layer = Instance.new("ImageLabel")
layer.Name = "DB_WallpaperLayer"
layer.Position = UDim2.fromOffset(-1, -1)
layer.Size = UDim2.new(1, 2, 1, 2)
layer.BackgroundTransparency = 1
layer.BorderSizePixel = 0
layer.Image = ""
layer.ImageTransparency = DBWallpaper.Transparency
layer.ScaleType = Enum.ScaleType.Crop
layer.ZIndex = 3
layer.Active = false
layer.Parent = Body
local wallpaperCorner =
Instance.new(
"UICorner"
)
wallpaperCorner.Name =
"DB_WallpaperCorner"
wallpaperCorner.CornerRadius =
UDim.new(
0,
CORNER_RADIUS + 1
)
wallpaperCorner.Parent =
layer
DBWallpaper.Layer = layer
function DBWallpaper.RefreshVisual()
if not DBWallpaper.Layer then
return
end
DBWallpaper.Layer.ImageTransparency = math.clamp(DBWallpaper.Transparency, 0, 1)
local c = DBWallpaper.TintColor
local b = math.clamp(DBWallpaper.Brightness, 0.20, 1.00)
DBWallpaper.Layer.ImageColor3 = Color3.new(
math.clamp(c.R * b, 0, 1),
math.clamp(c.G * b, 0, 1),
math.clamp(c.B * b, 0, 1)
)
end
function DBWallpaper.SetTransparency(value)
DBWallpaper.Transparency = math.clamp(value or 0, 0, 1)
DBWallpaper.RefreshVisual()
end
function DBWallpaper.SetTintColor(color)
if typeof(color) == "Color3" then
DBWallpaper.TintColor = color
DBWallpaper.RefreshVisual()
end
end
function DBWallpaper.SetBrightness(value)
DBWallpaper.Brightness = math.clamp(value or 1, 0.20, 1.00)
DBWallpaper.RefreshVisual()
end
function DBWallpaper.SetFromURL(url)
url = tostring(url or "")
url = url:gsub("^%s+", ""):gsub("%s+$", "")
if url == "" then
return false, "请输入图片URL"
end
if not url:match("^https?://") then
return false, "必须是 http/https 图片直链"
end
local env = nil
pcall(function()
if type(getgenv) == "function" then
env = getgenv()
end
end)
env = env or _G
if DBWallpaper.Layer then
local oldImage = DBWallpaper.Layer.Image
local ok = pcall(function()
DBWallpaper.Layer.Image = url
game:GetService(
"ContentProvider"
):PreloadAsync({
DBWallpaper.Layer
})
task.wait(0.15)
end)
if ok
and DBWallpaper.Layer.IsLoaded then
DBWallpaper.Assets[7] = url
DBWallpaper.CurrentIndex = 7
DBWallpaper.RefreshVisual()
return true, "远程图片直接加载成功"
end
DBWallpaper.Layer.Image = oldImage
end
local urlAssetNames = {
"getcustomassetfromurl",
"getcustomasset_from_url",
"getassetfromurl",
"getsynassetfromurl",
"getsynasset_from_url",
}
for _, name in ipairs(urlAssetNames) do
local fn = env[name]
if type(fn) == "function" then
local ok, asset =
pcall(
fn,
url
)
if ok
and type(asset) == "string"
and asset ~= "" then
DBWallpaper.Assets[7] = asset
DBWallpaper.CurrentIndex = 7
DBWallpaper.Apply(7)
return true, "URL资产接口加载成功"
end
end
end
local writer = writefile
local assetLoader =
getcustomasset
or getsynasset
if type(writer) ~= "function"
or type(assetLoader) ~= "function" then
return false, "当前执行器缺少 writefile/getcustomasset"
end
local requestFn =
env.request
or env.http_request
or env.httprequest
or env.krnl_request
or env.secure_request
if not requestFn
and env.syn
and type(env.syn) == "table" then
requestFn = env.syn.request
end
if not requestFn
and env.http
and type(env.http) == "table" then
requestFn = env.http.request
end
if not requestFn
and env.fluxus
and type(env.fluxus) == "table" then
requestFn = env.fluxus.request
end
local HttpService =
game:GetService("HttpService")
local urls = {url}
local okProxy, proxyUrl =
pcall(function()
return
"https://images.weserv.nl/?url="
.. HttpService:UrlEncode(url)
end)
if okProxy and proxyUrl then
table.insert(urls, proxyUrl)
end
local body = nil
local contentType = nil
local usedUrl = nil
local function Download(targetUrl)
local b = nil
local ct = nil
local status = nil
if type(requestFn) == "function" then
local ok, response =
pcall(
requestFn,
{
Url = targetUrl,
Method = "GET",
Headers = {
["User-Agent"] =
"Mozilla/5.0 (Android) AppleWebKit/537.36 Chrome/140 Mobile Safari/537.36",
["Accept"] =
"image/avif,image/webp,image/apng,image/png,image/jpeg,image/*,*/*;q=0.8",
}
}
)
if ok
and type(response) == "table" then
b = response.Body or response.body
status =
response.StatusCode
or response.Status
or response.status_code
local headers =
response.Headers
or response.headers
if type(headers) == "table" then
ct =
headers["Content-Type"]
or headers["content-type"]
or headers["CONTENT-TYPE"]
end
end
end
if tonumber(status)
and tonumber(status) >= 400 then
b = nil
end
if type(b) ~= "string"
or #b < 64 then
local ok, result =
pcall(function()
return game:HttpGet(
targetUrl,
true
)
end)
if ok
and type(result) == "string" then
b = result
end
end
if type(b) ~= "string"
or #b < 64 then
local ok, result =
pcall(function()
return HttpService:GetAsync(
targetUrl,
false
)
end)
if ok
and type(result) == "string" then
b = result
end
end
return b, ct
end
for _, targetUrl in ipairs(urls) do
local b, ct = Download(targetUrl)
if type(b) == "string"
and #b >= 64 then
body = b
contentType = ct
usedUrl = targetUrl
break
end
end
if type(body) ~= "string"
or #body < 64 then
return false,
"下载失败：执行器或当前网络无法访问这个图床"
end
local prefix =
string.lower(
string.sub(body, 1, 120)
)
if prefix:find("<!doctype html", 1, true)
or prefix:find("<html", 1, true) then
return false,
"这个链接返回的是网页，不是图片数据"
end
local lowerUrl = string.lower(url)
local lowerType =
string.lower(
tostring(contentType or "")
)
local ext = nil
if lowerType:find("image/jpeg", 1, true)
or lowerUrl:match("%.jpe?g[%?#]?") then
ext = ".jpg"
elseif lowerType:find("image/png", 1, true)
or lowerUrl:match("%.png[%?#]?") then
ext = ".png"
elseif lowerType:find("image/webp", 1, true)
or lowerUrl:match("%.webp[%?#]?") then
ext = ".webp"
end
if not ext then
local b1,b2,b3,b4,b5,b6,b7,b8 =
string.byte(body, 1, 8)
if b1 == 0xFF
and b2 == 0xD8
and b3 == 0xFF then
ext = ".jpg"
elseif b1 == 0x89
and b2 == 0x50
and b3 == 0x4E
and b4 == 0x47
and b5 == 0x0D
and b6 == 0x0A
and b7 == 0x1A
and b8 == 0x0A then
ext = ".png"
elseif string.sub(body,1,4) == "RIFF"
and string.sub(body,9,12) == "WEBP" then
ext = ".webp"
end
end
if not ext then
return false, "无法识别这个图片格式"
end
local path =
"DB_SCRIPT_URL_WALLPAPER_"
.. tostring(
math.floor(
os.clock() * 100000
)
)
.. ext
local okWrite =
pcall(
writer,
path,
body
)
if not okWrite then
return false, "图片下载成功，但保存失败"
end
local okAsset, asset =
pcall(
assetLoader,
path
)
if not okAsset
or type(asset) ~= "string"
or asset == "" then
return false,
"图片已保存，但执行器不能把它显示为壁纸"
end
DBWallpaper.Assets[7] = asset
DBWallpaper.CurrentIndex = 7
DBWallpaper.Apply(7)
if usedUrl == url then
return true, "图床壁纸已应用"
end
return true, "已通过兼容线路应用图床壁纸"
end
function DBWallpaper.Apply(index)
index = math.clamp(tonumber(index) or 1, 1, 7)
DBWallpaper.CurrentIndex = index
local asset = DBWallpaper.Assets[index]
if asset and asset ~= "" and DBWallpaper.Layer then
DBWallpaper.Layer.Image = asset
end
DBWallpaper.RefreshVisual()
end
end
DBVisualSettings = {
ButtonBordersEnabled = false,
ButtonBackground = Color3.fromRGB(255, 255, 255),
ButtonTransparency = 0.84,
TransitionStyle = "原版",
SpatialModeEnabled = true,
SpatialStyle = "默认",
SpatialAnchorOffsetX = 0,
SpatialAnchorOffsetY = 0,
SpatialLogoBackgroundEnabled = true,
SpatialBorderMode = "默认",
SpatialNavBoxesEnabled = false,
}
DBSpatial = {
Enabled = false,
}

function DBSpatial.ScreenToGuiPoint(guiObject, inputPosition)
    if not guiObject or not inputPosition then return nil end
    local surface = nil
    local current = guiObject
    while current do
        if current:IsA("SurfaceGui") then surface = current break end
        current = current.Parent
    end
    if not surface or not surface.Adornee or not surface.Adornee:IsA("BasePart") then return nil end
    local camera = workspace.CurrentCamera
    if not camera then return nil end
    local part = surface.Adornee
    local x = tonumber(inputPosition.X) or 0
    local y = tonumber(inputPosition.Y) or 0
    local ray = camera:ViewportPointToRay(x, y)
    local normal = part.CFrame.LookVector
    local planePoint = part.Position + normal * (part.Size.Z * 0.5)
    local denom = ray.Direction:Dot(normal)
    if math.abs(denom) < 0.00001 then return nil end
    local t = (planePoint - ray.Origin):Dot(normal) / denom
    if t <= 0 then return nil end
    local worldPoint = ray.Origin + ray.Direction * t
    local localPoint = part.CFrame:PointToObjectSpace(worldPoint)
    if math.abs(localPoint.X) > part.Size.X * 0.56 or math.abs(localPoint.Y) > part.Size.Y * 0.56 then return nil end
    local canvas = surface.CanvasSize
    local px = (0.5 - localPoint.X / math.max(0.001, part.Size.X)) * canvas.X
    local py = (0.5 - localPoint.Y / math.max(0.001, part.Size.Y)) * canvas.Y
    return Vector2.new(px, py), surface
end

function DBSpatial.InputAxis(guiObject, inputPosition, axis)
    local p = DBSpatial.ScreenToGuiPoint(guiObject, inputPosition)
    if p then
        if axis == "Y" then return p.Y end
        return p.X
    end
    if axis == "Y" then return tonumber(inputPosition and inputPosition.Y) end
    return tonumber(inputPosition and inputPosition.X)
end
function DBVisualSettings.ApplyButtonBorders()
if not Panel then return end
for _, obj in ipairs(Panel:GetDescendants()) do
if obj:IsA("TextButton") then
for _, child in ipairs(obj:GetChildren()) do
if child:IsA("UIStroke") then
local base = child:GetAttribute("DB_BaseTransparency")
if base == nil then
base = child.Transparency
child:SetAttribute("DB_BaseTransparency", base)
end
child.Transparency = DBVisualSettings.ButtonBordersEnabled and base or 1
end
end
end
end
end
function DBVisualSettings.SetButtonBorders(enabled)
DBVisualSettings.ButtonBordersEnabled = enabled == true
DBVisualSettings.ApplyButtonBorders()
end
local function StyleLiquidButton(btn, radius, strong)
radius = radius or 9
btn.BackgroundColor3 = DBVisualSettings.ButtonBackground
btn.BackgroundTransparency = strong and 0.80 or DBVisualSettings.ButtonTransparency
btn.BorderSizePixel = 0
btn.AutoButtonColor = false
btn.ClipsDescendants = false
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextTransparency = 0
btn.Font = Enum.Font.GothamBlack
btn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
btn.TextStrokeTransparency = 0.62
AddCorner(btn, radius)
local stroke = Instance.new("UIStroke")
stroke.Name = "DB_StableGlassStroke"
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Thickness = strong and 1.05 or 0.85
stroke.Color = Color3.fromRGB(255, 255, 255)
local baseTransparency = strong and 0.40 or 0.52
stroke:SetAttribute("DB_BaseTransparency", baseTransparency)
stroke.Transparency = DBVisualSettings.ButtonBordersEnabled and baseTransparency or 1
stroke.LineJoinMode = Enum.LineJoinMode.Round
stroke.Parent = btn
local scale = Instance.new("UIScale")
scale.Name = "DB_StableGlassScale"
scale.Scale = 1
scale.Parent = btn
local function RestoreGlass()
if not btn.Parent then return end
local spatialActive = DBSpatial and type(DBSpatial.IsActive) == "function" and DBSpatial.IsActive()
if spatialActive and btn:GetAttribute("DB_SpatialNavButton") == true then
    local selected = btn:GetAttribute("DB_SpatialSelected") == true
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundTransparency = selected and 0.80 or 1
    stroke.Color = Color3.fromRGB(255,255,255)
    stroke.Transparency = 1
    return
elseif spatialActive and btn:GetAttribute("DB_SpatialActionButton") == true then
    local base = tonumber(btn:GetAttribute("DB_SpatialActionBaseTransparency"))
    if base == nil then base = DBVisualSettings.ButtonTransparency end
    local baseColor = btn:GetAttribute("DB_SpatialActionBaseColor")
    if typeof(baseColor) ~= "Color3" then baseColor = DBVisualSettings.ButtonBackground end
    local pulseUntil = tonumber(btn:GetAttribute("DB_SpatialActionPulseUntil")) or 0
    if pulseUntil > os.clock() then
        btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
        btn.BackgroundTransparency = 0.52
    else
        btn.BackgroundColor3 = baseColor
        btn.BackgroundTransparency = math.clamp(base,0,1)
    end
    stroke.Color = Color3.fromRGB(255,255,255)
    stroke.Transparency = 1
    return
end
btn.BackgroundColor3 = DBVisualSettings.ButtonBackground
btn.BackgroundTransparency = strong and 0.80 or DBVisualSettings.ButtonTransparency
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Transparency = DBVisualSettings.ButtonBordersEnabled and baseTransparency or 1
end
btn.MouseEnter:Connect(RestoreGlass)
btn.MouseLeave:Connect(function()
RestoreGlass()
TweenService:Create(scale, TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
end)
btn.InputBegan:Connect(function(input)
if input.UserInputType ~= Enum.UserInputType.MouseButton1
and input.UserInputType ~= Enum.UserInputType.Touch then return end
if DBSpatial and type(DBSpatial.IsActive)=="function" and DBSpatial.IsActive()
and (btn:GetAttribute("DB_SpatialNavButton")==true or btn:GetAttribute("DB_SpatialActionButton")==true) then
    RestoreGlass()
    return
end
RestoreGlass()
TweenService:Create(scale, TweenInfo.new(0.055, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.972}):Play()
end)
btn.InputEnded:Connect(function(input)
if input.UserInputType ~= Enum.UserInputType.MouseButton1
and input.UserInputType ~= Enum.UserInputType.Touch then return end
if DBSpatial and type(DBSpatial.IsActive)=="function" and DBSpatial.IsActive()
and (btn:GetAttribute("DB_SpatialNavButton")==true or btn:GetAttribute("DB_SpatialActionButton")==true) then
    return
end
RestoreGlass()
TweenService:Create(scale, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
end)
btn.Activated:Connect(function()
    if DBSpatial and type(DBSpatial.IsActive)=="function" and DBSpatial.IsActive()
    and (btn:GetAttribute("DB_SpatialNavButton")==true or btn:GetAttribute("DB_SpatialActionButton")==true) then
        return
    end
    task.defer(RestoreGlass)
end)
return stroke
end
local FloatingButton = Instance.new("Frame")
FloatingButton.Name = "FloatingButton"
FloatingButton.AnchorPoint = Vector2.new(0.5, 0.5)
FloatingButton.Size = UDim2.fromOffset(FLOATING_WIDTH, FLOATING_HEIGHT)
FloatingButton.BackgroundColor3 = Color3.fromRGB(6, 9, 13)
FloatingButton.BackgroundTransparency = 0.06
FloatingButton.BorderSizePixel = 0
FloatingButton.Active = true
FloatingButton.ClipsDescendants = true
FloatingButton.Visible = false
FloatingButton.ZIndex = 1200
FloatingButton.Parent = MainGui
local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(1, 0)
BtnCorner.Parent = FloatingButton
local BtnBorder, BtnGrad = AddRainbowBorder(FloatingButton, 1.7, 0.01, 3.1)
local FloatingTransitionScale = Instance.new("UIScale")
FloatingTransitionScale.Name = "DB_AppleTransitionScale"
FloatingTransitionScale.Scale = 1
FloatingTransitionScale.Parent = FloatingButton
local FloatingDragZone = Instance.new("TextButton")
FloatingDragZone.Name = "FloatingDragZone"
FloatingDragZone.Size = UDim2.fromOffset(FLOATING_DRAG_WIDTH, FLOATING_HEIGHT)
FloatingDragZone.Position = UDim2.fromOffset(0, 0)
FloatingDragZone.BackgroundTransparency = 1
FloatingDragZone.BorderSizePixel = 0
FloatingDragZone.Text = ""
FloatingDragZone.AutoButtonColor = false
FloatingDragZone.Active = true
FloatingDragZone.ZIndex = 103
FloatingDragZone.Parent = FloatingButton
local FloatingMoveIcon = Instance.new("ImageLabel")
FloatingMoveIcon.Name = "DB_MoveFourWayImage"
FloatingMoveIcon.AnchorPoint = Vector2.new(0.5, 0.5)
FloatingMoveIcon.Position = UDim2.fromScale(0.5, 0.5)
FloatingMoveIcon.Size = UDim2.fromOffset(20, 20)
FloatingMoveIcon.BackgroundTransparency = 1
FloatingMoveIcon.BorderSizePixel = 0
FloatingMoveIcon.Image = ""
FloatingMoveIcon.ImageColor3 = Color3.fromRGB(242, 242, 246)
FloatingMoveIcon.ScaleType = Enum.ScaleType.Fit
FloatingMoveIcon.ZIndex = 105
FloatingMoveIcon.Parent = FloatingDragZone
local FloatingMoveFallback = Instance.new("TextLabel")
FloatingMoveFallback.AnchorPoint = Vector2.new(0.5, 0.5)
FloatingMoveFallback.Position = UDim2.fromScale(0.5, 0.5)
FloatingMoveFallback.Size = UDim2.fromOffset(21, 21)
FloatingMoveFallback.BackgroundTransparency = 1
FloatingMoveFallback.Text = "✥"
FloatingMoveFallback.TextColor3 = Color3.fromRGB(238, 238, 242)
FloatingMoveFallback.TextSize = 15
FloatingMoveFallback.Font = Enum.Font.GothamBold
FloatingMoveFallback.ZIndex = 104
FloatingMoveFallback.Parent = FloatingDragZone
local FloatingSeparator = Instance.new("Frame")
FloatingSeparator.Position = UDim2.fromOffset(FLOATING_DRAG_WIDTH, 7)
FloatingSeparator.Size = UDim2.fromOffset(1, FLOATING_HEIGHT - 12)
FloatingSeparator.BackgroundColor3 = Color3.fromRGB(150, 155, 165)
FloatingSeparator.BackgroundTransparency = 0.62
FloatingSeparator.BorderSizePixel = 0
FloatingSeparator.ZIndex = 102
FloatingSeparator.Parent = FloatingButton
local FloatingOpenZone = Instance.new("TextButton")
FloatingOpenZone.Name = "FloatingOpenZone"
FloatingOpenZone.Position = UDim2.fromOffset(FLOATING_DRAG_WIDTH + 1, 0)
FloatingOpenZone.Size = UDim2.new(1, -(FLOATING_DRAG_WIDTH + 1), 1, 0)
FloatingOpenZone.BackgroundTransparency = 1
FloatingOpenZone.BorderSizePixel = 0
FloatingOpenZone.Text = ""
FloatingOpenZone.AutoButtonColor = false
FloatingOpenZone.Active = true
FloatingOpenZone.ZIndex = 1203
FloatingOpenZone.Parent = FloatingButton
local FloatingBrandLogo = Instance.new("ImageLabel")
FloatingBrandLogo.Name = "FloatingBrandLogo"
FloatingBrandLogo.AnchorPoint = Vector2.new(0, 0.5)
FloatingBrandLogo.Position = UDim2.new(0, 12, 0.5, 0)
FloatingBrandLogo.Size = UDim2.fromOffset(29, 29)
FloatingBrandLogo.BackgroundTransparency = 1
FloatingBrandLogo.BorderSizePixel = 0
FloatingBrandLogo.ScaleType = Enum.ScaleType.Fit
FloatingBrandLogo.Image = DBSharedLogoAsset
FloatingBrandLogo.ZIndex = 1204
FloatingBrandLogo.Parent = FloatingOpenZone
local FloatingBrandLogoFallback = Instance.new("TextLabel")
FloatingBrandLogoFallback.Position = FloatingBrandLogo.Position
FloatingBrandLogoFallback.Size = FloatingBrandLogo.Size
FloatingBrandLogoFallback.BackgroundTransparency = 1
FloatingBrandLogoFallback.Text = "鱼"
FloatingBrandLogoFallback.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingBrandLogoFallback.TextSize = 12
FloatingBrandLogoFallback.Font = Enum.Font.GothamBlack
FloatingBrandLogoFallback.ZIndex = 1203
FloatingBrandLogoFallback.Visible = DBSharedLogoAsset == ""
FloatingBrandLogoFallback.Parent = FloatingOpenZone
local FloatingBrandName = Instance.new("TextLabel")
FloatingBrandName.Position = UDim2.fromOffset(49, 0)
FloatingBrandName.Size = UDim2.new(1, -54, 1, 0)
FloatingBrandName.BackgroundTransparency = 1
FloatingBrandName.Text = "大肥鱼脚本"
FloatingBrandName.TextColor3 = Color3.fromRGB(255, 246, 220)
FloatingBrandName.TextSize = 13
FloatingBrandName.Font = Enum.Font.GothamBlack
FloatingBrandName.TextXAlignment = Enum.TextXAlignment.Left
FloatingBrandName.TextYAlignment = Enum.TextYAlignment.Center
FloatingBrandName.ZIndex = 1204
FloatingBrandName.Parent = FloatingOpenZone
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 28)
Header.BackgroundTransparency = 1
Header.Active = true
Header.ZIndex = 10
Header.Parent = Body
local DragArea = Instance.new("TextButton")
DragArea.Name = "DragArea"
DragArea.Size = UDim2.new(1, -34, 1, 0)
DragArea.Position = UDim2.fromOffset(0, 0)
DragArea.BackgroundTransparency = 1
DragArea.BorderSizePixel = 0
DragArea.Text = ""
DragArea.AutoButtonColor = false
DragArea.Active = true
DragArea.ZIndex = 20
DragArea.Parent = Header
local HeaderLogo = Instance.new("ImageLabel")
HeaderLogo.Name = "DB_HeaderLogo_D"
HeaderLogo.Position = UDim2.fromOffset(7, 2)
HeaderLogo.Size = UDim2.fromOffset(24, 24)
HeaderLogo.BackgroundTransparency = 1
HeaderLogo.BorderSizePixel = 0
HeaderLogo.ScaleType = Enum.ScaleType.Fit
HeaderLogo.Image = DBSharedLogoAsset
HeaderLogo.ZIndex = 24
HeaderLogo.Parent = DragArea
local HeaderLogoFallback = Instance.new("TextLabel")
HeaderLogoFallback.Position = HeaderLogo.Position
HeaderLogoFallback.Size = HeaderLogo.Size
HeaderLogoFallback.BackgroundTransparency = 1
HeaderLogoFallback.Text = "鱼"
HeaderLogoFallback.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderLogoFallback.TextSize = 12
HeaderLogoFallback.Font = Enum.Font.GothamBlack
HeaderLogoFallback.ZIndex = 23
HeaderLogoFallback.Visible = DBSharedLogoAsset == ""
HeaderLogoFallback.Parent = DragArea
FloatingMoveIcon.Image = DBMoveFourWayAsset

do
    for i = 1, 6 do
        local asset = DBLoadLocalAsset("DB_SCRIPT_WALLPAPER_" .. tostring(i) .. ".jpg")
        if asset ~= "" then
            DBWallpaper.Assets[i] = asset
        end
    end
    DBWallpaper.Apply(DBWallpaper.CurrentIndex)
    DBWallpaper.SetTransparency(DBWallpaper.Transparency)
end
local Title = Instance.new("TextLabel")
Title.Name = "DB_SCRIPT_Title"
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(35, 1)
Title.Size = UDim2.fromOffset(82, 26)
Title.Text = "大肥鱼脚本"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextTransparency = 0
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 21
Title.Parent = DragArea
local TitleRainbow =
StartRainbowFlow(
Title,
4.25,
NumberSequence.new(0)
)
local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.fromOffset(119, 7)
Subtitle.Size = UDim2.new(1, -160, 0, 15)
Subtitle.Text = "V8.90 · Q群:819503470"
Subtitle.TextColor3 = UI.SubText
Subtitle.TextTransparency = 0
Subtitle.TextSize = 9
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.ZIndex = 21
Subtitle.Parent = DragArea
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "Close"
CloseBtn.Size = UDim2.fromOffset(26, 26)
CloseBtn.Position = UDim2.new(1, -30, 0, 1)
CloseBtn.BackgroundColor3 = UI.Button
CloseBtn.BackgroundTransparency = 1
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "−"
CloseBtn.TextColor3 = UI.Text
CloseBtn.TextTransparency = 0
CloseBtn.TextSize = 22
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 30
CloseBtn.Parent = Header
local CloseBtnScale = Instance.new("UIScale")
CloseBtnScale.Scale = 1
CloseBtnScale.Parent = CloseBtn
CloseBtn.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.Touch
or input.UserInputType == Enum.UserInputType.MouseButton1 then
TweenService:Create(
CloseBtnScale,
TweenInfo.new(0.05),
{Scale = 0.90}
):Play()
end
end)
CloseBtn.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.Touch
or input.UserInputType == Enum.UserInputType.MouseButton1 then
TweenService:Create(
CloseBtnScale,
TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
{Scale = 1}
):Play()
end
end)
do
local exitBtn = Instance.new("TextButton")
exitBtn.Name = "Exit"
exitBtn.Size = UDim2.fromOffset(26, 26)
exitBtn.Position = UDim2.new(1, -58, 0, 1)
exitBtn.BackgroundTransparency = 1
exitBtn.BorderSizePixel = 0
exitBtn.Text = "×"
exitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
exitBtn.TextTransparency = 0
exitBtn.TextSize = 20
exitBtn.Font = Enum.Font.GothamBold
exitBtn.AutoButtonColor = false
exitBtn.ZIndex = 30
exitBtn.Parent = Header
local scale = Instance.new("UIScale")
scale.Scale = 1
scale.Parent = exitBtn
exitBtn.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.Touch
or input.UserInputType == Enum.UserInputType.MouseButton1 then
TweenService:Create(scale, TweenInfo.new(0.05), {Scale = 0.90}):Play()
end
end)
exitBtn.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.Touch
or input.UserInputType == Enum.UserInputType.MouseButton1 then
TweenService:Create(
scale,
TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
{Scale = 1}
):Play()
end
end)
end
local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(6, 31)
Content.Size = UDim2.new(1, -12, 1, -47)
Content.BackgroundTransparency = 1
Content.ZIndex = 10
Content.Parent = Body
local PROFILE_RAIL_WIDTH = 104
local FUNCTION_RAIL_WIDTH = 130
local COLUMN_GAP = 6
local PlayerProfileRail = Instance.new("Frame")
PlayerProfileRail.Name = "DB_PlayerProfileRail"
PlayerProfileRail.Position = UDim2.fromOffset(0, 0)
PlayerProfileRail.Size = UDim2.new(0, PROFILE_RAIL_WIDTH, 1, 0)
PlayerProfileRail.BackgroundTransparency = 1
PlayerProfileRail.BorderSizePixel = 0
PlayerProfileRail.ClipsDescendants = true
PlayerProfileRail.ZIndex = 15
PlayerProfileRail.Parent = Content
local ProfileRailDivider = Instance.new("Frame")
ProfileRailDivider.Name = "DB_ProfileRailDivider"
ProfileRailDivider.AnchorPoint = Vector2.new(1, 0)
ProfileRailDivider.Position = UDim2.new(1, -1, 0, 4)
ProfileRailDivider.Size = UDim2.new(0, 1, 1, -8)
ProfileRailDivider.BackgroundColor3 = Color3.fromRGB(150, 205, 240)
ProfileRailDivider.BackgroundTransparency = 0.72
ProfileRailDivider.BorderSizePixel = 0
ProfileRailDivider.ZIndex = 16
ProfileRailDivider.Parent = PlayerProfileRail

local PlayerProfileScroll = Instance.new("ScrollingFrame")
PlayerProfileScroll.Name = "DB_PlayerProfileScroll"
PlayerProfileScroll.Position = UDim2.fromOffset(0, 0)
PlayerProfileScroll.Size = UDim2.new(1, -2, 1, 0)
PlayerProfileScroll.BackgroundTransparency = 1
PlayerProfileScroll.BorderSizePixel = 0
PlayerProfileScroll.CanvasSize = UDim2.fromOffset(0, 500)
PlayerProfileScroll.AutomaticCanvasSize = Enum.AutomaticSize.None
PlayerProfileScroll.ScrollingDirection = Enum.ScrollingDirection.Y
PlayerProfileScroll.ScrollBarThickness = 2
PlayerProfileScroll.ScrollBarImageColor3 = Color3.fromRGB(225, 225, 232)
PlayerProfileScroll.ScrollBarImageTransparency = 0.58
PlayerProfileScroll.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
PlayerProfileScroll.ScrollingEnabled = true
PlayerProfileScroll.Active = true
PlayerProfileScroll.ClipsDescendants = true
PlayerProfileScroll.ZIndex = 15
PlayerProfileScroll.Parent = PlayerProfileRail

local LeftMenu = Instance.new("Frame")
LeftMenu.Size = UDim2.new(0, FUNCTION_RAIL_WIDTH, 1, 0)
LeftMenu.Position = UDim2.new(1, -FUNCTION_RAIL_WIDTH, 0, 0)
LeftMenu.BackgroundTransparency = 1
LeftMenu.Parent = Content
local FunctionRailDivider = Instance.new("Frame")
FunctionRailDivider.Name = "DB_FunctionRailDivider"
FunctionRailDivider.Position = UDim2.fromOffset(0, 4)
FunctionRailDivider.Size = UDim2.new(0, 1, 1, -8)
FunctionRailDivider.BackgroundColor3 = Color3.fromRGB(150, 205, 240)
FunctionRailDivider.BackgroundTransparency = 0.72
FunctionRailDivider.BorderSizePixel = 0
FunctionRailDivider.ZIndex = 16
FunctionRailDivider.Parent = LeftMenu
local SpecialMenuHost = Instance.new("Frame")
SpecialMenuHost.Name = "SpecialMenuHost"
SpecialMenuHost.Size = UDim2.new(0.50, 0, 1, 0)
SpecialMenuHost.Position = UDim2.fromOffset(0, 0)
SpecialMenuHost.BackgroundTransparency = 1
SpecialMenuHost.BorderSizePixel = 0
SpecialMenuHost.ClipsDescendants = true
SpecialMenuHost.Parent = LeftMenu
local NormalMenuHost = Instance.new("Frame")
NormalMenuHost.Name = "NormalMenuHost"
NormalMenuHost.Size = UDim2.new(0.50, 0, 1, 0)
NormalMenuHost.Position = UDim2.new(0.50, 0, 0, 0)
NormalMenuHost.BackgroundTransparency = 1
NormalMenuHost.BorderSizePixel = 0
NormalMenuHost.ClipsDescendants = true
NormalMenuHost.Parent = LeftMenu
local SpecialMenuScroll = Instance.new("ScrollingFrame")
SpecialMenuScroll.Name = "SpecialMenuScroll"
SpecialMenuScroll.Size = UDim2.fromScale(1, 1)
SpecialMenuScroll.BackgroundTransparency = 1
SpecialMenuScroll.BorderSizePixel = 0
SpecialMenuScroll.ScrollBarThickness = 2
SpecialMenuScroll.ScrollBarImageColor3 = Color3.fromRGB(205, 205, 210)
SpecialMenuScroll.ScrollBarImageTransparency = 0.55
SpecialMenuScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
SpecialMenuScroll.CanvasSize = UDim2.new()
SpecialMenuScroll.ScrollingDirection = Enum.ScrollingDirection.Y
SpecialMenuScroll.ScrollingEnabled = true
SpecialMenuScroll.Active = true
SpecialMenuScroll.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
SpecialMenuScroll.ClipsDescendants = true
SpecialMenuScroll.Parent = SpecialMenuHost
local SpecialMenuLayout = Instance.new("UIListLayout")
SpecialMenuLayout.Padding = UDim.new(0, 4)
SpecialMenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
SpecialMenuLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SpecialMenuLayout.Parent = SpecialMenuScroll
local SpecialMenuPadding = Instance.new("UIPadding")
SpecialMenuPadding.PaddingTop = UDim.new(0, 4)
SpecialMenuPadding.PaddingBottom = UDim.new(0, 4)
SpecialMenuPadding.PaddingLeft = UDim.new(0, 2)
SpecialMenuPadding.PaddingRight = UDim.new(0, 2)
SpecialMenuPadding.Parent = SpecialMenuScroll
local MenuScroll = Instance.new("ScrollingFrame")
MenuScroll.Name = "NormalMenuScroll"
MenuScroll.Size = UDim2.fromScale(1, 1)
MenuScroll.BackgroundTransparency = 1
MenuScroll.BorderSizePixel = 0
MenuScroll.ScrollBarThickness = 2
MenuScroll.ScrollBarImageColor3 = Color3.fromRGB(205, 205, 210)
MenuScroll.ScrollBarImageTransparency = 0.55
MenuScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
MenuScroll.CanvasSize = UDim2.new()
MenuScroll.ScrollingDirection = Enum.ScrollingDirection.Y
MenuScroll.ScrollingEnabled = true
MenuScroll.Active = true
MenuScroll.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
MenuScroll.ClipsDescendants = true
MenuScroll.Parent = NormalMenuHost
local MenuLayout = Instance.new("UIListLayout")
MenuLayout.Padding = UDim.new(0, 8)
MenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
MenuLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
MenuLayout.Parent = MenuScroll
local MenuScrollPadding = Instance.new("UIPadding")
MenuScrollPadding.PaddingTop = UDim.new(0, 7)
MenuScrollPadding.PaddingBottom = UDim.new(0, 8)
MenuScrollPadding.PaddingLeft = UDim.new(0, 2)
MenuScrollPadding.PaddingRight = UDim.new(0, 2)
MenuScrollPadding.Parent = MenuScroll
local RightList = Instance.new("Frame")
RightList.Size = UDim2.new(
1,
-(PROFILE_RAIL_WIDTH + FUNCTION_RAIL_WIDTH + COLUMN_GAP * 2),
1,
0
)
RightList.Position = UDim2.new(
0,
PROFILE_RAIL_WIDTH + COLUMN_GAP,
0,
0
)
RightList.BackgroundTransparency = 1
RightList.Parent = Content
local ListScroll = Instance.new("ScrollingFrame")
ListScroll.Size = UDim2.new(1, -10, 1, -8)
ListScroll.Position = UDim2.fromOffset(5, 4)
ListScroll.BackgroundTransparency = 1
ListScroll.BorderSizePixel = 0
ListScroll.ScrollBarThickness = 2
ListScroll.ScrollBarImageColor3 = Color3.fromRGB(205, 205, 210)
ListScroll.ScrollBarImageTransparency = 0.55
ListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ListScroll.CanvasSize = UDim2.new()
ListScroll.Active = true
ListScroll.ScrollingEnabled = true
ListScroll.ClipsDescendants = true
ListScroll.Parent = RightList
local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 4)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ListLayout.Parent = ListScroll
local ListScrollPadding = Instance.new("UIPadding")
ListScrollPadding.PaddingTop = UDim.new(0, 4)
ListScrollPadding.PaddingBottom = UDim.new(0, 4)
ListScrollPadding.PaddingLeft = UDim.new(0, 0)
ListScrollPadding.PaddingRight = UDim.new(0, 0)
ListScrollPadding.Parent = ListScroll
local DB_UNIFIED_SIDE_PAD = 10
local DB_LEFT_FUNCTION_LABELS = {
{
Text = "主页",
Size = 14,
Font = Enum.Font.GothamBold
},
{
Text = "玩家面板",
Size = 14,
Font = Enum.Font.GothamBold
},
{
Text = "大肥鱼通用",
Size = 14,
Font = Enum.Font.GothamBold
},
{
Text = "通用",
Size = 14,
Font = Enum.Font.GothamMedium
},
{
Text = "脚本合集",
Size = 14,
Font = Enum.Font.GothamBold
},
{
Text = "公告",
Size = 14,
Font = Enum.Font.GothamBold
},
{
Text = "UI界面",
Size = 14,
Font = Enum.Font.GothamBold
},
{
Text = "音乐播放器",
Size = 14,
Font = Enum.Font.GothamBold
},
{
Text = "设置",
Size = 14,
Font = Enum.Font.GothamBold
},
}
local function DBMeasureUnifiedLeftWidth()
local longest = 0
for _, info in ipairs(
DB_LEFT_FUNCTION_LABELS
) do
local measured =
TextService:GetTextSize(
info.Text,
info.Size,
info.Font,
Vector2.new(
1000,
80
)
)
longest =
math.max(
longest,
math.ceil(
measured.X
)
)
end
return longest
+ DB_UNIFIED_SIDE_PAD * 2
end
local DB_UNIFIED_BUTTON_WIDTH =
DBMeasureUnifiedLeftWidth()
SpecialMenuHost.Visible = false
NormalMenuHost.Size =
UDim2.fromScale(
1,
1
)
NormalMenuHost.Position =
UDim2.fromOffset(
0,
0
)
PlayerProfileRail.Size =
UDim2.new(
0,
PROFILE_RAIL_WIDTH,
1,
0
)
PlayerProfileRail.Position =
UDim2.fromOffset(
0,
0
)
LeftMenu.Size =
UDim2.new(
0,
FUNCTION_RAIL_WIDTH,
1,
0
)
LeftMenu.Position =
UDim2.new(
1,
-FUNCTION_RAIL_WIDTH,
0,
0
)
RightList.Position =
UDim2.new(
0,
PROFILE_RAIL_WIDTH + COLUMN_GAP,
0,
0
)
RightList.Size =
UDim2.new(
1,
-(
PROFILE_RAIL_WIDTH
+ FUNCTION_RAIL_WIDTH
+ COLUMN_GAP * 2
),
1,
0
)
MenuScroll.Size =
UDim2.new(
1,
-8,
1,
-8
)
MenuScroll.Position =
UDim2.fromOffset(
4,
4
)
ListScroll.Size =
UDim2.new(
1,
-10,
1,
-8
)
ListScroll.Position =
UDim2.fromOffset(
5,
4
)
local function DBApplyUnifiedButton(
button,
height
)
local compactHeight = math.min(height or 29, 29)
button.Size = UDim2.new(1, -10, 0, compactHeight)
end
local function DBApplyRightFullWidthButton(
button,
height
)
local compactHeight = math.min(height or 30, 30)
button.Size = UDim2.new(1, -12, 0, compactHeight)
end
local function AddHyperOSScrollFrost(
scrollFrame,
hostFrame,
zBase
)
return nil
end
AddHyperOSScrollFrost(
SpecialMenuScroll,
SpecialMenuHost,
520
)
AddHyperOSScrollFrost(
MenuScroll,
NormalMenuHost,
520
)
AddHyperOSScrollFrost(
ListScroll,
RightList,
520
)
local MoveBarHitArea = Instance.new("TextButton")
MoveBarHitArea.Name = "MoveBarHitArea"
MoveBarHitArea.AnchorPoint = Vector2.new(0.5, 1)
MoveBarHitArea.Position = UDim2.new(0.5, 0, 1, -2)
MoveBarHitArea.Size = UDim2.new(3/5, 0, 0, 20)
MoveBarHitArea.BackgroundTransparency = 1
MoveBarHitArea.BorderSizePixel = 0
MoveBarHitArea.Text = ""
MoveBarHitArea.AutoButtonColor = false
MoveBarHitArea.Active = true
MoveBarHitArea.ZIndex = 992
MoveBarHitArea.Parent = Body

local MoveBar = Instance.new("Frame")
MoveBar.Name = "MoveBar"
MoveBar.AnchorPoint = Vector2.new(0.5, 0.5)
MoveBar.Position = UDim2.fromScale(0.5, 0.63)
MoveBar.Size = UDim2.new(1, 0, 0, 3)
MoveBar.BackgroundColor3 = Color3.fromRGB(88, 88, 94)
MoveBar.BackgroundTransparency = 0.20
MoveBar.BorderSizePixel = 0
MoveBar.ZIndex = 993
MoveBar.Parent = MoveBarHitArea
AddCorner(MoveBar, 999)

local MoveBarScale = Instance.new("UIScale")
MoveBarScale.Scale = 1
MoveBarScale.Parent = MoveBar

local MoveBarGlow = Instance.new("UIStroke")
MoveBarGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MoveBarGlow.Thickness = 1.0
MoveBarGlow.Color = Color3.fromRGB(255, 255, 255)
MoveBarGlow.Transparency = 1
MoveBarGlow.LineJoinMode = Enum.LineJoinMode.Round
MoveBarGlow.Parent = MoveBar

local MoveMagicGradient = Instance.new("UIGradient")
MoveMagicGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.35, Color3.fromRGB(165, 228, 255)),
    ColorSequenceKeypoint.new(0.68, Color3.fromRGB(208, 174, 255)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))
})
MoveMagicGradient.Rotation = 0
MoveMagicGradient.Parent = MoveBarGlow

local ResizeHandle = Instance.new("TextButton")
ResizeHandle.Name = "ResizeHandle"
ResizeHandle.AnchorPoint = Vector2.new(0, 0)
ResizeHandle.Position = UDim2.new(1, -26, 1, -26)
ResizeHandle.Size = UDim2.fromOffset(48, 48)
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.BorderSizePixel = 0
ResizeHandle.Text = ""
ResizeHandle.AutoButtonColor = false
ResizeHandle.Active = true
ResizeHandle.ZIndex = 994
ResizeHandle.Parent = Panel

local ResizeArcVisual = Instance.new("TextLabel")
ResizeArcVisual.Name = "ResizeArcVisual"
ResizeArcVisual.AnchorPoint = Vector2.new(0, 0)
ResizeArcVisual.Position = UDim2.fromOffset(12, 10)
ResizeArcVisual.Size = UDim2.fromOffset(36, 36)
ResizeArcVisual.BackgroundTransparency = 1
ResizeArcVisual.BorderSizePixel = 0
ResizeArcVisual.Text = "╯"
ResizeArcVisual.TextColor3 = Color3.fromRGB(150, 150, 156)
ResizeArcVisual.TextTransparency = 0.04
ResizeArcVisual.TextSize = 38
ResizeArcVisual.Font = Enum.Font.GothamMedium
ResizeArcVisual.TextXAlignment = Enum.TextXAlignment.Center
ResizeArcVisual.TextYAlignment = Enum.TextYAlignment.Center
ResizeArcVisual.ZIndex = 995
ResizeArcVisual.Parent = ResizeHandle

local ScriptDatabase = {
["大肥鱼通用"] = {
{
Name = "大肥鱼飞行",
Code = [====[--[[
大肥鱼飞行 · 蓝白附魔独立版 V4
用途：Roblox Studio / 自己拥有的 Experience
推荐位置：
StarterPlayer > StarterPlayerScripts

本版重点：
1. 小型紧凑面板，接近参考图整体尺寸
2. 不再做成一堆分散的小卡片，采用连续分区布局
3. 第一行：关闭 / 缩小，严格各占一半
4. 第二行：上 / 加 / 大肥鱼飞行
5. 第三行：下 / 减 / 速度档位 / 飞
6. 初始速度档位 = 1
7. 飞行后暂停角色动画，保持僵直姿态
8. 手机摇杆 / WASD 控制移动，镜头控制角色朝向
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Controls = nil

pcall(function()
    local playerScripts =
        LocalPlayer:WaitForChild(
            "PlayerScripts"
        )

    local playerModule =
        require(
            playerScripts:WaitForChild(
                "PlayerModule"
            )
        )

    Controls =
        playerModule:GetControls()
end)

local CONFIG = {
    Brand = "大肥鱼飞行",

    PanelWidth = 220,
    PanelHeight = 112,

    SpeedLevel = 1,
    MinSpeedLevel = 1,

    Blue = Color3.fromRGB(255, 255, 255),
    Cyan = Color3.fromRGB(255, 255, 255),
    White = Color3.fromRGB(255, 255, 255),
    Purple = Color3.fromRGB(255, 255, 255),

    Glass = Color3.fromRGB(255, 255, 255),
    Glass2 = Color3.fromRGB(255, 255, 255),
    Divider = Color3.fromRGB(255, 255, 255),
}

local State = {
    Flying = false,
    SpeedLevel = CONFIG.SpeedLevel,
    Vertical = 0,

    BaseFlightSpeed = 32,

    Character = nil,
    Humanoid = nil,
    Root = nil,

    Attachment = nil,
    Velocity = nil,
    Orientation = nil,

    OldAutoRotate = nil,
    OldPlatformStand = nil,
    OldAnimateDisabled = nil,
    OldStateEnabled = {},
    CurrentVelocity = Vector3.zero,
    PartPhysics = {},
}

local function BindCharacter(character)
    State.Character = character
    State.Humanoid = character:WaitForChild("Humanoid")
    State.Root = character:WaitForChild("HumanoidRootPart")
end

if LocalPlayer.Character then
    BindCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(character)
    State.Flying = false
    State.Vertical = 0
    BindCharacter(character)
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DB_FLIGHT_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function AddCorner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = object
    return corner
end

local function AddOuterEnchant(object)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = 0.95
    stroke.Transparency = 0.46
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = object
    return stroke
end

local function AddTextEnchant(label, stronger)
    for _, child in ipairs(label:GetChildren()) do
        if child:IsA("UIGradient") then child:Destroy() end
    end
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 1
end

local function AddGlassGradient(object)
    object.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    object.BackgroundTransparency = 0.88
    for _, child in ipairs(object:GetChildren()) do
        if child:IsA("UIGradient") then child:Destroy() end
    end
end

local function AddMagicDust(parent)
    return nil
end

local Panel = Instance.new("Frame")
Panel.Name = "DB_FLIGHT_PANEL"
Panel.AnchorPoint = Vector2.new(0.5, 0.5)
Panel.Position = UDim2.fromScale(0.5, 0.53)
Panel.Size = UDim2.fromOffset(CONFIG.PanelWidth, CONFIG.PanelHeight)
Panel.BackgroundColor3 = CONFIG.Glass
Panel.BackgroundTransparency = 0.88
Panel.BorderSizePixel = 0
Panel.ClipsDescendants = true
Panel.ZIndex = 10
Panel.Parent = ScreenGui

AddCorner(Panel, 18)

local PanelGlassStroke = Instance.new("UIStroke")
PanelGlassStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
PanelGlassStroke.Thickness = 0.95
PanelGlassStroke.Transparency = 0.46
PanelGlassStroke.Color = Color3.fromRGB(255, 255, 255)
PanelGlassStroke.LineJoinMode = Enum.LineJoinMode.Round
PanelGlassStroke.Parent = Panel

AddGlassGradient(Panel)

local TOP_H = 30
local MID_H = 40
local BOT_H = CONFIG.PanelHeight - TOP_H - MID_H

local function CreateRegion(name, pos, size, text, fontSize, strong)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Position = pos
    button.Size = size
    button.BackgroundColor3 = CONFIG.Glass2
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""
    button.ZIndex = 12
    button.Parent = Panel

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Text = text
    label.TextSize = fontSize or 16
    label.Font = strong and Enum.Font.GothamBlack or Enum.Font.GothamBold
    label.ZIndex = 13
    label.Parent = button

    AddTextEnchant(label, strong)

    return button, label
end

local CloseButton =
    CreateRegion(
        "Close",
        UDim2.new(0, 0, 0, 0),
        UDim2.new(0.5, 0, 0, TOP_H),
        "关闭",
        13,
        true
    )

local MinButton =
    CreateRegion(
        "Minimize",
        UDim2.new(0.5, 0, 0, 0),
        UDim2.new(0.5, 0, 0, TOP_H),
        "缩小",
        13,
        true
    )

local UpButton =
    CreateRegion(
        "Up",
        UDim2.new(0, 0, 0, TOP_H),
        UDim2.new(0.25, 0, 0, MID_H),
        "上",
        13,
        false
    )

local PlusButton =
    CreateRegion(
        "Plus",
        UDim2.new(0.25, 0, 0, TOP_H),
        UDim2.new(0.25, 0, 0, MID_H),
        "加",
        13,
        false
    )

local BrandRegion, BrandLabel =
    CreateRegion(
        "Brand",
        UDim2.new(0.50, 0, 0, TOP_H),
        UDim2.new(0.50, 0, 0, MID_H),
        CONFIG.Brand,
        12,
        true
    )

BrandRegion.Active = true

local DownButton =
    CreateRegion(
        "Down",
        UDim2.new(0, 0, 0, TOP_H + MID_H),
        UDim2.new(0.25, 0, 0, BOT_H),
        "下",
        13,
        false
    )

local MinusButton =
    CreateRegion(
        "Minus",
        UDim2.new(0.25, 0, 0, TOP_H + MID_H),
        UDim2.new(0.25, 0, 0, BOT_H),
        "减",
        13,
        false
    )

local SpeedRegion, SpeedLabel =
    CreateRegion(
        "Speed",
        UDim2.new(0.50, 0, 0, TOP_H + MID_H),
        UDim2.new(0.25, 0, 0, BOT_H),
        tostring(State.SpeedLevel),
        15,
        true
    )

SpeedRegion.Active = false

local FlyButton, FlyLabel =
    CreateRegion(
        "Fly",
        UDim2.new(0.75, 0, 0, TOP_H + MID_H),
        UDim2.new(0.25, 0, 0, BOT_H),
        "飞",
        14,
        true
    )

local function Divider(pos, size)
    local line = Instance.new("Frame")
    line.Position = pos
    line.Size = size
    line.BackgroundColor3 = CONFIG.Divider
    line.BackgroundTransparency = 0.58
    line.BorderSizePixel = 0
    line.ZIndex = 15
    line.Parent = Panel
    return line
end

Divider(
    UDim2.new(0, 0, 0, TOP_H - 1),
    UDim2.new(1, 0, 0, 1)
)

Divider(
    UDim2.new(0, 0, 0, TOP_H + MID_H - 1),
    UDim2.new(1, 0, 0, 1)
)

Divider(
    UDim2.new(0.5, -1, 0, 0),
    UDim2.new(0, 1, 0, TOP_H)
)

Divider(
    UDim2.new(0.25, -1, 0, TOP_H),
    UDim2.new(0, 1, 1, -TOP_H)
)

Divider(
    UDim2.new(0.50, -1, 0, TOP_H),
    UDim2.new(0, 1, 1, -TOP_H)
)

Divider(
    UDim2.new(0.75, -1, 0, TOP_H + MID_H),
    UDim2.new(0, 1, 0, BOT_H)
)

local MiniButton = Instance.new("TextButton")
MiniButton.Name = "DB_FLIGHT_MINI"
MiniButton.AnchorPoint = Vector2.new(0, 0.5)
MiniButton.Position = UDim2.new(0, 18, 0.5, 0)
MiniButton.Size = UDim2.fromOffset(58, 34)
MiniButton.BackgroundColor3 = CONFIG.Glass
MiniButton.BackgroundTransparency = 0.46
MiniButton.BorderSizePixel = 0
MiniButton.AutoButtonColor = false
MiniButton.Text = "鱼"
MiniButton.TextSize = 20
MiniButton.Font = Enum.Font.GothamBlack
MiniButton.Visible = false
MiniButton.ZIndex = 50
MiniButton.Parent = ScreenGui

AddCorner(MiniButton, 15)

local MiniAura = Instance.new("UIStroke")
MiniAura.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MiniAura.Thickness = 4.5
MiniAura.Transparency = 0.76
MiniAura.Color = CONFIG.Cyan
MiniAura.LineJoinMode = Enum.LineJoinMode.Round
MiniAura.Parent = MiniButton

TweenService:Create(
    MiniAura,
    TweenInfo.new(
        0.75,
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut,
        -1,
        true
    ),
    {
        Thickness = 6.2,
        Transparency = 0.90,
        Color = CONFIG.Purple
    }
):Play()

AddOuterEnchant(MiniButton)
AddTextEnchant(MiniButton, true)

local IsFlightPanelDragging = false
local function MakeDraggable(handle, guiObject)
    local dragging = false
    local activeTouch = nil
    local dragStart = nil
    local startPosition = nil

    handle.Active = true
    handle.AutoButtonColor = false

    local function finishDrag()
        dragging = false
        IsFlightPanelDragging = false
        activeTouch = nil
        dragStart = nil
        startPosition = nil
        State.Vertical = 0
        pcall(function() handle.Modal = false end)
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        dragging = true
        IsFlightPanelDragging = true
        dragStart = input.Position
        startPosition = guiObject.Position
        if input.UserInputType == Enum.UserInputType.Touch then
            activeTouch = input
        end
        pcall(function() handle.Modal = true end)
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging or not dragStart or not startPosition then return end
        local valid = input.UserInputType == Enum.UserInputType.MouseMovement
            or (input.UserInputType == Enum.UserInputType.Touch and input == activeTouch)
        if not valid then return end
        local delta = input.Position - dragStart
        guiObject.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end)

    UserInputService.InputEnded:Connect(function(input)
        local endedMouse = input.UserInputType == Enum.UserInputType.MouseButton1
        local endedTouch = input.UserInputType == Enum.UserInputType.Touch and input == activeTouch
        if dragging and (endedMouse or endedTouch) then finishDrag() end
    end)
end

MakeDraggable(BrandRegion, Panel)

local MiniDragState = {
    Dragging = false,
    StartPointer = nil,
    StartPosition = nil,
    Moved = false,
    SuppressUntil = 0
}

MiniButton.InputBegan:Connect(function(input)
    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
    or input.UserInputType ==
        Enum.UserInputType.Touch then

        MiniDragState.Dragging = true
        MiniDragState.StartPointer =
            input.Position

        MiniDragState.StartPosition =
            MiniButton.Position

        MiniDragState.Moved = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not MiniDragState.Dragging
    or not MiniDragState.StartPointer
    or not MiniDragState.StartPosition then
        return
    end

    if input.UserInputType ==
        Enum.UserInputType.MouseMovement
    or input.UserInputType ==
        Enum.UserInputType.Touch then

        local delta =
            input.Position
            - MiniDragState.StartPointer

        if delta.Magnitude >= 7 then
            MiniDragState.Moved = true
        end

        MiniButton.Position =
            UDim2.new(
                MiniDragState.StartPosition.X.Scale,
                MiniDragState.StartPosition.X.Offset
                    + delta.X,
                MiniDragState.StartPosition.Y.Scale,
                MiniDragState.StartPosition.Y.Offset
                    + delta.Y
            )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
    or input.UserInputType ==
        Enum.UserInputType.Touch then

        if MiniDragState.Dragging
        and MiniDragState.Moved then
            MiniDragState.SuppressUntil =
                os.clock()
                + 0.28
        end

        MiniDragState.Dragging = false
        MiniDragState.StartPointer = nil
        MiniDragState.StartPosition = nil
    end
end)

local function StopCharacterAnimations()
    local character = State.Character
    local humanoid = State.Humanoid

    if not character
    or not humanoid then
        return
    end

    local animate = character:FindFirstChild("Animate")
    if animate
    and animate:IsA("LocalScript") then
        State.OldAnimateDisabled = animate.Disabled
        animate.Disabled = true
    end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in ipairs(
            animator:GetPlayingAnimationTracks()
        ) do
            pcall(function()
                track:Stop(0)
            end)
        end
    end
end

local function RestoreCharacterAnimations()
    local character = State.Character

    if not character then
        return
    end

    local animate = character:FindFirstChild("Animate")
    if animate
    and animate:IsA("LocalScript")
    and State.OldAnimateDisabled ~= nil then
        animate.Disabled = State.OldAnimateDisabled
    end
end

local function SetFlightCharacterPhysics(enabled)
    if not State.Character then return end
    if enabled then
        State.PartPhysics = {}
        for _, obj in ipairs(State.Character:GetDescendants()) do
            if obj:IsA("BasePart") then
                State.PartPhysics[obj] = {CanCollide = obj.CanCollide, Massless = obj.Massless}
                pcall(function()
                    obj.CanCollide = false
                    if obj ~= State.Root then obj.Massless = true end
                end)
            end
        end
    else
        for obj, old in pairs(State.PartPhysics or {}) do
            if obj and obj.Parent then
                pcall(function()
                    obj.CanCollide = old.CanCollide
                    obj.Massless = old.Massless
                end)
            end
        end
        State.PartPhysics = {}
    end
end

local function DestroyFlightObjects()
    if State.Velocity then
        State.Velocity:Destroy()
        State.Velocity = nil
    end

    if State.Orientation then
        State.Orientation:Destroy()
        State.Orientation = nil
    end

    if State.Attachment then
        State.Attachment:Destroy()
        State.Attachment = nil
    end
end

local function StopFlying()
    State.Flying = false
    State.Vertical = 0

    DestroyFlightObjects()
    SetFlightCharacterPhysics(false)

    if State.Humanoid then
        if State.OldAutoRotate ~= nil then
            State.Humanoid.AutoRotate = State.OldAutoRotate
        end

        if State.OldPlatformStand ~= nil then
            State.Humanoid.PlatformStand = State.OldPlatformStand
        end

        pcall(function()
            State.Humanoid:ChangeState(
                Enum.HumanoidStateType.GettingUp
            )
        end)
    end

    if State.Humanoid and State.OldStateEnabled then
        for stateType, enabled in pairs(State.OldStateEnabled) do
            pcall(function() State.Humanoid:SetStateEnabled(stateType, enabled) end)
        end
    end
    State.OldStateEnabled = {}
    State.CurrentVelocity = Vector3.zero
    if State.Root then
        pcall(function()
            State.Root.AssemblyLinearVelocity = Vector3.zero
            State.Root.AssemblyAngularVelocity = Vector3.zero
        end)
    end

    RestoreCharacterAnimations()

    FlyLabel.Text = "飞"
end

local function StartFlying()
    if not State.Root
    or not State.Humanoid then
        return
    end

    DestroyFlightObjects()

    State.OldAutoRotate = State.Humanoid.AutoRotate
    State.OldPlatformStand = State.Humanoid.PlatformStand

    State.BaseFlightSpeed =
        math.max(
            1,
            State.Humanoid.WalkSpeed
            * 2
        )

    State.Humanoid.AutoRotate = false
    State.Humanoid.PlatformStand = false
    State.CurrentVelocity = Vector3.zero
    SetFlightCharacterPhysics(true)
    pcall(function() State.Humanoid:ChangeState(Enum.HumanoidStateType.Flying) end)
    State.OldStateEnabled = {}
    for _, stateType in ipairs({
        Enum.HumanoidStateType.FallingDown,
        Enum.HumanoidStateType.Ragdoll
    }) do
        pcall(function()
            State.OldStateEnabled[stateType] = State.Humanoid:GetStateEnabled(stateType)
            State.Humanoid:SetStateEnabled(stateType, false)
        end)
    end

    StopCharacterAnimations()
    pcall(function()
        State.Root.AssemblyLinearVelocity = Vector3.zero
        State.Root.AssemblyAngularVelocity = Vector3.zero
    end)

    local attachment = Instance.new("Attachment")
    attachment.Name = "DB_FLIGHT_ATTACHMENT"
    attachment.Parent = State.Root

    local velocity = Instance.new("LinearVelocity")
    velocity.Name = "DB_FLIGHT_VELOCITY"
    velocity.Attachment0 = attachment
    velocity.RelativeTo = Enum.ActuatorRelativeTo.World
    velocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    velocity.MaxForce = 1000000
    velocity.VectorVelocity = Vector3.zero
    velocity.Parent = State.Root

    local orientation = Instance.new("AlignOrientation")
    orientation.Name = "DB_FLIGHT_ORIENTATION"
    orientation.Attachment0 = attachment
    orientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    orientation.RigidityEnabled = false
    orientation.Responsiveness = 38
    orientation.MaxTorque = 1000000
    orientation.Parent = State.Root

    State.Attachment = attachment
    State.Velocity = velocity
    State.Orientation = orientation

    State.Flying = true
    FlyLabel.Text = "停"
end

local function ToggleFlying()
    if State.Flying then
        StopFlying()
    else
        StartFlying()
    end
end

local function GetControlMoveVector()
    if IsFlightPanelDragging then
        return Vector3.zero
    end

    if Controls
    and type(Controls.GetMoveVector) == "function" then
        local ok, move =
            pcall(function()
                return Controls:GetMoveVector()
            end)

        if ok
        and typeof(move) == "Vector3" then
            return move
        end
    end

    if State.Humanoid then
        local worldMove =
            State.Humanoid.MoveDirection

        return Vector3.new(
            worldMove.X,
            0,
            -worldMove.Z
        )
    end

    return Vector3.zero
end

RunService.RenderStepped:Connect(function(dt)
    if not State.Flying then
        return
    end

    if not State.Root
    or not State.Humanoid
    or not State.Velocity
    or not State.Orientation then
        StopFlying()
        return
    end

    local camera =
        workspace.CurrentCamera

    if not camera then
        return
    end

    local speed =
        State.SpeedLevel
        * State.BaseFlightSpeed

    local input =
        GetControlMoveVector()

    local cameraRight =
        camera.CFrame.RightVector

    local cameraLook =
        camera.CFrame.LookVector

    local flightDirection =
        cameraRight * input.X
        + cameraLook * (-input.Z)

    if flightDirection.Magnitude > 1 then
        flightDirection =
            flightDirection.Unit
    end

    local manualVertical =
        Vector3.new(
            0,
            State.Vertical * speed,
            0
        )

    local moveVelocity =
        flightDirection
        * speed

    local targetVelocity = moveVelocity + manualVertical

    if targetVelocity.Magnitude > 1 then
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {State.Character}
        params.IgnoreWater = true
        local frameDt = math.clamp(dt or 1/60, 1/240, 0.10)
        local lookAhead = math.clamp(targetVelocity.Magnitude * frameDt * 2.8 + 4.0, 5, 52)
        local result = nil
        local okCast = pcall(function()
            result = workspace:Blockcast(
                State.Root.CFrame,
                Vector3.new(4.2, 5.8, 4.2),
                targetVelocity.Unit * lookAhead,
                params
            )
        end)
        if not okCast then
            result = workspace:Raycast(State.Root.Position, targetVelocity.Unit * lookAhead, params)
        end
        if result and result.Instance and result.Instance.CanCollide then
            local intoSurface = targetVelocity:Dot(result.Normal)
            if intoSurface < 0 then
                targetVelocity = targetVelocity - result.Normal * intoSurface
            end
            local distance = (result.Position - State.Root.Position).Magnitude
            if distance < 4.5 then targetVelocity = targetVelocity * math.clamp(distance / 4.5, 0.08, 1) end
        end
    end

    local alpha = 1 - math.exp(-12 * math.clamp(dt or 1/60, 1/240, 0.10))
    State.CurrentVelocity = State.CurrentVelocity:Lerp(targetVelocity, alpha)
    if targetVelocity.Magnitude < 0.05 and State.CurrentVelocity.Magnitude < 0.5 then
        State.CurrentVelocity = Vector3.zero
    end
    State.Velocity.VectorVelocity = State.CurrentVelocity

    State.Orientation.CFrame =
        camera.CFrame.Rotation

    State.Root.AssemblyAngularVelocity =
        Vector3.zero
end)

local function BindHold(button, value)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            State.Vertical = value
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if State.Vertical == value then
                State.Vertical = 0
            end
        end
    end)
end

BindHold(UpButton, 1)
BindHold(DownButton, -1)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.Space then
        State.Vertical = 1
    elseif input.KeyCode == Enum.KeyCode.LeftControl
    or input.KeyCode == Enum.KeyCode.C then
        State.Vertical = -1
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        if State.Vertical == 1 then
            State.Vertical = 0
        end
    elseif input.KeyCode == Enum.KeyCode.LeftControl
    or input.KeyCode == Enum.KeyCode.C then
        if State.Vertical == -1 then
            State.Vertical = 0
        end
    end
end)

local function RefreshSpeed()
    SpeedLabel.Text = tostring(State.SpeedLevel)
end

PlusButton.Activated:Connect(function()
    State.SpeedLevel =
        State.SpeedLevel
        + 1

    RefreshSpeed()
end)

MinusButton.Activated:Connect(function()
    State.SpeedLevel =
        math.max(
            CONFIG.MinSpeedLevel,
            State.SpeedLevel - 1
        )

    RefreshSpeed()
end)

FlyButton.Activated:Connect(ToggleFlying)

MinButton.Activated:Connect(function()
    Panel.Visible = false
    MiniButton.Visible = true
end)

MiniButton.Activated:Connect(function()
    if MiniDragState.Moved
    or os.clock()
        < MiniDragState.SuppressUntil then
        MiniDragState.Moved = false
        return
    end

    MiniButton.Visible = false
    Panel.Visible = true
end)

CloseButton.Activated:Connect(function()
    StopFlying()
    ScreenGui:Destroy()
end)

RefreshSpeed()

print("✅ 大肥鱼飞行 V4 无限速度 / 1档双倍走速 / 拖动不误触版已加载")
]====]
},
{
Name = "自瞄",
Page = "Aimbot"
},
{
Name = "透视",
Page = "ESP"
}
},
["通用"] = {
{Name = "飞行", Code = [[loadstring(game:HttpGet("https://pastefy.app/tkHc58Wt/raw"))()]]},
{Name = "子追", Code = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/HB-ksdb/-4/main/%E5%AD%90%E8%BF%BD%E8%84%9A%E6%9C%AC%E7%A9%BF%E5%A2%99.lua"))()]]},
{Name = "自瞄", Code = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/gycgchgyfytdttr/QQ-9-2-8-9-50173/refs/heads/main/cure.lua"))()]]},
{Name = "XK Hub(支持服务器进群)", Url = "https://github.com/devslopo/DVES/raw/main/XK%20Hub"},
{Name = "翻译脚本", Code = [[TX = "TX Script"; Script = "全自动翻译"; loadstring(game:HttpGet("https://raw.githubusercontent.com/JsYb666/Item/refs/heads/main/Auto-language"))()]]},
{Name = "霖溺支持服务器详情进主页群", Url = "https://raw.githubusercontent.com/ShenJiaoBen/ScriptLoader/refs/heads/main/Linni_FreeLoader.lua"},
{Name = "恐脚本支持服务器进主页群", Url = "https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/恐脚本.NB"},
{Name = "BS脚本", Code = [[local BS = "https://gitee.com/BS_script/script/raw/master/BS_Script.Luau"; loadstring(game:HttpGet(BS))()]]},
{Name = "动画脚本", Url = "https://rawscripts.net/raw/Universal-Script-FREE-BUNDLES-l-FE-241758"},
{Name = "皮脚本", Url = "https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua"},
{Name = "TrashHub", Code = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/OnlyJumpToOther/main/loader.lua"))()]]},
{Name = "隐身", Code = [[loadstring(game:HttpGet('https://pastefy.app/6zjosppv/raw'))()]]},
{Name = "霖溺通用", Code = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/ShenJiaoBen/Partial-Server-Ribbon/refs/heads/main/Linni_Universal.txt"))()]]}
},
["射击游戏"] = {
{Name = "特种部队模拟器", Url = "https://rawscripts.net/raw/Tactical:-Swat-Simulator-Six-Hub-215287"},
{Name = "刀战竞技场", Url = "https://rawscripts.net/raw/FPSKnife-Arena-Script-Auto-Kill-And-Speed-And-More-No-Key-102295"},
{Name = "狙击竞技场", Url = "https://rawscripts.net/raw/GAMEMODE-Sniper-Arena-Script-ESP-Aimbot-Auto-Fire-Keyless-206741"},
{Name = "战斗竞技场", Url = "https://pastebin.com/raw/bJvbP48n"},
{Name = "刀对决", Url = "https://raw.githubusercontent.com/imshrak/knifeduels/main/menu"},
{Name = "手枪竞技场", Url = "https://rawscripts.net/raw/Pistol-Arena-Vodka-hub-keyless-op-201209"},
{Name = "监狱人生(不好用可以用XK)", Code = [[loadstring(game:HttpGet("https://rawscripts.net/raw/Prison-Life-auto-arrest-inf-jump-teleport-and-etc-242404"))()]]},
{Name = "莱克星顿和康科德(LC)", Code = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/Matds78/Script/refs/heads/main/LC"))()]]},
{Name = "杀手VS警长", Code = [[loadstring(game:HttpGet("https://rawscripts.net/raw/DUELS-Murderers-VS-Sheriffs-BEST-SCRIPT-SILENT-AIM-AIMBOT-ESP-RAGEBOT-AND-ALOT-MORE-227237"))()]]},
{Name = "凶手VS警长决斗", Code = [[loadstring(game:HttpGet("https://rawscripts.net/raw/Murderers-VS-Sheriffs-DUELS-mvsd-script-open-source-many-features-undetected-244205"))()]]}
},
["角色扮演RPG"] = {
        {Name = "ohio-天休缝合", Code = [====[

  DB 风格内置 UI 库（Fluent 兼容层）
  供缝合版脚本使用：提供 Fluent:CreateWindow / AddTab / AddToggle / AddButton /
  AddSlider / AddInput / AddDropdown / AddParagraph / AddSection / Notify / Dialog /
  GiveSignal / Options 系统，以及 ESP 库兼容（Add / Clear / ESPFolder）。
  完全不依赖外部 URL。
]]
local _DBUI = {}
local _DBOptions = {}
_DBUI.Options = _DBOptions

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local function AddCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
    return c
end

local function AddBorder(obj, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = thickness or 0.85
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = transparency or 0.52
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = obj
    return stroke
end

local function StyleButton(btn, radius)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.85
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    AddCorner(btn, radius or 8)
    AddBorder(btn, 0.8, 0.55)
end

local function Notify(opts)
    pcall(function()
        local pg = lp:FindFirstChildOfClass("PlayerGui")
        if not pg then return end
        local old = pg:FindFirstChild("DB_Notify")
        if old then old:Destroy() end
        local frame = Instance.new("Frame")
        frame.Name = "DB_Notify"
        frame.AnchorPoint = Vector2.new(1, 1)
        frame.Position = UDim2.new(1, -16, 1, -16)
        frame.Size = UDim2.fromOffset(300, 58)
        frame.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
        frame.BackgroundTransparency = 0.2
        frame.BorderSizePixel = 0
        frame.ZIndex = 5000
        frame.Parent = pg
        AddCorner(frame, 12)
        AddBorder(frame, 1, 0.35)
        local t1 = Instance.new("TextLabel")
        t1.Size = UDim2.new(1, -20, 0, 18)
        t1.Position = UDim2.fromOffset(10, 5)
        t1.BackgroundTransparency = 1
        t1.Text = opts.Title or "提示"
        t1.TextColor3 = Color3.fromRGB(255, 255, 255)
        t1.TextSize = 12
        t1.Font = Enum.Font.GothamBlack
        t1.TextXAlignment = Enum.TextXAlignment.Left
        t1.Parent = frame
        local t2 = Instance.new("TextLabel")
        t2.Size = UDim2.new(1, -20, 0, 26)
        t2.Position = UDim2.fromOffset(10, 25)
        t2.BackgroundTransparency = 1
        t2.Text = opts.Content or ""
        t2.TextColor3 = Color3.fromRGB(200, 210, 230)
        t2.TextSize = 10
        t2.Font = Enum.Font.GothamMedium
        t2.TextWrapped = true
        t2.TextXAlignment = Enum.TextXAlignment.Left
        t2.Parent = frame
        task.delay(4, function()
            if frame and frame.Parent then
                TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
                task.delay(0.35, function()
                    if frame and frame.Parent then frame:Destroy() end
                end)
            end
        end)
    end)
end

local function CreateWindow(opts)
    local Window = {}
    Window._tabs = {}
    Window._tabButtons = {}
    Window._currentIndex = 1

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DB_OhioHub"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 999
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local pg = lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui", 10)
    if not pg then
        warn("[大肥鱼UI] PlayerGui 不可用")
        return Window
    end
    ScreenGui.Parent = pg

    local Panel = Instance.new("Frame")
    Panel.AnchorPoint = Vector2.new(0.5, 0.5)
    Panel.Position = UDim2.fromScale(0.5, 0.5)
    Panel.Size = opts.Size or UDim2.fromOffset(640, 440)
    Panel.BackgroundColor3 = Color3.fromRGB(7, 9, 13)
    Panel.BackgroundTransparency = 0.08
    Panel.BorderSizePixel = 0
    Panel.Active = true
    Panel.Parent = ScreenGui
    AddCorner(Panel, 14)
    AddBorder(Panel, 1.2, 0.3)

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 34)
    Header.BackgroundTransparency = 1
    Header.Active = true
    Header.Parent = Panel

    local Title = Instance.new("TextLabel")
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.fromOffset(12, 4)
    Title.Size = UDim2.new(0, 300, 0, 24)
    Title.Text = opts.Title or "综合脚本"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 15
    Title.Font = Enum.Font.GothamBlack
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local Sub = Instance.new("TextLabel")
    Sub.BackgroundTransparency = 1
    Sub.Position = UDim2.fromOffset(320, 9)
    Sub.Size = UDim2.new(0, 220, 0, 14)
    Sub.Text = opts.SubTitle or ""
    Sub.TextColor3 = Color3.fromRGB(180, 190, 210)
    Sub.TextSize = 9
    Sub.Font = Enum.Font.GothamMedium
    Sub.TextXAlignment = Enum.TextXAlignment.Left
    Sub.Parent = Header

    local MiniBtn = Instance.new("TextButton")
    MiniBtn.Position = UDim2.new(1, -58, 0, 4)
    MiniBtn.Size = UDim2.fromOffset(24, 24)
    MiniBtn.BackgroundTransparency = 1
    MiniBtn.BorderSizePixel = 0
    MiniBtn.Text = "−"
    MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MiniBtn.TextSize = 18
    MiniBtn.Font = Enum.Font.GothamBold
    MiniBtn.AutoButtonColor = false
    MiniBtn.Parent = Header

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Position = UDim2.new(1, -30, 0, 4)
    CloseBtn.Size = UDim2.fromOffset(24, 24)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = Header

    local drag = { active = false, start = nil, pos = nil, touch = nil }
    local function StartDrag(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        drag.active = true
        drag.start = input.Position
        drag.pos = Panel.Position
        if input.UserInputType == Enum.UserInputType.Touch then drag.touch = input end
    end
    Header.InputBegan:Connect(StartDrag)
    Panel.InputBegan:Connect(StartDrag)
    UserInputService.InputChanged:Connect(function(input)
        if not drag.active then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement then
        elseif input.UserInputType == Enum.UserInputType.Touch and input == drag.touch then
        else
            return
        end
        Panel.Position = UDim2.new(
            drag.pos.X.Scale, drag.pos.X.Offset + (input.Position.X - drag.start.X),
            drag.pos.Y.Scale, drag.pos.Y.Offset + (input.Position.Y - drag.start.Y)
        )
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        drag.active = false
        drag.touch = nil
    end)

    local FloatBtn = Instance.new("TextButton")
    FloatBtn.Name = "DB_Float"
    FloatBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    FloatBtn.Position = UDim2.new(1, -80, 0.5, 0)
    FloatBtn.Size = UDim2.fromOffset(66, 34)
    FloatBtn.BackgroundColor3 = Color3.fromRGB(6, 9, 13)
    FloatBtn.BackgroundTransparency = 0.12
    FloatBtn.BorderSizePixel = 0
    FloatBtn.Text = opts.Title or "菜单"
    FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    FloatBtn.TextSize = 12
    FloatBtn.Font = Enum.Font.GothamBlack
    FloatBtn.Visible = false
    FloatBtn.Parent = ScreenGui
    StyleButton(FloatBtn, 999)
    FloatBtn.Activated:Connect(function()
        FloatBtn.Visible = false
        Panel.Visible = true
    end)
    MiniBtn.Activated:Connect(function()
        Panel.Visible = false
        FloatBtn.Visible = true
    end)
    CloseBtn.Activated:Connect(function()
        ScreenGui:Destroy()
    end)

    local TAB_W = 110
    local NavRail = Instance.new("Frame")
    NavRail.Position = UDim2.fromOffset(0, 40)
    NavRail.Size = UDim2.new(0, TAB_W, 1, -46)
    NavRail.BackgroundTransparency = 1
    NavRail.Parent = Panel

    local ContentHost = Instance.new("Frame")
    ContentHost.Position = UDim2.new(0, TAB_W + 2, 0, 40)
    ContentHost.Size = UDim2.new(1, -(TAB_W + 4), 1, -46)
    ContentHost.BackgroundTransparency = 1
    ContentHost.ClipsDescendants = true
    ContentHost.Parent = Panel

    local NavScroll = Instance.new("ScrollingFrame")
    NavScroll.Size = UDim2.new(1, 0, 1, 0)
    NavScroll.BackgroundTransparency = 1
    NavScroll.BorderSizePixel = 0
    NavScroll.ScrollBarThickness = 0
    NavScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    NavScroll.CanvasSize = UDim2.new()
    NavScroll.Parent = NavRail
    local NavLayout = Instance.new("UIListLayout")
    NavLayout.Padding = UDim.new(0, 4)
    NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NavLayout.Parent = NavScroll
    local NavPad = Instance.new("UIPadding")
    NavPad.PaddingLeft = UDim.new(0, 4)
    NavPad.PaddingRight = UDim.new(0, 4)
    NavPad.Parent = NavScroll

    local function SelectTab(indexOrSelf, maybeIndex)
        local index = indexOrSelf
        if type(indexOrSelf) == "table" then
            index = maybeIndex
        end
        Window._currentIndex = index
        for i, tab in ipairs(Window._tabs) do
            tab._frame.Visible = (i == index)
            local btn = Window._tabButtons[i]
            if btn then
                if i == index then
                    btn.BackgroundTransparency = 0.5
                    btn.TextColor3 = Color3.fromRGB(160, 215, 255)
                else
                    btn.BackgroundTransparency = 0.86
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
            end
        end
    end

    Window.SelectTab = SelectTab

    function Window:AddTab(opts)
        local tab = {}
        tab._frame = Instance.new("ScrollingFrame")
        tab._frame.Size = UDim2.new(1, -6, 1, -4)
        tab._frame.Position = UDim2.fromOffset(3, 2)
        tab._frame.BackgroundTransparency = 1
        tab._frame.BorderSizePixel = 0
        tab._frame.ScrollBarThickness = 3
        tab._frame.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 210)
        tab._frame.ScrollBarImageTransparency = 0.5
        tab._frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tab._frame.CanvasSize = UDim2.new()
        tab._frame.Parent = ContentHost
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = tab._frame
        local pad = Instance.new("UIPadding")
        pad.PaddingBottom = UDim.new(0, 8)
        pad.Parent = tab._frame

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -8, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundTransparency = 0.86
        btn.BorderSizePixel = 0
        btn.Text = opts.Title
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.TextTruncate = Enum.TextTruncate.AtEnd
        btn.AutoButtonColor = false
        local btnIndex = #Window._tabs + 1
        btn.LayoutOrder = btnIndex
        btn.Parent = NavScroll
        StyleButton(btn, 8)
        btn.Activated:Connect(function()
            SelectTab(btnIndex)
        end)

local function MakeRow(parent, height)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -8, 0, height)
        row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        row.BackgroundTransparency = 0.9
        row.BorderSizePixel = 0
        row.Parent = parent
        AddCorner(row, 8)
        AddBorder(row, 0.7, 0.62)
        return row
    end

    local function MakeLabel(row, text, size, pos, width)
        local lab = Instance.new("TextLabel")
        lab.Size = UDim2.new(0, width or 120, 0, size or 20)
        lab.Position = UDim2.fromOffset(pos or 10, 6)
        lab.BackgroundTransparency = 1
        lab.Text = text
        lab.TextColor3 = Color3.fromRGB(255, 255, 255)
        lab.TextSize = 11
        lab.Font = Enum.Font.GothamBold
        lab.TextXAlignment = Enum.TextXAlignment.Left
        lab.TextTruncate = Enum.TextTruncate.AtEnd
        lab.Parent = row
        return lab
    end

    function tab:AddToggle(key, opts)
        local row = MakeRow(tab._frame, 34)
        local lab = MakeLabel(row, opts.Title, 20)
        local opt = _DBOptions[key]
        if not opt then
            opt = { Value = opts.Default or false }
            _DBOptions[key] = opt
        end
        local enabled = opt.Value
        local switch = Instance.new("TextButton")
        switch.AnchorPoint = Vector2.new(1, 0.5)
        switch.Position = UDim2.new(1, -10, 0.5, 0)
        switch.Size = UDim2.fromOffset(46, 22)
        switch.BackgroundColor3 = enabled and Color3.fromRGB(190, 200, 215) or Color3.fromRGB(60, 64, 72)
        switch.BackgroundTransparency = 0.1
        switch.BorderSizePixel = 0
        switch.Text = ""
        switch.AutoButtonColor = false
        switch.Parent = row
        AddCorner(switch, 999)
        local knob = Instance.new("Frame")
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = enabled and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0)
        knob.Size = UDim2.fromOffset(17, 17)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BackgroundTransparency = 0
        knob.BorderSizePixel = 0
        knob.Parent = switch
        AddCorner(knob, 999)
        local function SetState(v)
            enabled = v
            opt.Value = v
            TweenService:Create(knob, TweenInfo.new(0.15), {
                Position = enabled and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0)
            }):Play()
            TweenService:Create(switch, TweenInfo.new(0.15), {
                BackgroundColor3 = enabled and Color3.fromRGB(190, 200, 215) or Color3.fromRGB(60, 64, 72)
            }):Play()
        end
        switch.Activated:Connect(function()
            SetState(not enabled)
            if opts.Callback then pcall(opts.Callback, opt.Value) end
        end)
        function opt:SetValue(v)
            SetState(v and true or false)
            if opts.Callback then pcall(opts.Callback, opt.Value) end
        end
        function opt:SetTitle(text)
            lab.Text = text
        end
        return opt
    end

    function tab:AddButton(opts)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -8, 0, 34)
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundTransparency = 0.87
        btn.BorderSizePixel = 0
        btn.Text = opts.Title
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBlack
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.TextTruncate = Enum.TextTruncate.AtEnd
        btn.AutoButtonColor = false
        btn.Parent = tab._frame
        StyleButton(btn, 8)
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 12)
        pad.PaddingRight = UDim.new(0, 12)
        pad.Parent = btn
        btn.Activated:Connect(function()
            if opts.Callback then pcall(opts.Callback) end
        end)
        return btn
    end

    function tab:AddSlider(key, opts)
        local row = MakeRow(tab._frame, 56)
        local label = MakeLabel(row, opts.Title .. "：" .. tostring(opts.Default or 0), 18, 8)
        local opt = _DBOptions[key]
        if not opt then
            opt = { Value = opts.Default or 0, IsMoved = false }
            _DBOptions[key] = opt
        end
        local min = opts.Min or 0
        local max = opts.Max or 100
        local rounding = opts.Rounding or 1
        local track = Instance.new("Frame")
        track.Position = UDim2.new(0, 12, 0, 34)
        track.Size = UDim2.new(1, -24, 0, 5)
        track.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        track.BackgroundTransparency = 0.78
        track.BorderSizePixel = 0
        track.Active = true
        track.Parent = row
        AddCorner(track, 999)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(140, 200, 255)
        fill.BackgroundTransparency = 0.05
        fill.BorderSizePixel = 0
        fill.Parent = track
        AddCorner(fill, 999)
        local knob = Instance.new("Frame")
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(0, 0, 0.5, 0)
        knob.Size = UDim2.fromOffset(14, 14)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BackgroundTransparency = 0
        knob.BorderSizePixel = 0
        knob.Parent = track
        AddCorner(knob, 999)
        local dragging = false
        local dragInput = nil
        local function ApplyRatio(ratio, fire)
            ratio = math.clamp(ratio, 0, 1)
            local snapped = math.clamp(math.floor((min + (max - min) * ratio) / rounding + 0.5) * rounding, min, max)
            local r2 = (snapped - min) / math.max(0.0001, (max - min))
            fill.Size = UDim2.new(r2, 0, 1, 0)
            knob.Position = UDim2.new(r2, 0, 0.5, 0)
            label.Text = opts.Title .. "：" .. tostring(snapped)
            opt.Value = snapped
            if fire then
                opt.IsMoved = true
                if opts.Callback then pcall(opts.Callback, snapped) end
            end
        end
        local function ApplyFromX(x)
            if not track.Parent then return end
            local width = math.max(1, track.AbsoluteSize.X)
            ApplyRatio((x - track.AbsolutePosition.X) / width, true)
        end
        ApplyRatio((opt.Value - min) / math.max(0.0001, (max - min)), false)
        track.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            dragging = true
            dragInput = input
            ApplyFromX(input.Position.X)
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not dragging or not track.Parent then return end
            if input.UserInputType == Enum.UserInputType.Touch then
                if input ~= dragInput then return end
            elseif input.UserInputType ~= Enum.UserInputType.MouseMovement then
                return
            end
            ApplyFromX(input.Position.X)
        end)
        UserInputService.InputEnded:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.Touch then
                if input ~= dragInput then return end
            elseif input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                return
            end
            dragging = false
            dragInput = nil
        end)
        function opt:SetValue(v)
            ApplyRatio((v - min) / math.max(0.0001, (max - min)), true)
        end
        return opt
    end

    function tab:AddInput(key, opts)
        local row = MakeRow(tab._frame, 38)
        local lab = MakeLabel(row, opts.Title, 20, 8, 150)
        local box = Instance.new("TextBox")
        box.AnchorPoint = Vector2.new(1, 0.5)
        box.Position = UDim2.new(1, -10, 0.5, 0)
        box.Size = UDim2.new(0, 150, 0, 26)
        box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        box.BackgroundTransparency = 0.88
        box.BorderSizePixel = 0
        box.Text = opts.Default or ""
        box.PlaceholderText = ""
        box.TextColor3 = Color3.fromRGB(255, 255, 255)
        box.TextSize = 11
        box.Font = Enum.Font.GothamMedium
        box.Parent = row
        AddCorner(box, 6)
        local opt = _DBOptions[key]
        if not opt then
            opt = { Value = opts.Default or "" }
            _DBOptions[key] = opt
        end
        box.FocusLost:Connect(function(enter)
            local text = box.Text
            if opts.Numeric then
                text = tostring(text):gsub("[^%d%.%-]", "")
                box.Text = text
            end
            opt.Value = text
            if opts.Callback then pcall(opts.Callback, text) end
        end)
        function opt:SetValue(v)
            box.Text = tostring(v)
            opt.Value = tostring(v)
        end
        function opt:SetTitle(text)
            lab.Text = text
        end
        return opt
    end

    function tab:AddDropdown(key, opts)
        local row = MakeRow(tab._frame, 36)
        MakeLabel(row, opts.Title, 20, 8, 140)
        local values = opts.Values or {}
        local multi = opts.Multi or false
        local opt = _DBOptions[key]
        if not opt then
            if multi then
                opt = { Value = {} }
            else
                local def = opts.Default
                if type(def) == "number" then
                    def = values[def]
                end
                opt = { Value = def or "" }
            end
            _DBOptions[key] = opt
        end
        local current = Instance.new("TextLabel")
        current.AnchorPoint = Vector2.new(1, 0.5)
        current.Position = UDim2.new(1, -10, 0.5, 0)
        current.Size = UDim2.new(0, 150, 0, 24)
        current.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        current.BackgroundTransparency = 0.88
        current.BorderSizePixel = 0
        current.Text = multi and "点击选择" or (tostring(opt.Value) ~= "" and tostring(opt.Value) or "未选择")
        current.TextColor3 = Color3.fromRGB(255, 255, 255)
        current.TextSize = 10
        current.Font = Enum.Font.GothamMedium
        current.TextTruncate = Enum.TextTruncate.AtEnd
        current.Parent = row
        AddCorner(current, 6)
        local function RefreshText()
            if multi then
                local parts = {}
                for k, v in pairs(opt.Value) do
                    if v then table.insert(parts, k) end
                end
                current.Text = #parts > 0 and table.concat(parts, "、") or "未选择"
            else
                current.Text = tostring(opt.Value) ~= "" and tostring(opt.Value) or "未选择"
            end
        end
        local popup = Instance.new("Frame")
        popup.AnchorPoint = Vector2.new(1, 0)
        popup.Position = UDim2.new(1, -10, 1, 2)
        popup.Size = UDim2.new(0, 170, 0, 0)
        popup.BackgroundColor3 = Color3.fromRGB(16, 19, 24)
        popup.BackgroundTransparency = 0.05
        popup.BorderSizePixel = 0
        popup.Visible = false
        popup.ZIndex = 60
        popup.Parent = row
        AddCorner(popup, 8)
        AddBorder(popup, 0.8, 0.3)
        local popScroll = Instance.new("ScrollingFrame")
        popScroll.Size = UDim2.new(1, -4, 1, -4)
        popScroll.Position = UDim2.fromOffset(2, 2)
        popScroll.BackgroundTransparency = 1
        popScroll.BorderSizePixel = 0
        popScroll.ScrollBarThickness = 0
        popScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        popScroll.CanvasSize = UDim2.new()
        popScroll.Parent = popup
        local popLayout = Instance.new("UIListLayout")
        popLayout.Padding = UDim.new(0, 2)
        popLayout.Parent = popScroll
        local function Populate()
            for _, child in ipairs(popScroll:GetChildren()) do
                if child:IsA("GuiObject") and child ~= popLayout then child:Destroy() end
            end
            local h = 0
            for _, val in ipairs(values) do
                local item = Instance.new("TextButton")
                item.Size = UDim2.new(1, -4, 0, 24)
                item.BackgroundTransparency = 0.9
                item.BorderSizePixel = 0
                item.Text = tostring(val)
                item.TextColor3 = Color3.fromRGB(255, 255, 255)
                item.TextSize = 10
                item.Font = Enum.Font.GothamMedium
                item.TextXAlignment = Enum.TextXAlignment.Left
                item.AutoButtonColor = false
                item.Parent = popScroll
                local ipad = Instance.new("UIPadding")
                ipad.PaddingLeft = UDim.new(0, 8)
                ipad.Parent = item
                AddCorner(item, 5)
                item.Activated:Connect(function()
                    if multi then
                        if opt.Value[val] then
                            opt.Value[val] = nil
                        else
                            opt.Value[val] = true
                        end
                        RefreshText()
                        if opts.Callback then pcall(opts.Callback, opt.Value) end
                    else
                        opt.Value = val
                        RefreshText()
                        popup.Visible = false
                        if opts.Callback then pcall(opts.Callback, val) end
                    end
                end)
                h = h + 26
            end
            popup.Size = UDim2.new(0, 170, 0, math.min(h + 4, 220))
        end
        current.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            Populate()
            popup.Visible = not popup.Visible
        end)
        UserInputService.InputBegan:Connect(function(input, gpe)
            if popup.Visible and not gpe then
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local pos = UserInputService:GetMouseLocation()
                    local abs = popup.AbsolutePosition
                    local size = popup.AbsoluteSize
                    if pos.X < abs.X or pos.X > abs.X + size.X or pos.Y < abs.Y or pos.Y > abs.Y + size.Y then
                        popup.Visible = false
                    end
                end
            end
        end)
        function opt:SetValue(v)
            if multi then
                opt.Value = v or {}
            else
                opt.Value = v
            end
            RefreshText()
        end
        return opt
    end

    function tab:AddParagraph(opts)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -8, 0, 0)
        frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        frame.BackgroundTransparency = 0.92
        frame.BorderSizePixel = 0
        frame.Parent = tab._frame
        AddCorner(frame, 8)
        AddBorder(frame, 0.7, 0.62)
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -16, 0, 18)
        title.Position = UDim2.fromOffset(8, 6)
        title.BackgroundTransparency = 1
        title.Text = opts.Title or ""
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 11
        title.Font = Enum.Font.GothamBlack
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = frame
        local content = Instance.new("TextLabel")
        content.Size = UDim2.new(1, -16, 0, 0)
        content.Position = UDim2.new(0, 8, 0, 26)
        content.BackgroundTransparency = 1
        content.Text = opts.Content or opts.Desc or ""
        content.TextColor3 = Color3.fromRGB(200, 210, 230)
        content.TextSize = 10
        content.Font = Enum.Font.GothamMedium
        content.TextWrapped = true
        content.TextXAlignment = Enum.TextXAlignment.Left
        content.TextYAlignment = Enum.TextYAlignment.Top
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.Parent = frame
        frame.AutomaticSize = Enum.AutomaticSize.Y
        return frame
    end

    function tab:AddSection(title)
        local txt = type(title) == "table" and (title.Title or "") or tostring(title)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -8, 0, 24)
        label.BackgroundTransparency = 1
        label.Text = txt
        label.TextColor3 = Color3.fromRGB(150, 200, 255)
        label.TextSize = 12
        label.Font = Enum.Font.GothamBlack
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = tab._frame
        return label
    end

            table.insert(Window._tabs, tab)
        table.insert(Window._tabButtons, btn)
        tab._frame.Visible = false
        return tab
    end

    function Window:Dialog(opts)
        local bg = Instance.new("Frame")
        bg.Size = UDim2.fromScale(1, 1)
        bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        bg.BackgroundTransparency = 0.45
        bg.BorderSizePixel = 0
        bg.ZIndex = 400
        bg.Active = true
        bg.Parent = ScreenGui
        local box = Instance.new("Frame")
        box.AnchorPoint = Vector2.new(0.5, 0.5)
        box.Position = UDim2.fromScale(0.5, 0.5)
        box.Size = UDim2.fromOffset(340, 150)
        box.BackgroundColor3 = Color3.fromRGB(14, 17, 22)
        box.BackgroundTransparency = 0.05
        box.BorderSizePixel = 0
        box.ZIndex = 401
        box.Parent = bg
        AddCorner(box, 12)
        AddBorder(box, 1, 0.3)
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -24, 0, 24)
        t.Position = UDim2.fromOffset(12, 8)
        t.BackgroundTransparency = 1
        t.Text = opts.Title or "确认"
        t.TextColor3 = Color3.fromRGB(255, 255, 255)
        t.TextSize = 13
        t.Font = Enum.Font.GothamBlack
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = box
        local c = Instance.new("TextLabel")
        c.Size = UDim2.new(1, -24, 0, 50)
        c.Position = UDim2.fromOffset(12, 36)
        c.BackgroundTransparency = 1
        c.Text = opts.Content or ""
        c.TextColor3 = Color3.fromRGB(200, 210, 230)
        c.TextSize = 10
        c.Font = Enum.Font.GothamMedium
        c.TextWrapped = true
        c.TextXAlignment = Enum.TextXAlignment.Left
        c.TextYAlignment = Enum.TextYAlignment.Top
        c.Parent = box
        local btns = opts.Buttons or {}
        local bw = math.max(60, (340 - 30 - (#btns - 1) * 8) / math.max(1, #btns))
        for i, b in ipairs(btns) do
            local btn = Instance.new("TextButton")
            btn.Position = UDim2.new(0, 14 + (i - 1) * (bw + 8), 1, -44)
            btn.Size = UDim2.new(0, bw, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            btn.BackgroundTransparency = 0.85
            btn.BorderSizePixel = 0
            btn.Text = b.Title or "确定"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 11
            btn.Font = Enum.Font.GothamBold
            btn.AutoButtonColor = false
            btn.ZIndex = 402
            btn.Parent = box
            StyleButton(btn, 7)
            btn.Activated:Connect(function()
                bg:Destroy()
                if b.Callback then pcall(b.Callback) end
            end)
        end
    end

    Window.SelectTab(1)
    return Window
end

_DBUI.CreateWindow = CreateWindow
function _DBUI:Notify(opts)
    Notify(opts)
end
function _DBUI:GiveSignal(conn)
    return conn
end

local _DBESP = {
    ESPFolder = Instance.new("Folder"),
}
_DBESP.ESPFolder.Name = "DB_ESP"
_DBESP.ESPFolder.Parent = workspace

local espEntries = {}

function _DBESP.Add(...)
    local args = { ... }
    local obj, name, color, textSize, tag, showDist
    if type(args[1]) == "table" then
        local t = args[1]
        obj = t.Object
        name = t.Name
        color = t.Color
        textSize = t.TextSize
        tag = t.Tag
        showDist = t.ShowDistance
    else
        obj, name, color, textSize, tag = args[1], args[2], args[3], args[4], args[5]
    end
    if not obj then return end
    tag = tag or "default"
    if not espEntries[tag] then espEntries[tag] = {} end
    if espEntries[tag][obj] then
        pcall(function() espEntries[tag][obj].bg:Destroy() end)
        espEntries[tag][obj] = nil
    end
    local bg = Instance.new("BillboardGui")
    bg.Name = "DB_ESPLabel"
    bg.AlwaysOnTop = true
    bg.Size = UDim2.fromOffset(160, 26)
    bg.MaxDistance = 1500
    bg.Adornee = obj
    local lab = Instance.new("TextLabel")
    lab.Size = UDim2.fromScale(1, 1)
    lab.BackgroundTransparency = 1
    lab.Font = Enum.Font.GothamBold
    lab.TextSize = textSize or 12
    lab.TextColor3 = color or Color3.new(1, 1, 1)
    lab.TextStrokeTransparency = 0
    lab.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    lab.Text = tostring(name or obj.Name)
    lab.Parent = bg
    bg.Parent = _DBESP.ESPFolder
    espEntries[tag][obj] = {
        bg = bg,
        lab = lab,
        obj = obj,
        name = name,
        showDist = showDist or false,
        tag = tag,
    }
    return bg
end

function _DBESP.Clear(tag)
    if not espEntries[tag] then return end
    for obj, e in pairs(espEntries[tag]) do
        pcall(function() e.bg:Destroy() end)
    end
    espEntries[tag] = nil
end

RunService.RenderStepped:Connect(function()
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    for tag, entries in pairs(espEntries) do
        for obj, e in pairs(entries) do
            if not obj or not obj.Parent then
                pcall(function() e.bg:Destroy() end)
                entries[obj] = nil
            else
                local txt = ""
                if typeof(e.name) == "number" then
                    local intVal = obj:FindFirstChildOfClass("IntValue")
                    if intVal then
                        txt = tostring(intVal.Value)
                    else
                        txt = tostring(e.name)
                    end
                else
                    txt = tostring(e.name or obj.Name)
                end
                if e.showDist and hrp then
                    local pos = obj:IsA("BasePart") and obj.Position
                        or (obj:IsA("Model") and obj:GetPivot().Position) or nil
                    if pos then
                        txt = txt .. "  " .. math.floor((pos - hrp.Position).Magnitude) .. "m"
                    end
                end
                e.lab.Text = txt
            end
        end
    end
end)


local function xa_main()

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if not isfolder("XA-Hub") then
    makefolder("XA-Hub")
end
if not isfolder("XA-Hub/Fluent") then
    makefolder("XA-Hub/Fluent")
end
if not isfile("XA-Hub/Fluent/AutoFindMoneyPrinter.txt") then
    writefile("XA-Hub/Fluent/AutoFindMoneyPrinter.txt", "false")
end

local autoFind = readfile("XA-Hub/Fluent/AutoFindMoneyPrinter.txt")
if autoFind == "true" then
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Xingtaiduan/Script/refs/heads/main/Games/俄亥俄州_印钞机.lua"))()
    end)
    return
end

local Fluent = _DBUI
local ESP = _DBESP
ESP.ESPFolder.Parent = workspace

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
if not Character then
    for _ = 1, 60 do
        task.wait(0.5)
        Character = LocalPlayer.Character
        if Character then break end
    end
end
if not Character then
    warn("[缝合版] 等待角色超时，依赖角色的功能请在重生后使用")
end

local Humanoid = Character and Character:WaitForChild("Humanoid", 5)
local HumanoidRootPart = Character and Character:WaitForChild("HumanoidRootPart", 5)
local AirdropCallback = Instance.new("BindableFunction")

local RemotesModule = require(ReplicatedStorage.devv.client.Helpers.remotes.Signal)
local remoteStorage = ReplicatedStorage.devv:WaitForChild("remoteStorage")
local cacheTbl = debug.getupvalue(RemotesModule.FireServer, 1)
local Remotes = {}
if type(cacheTbl) == "table" then
    for k, v in pairs(cacheTbl) do
        if typeof(v) == "Instance" and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
            Remotes[k] = v
        end
    end
end

for _, r in ipairs(remoteStorage:GetDescendants()) do
    if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") then
        Remotes[r.Name] = Remotes[r.Name] or r
        if type(cacheTbl) == "table" then
            cacheTbl[r.Name] = cacheTbl[r.Name] or r
        end
    end
end
local eventMap = Remotes
Remotes.FireServer = function(name, ...)
    local ev = eventMap[name]
    if ev then
        local args = { ... }
        pcall(function() ev:FireServer(table.unpack(args)) end)
    end
end
Remotes.InvokeServer = function(name, ...)
    local ev = eventMap[name]
    if ev and ev:IsA("RemoteFunction") then
        local args = { ... }
        local ok, res = pcall(function() return ev:InvokeServer(table.unpack(args)) end)
        return ok and res or nil
    end
end
local ClientReplicator = require(ReplicatedStorage.devv.client.Helpers.objectProperties.ClientReplicator)
local Inventory = require(ReplicatedStorage.devv.client.Objects.v3item.modules.inventory)
local StateData = require(ReplicatedStorage.devv).load("state").data

local SelectedTarget = nil
local Whitelist = {
    2953444466,
    5509421902
}
local ItemsOnSaleList = {}
local Locations = {
    ["军械库"] = CFrame.new(671.68688964844, 6.2448601722717, -655.50268554688),
    ["银行"] = CFrame.new(1091.5296630859, 6.0434188842773, -457.62033081055),
    ["珠宝店"] = CFrame.new(1543.3168945312, 6.2433180809021, -682.63525390625),
    ["警察局"] = CFrame.new(655.10638427734, 9.035834312439, -903.20697021484),
    ["军事基地"] = CFrame.new(835.84875488281, 25.234800338745, -1327.0417480469),
    ["医院"] = CFrame.new(1112.4508056641, 6.0434203147888, -973.91772460938),
    ["游乐场"] = CFrame.new(1170.8796386719, 13.850684165955, -25.795112609863)
}

task.spawn(function()
    for _, item in pairs(workspace.ItemsOnSale:GetChildren()) do
        ItemsOnSaleList[item.Name] = item.Name
    end

    for _, conn in pairs(getconnections(game:GetService("RunService").Heartbeat)) do
        local fn = conn.Function
        if fn and getfenv(fn).script == ReplicatedStorage.devv.client.Handlers.ClientValidate then
            conn:Disable()
            game.StarterGui:SetCore("SendNotification", {
                Title = "XA：提示",
                Text = "飞行/速度封禁绕过成功"
            })
        end
    end

    getgenv().fixedremotes = {}
    for name, remote in next, RemotesModule do
        local upval = debug.getupvalue(remote, 1)
        if upval then
            getgenv().fixedremotes[name] = upval
        end
    end
end)

local function FindPlayer(input)
    local query = input:gsub("%s+", "")
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():match("^" .. query:lower()) then
            return player
        end
        if player.DisplayName:lower():match("^" .. query:lower()) then
            return player
        end
    end
    game.StarterGui:SetCore("SendNotification", {
        Title = "XA：错误",
        Text = "未找到玩家"
    })
    return nil
end

local function RefreshItemESP()
    for _, item in pairs(workspace.Game.Entities.ItemPickup:GetChildren()) do
        for _, part in pairs(item:GetDescendants()) do
            if part:IsA("MeshPart") then
                for _, prompt in pairs(part:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        ESP.Add({
                            Object = part,
                            Name = prompt.ObjectText,
                            Color = Color3.new(1, 1, 1),
                            TextSize = 12,
                            Tag = "ItemESP",
                            ShowDistance = false
                        })
                    end
                end
            end
        end
    end
end


Fluent:GiveSignal(workspace.Game.Entities.ItemPickup.DescendantAdded:Connect(function(obj)
    if Fluent.Options.SItemsFarm.Value and obj:IsA("ProximityPrompt") then
        local v = Fluent.Options.SelectedItems.Value
        local match = (v["红卡"] and obj.ObjectText == "Military Armory Keycard")
            or (v["蓝卡"] and obj.ObjectText == "Police Armory Keycard")
            or (v["印钞机"] and obj.ObjectText == "Money Printer")
            or (v["气球"] and obj.ObjectText:match("Balloon"))
        if match then
            local savedCF = HumanoidRootPart.CFrame
            Character:PivotTo(obj.Parent:GetPivot())
            task.wait()
            for i = 1, 5 do
                fireproximityprompt(obj)
                task.wait(0.1)
            end
            if Fluent.Options.ReturnOnTeleport.Value then
                Character:PivotTo(savedCF)
            end
        end
    end
end))

Fluent:GiveSignal(workspace.Game.Entities.ItemPickup.ChildAdded:Connect(function()
    if Fluent.Options.ItemESP.Value then
        ESP.Clear("ItemESP")
        RefreshItemESP()
    end
end))

Fluent:GiveSignal(workspace.Game.Airdrops.ChildAdded:Connect(function(airdrop)
    if not Fluent.Options.NotifyAirdrop.Value then return end
    game.StarterGui:SetCore("SendNotification", {
        Title = "空投已刷新",
        Text = "是否传送到空投？",
        Duration = 5,
        Button1 = "是",
        Button2 = "否",
        Callback = AirdropCallback
    })
    AirdropCallback.OnInvoke = function(response)
        if response == "是" then
            Character:PivotTo(airdrop:GetPivot())
        end
    end
end))

Fluent:GiveSignal(workspace.Game.Entities.CashBundle.ChildAdded:Connect(function(obj)
    if not Fluent.Options.CashESP.Value then return end
    task.delay(0.2, function()
        local intVal = obj:FindFirstChildOfClass("IntValue")
        if intVal then
            ESP.Add(obj, intVal.Value, Color3.fromRGB(23, 255, 42), 10, "CashESP")
        end
    end)
end))

Fluent:GiveSignal(LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    if Fluent.Options.AutoEquip.Value then
        Remotes.FireServer("equip", Inventory.getFromName("Fists").guid)
    end
end))

Fluent:GiveSignal(RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if not char then continue end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then continue end
            if char:FindFirstChild("ForceField") then continue end
            if table.find(Whitelist, player.UserId) then continue end

            if Fluent.Options.KillAura.Value then
                local dist = (HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist < 35 and hum.Health > 5 then
                    Remotes.FireServer("attackMeleeHit", "player", {
                        meleeType = "meleemegapunch",
                        hitPlayerId = player.UserId
                    })
                end
            end

            if Fluent.Options.StompAura.Value then
                if ClientReplicator.Get(player, "knocked") then
                    local dist = (HumanoidRootPart.Position - hrp.Position).Magnitude
                    if dist < 30 then
                        Remotes.FireServer("finish", player)
                    end
                end
            end

            if Fluent.Options.GrabAura.Value then
                if ClientReplicator.Get(player, "knocked") then
                    local dist = (HumanoidRootPart.Position - hrp.Position).Magnitude
                    if dist < 35 then
                        Remotes.FireServer("grabPlayer", player)
                    end
                end
            end
        end
    end

    if Fluent.Options.Godmode.Value then
        if ClientReplicator.Get(LocalPlayer, "knocked") then
            ClientReplicator.Set(LocalPlayer, "knocked", false)
        end
    end

    if Fluent.Options.WalkSpeed.IsMoved and Humanoid then
        Humanoid.WalkSpeed = Fluent.Options.WalkSpeed.Value
    end
    if Fluent.Options.JumpPower.IsMoved and Humanoid then
        Humanoid.JumpPower = Fluent.Options.JumpPower.Value
        Humanoid.UseJumpPower = true
    end

    if Fluent.Options.Noclip.Value and Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    if Fluent.Options.Fullbright.Value then
        Lighting.Ambient = Color3.new(1, 1, 1)
    else
        Lighting.Ambient = Color3.new(0, 0, 0)
    end
end))

Fluent:GiveSignal(UserInputService.JumpRequest:Connect(function()
    if Fluent.Options.InfJump.Value and Humanoid then
        Humanoid:ChangeState("Jumping")
    end
end))

local Window = Fluent:CreateWindow({
    Title = "XA Hub",
    SubTitle = "俄亥俄州",
    TabWidth = 160,
    Size = UDim2.fromOffset(550, 350),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})
_G.XA_Window = Window

local TabCombat = Window:AddTab({ Title = "战斗类", Icon = "" })

TabCombat:AddToggle("OnePunch", {
    Title = "一拳秒杀",
    Default = false
})

TabCombat:AddToggle("OneSwing", {
    Title = "其他近战武器秒杀",
    Default = false
})

TabCombat:AddToggle("KillAura", {
    Title = "杀戮光环",
    Default = false,
    Callback = function(val)
        if val then
            Remotes.FireServer("equip", Inventory.getFromName("Fists").guid)
        end
    end
})

TabCombat:AddToggle("StompAura", {
    Title = "踩人光环",
    Default = false
})

TabCombat:AddToggle("GrabAura", {
    Title = "抓人光环",
    Default = false
})

TabCombat:AddToggle("Killall", {
    Title = "杀死全部",
    Default = false,
    Callback = function(val)
        if val then
            Remotes.FireServer("equip", Inventory.getFromName("Fists").guid)
        end
        HumanoidRootPart.Anchored = val
        while Fluent.Options.Killall.Value do
            task.wait()
            for _, player in pairs(Players:GetPlayers()) do
                if not Fluent.Options.Killall.Value then break end
                if player == LocalPlayer then continue end
                if table.find(Whitelist, player.UserId) then continue end
                local char = player.Character
                if not char then continue end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum then continue end
                if char:FindFirstChild("ForceField") then continue end
                if hum.Health <= 5 then continue end
                task.wait()
                Humanoid.Sit = false
                Character:PivotTo(char.HumanoidRootPart.CFrame)
                Remotes.FireServer("attackMeleeHit", "player", {
                    meleeType = "meleemegapunch",
                    hitPlayerId = player.UserId
                })
                Remotes.FireServer("finish", player)
                task.wait(0.7)
            end
        end
        HumanoidRootPart.Anchored = false
    end
})

TabCombat:AddToggle("AutoEquip", {
    Title = "死亡自动装备拳头",
    Default = false
})

TabCombat:AddToggle("Godmode", {
    Title = "防倒地",
    Default = false
})

TabCombat:AddToggle("Invisible", {
    Title = "隐身",
    Description = "可用枪械攻击",
    Default = false,
    Callback = function(val)
        if val then
            local savedCF = HumanoidRootPart.CFrame
            Character:MoveTo(Vector3.new(-25.95, 84, 3537.55))
            task.wait(0.15)
            local chair = Instance.new("Seat", workspace)
            chair.Anchored = false
            chair.CanCollide = false
            chair.Name = "invischair"
            chair.Transparency = 1
            chair.Position = Vector3.new(-25.95, 84, 3537.55)
            local weld = Instance.new("Weld", chair)
            weld.Part0 = chair
            local torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
            if torso then
                weld.Part1 = torso
                task.wait()
                Instance.new("Seat", workspace).CFrame = savedCF
            end
        else
            local chair = workspace:FindFirstChild("invischair")
            if chair then chair:Remove() end
        end
    end
})


TabCombat:AddToggle("AutoArmor", {
    Title = "自动穿甲",
    Default = false,
    Callback = function()
        while Fluent.Options.AutoArmor.Value do
            task.wait()
            if not Character then continue end
            local armor = LocalPlayer:GetAttribute("armor")
            if not armor or armor <= 0 then
                Remotes.InvokeServer("attemptPurchase", "Light Vest")
                local lvItem = Inventory.getFromName("Light Vest")
                if lvItem then
                    Remotes.FireServer("equip", lvItem.guid)
                    Remotes.FireServer("useConsumable", lvItem.guid)
                    Remotes.FireServer("removeItem", lvItem.guid)
                end
            end
        end
    end
})

TabCombat:AddSection("子弹范围")

local HitboxConnection
TabCombat:AddToggle("Hitbox", {
    Title = "开关",
    Default = false,
    Callback = function(val)
        if val then
            HitboxConnection = RunService.RenderStepped:Connect(function()
                for _, player in next, Players:GetPlayers() do
                    pcall(function()
                        player.Character.HumanoidRootPart.Size = Vector3.new(
                            Fluent.Options.HitboxSize.Value,
                            Fluent.Options.HitboxSize.Value,
                            Fluent.Options.HitboxSize.Value
                        )
                        player.Character.HumanoidRootPart.Transparency = Fluent.Options.HitboxTransparency.Value
                        player.Character.HumanoidRootPart.Color = Color3.fromRGB(0, 0, 0)
                        player.Character.HumanoidRootPart.Material = "Neon"
                        player.Character.HumanoidRootPart.CanCollide = false
                    end)
                end
            end)
        else
            if HitboxConnection then HitboxConnection:Disconnect() end
            task.wait()
            for _, player in next, Players:GetPlayers() do
                pcall(function()
                    player.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                    player.Character.HumanoidRootPart.Transparency = 1
                    player.Character.HumanoidRootPart.Color = Color3.fromRGB(163, 162, 165)
                    player.Character.HumanoidRootPart.BrickColor = BrickColor.new("Medium stone grey")
                    player.Character.HumanoidRootPart.Material = "Plastic"
                    player.Character.HumanoidRootPart.CanCollide = false
                end)
            end
        end
    end
})

TabCombat:AddInput("HitboxSize", {
    Title = "输入大小",
    Default = "15",
    Numeric = false,
    Finished = true
})

TabCombat:AddInput("HitboxTransparency", {
    Title = "输入透明度",
    Default = "0.8",
    Numeric = false,
    Finished = true
})

TabCombat:AddDropdown("HitboxHitPart", {
    Title = "攻击部位",
    Values = { "头部", "身体" },
    Multi = false,
    Default = 1,
    Callback = function(val)
    end
})

TabCombat:AddSection("白名单")

local WhitelistInput
WhitelistInput = TabCombat:AddInput("Input", {
    Title = "输入名称 当前：无",
    Numeric = false,
    Finished = true,
    Callback = function(val)
        local found = FindPlayer(val)
        if found then
            WhitelistInput:SetTitle("输入名称 当前：" .. found.Name)
            SelectedTarget = found
        else
            WhitelistInput:SetTitle("输入名称 当前：无")
            SelectedTarget = nil
        end
    end
})

TabCombat:AddButton({
    Title = "添加至白名单",
    Callback = function()
        if SelectedTarget then
            Window:Dialog({
                Title = "添加白名单",
                Content = "是否将玩家" .. SelectedTarget.Name .. "添加至白名单？",
                Buttons = {
                    {
                        Title = "是",
                        Callback = function()
                            if not table.find(Whitelist, SelectedTarget.UserId) then
                                table.insert(Whitelist, SelectedTarget.UserId)
                            else
                                Fluent:Notify({ Title = "XA：错误", Content = "该玩家已经被添加至白名单" })
                            end
                        end
                    },
                    { Title = "否", Callback = function() end }
                }
            })
        else
            Fluent:Notify({ Title = "XA：错误", Content = "请先输入名称" })
        end
    end
})

TabCombat:AddButton({
    Title = "移除白名单",
    Callback = function()
        if SelectedTarget then
            Window:Dialog({
                Title = "移除白名单",
                Content = "是否将玩家" .. SelectedTarget.Name .. "移除白名单？",
                Buttons = {
                    {
                        Title = "是",
                        Callback = function()
                            local idx = table.find(Whitelist, SelectedTarget.UserId)
                            if idx then
                                table.remove(Whitelist, idx)
                            else
                                Fluent:Notify({ Title = "XA：错误", Content = "该玩家没有白名单，无法移除" })
                            end
                        end
                    },
                    { Title = "否" }
                }
            })
        else
            Fluent:Notify({ Title = "XA：错误", Content = "请先输入名称" })
        end
    end
})

TabCombat:AddButton({
    Title = "清空白名单",
    Callback = function()
        table.clear(Whitelist)
    end
})

local TabItems = Window:AddTab({ Title = "物品", Icon = "" })
local SelectedItem = nil

TabItems:AddDropdown("SelectItem", {
    Title = "选择物品",
    Values = (function()
        local list = {}
        for k in pairs(ItemsOnSaleList) do
            table.insert(list, k)
        end
        table.sort(list)
        return list
    end)(),
    Multi = false,
    Searchable = true,
    Callback = function(val)
        SelectedItem = val
    end
})

TabItems:AddButton({
    Title = "购买",
    Callback = function()
        if SelectedItem then
            Remotes.InvokeServer("attemptPurchase", SelectedItem)
        else
            game.StarterGui:SetCore("SendNotification", { Title = "错误", Text = "请先选择物品" })
        end
    end
})

TabItems:AddButton({
    Title = "购买子弹",
    Callback = function()
        if SelectedItem then
            Remotes.InvokeServer("attemptPurchaseAmmo", SelectedItem)
        else
            game.StarterGui:SetCore("SendNotification", { Title = "错误", Text = "请先选择物品" })
        end
    end
})

TabItems:AddToggle("ShowBuyUI", {
    Title = "显示购买界面",
    Default = false,
    Callback = function()
        if not SelectedItem then return end
        while Fluent.Options.ShowBuyUI.Value do
            task.wait()
            local itemNode = workspace.ItemsOnSale:FindFirstChild(SelectedItem)
            if itemNode then
                local td = itemNode:FindFirstChildOfClass("TouchDetector")
                if td then
                    firetouchinterest(td.Parent, HumanoidRootPart, 0)
                    firetouchinterest(td.Parent, HumanoidRootPart, 1)
                end
            end
        end
    end
})

TabItems:AddToggle("BlackMarket", {
    Title = "远程黑市",
    Default = false,
    Callback = function(val)
        workspace.BlackMarket.Dealer.Dealer.ProximityPrompt.MaxActivationDistance = val and 10000 or 20
    end
})

TabItems:AddToggle("Locker", {
    Title = "远程储物柜",
    Description = "打开背包即可",
    Default = false,
    Callback = function(val)
        LocalPlayer.PlayerGui.Backpack.Holder.Locker.Visible = val
    end
})

local FastInteractConn
TabItems:AddToggle("FastInteract", {
    Title = "快速互动",
    Default = false,
    Callback = function(val)
        if val then
            FastInteractConn = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
                fireproximityprompt(prompt)
            end)
        else
            if FastInteractConn then FastInteractConn:Disconnect() end
        end
    end
})

TabItems:AddToggle("ItemESP", {
    Title = "透视物品",
    Default = false,
    Callback = function(val)
        if val then
            RefreshItemESP()
        else
            ESP.Clear("ItemESP")
        end
    end
})

local TabAuto = Window:AddTab({ Title = "自动", Icon = "" })

TabAuto:AddToggle("CashFarm", {
    Title = "自动捡钱(未测试)",
    Default = false,
    Callback = function()
        while Fluent.Options.CashFarm.Value do
            task.wait()
            for _, bundle in pairs(workspace.Game.Entities.CashBundle:GetChildren()) do
                if not Fluent.Options.CashFarm.Value then break end
                pcall(function()
                    local cd = bundle:FindFirstChildOfClass("ClickDetector")
                    if cd then
                        local cp = cd.Parent
                        if cp and cp:IsA("BasePart") then
                            Character:PivotTo(cp.CFrame * CFrame.new(0, 0, 3))
                            task.wait(0.3)
                            fireclickdetector(cd)
                            task.wait(1)
                        end
                    end
                end)
            end
        end
    end
})

TabAuto:AddToggle("CashAura", {
    Title = "捡钱光环",
    Default = false,
    Callback = function()
        while Fluent.Options.CashAura.Value do
            for _, bundle in pairs(workspace.Game.Entities.CashBundle:GetChildren()) do
                pcall(function()
                    local cd = bundle:FindFirstChildOfClass("ClickDetector")
                    if cd and (HumanoidRootPart.Position - bundle:GetPivot().Position).Magnitude <= cd.MaxActivationDistance then
                        fireclickdetector(cd)
                    end
                    local prompt = bundle:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt and (HumanoidRootPart.Position - bundle:GetPivot().Position).Magnitude <= (prompt.MaxActivationDistance or 16) then
                        fireproximityprompt(prompt)
                    end
                end)
            end
            wait(0.25)
        end
    end
})

TabAuto:AddToggle("ItemFarm", {
    Title = "自动捡物品",
    Default = false,
    Callback = function()
        while Fluent.Options.ItemFarm.Value do
            task.wait()
            for _, item in pairs(workspace.Game.Entities.ItemPickup:GetChildren()) do
                if not Fluent.Options.ItemFarm.Value then break end
                pcall(function()
                    local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                    local cd = item:FindFirstChildWhichIsA("ClickDetector", true)
                    if prompt then
                        local tp = prompt.Parent
                        local pos = nil
                        if tp then
                            if tp:IsA("Attachment") then pos = tp.WorldPosition
                            elseif tp:IsA("BasePart") then pos = tp.Position
                            elseif tp:IsA("Model") then local pp = tp.PrimaryPart or tp:FindFirstChildWhichIsA("BasePart"); if pp then pos = pp.Position end end
                        end
                        if pos then
                            Character:PivotTo(CFrame.new(pos) * CFrame.new(0, 0, 3))
                            task.wait(0.3)
                            fireproximityprompt(prompt)
                            task.wait(1.5)
                        end
                    elseif cd then
                        local cp = cd.Parent
                        if cp and cp:IsA("BasePart") then
                            Character:PivotTo(cp.CFrame * CFrame.new(0, 0, 3))
                            task.wait(0.3)
                            fireclickdetector(cd)
                            task.wait(1.5)
                        end
                    end
                end)
            end
        end
    end
})

TabAuto:AddToggle("ItemAura", {
    Title = "捡物品光环",
    Default = false,
    Callback = function()
        task.spawn(function()
            local lastTrigger = {}
            while Fluent.Options.ItemAura.Value do
                task.wait(0.5)
                pcall(function()
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    local now = os.clock()
                    for _, item in pairs(workspace.Game.Entities.ItemPickup:GetChildren()) do
                        if not Fluent.Options.ItemAura.Value then return end
                        if not item.Parent then continue end
                        local lt = lastTrigger[item]
                        if lt and now - lt < 2 then continue end
                        local dist = (hrp.Position - item:GetPivot().Position).Magnitude
                        local cd = item:FindFirstChildWhichIsA("ClickDetector", true)
                        local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if cd and dist <= cd.MaxActivationDistance then
                            fireclickdetector(cd)
                            lastTrigger[item] = now
                        elseif prompt and dist <= (prompt.MaxActivationDistance or 16) then
                            fireproximityprompt(prompt)
                            lastTrigger[item] = now
                        end
                    end
                    for k in pairs(lastTrigger) do
                        if not k.Parent then lastTrigger[k] = nil end
                    end
                end)
            end
        end)
    end
})

TabAuto:AddDropdown("SelectedItems", {
    Title = "选择物品",
    Values = { "红卡", "蓝卡", "印钞机", "气球" },
    Multi = true,
    AllowNull = true,
    Callback = function()
        if Fluent.Options.SItemsFarm.Value then
            Fluent.Options.SItemsFarm:SetValue(true)
        end
    end
})

TabAuto:AddToggle("SItemsFarm", {
    Title = "自动捡选中的物品",
    Default = false,
    Callback = function(val)
        if not val then return end
        local v = Fluent.Options.SelectedItems.Value
        for _, item in pairs(workspace.Game.Entities.ItemPickup:GetDescendants()) do
            if item:IsA("ProximityPrompt") then
                local match = (v["红卡"] and item.ObjectText == "Military Armory Keycard")
                    or (v["蓝卡"] and item.ObjectText == "Police Armory Keycard")
                    or (v["印钞机"] and item.ObjectText == "Money Printer")
                    or (v["气球"] and item.ObjectText:match("Balloon"))
                if match then
                    local savedCF = HumanoidRootPart.CFrame
                    local itp = item.Parent
                    local pos = nil
                    if itp then
                        if itp:IsA("Attachment") then pos = itp.WorldPosition
                        elseif itp:IsA("BasePart") then pos = itp.Position
                        elseif itp:IsA("Model") then local pp = itp.PrimaryPart or itp:FindFirstChildWhichIsA("BasePart"); if pp then pos = pp.Position end end
                    end
                    if pos then
                        Character:PivotTo(CFrame.new(pos) * CFrame.new(0, 0, 3))
                        task.wait(0.3)
                    end
                    for i = 1, 5 do
                        fireproximityprompt(item)
                        task.wait(0.1)
                    end
                    Character:PivotTo(savedCF)
                    wait(1.5)
                end
            end
        end
    end
})

TabAuto:AddInput("AutoBuyItem", {
    Title = "自动购买物品名",
    Default = "",
    Numeric = false,
    Finished = true,
})
TabAuto:AddToggle("AutoBuy", {
    Title = "自动购买",
    Default = false,
    Callback = function(val)
        if not val then return end
        task.spawn(function()
            while Fluent.Options.AutoBuy.Value do
                local itemName = Fluent.Options.AutoBuyItem.Value
                if itemName and itemName ~= "" then
                    pcall(function()
                        local char = LocalPlayer.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        local bought = false
                        if hrp then
                            for _, d in ipairs(workspace:GetDescendants()) do
                                if not Fluent.Options.AutoBuy.Value then return end
                                if d:IsA("ProximityPrompt") and d.Enabled then
                                    local t = d.ObjectText or ""
                                    if t:find(itemName, 1, true) then
                                        local tp = d.Parent
                                        local pos = nil
                                        if tp then
                                            if tp:IsA("Attachment") then pos = tp.WorldPosition
                                            elseif tp:IsA("BasePart") then pos = tp.Position
                                            elseif tp:IsA("Model") then local pp = tp.PrimaryPart or tp:FindFirstChildWhichIsA("BasePart"); if pp then pos = pp.Position end end
                                        end
                                        if pos then
                                            hrp.CFrame = CFrame.new(pos) * CFrame.new(0, 0, 3)
                                            task.wait(0.3)
                                        end
                                        fireproximityprompt(d)
                                        bought = true
                                        task.wait(1.2)
                                    end
                                end
                            end
                        end
                        if not bought then
                            Remotes.InvokeServer("attemptPurchase", itemName, true, nil)
                        end
                    end)
                end
                task.wait(2)
            end
        end)
    end
})
TabAuto:AddToggle("ReturnOnTeleport", {
    Title = "是否回传",
    Default = false
})

TabAuto:AddToggle("NotifyAirdrop", {
    Title = "空投刷新提示",
    Default = false
})

local function findPrinterPrompt()
    local found = {}
    local function scan(root)
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("ProximityPrompt") and d.Enabled then
                local t = d.ObjectText or ""
                if t:find("Money Printer") or t:find("印钞机") then
                    found[#found + 1] = d
                end
            end
        end
    end
    scan(game:GetService("Workspace"))
    scan(game:GetService("ReplicatedStorage"))
    return found
end

TabAuto:AddToggle("MoneyPrinterFarm", {
    Title = "自动捡印钞机",
    Default = false,
    Callback = function(val)
        if not val then return end
        task.spawn(function()
            while Fluent.Options.MoneyPrinterFarm.Value do
                pcall(function()
                    local prompts = findPrinterPrompt()
                    for _, prompt in ipairs(prompts) do
                        if not Fluent.Options.MoneyPrinterFarm.Value then return end
                        local tp = prompt.Parent
                        local pos = nil
                        if tp then
                            if tp:IsA("Attachment") then pos = tp.WorldPosition
                            elseif tp:IsA("BasePart") then pos = tp.Position
                            elseif tp:IsA("Model") then local pp = tp.PrimaryPart or tp:FindFirstChildWhichIsA("BasePart"); if pp then pos = pp.Position end end
                        end
                        if pos then
                            local char = LocalPlayer.Character
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                hrp.CFrame = CFrame.new(pos) * CFrame.new(0, 0, 3)
                                task.wait(0.3)
                            end
                            fireproximityprompt(prompt)
                            task.wait(1)
                        end
                    end
                end)
                task.wait(1.5)
            end
        end)
    end
})

TabAuto:AddButton({
    Title = "自动换服寻找印钞机(原版)",
    Callback = function()
        Fluent:Notify({
            Title = "提示",
            Content = "原作者印钞机脚本仓库已失效(404),已用本地自动捡印钞机替代"
        })
        wait(3)
        writefile("XA-Hub/Fluent/AutoFindMoneyPrinter.txt", "true")
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Xingtaiduan/Script/refs/heads/main/Games/俄亥俄州_印钞机.lua"))()
        end)
    end
})

local TabTeleport = Window:AddTab({ Title = "传送", Icon = "" })
local SelectedLocation = nil

TabTeleport:AddDropdown("SelectLocation", {
    Title = "选择地点",
    Values = (function()
        local list = {}
        for k in pairs(Locations) do
            table.insert(list, k)
        end
        return list
    end)(),
    Multi = false,
    Callback = function(val)
        SelectedLocation = val
    end
})

TabTeleport:AddButton({
    Title = "传送",
    Callback = function()
        if SelectedLocation then
            Character:PivotTo(Locations[SelectedLocation])
        end
    end
})

local TabFun = Window:AddTab({ Title = "娱乐", Icon = "" })
local FunTarget = nil
local FunTargetInput

FunTargetInput = TabFun:AddInput("Input", {
    Title = "输入名称 当前：无",
    Numeric = false,
    Finished = true,
    Callback = function(val)
        local found = FindPlayer(val)
        FunTarget = found
        if found then
            FunTargetInput:SetTitle("输入名称 当前：" .. found.Name)
        else
            FunTargetInput:SetTitle("输入名称 当前：无")
        end
    end
})

TabFun:AddInput("SpamMessage", {
    Title = "输入消息",
    Default = "XA-Hub No.1",
    Numeric = false,
    Finished = true
})

TabFun:AddToggle("SpamPlayer", {
    Title = "消息轰炸",
    Default = false,
    Callback = function()
        if not FunTarget then
            Fluent:Notify({ Title = "XA：错误", Content = "请先输入名称" })
            return
        end
        while Fluent.Options.SpamPlayer.Value do
            task.wait(0.2)
            Remotes.FireServer("sendMessage", FunTarget.UserId, Fluent.Options.SpamMessage.Value)
        end
    end
})

TabFun:AddToggle("SpamCall", {
    Title = "电话骚扰",
    Default = false,
    Callback = function()
        if not FunTarget then
            Fluent:Notify({ Title = "XA：错误", Content = "请先输入名称" })
            return
        end
        while Fluent.Options.SpamCall.Value do
            task.wait(0.2)
            Remotes.InvokeServer("attemptCall", FunTarget.UserId)
        end
    end
})

TabFun:AddToggle("SpamAll", {
    Title = "消息轰炸全体",
    Default = false,
    Callback = function()
        while Fluent.Options.SpamAll.Value do
            task.wait(0.2)
            for _, player in pairs(Players:GetPlayers()) do
                if not Fluent.Options.SpamAll.Value then break end
                Remotes.FireServer("sendMessage", player.UserId, Fluent.Options.SpamMessage.Value)
            end
        end
    end
})

local TabData = Window:AddTab({ Title = "数据", Icon = "" })

TabData:AddParagraph({ Title = "是否被封禁：否" })
TabData:AddParagraph({ Title = "封禁开始期：无" })
TabData:AddParagraph({ Title = "封禁结束期：无" })
local BanTimeLabel = TabData:AddParagraph({ Title = "剩余封禁时间：无" })
TabData:AddParagraph({ Title = "封禁原因：无" })
TabData:AddParagraph({ Title = "历史封禁次数：0" })

local TabOther = Window:AddTab({ Title = "其他", Icon = "" })

TabOther:AddToggle("ShowChat", {
    Title = "显示聊天框",
    Default = false,
    Callback = function(val)
        game:GetService("TextChatService").ChatWindowConfiguration.Enabled = val
    end
})

TabOther:AddToggle("CashESP", {
    Title = "透视钱",
    Default = false,
    Callback = function(val)
        if val then
            for _, bundle in pairs(workspace.Game.Entities.CashBundle:GetChildren()) do
                local intVal = bundle:FindFirstChildOfClass("IntValue")
                if intVal then
                    ESP.Add(bundle, intVal.Value, Color3.fromRGB(23, 255, 42), 10, "CashESP")
                end
            end
        else
            ESP.Clear("CashESP")
        end
    end
})

local PlayerESPOn = false
local plyEsp = {}
local plyEspLabelConn = nil
local function plyEspApply(char)
    local entry = plyEsp[char]
    if not entry then
        local hl = Instance.new("Highlight")
        hl.Name = "PlyESPChams"
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        local bg, lab = nil, nil
        local head = char:FindFirstChild("Head")
        if head then
            bg = Instance.new("BillboardGui")
            bg.Name = "PlyESPLabel"
            bg.AlwaysOnTop = true
            bg.Size = UDim2.fromOffset(200, 24)
            bg.MaxDistance = 700
            bg.Adornee = head
            bg.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
            lab = Instance.new("TextLabel")
            lab.Size = UDim2.fromScale(1, 1)
            lab.BackgroundTransparency = 1
            lab.Font = Enum.Font.GothamBold
            lab.TextSize = 12
            lab.TextColor3 = Color3.new(1, 1, 1)
            lab.TextStrokeTransparency = 0
            lab.TextStrokeColor3 = Color3.new(0, 0, 0)
            lab.Parent = bg
            bg.Parent = char
        end
        hl.Parent = char
        entry = { hl = hl, bg = bg, lab = lab }
        plyEsp[char] = entry
    end
    local p = Players:GetPlayerFromCharacter(char)
    local myTeam = LocalPlayer.Team
    local t = p and p.Team
    local col = (not t or not myTeam or t == myTeam) and Color3.fromRGB(80, 255, 140) or Color3.fromRGB(255, 64, 64)
    entry.hl.FillColor = col
    entry.hl.OutlineColor = col
    return entry
end
local function plyEspClean()
    for char, e in pairs(plyEsp) do
        if not char.Parent then
            pcall(function() e.hl:Destroy() end)
            if e.bg then pcall(function() e.bg:Destroy() end) end
            plyEsp[char] = nil
        end
    end
end
local function plyEspSet(on)
    PlayerESPOn = on
    if on then
        task.spawn(function()
            while PlayerESPOn do
                pcall(function()
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p == LocalPlayer then continue end
                        local char = p.Character
                        if char and char:FindFirstChildOfClass("Humanoid") then
                            plyEspApply(char)
                        end
                    end
                    plyEspClean()
                end)
                task.wait(0.5)
            end
        end)
        plyEspLabelConn = RunService.RenderStepped:Connect(function()
            if not PlayerESPOn then return end
            local cam = workspace.CurrentCamera
            if not cam then return end
            for char, e in pairs(plyEsp) do
                if e.lab then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hum and hrp then
                        local p = Players:GetPlayerFromCharacter(char)
                        local name = p and p.Name or "?"
                        local dist = (hrp.Position - cam.CFrame.Position).Magnitude
                        e.lab.Text = name .. " | " .. math.floor(hum.Health) .. "hp | " .. math.floor(dist) .. "m"
                    end
                end
            end
        end)
    else
        if plyEspLabelConn then
            plyEspLabelConn:Disconnect()
            plyEspLabelConn = nil
        end
        for char, e in pairs(plyEsp) do
            pcall(function() e.hl:Destroy() end)
            if e.bg then pcall(function() e.bg:Destroy() end) end
            plyEsp[char] = nil
        end
    end
end

TabOther:AddToggle("PlayerESP", {
    Title = "玩家透视",
    Default = false,
    Callback = function(v) plyEspSet(v) end
})
TabOther:AddInput("ItemSlots", {
    Title = "设置物品栏数量",
    Numeric = true,
    Finished = true,
    Callback = function(val)
        Inventory.numSlots = tonumber(val)
    end
})

TabOther:AddSection("通用")

TabOther:AddSlider("WalkSpeed", {
    Title = "移动速度",
    Default = 16,
    Min = 0,
    Max = 500,
    Rounding = 1
})

TabOther:AddSlider("JumpPower", {
    Title = "跳跃高度",
    Default = 50,
    Min = 0,
    Max = 500,
    Rounding = 1
})

_G.FlyState = { on = false, bv = nil, bg = nil, speed = 60, origin = nil }
local function FlySet(on)
    _G.FlyState.on = on
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if on then
        if _G.FlyState.bv then return end
        local bv = Instance.new("BodyVelocity")
        bv.Name = "DBFlyBV"
        bv.MaxForce = Vector3.new(9e4, 9e4, 9e4)
        bv.Velocity = Vector3.new()
        bv:SetAttribute("whitelist", true)
        local bg = Instance.new("BodyGyro")
        bg.Name = "DBFlyBG"
        bg.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
        bg.D = 100
        bg.P = 1000
        bg:SetAttribute("whitelist", true)
        bv.Parent = hrp
        bg.Parent = hrp
        _G.FlyState.bv, _G.FlyState.bg = bv, bg
        _G.FlyState.origin = hrp.Position
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        end
    else
        if _G.FlyState.bv then pcall(function() _G.FlyState.bv:Destroy() end) end
        if _G.FlyState.bg then pcall(function() _G.FlyState.bg:Destroy() end) end
        _G.FlyState.bv, _G.FlyState.bg = nil, nil
        _G.FlyState.origin = nil
    end
end
RunService.RenderStepped:Connect(function()
    if not _G.FlyState.on then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not _G.FlyState.bv then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local move = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
    if move.Magnitude > 0 then move = move.Unit * _G.FlyState.speed end
    _G.FlyState.bv.Velocity = move
    _G.FlyState.bg.CFrame = cam.CFrame
end)

TabOther:AddToggle("Fly", {
    Title = "飞行(绕过反作弊)",
    Default = false,
    Callback = function(v) FlySet(v) end
})
TabOther:AddSlider("FlySpeed", {
    Title = "飞行速度",
    Default = 60,
    Min = 10,
    Max = 300,
    Rounding = 5,
    Callback = function(v)
        if _G.FlyState then _G.FlyState.speed = v end
    end
})

TabOther:AddToggle("Noclip", {
    Title = "穿墙",
    Default = false,
    Callback = function(val)
        if not val and Humanoid then
            Humanoid:ChangeState("Flying")
        end
    end
})

TabOther:AddToggle("Fullbright", {
    Title = "夜视",
    Default = false,
    Callback = function(val)
        if not val then
            Lighting.Ambient = Color3.new(0, 0, 0)
        end
    end
})

TabOther:AddToggle("InfJump", {
    Title = "无限跳",
    Default = false
})

local TabSettings = Window:AddTab({ Title = "设置", Icon = "settings" })

if SaveManager and InterfaceManager then
    InterfaceManager:SetLibrary(Fluent)
    InterfaceManager:SetFolder("XA-Hub/Fluent")
    InterfaceManager:BuildInterfaceSection(TabSettings)

    SaveManager:SetLibrary(Fluent)
    SaveManager:SetFolder("XA-Hub/Fluent/" .. game.PlaceId)
    SaveManager:IgnoreThemeSettings()
    SaveManager:BuildConfigSection(TabSettings)
    SaveManager:LoadAutoloadConfig()
end

Window:SelectTab(1)
end
xa_main()


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Character = LocalPlayer.Character
local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
end)
local _tnKeyCounter = 0
local function _tnKey()
    _tnKeyCounter = _tnKeyCounter + 1
    return "tnine_" .. _tnKeyCounter
end
local function _tnShimTab(title)
    local win = _G.XA_Window
    local ftab = win and win:AddTab({ Title = title or ("tnine_" .. _tnKey()) }) or nil
    local tab = {}
    function tab:Paragraph(opts)
        if not ftab then return end
        ftab:AddParagraph({
            Title = opts.Title,
            Content = opts.Desc or opts.Content or "",
        })
    end
    function tab:Toggle(opts)
        if not ftab then return nil end
        return ftab:AddToggle(_tnKey(), {
            Title = opts.Title,
            Default = opts.Default or opts.Value or false,
            Callback = opts.Callback,
        })
    end
    function tab:Slider(opts)
        if not ftab then return nil end
        return ftab:AddSlider(_tnKey(), {
            Title = opts.Title,
            Min = opts.Value.Min,
            Max = opts.Value.Max,
            Default = opts.Value.Default,
            Rounding = 1,
            Callback = opts.Callback,
        })
    end
    function tab:Button(opts)
        if not ftab then return nil end
        return ftab:AddButton({
            Title = opts.Title,
            Callback = opts.Callback,
        })
    end
    function tab:Dropdown(opts)
        if not ftab then return nil end
        return ftab:AddDropdown(_tnKey(), {
            Title = opts.Title,
            Values = opts.Values,
            Multi = false,
            Default = opts.Value,
            Callback = opts.Callback,
        })
    end
    function tab:Input(opts)
        if not ftab then return nil end
        return ftab:AddInput(_tnKey(), {
            Title = opts.Title,
            Default = opts.Default or "",
            Numeric = false,
            Finished = true,
            Callback = opts.Callback,
        })
    end
    return tab
end
local function _tnSection(title)
    return {
        Tab = function(_, opts)
            return _tnShimTab(opts and opts.Title or title)
        end
    }
end

local Tabs = {}

do
    
    Tabs.MoneySection = _tnSection("主要类")
    
    Tabs.ProSection = _tnSection("防护类")
    
    Tabs.ConfigSection = _tnSection("次要类")
    
    
    Tabs.MoneyTab = Tabs.MoneySection:Tab({ Title = "刷钱类", Icon = "crown" })
    Tabs.BypassTab = Tabs.MoneySection:Tab({ Title = "绕过类", Icon = "crown" })
    Tabs.ProTab = Tabs.ProSection:Tab({ Title = "防护类", Icon = "crown" })
    Tabs.PlayerTab = Tabs.ConfigSection:Tab({ Title = "通用类", Icon = "crown" })
    Tabs.MMMTab = Tabs.ConfigSection:Tab({ Title = "快捷美化类", Icon = "crown" })
    Tabs.MHTab = Tabs.ConfigSection:Tab({ Title = "自定义美化类", Icon = "crown" })
end


_G.HealthThreshold = 0
_G.BladeAuraEnabled = false

local AutoArmor = false
local autokz = false
local healThread = nil
local AutoKnockReset = false
local antiKBEnabled = false
local sudu = nil
local Speed = 1
local jumpConn = nil
local skinvoid = false
local autoskin = false
local skinsec = ""


local plrs = game:GetService("Players")
local rs = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local lp = plrs.LocalPlayer

local dvv = require(rs.devv)
local sig = dvv.load("Signal")
local guid = dvv.load("GUID")
local inv = dvv.load("v3item").inventory


getgenv().TrailColors = {
    StartColor = Color3.fromRGB(200, 180, 255),
    EndColor = Color3.fromRGB(140, 100, 220),
    MiddleColor1 = Color3.fromRGB(180, 150, 240),
    MiddleColor2 = Color3.fromRGB(160, 130, 230)
}

local function createBeautifulTrail(origin, targetPos)
    local trailContainer = Instance.new("Folder")
    trailContainer.Name = "MagicTrail"
    trailContainer.Parent = Workspace
    
    local midPoint = (origin + targetPos) / 2
    local direction = (targetPos - origin).Unit
    local perpendicular = Vector3.new(-direction.Z, direction.Y, direction.X) * 3
    local controlPoint = midPoint + perpendicular + Vector3.new(0, math.random(-3, 3), 0)
    
    local function createBezierCurve(p0, p1, p2, t)
        return (1 - t)^2 * p0 + 2 * (1 - t) * t * p1 + t^2 * p2
    end
    
    local curvePoints = {}
    local numSegments = 20
    
    for i = 0, numSegments do
        local t = i / numSegments
        local point = createBezierCurve(origin, controlPoint, targetPos, t)
        table.insert(curvePoints, point)
    end
    
    for i = 1, #curvePoints - 1 do
        local startPoint = curvePoints[i]
        local endPoint = curvePoints[i + 1]
        local distance = (endPoint - startPoint).Magnitude
        
        local beamPart = Instance.new("Part")
        beamPart.Size = Vector3.new(0.15, 0.15, distance)
        beamPart.Anchored = true
        beamPart.CanCollide = false
        beamPart.Material = Enum.Material.Neon
        beamPart.Transparency = 0.3
        beamPart.CFrame = CFrame.new(startPoint, endPoint) * CFrame.new(0, 0, -distance / 2)
        beamPart.Parent = trailContainer
        
        local t = i / (#curvePoints - 1)
        local color
        if t < 0.3 then
            color = getgenv().TrailColors.StartColor or Color3.fromRGB(200, 180, 255)
        elseif t < 0.6 then
            color = getgenv().TrailColors.MiddleColor1 or Color3.fromRGB(180, 150, 240)
        elseif t < 0.9 then
            color = getgenv().TrailColors.MiddleColor2 or Color3.fromRGB(160, 130, 230)
        else
            color = getgenv().TrailColors.EndColor or Color3.fromRGB(140, 100, 220)
        end
        
        beamPart.Color = color
        
        local pointLight = Instance.new("PointLight")
        pointLight.Brightness = 5
        pointLight.Range = 3
        pointLight.Color = color
        pointLight.Parent = beamPart
        
        local particles = Instance.new("ParticleEmitter")
        particles.Size = NumberSequence.new(0.1, 0.3)
        particles.Transparency = NumberSequence.new(0.3, 0.8)
        particles.Lifetime = NumberRange.new(0.5, 1)
        particles.Rate = 50
        particles.Speed = NumberRange.new(1, 2)
        particles.VelocitySpread = 180
        particles.Color = ColorSequence.new(color)
        particles.Parent = beamPart
    end
    
    task.delay(1.5, function()
        if trailContainer and trailContainer.Parent then
            trailContainer:Destroy()
        end
    end)
    
    return trailContainer
end


local devv = ReplicatedStorage:WaitForChild("devv")
local load = require(devv).load
local FireServer = load("Signal").FireServer
local InvokeServer = load("Signal").InvokeServer
local GUID = load("GUID")
local Raycast = load("Raycast")
local v3item = load("v3item")
local inventory = v3item.inventory

_G.TargetId = nil
local lastAttack = 0
local lastAmmo = 0

local function getTarget()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local target, dist = nil, 150
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local tHum = plr.Character:FindFirstChildOfClass("Humanoid")
            if tRoot and tHum and tHum.Health >= _G.HealthThreshold then
                local d = (root.Position - tRoot.Position).Magnitude
                if d < dist then
                    dist = d
                    target = plr
                end
            end
        end
    end
    return target
end

local function hackthrow(plr, itemname, itemguid, velocity, epos)
    if plr ~= LocalPlayer then
        return
    end
    task.spawn(function()
        local throwGuid = GUID()
        local char = plr.Character
        if char and char:FindFirstChild("RightHand") then
            local hand = char:FindFirstChild("RightHand")
            createBeautifulTrail(hand.Position, epos)
        end
        
        local success, stickyId = InvokeServer("throwSticky", throwGuid, itemname, itemguid, velocity, epos)
        if not success then
            return
        end
        local dummyPart = Instance.new("Part")
        dummyPart.Size = Vector3.new(2, 2, 2)
        dummyPart.Position = epos
        dummyPart.Anchored = true
        dummyPart.Transparency = 1
        dummyPart.CanCollide = true
        dummyPart.Parent = workspace
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        rayParams.FilterDescendantsInstances = { plr.Character, workspace.Game.Local, workspace.Game.Drones }
        local dist = (epos - plr.Character.Head.Position).Magnitude
        local rayResult = workspace:Raycast(
            plr.Character.Head.Position,
            (epos - plr.Character.Head.Position).Unit * (dist + 5),
            rayParams
        )
        if rayResult and rayResult.Instance then
            local hitPart = rayResult.Instance
            local relativeHitCFrame = hitPart.CFrame:ToObjectSpace(CFrame.new(rayResult.Position, rayResult.Position + rayResult.Normal))
            local stickyCFrame = CFrame.new(rayResult.Position)
            if dummyPart.Parent then
                dummyPart:Destroy()
            end
            _G.throwargs = {
                "hitSticky",
                stickyId or throwGuid,
                hitPart,
                relativeHitCFrame,
                stickyCFrame,
            }
            InvokeServer("hitSticky", stickyId or throwGuid, hitPart, relativeHitCFrame, stickyCFrame)
        else
            if dummyPart.Parent then
                dummyPart:Destroy()
            end
        end
    end)
end

local function getinventory()
    return inventory.items
end

local function finditem(string)
    for guid, data in next, getinventory() do
        if data.name == string or data.type == string or data.subtype == string then
            return data
        end
    end
end

local function executebladekill(plr, head)
    local item = finditem("Tomahawk")
    if item then
        FireServer("equip", item.guid)

        if not _G.throwargs then
            local char = LocalPlayer.Character
            if not char then return end
            local hand = char:FindFirstChild("RightHand")
            if not hand then return end
            
            local spos = hand.Position
            local epos = head.Position
            local velocity = (epos - spos).Unit * ((spos - epos).Magnitude * 15)
            createBeautifulTrail(spos, epos)
            task.spawn(InvokeServer, "attemptPurchaseAmmo", "Tomahawk")
            hackthrow(LocalPlayer, "Tomahawk", item.guid, velocity, epos)
        end

        if _G.throwargs then
            _G.throwargs[3] = head
            task.spawn(InvokeServer, unpack(_G.throwargs))
        end
    else
        task.spawn(InvokeServer, "attemptPurchase", "Tomahawk")
    end
end

local function attack(plr)
    local now = tick()
    if now - lastAttack < 0.03 then return end
    lastAttack = now

    local tChar = plr.Character
    local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
    local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
    if not tRoot or not tHum or tHum.Health < 15 then return end

    task.spawn(function()
        local items = inventory.items or {}
        local banana = nil
        for _, v in next, items do
            if v.name == "Banana Peel" then
                banana = v
                break
            end
        end

        if not banana then
            pcall(function() InvokeServer("attemptPurchase", "Banana Peel") end)
            return
        end

        FireServer("equip", banana.guid)

        local pred = tRoot.AssemblyLinearVelocity * 0.2
        local cf = tRoot.CFrame * CFrame.new(0, -1, 0) + pred
        local rcf = tRoot.CFrame:ToObjectSpace(cf)

        local char = LocalPlayer.Character
        if char and char:FindFirstChild("RightHand") then
            local hand = char:FindFirstChild("RightHand")
            createBeautifulTrail(hand.Position, cf.Position)
        end

        if not _G.TargetId then
            local ok, _, id = pcall(function()
                return InvokeServer("throwSticky", GUID(), "Banana Peel", banana.guid, Vector3.new(0, 100, 0), cf.Position)
            end)
            if ok and id then _G.TargetId = id end
        end

        if _G.TargetId then
            pcall(function()
                InvokeServer("hitSticky", _G.TargetId, tRoot, rcf, cf)
            end)
        end
    end)
end

RunService.Heartbeat:Connect(function()
    if _G.AuraEnabled then
        local target = getTarget()
        if target then
            attack(target)
        end
        
        if tick() - lastAmmo > 0.5 then
            lastAmmo = tick()
            task.spawn(function()
                pcall(function() InvokeServer("attemptPurchaseAmmo", "Banana Peel") end)
            end)
        end
    end
    
    if _G.BladeAuraEnabled and HumanoidRootPart then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local char = plr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local head = char and char:FindFirstChild("Head")
                if head then
                    local dist = (HumanoidRootPart.Position - head.Position).Magnitude
                    if hum and hum.Health > 0 and dist < 190 then
                        executebladekill(plr, head)
                        break
                    end
                end
            end
        end
    end
end)

local autobank = false
local bankTeleportCFrame = CFrame.new(1112.12671, 10.1856346, -324.815613)  
local originalPosition = nil  

local function robBankAndReturn()
    if not autobank then return end
    
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    originalPosition = rootPart.CFrame
    
    rootPart.CFrame = bankTeleportCFrame
    task.wait(0.3)
    
    local maxWait = 15.0
    local startTime = tick()
    while autobank and (tick() - startTime) < maxWait do
        local triggered = false
        pcall(function()
            local bankRobbery = workspace:FindFirstChild("BankRobbery")
            if not bankRobbery then return end
            local bankCash = bankRobbery:FindFirstChild("BankCash")
            local prompt = bankCash and bankCash:FindFirstChild("ProximityPrompt", true)
            if prompt and prompt.Enabled then
                local pos = nil
                local tp = prompt.Parent
                if tp then
                    if tp:IsA("Attachment") then
                        pos = tp.WorldPosition
                    elseif tp:IsA("BasePart") then
                        pos = tp.Position
                    elseif tp:IsA("Model") then
                        local pp = tp.PrimaryPart or tp:FindFirstChildWhichIsA("BasePart")
                        if pp then pos = pp.Position end
                    end
                end
                if pos then
                    rootPart.CFrame = CFrame.new(pos) * CFrame.new(0, 0, 3)
                    task.wait(0.3)
                end
                fireproximityprompt(prompt)
                triggered = true
            end
        end)
        if not triggered then
            task.wait(0.5)
        else
            task.wait(0.3)
        end
    end
    
    if autobank and originalPosition then
        rootPart.CFrame = originalPosition
        task.wait(0.1)
    end
    
    originalPosition = nil
end

local bankThread = nil

local function startBankRobberyLoop()
    if bankThread then return end
    
    bankThread = task.spawn(function()
        while autobank do
            robBankAndReturn()
            task.wait(0.5)
        end
        bankThread = nil
    end)
end

local function stopBankRobberyLoop()
    if bankThread then
        task.cancel(bankThread)
        bankThread = nil
    end
end

Tabs.MoneyTab:Toggle({
    Title = "银行光环",
    Value = false,
    Callback = function(state) 
        autobank = state
        if autobank then
            startBankRobberyLoop()
        else
            stopBankRobberyLoop()
        end
    end
})

local autoATMCashCombo = false

Tabs.MoneyTab:Toggle({
    Title = "ATM农场",
    Default = false,
    Callback = function(Value)
        autoATMCashCombo = Value
        
        if autoATMCashCombo then
            local function collectCash()
                local player = game:GetService("Players").LocalPlayer
                local cashSize = Vector3.new(2, 0.2499999850988388, 1)
                
                for _, part in ipairs(workspace.Game.Entities.CashBundle:GetDescendants()) do
                    if part:IsA("BasePart") and part.Size == cashSize then
                        player.Character.HumanoidRootPart.CFrame = part.CFrame
                        task.wait()
                    end
                end
            end
            
            coroutine.wrap(function()
                while autoATMCashCombo and task.wait() do
                   
                    local ATMsFolder = workspace:FindFirstChild("ATMs")
                    local localPlayer = game:GetService("Players").LocalPlayer
                    local hasActiveATM = false
                    
                    if ATMsFolder and localPlayer.Character then
                        for _, atm in ipairs(ATMsFolder:GetChildren()) do
                            if atm:IsA("Model") then
                                local hp = atm:GetAttribute("health")
                                if hp ~= 0 then
                                    hasActiveATM = true
                                    for _, part in ipairs(atm:GetChildren()) do
                                        if part.Name == "Main" and part:IsA("BasePart") then
                                            localPlayer.Character.HumanoidRootPart.CFrame = part.CFrame
                                            task.wait()
                                            atm:SetAttribute("health", 0)
                                            break
                                        end
                                    end
                                    task.wait()
                                end
                            end
                        end
                    end
                    
                    if hasActiveATM then
                        task.wait(0.1)
                    else
                        collectCash()
                        
                 
                        task.wait()
                    end
                end
            end)()
        end
    end
})

local autoCraftEnabled = false
local autoClaimEnabled = false
local craftConnection

local Signal = require(game:GetService("ReplicatedStorage").devv).load("Signal")

local function performCrafting()
    if autoCraftEnabled then
        Signal.InvokeServer("beginCraft", 'RollieCraft')
    end
    
    if autoClaimEnabled then
        Signal.InvokeServer("claimCraft", 'RollieCraft')
    end
end

game:GetService("RunService").Heartbeat:Connect(function()
    if autoCraftEnabled or autoClaimEnabled then
        performCrafting()
    end
end)

Tabs.BypassTab:Toggle({
    Title = "自动制作萝莉",
    Value = false,
    Callback = function(state)
        autoCraftEnabled = state
    end
})

Tabs.BypassTab:Toggle({
    Title = "自动领取萝莉",
    Value = false,
    Callback = function(state)
        autoClaimEnabled = state
    end
})

Tabs.BypassTab:Button({
    Title = "绕过移动经销商",
    Callback = function()
game:GetService("Players").LocalPlayer:SetAttribute("mobileDealer",true)
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local mobileDealer=require(ReplicatedStorage.devv.shared.Indicies.mobileDealer)

for category,items in pairs(mobileDealer)do 
    for _,item in ipairs(items)do 
        item.stock=999999 
    end 
end

table.insert(mobileDealer.Gun,{itemName="Acid Gun",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Candy Bucket",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Golden Rose",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Black Rose",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Dollar Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Bat Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Bunny Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Clover Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Ghost Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Gold Clover Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Heart Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Skull Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Snowflake Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Admin AK-47",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Admin Nuke Launcher",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Admin RPG",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Void Gem",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Pulse Rifle",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Unusual Money Printer",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Money Printer",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Trident",stock=9999})
table.insert(mobileDealer.Gun,{itemName="NextBot Grenade",stock=9999})
table.insert(mobileDealer.Gun,{itemName="El Fuego",stock=9999})

    end
})

Tabs.BypassTab:Button({
    Title = "绕过高级动作",
    Callback = function()
        for _, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.Emotes.Frame.ScrollingFrame:GetDescendants()) do
            if v.Name == "Locked" then
                v.Visible = false
            end
        end
    end
})

Tabs.BypassTab:Button({
    Title = "绕过飞行封禁",
    Callback = function()
        if game:GetService("ReplicatedStorage"):FindFirstChild("devv"):FindFirstChild("remoteStorage"):FindFirstChild("makeExplosion") then
            game:GetService("ReplicatedStorage"):FindFirstChild("devv"):FindFirstChild("remoteStorage"):FindFirstChild("makeExplosion"):Destroy()
        end
    end
})

Tabs.BypassTab:Button({
    Title = "绕过物品栏封禁",
    Callback = function()
        if game:GetService("ReplicatedStorage"):FindFirstChild("devv"):FindFirstChild("remoteStorage"):FindFirstChild("makeExplosion") then
            game:GetService("ReplicatedStorage"):FindFirstChild("devv"):FindFirstChild("remoteStorage"):FindFirstChild("makeExplosion"):Destroy()
        end
    end
})

Tabs.BypassTab:Button({
    Title = "绕过战斗状态",
    Callback = function()
        for _, func in pairs(getgc(true)) do
            if type(func) == "function" then
                local info = debug.getinfo(func)
                if info.name == "isInCombat" or (info.source and info.source:find("combatIndicator")) then
                    hookfunction(func, function() 
                        return false 
                    end)
                end
            end
        end
    end
})

Tabs.ProTab:Toggle({
    Title = "自动买护甲",
    Default = false,
    Callback = function(Value)
        AutoArmor = Value
        if Value then
            local heartbeat = game:GetService("RunService").Heartbeat
            local connection
            connection = heartbeat:Connect(function()
                if not AutoArmor then
                    connection:Disconnect()
                    return
                end
                
                pcall(function()
                    local player = game:GetService('Players').LocalPlayer
                    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 35 then
                        local b1 = require(game:GetService('ReplicatedStorage').devv).load('v3item').inventory.items
                        local hasLightVest = false
                        
                        for i, v in next, b1 do
                            if v.name == "Light Vest" then
                                hasLightVest = true
                                local light = v.guid
                                local armor = player:GetAttribute('armor')
                                if armor == nil or armor <= 0 then
                                    require(game:GetService("ReplicatedStorage").devv).load("Signal").FireServer("equip", light)
                                    require(game:GetService("ReplicatedStorage").devv).load("Signal").FireServer("useConsumable", light)
                                    require(game:GetService("ReplicatedStorage").devv).load("Signal").FireServer("removeItem", light)
                                end
                                break
                            end
                        end
                        
                        if not hasLightVest then
                            require(game:GetService("ReplicatedStorage").devv).load("Signal").InvokeServer("attemptPurchase", "Light Vest")
                        end
                    end
                end)
            end)
        end
    end
})

Tabs.ProTab:Toggle({
    Title = "自动购买面具",
    Value = false,
    Callback = function(state) 
        autokz = state
        if autokz then
            while autokz and task.wait(1) do
                local player = game:GetService("Players").LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()
                local Mask = character:FindFirstChild("Hockey Mask")
                local Signal = require(game:GetService("ReplicatedStorage").devv).load("Signal")
                local b1 = require(game:GetService('ReplicatedStorage').devv).load('v3item').inventory.items
                if not Mask then
                    Signal.InvokeServer("attemptPurchase", "Hockey Mask")
                    for i, v in next, b1 do
                        if v.name == "Hockey Mask" then
                            local sugid = v.guid
                            if not Mask then
                                Signal.FireServer("equip", sugid)
                                Signal.FireServer("wearMask", sugid)
                            end
                            break
                        end
                    end
                end
            end
        end
    end
})

Tabs.ProTab:Toggle({
    Title = "自动恢复健康值(回血)",
    Default = false,
    Callback = function(Value)
        if healThread then
            healThread:Disconnect()
            healThread = nil
        end

        if Value then
            local heartbeat = game:GetService("RunService").Heartbeat
            healThread = heartbeat:Connect(function()
                Signal.InvokeServer("attemptPurchase", 'Bandage')
                local inv = require(game:GetService('ReplicatedStorage').devv).load('v3item').inventory
                for _, v in next, inv.items do
                    if v.name == 'Bandage' then
                        local bande = v.guid
                        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                        local Humanoid = Character:WaitForChild('Humanoid')
                        if Humanoid.Health >= 5 and Humanoid.Health < Humanoid.MaxHealth then
                            Signal.FireServer("equip", bande)
                            Signal.FireServer("useConsumable", bande)
                            Signal.FireServer("removeItem", bande)
                        end
                        break
                    end
                end
            end)
        end
    end
})

local melee = require(game:GetService("ReplicatedStorage").devv).load("ClientReplicator")
local lp = game:GetService("Players").LocalPlayer

Tabs.ProTab:Toggle({
    Title = "反立",
    Default = false,
    Callback = function(Value)
        AutoKnockReset = Value
        if Value then
            task.spawn(function()
                while AutoKnockReset do
                    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                        melee.Set(lp, "knocked", false)
                        melee.Replicate("knocked")
                    end
                    task.wait()
                end
            end)
        end
    end
})

Tabs.ProTab:Toggle({
    Title = "反击退",
    Default = false,
    Callback = function(Value)
        antiKBEnabled = Value
        task.spawn(function()
            while antiKBEnabled and task.wait(0.1) do
                local character = game:GetService("Players").LocalPlayer.Character
                if character then
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
    end
})

Tabs.PlayerTab:Toggle({
    Title = "walkspend(移速修改)",
    Default = false,
    Callback = function(v)
        if v == true then
            sudu = game:GetService("RunService").Heartbeat:Connect(function()
                if game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character.Humanoid and game:GetService("Players").LocalPlayer.Character.Humanoid.Parent then
                    if game:GetService("Players").LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 then
                        game:GetService("Players").LocalPlayer.Character:TranslateBy(game:GetService("Players").LocalPlayer.Character.Humanoid.MoveDirection * Speed / 10)
                    end
                end
            end)
        elseif not v and sudu then
            sudu:Disconnect()
            sudu = nil
        end
    end
})

Tabs.PlayerTab:Slider({
    Title = "速度设置",
    Value = {
        Min = 1,
        Max = 100,
        Default = 1,
    },
    Callback = function(Value)
        Speed = Value
    end
})

Tabs.PlayerTab:Toggle({
    Title = "无限跳跃",
    Default = false,
    Callback = function(Value)
        local jumpConn
        if Value then
            jumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
                local humanoid = game:GetService("Players").LocalPlayer.Character and
                                 game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if jumpConn then
                jumpConn:Disconnect()
                jumpConn = nil
            end
        end
    end
})

local xeniox = {
    Data = {
        Identity = getidentity()
    },
    Helpers = {}
}

local devv = game:GetService("ReplicatedStorage").devv
local load = require(devv).load

xeniox.Helpers.SetIdentity = function(self, identity)
    setidentity(identity)
end

xeniox.Helpers.CallFuncSec = function(self, func, waited)
    self:SetIdentity(2)
    local result, err = pcall(func)
    if not result then
        warn("函数执行错误:", err)
    end
    if waited then
        task.wait(waited)
    end
    self:SetIdentity(xeniox.Data.Identity)
end

Tabs.MMMTab:Toggle({
    Title = "自动购买气球",
    Value = false,
    Callback = function(state)
        if not state then return end
        
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        if character:FindFirstChild("Balloon") then return end
        
        local Signal = load("Signal")
        Signal.InvokeServer("attemptPurchase", "Balloon")
        
        task.wait(0.5)
        
        local v3item = load("v3item")
        local inventory = v3item.inventory
        local balloonItem = inventory.getFromName("Balloon")
        
        if balloonItem then
            xeniox.Helpers:CallFuncSec(function()
                balloonItem:SetEquipped(true)
            end)
        end
    end
})

Tabs.MMMTab:Button({
    Title = "美化美金(需普通气球)",
    Callback = function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "name") == "Balloon" and rawget(v, "holdableType") == "Balloon" then
                v.name, v.cost, v.unpurchasable, v.multiplier, v.movespeedAdd, v.cannotDiscard = "Dollar Balloon", 200, true, 0.8, 8, true
                if v.TPSOffsets then v.TPSOffsets.hold = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.pi, 0) end
                if v.viewportOffsets and v.viewportOffsets.hotbar then v.viewportOffsets.hotbar.dist = 4 end
                v.canDrop, v.dropCooldown, v.craft = nil
                break
            end
        end

        for _, item in pairs(require(game.ReplicatedStorage.devv.client.Objects.v3item.modules.inventory).items) do
            if item.name == "Dollar Balloon" then
                for _, btn in pairs({item.button, item.backpackButton}) do
                    if btn and btn.resetModelSkin then btn:resetModelSkin() end
                end
            end
        end
    end
})
Tabs.MMMTab:Button({
    Title = "美化黑玫瑰(需普通气球)",
    Callback = function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "name") == "Balloon" and rawget(v, "holdableType") == "Balloon" then
                v.name, v.cost, v.unpurchasable, v.multiplier, v.movespeedAdd, v.cannotDiscard = "Black Rose", 200, true, 0.75, 12, true
                if v.TPSOffsets then v.TPSOffsets.hold = CFrame.new(0, 0.5, 0) end
                if v.viewportOffsets and v.viewportOffsets.hotbar then v.viewportOffsets.hotbar.dist = 3 end
                v.canDrop, v.dropCooldown, v.craft = nil
                break
            end
        end

        for _, item in pairs(require(game.ReplicatedStorage.devv.client.Objects.v3item.modules.inventory).items) do
            if item.name == "Black Rose" then
                for _, btn in pairs({item.button, item.backpackButton}) do
                    if btn and btn.resetModelSkin then btn:resetModelSkin() end
                end
            end
        end
    end
})

Tabs.MMMTab:Button({
Title = "美化Kunai(需普通气球)",
Callback = function()
for _, v in pairs(getgc(true)) do
if type(v) == "table" and rawget(v, "name") == "Balloon" and rawget(v, "holdableType") == "Balloon" then
v.name = "Kunai"
v.permanent = true
v.canDrop = true
v.dropCooldown = 120
v.holdableType = "Balloon"
v.movespeedAdd = 12
if v.TPSOffsets then
v.TPSOffsets.hold = CFrame.new(0, -0.3, 0)
else
v.TPSOffsets = {hold = CFrame.new(0, -0.3, 0)}
end
if v.viewportOffsets then
if v.viewportOffsets.hotbar then
v.viewportOffsets.hotbar.dist = 3
v.viewportOffsets.hotbar.offset = CFrame.new(0, 0, 0)
v.viewportOffsets.hotbar.rotoffset = CFrame.Angles(0, 1.5707963, 0)
else
v.viewportOffsets.hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 1.5707963, 0)}
end
if v.viewportOffsets.ammoHUD then
v.viewportOffsets.ammoHUD.dist = 2
v.viewportOffsets.ammoHUD.offset = CFrame.new(-0.1, -0.2, 0)
v.viewportOffsets.ammoHUD.rotoffset = CFrame.Angles(0, -1.3744468, 0)
else
v.viewportOffsets.ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744468, 0)}
end
if v.viewportOffsets.slotButton then
v.viewportOffsets.slotButton.dist = 1
v.viewportOffsets.slotButton.offset = CFrame.new(-0.1, -0.2, 0)
v.viewportOffsets.slotButton.rotoffset = CFrame.Angles(0, -1.5707963, 0)
else
v.viewportOffsets.slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.5707963, 0)}
end
else
v.viewportOffsets = {
hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 1.5707963, 0)},
ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744468, 0)},
slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.5707963, 0)}
}
end
break
end
end
for _, item in pairs(require(game.ReplicatedStorage.devv.client.Objects.v3item.modules.inventory).items) do
if item.name == "Kunai" then
for _, btn in pairs({item.button, item.backpackButton}) do
if btn and btn.resetModelSkin then btn:resetModelSkin() end
end
end
end
end
})

Tabs.MMMTab:Button({
Title = "美化Spirit Kunai(需普通Kunai)",
Callback = function()
for _, v in pairs(getgc(true)) do
if type(v) == "table" and rawget(v, "name") == "Kunai" and rawget(v, "holdableType") == "Kunai" then
v.name = "Spirit Kunai"
v.permanent = true
v.canDrop = true
v.dropCooldown = 120
v.holdableType = "Kunai"
v.movespeedAdd = 12
if v.TPSOffsets then
v.TPSOffsets.hold = CFrame.new(0, -0.3, 0)
else
v.TPSOffsets = {hold = CFrame.new(0, -0.3, 0)}
end
if v.viewportOffsets then
if v.viewportOffsets.hotbar then
v.viewportOffsets.hotbar.dist = 3
v.viewportOffsets.hotbar.offset = CFrame.new(0, 0, 0)
v.viewportOffsets.hotbar.rotoffset = CFrame.Angles(0, 1.5707963, 0)
else
v.viewportOffsets.hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 1.5707963, 0)}
end
if v.viewportOffsets.ammoHUD then
v.viewportOffsets.ammoHUD.dist = 2
v.viewportOffsets.ammoHUD.offset = CFrame.new(-0.1, -0.2, 0)
v.viewportOffsets.ammoHUD.rotoffset = CFrame.Angles(0, -1.3744468, 0)
else
v.viewportOffsets.ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744468, 0)}
end
if v.viewportOffsets.slotButton then
v.viewportOffsets.slotButton.dist = 1
v.viewportOffsets.slotButton.offset = CFrame.new(-0.1, -0.2, 0)
v.viewportOffsets.slotButton.rotoffset = CFrame.Angles(0, -1.5707963, 0)
else
v.viewportOffsets.slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.5707963, 0)}
end
else
v.viewportOffsets = {
hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 1.5707963, 0)},
ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744468, 0)},
slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.5707963, 0)}
}
end
break
end
end
for _, item in pairs(require(game.ReplicatedStorage.devv.client.Objects.v3item.modules.inventory).items) do
if item.name == "Spirit Kunai" then
for _, btn in pairs({item.button, item.backpackButton}) do
if btn and btn.resetModelSkin then btn:resetModelSkin() end
end
end
end
end
})

Tabs.MMMTab:Toggle({
    Title = "背包枪械美化虚空",
    Value = false,
    Callback = function(start) 
        skinvoid = start
        if skinvoid then
            local it = require(game:GetService("ReplicatedStorage").devv).load("v3item").inventory
            local b1 = require(game:GetService('ReplicatedStorage').devv).load('v3item').inventory.items
            for i, item in next, b1 do 
                if item.type == "Gun" then
                    table.insert(require(game:GetService("ReplicatedStorage").devv.shared.Indicies.skins.bin.Special.Void).compatabilities, item.name)
                    it.skinUpdate(item.name, "Void")
                end
            end
        end
    end
})

Tabs.MMMTab:Toggle({
    Title = "背包枪械美化战术",
    Value = false,
    Callback = function(start) 
        skinvoid = start
        if skinvoid then
            local it = require(game:GetService("ReplicatedStorage").devv).load("v3item").inventory
            local b1 = require(game:GetService('ReplicatedStorage').devv).load('v3item').inventory.items
            for i, item in next, b1 do 
                if item.type == "Gun" then
                    table.insert(require(game:GetService("ReplicatedStorage").devv.shared.Indicies.skins.bin.Special.Void).compatabilities, item.name)
                    it.skinUpdate(item.name, "Tactical")
                end
            end
        end
    end
})

Tabs.MMMTab:Toggle({
    Title = "背包枪械美化赛博",
    Value = false,
    Callback = function(start) 
        skinvoid = start
        if skinvoid then
            local it = require(game:GetService("ReplicatedStorage").devv).load("v3item").inventory
            local b1 = require(game:GetService('ReplicatedStorage').devv).load('v3item').inventory.items
            for i, item in next, b1 do 
                if item.type == "Gun" then
                    table.insert(require(game:GetService("ReplicatedStorage").devv.shared.Indicies.skins.bin.Special.Void).compatabilities, item.name)
                    it.skinUpdate(item.name, "Cyberpunk")
                end
            end
        end
    end
})

Tabs.MMMTab:Toggle({
    Title = "背包枪械美化黑曜石",
    Value = false,
    Callback = function(start) 
        skinvoid = start
        if skinvoid then
            local it = require(game:GetService("ReplicatedStorage").devv).load("v3item").inventory
            local b1 = require(game:GetService('ReplicatedStorage').devv).load('v3item').inventory.items
            for i, item in next, b1 do 
                if item.type == "Gun" then
                    table.insert(require(game:GetService("ReplicatedStorage").devv.shared.Indicies.skins.bin.Special.Void).compatabilities, item.name)
                    it.skinUpdate(item.name, "Obsidian")
                end
            end
        end
    end
})

Tabs.MHTab:Dropdown({
    Title = "选择美化皮肤",
    Values = { 
        "烟火", "虚空", "纯金", "暗物质", "反物质", "神秘", "虚空神秘", "战术", "纯金战术", 
        "白未来", "黑未来", "圣诞未来", "礼物包装", "猩红", "收割者", "虚空收割者", "圣诞玩具",
        "荒地", "隐形", "像素", "钻石像素", "黄金零下", "绿水晶", "生物", "樱花", "精英", 
        "黑樱花", "彩虹激光", "蓝水晶", "紫水晶", "红水晶", "零下", "虚空射线", "冰冻钻石",
        "虚空梦魇", "金雪", "爱国者", "MM2", "声望", "酷化", "蒸汽", "海盗", "玫瑰", "黑玫瑰",
        "激光", "烟花", "诅咒背瓜", "大炮", "财富", "黄金大炮", "四叶草", "自由", "黑曜石", "赛博朋克"
    },
    Callback = function(Value) 
        if Value == "烟火" then
            skinsec = "Sparkler"
        elseif Value == "虚空" then
            skinsec = "Void"
        elseif Value == "纯金" then
            skinsec = "Solid Gold"
        elseif Value == "暗物质" then
            skinsec = "Dark Matter"
        elseif Value == "反物质" then
            skinsec = "Anti Matter"
        elseif Value == "神秘" then
            skinsec = "Hystic"
        elseif Value == "虚空神秘" then
            skinsec = "Void Mystic"
        elseif Value == "战术" then
            skinsec = "Tactical"
        elseif Value == "纯金战术" then
            skinsec = "Solid Gold Tactical"
        elseif Value == "白未来" then
            skinsec = "Future White"
        elseif Value == "黑未来" then
            skinsec = "Future Black"
        elseif Value == "圣诞未来" then
            skinsec = "Christmas Future"
        elseif Value == "礼物包装" then
            skinsec = "Gift Wrapped"
        elseif Value == "猩红" then
            skinsec = "Crimson Blood"
        elseif Value == "收割者" then
            skinsec = "Reaper"
        elseif Value == "虚空收割者" then
            skinsec = "Void Reaper"
        elseif Value == "圣诞玩具" then
            skinsec = "Christmas Toy"
        elseif Value == "荒地" then
            skinsec = "Wasteland"
        elseif Value == "隐形" then
            skinsec = "Invisible"
        elseif Value == "像素" then
            skinsec = "Pixel"
        elseif Value == "钻石像素" then
            skinsec = "Diamond Pixel"
        elseif Value == "黄金零下" then
            skinsec = "Frozen-Gold"
        elseif Value == "绿水晶" then
            skinsec = "Atomic Nature"
        elseif Value == "生物" then
            skinsec = "Biohazard"
        elseif Value == "樱花" then
            skinsec = "Sakura"
        elseif Value == "精英" then
            skinsec = "Elite"
        elseif Value == "黑樱花" then
            skinsec = "Death Blossom-Gold"
        elseif Value == "彩虹激光" then
            skinsec = "Rainbowlaser"
        elseif Value == "蓝水晶" then
            skinsec = "Atomic Water"
        elseif Value == "紫水晶" then
            skinsec = "Atomic Amethyst"
        elseif Value == "红水晶" then
            skinsec = "Atomic Flame"
        elseif Value == "零下" then
            skinsec = "Sub-Zero"
        elseif Value == "虚空射线" then
            skinsec = "Void-Ray"
        elseif Value == "冰冻钻石" then
            skinsec = "Frozen Diamond"
        elseif Value == "虚空梦魇" then
            skinsec = "Void Nightmare"
        elseif Value == "金雪" then
            skinsec = "Golden Snow"
        elseif Value == "爱国者" then
            skinsec = "Patriot"
        elseif Value == "MM2" then
            skinsec = "MM2 Barrett"
        elseif Value == "声望" then
            skinsec = "Prestige Barnett"
        elseif Value == "酷化" then
            skinsec = "Skin Walter"
        elseif Value == "蒸汽" then
            skinsec = "Steampunk"
        elseif Value == "海盗" then
            skinsec = "Pirate"
        elseif Value == "玫瑰" then
            skinsec = "Rose"
        elseif Value == "黑玫瑰" then
            skinsec = "Black Rose"
        elseif Value == "激光" then
            skinsec = "Hyperlaser"
        elseif Value == "烟花" then
            skinsec = "Firework"
        elseif Value == "诅咒背瓜" then
            skinsec = "Cursed Pumpkin"
        elseif Value == "大炮" then
            skinsec = "Cannon"
        elseif Value == "财富" then
            skinsec = "Firework"
        elseif Value == "黄金大炮" then
            skinsec = "Gold Cannon"
        elseif Value == "四叶草" then
            skinsec = "Lucky Clover"
        elseif Value == "自由" then
            skinsec = "Freedom"
        elseif Value == "黑曜石" then
            skinsec = "Obsidian"
        elseif Value == "赛博朋克" then
            skinsec = "Cyberpunk"
        end
    end
})
Tabs.MHTab:Toggle({
    Title = "全部枪械美化",
    Value = false,
    Callback = function(start) 
        autoskin = start
        if autoskin then
            local it = require(game:GetService("ReplicatedStorage").devv).load("v3item").inventory
            local b1 = require(game:GetService('ReplicatedStorage').devv).load('v3item').inventory.items
            for i, item in next, b1 do 
                if item.type == "Gun" then
                    it.skinUpdate(item.name, skinsec)
                end
            end
        end
    end
})

local items = {
    "Golden Rose", "Black Rose", "Dollar Balloon", "Bat Balloon", "Bunny Balloon", "Clover Balloon",
    "Ghost Balloon", "Gold Clover Balloon", "Heart Balloon", "Skull Balloon", "Snowflake Balloon",
    "Admin AK-47", "Admin Nuke Launcher", "Admin RPG", "Void Gem", "Pulse Rifle", "Unusual Money Printer",
    "Money Printer", "Trident", "NextBot Grenade", "El Fuego", "Kunai", "Spirit Kunai"
}
local itemDisplayNames = {
    ["Golden Rose"] = "金玫瑰", ["Black Rose"] = "黑玫瑰", ["Dollar Balloon"] = "美元气球",
    ["Bat Balloon"] = "蝙蝠气球", ["Bunny Balloon"] = "兔子气球", ["Clover Balloon"] = "三叶草气球",
    ["Ghost Balloon"] = "幽灵气球", ["Gold Clover Balloon"] = "金三叶草气球", ["Heart Balloon"] = "爱心气球",
    ["Skull Balloon"] = "骷髅气球", ["Snowflake Balloon"] = "雪花气球", ["Admin AK-47"] = "管理员黄金AK-47",
    ["Admin Nuke Launcher"] = "管理员核弹发射器", ["Admin RPG"] = "管理员RPG", ["Void Gem"] = "虚空宝石",
    ["Pulse Rifle"] = "脉冲步枪", ["Unusual Money Printer"] = "异常印钞机", ["Money Printer"] = "印钞机",
    ["Trident"] = "三叉戟", ["NextBot Grenade"] = "NextBot手榴弹", ["El Fuego"] = "烈焰喷射器",
    ["Kunai"] = "苦无", ["Spirit Kunai"] = "灵魂苦无"
}
local itemData = {}

itemData["Bat Balloon"] = {name = "Bat Balloon", cost = 0, unpurchasable = true, multiplier = 0.625, holdableType = "Balloon", canDrop = true, dropCooldown = 120, permanent = true, TPSOffsets = {hold = CFrame.new(0, 0, 0)}, viewportOffsets = {hotbar = {dist = 5.5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, math.pi, 0)}, ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}}}
itemData["Bunny Balloon"] = {name = "Bunny Balloon", cost = 0, unpurchasable = true, multiplier = 0.61, holdableType = "Balloon", canDrop = true, dropCooldown = 120, permanent = true, TPSOffsets = {hold = CFrame.new(0, 0, 0)}, viewportOffsets = {hotbar = {dist = 4.75, offset = CFrame.new(0, -0.25, 0), rotoffset = CFrame.Angles(0, 4.71238898038469, 0)}, ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}}}
itemData["Clover Balloon"] = {name = "Clover Balloon", cost = 200, unpurchasable = true, multiplier = 0.625, holdableType = "Balloon", canDrop = true, dropCooldown = 120, permanent = true, TPSOffsets = {hold = CFrame.new(0, 0, 0)}, viewportOffsets = {hotbar = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}, ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}}}
itemData["Ghost Balloon"] = {name = "Ghost Balloon", cost = 0, unpurchasable = true, multiplier = 0.625, holdableType = "Balloon", canDrop = true, dropCooldown = 120, permanent = true, TPSOffsets = {hold = CFrame.new(0, 0, 0)}, viewportOffsets = {hotbar = {dist = 3.5, offset = CFrame.new(0, 0.5, 0), rotoffset = CFrame.Angles(0, math.pi, 0)}, ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}}}
itemData["Gold Clover Balloon"] = {name = "Gold Clover Balloon", cost = 250000, unpurchasable = true, multiplier = 0.6, holdableType = "Balloon", canDrop = true, dropCooldown = 120, permanent = true, TPSOffsets = {hold = CFrame.new(0, 0, 0)}, viewportOffsets = {hotbar = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}, ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}}}
itemData["Heart Balloon"] = {name = "Heart Balloon", cost = 200, multiplier = 0.6, holdableType = "Balloon", unpurchasable = true, canDrop = true, dropCooldown = 120, permanent = true, TPSOffsets = {hold = CFrame.new(0, 0, 0)}, viewportOffsets = {hotbar = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}, ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}}}
itemData["Skull Balloon"] = {name = "Skull Balloon", cost = 0, unpurchasable = true, multiplier = 0.625, holdableType = "Balloon", canDrop = true, dropCooldown = 120, permanent = true, TPSOffsets = {hold = CFrame.new(0, 0, 0)}, viewportOffsets = {hotbar = {dist = 5.5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, -270, 0)}, ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}}}
itemData["Snowflake Balloon"] = {name = "Snowflake Balloon", cost = 0, unpurchasable = true, multiplier = 0.625, holdableType = "Balloon", canDrop = true, dropCooldown = 120, permanent = true, TPSOffsets = {hold = CFrame.new(0, 0, 0)}, viewportOffsets = {hotbar = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, (math.pi/2), 0)}, ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}}}
itemData["Golden Rose"] = {name = "Golden Rose", guid = "golden_rose_"..tostring(tick()), permanent = true, canDrop = true, dropCooldown = 120, multiplier = 0.625, holdableType = "Balloon", movespeedAdd = 5, TPSOffsets = {hold = CFrame.new(0, 0.5, 0)}, viewportOffsets = {hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, (math.pi/2), 0)}, ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744467859455345, 0)}, slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, (-math.pi/2), 0)}}}
itemData["Black Rose"] = {name = "Black Rose", guid = "black_rose_"..tostring(tick()), permanent = true, canDrop = true, dropCooldown = 120, multiplier = 0.75, holdableType = "Balloon", movespeedAdd = 12, TPSOffsets = {hold = CFrame.new(0, 0.5, 0)}, viewportOffsets = {hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, (math.pi/2), 0)}, ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744467859455345, 0)}, slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, (-math.pi/2), 0)}}}
itemData["Dollar Balloon"] = {name = "Dollar Balloon", cost = 100000000000, unpurchasable = true, multiplier = 0.8, holdableType = "Balloon", movespeedAdd = 8, cannotDiscard = true, TPSOffsets = {hold = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.pi, 0)}, viewportOffsets = {hotbar = {dist = 4, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}, ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}}}
itemData["Admin AK-47"] = {name = "Admin AK-47", modelName = "Gold AK-47", subtype = "AK-47", adminOnly = true, canDrop = false, unpurchasable = true, damage = 10, ammo = 999999999, startAmmo = -1, maxAmmo = -1, firemode = "auto", numProjectiles = 8, fireDebounce = 0.01}
itemData["Admin Nuke Launcher"] = {name = "Admin Nuke Launcher", modelName = "Nuke Launcher", subtype = "Nuke Launcher", adminOnly = true, canDrop = false, unpurchasable = true, ammo = 99999999, startAmmo = -1, maxAmmo = -1, overrideProjectileProperties = {disableNukeFlash = true}, reloadTime = 0, reloadType = "mag", firemode = "auto", numProjectiles = 1, fireDebounce = 0.2}
itemData["Admin RPG"] = {canDrop = false, unpurchasable = true, name = "Admin RPG", modelName = "RPG", subtype = "RPG", adminOnly = true, ammo = 99999999, startAmmo = -1, maxAmmo = -1, reloadTime = 0, reloadType = "mag", firemode = "auto", numProjectiles = 1, fireDebounce = 0.02, recoilAdd = 0, maxRecoil = 0, recoilDiminishFactor = 0, recoilFastDiminishFactor = 0}
itemData["Void Gem"] = {name = "Void Gem", subtype = "gem", maxAmmo = 3, adminLimit = 1, sellPrice = 25000, canDrop = true, dropCooldown = 300}
itemData["Pulse Rifle"] = {name = "Pulse Rifle", subtype = "Raygun", unpurchasable = true, damage = 22, headshotMultiplier = 1.5, ammo = 50, startAmmo = -1, maxAmmo = -1, reloadTime = 3.5, reloadType = "mag", firemode = "auto", numProjectiles = 1, fireDebounce = 0.04, projectileLength = 20, projectileLifetime = 200, speedDropoff = 0.04, speedMax = 5, baseSpread = 3, baseAimSpread = 0.8, spread = 11, aimSpread = 2.4, recoilAdd = 0.05, maxRecoil = 0.4, recoilDiminishFactor = 0.95, recoilFastDiminishFactor = 0.85}
itemData["Unusual Money Printer"] = {name = "Unusual Money Printer", cost = 500, ammo = 1, startAmmo = -1, maxAmmo = 1, hint = {computer = "Click to Place", console = "Click to Place"}, canDrop = true, dropCooldown = 600, isConsumable = true, TPSOffsets = {hold = CFrame.new(-0.1, 0, -0.75) * CFrame.Angles(0, 0, 0)}, viewportOffsets = {hotbar = {dist = 5, offset = CFrame.new(0, 0.15, 0), rotoffset = CFrame.Angles(0, (-math.pi/2), 0)}, ammoHUD = {dist = 3.25, offset = CFrame.new(0, 1, 0), rotoffset = CFrame.Angles(0, (math.pi/2), 0)}}}
itemData["Money Printer"] = {name = "Money Printer", ammo = 1, startAmmo = -1, maxAmmo = 1, adminLimit = 10, hint = {computer = "Click to Place", console = "Click to Place"}, canDrop = true, dropCooldown = 600, isConsumable = true, permanent = true, TPSOffsets = {hold = CFrame.new(-0.1, 0, -0.75) * CFrame.Angles(0, 0, 0)}, viewportOffsets = {hotbar = {dist = 5, offset = CFrame.new(0, 0.15, 0), rotoffset = CFrame.Angles(0, (-math.pi/2), 0)}, ammoHUD = {dist = 3.25, offset = CFrame.new(0, 1, 0), rotoffset = CFrame.Angles(0, (-math.pi/2), 0)}}}
itemData["Trident"] = {name = "Trident", subtype = "RPG", unpurchasable = true, ammo = 1, startAmmo = 12, maxAmmo = 12, firemode = "semi", numProjectiles = 3, fireDebounce = 0.5, projectileLength = 4, projectileLifetime = 1000, speedDropoff = 0.04, speedMax = 5, baseSpread = 5, baseAimSpread = 1, spread = 10, aimSpread = 6, recoilAdd = 1, maxRecoil = 1.25, recoilDiminishFactor = 0.9, recoilFastDiminishFactor = 0.66}
itemData["NextBot Grenade"] = {name = "NextBot Grenade", isNade = true, bounceSFX = "nadeBounce", canDrop = true, dropCooldown = 600, thrownOffset = CFrame.Angles(0, (math.pi/2), 0), ammo = 1, startAmmo = -1, maxAmmo = 1, permanent = true, throwDist = 50, TPSOffsets = {hold = CFrame.new(-0.1, 0.25, -0.125)}, viewportOffsets = {hotbar = {dist = 2.75, offset = CFrame.new(0, -0.125, 0), rotoffset = CFrame.Angles(0, 1.8849555921538759, 0)}, ammoHUD = {dist = 2, offset = CFrame.new(0, 0.1, 0), rotoffset = CFrame.Angles(0, (math.pi/2), 0)}}}
itemData["El Fuego"] = {name = "El Fuego", modelName = "El Fuego", subtype = "Flamethrower", unpurchasable = true, ammo = 600, startAmmo = 0, maxAmmo = 600, reloadTime = 6, reloadType = "mag", firemode = "auto", damage = 6, numProjectiles = 3, fireDebounce = 0.05, projectileLength = 4, projectileLifetime = 60, speedDropoff = 0.04, speedMax = 5, baseSpread = 4, baseAimSpread = 2, spread = 12, aimSpread = 6, recoilAdd = 0.1, maxRecoil = 1, recoilDiminishFactor = 0.95, recoilFastDiminishFactor = 0.8}
itemData["Kunai"] = {name = "Kunai", permanent = true, canDrop = true, dropCooldown = 120, holdableType = "Kunai", movespeedAdd = 12, TPSOffsets = {hold = CFrame.new(0, -0.3, 0)}, viewportOffsets = {hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 1.5707963, 0)}, ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744468, 0)}, slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.5707963, 0)}}}
itemData["Spirit Kunai"] = {name = "Spirit Kunai", permanent = true, canDrop = true, dropCooldown = 120, holdableType = "Kunai", movespeedAdd = 12, TPSOffsets = {hold = CFrame.new(0, -0.3, 0)}, viewportOffsets = {hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 1.5707963, 0)}, ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744468, 0)}, slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.5707963, 0)}}}

local function getItemList()
    local itemList = {}
    for _, itemName in ipairs(items) do
        local displayName = itemDisplayNames[itemName] or itemName
        table.insert(itemList, displayName)
    end
    return itemList
end

local selectedItem = ""
Tabs.MHTab:Dropdown({
    Title = "选择物品",
    Desc = "从列表中选择要获得的物品",
    Values = getItemList(),
    Value = "",
    Callback = function(value)
        if value and value ~= "" then
            selectedItem = value
        else
            selectedItem = ""
        end
    end
})

local function getItemNameByDisplayName(displayName)
    for itemName, dispName in pairs(itemDisplayNames) do
        if dispName == displayName then return itemName end
    end
    return displayName
end

local function addItem(itemName)
    pcall(function()
        local itemSystem = require(ReplicatedStorage.devv).load("v3item")
        local inventory = itemSystem.inventory
        if not itemData[itemName] then return end
        local itemConfig = itemData[itemName]
        local itemToAdd = {
            name = itemConfig.name,
            guid = itemName:lower():gsub(" ", "_").."_"..tostring(tick()),
            permanent = itemConfig.permanent or true,
            canDrop = itemConfig.canDrop or true,
            dropCooldown = itemConfig.dropCooldown or 120,
            multiplier = itemConfig.multiplier or 0.625,
            holdableType = itemConfig.holdableType or "Balloon",
            movespeedAdd = itemConfig.movespeedAdd or 0,
            cannotDiscard = itemConfig.cannotDiscard or false,
            TPSOffsets = itemConfig.TPSOffsets or {hold = CFrame.new(0, 0.5, 0)},
            viewportOffsets = itemConfig.viewportOffsets or {
                hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, (math.pi/2), 0)},
                ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744467859455345, 0)},
                slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, (-math.pi/2), 0)}
            }
        }
        if itemConfig.subtype then itemToAdd.subtype = itemConfig.subtype end
        if itemConfig.modelName then itemToAdd.modelName = itemConfig.modelName end
        if itemConfig.adminOnly then itemToAdd.adminOnly = itemConfig.adminOnly end
        if itemConfig.damage then itemToAdd.damage = itemConfig.damage end
        if itemConfig.ammo then itemToAdd.ammo = itemConfig.ammo end
        if itemConfig.startAmmo then itemToAdd.startAmmo = itemConfig.startAmmo end
        if itemConfig.maxAmmo then itemToAdd.maxAmmo = itemConfig.maxAmmo end
        if itemConfig.reloadTime then itemToAdd.reloadTime = itemConfig.reloadTime end
        if itemConfig.reloadType then itemToAdd.reloadType = itemConfig.reloadType end
        if itemConfig.firemode then itemToAdd.firemode = itemConfig.firemode end
        if itemConfig.numProjectiles then itemToAdd.numProjectiles = itemConfig.numProjectiles end
        if itemConfig.fireDebounce then itemToAdd.fireDebounce = itemConfig.fireDebounce end
        if itemConfig.projectileLength then itemToAdd.projectileLength = itemConfig.projectileLength end
        if itemConfig.projectileLifetime then itemToAdd.projectileLifetime = itemConfig.projectileLifetime end
        if itemConfig.headshotMultiplier then itemToAdd.headshotMultiplier = itemConfig.headshotMultiplier end
        if itemConfig.hint then itemToAdd.hint = itemConfig.hint end
        if itemConfig.isConsumable then itemToAdd.isConsumable = itemConfig.isConsumable end
        if itemConfig.isNade then itemToAdd.isNade = itemConfig.isNade end
        if itemConfig.throwDist then itemToAdd.throwDist = itemConfig.throwDist end
        if itemConfig.sellPrice then itemToAdd.sellPrice = itemConfig.sellPrice end
        if itemConfig.adminLimit then itemToAdd.adminLimit = itemConfig.adminLimit end
        if itemConfig.overrideProjectileProperties then itemToAdd.overrideProjectileProperties = itemConfig.overrideProjectileProperties end
        if itemConfig.recoilAdd then itemToAdd.recoilAdd = itemConfig.recoilAdd end
        if itemConfig.maxRecoil then itemToAdd.maxRecoil = itemConfig.maxRecoil end
        if itemConfig.recoilDiminishFactor then itemToAdd.recoilDiminishFactor = itemConfig.recoilDiminishFactor end
        if itemConfig.recoilFastDiminishFactor then itemToAdd.recoilFastDiminishFactor = itemConfig.recoilFastDiminishFactor end
        if inventory.add then
            inventory.add(itemToAdd, false)
            if inventory.currentItemsData then
                table.insert(inventory.currentItemsData, itemToAdd)
            end
        end
        if inventory.rerender then
            inventory:rerender()
        end
    end)
end

Tabs.MHTab:Button({
    Title = "免费获得选择的物品",
    Callback = function()
        if selectedItem and selectedItem ~= "" then
            local itemName = getItemNameByDisplayName(selectedItem)
            if itemName then
                addItem(itemName)
            end
        end
    end
})

local newFeatureTab = _G.XA_Window and _G.XA_Window:AddTab({ Title = "新功能", Icon = "star" })
local function nfAddToggle(key, opts)
    if newFeatureTab and newFeatureTab.AddToggle then return newFeatureTab:AddToggle(key, opts) end
    return nil
end
local function nfAddSection(title)
    if newFeatureTab and newFeatureTab.AddSection then newFeatureTab:AddSection(title) end
end
local function nfAddSlider(key, opts)
    if newFeatureTab and newFeatureTab.AddSlider then return newFeatureTab:AddSlider(key, opts) end
    return nil
end

local bulletTrackOn = false
local trackFov = 60
local trackMaxDist = 5000

local function findTrackTarget()
    local lpChar = LocalPlayer.Character
    local root = lpChar and lpChar:FindFirstChild("HumanoidRootPart")
    local cam = workspace.CurrentCamera
    if not root or not cam then return nil end
    local viewport = cam.ViewportSize
    local center = viewport / 2
    local radius = math.clamp(trackFov / 180, 0.02, 1) * 900 + 8
    local best, bestScore = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if p.Character:FindFirstChild("ForceField") then continue end
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                local d = (head.Position - root.Position).Magnitude
                if d <= trackMaxDist then
                    local sp, onscreen = cam:WorldToViewportPoint(head.Position)
                    if onscreen then
                        local screenDist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if screenDist <= radius then
                            local score = screenDist * 100000 + d
                            if score < bestScore then
                                bestScore = score
                                best = head
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

local projMod = v3item.projectiles
if projMod and projMod.newProjectileOfType then
    local oldNew = projMod.newProjectileOfType
    projMod.newProjectileOfType = function(projType, props)
        if bulletTrackOn and props and props.isPlayerOwned and props.cframe then
            pcall(function()
                local t = findTrackTarget()
                if t then
                    props.cframe = CFrame.new(props.cframe.Position, t.Position)
                end
            end)
        end
        return oldNew(projType, props)
    end
end

local sigMod = load("Signal")
local sigFireFn = sigMod and sigMod.FireServer
if type(sigFireFn) == "function" then
    local oldFire = nil
    oldFire = hookfunction(sigFireFn, function(...)
        if bulletTrackOn then
            local name = ...
            local args = { ... }
            pcall(function()
                if name == "replicateProjectiles" then
                    local t = findTrackTarget()
                    if t then
                        local shots = args[2]
                        if type(shots) == "table" then
                            for _, s in ipairs(shots) do
                                if type(s) == "table" and s[2] and typeof(s[2]) == "CFrame" then
                                    s[2] = CFrame.new(s[2].Position, t.Position)
                                end
                            end
                        end
                    end
                end
            end)
        end
        if oldFire then
            return oldFire(...)
        end
        return nil
    end)
    if not oldFire then
        oldFire = hookfunction(sigFireFn, function(...)
            if oldFire then return oldFire(...) end
            return nil
        end)
        print("[Track] Signal 二次安装:", oldFire ~= nil)
    end
end

local rayHelper = load("Raycast")
if type(rayHelper) == "function" then
    local oldRay = nil
    oldRay = hookfunction(rayHelper, function(origin, direction, params)
        if bulletTrackOn and origin and direction then
            local ok, res = pcall(function()
                local lpChar = LocalPlayer.Character
                local root = lpChar and lpChar:FindFirstChild("HumanoidRootPart")
                if root and (origin - root.Position).Magnitude <= 200 and direction.Magnitude > 0 and direction.Magnitude <= 60 then
                    local t = findTrackTarget()
                    if t then
                        return {
                            Instance = t,
                            Position = t.Position,
                            Normal = Vector3.new(0, 1, 0),
                            Material = Enum.Material.SmoothPlastic
                        }
                    end
                end
                return nil
            end)
            if ok and res then
                return res
            end
        end
        if oldRay then
            return oldRay(origin, direction, params)
        end
        return nil
    end)
    if not oldRay then
        oldRay = hookfunction(rayHelper, function(origin, direction, params)
            if oldRay then return oldRay(origin, direction, params) end
            return nil
        end)
        print("[Track] Raycast 二次安装:", oldRay ~= nil)
    end
end

local fovCircle = nil
pcall(function()
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1.2
    fovCircle.Color = Color3.fromRGB(0, 255, 120)
    fovCircle.Transparency = 0.7
    fovCircle.Visible = false
end)
task.spawn(function()
    while true do
        task.wait(0.05)
        if fovCircle then
            fovCircle.Visible = bulletTrackOn
            if bulletTrackOn then
                local cam = workspace.CurrentCamera
                if cam then
                    fovCircle.Position = cam.ViewportSize / 2
                    fovCircle.Radius = math.clamp(trackFov / 180, 0.02, 1) * 900 + 8
                end
            end
        end
    end
end)

nfAddSection("子追")
nfAddToggle("BulletTrack", {
    Title = "子追(穿墙全图)",
    Default = false,
    Callback = function(val) bulletTrackOn = val end
})
nfAddSlider("TrackFov", {
    Title = "子追 FOV(度)",
    Min = 5, Max = 360, Default = 60, Rounding = 1,
    Callback = function(v) trackFov = v end
})
nfAddSlider("TrackDist", {
    Title = "子追最大距离",
    Min = 50, Max = 5000, Default = 300, Rounding = 1,
    Callback = function(v) trackMaxDist = v end
})

local rateOn = false
local rateVal = 0.1
nfAddSection("射速")
nfAddToggle("FireRate", {
    Title = "射速修改",
    Default = false,
    Callback = function(val) rateOn = val end
})
nfAddSlider("RateVal", {
    Title = "射速间隔(秒/发)",
    Min = 0.01, Max = 1, Default = 0.1, Rounding = 0.01,
    Callback = function(v) rateVal = v end
})

task.spawn(function()
    while true do
        task.wait(0.3)
        pcall(function()
            if rateOn then
                for _, it in pairs(v3item.inventory.items or {}) do
                    if type(it) == "table" and it.fireDebounce then
                        it.fireDebounce = rateVal
                    end
                end
                for _, it in pairs(v3item.inventory.currentItemsData or {}) do
                    if type(it) == "table" and it.fireDebounce then
                        it.fireDebounce = rateVal
                    end
                end
            end
        end)
    end
end)

]====]},
{Name = "圣奥里", Code = [[getgenv().XiaoPi="皮脚本-圣奥里"; loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/refs/heads/main/Roblox-Pi-Script-SaintOrie.lua"))()]]},
{Name = "圣地亚哥角色扮演(刷钱)", Url = "https://paste.dot.com.in/p/csolyxih65/raw"},
{Name = "河北唐县", Code = [[getgenv().XiaoPi="皮脚本-河北唐县"; loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/refs/heads/main/PIJIAOBEN-HEBEITANGXIAN.lua"))()]]},
{Name = "恶名昭彰收获日体验", Code = [[loadstring(game:HttpGet("https://rawscripts.net/raw/Notoriety:-A-PAYDAY(r)-Experience-XXMZ-HUB-177374"))()]]},
        {Name = "圣奥里-恐脚本", Url = "https://raw.githubusercontent.com/dish-rr/DB-Script/master/%E5%9C%A3%E5%A5%A5%E9%87%8C-%E6%81%90%E8%84%9A%E6%9C%AC.lua"}
},
["休闲挂机"] = {
{Name = "偷走一个蛋｜群友：搁浅(小号) 投稿", Url = "https://raw.githubusercontent.com/kaisenlmao/loader/refs/heads/main/chiyo.lua"},
{Name = "踢一个幸运方块", Url = "https://raw.githubusercontent.com/fartez127-design/FARTEZHUB/refs/heads/main/FARTEZHUBXKickaLuckyBlock"},
{Name = "偷一个蛋", Code = [[loadstring(game:HttpGet("https://solixhub.com/loader"))()]]},
{Name = "重型钓鱼(脚本不能用看群公告)", Code = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/linni-fish/HeavyFishing/main/Fishing.lua"))()]]},
        {
            Name = "偷一个蛋--天休制作",
            Code = [=====[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

if not game:IsLoaded() then game.Loaded:Wait() end

pcall(function()
	local pg = lp:WaitForChild("PlayerGui", 5)
	if pg then
		local old = pg:FindFirstChild("TX_Egg_Panel")
		if old then old:Destroy() end
	end
end)

local S = {
	speedOn = false, speedMult = 50,
	stealOn = false, hatchOn = false, collectOn = false,
	espOn = false, showNames = true, showDist = true,
	byPrice = false,
	rarities = {},
}

local RarityZh = { "神圣", "永恒", "秘密", "宇宙", "神话", "传说", "史诗", "稀有", "罕见", "普通" }
local RarityEn = { "Divine", "Eternal", "Secret", "Cosmic", "Mythic", "Legendary", "Epic", "Rare", "Uncommon", "Common" }

local H = game:GetService("HttpService")
local CFG_FILE = "tianxiu_egg_cfg.txt"
local function saveCfg()
	pcall(function()
		writefile(CFG_FILE, H:JSONEncode({
			speedOn = S.speedOn,
			speedMult = S.speedMult,
			stealOn = S.stealOn,
			byPrice = S.byPrice,
			hatchOn = S.hatchOn,
			collectOn = S.collectOn,
			espOn = S.espOn,
			showNames = S.showNames,
			showDist = S.showDist,
			rarities = S.rarities,
		}))
	end)
end
local function loadCfg()
	pcall(function()
		if not isfile(CFG_FILE) then return end
		local d = H:JSONDecode(readfile(CFG_FILE))
		if type(d) == "table" then
			if type(d.speedOn) == "boolean" then S.speedOn = d.speedOn end
			if type(d.speedMult) == "number" then S.speedMult = d.speedMult end
			if type(d.stealOn) == "boolean" then S.stealOn = d.stealOn end
			if type(d.byPrice) == "boolean" then S.byPrice = d.byPrice end
			if type(d.hatchOn) == "boolean" then S.hatchOn = d.hatchOn end
			if type(d.collectOn) == "boolean" then S.collectOn = d.collectOn end
			if type(d.espOn) == "boolean" then S.espOn = d.espOn end
			if type(d.showNames) == "boolean" then S.showNames = d.showNames end
			if type(d.showDist) == "boolean" then S.showDist = d.showDist end
			if type(d.rarities) == "table" then S.rarities = d.rarities end
		end
	end)
end

local EggState = nil
pcall(function() EggState = require(ReplicatedStorage.Client.EggState) end)

local function getChar() return lp.Character end
local function getHRP()
	local c = getChar()
	return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
	local c = getChar()
	return c and c:FindFirstChildOfClass("Humanoid")
end

local state = nil
local function findAC()
	if state then return true end
	local gc = getgc()
	for i, fn in ipairs(gc) do
		if type(fn) == "function" then
			local ok, inf = pcall(getinfo, fn)
			local src = ok and inf and tostring(inf.source) or ""
			if src:find("ContentCatalog", 1, true) then
				local ok2, consts = pcall(getconstants, fn)
				if ok2 and consts then
					local hasWS = false
					for _, c in ipairs(consts) do
						if type(c) == "string" and c == "WalkSpeed" then hasWS = true break end
					end
					if hasWS then
						local ok3, uv = pcall(getupvalues, fn)
						if ok3 and uv and type(uv[1]) == "table" and uv[1].ThreatLevel then
							state = uv[1]
							return true
						end
					end
				end
			end
		end
	end
	return false
end
local function applyBypass()
	if not findAC() then return false end
	pcall(function()
		setreadonly(state, false)
		state.ThreatLevel = "low"
		state.Evidence = {}
		state.Allowances = {}
		state.ContinuousAllowances = {}
		state.LastCorrectionAt = math.huge
	end)
	return true
end
pcall(function()
	for _, conn in ipairs(getconnections(lp.Idled)) do
		pcall(function() conn:Disable() end)
	end
end)
task.spawn(function()
	while true do
		task.wait(30)
		pcall(function()
			require(ReplicatedStorage.Shared.Remotes).Telemetry.SubmitIdleState:FireServer(false)
		end)
	end
end)
task.spawn(function()
	local UIS = UserInputService
	while true do
		task.wait(45)
		pcall(function()
			firesignal(UIS.InputChanged, { UserInputType = Enum.UserInputType.MouseMovement })
		end)
	end
end)
pcall(function()
	local TS = game:GetService("TeleportService")
	local oldTeleport = TS.Teleport
	if oldTeleport then
		hookfunction(oldTeleport, function() return nil end)
	end
end)
pcall(function()
	local g = getgenv()
	if g.tx_egg_queued then return end
	local qt = queue_on_teleport or queueonteleport
	if not qt then return end
	g.tx_egg_queued = true
	pcall(function()
		local src = readfile("tianxiu_egg.lua")
		if src and #src > 50 then
			qt("loadstring(readfile('tianxiu_egg.lua'))()")
		end
	end)
end)
RunService.Heartbeat:Connect(function()
	applyBypass()
	local hum = getHum()
	if hum then
		if hum.Health < hum.MaxHealth then
			hum.Health = hum.MaxHealth
		end
	end
end)
local function getInputMove()
	local cam = workspace.CurrentCamera
	if not cam then return Vector3.new() end
	local look = cam.CFrame.LookVector
	local right = cam.CFrame.RightVector
	local f = 0
	local r = 0
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then f = f + 1 end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then f = f - 1 end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then r = r + 1 end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then r = r - 1 end
	local mv = Vector3.new(look.X, 0, look.Z).Unit * f + Vector3.new(right.X, 0, right.Z).Unit * r
	if mv.Magnitude > 1 then mv = mv.Unit end
	return mv
end
local moveConn = nil
local function startTpwalk()
	if moveConn then return end
	moveConn = RunService.Heartbeat:Connect(function(dt)
		if not S.speedOn then return end
		local char = getChar()
		if not char then return end
		local mv = getInputMove()
		if mv.Magnitude > 0 then
			char:TranslateBy(mv * math.min(S.speedMult * 10, 1000) * dt)
		end
	end)
end
local function noclipChar(char, v)
	if not char then return end
	for _, p in ipairs(char:GetDescendants()) do
		if p:IsA("BasePart") then p.CanCollide = v end
	end
end
local function getBasePos()
	local sl = workspace:FindFirstChildOfClass("SpawnLocation")
	if sl then return sl.Position end
	return Vector3.new(500, 70, -365)
end
local moving = false
local moveStop = nil
local function stopMove()
	moving = false
	if moveStop then pcall(moveStop) moveStop = nil end
end
local function walkTo(pos, onArrive, arriveDist)
	if moving then return end
	local char = getChar()
	local hrp = getHRP()
	if not (char and hrp) then return end
	local thresh = arriveDist or 2.5
	moving = true
	local conn
	local lastPos = hrp.Position
	local stuckT = 0
	local noclip = false
	local clipT = 0
	conn = RunService.Heartbeat:Connect(function(dt)
		if not moving then
			conn:Disconnect()
			return
		end
		if not hrp.Parent then
			hrp = getHRP()
			char = getChar()
			if not (char and hrp) then
				conn:Disconnect()
				moving = false
				return
			end
			lastPos = hrp.Position
			stuckT = 0
			return
		end
		local dir = pos - hrp.Position
		local dist = dir.Magnitude
		if dist < thresh then
			conn:Disconnect()
			moving = false
			if noclip then noclipChar(char, true) end
			if onArrive then pcall(onArrive) end
			return
		end
		local moved = (hrp.Position - lastPos).Magnitude
		if moved < 0.3 then
			stuckT = stuckT + dt
			if stuckT > 1 and not noclip then
				stuckT = 0
				noclip = true
				clipT = 0
				noclipChar(char, false)
			end
		else
			stuckT = 0
		end
		lastPos = hrp.Position
		local unit = dir / dist
		if noclip then
			clipT = clipT + dt
			char:TranslateBy(unit * 60 * dt)
			if clipT > 0.5 then
				noclip = false
				noclipChar(char, true)
			end
		else
			local spd = math.min(S.speedMult * 10, 1000)
			if dist < 8 then spd = math.min(spd, 60) end
			if dist < 20 then spd = math.min(spd, 150) end
			char:TranslateBy(unit * spd * dt)
		end
	end)
	moveStop = function()
		if conn then pcall(function() conn:Disconnect() end) end
		if noclip then pcall(function() noclipChar(char, true) end) end
		moving = false
	end
end
local Assets = nil
pcall(function() Assets = require(ReplicatedStorage.Data.Assets) end)
local AssetItems = nil
pcall(function() AssetItems = require(ReplicatedStorage.Shared.Util.AssetItems) end)
local RarityNumToZh = { [1] = 10, [2] = 9, [3] = 8, [4] = 7, [5] = 6, [6] = 5, [7] = 4, [8] = 3, [9] = 2, [10] = 1, [11] = 1 }
local function eggRarityNum(cat)
	if not Assets or not Assets.Directory then return 10 end
	local cfg = Assets.Directory[cat]
	local rar = cfg and cfg.Rarity
	local num = rar and rar.RarityNumber or 1
	return RarityNumToZh[num] or 10
end
local function eggPrice(r)
	if not AssetItems or not AssetItems.SalePrice then return 0 end
	local ok, price = pcall(function()
		return AssetItems.SalePrice({
			Category = r.AssetCategory,
			Scale = r.AssetScale,
			EyeColor = r.AssetEyeColor,
			ColorSeed = r.AssetColorSeed,
			ColorIndex = r.AssetColorIndex,
			Mutations = r.Mutations or {},
			BaseMutation = r.BaseMutation,
		})
	end)
	return ok and price or 0
end
local eggCache = nil
local eggCacheT = 0
local function findAllEggs()
	local now = os.clock()
	if eggCache and now - eggCacheT < 1 then return eggCache end
	local out = {}
	local field = nil
	if EggState then pcall(function() field = EggState.SyncFieldEggs() end) end
	if not field then return out end
	for _, r in ipairs(field.Records or {}) do
		if r.State == "Slot" and r.Uid and r.BottomCFrame then
			local uid = tostring(r.Uid)
			if not uid:find("FirstAreaEgg") then
				local name = tostring(r.AssetCategory or "")
				if name == "" then name = "蛋" end
				table.insert(out, { uid = uid, pos = r.BottomCFrame.Position, rarity = eggRarityNum(name), name = name, price = eggPrice(r) })
			end
		end
	end
	if S.byPrice then
		table.sort(out, function(a, b) return a.price > b.price end)
	else
		table.sort(out, function(a, b) return a.rarity < b.rarity end)
	end
	eggCache = out
	eggCacheT = now
	return out
end
local function wantRarity(rank)
	local any = false
	for _, zh in ipairs(RarityZh) do
		if S.rarities[zh] then any = true break end
	end
	if not any then return true end
	for i, zh in ipairs(RarityZh) do
		if i == rank and S.rarities[zh] then return true end
	end
	return false
end
local stealTick = 0
local skipUid = nil
local skipT = 0
local needBack = false
local needBackT = 0
local firstGo = false
local function carryEgg(uid)
	if not EggState then return "error" end
	local ok, res, msg = pcall(function() return EggState.CarryFieldEgg(uid) end)
	if not ok then return "error" end
	if res == true then return "success" end
	if type(msg) == "string" and msg:find("Already", 1, true) then return "already" end
	return "fail"
end
local function stopAfterBack()
	walkTo(getBasePos(), function()
		stopMove()
		needBack = false
	end)
end
local function stealLoop(dt)
	if not S.stealOn then return end
	if needBack then
		if os.clock() - needBackT > 120 then needBack = false end
		return
	end
	if moving then return end
	if firstGo then
		firstGo = false
		walkTo(getBasePos(), function() end)
		return
	end
	stealTick = stealTick + dt
	if stealTick < 0.6 then return end
	stealTick = 0
	if skipUid and os.clock() - skipT > 30 then skipUid = nil end
	local eggs = findAllEggs()
	for _, e in ipairs(eggs) do
		if not S.stealOn then break end
		if e.uid ~= skipUid and wantRarity(e.rarity) then
			local attempts = 0
			local function tryCarry()
				attempts = attempts + 1
				needBack = true
				needBackT = os.clock()
				local st = carryEgg(e.uid)
				if st == "success" or st == "already" then
					skipUid = e.uid
					skipT = os.clock()
					eggCache = nil
					task.wait(0.3)
					stopAfterBack()
					return
				end
				needBack = false
				if attempts >= 4 then
					skipUid = e.uid
					skipT = os.clock()
					needBack = true
					needBackT = os.clock()
					task.wait(0.2)
					walkTo(getBasePos(), function()
						needBack = false
						stopMove()
					end)
					return
				end
				task.wait(0.2)
				walkTo(e.pos, tryCarry, 2.5 - attempts * 0.6)
			end
			walkTo(e.pos, tryCarry)
			return
		end
	end
end
local hatchTick = 0
local function hatchLoop(dt)
	if not S.hatchOn then return end
	hatchTick = hatchTick + dt
	if hatchTick < 2 then return end
	hatchTick = 0
	if not EggState then return end
	pcall(function() EggState.SyncOwnedEggs() end)
	local rows = pcall(function() return EggState.ReadOwnedEggs() end)
	if type(rows) == "table" then
		for _, row in ipairs(rows) do
			for _, rec in ipairs(row.Records or {}) do
				if rec.Uid and rec.State == "Dropped" then
					pcall(function() EggState.BeginHatch(rec.Uid) end)
					task.wait(0.3)
					pcall(function() EggState.FinishHatch(rec.Uid) end)
					task.wait(0.3)
				end
			end
		end
	end
end
local collectTick = 0
local function collectLoop(dt)
	if not S.collectOn then return end
	collectTick = collectTick + dt
	if collectTick < 30 then return end
	collectTick = 0
	pcall(function()
		local rem = require(ReplicatedStorage.Shared.Remotes)
		rem.AwayEarnings.PendingCheck:InvokeServer()
		task.wait(0.2)
		rem.AwayEarnings.AskCollect:InvokeServer()
	end)
end

local function AddCorner(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = obj
	return c
end
local RAINBOW_FLOW = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 82, 126)),
	ColorSequenceKeypoint.new(0.14, Color3.fromRGB(255, 178, 78)),
	ColorSequenceKeypoint.new(0.28, Color3.fromRGB(255, 246, 112)),
	ColorSequenceKeypoint.new(0.43, Color3.fromRGB(102, 255, 176)),
	ColorSequenceKeypoint.new(0.58, Color3.fromRGB(86, 230, 255)),
	ColorSequenceKeypoint.new(0.72, Color3.fromRGB(126, 138, 255)),
	ColorSequenceKeypoint.new(0.86, Color3.fromRGB(236, 92, 255)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 82, 126))
})
local function StartRainbowFlow(parent, duration, transparency)
	local grad = Instance.new("UIGradient")
	grad.Name = "RainbowFlow"
	grad.Color = RAINBOW_FLOW
	grad.Transparency = transparency or NumberSequence.new(0)
	grad.Rotation = -180
	grad.Parent = parent
	local tw = TweenService:Create(grad, TweenInfo.new(duration or 2.0, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, 0), { Rotation = 180 })
	tw:Play()
	return grad, tw
end
local function AddRainbowBorder(obj, thickness, transparency, speed)
	local stroke = Instance.new("UIStroke")
	stroke.Name = "DB_RainbowMain"
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Thickness = thickness or 0.9
	stroke.Color = Color3.new(1, 1, 1)
	stroke.Transparency = transparency or 0.01
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	stroke.Parent = obj
	local grad = StartRainbowFlow(stroke, speed or 1.95)
	return stroke, grad
end
local function AddBorder(obj, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Thickness = thickness or 0.85
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = transparency or 0.52
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	stroke.Parent = obj
	return stroke
end
local function StyleButton(btn, radius)
	btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	btn.BackgroundTransparency = 0.84
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBlack
	btn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	btn.TextStrokeTransparency = 0.62
	AddCorner(btn, radius or 9)
	AddBorder(btn, 0.85, 0.52)
	local scale = Instance.new("UIScale")
	scale.Name = "DB_Scale"
	scale.Scale = 1
	scale.Parent = btn
	btn.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		TweenService:Create(scale, TweenInfo.new(0.055, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.965 }):Play()
	end)
	btn.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		TweenService:Create(scale, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	end)
end
local function CreateToggleRow(parent, title, getValue, onChange)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -12, 0, 36)
	row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	row.BackgroundTransparency = 0.88
	row.BorderSizePixel = 0
	row.Parent = parent
	AddCorner(row, 8)
	AddBorder(row, 0.7, 0.6)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -66, 1, 0)
	label.Position = UDim2.fromOffset(12, 0)
	label.BackgroundTransparency = 1
	label.Text = title
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 12
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Parent = row
	local enabled = getValue and getValue() or false
	local switch = Instance.new("TextButton")
	switch.AnchorPoint = Vector2.new(1, 0.5)
	switch.Position = UDim2.new(1, -12, 0.5, 0)
	switch.Size = UDim2.fromOffset(44, 22)
	switch.BackgroundColor3 = enabled and Color3.fromRGB(205, 210, 220) or Color3.fromRGB(62, 65, 72)
	switch.BackgroundTransparency = 0.12
	switch.BorderSizePixel = 0
	switch.Text = ""
	switch.AutoButtonColor = false
	switch.Parent = row
	AddCorner(switch, 999)
	local knob = Instance.new("Frame")
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = enabled and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0)
	knob.Size = UDim2.fromOffset(17, 17)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BackgroundTransparency = 0
	knob.BorderSizePixel = 0
	knob.Parent = switch
	AddCorner(knob, 999)
	switch.Activated:Connect(function()
		enabled = not enabled
		if onChange then pcall(onChange, enabled) end
		TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = enabled and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0) }):Play()
		TweenService:Create(switch, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = enabled and Color3.fromRGB(205, 210, 220) or Color3.fromRGB(62, 65, 72) }):Play()
	end)
	return row
end
local function CreateButtonRow(parent, title, onClick)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -12, 0, 34)
	btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	btn.BackgroundTransparency = 0.88
	btn.BorderSizePixel = 0
	btn.Text = title
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamBlack
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.TextTruncate = Enum.TextTruncate.AtEnd
	btn.AutoButtonColor = false
	btn.Parent = parent
	StyleButton(btn, 8)
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 12)
	pad.PaddingRight = UDim.new(0, 12)
	pad.Parent = btn
	btn.Activated:Connect(function()
		if onClick then pcall(onClick) end
	end)
	return btn
end
local function CreateSliderRow(parent, title, min, max, def, step, onChange)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -12, 0, 62)
	row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	row.BackgroundTransparency = 0.88
	row.BorderSizePixel = 0
	row.Parent = parent
	AddCorner(row, 8)
	AddBorder(row, 0.7, 0.6)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 0, 18)
	label.Position = UDim2.fromOffset(12, 3)
	label.BackgroundTransparency = 1
	label.Text = title .. "：" .. tostring(def)
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 11
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row
	local track = Instance.new("Frame")
	track.Position = UDim2.new(0, 14, 0, 38)
	track.Size = UDim2.new(1, -28, 0, 5)
	track.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	track.BackgroundTransparency = 0.75
	track.BorderSizePixel = 0
	track.Active = true
	track.Parent = row
	AddCorner(track, 999)
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	fill.BackgroundTransparency = 0.02
	fill.BorderSizePixel = 0
	fill.Parent = track
	AddCorner(fill, 999)
	local knob = Instance.new("Frame")
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(0, 0, 0.5, 0)
	knob.Size = UDim2.fromOffset(14, 14)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BackgroundTransparency = 0
	knob.BorderSizePixel = 0
	knob.Active = false
	knob.Parent = track
	AddCorner(knob, 999)
	local dragging = false
	local dragInput = nil
	local function ApplyRatio(ratio, fireCallback)
		ratio = math.max(0, math.min(1, ratio))
		local snapped = math.max(min, math.min(max, math.floor((min + (max - min) * ratio) / step + 0.5) * step))
		local r2 = (snapped - min) / (max - min)
		fill.Size = UDim2.new(r2, 0, 1, 0)
		knob.Position = UDim2.new(r2, 0, 0.5, 0)
		label.Text = title .. "：" .. tostring(snapped)
		if fireCallback and onChange then pcall(onChange, snapped) end
	end
	local function ApplyFromX(x)
		if not track.Parent then return end
		local width = math.max(1, track.AbsoluteSize.X)
		ApplyRatio((x - track.AbsolutePosition.X) / width, true)
	end
	ApplyRatio((def - min) / (max - min), false)
	track.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		dragging = true
		dragInput = input
		ApplyFromX(input.Position.X)
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging or not track.Parent then return end
		if input.UserInputType == Enum.UserInputType.Touch then
			if input ~= dragInput then return end
		elseif input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		ApplyFromX(input.Position.X)
	end)
	UserInputService.InputEnded:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.Touch then
			if input ~= dragInput then return end
		elseif input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		dragging = false
		dragInput = nil
	end)
	return row
end
local function Notify(title, text)
	pcall(function()
		local pg = lp:WaitForChild("PlayerGui")
		local old = pg:FindFirstChild("TX_EggNotify")
		if old then old:Destroy() end
		local frame = Instance.new("Frame")
		frame.Name = "TX_EggNotify"
		frame.AnchorPoint = Vector2.new(1, 1)
		frame.Position = UDim2.new(1, -16, 1, -16)
		frame.Size = UDim2.fromOffset(280, 54)
		frame.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
		frame.BackgroundTransparency = 0.25
		frame.BorderSizePixel = 0
		frame.ZIndex = 5000
		frame.Parent = pg
		AddCorner(frame, 12)
		AddBorder(frame, 1, 0.35)
		local t1 = Instance.new("TextLabel")
		t1.Size = UDim2.new(1, -20, 0, 18)
		t1.Position = UDim2.fromOffset(10, 5)
		t1.BackgroundTransparency = 1
		t1.Text = title
		t1.TextColor3 = Color3.fromRGB(255, 255, 255)
		t1.TextSize = 12
		t1.Font = Enum.Font.GothamBlack
		t1.TextXAlignment = Enum.TextXAlignment.Left
		t1.Parent = frame
		local t2 = Instance.new("TextLabel")
		t2.Size = UDim2.new(1, -20, 0, 22)
		t2.Position = UDim2.fromOffset(10, 25)
		t2.BackgroundTransparency = 1
		t2.Text = text
		t2.TextColor3 = Color3.fromRGB(200, 210, 230)
		t2.TextSize = 10
		t2.Font = Enum.Font.GothamMedium
		t2.TextXAlignment = Enum.TextXAlignment.Left
		t2.Parent = frame
		task.delay(3, function()
			if frame and frame.Parent then
				TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
				task.delay(0.35, function() if frame and frame.Parent then frame:Destroy() end end)
			end
		end)
	end)
end

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "TX_Egg_Panel"
MainGui.ResetOnSpawn = false
MainGui.IgnoreGuiInset = true
MainGui.DisplayOrder = 999
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local pg = lp:WaitForChild("PlayerGui", 10)
MainGui.Parent = pg

local IntroGui = Instance.new("Frame")
IntroGui.Name = "TX_Intro"
IntroGui.Size = UDim2.fromScale(1, 1)
IntroGui.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
IntroGui.BackgroundTransparency = 1
IntroGui.BorderSizePixel = 0
IntroGui.ZIndex = 10000
IntroGui.Active = true
IntroGui.ClipsDescendants = true
IntroGui.Parent = MainGui
local IntroTitle = Instance.new("TextLabel")
IntroTitle.AnchorPoint = Vector2.new(0.5, 0.5)
IntroTitle.Position = UDim2.fromScale(0.5, 0.42)
IntroTitle.Size = UDim2.new(0, 320, 0, 64)
IntroTitle.BackgroundTransparency = 1
IntroTitle.Text = "偷一个蛋"
IntroTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroTitle.TextTransparency = 1
IntroTitle.TextSize = 48
IntroTitle.Font = Enum.Font.GothamBlack
IntroTitle.ZIndex = 10002
IntroTitle.Parent = IntroGui
AddBorder(IntroTitle, 1.4, 0.15)
StartRainbowFlow(IntroTitle, 2.2, NumberSequence.new(0))
local IntroSub = Instance.new("TextLabel")
IntroSub.AnchorPoint = Vector2.new(0.5, 1)
IntroSub.Position = UDim2.new(0.5, 0, 0.72, 0)
IntroSub.Size = UDim2.new(0, 300, 0, 26)
IntroSub.BackgroundTransparency = 1
IntroSub.Text = "天休制作 · 欢迎：" .. lp.Name
IntroSub.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroSub.TextTransparency = 1
IntroSub.TextSize = 15
IntroSub.Font = Enum.Font.GothamMedium
IntroSub.ZIndex = 10002
IntroSub.Parent = IntroGui
TweenService:Create(IntroGui, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.25 }):Play()
task.wait(0.15)
TweenService:Create(IntroTitle, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
TweenService:Create(IntroSub, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
task.wait(1.7)
TweenService:Create(IntroGui, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { BackgroundTransparency = 1 }):Play()
TweenService:Create(IntroTitle, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 }):Play()
TweenService:Create(IntroSub, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 }):Play()
task.wait(0.5)
if IntroGui.Parent then IntroGui:Destroy() end

local PANEL_W, PANEL_H = 440, 420
local Panel = Instance.new("Frame")
Panel.Name = "Panel"
Panel.AnchorPoint = Vector2.new(0.5, 0.5)
Panel.Position = UDim2.fromScale(0.5, 0.5)
Panel.Size = UDim2.fromOffset(PANEL_W, PANEL_H)
Panel.BackgroundTransparency = 1
Panel.BorderSizePixel = 0
Panel.Active = true
Panel.Parent = MainGui
local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Position = UDim2.fromOffset(2, 2)
Body.Size = UDim2.new(1, -4, 1, -4)
Body.BackgroundColor3 = Color3.fromRGB(6, 8, 12)
Body.BackgroundTransparency = 0.12
Body.BorderSizePixel = 0
Body.ClipsDescendants = true
Body.Parent = Panel
AddCorner(Body, 14)
AddRainbowBorder(Body, 1.5, 0.02, 2.6)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundTransparency = 1
Header.Active = true
Header.Parent = Body
local TitleLabel = Instance.new("TextLabel")
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.fromOffset(12, 3)
TitleLabel.Size = UDim2.new(0, 130, 0, 24)
TitleLabel.Text = "偷一个蛋"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header
StartRainbowFlow(TitleLabel, 4.0, NumberSequence.new(0))
local SubLabel = Instance.new("TextLabel")
SubLabel.BackgroundTransparency = 1
SubLabel.Position = UDim2.fromOffset(150, 8)
SubLabel.Size = UDim2.new(1, -240, 0, 14)
SubLabel.Text = "天休制作"
SubLabel.TextColor3 = Color3.fromRGB(190, 200, 215)
SubLabel.TextSize = 9
SubLabel.Font = Enum.Font.GothamMedium
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent = Header
local DragArea = Instance.new("TextButton")
DragArea.Name = "DragArea"
DragArea.Size = UDim2.new(1, -58, 1, 0)
DragArea.BackgroundTransparency = 1
DragArea.BorderSizePixel = 0
DragArea.Text = ""
DragArea.AutoButtonColor = false
DragArea.Active = true
DragArea.Parent = Header
local panelDrag = { active = false, start = nil, pos = nil, touch = nil }
local function StartPanelDrag(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	panelDrag.active = true
	panelDrag.start = input.Position
	panelDrag.pos = Panel.Position
	if input.UserInputType == Enum.UserInputType.Touch then panelDrag.touch = input end
end
DragArea.InputBegan:Connect(StartPanelDrag)
Header.InputBegan:Connect(StartPanelDrag)
Panel.InputBegan:Connect(StartPanelDrag)
UserInputService.InputChanged:Connect(function(input)
	if not panelDrag.active then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement then
	elseif input.UserInputType == Enum.UserInputType.Touch and input == panelDrag.touch then
	else
		return
	end
	local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
	local maxX = vp.X - PANEL_W / 2 - 30
	local maxY = vp.Y - PANEL_H / 2 - 30
	local minX = PANEL_W / 2 - vp.X + 30
	local minY = PANEL_H / 2 - vp.Y + 30
	local dx = math.max(minX, math.min(maxX, panelDrag.pos.X.Offset + (input.Position.X - panelDrag.start.X)))
	local dy = math.max(minY, math.min(maxY, panelDrag.pos.Y.Offset + (input.Position.Y - panelDrag.start.Y)))
	Panel.Position = UDim2.new(0.5, dx, 0.5, dy)
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	panelDrag.active = false
	panelDrag.touch = nil
end)
local MiniBtn = Instance.new("TextButton")
MiniBtn.Name = "Mini"
MiniBtn.Position = UDim2.new(1, -56, 0, 2)
MiniBtn.Size = UDim2.fromOffset(26, 26)
MiniBtn.BackgroundTransparency = 1
MiniBtn.BorderSizePixel = 0
MiniBtn.Text = "−"
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.TextSize = 20
MiniBtn.Font = Enum.Font.GothamMedium
MiniBtn.AutoButtonColor = false
MiniBtn.Parent = Header
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "Close"
CloseBtn.Position = UDim2.new(1, -28, 0, 2)
CloseBtn.Size = UDim2.fromOffset(26, 26)
CloseBtn.BackgroundTransparency = 1
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header
local Divider = Instance.new("Frame")
Divider.Position = UDim2.new(0, 0, 0, 30)
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.BackgroundColor3 = Color3.fromRGB(150, 205, 240)
Divider.BackgroundTransparency = 0.72
Divider.BorderSizePixel = 0
Divider.Parent = Body
local NAV_W = 112
local NavRail = Instance.new("Frame")
NavRail.Name = "NavRail"
NavRail.Position = UDim2.fromOffset(0, 31)
NavRail.Size = UDim2.new(0, NAV_W, 1, -31)
NavRail.BackgroundTransparency = 1
NavRail.Parent = Body
local ContentHost = Instance.new("Frame")
ContentHost.Name = "ContentHost"
ContentHost.Position = UDim2.new(0, NAV_W + 1, 0, 31)
ContentHost.Size = UDim2.new(1, -(NAV_W + 1), 1, -31)
ContentHost.BackgroundTransparency = 1
ContentHost.ClipsDescendants = true
ContentHost.Parent = Body
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, -10, 1, -8)
ContentScroll.Position = UDim2.fromOffset(5, 4)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 2
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(205, 205, 210)
ContentScroll.ScrollBarImageTransparency = 0.5
ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentScroll.CanvasSize = UDim2.new()
ContentScroll.ScrollingDirection = Enum.ScrollingDirection.Y
ContentScroll.Active = true
ContentScroll.ScrollingEnabled = true
ContentScroll.Parent = ContentHost
local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 5)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = ContentScroll
local NavLayout = Instance.new("UIListLayout")
NavLayout.Padding = UDim.new(0, 5)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
NavLayout.Parent = NavRail
local NavPad = Instance.new("UIPadding")
NavPad.PaddingTop = UDim.new(0, 5)
NavPad.PaddingLeft = UDim.new(0, 4)
NavPad.PaddingRight = UDim.new(0, 4)
NavPad.Parent = NavRail
local currentCategory = "移动"
local navButtons = {}
local function RenderCategory(cat)
	for _, child in ipairs(ContentScroll:GetChildren()) do
		if child:IsA("GuiObject") and child ~= ContentLayout then
			child:Destroy()
		end
	end
	ContentScroll.CanvasPosition = Vector2.new(0, 0)
	if cat == "移动" then
		CreateToggleRow(ContentScroll, "速度更改(tpwalk)", function() return S.speedOn end, function(v)
			S.speedOn = v
			saveCfg()
			if v then startTpwalk() end
		end)
		CreateSliderRow(ContentScroll, "速度倍数", 1, 100, S.speedMult, 1, function(v) S.speedMult = v saveCfg() end)
		CreateButtonRow(ContentScroll, "反作弊绕过(常开)", function()
			applyBypass()
			Notify("偷一个蛋", "反作弊绕过已开启")
		end)
	elseif cat == "偷蛋" then
		CreateToggleRow(ContentScroll, "自动偷蛋", function() return S.stealOn end, function(v)
			S.stealOn = v
			saveCfg()
			if v then
				firstGo = true
			else
				stopMove()
			end
		end)
		CreateButtonRow(ContentScroll, "回基地", function()
			walkTo(getBasePos(), function() stopMove() end)
		end)
		CreateButtonRow(ContentScroll, "扫描全场蛋", function()
			local n = #findAllEggs()
			Notify("偷一个蛋", "找到 " .. n .. " 个蛋")
		end)
		CreateToggleRow(ContentScroll, "自动孵化", function() return S.hatchOn end, function(v) S.hatchOn = v saveCfg() end)
		CreateToggleRow(ContentScroll, "按价格偷蛋(贵的先偷)", function() return S.byPrice end, function(v) S.byPrice = v saveCfg() end)
		local rarityHint = Instance.new("TextLabel")
		rarityHint.Name = "RarityHint"
		rarityHint.Size = UDim2.new(1, -12, 0, 22)
		rarityHint.BackgroundTransparency = 1
		rarityHint.Text = "点下面的稀有度加入偷取列表"
		rarityHint.TextColor3 = Color3.fromRGB(255, 205, 120)
		rarityHint.TextSize = 10
		rarityHint.Font = Enum.Font.GothamMedium
		rarityHint.TextXAlignment = Enum.TextXAlignment.Left
		rarityHint.Parent = ContentScroll
		for i, zh in ipairs(RarityZh) do
			CreateToggleRow(ContentScroll, zh, function() return S.rarities[zh] or false end, function(v)
				S.rarities[zh] = v
				saveCfg()
			end)
		end
	elseif cat == "挂机" then
		CreateToggleRow(ContentScroll, "自动领离线收益", function() return S.collectOn end, function(v) S.collectOn = v saveCfg() end)
		CreateButtonRow(ContentScroll, "立即领离线收益", function()
			pcall(function()
				local rem = require(ReplicatedStorage.Shared.Remotes)
				rem.AwayEarnings.PendingCheck:InvokeServer()
				task.wait(0.2)
				rem.AwayEarnings.AskCollect:InvokeServer()
			end)
			Notify("偷一个蛋", "离线收益已领取")
		end)
		CreateButtonRow(ContentScroll, "一键兑换全部", function()
			pcall(function()
				require(ReplicatedStorage.Shared.Remotes).Codex.AskRedeemAll:InvokeServer()
			end)
			Notify("偷一个蛋", "兑换已全部领取")
		end)
	elseif cat == "视觉" then
		CreateToggleRow(ContentScroll, "蛋透视", function() return S.espOn end, function(v) S.espOn = v saveCfg() end)
		CreateToggleRow(ContentScroll, "显示名字", function() return S.showNames end, function(v) S.showNames = v saveCfg() end)
		CreateToggleRow(ContentScroll, "显示距离", function() return S.showDist end, function(v) S.showDist = v saveCfg() end)
	end
end
local categories = { "移动", "偷蛋", "挂机", "视觉" }
for i, cat in ipairs(categories) do
	local btn = Instance.new("TextButton")
	btn.Name = "Nav_" .. cat
	btn.Size = UDim2.new(1, -8, 0, 34)
	btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	btn.BackgroundTransparency = 0.86
	btn.BorderSizePixel = 0
	btn.Text = cat
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 13
	btn.Font = Enum.Font.GothamBlack
	btn.TextXAlignment = Enum.TextXAlignment.Center
	btn.AutoButtonColor = false
	btn.LayoutOrder = i
	btn.Parent = NavRail
	StyleButton(btn, 8)
	btn.Activated:Connect(function()
		currentCategory = cat
		RenderCategory(cat)
		for _, b in ipairs(navButtons) do
			b.BackgroundTransparency = 0.88
			b.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
		btn.BackgroundTransparency = 0.68
		btn.TextColor3 = Color3.fromRGB(190, 235, 255)
	end)
	table.insert(navButtons, btn)
end
local Floating = Instance.new("TextButton")
Floating.Name = "TX_Floating"
Floating.AnchorPoint = Vector2.new(0.5, 0.5)
Floating.Position = UDim2.new(1, -70, 0.5, 0)
Floating.Size = UDim2.fromOffset(58, 34)
Floating.BackgroundColor3 = Color3.fromRGB(6, 9, 13)
Floating.BackgroundTransparency = 0.1
Floating.BorderSizePixel = 0
Floating.Text = "偷蛋"
Floating.TextColor3 = Color3.fromRGB(255, 255, 255)
Floating.TextSize = 12
Floating.Font = Enum.Font.GothamBlack
Floating.Visible = false
Floating.ZIndex = 200
Floating.Parent = MainGui
AddCorner(Floating, 999)
AddRainbowBorder(Floating, 1.4, 0.02, 2.8)
local floatDrag = { active = false, start = nil, pos = nil, touch = nil, moved = false, suppressUntil = 0 }
Floating.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	floatDrag.active = true
	floatDrag.start = input.Position
	floatDrag.pos = Floating.Position
	floatDrag.moved = false
	if input.UserInputType == Enum.UserInputType.Touch then floatDrag.touch = input end
end)
UserInputService.InputChanged:Connect(function(input)
	if not floatDrag.active then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement then
	elseif input.UserInputType == Enum.UserInputType.Touch and input == floatDrag.touch then
	else
		return
	end
	local delta = input.Position - floatDrag.start
	if delta.Magnitude >= 7 then floatDrag.moved = true end
	Floating.Position = UDim2.new(floatDrag.pos.X.Scale, floatDrag.pos.X.Offset + delta.X, floatDrag.pos.Y.Scale, floatDrag.pos.Y.Offset + delta.Y)
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	if floatDrag.active and floatDrag.moved then
		floatDrag.suppressUntil = os.clock() + 0.3
	end
	floatDrag.active = false
	floatDrag.touch = nil
end)
Floating.Activated:Connect(function()
	if floatDrag.moved or os.clock() < floatDrag.suppressUntil then
		floatDrag.moved = false
		return
	end
	Floating.Visible = false
	Panel.Visible = true
end)
MiniBtn.Activated:Connect(function()
	Panel.Visible = false
	Floating.Visible = true
end)

local chams = {}
local lastScan = 0
local function refreshESP(dt)
	if not S.espOn then
		for uid, obj in pairs(chams) do
			pcall(function() obj.P:Destroy() end)
			pcall(function() obj.H:Destroy() end)
			pcall(function() obj.B:Destroy() end)
			chams[uid] = nil
		end
		return
	end
	lastScan = lastScan + dt
	local doScan = lastScan > 0.3
	if doScan then lastScan = 0 end
	local hrp = getHRP()
	local eggs = findAllEggs()
	local seen = {}
	for _, e in ipairs(eggs) do
		seen[e.uid] = true
		if doScan then
			if not chams[e.uid] then
				local p = Instance.new("Part")
				p.Name = "EggESP"
				p.Size = Vector3.new(3, 3, 3)
				p.Transparency = 1
				p.Anchored = true
				p.CanCollide = false
				p.Parent = workspace
				local h = Instance.new("Highlight")
				h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				h.FillTransparency = 0.6
				h.FillColor = Color3.fromRGB(255, 170, 0)
				h.OutlineColor = Color3.fromRGB(255, 170, 0)
				h.Parent = p
				local b = Instance.new("BillboardGui")
				b.AlwaysOnTop = true
				b.Size = UDim2.fromOffset(120, 40)
				b.StudsOffset = Vector3.new(0, 3, 0)
				b.Parent = p
				local lab = Instance.new("TextLabel")
				lab.Size = UDim2.fromScale(1, 1)
				lab.BackgroundTransparency = 1
				lab.Font = Enum.Font.Code
				lab.TextColor3 = Color3.fromRGB(255, 220, 100)
				lab.TextStrokeTransparency = 0
				lab.Parent = b
				chams[e.uid] = { P = p, H = h, B = b, L = lab }
			end
		end
		local obj = chams[e.uid]
		if obj then
			obj.P.CFrame = CFrame.new(e.pos + Vector3.new(0, 2, 0))
			local txt = ""
			if S.showNames then txt = e.name end
			if S.showDist and hrp then
				local d = (hrp.Position - e.pos).Magnitude
				txt = txt .. (txt ~= "" and "\n" or "") .. string.format("[%.0f]", d)
			end
			obj.L.Text = txt
		end
	end
	if doScan then
		for uid, obj in pairs(chams) do
			if not seen[uid] then
				pcall(function() obj.P:Destroy() end)
				pcall(function() obj.H:Destroy() end)
				pcall(function() obj.B:Destroy() end)
				chams[uid] = nil
			end
		end
	end
end

local mainConn = RunService.RenderStepped:Connect(function(dt)
	stealLoop(dt)
	hatchLoop(dt)
	collectLoop(dt)
	refreshESP(dt)
end)

local function Shutdown()
	S.stealOn = false
	S.speedOn = false
	S.espOn = false
	stopMove()
	if moveConn then pcall(function() moveConn:Disconnect() end) end
	if mainConn then pcall(function() mainConn:Disconnect() end) end
	for uid, obj in pairs(chams) do
		pcall(function() obj.P:Destroy() end)
		chams[uid] = nil
	end
	pcall(function()
		if MainGui and MainGui.Parent then MainGui:Destroy() end
	end)
	Notify("偷一个蛋", "已关闭")
end
CloseBtn.Activated:Connect(Shutdown)

loadCfg()
RenderCategory("移动")
if navButtons[1] then
	navButtons[1].BackgroundTransparency = 0.68
	navButtons[1].TextColor3 = Color3.fromRGB(190, 235, 255)
end

task.wait(0.2)
applyBypass()
if S.speedOn then startTpwalk() end
Notify("偷一个蛋", "天休制作 · 加载成功")
            ]=====]
        }
},
["竞技格斗"] = {
{
            Name = "决斗场--天休制作",
            Code = [[loadstring(request({ Url = "https://raw.githubusercontent.com/dish-rr/autoparry--tianxiuzhizuo/master/duel_autoparry.luau", Method = "GET" }).Body)()]]
        },
{
Name = "刀刃球",
Code = [[loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/b7cca66d493ea7fe18629f1b27a3ecc5.lua"))()]]
},
{
Name = "西蒙说",
Code = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/TuxHubScripts/SillySimonSays/refs/heads/main/script"))()]]
}
},
["休闲社交"] = {
{Name = "谋杀之谜MM2", Url = "https://raw.githubusercontent.com/snxpzscripts/mm2/refs/heads/main/MozqlHub"},
{Name = "NPC或死", Code = [[loadstring(game:HttpGet('https://raw.githubusercontent.com/ToraScript/Script/main/BENPCORDIE', true))()]]},
{Name = "画我", Code = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/KENNY画我.lua"))()]]},
{
Name = "闪耀事物人",
Code = [[loadstring(game:HttpGet("https://rawscripts.net/raw/Fling-Things-and-People-ftap-script-241022"))()]]
}
},
["合作游戏"] = {
{Name = "逃跑者--天休制作", Code = [====[

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer

if not game:IsLoaded() then game.Loaded:Wait() end

local S = {
	nuke = false, ragdoll = false, threaten = false,
	fly = false, flySpeed = 60, vertical = 0,
	autoPickup = true, autoCash = true, pickupRange = 99999,
	aimbot = false, aimRange = 300,
	chamsNPC = true, itemESP = true, showNames = true, showDist = true,
	speed = 26, jump = 50, nightVision = false, fov = 70,
}

local function getFlow()
	return require(game.ReplicatedStorage.FlowClient)
end

local function getNPCs()
	local list = {}
	for _, m in CollectionService:GetTagged("NPC") do
		local h = m:FindFirstChildOfClass("Humanoid")
		if h and h.Health > 0 then
			table.insert(list, { m = m, h = h })
		end
	end
	return list
end

local nukeTick = 0
local function nukeLoop(dt)
	if not S.nuke then return end
	nukeTick = nukeTick + dt
	if nukeTick < 0.3 then return end
	nukeTick = 0
	local Flow = getFlow()
	for _, t in ipairs(getNPCs()) do
		pcall(function() Flow.NPCs.Damage(t.h, 999999) end)
	end
end

local function ragdollNPCs()
	local Flow = getFlow()
	local n = 0
	for _, t in ipairs(getNPCs()) do
		pcall(function() Flow.RagdollClient.ChangeNPCState(t.h, Enum.HumanoidStateType.Ragdoll) end)
		n = n + 1
	end
	return n
end

local function threatenNPCs()
	local Flow = getFlow()
	local n = 0
	for _, t in ipairs(getNPCs()) do
		pcall(function() Flow.NPCs.Threaten(t.h) end)
		n = n + 1
	end
	return n
end

local pickupTick = 0
local droppedInst = {}
local dropTracked = false
local function trackDrops()
	local pb = lp:FindFirstChild("Backpack")
	if pb then
		pb.ChildRemoved:Connect(function(child)
			if child:IsA("Tool") then droppedInst[child] = os.clock() end
		end)
	end
	local char = lp.Character
	if char then
		char.ChildRemoved:Connect(function(child)
			if child:IsA("Tool") then droppedInst[child] = os.clock() end
		end)
	end
	dropTracked = true
end
local function isRecentlyDropped(inst)
	local t = droppedInst[inst]
	return t ~= nil and os.clock() - t < 8
end
local function pickupLoop(dt)
	if not (S.autoPickup or S.autoCash) then return end
	if not dropTracked then trackDrops() end
	pickupTick = pickupTick + dt
	if pickupTick < 0.12 then return end
	pickupTick = 0
	local char = lp.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local Flow = getFlow()
	if S.autoCash then
		for _, c in CollectionService:GetTagged("Cash") do
			if c.Parent and c:IsA("BasePart") and c:IsDescendantOf(workspace) and not c:IsDescendantOf(lp) then
				if (c.Position - hrp.Position).Magnitude < 40 then
					pcall(function() Flow.Cash.Collect(c) end)
				end
			end
		end
	end
	if S.autoPickup then
		for _, m in CollectionService:GetTagged("Equippable") do
			local skip = false
			if not (m.Parent and (m:IsA("Tool") or m:IsA("Model"))) then
				skip = true
			elseif m:IsDescendantOf(lp) then
				skip = true
			elseif not m:IsDescendantOf(workspace) then
				skip = true
			elseif isRecentlyDropped(m) then
				skip = true
			end
			if not skip then
				local part = m.PrimaryPart or m:FindFirstChildOfClass("BasePart")
				if part then
					local dd = (part.Position - hrp.Position).Magnitude
					if dd < S.pickupRange then
						local ok, res = pcall(function() return Flow.Loot.LootEquip(part) end)
						if ok and res == "Success" then
							task.wait(0.05)
						end
					end
				end
			end
		end
	end
end

local Controls = nil
pcall(function()
	local playerScripts = lp:WaitForChild("PlayerScripts")
	local playerModule = require(playerScripts:WaitForChild("PlayerModule"))
	Controls = playerModule:GetControls()
end)

local flyParts = {}
local vertButtons = {}
local function startFly()
	if flyParts.bv then return end
	local char = lp.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(9e4, 9e4, 9e4)
	bv.Parent = hrp
	local bg = Instance.new("BodyGyro")
	bg.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
	bg.D = 100
	bg.P = 1000
	bg.Parent = hrp
	flyParts = { bv = bv, bg = bg, hum = hum }
	if hum then
		hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
		hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	end
	for _, b in ipairs(vertButtons) do
		if b and b.Parent then b.Visible = true end
	end
end
local function stopFly()
	if flyParts.bv then
		flyParts.bv:Destroy()
		flyParts.bg:Destroy()
		flyParts = {}
	end
	S.vertical = 0
	for _, b in ipairs(vertButtons) do
		if b and b.Parent then b.Visible = false end
	end
end
local function flyLoop(dt)
	if not S.fly then return end
	if not flyParts.bv then startFly() end
	local char = lp.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local cam = workspace.CurrentCamera
	if not (hrp and cam and flyParts.bv) then return end
	local move = Vector3.new()
	if Controls and type(Controls.GetMoveVector) == "function" then
		local ok, mv = pcall(function() return Controls:GetMoveVector() end)
		if ok and typeof(mv) == "Vector3" and mv.Magnitude > 0.01 then
			move = cam.CFrame.RightVector * mv.X + cam.CFrame.LookVector * (-mv.Z)
		end
	end
	if move.Magnitude <= 0.01 then
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
	end
	if S.vertical ~= 0 then move = move + Vector3.new(0, S.vertical, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
	if move.Magnitude > 0 then move = move.Unit * S.flySpeed end
	flyParts.bv.Velocity = move
	flyParts.bg.CFrame = cam.CFrame
end

local moveConn = nil
local function startMove()
	if moveConn then return end
	moveConn = RunService.Stepped:Connect(function()
		local c = lp.Character
		local hum = c and c:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = S.speed
			hum.JumpPower = S.jump
		end
	end)
end

local chams = {}
local itemChams = {}
local nameTags = {}
local lastScan = 0
local function refreshESP(dt)
	lastScan = lastScan + dt
	local doScan = lastScan > 0.3
	if doScan then lastScan = 0 end
	local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
	local npcs = getNPCs()
	local seen = {}
	for _, t in npcs do
		seen[t.m] = true
		if doScan then
			if S.chamsNPC then
				if not chams[t.m] then
					local h = Instance.new("Highlight")
					h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					h.FillColor = Color3.fromRGB(255, 60, 60)
					h.FillTransparency = 0.5
					h.OutlineColor = Color3.fromRGB(255, 255, 255)
					h.Parent = t.m
					chams[t.m] = h
				end
			elseif chams[t.m] then
				chams[t.m]:Destroy()
				chams[t.m] = nil
			end
			if S.showNames then
				if not nameTags[t.m] then
					local head = t.m:FindFirstChild("Head")
					if head then
						local bg = Instance.new("BillboardGui")
						bg.Name = "OmegaName"
						bg.AlwaysOnTop = true
						bg.Size = UDim2.fromOffset(200, 40)
						bg.MaxDistance = 800
						bg.Adornee = head
						local lab = Instance.new("TextLabel")
						lab.Size = UDim2.fromScale(1, 1)
						lab.BackgroundTransparency = 1
						lab.Font = Enum.Font.GothamBold
						lab.TextSize = 13
						lab.TextColor3 = Color3.fromRGB(255, 255, 255)
						lab.TextStrokeTransparency = 0
						lab.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
						lab.Parent = bg
						bg.Parent = head
						nameTags[t.m] = { bg = bg, lab = lab }
					end
				end
			elseif nameTags[t.m] then
				nameTags[t.m].bg:Destroy()
				nameTags[t.m] = nil
			end
		end
		if nameTags[t.m] then
			local txt = t.m.Name
			if hrp then
				local root = t.m:FindFirstChild("HumanoidRootPart")
				if root and S.showDist then
					txt = txt .. "  " .. math.floor((root.Position - hrp.Position).Magnitude) .. "m"
				end
			end
			txt = txt .. "  HP" .. math.floor(t.h.Health)
			nameTags[t.m].lab.Text = txt
		end
	end
	local itemSeen = {}
	if S.itemESP and hrp then
		for _, m in CollectionService:GetTagged("Equippable") do
			if m.Parent then
				itemSeen[m] = true
				if not itemChams[m] then
					local part = m.PrimaryPart or m:FindFirstChildOfClass("BasePart")
					if part then
						local h = Instance.new("Highlight")
						h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						h.FillColor = Color3.fromRGB(80, 255, 120)
						h.FillTransparency = 0.6
						h.OutlineColor = Color3.fromRGB(255, 255, 255)
						h.OutlineTransparency = 0.4
						h.Parent = m
						itemChams[m] = h
					end
				end
			end
		end
		for _, c in CollectionService:GetTagged("Cash") do
			if c.Parent and c:IsA("BasePart") then
				local mm = c:FindFirstAncestorWhichIsA("Model") or c.Parent
				if mm then
					itemSeen[mm] = true
					if not itemChams[mm] then
						local h = Instance.new("Highlight")
						h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						h.FillColor = Color3.fromRGB(255, 220, 60)
						h.FillTransparency = 0.6
						h.OutlineColor = Color3.fromRGB(255, 255, 255)
						h.OutlineTransparency = 0.4
						h.Parent = mm
						itemChams[mm] = h
					end
				end
			end
		end
	end
	if doScan then
		for m, h in pairs(chams) do
			if not seen[m] or not m.Parent then
				h:Destroy()
				chams[m] = nil
			end
		end
		for m, tag in pairs(nameTags) do
			if not seen[m] or not m.Parent then
				tag.bg:Destroy()
				nameTags[m] = nil
			end
		end
		for m, h in pairs(itemChams) do
			if not itemSeen[m] or not m.Parent then
				h:Destroy()
				itemChams[m] = nil
			end
		end
	end
end

local aimConn = nil
local function startAim()
	if aimConn then return end
	aimConn = RunService.RenderStepped:Connect(function()
		local char = lp.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local best, bestD = nil, S.aimRange
		for _, t in ipairs(getNPCs()) do
			local head = t.m:FindFirstChild("Head")
			if head then
				local d = (head.Position - hrp.Position).Magnitude
				if d < bestD then
					best = head
					bestD = d
				end
			end
		end
		if best then
			local gyro = hrp:FindFirstChild("OmegaAim")
			if not gyro then
				gyro = Instance.new("BodyGyro")
				gyro.Name = "OmegaAim"
				gyro.MaxTorque = Vector3.new(0, 10000, 0)
				gyro.D = 60
				gyro.P = 900
				gyro.Parent = hrp
			end
			gyro.CFrame = CFrame.lookAt(hrp.Position, best.Position)
		end
	end)
end
local function stopAim()
	if aimConn then
		aimConn:Disconnect()
		aimConn = nil
	end
	local char = lp.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local gyro = hrp and hrp:FindFirstChild("OmegaAim")
	if gyro then gyro:Destroy() end
end

local function AddCorner(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = obj
	return c
end

local RAINBOW_FLOW = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 82, 126)),
	ColorSequenceKeypoint.new(0.14, Color3.fromRGB(255, 178, 78)),
	ColorSequenceKeypoint.new(0.28, Color3.fromRGB(255, 246, 112)),
	ColorSequenceKeypoint.new(0.43, Color3.fromRGB(102, 255, 176)),
	ColorSequenceKeypoint.new(0.58, Color3.fromRGB(86, 230, 255)),
	ColorSequenceKeypoint.new(0.72, Color3.fromRGB(126, 138, 255)),
	ColorSequenceKeypoint.new(0.86, Color3.fromRGB(236, 92, 255)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 82, 126))
})

local function StartRainbowFlow(parent, duration, transparency)
	local grad = Instance.new("UIGradient")
	grad.Name = "RainbowFlow"
	grad.Color = RAINBOW_FLOW
	grad.Transparency = transparency or NumberSequence.new(0)
	grad.Rotation = -180
	grad.Parent = parent
	local tw = TweenService:Create(grad, TweenInfo.new(duration or 2.0, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, 0), {Rotation = 180})
	tw:Play()
	return grad, tw
end

local function AddRainbowBorder(obj, thickness, transparency, speed)
	local stroke = Instance.new("UIStroke")
	stroke.Name = "DB_RainbowMain"
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Thickness = thickness or 0.9
	stroke.Color = Color3.new(1, 1, 1)
	stroke.Transparency = transparency or 0.01
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	stroke.Parent = obj
	local grad = StartRainbowFlow(stroke, speed or 1.95)
	return stroke, grad
end

local function AddBorder(obj, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Thickness = thickness or 0.85
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = transparency or 0.52
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	stroke.Parent = obj
	return stroke
end

local function StyleButton(btn, radius)
	btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	btn.BackgroundTransparency = 0.84
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBlack
	btn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	btn.TextStrokeTransparency = 0.62
	AddCorner(btn, radius or 9)
	AddBorder(btn, 0.85, 0.52)
	local scale = Instance.new("UIScale")
	scale.Name = "DB_Scale"
	scale.Scale = 1
	scale.Parent = btn
	btn.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		TweenService:Create(scale, TweenInfo.new(0.055, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.965}):Play()
	end)
	btn.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		TweenService:Create(scale, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	end)
end

local function CreateToggleRow(parent, title, getValue, onChange)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -12, 0, 36)
	row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	row.BackgroundTransparency = 0.88
	row.BorderSizePixel = 0
	row.Parent = parent
	AddCorner(row, 8)
	AddBorder(row, 0.7, 0.6)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -66, 1, 0)
	label.Position = UDim2.fromOffset(12, 0)
	label.BackgroundTransparency = 1
	label.Text = title
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 12
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Parent = row

	local enabled = getValue and getValue() or false
	local switch = Instance.new("TextButton")
	switch.AnchorPoint = Vector2.new(1, 0.5)
	switch.Position = UDim2.new(1, -12, 0.5, 0)
	switch.Size = UDim2.fromOffset(44, 22)
	switch.BackgroundColor3 = enabled and Color3.fromRGB(205, 210, 220) or Color3.fromRGB(62, 65, 72)
	switch.BackgroundTransparency = 0.12
	switch.BorderSizePixel = 0
	switch.Text = ""
	switch.AutoButtonColor = false
	switch.Parent = row
	AddCorner(switch, 999)

	local knob = Instance.new("Frame")
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = enabled and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0)
	knob.Size = UDim2.fromOffset(17, 17)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BackgroundTransparency = 0
	knob.BorderSizePixel = 0
	knob.Parent = switch
	AddCorner(knob, 999)

	switch.Activated:Connect(function()
		enabled = not enabled
		if onChange then pcall(onChange, enabled) end
		TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = enabled and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0)}):Play()
		TweenService:Create(switch, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = enabled and Color3.fromRGB(205, 210, 220) or Color3.fromRGB(62, 65, 72)}):Play()
	end)
	return row
end

local function CreateButtonRow(parent, title, onClick)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -12, 0, 34)
	btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	btn.BackgroundTransparency = 0.88
	btn.BorderSizePixel = 0
	btn.Text = title
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamBlack
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.TextTruncate = Enum.TextTruncate.AtEnd
	btn.AutoButtonColor = false
	btn.Parent = parent
	StyleButton(btn, 8)
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 12)
	pad.PaddingRight = UDim.new(0, 12)
	pad.Parent = btn
	btn.Activated:Connect(function()
		if onClick then pcall(onClick) end
	end)
	return btn
end

local function CreateSliderRow(parent, title, min, max, def, step, onChange)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -12, 0, 62)
	row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	row.BackgroundTransparency = 0.88
	row.BorderSizePixel = 0
	row.Parent = parent
	AddCorner(row, 8)
	AddBorder(row, 0.7, 0.6)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 0, 18)
	label.Position = UDim2.fromOffset(12, 3)
	label.BackgroundTransparency = 1
	label.Text = title .. "：" .. tostring(def)
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 11
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local track = Instance.new("Frame")
	track.Position = UDim2.new(0, 14, 0, 38)
	track.Size = UDim2.new(1, -28, 0, 5)
	track.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	track.BackgroundTransparency = 0.75
	track.BorderSizePixel = 0
	track.Active = true
	track.Parent = row
	AddCorner(track, 999)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	fill.BackgroundTransparency = 0.02
	fill.BorderSizePixel = 0
	fill.Parent = track
	AddCorner(fill, 999)

	local knob = Instance.new("Frame")
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(0, 0, 0.5, 0)
	knob.Size = UDim2.fromOffset(14, 14)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BackgroundTransparency = 0
	knob.BorderSizePixel = 0
	knob.Active = false
	knob.Parent = track
	AddCorner(knob, 999)

	local dragging = false
	local dragInput = nil
	local function ApplyRatio(ratio, fireCallback)
		ratio = math.clamp(ratio, 0, 1)
		local snapped = math.clamp(math.floor((min + (max - min) * ratio) / step + 0.5) * step, min, max)
		local r2 = (snapped - min) / (max - min)
		fill.Size = UDim2.new(r2, 0, 1, 0)
		knob.Position = UDim2.new(r2, 0, 0.5, 0)
		label.Text = title .. "：" .. tostring(snapped)
		if fireCallback and onChange then pcall(onChange, snapped) end
	end
	local function ApplyFromInput(pos)
		if not track.Parent then return end
		local x = DBSpatial and DBSpatial.InputAxis and DBSpatial.InputAxis(track, pos, "X") or (pos and pos.X)
		if not x then return end
		local width = math.max(1, track.AbsoluteSize.X)
		ApplyRatio((x - track.AbsolutePosition.X) / width, true)
	end
	ApplyRatio((def - min) / (max - min), false)
	track.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		dragging = true
		dragInput = input
		ApplyFromInput(input.Position)
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging or not track.Parent then return end
		if input.UserInputType == Enum.UserInputType.Touch then
			if input ~= dragInput then return end
		elseif input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		ApplyFromInput(input.Position)
	end)
	UserInputService.InputEnded:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.Touch then
			if input ~= dragInput then return end
		elseif input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		dragging = false
		dragInput = nil
	end)
	return row
end

local function Notify(title, text)
	pcall(function()
		local pg = lp:WaitForChild("PlayerGui")
		local old = pg:FindFirstChild("TX_RunnerNotify")
		if old then old:Destroy() end
		local frame = Instance.new("Frame")
		frame.Name = "TX_RunnerNotify"
		frame.AnchorPoint = Vector2.new(1, 1)
		frame.Position = UDim2.new(1, -16, 1, -16)
		frame.Size = UDim2.fromOffset(280, 54)
		frame.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
		frame.BackgroundTransparency = 0.25
		frame.BorderSizePixel = 0
		frame.ZIndex = 5000
		frame.Parent = pg
		AddCorner(frame, 12)
		AddBorder(frame, 1, 0.35)
		local t1 = Instance.new("TextLabel")
		t1.Size = UDim2.new(1, -20, 0, 18)
		t1.Position = UDim2.fromOffset(10, 5)
		t1.BackgroundTransparency = 1
		t1.Text = title
		t1.TextColor3 = Color3.fromRGB(255, 255, 255)
		t1.TextSize = 12
		t1.Font = Enum.Font.GothamBlack
		t1.TextXAlignment = Enum.TextXAlignment.Left
		t1.Parent = frame
		local t2 = Instance.new("TextLabel")
		t2.Size = UDim2.new(1, -20, 0, 22)
		t2.Position = UDim2.fromOffset(10, 25)
		t2.BackgroundTransparency = 1
		t2.Text = text
		t2.TextColor3 = Color3.fromRGB(200, 210, 230)
		t2.TextSize = 10
		t2.Font = Enum.Font.GothamMedium
		t2.TextXAlignment = Enum.TextXAlignment.Left
		t2.Parent = frame
		task.delay(3, function()
			if frame and frame.Parent then
				TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
				task.delay(0.35, function() if frame and frame.Parent then frame:Destroy() end end)
			end
		end)
	end)
end

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "TX_Runner_Panel"
MainGui.ResetOnSpawn = false
MainGui.IgnoreGuiInset = true
MainGui.DisplayOrder = 999
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local pg = lp:WaitForChild("PlayerGui", 10)
MainGui.Parent = pg

local IntroGui = Instance.new("Frame")
IntroGui.Name = "TX_Intro"
IntroGui.Size = UDim2.fromScale(1, 1)
IntroGui.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
IntroGui.BackgroundTransparency = 1
IntroGui.BorderSizePixel = 0
IntroGui.ZIndex = 10000
IntroGui.Active = true
IntroGui.ClipsDescendants = true
IntroGui.Parent = MainGui

local IntroTitle = Instance.new("TextLabel")
IntroTitle.AnchorPoint = Vector2.new(0.5, 0.5)
IntroTitle.Position = UDim2.fromScale(0.5, 0.42)
IntroTitle.Size = UDim2.new(0, 320, 0, 64)
IntroTitle.BackgroundTransparency = 1
IntroTitle.Text = "逃跑者"
IntroTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroTitle.TextTransparency = 1
IntroTitle.TextSize = 48
IntroTitle.Font = Enum.Font.GothamBlack
IntroTitle.ZIndex = 10002
IntroTitle.Parent = IntroGui
AddBorder(IntroTitle, 1.4, 0.15)
StartRainbowFlow(IntroTitle, 2.2, NumberSequence.new(0))

local IntroSub = Instance.new("TextLabel")
IntroSub.AnchorPoint = Vector2.new(0.5, 1)
IntroSub.Position = UDim2.new(0.5, 0, 0.72, 0)
IntroSub.Size = UDim2.new(0, 300, 0, 26)
IntroSub.BackgroundTransparency = 1
IntroSub.Text = "欢迎：" .. lp.Name
IntroSub.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroSub.TextTransparency = 1
IntroSub.TextSize = 15
IntroSub.Font = Enum.Font.GothamMedium
IntroSub.ZIndex = 10002
IntroSub.Parent = IntroGui

TweenService:Create(IntroGui, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.25}):Play()
task.wait(0.15)
TweenService:Create(IntroTitle, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
TweenService:Create(IntroSub, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
task.wait(1.7)
TweenService:Create(IntroGui, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
TweenService:Create(IntroTitle, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
TweenService:Create(IntroSub, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
task.wait(0.5)
if IntroGui.Parent then IntroGui:Destroy() end

local PANEL_W, PANEL_H = 440, 400
local Panel = Instance.new("Frame")
Panel.Name = "Panel"
Panel.AnchorPoint = Vector2.new(0.5, 0.5)
Panel.Position = UDim2.fromScale(0.5, 0.5)
Panel.Size = UDim2.fromOffset(PANEL_W, PANEL_H)
Panel.BackgroundTransparency = 1
Panel.BorderSizePixel = 0
Panel.Active = true
Panel.Parent = MainGui

local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Position = UDim2.fromOffset(2, 2)
Body.Size = UDim2.new(1, -4, 1, -4)
Body.BackgroundColor3 = Color3.fromRGB(6, 8, 12)
Body.BackgroundTransparency = 0.12
Body.BorderSizePixel = 0
Body.ClipsDescendants = true
Body.Parent = Panel
AddCorner(Body, 14)
AddRainbowBorder(Body, 1.5, 0.02, 2.6)

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundTransparency = 1
Header.Active = true
Header.Parent = Body

local TitleLabel = Instance.new("TextLabel")
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.fromOffset(12, 3)
TitleLabel.Size = UDim2.new(0, 130, 0, 24)
TitleLabel.Text = "逃跑者"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header
StartRainbowFlow(TitleLabel, 4.0, NumberSequence.new(0))

local SubLabel = Instance.new("TextLabel")
SubLabel.BackgroundTransparency = 1
SubLabel.Position = UDim2.fromOffset(150, 8)
SubLabel.Size = UDim2.new(1, -240, 0, 14)
SubLabel.Text = "天休制作"
SubLabel.TextColor3 = Color3.fromRGB(190, 200, 215)
SubLabel.TextSize = 9
SubLabel.Font = Enum.Font.GothamMedium
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent = Header

local DragArea = Instance.new("TextButton")
DragArea.Name = "DragArea"
DragArea.Size = UDim2.new(1, -58, 1, 0)
DragArea.BackgroundTransparency = 1
DragArea.BorderSizePixel = 0
DragArea.Text = ""
DragArea.AutoButtonColor = false
DragArea.Active = true
DragArea.Parent = Header

local panelDrag = { active = false, start = nil, pos = nil, touch = nil }
local function StartPanelDrag(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	panelDrag.active = true
	panelDrag.start = input.Position
	panelDrag.pos = Panel.Position
	if input.UserInputType == Enum.UserInputType.Touch then panelDrag.touch = input end
end
DragArea.InputBegan:Connect(StartPanelDrag)
Header.InputBegan:Connect(StartPanelDrag)
Panel.InputBegan:Connect(StartPanelDrag)
UserInputService.InputChanged:Connect(function(input)
	if not panelDrag.active then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement then
	elseif input.UserInputType == Enum.UserInputType.Touch and input == panelDrag.touch then
	else
		return
	end
	local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
	local maxX = vp.X - PANEL_W / 2 - 30
	local maxY = vp.Y - PANEL_H / 2 - 30
	local minX = PANEL_W / 2 - vp.X + 30
	local minY = PANEL_H / 2 - vp.Y + 30
	local dx = math.clamp(panelDrag.pos.X.Offset + (input.Position.X - panelDrag.start.X), minX, maxX)
	local dy = math.clamp(panelDrag.pos.Y.Offset + (input.Position.Y - panelDrag.start.Y), minY, maxY)
	Panel.Position = UDim2.new(0.5, dx, 0.5, dy)
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	panelDrag.active = false
	panelDrag.touch = nil
end)

local MiniBtn = Instance.new("TextButton")
MiniBtn.Name = "Mini"
MiniBtn.Position = UDim2.new(1, -56, 0, 2)
MiniBtn.Size = UDim2.fromOffset(26, 26)
MiniBtn.BackgroundTransparency = 1
MiniBtn.BorderSizePixel = 0
MiniBtn.Text = "−"
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.TextSize = 20
MiniBtn.Font = Enum.Font.GothamMedium
MiniBtn.AutoButtonColor = false
MiniBtn.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "Close"
CloseBtn.Position = UDim2.new(1, -28, 0, 2)
CloseBtn.Size = UDim2.fromOffset(26, 26)
CloseBtn.BackgroundTransparency = 1
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header

local Divider = Instance.new("Frame")
Divider.Position = UDim2.new(0, 0, 0, 30)
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.BackgroundColor3 = Color3.fromRGB(150, 205, 240)
Divider.BackgroundTransparency = 0.72
Divider.BorderSizePixel = 0
Divider.Parent = Body

local NAV_W = 112
local NavRail = Instance.new("Frame")
NavRail.Name = "NavRail"
NavRail.Position = UDim2.fromOffset(0, 31)
NavRail.Size = UDim2.new(0, NAV_W, 1, -31)
NavRail.BackgroundTransparency = 1
NavRail.Parent = Body

local ContentHost = Instance.new("Frame")
ContentHost.Name = "ContentHost"
ContentHost.Position = UDim2.new(0, NAV_W + 1, 0, 31)
ContentHost.Size = UDim2.new(1, -(NAV_W + 1), 1, -31)
ContentHost.BackgroundTransparency = 1
ContentHost.ClipsDescendants = true
ContentHost.Parent = Body

local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, -10, 1, -8)
ContentScroll.Position = UDim2.fromOffset(5, 4)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 2
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(205, 205, 210)
ContentScroll.ScrollBarImageTransparency = 0.5
ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentScroll.CanvasSize = UDim2.new()
ContentScroll.ScrollingDirection = Enum.ScrollingDirection.Y
ContentScroll.Active = true
ContentScroll.ScrollingEnabled = true
ContentScroll.Parent = ContentHost

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 5)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = ContentScroll

local NavLayout = Instance.new("UIListLayout")
NavLayout.Padding = UDim.new(0, 5)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
NavLayout.Parent = NavRail

local NavPad = Instance.new("UIPadding")
NavPad.PaddingTop = UDim.new(0, 5)
NavPad.PaddingLeft = UDim.new(0, 4)
NavPad.PaddingRight = UDim.new(0, 4)
NavPad.Parent = NavRail

local currentCategory = "战斗"
local navButtons = {}

local function RenderCategory(cat)
	for _, child in ipairs(ContentScroll:GetChildren()) do
		if child:IsA("GuiObject") and child ~= ContentLayout then
			child:Destroy()
		end
	end
	ContentScroll.CanvasPosition = Vector2.new(0, 0)

	if cat == "战斗" then
		CreateToggleRow(ContentScroll, "全图秒杀 NPC", function() return S.nuke end, function(v) S.nuke = v end)
		CreateButtonRow(ContentScroll, "NPC 全部布娃娃", function()
			local n = ragdollNPCs()
			Notify("逃跑者", "已布娃娃 " .. n .. " 个 NPC")
		end)
		CreateButtonRow(ContentScroll, "NPC 全部威胁", function()
			local n = threatenNPCs()
			Notify("逃跑者", "已威胁 " .. n .. " 个 NPC")
		end)
		CreateToggleRow(ContentScroll, "自瞄锁 NPC", function() return S.aimbot end, function(v)
			S.aimbot = v
			if v then startAim() else stopAim() end
		end)
		CreateSliderRow(ContentScroll, "锁定距离", 20, 500, S.aimRange, 10, function(v) S.aimRange = v end)
	elseif cat == "视觉" then
		CreateToggleRow(ContentScroll, "NPC Chams", function() return S.chamsNPC end, function(v) S.chamsNPC = v end)
		CreateToggleRow(ContentScroll, "物品 ESP", function() return S.itemESP end, function(v) S.itemESP = v end)
		CreateToggleRow(ContentScroll, "显示名字", function() return S.showNames end, function(v) S.showNames = v end)
		CreateToggleRow(ContentScroll, "距离/血量", function() return S.showDist end, function(v) S.showDist = v end)
		CreateToggleRow(ContentScroll, "夜视", function() return S.nightVision end, function(v)
			S.nightVision = v
			game.Lighting.Ambient = v and Color3.fromRGB(95, 95, 95) or Color3.fromRGB(128, 128, 128)
		end)
		CreateSliderRow(ContentScroll, "视野 FOV", 30, 120, S.fov, 1, function(v)
			S.fov = v
			workspace.CurrentCamera.FieldOfView = v
		end)
	elseif cat == "移动" then
		CreateToggleRow(ContentScroll, "飞行(摇杆/键盘)", function() return S.fly end, function(v)
			S.fly = v
			if v then startFly() else stopFly() end
		end)
		CreateSliderRow(ContentScroll, "飞行速度", 20, 200, S.flySpeed, 5, function(v) S.flySpeed = v end)
		CreateSliderRow(ContentScroll, "移速", 16, 100, S.speed, 1, function(v)
			S.speed = v
			startMove()
		end)
		CreateSliderRow(ContentScroll, "跳跃高度", 25, 300, S.jump, 5, function(v)
			S.jump = v
			startMove()
		end)
	elseif cat == "拾取" then
		local hint = Instance.new("TextLabel")
		hint.Name = "PickupHint"
		hint.Size = UDim2.new(1, -12, 0, 24)
		hint.BackgroundTransparency = 1
		hint.Text = "⚠ 不能隔墙拾取"
		hint.TextColor3 = Color3.fromRGB(255, 205, 120)
		hint.TextSize = 10
		hint.Font = Enum.Font.GothamMedium
		hint.TextXAlignment = Enum.TextXAlignment.Left
		hint.Parent = ContentScroll
		CreateToggleRow(ContentScroll, "自动拾取", function() return S.autoPickup end, function(v) S.autoPickup = v end)
		CreateToggleRow(ContentScroll, "自动捡钱", function() return S.autoCash end, function(v) S.autoCash = v end)
		CreateSliderRow(ContentScroll, "拾取范围", 10, 99999, S.pickupRange, 50, function(v) S.pickupRange = v end)
	end
end

local categories = { "战斗", "视觉", "移动", "拾取" }
for i, cat in ipairs(categories) do
	local btn = Instance.new("TextButton")
	btn.Name = "Nav_" .. cat
	btn.Size = UDim2.new(1, -8, 0, 34)
	btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	btn.BackgroundTransparency = 0.86
	btn.BorderSizePixel = 0
	btn.Text = cat
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 13
	btn.Font = Enum.Font.GothamBlack
	btn.TextXAlignment = Enum.TextXAlignment.Center
	btn.AutoButtonColor = false
	btn.LayoutOrder = i
	btn.Parent = NavRail
	StyleButton(btn, 8)
	btn.Activated:Connect(function()
		currentCategory = cat
		RenderCategory(cat)
		for _, b in ipairs(navButtons) do
			b.BackgroundTransparency = 0.88
			b.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
		btn.BackgroundTransparency = 0.68
		btn.TextColor3 = Color3.fromRGB(190, 235, 255)
	end)
	table.insert(navButtons, btn)
end

local Floating = Instance.new("TextButton")
Floating.Name = "TX_Floating"
Floating.AnchorPoint = Vector2.new(0.5, 0.5)
Floating.Position = UDim2.new(1, -70, 0.5, 0)
Floating.Size = UDim2.fromOffset(58, 34)
Floating.BackgroundColor3 = Color3.fromRGB(6, 9, 13)
Floating.BackgroundTransparency = 0.1
Floating.BorderSizePixel = 0
Floating.Text = "逃跑者"
Floating.TextColor3 = Color3.fromRGB(255, 255, 255)
Floating.TextSize = 12
Floating.Font = Enum.Font.GothamBlack
Floating.Visible = false
Floating.ZIndex = 200
Floating.Parent = MainGui
AddCorner(Floating, 999)
AddRainbowBorder(Floating, 1.4, 0.02, 2.8)

local floatDrag = { active = false, start = nil, pos = nil, touch = nil, moved = false, suppressUntil = 0 }
Floating.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	floatDrag.active = true
	floatDrag.start = input.Position
	floatDrag.pos = Floating.Position
	floatDrag.moved = false
	if input.UserInputType == Enum.UserInputType.Touch then floatDrag.touch = input end
end)
UserInputService.InputChanged:Connect(function(input)
	if not floatDrag.active then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement then
	elseif input.UserInputType == Enum.UserInputType.Touch and input == floatDrag.touch then
	else
		return
	end
	local delta = input.Position - floatDrag.start
	if delta.Magnitude >= 7 then floatDrag.moved = true end
	Floating.Position = UDim2.new(floatDrag.pos.X.Scale, floatDrag.pos.X.Offset + delta.X, floatDrag.pos.Y.Scale, floatDrag.pos.Y.Offset + delta.Y)
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	if floatDrag.active and floatDrag.moved then
		floatDrag.suppressUntil = os.clock() + 0.3
	end
	floatDrag.active = false
	floatDrag.touch = nil
end)
Floating.Activated:Connect(function()
	if floatDrag.moved or os.clock() < floatDrag.suppressUntil then
		floatDrag.moved = false
		return
	end
	Floating.Visible = false
	Panel.Visible = true
end)

MiniBtn.Activated:Connect(function()
	Panel.Visible = false
	Floating.Visible = true
end)

local function CreateVertButton(name, text, pos, value)
	local b = Instance.new("TextButton")
	b.Name = name
	b.AnchorPoint = Vector2.new(1, 0.5)
	b.Position = pos
	b.Size = UDim2.fromOffset(64, 64)
	b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	b.BackgroundTransparency = 0.74
	b.BorderSizePixel = 0
	b.Text = text
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.TextSize = 30
	b.Font = Enum.Font.GothamBold
	b.ZIndex = 300
	b.Visible = false
	b.Parent = MainGui
	AddCorner(b, 999)
	b.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
			S.vertical = value
		end
	end)
	b.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
			if S.vertical == value then S.vertical = 0 end
		end
	end)
	table.insert(vertButtons, b)
	return b
end
CreateVertButton("TX_FlyUp", "▲", UDim2.new(1, -86, 0.5, -78), 1)
CreateVertButton("TX_FlyDown", "▼", UDim2.new(1, -86, 0.5, 12), -1)

local mainConn = RunService.RenderStepped:Connect(function(dt)
	nukeLoop(dt)
	pickupLoop(dt)
	flyLoop(dt)
	refreshESP(dt)
end)

local function Shutdown()
	pcall(stopFly)
	pcall(stopAim)
	if moveConn then pcall(function() moveConn:Disconnect() end) end
	if mainConn then pcall(function() mainConn:Disconnect() end) end
	pcall(function()
		if MainGui and MainGui.Parent then MainGui:Destroy() end
	end)
	Notify("逃跑者", "已关闭")
end
CloseBtn.Activated:Connect(Shutdown)

RenderCategory("战斗")
if navButtons[1] then
	navButtons[1].BackgroundTransparency = 0.68
	navButtons[1].TextColor3 = Color3.fromRGB(190, 235, 255)
end

task.wait(0.2)
Notify("逃跑者", "大肥鱼脚本 8.90 加载成功")
print("✅ 逃跑者 · 大肥鱼脚本 8.90 已加载")

]====]},
{Name = "动物医院", Url = "https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/FN_AnimalHospital.lua"},
{Name = "门｜群友提供@噬", Url = "https://api.luarmor.net/files/v4/loaders/730854e5b6499ee91deb1080e8e12ae3.lua"},
{Name = "恐鬼症", Code = [[loadstring(game:HttpGet('https://raw.githubusercontent.com/Aoruen/Roblox-Stuff/refs/heads/main/Dusty%20Trip%20Gui%20V2.lua'))()]]},
{Name = "森林中的99夜", Code = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/FoxnameHub.lua"))()]]},
{Name = "彩虹朋友1", Code = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/Iliankytb/Iliankytb/main/BestRainbowFriendOne"))()]]},
{Name = "死铁轨", Code = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/erewe23/deadrailsring.github.io/refs/heads/main/ringta.lua"))()]]},
{
Name = "一次尘土飞扬的旅行",
Code = [[loadstring(game:HttpGet("https://rawscripts.net/raw/a-dusty-trip-SHOP-KEYLESS-Dusty-Trip-Gui-V2-135343"))()]]
}
},
["非对称竞技"] = {
{Name = "被遗弃｜群友提供@噬", Url = "https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/ainianniang.lua"},
{Name = "致命猿猴", Url = "https://raw.githubusercontent.com/Anzzckc/Lethal-Ape-Beta/refs/heads/main/Lethal%20Ape%20Beta.lua"},
{Name = "暴力区", Code = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/lixxWW/ViolenceDistrict/refs/heads/main/ViolenceDistrict.lua"))()]]},
        {Name = "躲避恶人｜天休制作", Code = [====[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

if not game:IsLoaded() then game.Loaded:Wait() end

local S = {
    crateChams = true,
    playerEsp = true,
    instantInteract = false,
    closed = false,
}

local RAINBOW_FLOW = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 82, 126)),
    ColorSequenceKeypoint.new(0.14, Color3.fromRGB(255, 146, 82)),
    ColorSequenceKeypoint.new(0.28, Color3.fromRGB(255, 218, 82)),
    ColorSequenceKeypoint.new(0.42, Color3.fromRGB(142, 255, 82)),
    ColorSequenceKeypoint.new(0.56, Color3.fromRGB(82, 224, 255)),
    ColorSequenceKeypoint.new(0.70, Color3.fromRGB(98, 130, 255)),
    ColorSequenceKeypoint.new(0.86, Color3.fromRGB(236, 92, 255)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 82, 126)),
})

local function AddCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
end

local function StartRainbowFlow(parent, duration, transparency)
    local grad = Instance.new("UIGradient")
    grad.Name = "RainbowFlow"
    grad.Color = RAINBOW_FLOW
    grad.Transparency = transparency or NumberSequence.new(0)
    grad.Rotation = -180
    grad.Parent = parent
    local tw = TweenService:Create(grad, TweenInfo.new(duration or 2.0, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, 0), { Rotation = 180 })
    tw:Play()
    return grad, tw
end

local function AddRainbowBorder(obj, thickness, transparency, speed)
    local stroke = Instance.new("UIStroke")
    stroke.Name = "DB_RainbowMain"
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = thickness or 0.9
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Transparency = transparency or 0.01
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = obj
    local grad = StartRainbowFlow(stroke, speed or 1.95)
    return stroke, grad
end

local function AddBorder(obj, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = thickness or 0.85
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = transparency or 0.52
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = obj
    return stroke
end

local function CreateToggleRow(parent, title, getValue, onChange)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -12, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    row.BackgroundTransparency = 0.88
    row.BorderSizePixel = 0
    row.Parent = parent
    AddCorner(row, 8)
    AddBorder(row, 0.7, 0.6)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -66, 1, 0)
    label.Position = UDim2.fromOffset(12, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = row
    local enabled = getValue and getValue() or false
    local switch = Instance.new("TextButton")
    switch.AnchorPoint = Vector2.new(1, 0.5)
    switch.Position = UDim2.new(1, -12, 0.5, 0)
    switch.Size = UDim2.fromOffset(44, 22)
    switch.BackgroundColor3 = enabled and Color3.fromRGB(205, 210, 220) or Color3.fromRGB(62, 65, 72)
    switch.BackgroundTransparency = 0.12
    switch.BorderSizePixel = 0
    switch.Text = ""
    switch.AutoButtonColor = false
    switch.Parent = row
    AddCorner(switch, 999)
    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = enabled and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0)
    knob.Size = UDim2.fromOffset(17, 17)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BackgroundTransparency = 0
    knob.BorderSizePixel = 0
    knob.Parent = switch
    AddCorner(knob, 999)
    switch.Activated:Connect(function()
        enabled = not enabled
        if onChange then pcall(onChange, enabled) end
        TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = enabled and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0) }):Play()
        TweenService:Create(switch, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = enabled and Color3.fromRGB(205, 210, 220) or Color3.fromRGB(62, 65, 72) }):Play()
    end)
    return row
end

local function Notify(title, text)
    pcall(function()
        local pg = lp:WaitForChild("PlayerGui")
        local old = pg:FindFirstChild("TX_CollectionNotify")
        if old then old:Destroy() end
        local frame = Instance.new("Frame")
        frame.Name = "TX_CollectionNotify"
        frame.AnchorPoint = Vector2.new(1, 1)
        frame.Position = UDim2.new(1, -16, 1, -16)
        frame.Size = UDim2.fromOffset(280, 54)
        frame.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
        frame.BackgroundTransparency = 0.25
        frame.BorderSizePixel = 0
        frame.ZIndex = 5000
        frame.Parent = pg
        AddCorner(frame, 12)
        AddBorder(frame, 1, 0.35)
        local t1 = Instance.new("TextLabel")
        t1.Size = UDim2.new(1, -20, 0, 18)
        t1.Position = UDim2.fromOffset(10, 5)
        t1.BackgroundTransparency = 1
        t1.Text = title
        t1.TextColor3 = Color3.fromRGB(255, 255, 255)
        t1.TextSize = 12
        t1.Font = Enum.Font.GothamBlack
        t1.TextXAlignment = Enum.TextXAlignment.Left
        t1.Parent = frame
        local t2 = Instance.new("TextLabel")
        t2.Size = UDim2.new(1, -20, 0, 22)
        t2.Position = UDim2.fromOffset(10, 25)
        t2.BackgroundTransparency = 1
        t2.Text = text
        t2.TextColor3 = Color3.fromRGB(200, 210, 230)
        t2.TextSize = 10
        t2.Font = Enum.Font.GothamMedium
        t2.TextXAlignment = Enum.TextXAlignment.Left
        t2.Parent = frame
        task.delay(3, function()
            if frame and frame.Parent then
                TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
                task.delay(0.35, function() if frame and frame.Parent then frame:Destroy() end end)
            end
        end)
    end)
end

local function getCrateSpawns()
    local Map1 = workspace:FindFirstChild("Map1")
    return Map1 and Map1:FindFirstChild("CrateSpawns") or nil
end

local function applyCrateChams(crate)
    if crate:FindFirstChild("VoughtCrateChams") then
        return
    end
    pcall(function()
        local h = Instance.new("Highlight")
        h.Name = "VoughtCrateChams"
        h.FillColor = Color3.fromRGB(80, 255, 140)
        h.FillTransparency = 0.45
        h.OutlineColor = Color3.fromRGB(20, 200, 90)
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = crate
    end)
end

local function scanCrates()
    local CrateSpawns = getCrateSpawns()
    if not CrateSpawns then
        return 0
    end
    local n = 0
    for _, child in ipairs(CrateSpawns:GetChildren()) do
        if child:IsA("Model") and child.Name == "VoughtCrate" then
            applyCrateChams(child)
            n = n + 1
        end
    end
    return n
end

task.spawn(function()
    while true do
        if S.closed then break end
        pcall(function()
            if S.crateChams then
                scanCrates()
            end
        end)
        task.wait(1.5)
    end
end)

local function charTeam(char)
    if not char then
        return "None"
    end
    local player = Players:GetPlayerFromCharacter(char)
    if player then
        return player.Team and player.Team.Name or "Lobby"
    end
    return "None"
end

local function isVillain(char)
    return charTeam(char) == "Villain" or char:FindFirstChild("VillainCostume") ~= nil
end

local COLORS = {
    Villain = { fill = Color3.fromRGB(255, 64, 64), outline = Color3.fromRGB(200, 20, 20) },
    Survivor = { fill = Color3.fromRGB(80, 255, 140), outline = Color3.fromRGB(20, 200, 90) },
    Lobby = { fill = Color3.fromRGB(150, 150, 150), outline = Color3.fromRGB(100, 100, 100) },
}

local tracked = {}
local function applyPlayerChams(char)
    local hl = char:FindFirstChild("PlyEspChams")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "PlyEspChams"
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
    end
    local c = isVillain(char) and COLORS.Villain or (charTeam(char) == "Survivors" and COLORS.Survivor or COLORS.Lobby)
    hl.FillColor = c.fill
    hl.FillTransparency = 0.45
    hl.OutlineColor = c.outline
    hl.OutlineTransparency = 0
end

local function rescanPlayers()
    for _, p in ipairs(Players:GetPlayers()) do
        local char = p.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            tracked[char] = true
        end
    end
end

local function onPlayerChar(char)
    tracked[char] = true
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(onPlayerChar)
end)
for _, p in ipairs(Players:GetPlayers()) do
    p.CharacterAdded:Connect(onPlayerChar)
end

task.spawn(function()
    while true do
        if S.closed then break end
        pcall(function()
            rescanPlayers()
            for char in pairs(tracked) do
                if not char.Parent then
                    tracked[char] = nil
                elseif S.playerEsp then
                    applyPlayerChams(char)
                end
            end
        end)
        task.wait(1)
    end
end)

RunService.RenderStepped:Connect(function()
    if S.closed then return end
    if not S.playerEsp then
        return
    end
    local cam = workspace.CurrentCamera
    if not cam then
        return
    end
    for char in pairs(tracked) do
        if not char.Parent then
            continue
        end
        local head = char:FindFirstChild("Head")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not (head and hrp and hum) then
            continue
        end
        local screenPos, onScreen = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 3, 0))
        if not onScreen then
            continue
        end
        local dist = (hrp.Position - cam.CFrame.Position).Magnitude
        local player = Players:GetPlayerFromCharacter(char)
        local name = player and player.Name or "?"
        local team = charTeam(char)
        local label = name .. " | " .. tostring(math.floor(hum.Health)) .. "hp | " .. tostring(math.floor(dist)) .. "m"
        local col = isVillain(char) and COLORS.Villain.fill or (team == "Survivors" and COLORS.Survivor.fill or COLORS.Lobby.fill)
        if DrawingImmediate and DrawingImmediate.OutlinedText then
            DrawingImmediate.OutlinedText(
                Vector2.new(screenPos.X, screenPos.Y - 24),
                13,
                1,
                col,
                1,
                Color3.new(0, 0, 0),
                1,
                label,
                true
            )
        end
    end
end)

local scannedPrompts = {}
local function boostPrompt(prompt)
    if scannedPrompts[prompt] then
        return
    end
    scannedPrompts[prompt] = true
    pcall(function()
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 1000
        prompt.RequiresLineOfSight = false
    end)
end

local function collectPrompts()
    for _, obj in ipairs({ workspace, game:GetService("ReplicatedStorage") }) do
        for _, d in ipairs(obj:GetDescendants()) do
            if d:IsA("ProximityPrompt") then
                boostPrompt(d)
            end
        end
    end
end

task.spawn(function()
    while true do
        if S.closed then break end
        if S.instantInteract then
            pcall(collectPrompts)
        end
        task.wait(0.4)
    end
end)


local MainGui = Instance.new("ScreenGui")
MainGui.Name = "TX_Collection_Panel"
MainGui.ResetOnSpawn = false
MainGui.IgnoreGuiInset = true
MainGui.DisplayOrder = 999999
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local pg = lp:WaitForChild("PlayerGui", 10)
MainGui.Parent = pg

local IntroGui = Instance.new("Frame")
IntroGui.Name = "TX_Intro"
IntroGui.Size = UDim2.fromScale(1, 1)
IntroGui.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
IntroGui.BackgroundTransparency = 1
IntroGui.BorderSizePixel = 0
IntroGui.ZIndex = 10000
IntroGui.Active = true
IntroGui.Parent = MainGui
local IntroTitle = Instance.new("TextLabel")
IntroTitle.AnchorPoint = Vector2.new(0.5, 0.5)
IntroTitle.Position = UDim2.fromScale(0.5, 0.42)
IntroTitle.Size = UDim2.new(0, 320, 0, 56)
IntroTitle.BackgroundTransparency = 1
IntroTitle.Text = "躲避恶人"
IntroTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroTitle.TextTransparency = 1
IntroTitle.TextSize = 44
IntroTitle.Font = Enum.Font.GothamBlack
IntroTitle.ZIndex = 10002
IntroTitle.Parent = IntroGui
AddBorder(IntroTitle, 1.4, 0.15)
StartRainbowFlow(IntroTitle, 2.2, NumberSequence.new(0))
local IntroSub = Instance.new("TextLabel")
IntroSub.AnchorPoint = Vector2.new(0.5, 1)
IntroSub.Position = UDim2.new(0.5, 0, 0.72, 0)
IntroSub.Size = UDim2.new(0, 320, 0, 26)
IntroSub.BackgroundTransparency = 1
IntroSub.Text = "天休制作 · 欢迎, " .. lp.Name
IntroSub.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroSub.TextTransparency = 1
IntroSub.TextSize = 14
IntroSub.Font = Enum.Font.GothamMedium
IntroSub.ZIndex = 10002
IntroSub.Parent = IntroGui
TweenService:Create(IntroGui, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.25 }):Play()
task.wait(0.15)
TweenService:Create(IntroTitle, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
TweenService:Create(IntroSub, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
task.wait(1.4)
TweenService:Create(IntroGui, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { BackgroundTransparency = 1 }):Play()
TweenService:Create(IntroTitle, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 }):Play()
TweenService:Create(IntroSub, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 }):Play()
task.wait(0.5)
if IntroGui.Parent then IntroGui:Destroy() end

local PANEL_W, PANEL_H = 420, 300
local Panel = Instance.new("Frame")
Panel.Name = "Panel"
Panel.AnchorPoint = Vector2.new(0.5, 0.5)
Panel.Position = UDim2.fromScale(0.5, 0.5)
Panel.Size = UDim2.fromOffset(PANEL_W, PANEL_H)
Panel.BackgroundTransparency = 1
Panel.BorderSizePixel = 0
Panel.Active = true
Panel.Parent = MainGui

local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Position = UDim2.fromOffset(2, 2)
Body.Size = UDim2.new(1, -4, 1, -4)
Body.BackgroundColor3 = Color3.fromRGB(6, 8, 12)
Body.BackgroundTransparency = 0.12
Body.BorderSizePixel = 0
Body.ClipsDescendants = true
Body.Parent = Panel
AddCorner(Body, 14)
AddRainbowBorder(Body, 1.5, 0.02, 2.6)

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundTransparency = 1
Header.Active = true
Header.Parent = Body

local DragArea = Instance.new("TextButton")
DragArea.Name = "DragArea"
DragArea.Size = UDim2.new(1, -58, 1, 0)
DragArea.BackgroundTransparency = 1
DragArea.BorderSizePixel = 0
DragArea.Text = ""
DragArea.AutoButtonColor = false
DragArea.Active = true
DragArea.Parent = Header

local panelDrag = { active = false, start = nil, pos = nil }
local function StartPanelDrag(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
    panelDrag.active = true
    panelDrag.start = input.Position
    panelDrag.pos = Panel.Position
end
DragArea.InputBegan:Connect(StartPanelDrag)
Header.InputBegan:Connect(StartPanelDrag)
Panel.InputBegan:Connect(StartPanelDrag)
UserInputService.InputChanged:Connect(function(input)
    if not panelDrag.active then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
    local maxX = vp.X - PANEL_W / 2 - 30
    local maxY = vp.Y - PANEL_H / 2 - 30
    local minX = PANEL_W / 2 - vp.X + 30
    local minY = PANEL_H / 2 - vp.Y + 30
    local dx = math.clamp(panelDrag.pos.X.Offset + (input.Position.X - panelDrag.start.X), minX, maxX)
    local dy = math.clamp(panelDrag.pos.Y.Offset + (input.Position.Y - panelDrag.start.Y), minY, maxY)
    Panel.Position = UDim2.new(0.5, dx, 0.5, dy)
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
    panelDrag.active = false
end)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.fromOffset(12, 3)
TitleLabel.Size = UDim2.new(0, 110, 0, 24)
TitleLabel.Text = "躲避恶人"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header
StartRainbowFlow(TitleLabel, 2.4, NumberSequence.new(0))

local SubLabel = Instance.new("TextLabel")
SubLabel.BackgroundTransparency = 1
SubLabel.Position = UDim2.new(0, 12, 0, 0)
SubLabel.Size = UDim2.new(0, 200, 0, 22)
SubLabel.Text = "天休制作 · Slaughter"
SubLabel.TextColor3 = Color3.fromRGB(150, 160, 180)
SubLabel.TextSize = 11
SubLabel.Font = Enum.Font.GothamMedium
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent = Header

local function makeHeaderBtn(parent, text, tooltip, onClick)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(26, 22)
    btn.Position = UDim2.new(1, 0, 0.5, 0)
    btn.AnchorPoint = Vector2.new(1, 0.5)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.85
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBlack
    btn.AutoButtonColor = false
    btn.ZIndex = 20
    btn.Parent = parent
    AddCorner(btn, 6)
    AddBorder(btn, 0.7, 0.55)
    btn.Activated:Connect(function()
        if onClick then pcall(onClick) end
    end)
    return btn
end

local MinimizeBtn = makeHeaderBtn(Header, "—", "最小化", function() end)
MinimizeBtn.Position = UDim2.new(1, -56, 0.5, 0)
local CloseBtn = makeHeaderBtn(Header, "✕", "关闭", function() end)
CloseBtn.Position = UDim2.new(1, -26, 0.5, 0)

local panelHidden = false
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "TX_FloatBtn"
FloatBtn.Size = UDim2.fromOffset(120, 36)
FloatBtn.AnchorPoint = Vector2.new(0.5, 1)
FloatBtn.Position = UDim2.new(0.5, 0, 1, -24)
FloatBtn.BackgroundColor3 = Color3.fromRGB(6, 8, 12)
FloatBtn.BackgroundTransparency = 0.18
FloatBtn.BorderSizePixel = 0
FloatBtn.Text = "躲避恶人"
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.TextSize = 13
FloatBtn.Font = Enum.Font.GothamBlack
FloatBtn.AutoButtonColor = false
FloatBtn.Visible = false
FloatBtn.Parent = MainGui
AddCorner(FloatBtn, 10)
AddRainbowBorder(FloatBtn, 1.2, 0.02, 2.2)
FloatBtn.Activated:Connect(function()
    panelHidden = false
    FloatBtn.Visible = false
    Panel.Visible = true
end)

MinimizeBtn.Activated:Connect(function()
    panelHidden = true
    Panel.Visible = false
    FloatBtn.Visible = true
end)

local function shutdown()
    S.closed = true
    pcall(function()
        for _, conn in ipairs(getconnections(RunService.RenderStepped)) do
            local f = conn and conn.Function
            if f and isexecutorclosure(f) then
                conn:Disconnect()
            end
        end
        for _, conn in ipairs(getconnections(RunService.Heartbeat)) do
            local f = conn and conn.Function
            if f and isexecutorclosure(f) then
                conn:Disconnect()
            end
        end
    end)
    pcall(function()
        local CrateSpawns = getCrateSpawns()
        if CrateSpawns then
            for _, child in ipairs(CrateSpawns:GetChildren()) do
                local h = child:FindFirstChild("VoughtCrateChams")
                if h then h:Destroy() end
            end
        end
        for char in pairs(tracked) do
            local h = char:FindFirstChild("PlyEspChams")
            if h then h:Destroy() end
        end
    end)
    if MainGui then MainGui:Destroy() end
    Notify("躲避恶人", "已关闭卸载")
end

CloseBtn.Activated:Connect(shutdown)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "Scroll"
Scroll.Position = UDim2.fromOffset(0, 34)
Scroll.Size = UDim2.new(1, 0, 1, -40)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageTransparency = 0.6
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Body

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 6)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = Scroll

CreateToggleRow(Scroll, "箱子 Chams", function() return S.crateChams end, function(v)
    S.crateChams = v
    if not v then
        pcall(function()
            local CrateSpawns = getCrateSpawns()
            if CrateSpawns then
                for _, child in ipairs(CrateSpawns:GetChildren()) do
                    local h = child:FindFirstChild("VoughtCrateChams")
                    if h then h:Destroy() end
                end
            end
        end)
    else
        scanCrates()
    end
    Notify("箱子 Chams", v and "已开启" or "已关闭")
end)

CreateToggleRow(Scroll, "人物 ESP", function() return S.playerEsp end, function(v)
    S.playerEsp = v
    if not v then
        pcall(function()
            for char in pairs(tracked) do
                local h = char:FindFirstChild("PlyEspChams")
                if h then h:Destroy() end
            end
        end)
    end
    Notify("人物 ESP", v and "已开启" or "已关闭")
end)

CreateToggleRow(Scroll, "交互条秒满", function() return S.instantInteract end, function(v)
    S.instantInteract = v
    if v then
        pcall(collectPrompts)
    end
    Notify("交互条秒满", v and "已开启" or "已关闭")
end)

rescanPlayers()
scanCrates()
Notify("躲避恶人 · 天休制作", "加载完成 · 功能就绪")

_G.CollectionAPI = {
    set = function(key, v)
        if S[key] ~= nil then
            S[key] = v and true or false
            Notify(key, S[key] and "已开启" or "已关闭")
        end
    end,
    get = function(key)
        return S[key]
    end,
    state = function()
        return table.clone(S)
    end,
    close = shutdown,
}

print("COLLECTION|loaded|crateChams=" .. tostring(S.crateChams) .. "|playerEsp=" .. tostring(S.playerEsp) .. "|instantInteract=" .. tostring(S.instantInteract))
        ]====]}
},
["塔防游戏"] = {
{Name = "战斗砖块", Url = "https://rawscripts.net/raw/The-Battle-Bricks-auto-play-no-key-141463"}
}
}
local RefreshHomePage
local DBRuntimeState = {
MainStatus = "运行中",
Scripts = {},
ScriptOrder = {}
}
local function DBGetGuiRoots()
local roots = {}
local seen = {}
local function addRoot(root)
if root
and typeof(root) == "Instance"
and not seen[root] then
seen[root] = true
roots[#roots + 1] = root
end
end
pcall(function()
addRoot(
LocalPlayer:FindFirstChild(
"PlayerGui"
)
)
end)
pcall(function()
addRoot(
game:GetService(
"CoreGui"
)
)
end)
pcall(function()
if type(gethui) == "function" then
addRoot(
gethui()
)
end
end)
return roots
end
local function DBCaptureGuiBaseline()
local baseline = {}
for _, root in ipairs(
DBGetGuiRoots()
) do
local ok, children =
pcall(function()
return root:GetChildren()
end)
if ok and children then
for _, child in ipairs(
children
) do
baseline[child] = true
end
end
end
return baseline
end
local function DBCollectNewTopLevelGui(
baseline
)
local result = {}
local seen = {}
baseline =
baseline
or {}
for _, root in ipairs(
DBGetGuiRoots()
) do
local ok, children =
pcall(function()
return root:GetChildren()
end)
if ok and children then
for _, child in ipairs(
children
) do
if child ~= MainGui
and not baseline[child]
and not seen[child] then
local shouldTrack =
child:IsA("LayerCollector")
or child:IsA("Folder")
if shouldTrack then
seen[child] = true
result[#result + 1] =
child
end
end
end
end
end
return result
end
local function DBDestroyInstances(list)
local destroyed = 0
if type(list) ~= "table" then
return destroyed
end
for _, object in ipairs(list) do
if typeof(object) == "Instance"
and object.Parent then
local ok =
pcall(function()
object:Destroy()
end)
if ok then
destroyed =
destroyed + 1
end
end
end
return destroyed
end
local function DBCaptureClientSnapshot()
local snapshot = {}
pcall(function()
snapshot.Gravity =
workspace.Gravity
end)
pcall(function()
local camera =
workspace.CurrentCamera
if camera then
snapshot.Camera = {
FieldOfView =
camera.FieldOfView,
CameraType =
camera.CameraType,
CameraSubject =
camera.CameraSubject
}
end
end)
pcall(function()
local lighting =
game:GetService(
"Lighting"
)
snapshot.Lighting = {
Brightness =
lighting.Brightness,
ClockTime =
lighting.ClockTime,
FogStart =
lighting.FogStart,
FogEnd =
lighting.FogEnd,
ExposureCompensation =
lighting.ExposureCompensation,
GlobalShadows =
lighting.GlobalShadows,
Ambient =
lighting.Ambient,
OutdoorAmbient =
lighting.OutdoorAmbient
}
end)
pcall(function()
local character =
LocalPlayer.Character
local humanoid =
character
and character:FindFirstChildOfClass(
"Humanoid"
)
if humanoid then
snapshot.Humanoid = {
WalkSpeed =
humanoid.WalkSpeed,
JumpPower =
humanoid.JumpPower,
JumpHeight =
humanoid.JumpHeight,
HipHeight =
humanoid.HipHeight,
AutoRotate =
humanoid.AutoRotate,
PlatformStand =
humanoid.PlatformStand,
Sit =
humanoid.Sit,
UseJumpPower =
humanoid.UseJumpPower
}
end
end)
return snapshot
end
local function DBRestoreClientSnapshot(
snapshot
)
if type(snapshot) ~= "table" then
return
end
pcall(function()
if snapshot.Gravity ~= nil then
workspace.Gravity =
snapshot.Gravity
end
end)
pcall(function()
local camera =
workspace.CurrentCamera
local saved =
snapshot.Camera
if camera
and type(saved) == "table" then
if saved.FieldOfView ~= nil then
camera.FieldOfView =
saved.FieldOfView
end
if saved.CameraType ~= nil then
camera.CameraType =
saved.CameraType
end
if saved.CameraSubject
and saved.CameraSubject.Parent then
camera.CameraSubject =
saved.CameraSubject
else
local character =
LocalPlayer.Character
local humanoid =
character
and character:FindFirstChildOfClass(
"Humanoid"
)
if humanoid then
camera.CameraSubject =
humanoid
end
end
end
end)
pcall(function()
local lighting =
game:GetService(
"Lighting"
)
local saved =
snapshot.Lighting
if type(saved) == "table" then
for property, value in pairs(
saved
) do
pcall(function()
lighting[property] =
value
end)
end
end
end)
pcall(function()
local character =
LocalPlayer.Character
local humanoid =
character
and character:FindFirstChildOfClass(
"Humanoid"
)
local saved =
snapshot.Humanoid
if humanoid
and type(saved) == "table" then
local restoreProperties = {
"WalkSpeed",
"JumpPower",
"JumpHeight",
"HipHeight",
"AutoRotate",
"PlatformStand",
"Sit",
"UseJumpPower"
}
for _, property in ipairs(
restoreProperties
) do
if saved[property] ~= nil then
pcall(function()
humanoid[property] =
saved[property]
end)
end
end
end
end)
end
local DBSessionGuiBaseline =
DBCaptureGuiBaseline()
local DBSessionClientSnapshot =
DBCaptureClientSnapshot()
local DBAbsoluteShutdownBusy = false
local function DBSetScriptStatus(name, status)
name = tostring(name or "未命名脚本")
status = tostring(status or "未知")
local info =
DBRuntimeState.Scripts[name]
if not info then
info = {}
DBRuntimeState.Scripts[name] = info
table.insert(
DBRuntimeState.ScriptOrder,
name
)
end
info.Status = status
info.UpdatedAt = os.clock()
if RefreshHomePage then
pcall(RefreshHomePage)
end
end
local function DBSetScriptHandle(name, handle)
name =
tostring(
name
or "未命名脚本"
)
local info =
DBRuntimeState.Scripts[name]
if not info then
info = {
Status = "运行中",
UpdatedAt = os.clock()
}
DBRuntimeState.Scripts[name] =
info
table.insert(
DBRuntimeState.ScriptOrder,
name
)
end
info.Handle = handle
end
local function DBRememberScriptGui(
name,
baseline
)
name =
tostring(
name
or "未命名脚本"
)
local info =
DBRuntimeState.Scripts[name]
if not info then
return
end
info.ManagedGui =
info.ManagedGui
or {}
info.ManagedGuiSet =
info.ManagedGuiSet
or {}
local found =
DBCollectNewTopLevelGui(
baseline
)
for _, object in ipairs(found) do
if not info.ManagedGuiSet[object] then
info.ManagedGuiSet[object] =
true
info.ManagedGui[#info.ManagedGui + 1] =
object
end
end
end
local function DBTryCleanupHandle(handle)
if handle == nil then
return false
end
local valueType =
typeof(handle)
if valueType == "RBXScriptConnection" then
local ok =
pcall(function()
handle:Disconnect()
end)
return ok
end
if valueType == "Instance" then
local ok =
pcall(function()
handle:Destroy()
end)
return ok
end
if type(handle) == "thread" then
local ok =
pcall(function()
task.cancel(handle)
end)
return ok
end
if type(handle) == "function" then
local ok =
pcall(handle)
return ok
end
if type(handle) == "table"
or valueType == "userdata" then
local methodNames = {
"Stop",
"Shutdown",
"Unload",
"Destroy",
"Disable",
"Disconnect",
"Cleanup",
"Close"
}
for _, methodName in ipairs(
methodNames
) do
local okRead, method =
pcall(function()
return handle[methodName]
end)
if okRead
and type(method) == "function" then
local okCall =
pcall(function()
method(handle)
end)
if okCall then
return true
end
end
end
if type(handle) == "table" then
local cleanedAny = false
for _, child in pairs(handle) do
local childType =
typeof(child)
if childType == "RBXScriptConnection"
or childType == "Instance"
or type(child) == "thread"
or type(child) == "function" then
if DBTryCleanupHandle(child) then
cleanedAny = true
end
end
end
return cleanedAny
end
end
return false
end
local function DBStopScriptByName(name)
name =
tostring(
name
or ""
)
local info =
DBRuntimeState.Scripts[name]
if not info then
return false, "未记录"
end
local uiDestroyed =
DBDestroyInstances(
info.ManagedGui
)
local cleaned =
DBTryCleanupHandle(
info.Handle
)
info.Status =
cleaned
and "已关停"
or (
uiDestroyed > 0
and "UI已关闭 · 主体已请求关停"
or "已请求关停"
)
info.UpdatedAt =
os.clock()
if RefreshHomePage then
pcall(RefreshHomePage)
end
return cleaned, info.Status
end
local function DBStopAllTrackedScripts()
local total = 0
local cleaned = 0
for _, name in ipairs(
DBRuntimeState.ScriptOrder
) do
local info =
DBRuntimeState.Scripts[name]
if info
and (
info.Status == "运行中"
or info.Status == "加载中"
) then
total = total + 1
local ok =
DBStopScriptByName(name)
if ok then
cleaned = cleaned + 1
end
end
end
return total, cleaned
end
local function DBAbsoluteShutdown()
if DBAbsoluteShutdownBusy then
return
end
DBAbsoluteShutdownBusy = true
pcall(function()
if DBSpatial and type(DBSpatial.Destroy) == "function" then DBSpatial.Destroy(true) end
end)
DBRuntimeState.MainStatus =
"绝对关停中"
pcall(function()
MainGui.Enabled = false
end)
local newGui =
DBCollectNewTopLevelGui(
DBSessionGuiBaseline
)
DBDestroyInstances(
newGui
)
pcall(function()
DBStopAllTrackedScripts()
end)
pcall(function()
DBRestoreClientSnapshot(
DBSessionClientSnapshot
)
end)
pcall(function()
MainGui:Destroy()
end)
DBRuntimeState.MainStatus =
"已关停"
end
local function DBCloseScript()
pcall(function()
if DBSpatial and type(DBSpatial.Destroy) == "function" then
DBSpatial.Destroy(true)
end
end)
pcall(function()
DBRuntimeState.MainStatus = "已关闭"
end)
pcall(function()
DBStopAllTrackedScripts()
end)
pcall(function()
DBRestoreClientSnapshot(DBSessionClientSnapshot)
end)
pcall(function()
local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
if playerGui then
local flightGui = playerGui:FindFirstChild("DB_FLIGHT_UI")
if flightGui then
flightGui:Destroy()
end
end
end)
pcall(function()
if MainGui and MainGui.Parent then
MainGui:Destroy()
end
end)
end
local function SafeLoadScript(item)
local itemName =
tostring(
item and item.Name
or "未命名脚本"
)
local scriptGuiBaseline =
DBCaptureGuiBaseline()
DBSetScriptStatus(
itemName,
"加载中"
)
task.spawn(function()
local success, resultOrError =
pcall(function()
if item.Code then
local chunk, compileError =
loadstring(
item.Code
)
if type(chunk) ~= "function" then
error("脚本编译失败：" .. tostring(compileError))
end
return chunk()
elseif item.Url then
local src =
game:HttpGet(
item.Url
)
local chunk, compileError =
loadstring(src)
if type(chunk) ~= "function" then
error("远程脚本编译失败：" .. tostring(compileError))
end
return chunk()
end
end)
if success then
DBSetScriptHandle(
itemName,
resultOrError
)
DBSetScriptStatus(
itemName,
"运行中"
)
task.delay(
0.35,
function()
DBRememberScriptGui(
itemName,
scriptGuiBaseline
)
end
)
task.delay(
1.60,
function()
DBRememberScriptGui(
itemName,
scriptGuiBaseline
)
end
)
ShowDBNotification(
"加载成功",
itemName,
true
)
else
DBSetScriptStatus(
itemName,
"加载失败"
)
warn(
"❌ 脚本加载失败: "
.. tostring(
resultOrError
)
)
ShowDBNotification(
"加载失败",
itemName,
false
)
end
end)
end
local function DBCreateAdvancedPlayerPanel(
parent
)
local controller = {}
local refreshers = {}
local snapshot = nil
local function StylePlayerPanelButton(
button,
redMode
)
button.TextTransparency = 0
button.AutoButtonColor = false
if redMode then
button.TextColor3 = Color3.fromRGB(255, 112, 130)
button.BackgroundColor3 = Color3.fromRGB(30, 12, 18)
button.BackgroundTransparency = 0.12
else
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
button.BackgroundTransparency = 0.84
button.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
button.TextStrokeTransparency = 0.80
button.Font = Enum.Font.GothamBlack
end
for _, child in ipairs(button:GetChildren()) do
if child:IsA("UIGradient") then child:Destroy() end
end
local scale = button:FindFirstChild("DB_PlayerPanelClickScale")
if not scale then
scale = Instance.new("UIScale")
scale.Name = "DB_PlayerPanelClickScale"
scale.Scale = 1
scale.Parent = button
end
button.InputBegan:Connect(function(input)
if input.UserInputType ~= Enum.UserInputType.MouseButton1
and input.UserInputType ~= Enum.UserInputType.Touch then return end
TweenService:Create(scale, TweenInfo.new(0.055, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.965}):Play()
end)
button.InputEnded:Connect(function(input)
if input.UserInputType ~= Enum.UserInputType.MouseButton1
and input.UserInputType ~= Enum.UserInputType.Touch then return end
TweenService:Create(scale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
end)
end
local panel =
Instance.new(
"Frame"
)
panel.Name =
"DB_Advanced_Player_Panel"
panel.Size =
UDim2.new(
1,
-8,
1,
-4
)
panel.Position =
UDim2.fromOffset(
4,
2
)
panel.BackgroundColor3 =
Color3.fromRGB(
8,
10,
14
)
panel.BackgroundTransparency =
0.14
panel.BorderSizePixel = 0
panel.Visible = false
panel.ZIndex = 20
panel.Parent = parent
AddCorner(
panel,
12
)
AddDBEnchantedBorder(
panel,
1.35,
true
)
local header =
Instance.new(
"Frame"
)
header.Name = "Header"
header.Size =
UDim2.new(
1,
0,
0,
50
)
header.BackgroundColor3 =
Color3.fromRGB(
12,
15,
21
)
header.BackgroundTransparency =
0.16
header.BorderSizePixel = 0
header.ZIndex = 22
header.Parent = panel
AddCorner(
header,
11
)
AddDBEnchantedBorder(
header,
1.05,
true
)
local title =
Instance.new(
"TextLabel"
)
title.BackgroundTransparency = 1
title.Position =
UDim2.fromOffset(
12,
5
)
title.Size =
UDim2.new(
1,
-120,
0,
22
)
title.Text = "玩家面板"
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment =
Enum.TextXAlignment.Left
title.ZIndex = 23
title.Parent = header
AddDBEnchantedText(
title,
true
)
local subtitle =
Instance.new(
"TextLabel"
)
subtitle.BackgroundTransparency = 1
subtitle.Position =
UDim2.fromOffset(
12,
27
)
subtitle.Size =
UDim2.new(
1,
-120,
0,
16
)
subtitle.Text =
"本地角色 / 镜头 / 物理 / 高级属性 · 服务端数据可能自动恢复"
subtitle.TextColor3 =
Color3.fromRGB(
225,
236,
250
)
subtitle.TextSize = 9
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextXAlignment =
Enum.TextXAlignment.Left
subtitle.ZIndex = 23
subtitle.Parent = header
local refreshButton =
Instance.new(
"TextButton"
)
refreshButton.Size =
UDim2.fromOffset(
78,
30
)
refreshButton.Position =
UDim2.new(
1,
-88,
0,
10
)
refreshButton.BackgroundColor3 =
Color3.fromRGB(
15,
20,
28
)
refreshButton.BackgroundTransparency =
0.12
refreshButton.BorderSizePixel = 0
refreshButton.Text = "刷新"
refreshButton.TextSize = 12
refreshButton.Font = Enum.Font.GothamBold
refreshButton.AutoButtonColor = false
refreshButton.ZIndex = 24
refreshButton.Parent = header
AddCorner(
refreshButton,
8
)
AddDBEnchantedBorder(
refreshButton,
0.9,
true
)
AddDBEnchantedText(
refreshButton,
false
)
StylePlayerPanelButton(
refreshButton,
false
)
local scroll =
Instance.new(
"ScrollingFrame"
)
scroll.Name =
"PlayerPanelScroll"
scroll.Position =
UDim2.fromOffset(
0,
56
)
scroll.Size =
UDim2.new(
1,
0,
1,
-56
)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 =
Color3.fromRGB(
255,
255,
255
)
scroll.ScrollBarImageTransparency =
0.25
scroll.AutomaticCanvasSize =
Enum.AutomaticSize.Y
scroll.CanvasSize =
UDim2.new()
scroll.ScrollingDirection =
Enum.ScrollingDirection.Y
scroll.Active = true
scroll.ScrollingEnabled = true
scroll.ZIndex = 21
scroll.Parent = panel
local layout =
Instance.new(
"UIListLayout"
)
layout.Padding =
UDim.new(
0,
8
)
layout.SortOrder =
Enum.SortOrder.LayoutOrder
layout.Parent = scroll
local padding =
Instance.new(
"UIPadding"
)
padding.PaddingTop =
UDim.new(
0,
4
)
padding.PaddingBottom =
UDim.new(
0,
8
)
padding.PaddingLeft =
UDim.new(
0,
5
)
padding.PaddingRight =
UDim.new(
0,
8
)
padding.Parent = scroll
local function getTargets()
local player =
LocalPlayer
local character =
player
and player.Character
local humanoid =
character
and character:FindFirstChildOfClass(
"Humanoid"
)
local root =
character
and character:FindFirstChild(
"HumanoidRootPart"
)
local camera =
workspace.CurrentCamera
return player,
character,
humanoid,
root,
camera
end
local function safeNumber(value)
local n =
tonumber(
value
)
if not n
or n ~= n
or n == math.huge
or n == -math.huge then
return nil
end
return n
end
local function formatValue(value)
if value == nil then
return "nil"
end
if type(value) == "number" then
return string.format(
"%.3f",
value
):gsub(
"0+$",
""
):gsub(
"%.$",
""
)
end
return tostring(
value
)
end
local function notify(
textValue
)
ShowDBNotification(
"玩家面板",
textValue,
true
)
end
local function createSection(
titleText
)
local section =
Instance.new(
"Frame"
)
section.Name =
"Section_"
.. titleText
section.Size =
UDim2.new(
1,
0,
0,
0
)
section.AutomaticSize =
Enum.AutomaticSize.Y
section.BackgroundColor3 =
Color3.fromRGB(
12,
14,
20
)
section.BackgroundTransparency =
0.18
section.BorderSizePixel = 0
section.ZIndex = 22
section.Parent = scroll
AddCorner(
section,
10
)
AddDBEnchantedBorder(
section,
0.85,
true
)
local sectionLayout =
Instance.new(
"UIListLayout"
)
sectionLayout.Padding =
UDim.new(
0,
5
)
sectionLayout.SortOrder =
Enum.SortOrder.LayoutOrder
sectionLayout.Parent =
section
local sectionPadding =
Instance.new(
"UIPadding"
)
sectionPadding.PaddingTop =
UDim.new(
0,
8
)
sectionPadding.PaddingBottom =
UDim.new(
0,
8
)
sectionPadding.PaddingLeft =
UDim.new(
0,
8
)
sectionPadding.PaddingRight =
UDim.new(
0,
8
)
sectionPadding.Parent =
section
local sectionTitle =
Instance.new(
"TextLabel"
)
sectionTitle.Size =
UDim2.new(
1,
0,
0,
22
)
sectionTitle.BackgroundTransparency = 1
sectionTitle.Text = titleText
sectionTitle.TextSize = 13
sectionTitle.Font = Enum.Font.GothamBold
sectionTitle.TextXAlignment =
Enum.TextXAlignment.Left
sectionTitle.ZIndex = 23
sectionTitle.Parent = section
AddDBEnchantedText(
sectionTitle,
false
)
return section
end
local function createRow(
section,
height
)
local row =
Instance.new(
"Frame"
)
row.Size =
UDim2.new(
1,
0,
0,
height
or 34
)
row.BackgroundColor3 =
Color3.fromRGB(
18,
21,
28
)
row.BackgroundTransparency =
0.42
row.BorderSizePixel = 0
row.ZIndex = 23
row.Parent = section
AddCorner(
row,
8
)
return row
end
local function createValueEditor(
section,
labelText,
getter,
setter
)
local row =
createRow(
section,
34
)
local label =
Instance.new(
"TextLabel"
)
label.Size =
UDim2.new(
0.40,
-4,
1,
0
)
label.Position =
UDim2.fromOffset(
9,
0
)
label.BackgroundTransparency = 1
label.Text = labelText
label.TextColor3 =
Color3.fromRGB(
238,
241,
248
)
label.TextSize = 10
label.Font = Enum.Font.GothamMedium
label.TextXAlignment =
Enum.TextXAlignment.Left
label.ZIndex = 24
label.Parent = row
local box =
Instance.new(
"TextBox"
)
box.Size =
UDim2.new(
0.34,
-5,
0,
26
)
box.Position =
UDim2.new(
0.40,
0,
0.5,
-13
)
box.BackgroundColor3 =
Color3.fromRGB(
9,
12,
18
)
box.BackgroundTransparency =
0.10
box.BorderSizePixel = 0
box.ClearTextOnFocus = false
box.Text = ""
box.TextColor3 =
Color3.fromRGB(
245,
248,
255
)
box.PlaceholderColor3 =
Color3.fromRGB(
205,
218,
235
)
box.TextSize = 10
box.Font = Enum.Font.GothamMedium
box.ZIndex = 24
box.Parent = row
AddCorner(
box,
7
)
local apply =
Instance.new(
"TextButton"
)
apply.Size =
UDim2.new(
0.24,
-6,
0,
26
)
apply.Position =
UDim2.new(
0.76,
0,
0.5,
-13
)
apply.BackgroundColor3 =
Color3.fromRGB(
15,
22,
31
)
apply.BackgroundTransparency =
0.08
apply.BorderSizePixel = 0
apply.Text = "应用"
apply.TextSize = 10
apply.Font = Enum.Font.GothamBold
apply.AutoButtonColor = false
apply.ZIndex = 24
apply.Parent = row
AddCorner(
apply,
7
)
AddDBEnchantedBorder(
apply,
0.62,
true
)
StylePlayerPanelButton(
apply,
false
)
local function refresh()
local ok,
value =
pcall(
getter
)
if ok then
box.Text =
formatValue(
value
)
else
box.Text = "不可用"
end
end
local function commit()
local ok,
err =
pcall(
setter,
box.Text
)
if ok then
refresh()
else
warn(
"[DB玩家面板] "
.. labelText
.. " 修改失败: "
.. tostring(
err
)
)
end
end
apply.Activated:Connect(
commit
)
box.FocusLost:Connect(
function(
enterPressed
)
if enterPressed then
commit()
end
end
)
refreshers[
#refreshers + 1
] = refresh
return refresh
end
local function createNumericProperty(
section,
labelText,
targetGetter,
propertyName
)
createValueEditor(
section,
labelText,
function()
local target =
targetGetter()
return target
and target[
propertyName
]
end,
function(raw)
local n =
safeNumber(
raw
)
if not n then
error(
"请输入有效数字"
)
end
local target =
targetGetter()
if not target then
error(
"目标不存在"
)
end
target[
propertyName
] = n
end
)
end
local function createToggle(
section,
labelText,
targetGetter,
propertyName
)
local row =
createRow(
section,
34
)
local label =
Instance.new(
"TextLabel"
)
label.Size =
UDim2.new(
0.66,
-6,
1,
0
)
label.Position =
UDim2.fromOffset(
9,
0
)
label.BackgroundTransparency = 1
label.Text = labelText
label.TextColor3 =
Color3.fromRGB(
238,
241,
248
)
label.TextSize = 10
label.Font = Enum.Font.GothamMedium
label.TextXAlignment =
Enum.TextXAlignment.Left
label.ZIndex = 24
label.Parent = row
local toggle =
Instance.new(
"TextButton"
)
toggle.Size =
UDim2.new(
0.32,
-5,
0,
26
)
toggle.Position =
UDim2.new(
0.68,
0,
0.5,
-13
)
toggle.BackgroundColor3 =
Color3.fromRGB(
15,
22,
31
)
toggle.BackgroundTransparency =
0.08
toggle.BorderSizePixel = 0
toggle.TextSize = 10
toggle.Font = Enum.Font.GothamBold
toggle.AutoButtonColor = false
toggle.ZIndex = 24
toggle.Parent = row
AddCorner(
toggle,
7
)
AddDBEnchantedBorder(
toggle,
0.62,
true
)
StylePlayerPanelButton(
toggle,
false
)
local function refresh()
local target =
targetGetter()
if not target then
toggle.Text = "不可用"
return
end
local ok,
value =
pcall(function()
return target[
propertyName
]
end)
if not ok then
toggle.Text = "不可用"
return
end
toggle.Text =
value
and "开启"
or "关闭"
end
toggle.Activated:Connect(function()
local target =
targetGetter()
if not target then
return
end
pcall(function()
target[
propertyName
] =
not target[
propertyName
]
end)
refresh()
end)
refreshers[
#refreshers + 1
] = refresh
return refresh
end
local function createAction(
section,
textValue,
callback
)
local button =
Instance.new(
"TextButton"
)
button.Size =
UDim2.new(
1,
0,
0,
32
)
button.BackgroundColor3 =
Color3.fromRGB(
15,
20,
28
)
button.BackgroundTransparency =
0.18
button.BorderSizePixel = 0
button.Text = textValue
button.TextSize = 10
button.Font = Enum.Font.GothamBold
button.AutoButtonColor = false
button.ZIndex = 23
button.Parent = section
AddCorner(
button,
8
)
AddDBEnchantedBorder(
button,
0.72,
true
)
AddDBEnchantedText(
button,
false
)
StylePlayerPanelButton(
button,
false
)
button.Activated:Connect(function()
local ok,
err =
pcall(
callback
)
if not ok then
warn(
"[DB玩家面板] "
.. tostring(
err
)
)
end
end)
return button
end
local function createInfoRow(
section,
labelText,
getter
)
local row =
createRow(
section,
30
)
local label =
Instance.new(
"TextLabel"
)
label.Size =
UDim2.new(
0.42,
-4,
1,
0
)
label.Position =
UDim2.fromOffset(
9,
0
)
label.BackgroundTransparency = 1
label.Text = labelText
label.TextColor3 =
Color3.fromRGB(
220,
232,
248
)
label.TextSize = 9
label.Font = Enum.Font.GothamMedium
label.TextXAlignment =
Enum.TextXAlignment.Left
label.ZIndex = 24
label.Parent = row
local valueLabel =
Instance.new(
"TextLabel"
)
valueLabel.Size =
UDim2.new(
0.56,
-6,
1,
0
)
valueLabel.Position =
UDim2.new(
0.44,
0,
0,
0
)
valueLabel.BackgroundTransparency = 1
valueLabel.TextColor3 =
Color3.fromRGB(
240,
244,
252
)
valueLabel.TextSize = 9
valueLabel.Font = Enum.Font.GothamMedium
valueLabel.TextXAlignment =
Enum.TextXAlignment.Left
valueLabel.TextTruncate =
Enum.TextTruncate.AtEnd
valueLabel.ZIndex = 24
valueLabel.Parent = row
local function refresh()
local ok,
value =
pcall(
getter
)
valueLabel.Text =
ok
and formatValue(
value
)
or "不可用"
end
refreshers[
#refreshers + 1
] = refresh
return refresh
end
local function createVectorEditor(
section,
labelText,
getter,
setter
)
local row =
createRow(
section,
62
)
local label =
Instance.new(
"TextLabel"
)
label.Size =
UDim2.new(
1,
-18,
0,
22
)
label.Position =
UDim2.fromOffset(
9,
2
)
label.BackgroundTransparency = 1
label.Text = labelText
label.TextColor3 =
Color3.fromRGB(
238,
241,
248
)
label.TextSize = 10
label.Font = Enum.Font.GothamMedium
label.TextXAlignment =
Enum.TextXAlignment.Left
label.ZIndex = 24
label.Parent = row
local boxes = {}
for i,
axis in ipairs({
"X",
"Y",
"Z"
}) do
local box =
Instance.new(
"TextBox"
)
box.Size =
UDim2.new(
0.22,
-4,
0,
26
)
box.Position =
UDim2.new(
0.02
+ (
i - 1
) * 0.23,
0,
0,
30
)
box.BackgroundColor3 =
Color3.fromRGB(
9,
12,
18
)
box.BackgroundTransparency =
0.10
box.BorderSizePixel = 0
box.ClearTextOnFocus = false
box.Text = ""
box.PlaceholderText = axis
box.TextColor3 =
Color3.fromRGB(
250,
252,
255
)
box.PlaceholderColor3 =
Color3.fromRGB(
210,
224,
240
)
box.TextSize = 9
box.Font = Enum.Font.GothamMedium
box.ZIndex = 24
box.Parent = row
AddCorner(
box,
6
)
boxes[
i
] = box
end
local apply =
Instance.new(
"TextButton"
)
apply.Size =
UDim2.new(
0.27,
-6,
0,
26
)
apply.Position =
UDim2.new(
0.72,
0,
0,
30
)
apply.BackgroundColor3 =
Color3.fromRGB(
15,
22,
31
)
apply.BackgroundTransparency =
0.08
apply.BorderSizePixel = 0
apply.Text = "应用"
apply.TextSize = 9
apply.Font = Enum.Font.GothamBold
apply.AutoButtonColor = false
apply.ZIndex = 24
apply.Parent = row
AddCorner(
apply,
6
)
AddDBEnchantedBorder(
apply,
0.62,
true
)
StylePlayerPanelButton(
apply,
false
)
local function refresh()
local ok,
value =
pcall(
getter
)
if ok
and typeof(
value
) == "Vector3" then
boxes[1].Text =
formatValue(
value.X
)
boxes[2].Text =
formatValue(
value.Y
)
boxes[3].Text =
formatValue(
value.Z
)
end
end
local function commit()
local x =
safeNumber(
boxes[1].Text
)
local y =
safeNumber(
boxes[2].Text
)
local z =
safeNumber(
boxes[3].Text
)
if not x
or not y
or not z then
return
end
pcall(
setter,
Vector3.new(
x,
y,
z
)
)
refresh()
end
apply.Activated:Connect(
commit
)
refreshers[
#refreshers + 1
] = refresh
end
local basicSection =
createSection(
"基础信息"
)
createInfoRow(
basicSection,
"显示名",
function()
return LocalPlayer.DisplayName
end
)
createInfoRow(
basicSection,
"用户名",
function()
return LocalPlayer.Name
end
)
createInfoRow(
basicSection,
"UserId",
function()
return LocalPlayer.UserId
end
)
createInfoRow(
basicSection,
"账号年龄",
function()
return LocalPlayer.AccountAge
end
)
createInfoRow(
basicSection,
"队伍",
function()
return LocalPlayer.Team
and LocalPlayer.Team.Name
or "无"
end
)
createInfoRow(
basicSection,
"角色骨架类型",
function()
local _,
_,
humanoid =
getTargets()
return humanoid
and humanoid.RigType.Name
or "无"
end
)
createInfoRow(
basicSection,
"角色当前状态",
function()
local _,
_,
humanoid =
getTargets()
return humanoid
and humanoid:GetState().Name
or "无"
end
)
local moveSection =
createSection(
"移动与角色控制"
)
local function getHumanoid()
local _,
_,
humanoid =
getTargets()
return humanoid
end
createNumericProperty(
moveSection,
"移动速度",
getHumanoid,
"WalkSpeed"
)
createNumericProperty(
moveSection,
"跳跃力度",
getHumanoid,
"JumpPower"
)
createNumericProperty(
moveSection,
"跳跃高度",
getHumanoid,
"JumpHeight"
)
createNumericProperty(
moveSection,
"离地高度",
getHumanoid,
"HipHeight"
)
createNumericProperty(
moveSection,
"最大可行走坡度",
getHumanoid,
"MaxSlopeAngle"
)
createToggle(
moveSection,
"自动转向",
getHumanoid,
"AutoRotate"
)
createToggle(
moveSection,
"使用跳跃力度模式",
getHumanoid,
"UseJumpPower"
)
createToggle(
moveSection,
"Sit 坐下",
getHumanoid,
"Sit"
)
createToggle(
moveSection,
"PlatformStand 平台站立",
getHumanoid,
"PlatformStand"
)
createToggle(
moveSection,
"自动角色缩放",
getHumanoid,
"AutomaticScalingEnabled"
)
createToggle(
moveSection,
"角色状态机",
getHumanoid,
"EvaluateStateMachine"
)
local lifeSection =
createSection(
"生命与角色状态"
)
createNumericProperty(
lifeSection,
"当前血量",
getHumanoid,
"Health"
)
createNumericProperty(
lifeSection,
"最大血量",
getHumanoid,
"MaxHealth"
)
createNumericProperty(
lifeSection,
"血条显示距离",
getHumanoid,
"HealthDisplayDistance"
)
createNumericProperty(
lifeSection,
"名字显示距离",
getHumanoid,
"NameDisplayDistance"
)
createToggle(
lifeSection,
"死亡时断开身体关节",
getHumanoid,
"BreakJointsOnDeath"
)
createToggle(
lifeSection,
"角色需要颈部连接",
getHumanoid,
"RequiresNeck"
)
createAction(
lifeSection,
"立即回满当前最大血量",
function()
local humanoid =
getHumanoid()
if humanoid then
humanoid.Health =
humanoid.MaxHealth
end
end
)
local cameraSection =
createSection(
"镜头与视角"
)
createValueEditor(
cameraSection,
"视野范围",
function()
local _,
_,
_,
_,
camera =
getTargets()
return camera
and camera.FieldOfView
end,
function(raw)
local n =
safeNumber(
raw
)
local camera =
workspace.CurrentCamera
if n
and camera then
camera.FieldOfView = n
end
end
)
createValueEditor(
cameraSection,
"最小缩放距离",
function()
return LocalPlayer.CameraMinZoomDistance
end,
function(raw)
local n =
safeNumber(
raw
)
if n then
LocalPlayer.CameraMinZoomDistance = n
end
end
)
createValueEditor(
cameraSection,
"最大缩放距离",
function()
return LocalPlayer.CameraMaxZoomDistance
end,
function(raw)
local n =
safeNumber(
raw
)
if n then
LocalPlayer.CameraMaxZoomDistance = n
end
end
)
createVectorEditor(
cameraSection,
"镜头偏移（X / Y / Z）",
function()
local humanoid =
getHumanoid()
return humanoid
and humanoid.CameraOffset
or Vector3.zero
end,
function(value)
local humanoid =
getHumanoid()
if humanoid then
humanoid.CameraOffset =
value
end
end
)
local physicsSection =
createSection(
"物理与RootPart"
)
createValueEditor(
physicsSection,
"世界重力",
function()
return workspace.Gravity
end,
function(raw)
local n =
safeNumber(
raw
)
if n then
workspace.Gravity = n
end
end
)
local function getRoot()
local _,
_,
_,
root =
getTargets()
return root
end
createVectorEditor(
physicsSection,
"角色线速度（X / Y / Z）",
function()
local root =
getRoot()
return root
and root.AssemblyLinearVelocity
or Vector3.zero
end,
function(value)
local root =
getRoot()
if root then
root.AssemblyLinearVelocity =
value
end
end
)
createVectorEditor(
physicsSection,
"角色旋转速度（X / Y / Z）",
function()
local root =
getRoot()
return root
and root.AssemblyAngularVelocity
or Vector3.zero
end,
function(value)
local root =
getRoot()
if root then
root.AssemblyAngularVelocity =
value
end
end
)
createToggle(
physicsSection,
"固定角色位置",
getRoot,
"Anchored"
)
createToggle(
physicsSection,
"角色根部无重量",
getRoot,
"Massless"
)
local scaleSection =
createSection(
"R15角色身体比例"
)
local scaleNames = {
{
"角色身高比例",
"BodyHeightScale"
},
{
"角色宽度比例",
"BodyWidthScale"
},
{
"角色厚度比例",
"BodyDepthScale"
},
{
"头部大小比例",
"HeadScale"
},
{
"体型比例",
"BodyTypeScale"
},
{
"身体比例",
"BodyProportionScale"
}
}
for _,
info in ipairs(
scaleNames
) do
createValueEditor(
scaleSection,
info[1],
function()
local humanoid =
getHumanoid()
local value =
humanoid
and humanoid:FindFirstChild(
info[2]
)
return value
and value.Value
end,
function(raw)
local n =
safeNumber(
raw
)
local humanoid =
getHumanoid()
local value =
humanoid
and humanoid:FindFirstChild(
info[2]
)
if n
and value
and value:IsA(
"NumberValue"
) then
value.Value = n
end
end
)
end
local stateSection =
createSection(
"角色状态动作"
)
local states = {
{
State = Enum.HumanoidStateType.Jumping,
Name = "跳跃"
},
{
State = Enum.HumanoidStateType.GettingUp,
Name = "起身"
},
{
State = Enum.HumanoidStateType.Running,
Name = "奔跑"
},
{
State = Enum.HumanoidStateType.Landed,
Name = "落地"
},
{
State = Enum.HumanoidStateType.Physics,
Name = "物理状态"
}
}
for _,
info in ipairs(
states
) do
createAction(
stateSection,
"切换角色状态 → "
.. info.Name,
function()
local humanoid =
getHumanoid()
if humanoid then
humanoid:ChangeState(
info.State
)
end
end
)
end
local attrSection =
createSection(
"高级自定义属性"
)
local attrTargetIndex = 1
local attrTargets = {
"玩家",
"角色",
"角色控制器"
}
local attrControl =
createRow(
attrSection,
74
)
local attrTargetButton =
Instance.new(
"TextButton"
)
attrTargetButton.Size =
UDim2.new(
0.27,
-5,
0,
26
)
attrTargetButton.Position =
UDim2.fromOffset(
7,
7
)
attrTargetButton.BackgroundColor3 =
Color3.fromRGB(
15,
22,
31
)
attrTargetButton.BackgroundTransparency =
0.08
attrTargetButton.BorderSizePixel = 0
attrTargetButton.TextSize = 9
attrTargetButton.Font = Enum.Font.GothamBold
attrTargetButton.AutoButtonColor = false
attrTargetButton.ZIndex = 24
attrTargetButton.Parent = attrControl
AddCorner(
attrTargetButton,
6
)
AddDBEnchantedBorder(
attrTargetButton,
0.62,
true
)
StylePlayerPanelButton(
attrTargetButton,
false
)
local attrName =
Instance.new(
"TextBox"
)
attrName.Size =
UDim2.new(
0.34,
-5,
0,
26
)
attrName.Position =
UDim2.new(
0.29,
0,
0,
7
)
attrName.BackgroundColor3 =
Color3.fromRGB(
9,
12,
18
)
attrName.BackgroundTransparency =
0.10
attrName.BorderSizePixel = 0
attrName.TextColor3 =
Color3.fromRGB(
250,
252,
255
)
attrName.PlaceholderColor3 =
Color3.fromRGB(
210,
224,
240
)
attrName.PlaceholderText = "属性名"
attrName.ClearTextOnFocus = false
attrName.Text = ""
attrName.TextSize = 9
attrName.Font = Enum.Font.GothamMedium
attrName.ZIndex = 24
attrName.Parent = attrControl
AddCorner(
attrName,
6
)
local attrValue =
Instance.new(
"TextBox"
)
attrValue.Size =
UDim2.new(
0.36,
-5,
0,
26
)
attrValue.Position =
UDim2.new(
0.64,
0,
0,
7
)
attrValue.BackgroundColor3 =
Color3.fromRGB(
9,
12,
18
)
attrValue.BackgroundTransparency =
0.10
attrValue.BorderSizePixel = 0
attrValue.TextColor3 =
Color3.fromRGB(
250,
252,
255
)
attrValue.PlaceholderColor3 =
Color3.fromRGB(
210,
224,
240
)
attrValue.PlaceholderText = "值：数字/true/false/文本"
attrValue.ClearTextOnFocus = false
attrValue.Text = ""
attrValue.TextSize = 9
attrValue.Font = Enum.Font.GothamMedium
attrValue.ZIndex = 24
attrValue.Parent = attrControl
AddCorner(
attrValue,
6
)
local setAttr =
Instance.new(
"TextButton"
)
setAttr.Size =
UDim2.new(
0.48,
-6,
0,
26
)
setAttr.Position =
UDim2.new(
0.01,
0,
0,
40
)
setAttr.BackgroundColor3 =
Color3.fromRGB(
15,
22,
31
)
setAttr.BackgroundTransparency =
0.08
setAttr.BorderSizePixel = 0
setAttr.Text = "设置属性"
setAttr.TextSize = 9
setAttr.Font = Enum.Font.GothamBold
setAttr.AutoButtonColor = false
setAttr.ZIndex = 24
setAttr.Parent = attrControl
AddCorner(
setAttr,
6
)
AddDBEnchantedBorder(
setAttr,
0.62,
true
)
StylePlayerPanelButton(
setAttr,
false
)
local removeAttr =
Instance.new(
"TextButton"
)
removeAttr.Size =
UDim2.new(
0.48,
-6,
0,
26
)
removeAttr.Position =
UDim2.new(
0.51,
0,
0,
40
)
removeAttr.BackgroundColor3 =
Color3.fromRGB(
32,
17,
22
)
removeAttr.BackgroundTransparency =
0.08
removeAttr.BorderSizePixel = 0
removeAttr.Text = "删除属性"
removeAttr.TextSize = 9
removeAttr.Font = Enum.Font.GothamBold
removeAttr.TextColor3 =
Color3.fromRGB(
255,
105,
125
)
removeAttr.AutoButtonColor = false
removeAttr.ZIndex = 24
removeAttr.Parent = attrControl
AddCorner(
removeAttr,
6
)
StylePlayerPanelButton(
removeAttr,
true
)
local attrList =
Instance.new(
"TextLabel"
)
attrList.Size =
UDim2.new(
1,
0,
0,
72
)
attrList.BackgroundColor3 =
Color3.fromRGB(
8,
10,
15
)
attrList.BackgroundTransparency =
0.30
attrList.BorderSizePixel = 0
attrList.Text = "暂无自定义属性"
attrList.TextWrapped = true
attrList.TextColor3 =
Color3.fromRGB(
230,
238,
250
)
attrList.TextSize = 8
attrList.Font = Enum.Font.Code
attrList.TextXAlignment =
Enum.TextXAlignment.Left
attrList.TextYAlignment =
Enum.TextYAlignment.Top
attrList.ZIndex = 23
attrList.Parent = attrSection
AddCorner(
attrList,
7
)
local function getAttrTarget()
local player,
character,
humanoid =
getTargets()
local name =
attrTargets[
attrTargetIndex
]
if name == "玩家" then
return player
elseif name == "角色" then
return character
end
return humanoid
end
local function parseAttributeValue(
raw
)
local lower =
string.lower(
raw
)
if lower == "true" then
return true
elseif lower == "false" then
return false
end
local n =
safeNumber(
raw
)
if n then
return n
end
return raw
end
local function refreshAttrs()
attrTargetButton.Text =
attrTargets[
attrTargetIndex
]
local target =
getAttrTarget()
if not target then
attrList.Text =
"目标不存在"
return
end
local ok,
attrs =
pcall(function()
return target:GetAttributes()
end)
if not ok then
attrList.Text =
"无法读取自定义属性"
return
end
local lines = {}
for name,
value in pairs(
attrs
) do
lines[
#lines + 1
] =
tostring(name)
.. " = "
.. tostring(value)
end
table.sort(
lines
)
if #lines == 0 then
attrList.Text =
"暂无自定义属性"
else
attrList.Text =
table.concat(
lines,
"\n"
)
end
end
attrTargetButton.Activated:Connect(function()
attrTargetIndex =
attrTargetIndex % #attrTargets
+ 1
refreshAttrs()
end)
setAttr.Activated:Connect(function()
local target =
getAttrTarget()
if not target
or attrName.Text == "" then
return
end
pcall(function()
target:SetAttribute(
attrName.Text,
parseAttributeValue(
attrValue.Text
)
)
end)
refreshAttrs()
end)
removeAttr.Activated:Connect(function()
local target =
getAttrTarget()
if not target
or attrName.Text == "" then
return
end
pcall(function()
target:SetAttribute(
attrName.Text,
nil
)
end)
refreshAttrs()
end)
refreshers[
#refreshers + 1
] = refreshAttrs
local valuesSection =
createSection(
"数值对象 / 排行榜数据"
)
local valuesHint =
Instance.new(
"TextLabel"
)
valuesHint.Size =
UDim2.new(
1,
0,
0,
28
)
valuesHint.BackgroundTransparency = 1
valuesHint.Text =
"扫描玩家和角色中可见的整数、数字、开关、文本数值；仅本地修改，服务端可能覆盖。"
valuesHint.TextWrapped = true
valuesHint.TextColor3 =
Color3.fromRGB(
220,
232,
248
)
valuesHint.TextSize = 8
valuesHint.Font = Enum.Font.GothamMedium
valuesHint.TextXAlignment =
Enum.TextXAlignment.Left
valuesHint.ZIndex = 23
valuesHint.Parent = valuesSection
local dynamicValuesHost =
Instance.new(
"Frame"
)
dynamicValuesHost.Name =
"DynamicValuesHost"
dynamicValuesHost.Size =
UDim2.new(
1,
0,
0,
0
)
dynamicValuesHost.AutomaticSize =
Enum.AutomaticSize.Y
dynamicValuesHost.BackgroundTransparency = 1
dynamicValuesHost.BorderSizePixel = 0
dynamicValuesHost.ZIndex = 23
dynamicValuesHost.Parent = valuesSection
local dynamicLayout =
Instance.new(
"UIListLayout"
)
dynamicLayout.Padding =
UDim.new(
0,
5
)
dynamicLayout.SortOrder =
Enum.SortOrder.LayoutOrder
dynamicLayout.Parent =
dynamicValuesHost
local function getObjectPath(
object,
root
)
local parts = {}
local current = object
while current
and current ~= root do
table.insert(
parts,
1,
current.Name
)
current =
current.Parent
end
return table.concat(
parts,
"."
)
end
local function refreshValueRows()
for _,
child in ipairs(
dynamicValuesHost:GetChildren()
) do
if child:IsA(
"Frame"
) then
child:Destroy()
end
end
local player,
character =
getTargets()
local found = {}
local function scan(
root,
prefix
)
if not root then
return
end
for _,
object in ipairs(
root:GetDescendants()
) do
if object:IsA(
"IntValue"
)
or object:IsA(
"NumberValue"
)
or object:IsA(
"BoolValue"
)
or object:IsA(
"StringValue"
) then
found[
#found + 1
] = {
Object = object,
Label =
prefix
.. "."
.. getObjectPath(
object,
root
)
}
if #found >= 40 then
return
end
end
end
end
scan(
player,
"玩家"
)
if #found < 40 then
scan(
character,
"角色"
)
end
if #found == 0 then
local empty =
Instance.new(
"TextLabel"
)
empty.Size =
UDim2.new(
1,
0,
0,
28
)
empty.BackgroundTransparency = 1
empty.Text =
"当前没有可见的数值对象数据"
empty.TextColor3 =
Color3.fromRGB(
220,
232,
248
)
empty.TextSize = 9
empty.Font = Enum.Font.GothamMedium
empty.ZIndex = 23
empty.Parent =
dynamicValuesHost
return
end
for index,
info in ipairs(
found
) do
local object =
info.Object
local row =
createRow(
dynamicValuesHost,
34
)
row.LayoutOrder =
index
local label =
Instance.new(
"TextLabel"
)
label.Size =
UDim2.new(
0.48,
-5,
1,
0
)
label.Position =
UDim2.fromOffset(
8,
0
)
label.BackgroundTransparency = 1
label.Text = info.Label
label.TextTruncate =
Enum.TextTruncate.AtEnd
label.TextColor3 =
Color3.fromRGB(
225,
230,
240
)
label.TextSize = 8
label.Font = Enum.Font.GothamMedium
label.TextXAlignment =
Enum.TextXAlignment.Left
label.ZIndex = 24
label.Parent = row
local box =
Instance.new(
"TextBox"
)
box.Size =
UDim2.new(
0.31,
-4,
0,
25
)
box.Position =
UDim2.new(
0.50,
0,
0.5,
-12
)
box.BackgroundColor3 =
Color3.fromRGB(
9,
12,
18
)
box.BackgroundTransparency =
0.10
box.BorderSizePixel = 0
box.ClearTextOnFocus = false
box.TextColor3 =
Color3.fromRGB(
250,
252,
255
)
box.Text =
tostring(
object.Value
)
box.TextSize = 8
box.Font = Enum.Font.GothamMedium
box.ZIndex = 24
box.Parent = row
AddCorner(
box,
6
)
local apply =
Instance.new(
"TextButton"
)
apply.Size =
UDim2.new(
0.18,
-5,
0,
25
)
apply.Position =
UDim2.new(
0.82,
0,
0.5,
-12
)
apply.BackgroundColor3 =
Color3.fromRGB(
15,
22,
31
)
apply.BackgroundTransparency =
0.08
apply.BorderSizePixel = 0
apply.Text = "应用"
apply.TextSize = 8
apply.Font = Enum.Font.GothamBold
apply.AutoButtonColor = false
apply.ZIndex = 24
apply.Parent = row
AddCorner(
apply,
6
)
AddDBEnchantedBorder(
apply,
0.62,
true
)
StylePlayerPanelButton(
apply,
false
)
apply.Activated:Connect(function()
if not object.Parent then
return
end
pcall(function()
if object:IsA(
"BoolValue"
) then
object.Value =
string.lower(
box.Text
) == "true"
elseif object:IsA(
"IntValue"
) then
object.Value =
math.floor(
safeNumber(
box.Text
)
or object.Value
)
elseif object:IsA(
"NumberValue"
) then
object.Value =
safeNumber(
box.Text
)
or object.Value
else
object.Value =
box.Text
end
end)
box.Text =
tostring(
object.Value
)
end)
end
end
createAction(
valuesSection,
"重新扫描数值对象 / 排行榜数据",
refreshValueRows
)
local restoreSection =
createSection(
"恢复与刷新"
)
local function captureSnapshot()
local player,
character,
humanoid,
root,
camera =
getTargets()
if not humanoid then
return
end
snapshot = {
WalkSpeed =
humanoid.WalkSpeed,
JumpPower =
humanoid.JumpPower,
JumpHeight =
humanoid.JumpHeight,
HipHeight =
humanoid.HipHeight,
MaxSlopeAngle =
humanoid.MaxSlopeAngle,
Health =
humanoid.Health,
MaxHealth =
humanoid.MaxHealth,
AutoRotate =
humanoid.AutoRotate,
UseJumpPower =
humanoid.UseJumpPower,
PlatformStand =
humanoid.PlatformStand,
Gravity =
workspace.Gravity,
FOV =
camera
and camera.FieldOfView,
MinZoom =
player.CameraMinZoomDistance,
MaxZoom =
player.CameraMaxZoomDistance,
CameraOffset =
humanoid.CameraOffset,
RootAnchored =
root
and root.Anchored,
RootMassless =
root
and root.Massless,
Scales = {}
}
for _,
info in ipairs(
scaleNames
) do
local value =
humanoid:FindFirstChild(
info[2]
)
if value
and value:IsA(
"NumberValue"
) then
snapshot.Scales[
info[2]
] =
value.Value
end
end
end
local function restoreSnapshot()
if not snapshot then
return
end
local player,
_,
humanoid,
root,
camera =
getTargets()
if not humanoid then
return
end
pcall(function()
humanoid.WalkSpeed =
snapshot.WalkSpeed
humanoid.JumpPower =
snapshot.JumpPower
humanoid.JumpHeight =
snapshot.JumpHeight
humanoid.HipHeight =
snapshot.HipHeight
humanoid.MaxSlopeAngle =
snapshot.MaxSlopeAngle
humanoid.MaxHealth =
snapshot.MaxHealth
humanoid.Health =
math.min(
snapshot.Health,
snapshot.MaxHealth
)
humanoid.AutoRotate =
snapshot.AutoRotate
humanoid.UseJumpPower =
snapshot.UseJumpPower
humanoid.PlatformStand =
snapshot.PlatformStand
humanoid.CameraOffset =
snapshot.CameraOffset
workspace.Gravity =
snapshot.Gravity
if camera
and snapshot.FOV then
camera.FieldOfView =
snapshot.FOV
end
player.CameraMinZoomDistance =
snapshot.MinZoom
player.CameraMaxZoomDistance =
snapshot.MaxZoom
if root then
root.Anchored =
snapshot.RootAnchored
root.Massless =
snapshot.RootMassless
end
for name,
value in pairs(
snapshot.Scales
) do
local scale =
humanoid:FindFirstChild(
name
)
if scale
and scale:IsA(
"NumberValue"
) then
scale.Value =
value
end
end
end)
notify(
"已恢复打开玩家面板时保存的主要数据"
)
end
createAction(
restoreSection,
"保存当前数据为恢复点",
function()
captureSnapshot()
notify(
"已保存当前恢复点"
)
end
)
createAction(
restoreSection,
"恢复保存的数据",
restoreSnapshot
)
local warning =
Instance.new(
"TextLabel"
)
warning.Size =
UDim2.new(
1,
0,
0,
48
)
warning.BackgroundTransparency = 1
warning.Text =
"说明：用户编号、账号年龄等只读信息只展示；血量、移动速度、排行榜数值等若由游戏服务器控制，修改后可能被服务器重新写回。"
warning.TextWrapped = true
warning.TextColor3 =
Color3.fromRGB(
255,
222,
150
)
warning.TextSize = 8
warning.Font = Enum.Font.GothamMedium
warning.TextXAlignment =
Enum.TextXAlignment.Left
warning.TextYAlignment =
Enum.TextYAlignment.Top
warning.ZIndex = 23
warning.Parent = restoreSection
function controller.Refresh()
for _,
callback in ipairs(
refreshers
) do
pcall(
callback
)
end
pcall(
refreshValueRows
)
end
function controller.Show()
panel.Visible = true
for _, obj in ipairs(panel:GetDescendants()) do
if (
obj:IsA("Frame")
or obj:IsA("TextButton")
or obj:IsA("TextBox")
or obj:IsA("ScrollingFrame")
)
and obj.BackgroundTransparency < 0.98 then
local c = obj.BackgroundColor3
local luminance =
c.R * 0.299
+ c.G * 0.587
+ c.B * 0.114
if luminance < 0.48 then
obj.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
obj.BackgroundTransparency =
math.max(
obj.BackgroundTransparency,
0.82
)
end
end
if obj:IsA("UIStroke")
and obj.Name ~= "DB_RainbowMain"
then
obj.Color =
Color3.fromRGB(
255,
255,
255
)
end
end
panel.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
panel.BackgroundTransparency =
0.82
if not snapshot then
captureSnapshot()
end
controller.Refresh()
end
function controller.Hide()
panel.Visible = false
end
controller.Frame = panel
refreshButton.Activated:Connect(function()
controller.Refresh()
end)
LocalPlayer.CharacterAdded:Connect(function()
task.delay(
0.60,
function()
if panel.Visible then
snapshot = nil
controller.Show()
end
end
)
end)
return controller
end
local function DBBuildHome()
local PlayerControlPanel
PlayerControlPanel =
DBCreateAdvancedPlayerPanel(
RightList
)
local HomePanel = Instance.new("Frame")
HomePanel.Name = "DB_Home_Panel"
HomePanel.Size = UDim2.new(1, 0, 1, -4)
HomePanel.Position = UDim2.new(0, 0, 0, 2)
HomePanel.BackgroundTransparency = 1
HomePanel.Visible = false
HomePanel.ZIndex = 20
HomePanel.Parent = RightList
local HomeScroll = Instance.new("ScrollingFrame")
HomeScroll.Name = "HomeScroll"
HomeScroll.Size = UDim2.fromScale(1, 1)
HomeScroll.BackgroundTransparency = 1
HomeScroll.BorderSizePixel = 0
HomeScroll.ScrollBarThickness = 2
HomeScroll.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 205)
HomeScroll.ScrollBarImageTransparency = 0.58
HomeScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
HomeScroll.CanvasSize = UDim2.new()
HomeScroll.ZIndex = 21
HomeScroll.Parent = HomePanel
local HomeLayout = Instance.new("UIListLayout")
HomeLayout.Padding = UDim.new(0, 8)
HomeLayout.SortOrder = Enum.SortOrder.LayoutOrder
HomeLayout.Parent = HomeScroll
local HomePadding = Instance.new("UIPadding")
HomePadding.PaddingTop = UDim.new(0, 7)
HomePadding.PaddingBottom = UDim.new(0, 8)
HomePadding.PaddingLeft = UDim.new(0, 2)
HomePadding.PaddingRight = UDim.new(0, 2)
HomePadding.Parent = HomeScroll
local function CreateHomeCard(titleText, height)
local card = Instance.new("Frame")
card.Size = UDim2.new(1, -2, 0, height)
card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
card.BackgroundTransparency = 0.82
card.BorderSizePixel = 0
card.ZIndex = 22
card.Parent = HomeScroll
AddCorner(card, 11)
AddDBEnchantedBorder(
card,
1.25,
true
)
local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(12, 7)
title.Size = UDim2.new(1, -24, 0, 20)
title.Text = titleText
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 23
title.Parent = card
AddDBEnchantedText(
title,
false
)
local value = Instance.new("TextLabel")
value.Name = "Value"
value.BackgroundTransparency = 1
value.Position = UDim2.fromOffset(12, 29)
value.Size = UDim2.new(1, -24, 1, -36)
value.Text = ""
value.TextColor3 = Color3.fromRGB(255, 255, 255)
value.TextSize = 11
value.Font = Enum.Font.GothamMedium
value.TextWrapped = true
value.TextXAlignment = Enum.TextXAlignment.Left
value.TextYAlignment = Enum.TextYAlignment.Top
value.ZIndex = 23
value.Parent = card
return card, value
end
local PlayerInfoCard = Instance.new("Frame")
PlayerInfoCard.Name = "PlayerInfoCard"
PlayerInfoCard.Size = UDim2.new(1, -10, 0, 238)
PlayerInfoCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
PlayerInfoCard.BackgroundTransparency = 0.76
PlayerInfoCard.BorderSizePixel = 0
PlayerInfoCard.LayoutOrder = 1
PlayerInfoCard.Position = UDim2.fromOffset(5, 4)
PlayerInfoCard.ZIndex = 22
PlayerInfoCard.Parent = PlayerProfileScroll
AddCorner(PlayerInfoCard, 12)
AddDBEnchantedBorder(
PlayerInfoCard,
1.45,
true
)
local PlayerInfoTitle = Instance.new("TextLabel")
PlayerInfoTitle.BackgroundTransparency = 1
PlayerInfoTitle.Position = UDim2.fromOffset(8, 7)
PlayerInfoTitle.Size = UDim2.new(1, -16, 0, 19)
PlayerInfoTitle.Text = "玩家信息"
PlayerInfoTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerInfoTitle.TextSize = 11
PlayerInfoTitle.Font = Enum.Font.GothamBold
PlayerInfoTitle.TextXAlignment = Enum.TextXAlignment.Left
PlayerInfoTitle.ZIndex = 24
PlayerInfoTitle.Parent = PlayerInfoCard
AddDBEnchantedText(
PlayerInfoTitle,
false
)
local PlayerAvatar = Instance.new("ImageLabel")
PlayerAvatar.Name = "PlayerAvatar"
PlayerAvatar.Position = UDim2.fromOffset(8, 31)
PlayerAvatar.Size = UDim2.new(1, -16, 0, 86)
PlayerAvatar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
PlayerAvatar.BackgroundTransparency = 0.82
PlayerAvatar.BorderSizePixel = 0
PlayerAvatar.Image = ""
PlayerAvatar.ScaleType = Enum.ScaleType.Crop
PlayerAvatar.ZIndex = 24
PlayerAvatar.Parent = PlayerInfoCard
local PlayerAvatarCorner = Instance.new("UICorner")
PlayerAvatarCorner.CornerRadius = UDim.new(0, 8)
PlayerAvatarCorner.Parent = PlayerAvatar
local PlayerAvatarStroke = Instance.new("UIStroke")
PlayerAvatarStroke.Thickness = 1.15
PlayerAvatarStroke.Transparency = 0.12
PlayerAvatarStroke.Color = Color3.fromRGB(220, 220, 225)
PlayerAvatarStroke.Parent = PlayerAvatar
local PlayerNameLabel = Instance.new("TextLabel")
PlayerNameLabel.BackgroundTransparency = 1
PlayerNameLabel.Position = UDim2.fromOffset(8, 124)
PlayerNameLabel.Size = UDim2.new(1, -16, 0, 31)
PlayerNameLabel.Text = "玩家名字：读取中..."
PlayerNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerNameLabel.TextSize = 10
PlayerNameLabel.Font = Enum.Font.GothamBold
PlayerNameLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerNameLabel.TextWrapped = true
PlayerNameLabel.ZIndex = 24
PlayerNameLabel.Parent = PlayerInfoCard
local PlayerAgeLabel = Instance.new("TextLabel")
PlayerAgeLabel.BackgroundTransparency = 1
PlayerAgeLabel.Position = UDim2.fromOffset(8, 157)
PlayerAgeLabel.Size = UDim2.new(1, -16, 0, 28)
PlayerAgeLabel.Text = "账号年龄：读取中..."
PlayerAgeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerAgeLabel.TextSize = 9
PlayerAgeLabel.Font = Enum.Font.GothamMedium
PlayerAgeLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerAgeLabel.TextWrapped = true
PlayerAgeLabel.ZIndex = 24
PlayerAgeLabel.Parent = PlayerInfoCard
local PlayerUsernameLabel = Instance.new("TextLabel")
PlayerUsernameLabel.BackgroundTransparency = 1
PlayerUsernameLabel.Position = UDim2.fromOffset(8, 188)
PlayerUsernameLabel.Size = UDim2.new(1, -16, 0, 40)
PlayerUsernameLabel.Text = ""
PlayerUsernameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerUsernameLabel.TextSize = 9
PlayerUsernameLabel.Font = Enum.Font.GothamBold
PlayerUsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerUsernameLabel.TextWrapped = true
PlayerUsernameLabel.ZIndex = 24
PlayerUsernameLabel.Parent = PlayerInfoCard
local function CreatePlayer3DPreview()
local PreviewRunService =
game:GetService(
"RunService"
)
local previewState = {
Enabled = false,
SourceCharacter = nil,
SourceRoot = nil,
CloneCharacter = nil,
CloneRoot = nil,
PartPairs = {},
Center = Vector3.new(0, 1.5, 0),
Distance = 7,
BaseSourceYaw = 0,
DisplayYaw = 0
}
local switchButton =
Instance.new(
"TextButton"
)
switchButton.Name =
"Player3DSwitch"
switchButton.Position =
UDim2.fromOffset(
3,
28
)
switchButton.Size =
UDim2.fromOffset(
24,
24
)
switchButton.BackgroundColor3 =
Color3.fromRGB(
12,
22,
34
)
switchButton.BackgroundTransparency =
0.12
switchButton.BorderSizePixel = 0
switchButton.AutoButtonColor = false
switchButton.Text = "⇅"
switchButton.TextSize = 14
switchButton.Font =
Enum.Font.GothamBlack
switchButton.ZIndex = 45
switchButton.Parent =
PlayerInfoCard
AddCorner(
switchButton,
9
)
AddDBEnchantedBorder(
switchButton,
0.72,
true
)
AddDBEnchantedText(
switchButton,
false
)
local viewport =
Instance.new(
"ViewportFrame"
)
viewport.Name =
"Player3DViewport"
viewport.Position =
UDim2.fromOffset(
5,
29
)
viewport.Size =
UDim2.fromOffset(
94,
94
)
viewport.BackgroundColor3 =
Color3.fromRGB(
7,
12,
20
)
viewport.BackgroundTransparency =
0.035
viewport.BorderSizePixel = 0
viewport.Active = false
viewport.Ambient =
Color3.fromRGB(
180,
190,
215
)
viewport.LightColor =
Color3.fromRGB(
255,
255,
255
)
viewport.LightDirection =
Vector3.new(
-0.55,
-0.85,
-0.65
)
viewport.ImageColor3 =
Color3.fromRGB(
255,
255,
255
)
viewport.ImageTransparency = 0
viewport.Visible = false
viewport.ZIndex = 34
viewport.Parent =
PlayerInfoCard
AddCorner(
viewport,
10
)
AddDBEnchantedBorder(
viewport,
0.72,
true
)
local world =
Instance.new(
"WorldModel"
)
world.Name =
"DB_PlayerPreviewWorld"
world.Parent =
viewport
local camera =
Instance.new(
"Camera"
)
camera.Name =
"DB_PlayerPreviewCamera"
camera.FieldOfView = 30
camera.Parent =
viewport
viewport.CurrentCamera =
camera
local function GetRelativePath(
object,
root
)
local names = {}
local current = object
while current
and current ~= root do
table.insert(
names,
1,
current.Name
)
current =
current.Parent
end
return table.concat(
names,
"/"
)
end
local function ClearPreviewCharacter()
previewState.PartPairs = {}
previewState.SourceCharacter = nil
previewState.SourceRoot = nil
previewState.CloneRoot = nil
if previewState.CloneCharacter then
pcall(function()
previewState.CloneCharacter:Destroy()
end)
previewState.CloneCharacter = nil
end
for _, child in ipairs(
world:GetChildren()
) do
child:Destroy()
end
end
local function UpdatePreviewCamera()
camera.CFrame =
CFrame.lookAt(
previewState.Center
+ Vector3.new(
0,
0,
previewState.Distance
),
previewState.Center
)
end
local function GetYawFromCFrame(cf)
local look =
cf.LookVector
return math.atan2(
-look.X,
-look.Z
)
end
local function WrapAngle(angle)
return math.atan2(
math.sin(angle),
math.cos(angle)
)
end
local function BuildPreviewCharacter()
ClearPreviewCharacter()
local character =
LocalPlayer.Character
if not character then
return
end
local sourceRoot =
character:FindFirstChild(
"HumanoidRootPart"
)
if not sourceRoot then
return
end
local oldArchivable =
character.Archivable
character.Archivable = true
local ok, clone =
pcall(function()
return character:Clone()
end)
character.Archivable =
oldArchivable
if not ok
or not clone then
return
end
clone.Name =
"DB_Player3DClone"
for _, object in ipairs(
clone:GetDescendants()
) do
if object:IsA("Tool")
or object:IsA("Script")
or object:IsA("LocalScript")
or object:IsA("ModuleScript") then
object:Destroy()
elseif object:IsA("BasePart") then
object.Anchored = true
object.CanCollide = false
object.CanQuery = false
object.CanTouch = false
object.CastShadow = false
end
end
local cloneHumanoid =
clone:FindFirstChildOfClass(
"Humanoid"
)
if cloneHumanoid then
pcall(function()
cloneHumanoid.DisplayDistanceType =
Enum.HumanoidDisplayDistanceType.None
end)
end
clone.Parent =
world
local cloneRoot =
clone:FindFirstChild(
"HumanoidRootPart"
)
if not cloneRoot then
clone:Destroy()
return
end
local cloneParts = {}
for _, part in ipairs(
clone:GetDescendants()
) do
if part:IsA("BasePart") then
cloneParts[
GetRelativePath(
part,
clone
)
] = part
end
end
local pairsList = {}
for _, sourcePart in ipairs(
character:GetDescendants()
) do
if sourcePart:IsA("BasePart") then
local isToolPart =
sourcePart:FindFirstAncestorOfClass(
"Tool"
)
~= nil
if not isToolPart then
local key =
GetRelativePath(
sourcePart,
character
)
local clonePart =
cloneParts[key]
if clonePart then
pairsList[
#pairsList + 1
] = {
Source =
sourcePart,
Clone =
clonePart
}
end
end
end
end
previewState.SourceCharacter =
character
previewState.SourceRoot =
sourceRoot
previewState.BaseSourceYaw =
GetYawFromCFrame(
sourceRoot.CFrame
)
previewState.DisplayYaw =
math.rad(180)
previewState.CloneCharacter =
clone
previewState.CloneRoot =
cloneRoot
previewState.PartPairs =
pairsList
for _, pair in ipairs(
previewState.PartPairs
) do
if pair.Source.Parent
and pair.Clone.Parent then
pair.Clone.CFrame =
CFrame.Angles(
0,
previewState.DisplayYaw,
0
)
* sourceRoot.CFrame:ToObjectSpace(
pair.Source.CFrame
)
end
end
local boxCF, boxSize =
clone:GetBoundingBox()
previewState.Center =
boxCF.Position
local halfFov =
math.rad(
camera.FieldOfView
* 0.5
)
local tanHalfFov =
math.max(
0.01,
math.tan(
halfFov
)
)
local fitY =
(
boxSize.Y
* 0.5
)
/ tanHalfFov
local fitX =
(
boxSize.X
* 0.5
)
/ tanHalfFov
local depthAllowance =
boxSize.Z
* 0.5
local extraMargin =
0.42
previewState.Distance =
math.max(
4.8,
math.max(
fitX,
fitY
)
+ depthAllowance
+ extraMargin
)
previewState.Yaw = 0
previewState.Pitch = 0
UpdatePreviewCamera()
end
local function SetPreviewEnabled(
enabled
)
previewState.Enabled =
enabled == true
PlayerAvatar.Visible =
not previewState.Enabled
PlayerNameLabel.Visible = true
PlayerAgeLabel.Visible = true
PlayerUsernameLabel.Visible = true
if FriendBox then FriendBox.Visible = true end
viewport.Visible =
previewState.Enabled
if previewState.Enabled then
BuildPreviewCharacter()
end
end
switchButton.Activated:Connect(function()
SetPreviewEnabled(
not previewState.Enabled
)
end)
local renderConnection =
PreviewRunService.RenderStepped:Connect(
function()
if not previewState.Enabled then
return
end
local sourceRoot =
previewState.SourceRoot
local clone =
previewState.CloneCharacter
if not sourceRoot
or not sourceRoot.Parent
or not clone
or not clone.Parent then
BuildPreviewCharacter()
return
end
local currentYaw =
GetYawFromCFrame(
sourceRoot.CFrame
)
local rawYaw =
WrapAngle(
currentYaw
- previewState.BaseSourceYaw
)
local maxFrontYaw =
math.rad(90)
if math.abs(rawYaw)
<= maxFrontYaw then
previewState.DisplayYaw =
math.rad(180)
+ rawYaw
end
local previewRotation =
CFrame.Angles(
0,
previewState.DisplayYaw,
0
)
for _, pair in ipairs(
previewState.PartPairs
) do
local sourcePart =
pair.Source
local clonePart =
pair.Clone
if sourcePart
and sourcePart.Parent
and clonePart
and clonePart.Parent then
clonePart.CFrame =
previewRotation
* sourceRoot.CFrame:ToObjectSpace(
sourcePart.CFrame
)
end
end
end
)
local characterConnection =
LocalPlayer.CharacterAdded:Connect(
function()
if previewState.Enabled then
task.delay(
0.45,
BuildPreviewCharacter
)
end
end
)
PlayerInfoCard.AncestryChanged:Connect(
function(_, parent)
if parent ~= nil then
return
end
pcall(function()
renderConnection:Disconnect()
end)
pcall(function()
characterConnection:Disconnect()
end)
end
)
return {
Button = switchButton,
Viewport = viewport,
SetEnabled = SetPreviewEnabled,
Refresh = BuildPreviewCharacter
}
end
local Player3DPreview = nil
local function GetUserHeadshot(userId)
local ok, content =
pcall(function()
local image =
Players:GetUserThumbnailAsync(
userId,
Enum.ThumbnailType.HeadShot,
Enum.ThumbnailSize.Size150x150
)
return image
end)
if ok then
return content
end
return ""
end
task.spawn(function()
local avatar =
GetUserHeadshot(
LocalPlayer.UserId
)
if PlayerAvatar
and PlayerAvatar.Parent then
PlayerAvatar.Image =
avatar
end
end)
PlayerNameLabel.Text =
"玩家名字：\n"
.. tostring(LocalPlayer.DisplayName)
PlayerAgeLabel.Text =
"账号年龄：\n"
.. tostring(LocalPlayer.AccountAge)
.. " 天"
PlayerUsernameLabel.Text =
"玩家用户名：\n"
.. tostring(LocalPlayer.Name)
local ProcessCard, ProcessValue =
CreateHomeCard(
"正在运行的脚本 / 运行状态",
92
)
ProcessCard.LayoutOrder = 2
local function CreatePerformanceCard()
local RunService = game:GetService("RunService")
local card = Instance.new("Frame")
card.Name = "PerformanceCard"
card.Size = UDim2.new(1, -2, 0, 288)
card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
card.BackgroundTransparency = 0.82
card.BorderSizePixel = 0
card.LayoutOrder = 3
card.ZIndex = 22
card.Parent = HomeScroll
AddCorner(card, 12)
AddDBEnchantedBorder(
card,
1.35,
true
)
local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(13, 7)
title.Size = UDim2.new(1, -26, 0, 20)
title.Text = "实时帧率 / 网络延迟"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 24
title.Parent = card
AddDBEnchantedText(
title,
false
)
local liveLabel = Instance.new("TextLabel")
liveLabel.BackgroundTransparency = 1
liveLabel.Position = UDim2.fromOffset(13, 29)
liveLabel.Size = UDim2.new(0.44, -4, 0, 20)
liveLabel.Text = "FPS：--    Ping：-- ms"
liveLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
liveLabel.TextSize = 10
liveLabel.Font = Enum.Font.GothamMedium
liveLabel.TextXAlignment = Enum.TextXAlignment.Left
liveLabel.ZIndex = 24
liveLabel.Parent = card
local avgTopLabel = Instance.new("TextLabel")
avgTopLabel.BackgroundTransparency = 1
avgTopLabel.Position = UDim2.new(0.44, 4, 0, 29)
avgTopLabel.Size = UDim2.new(0.20, -6, 0, 20)
avgTopLabel.Text = "AVG：--"
avgTopLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
avgTopLabel.TextSize = 10
avgTopLabel.Font = Enum.Font.GothamMedium
avgTopLabel.TextXAlignment = Enum.TextXAlignment.Left
avgTopLabel.ZIndex = 24
avgTopLabel.Parent = card
local floatToggle = Instance.new("TextButton")
floatToggle.AnchorPoint = Vector2.new(1, 0)
floatToggle.Position = UDim2.new(1, -12, 0, 28)
floatToggle.Size = UDim2.new(0.31, 0, 0, 21)
floatToggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
floatToggle.BackgroundTransparency = 0.84
floatToggle.BorderSizePixel = 0
floatToggle.Text = "实时帧率 · 关"
floatToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
floatToggle.TextSize = 8
floatToggle.Font = Enum.Font.GothamMedium
floatToggle.AutoButtonColor = false
floatToggle.ZIndex = 25
floatToggle.Parent = card
AddCorner(floatToggle, 12)
local floatingFPS = Instance.new("Frame")
floatingFPS.Name = "DB_FloatingFPS"
floatingFPS.AnchorPoint = Vector2.new(0.5, 0.5)
floatingFPS.Position = UDim2.fromScale(0.5, 0.5)
floatingFPS.Size = UDim2.fromOffset(82, 29)
floatingFPS.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
floatingFPS.BackgroundTransparency = 1
floatingFPS.BorderSizePixel = 0
floatingFPS.Active = true
floatingFPS.Visible = false
floatingFPS.ZIndex = 1000
floatingFPS.Parent = MainGui
AddCorner(floatingFPS, 14)
local floatingText = Instance.new("TextLabel")
floatingText.Size = UDim2.fromScale(1, 1)
floatingText.BackgroundTransparency = 1
floatingText.Text = "FPS --"
floatingText.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingText.TextStrokeTransparency = 1
floatingText.TextSize = 15
floatingText.Font = Enum.Font.GothamBlack
floatingText.ZIndex = 1001
floatingText.Parent = floatingFPS
local floatingEnabled = false
local dragging = false
local dragInput = nil
local dragStart = nil
local dragStartPosition = nil
local function setFloatingEnabled(enabled)
floatingEnabled = enabled == true
floatingFPS.Visible = floatingEnabled
floatToggle.Text = floatingEnabled and "实时帧率 · 开" or "实时帧率 · 关"
floatToggle.BackgroundColor3 = floatingEnabled and Color3.fromRGB(46, 153, 78) or Color3.fromRGB(48, 48, 56)
end
floatToggle.Activated:Connect(function()
setFloatingEnabled(not floatingEnabled)
end)
floatingFPS.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
dragStart = input.Position
dragStartPosition = floatingFPS.Position
input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
dragging = false
end
end)
end
end)
floatingFPS.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
dragInput = input
end
end)
UserInputService.InputChanged:Connect(function(input)
if dragging and input == dragInput and dragStart and dragStartPosition then
local delta = input.Position - dragStart
floatingFPS.Position = UDim2.new(
dragStartPosition.X.Scale,
dragStartPosition.X.Offset + delta.X,
dragStartPosition.Y.Scale,
dragStartPosition.Y.Offset + delta.Y
)
end
end)
local statsFrame = Instance.new("Frame")
statsFrame.Position = UDim2.fromOffset(10, 53)
statsFrame.Size = UDim2.new(1, -20, 0, 43)
statsFrame.BackgroundTransparency = 1
statsFrame.ZIndex = 24
statsFrame.Parent = card
local statsLayout = Instance.new("UIListLayout")
statsLayout.FillDirection = Enum.FillDirection.Horizontal
statsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
statsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
statsLayout.Padding = UDim.new(0, 2)
statsLayout.Parent = statsFrame
local statValues = {}
local function createStat(nameText)
local cell = Instance.new("Frame")
cell.Size = UDim2.new(0.2, -2, 1, 0)
cell.BackgroundTransparency = 1
cell.ZIndex = 24
cell.Parent = statsFrame
local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1, 0, 0, 14)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = nameText
nameLabel.TextColor3 = Color3.fromRGB(145, 148, 158)
nameLabel.TextSize = 7
nameLabel.Font = Enum.Font.Gotham
nameLabel.ZIndex = 25
nameLabel.Parent = cell
local valueLabel = Instance.new("TextLabel")
valueLabel.Position = UDim2.fromOffset(0, 14)
valueLabel.Size = UDim2.new(1, 0, 0, 20)
valueLabel.BackgroundTransparency = 1
valueLabel.Text = "--"
valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
valueLabel.TextSize = 11
valueLabel.Font = Enum.Font.GothamBold
valueLabel.ZIndex = 25
valueLabel.Parent = cell
statValues[nameText] = valueLabel
end
createStat("MAX")
createStat("MIN")
createStat("AVG")
createStat("JITTER")
createStat("5% LOW")
local chart = Instance.new("Frame")
chart.Name = "FPSChart"
chart.Position = UDim2.fromOffset(33, 102)
chart.Size = UDim2.new(1, -39, 1, -122)
chart.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
chart.BackgroundTransparency = 0.88
chart.BorderSizePixel = 0
chart.ClipsDescendants = false
chart.ZIndex = 23
chart.Parent = card
AddCorner(chart, 7)
local haze = Instance.new("Frame")
haze.Size = UDim2.fromScale(1, 1)
haze.BackgroundColor3 = Color3.fromRGB(70, 73, 84)
haze.BackgroundTransparency = 0.93
haze.BorderSizePixel = 0
haze.ZIndex = 23
haze.Parent = chart
AddCorner(haze, 7)
local grid = Instance.new("Frame")
grid.Size = UDim2.fromScale(1, 1)
grid.BackgroundTransparency = 1
grid.ClipsDescendants = true
grid.ZIndex = 24
grid.Parent = chart
local fpsTicks = {0, 10, 15, 30, 40, 60, 90, 120}
for _, value in ipairs(fpsTicks) do
local yScale = 1 - math.clamp(value / 120, 0, 1)
local major = value == 0 or value == 30 or value == 60 or value == 90 or value == 120
local line = Instance.new("Frame")
line.AnchorPoint = Vector2.new(0, 0.5)
line.Position = UDim2.new(0, 0, yScale, 0)
line.Size = UDim2.new(1, 0, 0, 1)
line.BackgroundColor3 = Color3.fromRGB(205, 208, 218)
line.BackgroundTransparency = major and 0.87 or 0.95
line.BorderSizePixel = 0
line.ZIndex = 24
line.Parent = grid
local label = Instance.new("TextLabel")
label.AnchorPoint = Vector2.new(1, 0.5)
label.Position = UDim2.new(0, -5, yScale, 0)
label.Size = UDim2.fromOffset(27, 13)
label.BackgroundTransparency = 1
label.Text = tostring(value)
label.TextColor3 = Color3.fromRGB(157, 160, 170)
label.TextSize = 7
label.Font = Enum.Font.Gotham
label.TextXAlignment = Enum.TextXAlignment.Right
label.ZIndex = 25
label.Parent = chart
end
for i = 1, 7 do
local line = Instance.new("Frame")
line.AnchorPoint = Vector2.new(0.5, 0)
line.Position = UDim2.new(i / 8, 0, 0, 0)
line.Size = UDim2.new(0, 1, 1, 0)
line.BackgroundColor3 = Color3.fromRGB(205, 208, 218)
line.BackgroundTransparency = 0.93
line.BorderSizePixel = 0
line.ZIndex = 24
line.Parent = grid
end
local yAxis = Instance.new("Frame")
yAxis.Size = UDim2.new(0, 2, 1, 0)
yAxis.BackgroundColor3 = Color3.fromRGB(220, 223, 230)
yAxis.BackgroundTransparency = 0.30
yAxis.BorderSizePixel = 0
yAxis.ZIndex = 27
yAxis.Parent = chart
local yArrow = Instance.new("TextLabel")
yArrow.AnchorPoint = Vector2.new(0.5, 0.5)
yArrow.Position = UDim2.fromOffset(0, -1)
yArrow.Size = UDim2.fromOffset(15, 15)
yArrow.BackgroundTransparency = 1
yArrow.Text = "↑"
yArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
yArrow.TextSize = 14
yArrow.Font = Enum.Font.GothamBold
yArrow.ZIndex = 29
yArrow.Parent = chart
local xAxis = Instance.new("Frame")
xAxis.AnchorPoint = Vector2.new(0, 1)
xAxis.Position = UDim2.new(0, 0, 1, 0)
xAxis.Size = UDim2.new(1, 0, 0, 2)
xAxis.BackgroundColor3 = Color3.fromRGB(220, 223, 230)
xAxis.BackgroundTransparency = 0.30
xAxis.BorderSizePixel = 0
xAxis.ZIndex = 27
xAxis.Parent = chart
local xArrow = Instance.new("TextLabel")
xArrow.AnchorPoint = Vector2.new(0.5, 0.5)
xArrow.Position = UDim2.new(1, 2, 1, 0)
xArrow.Size = UDim2.fromOffset(15, 15)
xArrow.BackgroundTransparency = 1
xArrow.Text = "→"
xArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
xArrow.TextSize = 14
xArrow.Font = Enum.Font.GothamBold
xArrow.ZIndex = 29
xArrow.Parent = chart
local startTimeLabel = Instance.new("TextLabel")
startTimeLabel.Position = UDim2.new(0, 3, 1, 3)
startTimeLabel.Size = UDim2.fromOffset(54, 13)
startTimeLabel.BackgroundTransparency = 1
startTimeLabel.Text = "0:00"
startTimeLabel.TextColor3 = Color3.fromRGB(150, 153, 163)
startTimeLabel.TextSize = 7
startTimeLabel.Font = Enum.Font.Gotham
startTimeLabel.TextXAlignment = Enum.TextXAlignment.Left
startTimeLabel.ZIndex = 25
startTimeLabel.Parent = chart
local midTimeLabel = startTimeLabel:Clone()
midTimeLabel.AnchorPoint = Vector2.new(0.5, 0)
midTimeLabel.Position = UDim2.new(0.5, 0, 1, 3)
midTimeLabel.TextXAlignment = Enum.TextXAlignment.Center
midTimeLabel.Parent = chart
local endTimeLabel = startTimeLabel:Clone()
endTimeLabel.AnchorPoint = Vector2.new(1, 0)
endTimeLabel.Position = UDim2.new(1, -3, 1, 3)
endTimeLabel.TextXAlignment = Enum.TextXAlignment.Right
endTimeLabel.Parent = chart
local SAMPLE_INTERVAL = 0.5
local SMOOTH_WINDOW = 0.75
local HISTORY_WINDOW = 60
local MAX_HISTORY = 121
local MAX_DRAW_POINTS = 121
local FPS_CAP = 60
local FPS_AXIS_MAX = 120
local state = {
SessionStart = time(),
SampleClock = 0,
FrameTimes = {},
Samples = {},
SmoothedFPS = nil,
SmoothedPing = nil,
Segments = {},
LastStatsUpdate = 0
}
local lineLayer = Instance.new("Frame")
lineLayer.Name = "FPSLineLayer"
lineLayer.Size = UDim2.fromScale(1, 1)
lineLayer.BackgroundTransparency = 1
lineLayer.BorderSizePixel = 0
lineLayer.ClipsDescendants = true
lineLayer.ZIndex = 29
lineLayer.Parent = chart
state.UseDrawing = false
for i = 1, MAX_DRAW_POINTS - 1 do
local line =
Instance.new("Frame")
line.Name =
"FPSLine_"
.. tostring(i)
line.AnchorPoint =
Vector2.new(
0.5,
0.5
)
line.Size =
UDim2.fromOffset(
0,
1
)
line.BackgroundColor3 =
Color3.fromRGB(
176,
178,
183
)
line.BackgroundTransparency =
0.06
line.BorderSizePixel = 0
line.Visible = false
line.ZIndex = 30
line.Parent = lineLayer
state.Segments[i] =
line
end
local function hideAllGraphLines()
for _, line in ipairs(
state.Segments
) do
if line
and line.Parent then
line.Visible = false
end
end
end
local function formatTime(seconds)
seconds = math.max(0, math.floor(seconds or 0))
local minutes = math.floor(seconds / 60)
local remain = seconds % 60
return tostring(minutes) .. ":" .. string.format("%02d", remain)
end
local function getWindowFPS(now)
local cutoff = now - SMOOTH_WINDOW
while #state.FrameTimes > 0 and state.FrameTimes[1].Time < cutoff do
table.remove(state.FrameTimes, 1)
end
local count = #state.FrameTimes
if count < 2 then
return nil
end
local totalDt = 0
for _, frame in ipairs(state.FrameTimes) do
totalDt = totalDt + frame.Dt
end
if totalDt <= 0 then
return nil
end
return math.clamp(count / totalDt, 1, 240)
end
local function makePlotSamples()
local source = state.Samples
local count = #source
local result = {}
local firstIndex =
math.max(
1,
count - MAX_DRAW_POINTS + 1
)
for i = firstIndex, count do
result[#result + 1] = source[i]
end
return result
end
local function updateStats()
local samples = state.Samples
local count = #samples
if count == 0 then return end
local values = {}
local sum = 0
local maxValue = -math.huge
local minValue = math.huge
for i, sample in ipairs(samples) do
local value = sample.FPS
values[i] = value
sum = sum + value
maxValue = math.max(maxValue, value)
minValue = math.min(minValue, value)
end
local avg = sum / count
local variance = 0
for _, value in ipairs(values) do
local d = value - avg
variance = variance + d * d
end
local deviation = math.sqrt(variance / math.max(1, count))
local jitter = avg > 0 and (deviation / avg * 100) or 0
table.sort(values)
local lowCount = math.max(1, math.floor(count * 0.05 + 0.5))
local lowSum = 0
for i = 1, lowCount do
lowSum = lowSum + values[i]
end
local low5 = lowSum / lowCount
statValues["MAX"].Text = string.format("%.1f", maxValue)
statValues["MIN"].Text = string.format("%.1f", minValue)
statValues["AVG"].Text = string.format("%.1f", avg)
statValues["JITTER"].Text = string.format("%.1f%%", jitter)
statValues["5% LOW"].Text = string.format("%.1f", low5)
end
local function refreshGraph()
local plot =
makePlotSamples()
local width =
math.max(
1,
lineLayer.AbsoluteSize.X
)
local height =
math.max(
1,
lineLayer.AbsoluteSize.Y
)
local elapsed =
math.max(
0,
time()
- state.SessionStart
)
local rightTime =
elapsed
local leftTime =
math.max(
0,
rightTime
- HISTORY_WINDOW
)
local span =
math.max(
1,
rightTime
- leftTime
)
for i, line in ipairs(
state.Segments
) do
local a =
plot[i]
local b =
plot[i + 1]
if line
and a
and b
and HomePanel.Visible
and Panel.Visible then
local x1 =
math.clamp(
(
a.Time
- leftTime
)
/ span,
0,
1
)
* width
local x2 =
math.clamp(
(
b.Time
- leftTime
)
/ span,
0,
1
)
* width
local y1 =
(
1
- math.clamp(
a.FPS
/ FPS_AXIS_MAX,
0,
1
)
)
* height
local y2 =
(
1
- math.clamp(
b.FPS
/ FPS_AXIS_MAX,
0,
1
)
)
* height
local dx =
x2 - x1
local dy =
y2 - y1
local length =
math.sqrt(
dx * dx
+ dy * dy
)
line.Position =
UDim2.fromOffset(
(
x1
+ x2
)
* 0.5,
(
y1
+ y2
)
* 0.5
)
line.Size =
UDim2.fromOffset(
math.max(
0.5,
length
),
1
)
line.Rotation =
math.deg(
math.atan2(
dy,
dx
)
)
line.Visible = true
elseif line then
line.Visible = false
end
end
startTimeLabel.Text =
formatTime(
leftTime
)
midTimeLabel.Text =
formatTime(
leftTime
+ span
* 0.5
)
endTimeLabel.Text =
formatTime(
rightTime
)
end
local function takeSample()
local now = time()
local rawFPS =
getWindowFPS(now)
if not rawFPS then
return
end
rawFPS =
math.clamp(
rawFPS,
1,
FPS_CAP
)
state.SmoothedFPS =
rawFPS
local pingOk, ping = pcall(function()
return LocalPlayer:GetNetworkPing()
end)
if pingOk and type(ping) == "number" then
local pingMS = ping * 1000
if not state.SmoothedPing then
state.SmoothedPing = pingMS
else
state.SmoothedPing = state.SmoothedPing + (pingMS - state.SmoothedPing) * 0.30
end
end
local elapsed = now - state.SessionStart
table.insert(state.Samples, {FPS = state.SmoothedFPS, Time = elapsed})
local cutoff =
math.max(
0,
elapsed - HISTORY_WINDOW
)
while #state.Samples > 0
and state.Samples[1].Time < cutoff do
table.remove(state.Samples, 1)
end
while #state.Samples > MAX_HISTORY do
table.remove(state.Samples, 1)
end
local displayFPS = math.floor(state.SmoothedFPS + 0.5)
local displayPing = math.floor((state.SmoothedPing or 0) + 0.5)
liveLabel.Text = "FPS：" .. tostring(displayFPS) .. "    Ping：" .. tostring(displayPing) .. " ms"
local runningAverage = 0
if #state.Samples > 0 then
local sumFPS = 0
for _, sample in ipairs(state.Samples) do
sumFPS = sumFPS + sample.FPS
end
runningAverage = sumFPS / #state.Samples
end
avgTopLabel.Text =
"AVG："
.. string.format("%.1f", runningAverage)
floatingText.Text = "FPS " .. tostring(displayFPS)
refreshGraph()
if now - state.LastStatsUpdate >= 1.5 then
state.LastStatsUpdate = now
updateStats()
end
end
RunService.RenderStepped:Connect(function(dt)
local now =
time()
table.insert(
state.FrameTimes,
{
Time = now,
Dt = dt
}
)
state.SampleClock =
state.SampleClock
+ dt
while state.SampleClock
>= SAMPLE_INTERVAL do
state.SampleClock =
state.SampleClock
- SAMPLE_INTERVAL
takeSample()
end
end)
chart:GetPropertyChangedSignal(
"AbsoluteSize"
):Connect(
refreshGraph
)
lineLayer:GetPropertyChangedSignal(
"AbsoluteSize"
):Connect(
refreshGraph
)
HomePanel:GetPropertyChangedSignal(
"Visible"
):Connect(function()
if HomePanel.Visible then
refreshGraph()
else
hideAllGraphLines()
end
end)
Panel:GetPropertyChangedSignal(
"Visible"
):Connect(function()
if Panel.Visible then
refreshGraph()
else
hideAllGraphLines()
end
end)
return {
Card = card,
Refresh = refreshGraph,
SetFloatingVisible = setFloatingEnabled,
Floating = floatingFPS
}
end
local PerformanceUI =
CreatePerformanceCard()
local ServerCard, ServerValue =
CreateHomeCard(
"服务器在线人数",
58
)
ServerCard.LayoutOrder = 4
local PlayersCard, PlayersValue =
CreateHomeCard(
"服务器玩家",
118
)
PlayersCard.LayoutOrder = 5
PlayersValue.Visible = false
local ServerPlayersScroll = nil
local ServerPlayersContent = nil
local ServerPlayersLayout = nil
local ServerPlayersSignature = ""
local function CreateServerPlayersScroller(
card
)
local scroll =
Instance.new(
"ScrollingFrame"
)
scroll.Name =
"ServerPlayersScroll"
scroll.Position =
UDim2.fromOffset(
10,
28
)
scroll.Size =
UDim2.new(
1,
-18,
1,
-34
)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.Active = true
scroll.ScrollingEnabled = true
scroll.ClipsDescendants = true
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 =
Color3.fromRGB(
125,
205,
255
)
scroll.ScrollBarImageTransparency =
0.18
scroll.AutomaticCanvasSize =
Enum.AutomaticSize.None
scroll.CanvasSize =
UDim2.new()
scroll.ScrollingDirection =
Enum.ScrollingDirection.Y
scroll.ElasticBehavior =
Enum.ElasticBehavior.WhenScrollable
scroll.ZIndex = 24
scroll.Parent = card
local content =
Instance.new(
"Frame"
)
content.Name =
"ServerPlayersContent"
content.Size =
UDim2.new(
1,
-5,
0,
0
)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ZIndex = 24
content.Parent = scroll
local layout =
Instance.new(
"UIListLayout"
)
layout.FillDirection =
Enum.FillDirection.Vertical
layout.SortOrder =
Enum.SortOrder.LayoutOrder
layout.Padding =
UDim.new(
0,
3
)
layout.Parent = content
local padding =
Instance.new(
"UIPadding"
)
padding.PaddingTop =
UDim.new(
0,
2
)
padding.PaddingBottom =
UDim.new(
0,
5
)
padding.PaddingLeft =
UDim.new(
0,
1
)
padding.PaddingRight =
UDim.new(
0,
3
)
padding.Parent = content
local function SyncCanvas()
local height =
layout.AbsoluteContentSize.Y
+ 9
content.Size =
UDim2.new(
1,
-5,
0,
height
)
scroll.CanvasSize =
UDim2.fromOffset(
0,
height
)
local maxY =
math.max(
0,
height
- scroll.AbsoluteSize.Y
)
if scroll.CanvasPosition.Y
> maxY then
scroll.CanvasPosition =
Vector2.new(
0,
maxY
)
end
end
layout:GetPropertyChangedSignal(
"AbsoluteContentSize"
):Connect(
SyncCanvas
)
scroll:GetPropertyChangedSignal(
"AbsoluteSize"
):Connect(
SyncCanvas
)
local touchState = {
Active = false,
Input = nil,
StartY = 0,
StartCanvasY = 0
}
scroll.InputBegan:Connect(function(input)
if input.UserInputType
== Enum.UserInputType.Touch then
touchState.Active = true
touchState.Input = input
touchState.StartY =
input.Position.Y
touchState.StartCanvasY =
scroll.CanvasPosition.Y
HomeScroll.ScrollingEnabled =
false
end
end)
UserInputService.InputChanged:Connect(
function(input)
if not touchState.Active
or input ~= touchState.Input then
return
end
local deltaY =
input.Position.Y
- touchState.StartY
local contentHeight =
layout.AbsoluteContentSize.Y
+ 9
local maxY =
math.max(
0,
contentHeight
- scroll.AbsoluteSize.Y
)
local targetY =
math.clamp(
touchState.StartCanvasY
- deltaY,
0,
maxY
)
scroll.CanvasPosition =
Vector2.new(
0,
targetY
)
end
)
UserInputService.InputEnded:Connect(
function(input)
if touchState.Active
and input == touchState.Input then
touchState.Active = false
touchState.Input = nil
HomeScroll.ScrollingEnabled =
true
end
end
)
ServerPlayersScroll = scroll
ServerPlayersContent = content
ServerPlayersLayout = layout
task.defer(
SyncCanvas
)
return scroll
end
CreateServerPlayersScroller(
PlayersCard
)
local function RefreshServerPlayersRows()
if not ServerPlayersContent
or not ServerPlayersContent.Parent then
return
end
local players =
Players:GetPlayers()
table.sort(
players,
function(a, b)
return string.lower(
tostring(a.DisplayName)
)
< string.lower(
tostring(b.DisplayName)
)
end
)
local signatureParts = {}
for _, player in ipairs(players) do
signatureParts[
#signatureParts + 1
] =
tostring(
player.UserId
)
end
local signature =
table.concat(
signatureParts,
","
)
if signature ==
ServerPlayersSignature then
return
end
ServerPlayersSignature =
signature
for _, child in ipairs(
ServerPlayersContent:GetChildren()
) do
if child:IsA("TextLabel")
and child.Name ==
"ServerPlayerRow" then
child:Destroy()
end
end
if #players == 0 then
local empty =
Instance.new(
"TextLabel"
)
empty.Name =
"ServerPlayerRow"
empty.Size =
UDim2.new(
1,
-2,
0,
20
)
empty.BackgroundTransparency = 1
empty.Text = "暂无玩家"
empty.TextColor3 =
Color3.fromRGB(
190,
194,
204
)
empty.TextSize = 10
empty.Font =
Enum.Font.GothamMedium
empty.TextXAlignment =
Enum.TextXAlignment.Left
empty.ZIndex = 25
empty.Parent =
ServerPlayersContent
return
end
for index, player in ipairs(players) do
local row =
Instance.new(
"TextLabel"
)
row.Name =
"ServerPlayerRow"
row.LayoutOrder = index
row.Size =
UDim2.new(
1,
-2,
0,
20
)
row.BackgroundColor3 =
Color3.fromRGB(
18,
24,
33
)
row.BackgroundTransparency =
index % 2 == 0
and 0.82
or 0.92
row.BorderSizePixel = 0
row.Text =
tostring(index)
.. ". "
.. tostring(
player.DisplayName
)
.. "  (@"
.. tostring(
player.Name
)
.. ")"
row.TextColor3 =
Color3.fromRGB(
242,
246,
252
)
row.TextSize = 10
row.Font =
Enum.Font.GothamMedium
row.TextXAlignment =
Enum.TextXAlignment.Left
row.TextYAlignment =
Enum.TextYAlignment.Center
row.TextTruncate =
Enum.TextTruncate.AtEnd
row.ZIndex = 25
row.Parent =
ServerPlayersContent
AddCorner(
row,
5
)
end
task.defer(function()
if ServerPlayersLayout
and ServerPlayersScroll then
local height =
ServerPlayersLayout.AbsoluteContentSize.Y
+ 9
ServerPlayersContent.Size =
UDim2.new(
1,
-5,
0,
height
)
ServerPlayersScroll.CanvasSize =
UDim2.fromOffset(
0,
height
)
end
end)
end
local AuthorCard, AuthorValue =
CreateHomeCard(
"大肥鱼作者",
108
)
AuthorCard.LayoutOrder = 6
AuthorValue.Text =
"作者:大肥鱼"
.. "\n开发与维护:大肥鱼"
.. "\nUI设计与特色功能:大肥鱼"
.. "\nQQ群:819503470"
local TimeCard, TimeValue =
CreateHomeCard(
"现实时间 · 北京时间",
66
)
TimeCard.LayoutOrder = 7
local function DBGetBeijingTimestamp()
local unixNow = nil
local ok, value =
pcall(function()
return workspace:GetServerTimeNow()
end)
if ok
and type(value) == "number"
and value > 1000000000 then
unixNow = value
else
unixNow = os.time()
end
return os.date(
"!%Y-%m-%d %H:%M:%S",
math.floor(unixNow + 8 * 60 * 60)
)
end
local function DBBuildProcessText()
local lines = {
"大肥鱼主程序  ·  "
.. DBRuntimeState.MainStatus
}
local shown = 0
for i = #DBRuntimeState.ScriptOrder, 1, -1 do
local name =
DBRuntimeState.ScriptOrder[i]
local info =
DBRuntimeState.Scripts[name]
if info then
table.insert(
lines,
name
.. "  ·  "
.. tostring(info.Status)
)
shown = shown + 1
if shown >= 4 then
break
end
end
end
if shown == 0 then
table.insert(
lines,
"外部脚本  ·  暂无"
)
end
return table.concat(lines, "\n")
end
local function DBBuildPlayersText()
local players =
Players:GetPlayers()
local lines = {}
for i, p in ipairs(players) do
table.insert(
lines,
tostring(i)
.. ". "
.. tostring(p.DisplayName)
.. " (@"
.. tostring(p.Name)
.. ")"
)
end
if #lines == 0 then
return "暂无玩家"
end
return table.concat(
lines,
"\n"
)
end
RefreshHomePage = function()
if not ProcessValue
or not ProcessValue.Parent then
return
end
ProcessValue.Text =
DBBuildProcessText()
ServerValue.Text =
"当前在线："
.. tostring(
#Players:GetPlayers()
)
.. " 人"
RefreshServerPlayersRows()
TimeValue.Text =
DBGetBeijingTimestamp()
.. "\nUTC+8 · 中国标准时间"
end
local function ShowHomePage()
ListScroll.Visible = false
if PlayerControlPanel then
PlayerControlPanel.Hide()
end
HomePanel.Visible = true
State.CurrentCategory = "主页"
RefreshHomePage()
end
task.spawn(function()
while MainGui
and MainGui.Parent do
if HomePanel.Visible then
RefreshHomePage()
end
task.wait(1)
end
end)
Players.PlayerAdded:Connect(function()
ServerPlayersSignature = ""
if HomePanel.Visible then
task.defer(RefreshHomePage)
end
end)
Players.PlayerRemoving:Connect(function()
ServerPlayersSignature = ""
if HomePanel.Visible then
task.defer(RefreshHomePage)
end
end)
local function ShowPlayerControlPanel()
ListScroll.Visible = false
HomePanel.Visible = false
if PlayerControlPanel then
PlayerControlPanel.Show()
end
State.CurrentCategory =
"玩家面板"
end
local function ApplySafeClickEffect(btn, onClick)
btn.Activated:Connect(function()
if onClick then
onClick()
end
end)
end
local function DBClearRightList()
HomePanel.Visible = false
if PlayerControlPanel then
PlayerControlPanel.Hide()
end
ListScroll.Visible = true
ListScroll.ClipsDescendants = true
ListScroll.ScrollingEnabled = true
for _, child in ipairs(
ListScroll:GetChildren()
) do
if child:IsA("GuiObject") then
child:Destroy()
end
end
ListScroll.CanvasPosition =
Vector2.new(
0,
0
)
local oldDetail =
RightList:FindFirstChild(
"DB_ScriptCollectionDetail"
)
if oldDetail then
oldDetail:Destroy()
end
local oldColorPopup =
RightList:FindFirstChild(
"DB_WallpaperColorPopup"
)
if oldColorPopup then
oldColorPopup:Destroy()
end
end
local ScriptCollectionUI = {}
do
local collectionCategories = {
"射击游戏",
"角色扮演RPG",
"休闲挂机",
"竞技格斗",
"休闲社交",
"合作游戏",
"非对称竞技",
"塔防游戏",
}
function ScriptCollectionUI.ShowDetail(
categoryName
)
DBClearRightList()
State.CurrentCategory =
"脚本合集/"
.. tostring(
categoryName
)
ListScroll.Visible = false
local detail =
Instance.new(
"Frame"
)
detail.Name =
"DB_ScriptCollectionDetail"
detail.Position =
UDim2.fromOffset(
5,
4
)
detail.Size =
UDim2.new(
1,
-10,
1,
-8
)
detail.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
detail.BackgroundTransparency =
0.91
detail.BorderSizePixel = 0
detail.ClipsDescendants = true
detail.ZIndex = 40
detail.Parent = RightList
AddCorner(
detail,
12
)
local detailStroke =
Instance.new(
"UIStroke"
)
detailStroke.ApplyStrokeMode =
Enum.ApplyStrokeMode.Border
detailStroke.Thickness = 0.9
detailStroke.Transparency = 0.48
detailStroke.Color =
Color3.fromRGB(
255,
255,
255
)
detailStroke.LineJoinMode =
Enum.LineJoinMode.Round
detailStroke.Parent =
detail
local back =
Instance.new(
"TextButton"
)
back.Name =
"DB_ScriptCollectionDetailBack"
back.Position =
UDim2.fromOffset(
8,
7
)
back.Size =
UDim2.fromOffset(
31,
31
)
back.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
back.BackgroundTransparency =
0.84
back.BorderSizePixel = 0
back.Text = "←"
back.TextColor3 =
Color3.fromRGB(
255,
255,
255
)
back.TextSize = 18
back.Font =
Enum.Font.GothamBlack
back.AutoButtonColor = false
back.ZIndex = 43
back.Parent = detail
AddCorner(
back,
999
)
local backStroke =
Instance.new(
"UIStroke"
)
backStroke.ApplyStrokeMode =
Enum.ApplyStrokeMode.Border
backStroke.Thickness = 0.8
backStroke.Transparency = 0.50
backStroke.Color =
Color3.fromRGB(
255,
255,
255
)
backStroke.Parent =
back
ApplySafeClickEffect(
back,
function()
if detail
and detail.Parent then
detail:Destroy()
end
ScriptCollectionUI.Show()
end
)
local title =
Instance.new(
"TextLabel"
)
title.Position =
UDim2.fromOffset(
48,
7
)
title.Size =
UDim2.new(
1,
-58,
0,
31
)
title.BackgroundTransparency = 1
title.Text = tostring(categoryName)
title.TextColor3 =
Color3.fromRGB(
255,
255,
255
)
title.TextSize = 14
title.Font =
Enum.Font.GothamBlack
title.TextXAlignment =
Enum.TextXAlignment.Left
title.ZIndex = 43
title.Parent = detail
local detailScroll =
Instance.new(
"ScrollingFrame"
)
detailScroll.Name =
"DB_ScriptCollectionDetailScroll"
detailScroll.Position =
UDim2.fromOffset(
7,
45
)
detailScroll.Size =
UDim2.new(
1,
-14,
1,
-52
)
detailScroll.BackgroundTransparency = 1
detailScroll.BorderSizePixel = 0
detailScroll.ScrollBarThickness = 2
detailScroll.ScrollBarImageColor3 =
Color3.fromRGB(
255,
255,
255
)
detailScroll.ScrollBarImageTransparency =
0.50
detailScroll.ScrollingDirection =
Enum.ScrollingDirection.Y
detailScroll.AutomaticCanvasSize =
Enum.AutomaticSize.Y
detailScroll.CanvasSize =
UDim2.new(
0,
0,
0,
0
)
detailScroll.Active = true
detailScroll.ScrollingEnabled = true
detailScroll.ZIndex = 42
detailScroll.Parent = detail
local detailLayout =
Instance.new(
"UIListLayout"
)
detailLayout.Padding =
UDim.new(
0,
7
)
detailLayout.SortOrder =
Enum.SortOrder.LayoutOrder
detailLayout.HorizontalAlignment =
Enum.HorizontalAlignment.Center
detailLayout.Parent =
detailScroll
local detailPadding =
Instance.new(
"UIPadding"
)
detailPadding.PaddingTop =
UDim.new(
0,
4
)
detailPadding.PaddingBottom =
UDim.new(
0,
8
)
detailPadding.PaddingLeft =
UDim.new(
0,
3
)
detailPadding.PaddingRight =
UDim.new(
0,
3
)
detailPadding.Parent =
detailScroll
local list =
ScriptDatabase[categoryName]
or {}
if #list == 0 then
local empty =
Instance.new(
"TextLabel"
)
empty.Size =
UDim2.new(
1,
-8,
0,
42
)
empty.BackgroundTransparency = 1
empty.Text = "这个分类暂时没有脚本"
empty.TextColor3 =
Color3.fromRGB(
235,
235,
240
)
empty.TextSize = 13
empty.Font =
Enum.Font.GothamMedium
empty.LayoutOrder = 1
empty.ZIndex = 43
empty.Parent = detailScroll
else
for index,
item in ipairs(
list
) do
local scriptButton =
Instance.new(
"TextButton"
)
scriptButton.Name =
"DB_CollectionDetail_"
.. tostring(
item.Name
)
scriptButton.Size =
UDim2.new(
1,
-8,
0,
34
)
scriptButton.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
scriptButton.BackgroundTransparency =
0.88
scriptButton.BorderSizePixel = 0
scriptButton.Text = item.Name
scriptButton.TextColor3 =
Color3.fromRGB(
255,
255,
255
)
scriptButton.TextSize = 13
scriptButton.Font =
Enum.Font.GothamMedium
scriptButton.TextXAlignment =
Enum.TextXAlignment.Left
scriptButton.TextTruncate =
Enum.TextTruncate.AtEnd
scriptButton.AutoButtonColor = false
scriptButton.LayoutOrder = index
scriptButton.ZIndex = 43
StyleLiquidButton(
scriptButton,
9,
false
)
local scriptPad =
Instance.new(
"UIPadding"
)
scriptPad.PaddingLeft =
UDim.new(
0,
12
)
scriptPad.PaddingRight =
UDim.new(
0,
12
)
scriptPad.Parent =
scriptButton
ApplySafeClickEffect(
scriptButton,
function()
SafeLoadScript(
item
)
end
)
scriptButton.Parent =
detailScroll
end
end
end
function ScriptCollectionUI.Show()
DBClearRightList()
State.CurrentCategory =
"脚本合集"
local title =
Instance.new(
"TextLabel"
)
title.Size =
UDim2.new(
1,
-12,
0,
28
)
title.BackgroundTransparency = 1
title.Text = "脚本合集"
title.TextColor3 =
Color3.fromRGB(
255,
255,
255
)
title.TextSize = 15
title.Font =
Enum.Font.GothamBlack
title.TextXAlignment =
Enum.TextXAlignment.Left
title.LayoutOrder = 1
title.ZIndex = 18
title.Parent = ListScroll
local titlePad =
Instance.new(
"UIPadding"
)
titlePad.PaddingLeft =
UDim.new(
0,
7
)
titlePad.Parent =
title
for index,
categoryName in ipairs(
collectionCategories
) do
local button =
Instance.new(
"TextButton"
)
button.Name =
"DB_Collection_"
.. categoryName
DBApplyRightFullWidthButton(
button,
38
)
button.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
button.BackgroundTransparency =
0.88
button.BorderSizePixel = 0
button.Text = categoryName
button.TextColor3 =
Color3.fromRGB(
255,
255,
255
)
button.TextSize = 12
button.Font =
Enum.Font.GothamBlack
button.TextXAlignment =
Enum.TextXAlignment.Left
button.AutoButtonColor = false
button.LayoutOrder =
index + 1
button.ZIndex = 18
StyleLiquidButton(
button,
10,
false
)
local pad =
Instance.new(
"UIPadding"
)
pad.PaddingLeft =
UDim.new(
0,
12
)
pad.PaddingRight =
UDim.new(
0,
12
)
pad.Parent =
button
ApplySafeClickEffect(
button,
function()
ScriptCollectionUI.ShowDetail(
categoryName
)
end
)
button.Parent =
ListScroll
end
end
end
local DBUIInterfaceUI = {}
do
local function MakePageTitle(
textValue,
order
)
local label =
Instance.new(
"TextLabel"
)
label.Size =
UDim2.new(
1,
-12,
0,
22
)
label.BackgroundTransparency = 1
label.Text = textValue
label.TextColor3 =
Color3.fromRGB(
255,
255,
255
)
label.TextSize = 15
label.Font =
Enum.Font.GothamBlack
label.TextXAlignment =
Enum.TextXAlignment.Left
label.LayoutOrder =
order or 1
label.ZIndex = 20
label.Parent = ListScroll
local pad =
Instance.new(
"UIPadding"
)
pad.PaddingLeft =
UDim.new(
0,
8
)
pad.Parent =
label
return label
end
local function MakeGlassRow(
height,
order
)
local row =
Instance.new(
"Frame"
)
row.Size =
UDim2.new(
1,
-12,
0,
height
)
row.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
row.BackgroundTransparency =
0.84
row.BorderSizePixel = 0
row.LayoutOrder = order
row.ZIndex = 19
row.Parent = ListScroll
AddCorner(
row,
11
)
local stroke =
Instance.new(
"UIStroke"
)
stroke.ApplyStrokeMode =
Enum.ApplyStrokeMode.Border
stroke.Thickness = 0.8
stroke.Transparency = 0.56
stroke.Color =
Color3.fromRGB(
255,
255,
255
)
stroke.LineJoinMode =
Enum.LineJoinMode.Round
stroke.Parent =
row
return row
end
function DBUIInterfaceUI.ShowWallpaperSelection()
DBClearRightList()
State.CurrentCategory =
"UI界面/壁纸"
local back =
Instance.new(
"TextButton"
)
DBApplyRightFullWidthButton(
back,
32
)
back.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
back.BackgroundTransparency =
0.88
back.BorderSizePixel = 0
back.Text = "←  返回UI界面"
back.TextColor3 =
Color3.fromRGB(
255,
255,
255
)
back.TextSize = 13
back.Font =
Enum.Font.GothamBold
back.TextXAlignment =
Enum.TextXAlignment.Left
back.AutoButtonColor = false
back.LayoutOrder = 1
back.ZIndex = 21
StyleLiquidButton(
back,
10,
false
)
local backPad =
Instance.new(
"UIPadding"
)
backPad.PaddingLeft =
UDim.new(
0,
12
)
backPad.Parent =
back
ApplySafeClickEffect(
back,
function()
DBUIInterfaceUI.Show()
end
)
back.Parent =
ListScroll
MakePageTitle(
"选择壁纸",
2
)
for index = 1, 6 do
local card =
Instance.new(
"ImageButton"
)
card.Name =
"DB_WallpaperCard_"
.. tostring(index)
card.Size =
UDim2.new(
1,
-12,
0,
92
)
card.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
card.BackgroundTransparency =
0.91
card.BorderSizePixel = 0
card.Image =
DBWallpaper.Assets[index]
or ""
card.ImageTransparency =
0.05
card.ScaleType =
Enum.ScaleType.Crop
card.AutoButtonColor = false
card.LayoutOrder =
index + 2
card.ZIndex = 20
card.Parent =
ListScroll
AddCorner(
card,
10
)
local stroke =
Instance.new(
"UIStroke"
)
stroke.ApplyStrokeMode =
Enum.ApplyStrokeMode.Border
stroke.Thickness =
DBWallpaper.CurrentIndex == index
and 1.5
or 0.8
stroke.Transparency =
DBWallpaper.CurrentIndex == index
and 0.18
or 0.62
stroke.Color =
Color3.fromRGB(
255,
255,
255
)
stroke.LineJoinMode =
Enum.LineJoinMode.Round
stroke.Parent =
card
local shade =
Instance.new(
"Frame"
)
shade.Size =
UDim2.fromScale(
1,
1
)
shade.BackgroundColor3 =
Color3.fromRGB(
0,
0,
0
)
shade.BackgroundTransparency =
0.67
shade.BorderSizePixel = 0
shade.ZIndex = 21
shade.Active = false
shade.Parent = card
AddCorner(
shade,
10
)
local label =
Instance.new(
"TextLabel"
)
label.Position =
UDim2.fromOffset(
12,
0
)
label.Size =
UDim2.new(
1,
-24,
1,
0
)
label.BackgroundTransparency = 1
label.Text =
index == 1
and "壁纸 1 · 默认"
or (
"壁纸 "
.. tostring(index)
)
label.TextColor3 =
Color3.fromRGB(
255,
255,
255
)
label.TextSize = 14
label.Font =
Enum.Font.GothamBold
label.TextXAlignment =
Enum.TextXAlignment.Left
label.ZIndex = 22
label.Parent = card
card.Activated:Connect(function()
DBWallpaper.Apply(index)
for cardIndex = 1, 6 do
local item =
ListScroll:FindFirstChild(
"DB_WallpaperCard_"
.. tostring(
cardIndex
)
)
if item then
local itemStroke =
item:FindFirstChildOfClass(
"UIStroke"
)
if itemStroke then
local selected =
cardIndex == index
itemStroke.Thickness =
selected
and 1.5
or 0.8
itemStroke.Transparency =
selected
and 0.18
or 0.62
end
end
end
end)
end
end
function DBUIInterfaceUI.Show()
DBClearRightList()
State.CurrentCategory = "UI界面"
MakePageTitle("UI界面", 1)
local wallpaperButton = Instance.new("TextButton")
DBApplyRightFullWidthButton(wallpaperButton, 44)
wallpaperButton.BackgroundColor3 = DBVisualSettings.ButtonBackground
wallpaperButton.BackgroundTransparency = DBVisualSettings.ButtonTransparency
wallpaperButton.BorderSizePixel = 0
wallpaperButton.Text = "壁纸"
wallpaperButton.TextColor3 = Color3.fromRGB(255,255,255)
wallpaperButton.TextSize = 14
wallpaperButton.Font = Enum.Font.GothamBlack
wallpaperButton.TextXAlignment = Enum.TextXAlignment.Left
wallpaperButton.AutoButtonColor = false
wallpaperButton.LayoutOrder = 2
wallpaperButton.ZIndex = 20
StyleLiquidButton(wallpaperButton, 11, false)
local wallpaperPad = Instance.new("UIPadding")
wallpaperPad.PaddingLeft = UDim.new(0,12)
wallpaperPad.PaddingRight = UDim.new(0,42)
wallpaperPad.Parent = wallpaperButton
local wallpaperArrow = Instance.new("TextLabel")
wallpaperArrow.Name = "DB_WallpaperArrow"
wallpaperArrow.AnchorPoint = Vector2.new(1, 0.5)
wallpaperArrow.Position = UDim2.new(1, -11, 0.5, 0)
wallpaperArrow.Size = UDim2.fromOffset(30, 34)
wallpaperArrow.BackgroundTransparency = 1
wallpaperArrow.Text = "›"
wallpaperArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
wallpaperArrow.TextSize = 25
wallpaperArrow.Font = Enum.Font.GothamBlack
wallpaperArrow.TextXAlignment = Enum.TextXAlignment.Center
wallpaperArrow.TextYAlignment = Enum.TextYAlignment.Center
wallpaperArrow.Active = false
wallpaperArrow.ZIndex = 23
wallpaperArrow.Parent = wallpaperButton
ApplySafeClickEffect(wallpaperButton, function() DBUIInterfaceUI.ShowWallpaperSelection() end)
wallpaperButton.Parent = ListScroll
local urlRow =
MakeGlassRow(
62,
3
)
urlRow.Name =
"DB_WallpaperURLRow"
urlRow.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
urlRow.BackgroundTransparency =
0.84
local urlBox =
Instance.new(
"TextBox"
)
urlBox.Name =
"DB_WallpaperURLInput"
urlBox.Position =
UDim2.fromOffset(
10,
9
)
urlBox.Size =
UDim2.new(
1,
-92,
0,
44
)
urlBox.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
urlBox.BackgroundTransparency =
0.88
urlBox.BorderSizePixel = 0
urlBox.ClearTextOnFocus = false
urlBox.PlaceholderText =
"粘贴图片直链，例如 https://i.imgs.ovh/xxxx.jpg"
urlBox.PlaceholderColor3 =
Color3.fromRGB(
210,
210,
218
)
urlBox.Text = ""
urlBox.TextColor3 =
Color3.fromRGB(
255,
255,
255
)
urlBox.TextSize = 11
urlBox.Font =
Enum.Font.GothamMedium
urlBox.TextXAlignment =
Enum.TextXAlignment.Left
urlBox.ZIndex = 23
urlBox.Parent = urlRow
AddCorner(
urlBox,
9
)
local urlPad =
Instance.new(
"UIPadding"
)
urlPad.PaddingLeft =
UDim.new(
0,
10
)
urlPad.PaddingRight =
UDim.new(
0,
8
)
urlPad.Parent =
urlBox
local urlApply =
Instance.new(
"TextButton"
)
urlApply.Name =
"DB_WallpaperURLApply"
urlApply.AnchorPoint =
Vector2.new(
1,
0
)
urlApply.Position =
UDim2.new(
1,
-8,
0,
9
)
urlApply.Size =
UDim2.fromOffset(
68,
44
)
urlApply.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
urlApply.BackgroundTransparency =
0.80
urlApply.BorderSizePixel = 0
urlApply.Text = "应用"
urlApply.TextColor3 =
Color3.fromRGB(
255,
255,
255
)
urlApply.TextSize = 12
urlApply.Font =
Enum.Font.GothamBlack
urlApply.AutoButtonColor = false
urlApply.ZIndex = 24
urlApply.Parent = urlRow
StyleLiquidButton(
urlApply,
9,
false
)
urlApply.Activated:Connect(function()
urlApply.Text = "加载中"
local ok, message =
DBWallpaper.SetFromURL(
urlBox.Text
)
urlApply.Text =
ok
and "成功"
or "失败"
if not ok then
warn(
"[大肥鱼 壁纸URL] ",
message
)
urlBox.Text =
"失败：" .. tostring(message)
end
task.delay(
1.2,
function()
if urlApply
and urlApply.Parent then
urlApply.Text = "应用"
end
end
)
end)
local function MakeSlider(rowName, titlePrefix, ratio, order, onRatio)
local row = MakeGlassRow(64, order)
row.Name = rowName
row.BackgroundColor3 = Color3.fromRGB(255,255,255)
row.BackgroundTransparency = 0.84
local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(12,4)
title.Size = UDim2.new(1,-24,0,18)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextSize = 13
title.Font = Enum.Font.GothamBlack
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 21
title.Parent = row
local track = Instance.new("Frame")
track.Position = UDim2.new(0,14,0,41)
track.Size = UDim2.new(1,-28,0,6)
track.BackgroundColor3 = Color3.fromRGB(255,255,255)
track.BackgroundTransparency = 0.72
track.BorderSizePixel = 0
track.Active = true
track.ZIndex = 22
track.Parent = row
AddCorner(track,999)
local fill = Instance.new("Frame")
fill.Size = UDim2.new(ratio,0,1,0)
fill.BackgroundColor3 = Color3.fromRGB(255,255,255)
fill.BackgroundTransparency = 0.02
fill.BorderSizePixel = 0
fill.ZIndex = 23
fill.Parent = track
AddCorner(fill,999)
local knob = Instance.new("Frame")
knob.AnchorPoint = Vector2.new(0.5,0.5)
knob.Position = UDim2.new(ratio,0,0.5,0)
knob.Size = UDim2.fromOffset(16,16)
knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
knob.BackgroundTransparency = 0
knob.BorderSizePixel = 0
knob.ZIndex = 24
knob.Active = false
knob.Parent = track
AddCorner(knob,999)
local dragging = false
local dragInput = nil
local function ApplyRatio(newRatio)
newRatio = math.clamp(newRatio,0,1)
fill.Size = UDim2.new(newRatio,0,1,0)
knob.Position = UDim2.new(newRatio,0,0.5,0)
title.Text = titlePrefix .. tostring(onRatio(newRatio))
end
ApplyRatio(ratio)
local function ApplyFromInput(pos)
if not track.Parent then return end
local x = DBSpatial and DBSpatial.InputAxis and DBSpatial.InputAxis(track, pos, "X") or (pos and pos.X)
if not x then return end
local width = math.max(1, track.AbsoluteSize.X)
ApplyRatio((x-track.AbsolutePosition.X)/width)
end
track.InputBegan:Connect(function(input)
if input.UserInputType ~= Enum.UserInputType.Touch
and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
dragging = true
dragInput = input
ApplyFromInput(input.Position)
end)
UserInputService.InputChanged:Connect(function(input)
if not dragging or not track.Parent then return end
if input.UserInputType == Enum.UserInputType.Touch then
if input ~= dragInput then return end
elseif input.UserInputType ~= Enum.UserInputType.MouseMovement then
return
end
ApplyFromInput(input.Position)
end)
UserInputService.InputEnded:Connect(function(input)
if not dragging then return end
if input.UserInputType == Enum.UserInputType.Touch then
if input ~= dragInput then return end
elseif input.UserInputType ~= Enum.UserInputType.MouseButton1 then
return
end
dragging = false
dragInput = nil
end)
return row
end
MakeSlider("DB_WallpaperTransparencyRow", "壁纸透明度：", DBWallpaper.Transparency, 4, function(ratio)
DBWallpaper.SetTransparency(ratio)
return tostring(math.floor(ratio*100+0.5)) .. "%"
end)
local colorButton = Instance.new("TextButton")
DBApplyRightFullWidthButton(colorButton,48)
colorButton.Name = "DB_WallpaperColorButton"
colorButton.BackgroundColor3 = DBVisualSettings.ButtonBackground
colorButton.BackgroundTransparency = DBVisualSettings.ButtonTransparency
colorButton.BorderSizePixel = 0
colorButton.Text = "壁纸颜色"
colorButton.TextColor3 = Color3.fromRGB(255,255,255)
colorButton.TextSize = 14
colorButton.Font = Enum.Font.GothamBlack
colorButton.TextXAlignment = Enum.TextXAlignment.Left
colorButton.AutoButtonColor = false
colorButton.LayoutOrder = 5
colorButton.ZIndex = 20
StyleLiquidButton(colorButton,11,false)
local colorPad = Instance.new("UIPadding")
colorPad.PaddingLeft = UDim.new(0,12)
colorPad.Parent = colorButton
local colorPreview = Instance.new("Frame")
colorPreview.AnchorPoint = Vector2.new(1,0.5)
colorPreview.Position = UDim2.new(1,-12,0.5,0)
colorPreview.Size = UDim2.fromOffset(24,24)
colorPreview.BackgroundColor3 = DBWallpaper.TintColor
colorPreview.BorderSizePixel = 0
colorPreview.ZIndex = 22
colorPreview.Active = false
colorPreview.Parent = colorButton
AddCorner(colorPreview,999)
local cps = Instance.new("UIStroke")
cps.Thickness = 1
cps.Transparency = 0.35
cps.Color = Color3.fromRGB(255,255,255)
cps.Parent = colorPreview
colorButton.Parent = ListScroll
colorButton.Activated:Connect(function()
local old = RightList:FindFirstChild("DB_WallpaperColorPopup")
if old then old:Destroy(); return end
local popup = Instance.new("Frame")
popup.Name = "DB_WallpaperColorPopup"
popup.AnchorPoint = Vector2.new(0.5,0.5)
popup.Position = UDim2.fromScale(0.5,0.52)
popup.Size = UDim2.new(0.86,0,0,218)
popup.BackgroundColor3 = Color3.fromRGB(8,10,14)
popup.BackgroundTransparency = 0.05
popup.BorderSizePixel = 0
popup.ZIndex = 80
popup.Parent = RightList
AddCorner(popup,12)
local ps = Instance.new("UIStroke")
ps.Thickness = 1
ps.Transparency = 0.36
ps.Color = Color3.fromRGB(255,255,255)
ps.Parent = popup
local pt = Instance.new("TextLabel")
pt.Position = UDim2.fromOffset(12,6)
pt.Size = UDim2.new(1,-48,0,28)
pt.BackgroundTransparency = 1
pt.Text = "壁纸颜色"
pt.TextColor3 = Color3.fromRGB(255,255,255)
pt.TextSize = 13
pt.Font = Enum.Font.GothamBlack
pt.TextXAlignment = Enum.TextXAlignment.Left
pt.ZIndex = 82
pt.Parent = popup
local close = Instance.new("TextButton")
close.AnchorPoint = Vector2.new(1,0)
close.Position = UDim2.new(1,-7,0,6)
close.Size = UDim2.fromOffset(28,28)
close.BackgroundTransparency = 1
close.BorderSizePixel = 0
close.Text = "×"
close.TextColor3 = Color3.fromRGB(255,255,255)
close.TextSize = 20
close.Font = Enum.Font.GothamBlack
close.ZIndex = 83
close.Parent = popup
close.Activated:Connect(function() if popup.Parent then popup:Destroy() end end)
local holder = Instance.new("Frame")
holder.Position = UDim2.fromOffset(10,40)
holder.Size = UDim2.new(1,-20,1,-50)
holder.BackgroundTransparency = 1
holder.BorderSizePixel = 0
holder.ZIndex = 81
holder.Parent = popup
local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(1/6,-6,0,28)
grid.CellPadding = UDim2.fromOffset(5,5)
grid.FillDirectionMaxCells = 6
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = holder
local colors = {
{Name="默认",Color=Color3.fromRGB(255,255,255)},
{Color=Color3.fromRGB(235,235,235)},{Color=Color3.fromRGB(180,180,180)},{Color=Color3.fromRGB(95,95,95)},{Color=Color3.fromRGB(38,38,42)},{Color=Color3.fromRGB(18,18,20)},
{Color=Color3.fromRGB(255,105,120)},{Color=Color3.fromRGB(255,70,70)},{Color=Color3.fromRGB(255,145,65)},{Color=Color3.fromRGB(255,205,80)},{Color=Color3.fromRGB(240,235,90)},{Color=Color3.fromRGB(190,240,95)},
{Color=Color3.fromRGB(90,230,130)},{Color=Color3.fromRGB(70,205,155)},{Color=Color3.fromRGB(70,220,205)},{Color=Color3.fromRGB(75,210,245)},{Color=Color3.fromRGB(75,165,255)},{Color=Color3.fromRGB(90,115,255)},
{Color=Color3.fromRGB(125,95,255)},{Color=Color3.fromRGB(170,90,255)},{Color=Color3.fromRGB(220,85,255)},{Color=Color3.fromRGB(255,90,220)},{Color=Color3.fromRGB(255,115,175)},{Color=Color3.fromRGB(245,150,185)},
{Color=Color3.fromRGB(145,105,85)},{Color=Color3.fromRGB(185,130,90)},{Color=Color3.fromRGB(220,165,115)},{Color=Color3.fromRGB(255,205,165)},{Color=Color3.fromRGB(195,220,255)},{Color=Color3.fromRGB(205,190,255)},
}
for index, info in ipairs(colors) do
local swatch = Instance.new("TextButton")
swatch.BackgroundColor3 = info.Color
swatch.BackgroundTransparency = 0
swatch.BorderSizePixel = 0
swatch.Text = info.Name or ""
swatch.TextColor3 = (info.Color.R+info.Color.G+info.Color.B)>1.65 and Color3.fromRGB(25,25,28) or Color3.fromRGB(255,255,255)
swatch.TextSize = 8
swatch.Font = Enum.Font.GothamBlack
swatch.AutoButtonColor = false
swatch.LayoutOrder = index
swatch.ZIndex = 82
swatch.Parent = holder
AddCorner(swatch,7)
local ss = Instance.new("UIStroke")
ss.Thickness = 0.8
ss.Transparency = 0.45
ss.Color = Color3.fromRGB(255,255,255)
ss.Parent = swatch
swatch.Activated:Connect(function()
DBWallpaper.SetTintColor(info.Color)
colorPreview.BackgroundColor3 = info.Color
if popup.Parent then popup:Destroy() end
end)
end
end)
local brightnessRatio = math.clamp((DBWallpaper.Brightness-0.20)/0.80,0,1)
MakeSlider("DB_WallpaperBrightnessRow", "壁纸亮度：", brightnessRatio, 6, function(ratio)
local brightness = 0.20 + ratio*0.80
DBWallpaper.SetBrightness(brightness)
return tostring(math.floor(brightness*100+0.5)) .. "%"
end)
local borderRow = MakeGlassRow(44,7)
borderRow.Name = "DB_ButtonBorderRow"
borderRow.BackgroundColor3 = Color3.fromRGB(255,255,255)
borderRow.BackgroundTransparency = 0.84
local borderTitle = Instance.new("TextLabel")
borderTitle.Position = UDim2.fromOffset(12,0)
borderTitle.Size = UDim2.new(1,-88,1,0)
borderTitle.BackgroundTransparency = 1
borderTitle.Text = "按钮边框"
borderTitle.TextColor3 = Color3.fromRGB(255,255,255)
borderTitle.TextSize = 13
borderTitle.Font = Enum.Font.GothamBlack
borderTitle.TextXAlignment = Enum.TextXAlignment.Left
borderTitle.ZIndex = 21
borderTitle.Parent = borderRow
local switch = Instance.new("TextButton")
switch.AnchorPoint = Vector2.new(1,0.5)
switch.Position = UDim2.new(1,-12,0.5,0)
switch.Size = UDim2.fromOffset(48,24)
switch.BackgroundColor3 = DBVisualSettings.ButtonBordersEnabled and Color3.fromRGB(205,210,220) or Color3.fromRGB(62,65,72)
switch.BackgroundTransparency = 0.12
switch.BorderSizePixel = 0
switch.Text = ""
switch.AutoButtonColor = false
switch.ZIndex = 22
switch.Parent = borderRow
AddCorner(switch,999)
local switchKnob = Instance.new("Frame")
switchKnob.AnchorPoint = Vector2.new(0.5,0.5)
switchKnob.Position = DBVisualSettings.ButtonBordersEnabled and UDim2.new(1,-12,0.5,0) or UDim2.new(0,12,0.5,0)
switchKnob.Size = UDim2.fromOffset(19,19)
switchKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
switchKnob.BackgroundTransparency = 0
switchKnob.BorderSizePixel = 0
switchKnob.ZIndex = 23
switchKnob.Parent = switch
AddCorner(switchKnob,999)
switch.Activated:Connect(function()
local enabled = not DBVisualSettings.ButtonBordersEnabled
DBVisualSettings.SetButtonBorders(enabled)
TweenService:Create(switchKnob, TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Position = enabled and UDim2.new(1,-12,0.5,0) or UDim2.new(0,12,0.5,0)}):Play()
TweenService:Create(switch, TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundColor3 = enabled and Color3.fromRGB(205,210,220) or Color3.fromRGB(62,65,72)}):Play()
end)
end
end

local DBTitle = (function()
    local api = {}
    local env = _G
    pcall(function()
        if type(getgenv) == "function" then env = getgenv() end
    end)

    local cfg = {
        Enabled = true,
        Line1 = "大肥鱼脚本",
        Line2 = "Q群:819503470",
        ColorMode = "彩虹",
        ServerSync = true,
    }

    local solidColors = {
        ["白色"] = Color3.fromRGB(255,255,255),
        ["红色"] = Color3.fromRGB(255,70,70),
        ["橙色"] = Color3.fromRGB(255,145,45),
        ["黄色"] = Color3.fromRGB(255,225,70),
        ["绿色"] = Color3.fromRGB(90,235,125),
        ["青色"] = Color3.fromRGB(70,225,235),
        ["蓝色"] = Color3.fromRGB(90,145,255),
        ["紫色"] = Color3.fromRGB(180,100,255),
        ["粉色"] = Color3.fromRGB(255,105,190),
    }

    local gui, rainbowConn, currentCharacter
    local syncState = {
        Status = "等待检测",
        Method = "local",
        Remote = nil,
        RemotePath = "",
        LastScan = 0,
        LastPublish = 0,
        Verified = false,
        Busy = false,
    }

    local function payload(enabledOverride)
        return {
            Enabled = enabledOverride == nil and cfg.Enabled or enabledOverride,
            Line1 = cfg.Line1,
            Line2 = cfg.Line2,
            Text = cfg.Line1 .. "\n" .. cfg.Line2,
            ColorMode = cfg.ColorMode,
            Source = "DB",
            Kind = "Overhead",
        }
    end

    local function normalized(s)
        return tostring(s or ""):lower():gsub("[^%w_]", "")
    end

    local BAD_WORDS = {
        "anti","cheat","detect","security","validate","ban","kick","report",
        "damage","hit","weapon","gun","attack","kill","money","cash","coin",
        "trade","shop","purchase","buy","admin","moderation","teleport","inventory",
    }
    local GOOD_WORDS = {
        title=14, settitle=30, updatetitle=30, customtitle=32,
        tag=8, settag=24, updatetag=24, customtag=26,
        nametag=20, setnametag=34, updatenametag=34,
        billboard=20, setbillboard=34, updatebillboard=34,
        overhead=22, setoverhead=36, updateoverhead=36,
        overheadgui=30, displaytag=20, displaytitle=20,
        cosmetic=7, cosmetics=7, ui=3, gui=3,
    }

    local function containsBad(text)
        local n = normalized(text)
        for _, word in ipairs(BAD_WORDS) do
            if n:find(word, 1, true) then return true end
        end
        return false
    end

    local function remoteScore(remote)
        if not remote or not remote:IsA("RemoteEvent") then return -999 end
        local full = ""
        pcall(function() full = remote:GetFullName() end)
        local combined = normalized((remote.Name or "") .. "_" .. full)
        if containsBad(combined) then return -999 end
        local score = 0
        for word, value in pairs(GOOD_WORDS) do
            if combined:find(word, 1, true) then score = score + value end
        end
        local parentName = normalized(remote.Parent and remote.Parent.Name or "")
        if parentName:find("title",1,true) or parentName:find("tag",1,true)
            or parentName:find("cosmetic",1,true) or parentName:find("overhead",1,true)
            or parentName:find("ui",1,true) then
            score = score + 8
        end
        local rn = normalized(remote.Name)
        local exactish = rn:find("title",1,true) or rn:find("tag",1,true)
            or rn:find("nametag",1,true) or rn:find("billboard",1,true)
            or rn:find("overhead",1,true)
        if not exactish then score = math.min(score, 12) end
        return score
    end

    local function findCandidateRemote(force)
        if syncState.Remote and syncState.Remote.Parent and not force then
            return syncState.Remote
        end
        local now = os.clock()
        if not force and now - syncState.LastScan < 7 then return nil end
        syncState.LastScan = now
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local best, bestScore = nil, -999
        for _, inst in ipairs(ReplicatedStorage:GetDescendants()) do
            if inst:IsA("RemoteEvent") then
                local score = remoteScore(inst)
                if score > bestScore then best, bestScore = inst, score end
            end
        end
        if best and bestScore >= 26 then
            syncState.Remote = best
            pcall(function() syncState.RemotePath = best:GetFullName() end)
            syncState.Status = "发现服务器展示接口，正在验证"
            return best
        end
        syncState.Remote = nil
        syncState.RemotePath = ""
        syncState.Status = "未发现可安全自动使用的服务器展示接口"
        return nil
    end

    local function textMatches(root)
        if not root then return false end
        local wanted1 = tostring(cfg.Line1)
        local wanted2 = tostring(cfg.Line2)
        local function inspect(obj)
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                local t = tostring(obj.Text or "")
                if t:find(wanted1,1,true) or (wanted2 ~= "" and t:find(wanted2,1,true)) then
                    return true
                end
            elseif obj:IsA("StringValue") then
                local t = tostring(obj.Value or "")
                if t:find(wanted1,1,true) or (wanted2 ~= "" and t:find(wanted2,1,true)) then return true end
            end
            return false
        end
        if inspect(root) then return true end
        for _, obj in ipairs(root:GetDescendants()) do
            if inspect(obj) then return true end
        end
        return false
    end

    local function verifyServerReplication(beforeNames)
        local player = Players.LocalPlayer
        local char = player and player.Character
        if not char then return false end
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") or obj:IsA("Folder") or obj:IsA("Model") then
                if textMatches(obj) then return true end
            end
        end
        for key, value in pairs(char:GetAttributes()) do
            if type(value) == "string" and (value:find(cfg.Line1,1,true) or value:find(cfg.Line2,1,true)) then
                return true
            end
        end
        return false
    end

    local function fireVariants(remote, enabled)
        if not remote then return false end
        local data = payload(enabled)
        local variants = {
            function() remote:FireServer(data) end,
            function() remote:FireServer(data.Text, data.ColorMode) end,
            function() remote:FireServer(data.Line1, data.Line2, data.ColorMode) end,
            function() remote:FireServer(enabled and data.Text or "") end,
        }
        for i, fn in ipairs(variants) do
            local ok = pcall(fn)
            if ok then
                task.wait(0.28)
                if verifyServerReplication() then
                    return true
                end
            end
        end
        return false
    end

    local function syncWithProvider(enabled)
        local provider = env.DBTitleProvider
        if type(provider) ~= "table" then return false end
        if enabled and type(provider.Publish) == "function" then
            local ok, result = pcall(provider.Publish, payload(true))
            if ok and result ~= false then
                syncState.Status = "已通过外部服务器同步接口发布"
                syncState.Method = "provider"
                syncState.Verified = true
                return true
            end
        elseif not enabled and type(provider.Clear) == "function" then
            local ok, result = pcall(provider.Clear)
            if ok and result ~= false then
                syncState.Status = "公开宣传框已清除"
                syncState.Method = "provider"
                return true
            end
        end
        return false
    end

    local function syncPublic(forceScan)
        if syncState.Busy then return false end
        if not cfg.ServerSync then
            syncState.Status = "公开同步已关闭"
            syncState.Method = "local"
            return false
        end
        syncState.Busy = true
        local success = false
        if syncWithProvider(cfg.Enabled) then
            success = true
        else
            local remote = findCandidateRemote(forceScan)
            if remote then
                success = fireVariants(remote, cfg.Enabled)
                if success then
                    syncState.Status = "服务器公开同步已验证"
                    syncState.Method = "remote"
                    syncState.Verified = true
                    syncState.LastPublish = os.clock()
                else
                    syncState.Status = "发现展示接口，但当前游戏参数不兼容"
                    syncState.Method = "local"
                    syncState.Verified = false
                end
            end
        end
        syncState.Busy = false
        return success
    end

    local function destroyLocal()
        if rainbowConn then rainbowConn:Disconnect(); rainbowConn = nil end
        if gui then gui:Destroy(); gui = nil end
    end

    local function addRainbow(label, offset)
        local grad = Instance.new("UIGradient")
        grad.Name = "DB_TitleRainbow"
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,50,70)),
            ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255,165,45)),
            ColorSequenceKeypoint.new(0.32, Color3.fromRGB(255,235,65)),
            ColorSequenceKeypoint.new(0.48, Color3.fromRGB(70,235,125)),
            ColorSequenceKeypoint.new(0.64, Color3.fromRGB(65,220,255)),
            ColorSequenceKeypoint.new(0.80, Color3.fromRGB(105,120,255)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(240,85,220)),
        })
        grad.Offset = Vector2.new(offset or 0, 0)
        grad.Parent = label
        return grad
    end

    local function applyTextColor(label, rainbowOffset)
        for _, c in ipairs(label:GetChildren()) do
            if c:IsA("UIGradient") and c.Name == "DB_TitleRainbow" then c:Destroy() end
        end
        if cfg.ColorMode == "彩虹" then
            label.TextColor3 = Color3.new(1,1,1)
            return addRainbow(label, rainbowOffset)
        else
            label.TextColor3 = solidColors[cfg.ColorMode] or Color3.new(1,1,1)
        end
        return nil
    end

    local function render(character)
        destroyLocal()
        currentCharacter = character
        if not cfg.Enabled or not character then
            task.spawn(syncPublic)
            return
        end
        local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 5)
        if not head then task.spawn(syncPublic); return end

        local bill = Instance.new("BillboardGui")
        bill.Name = "DB_CustomTitle"
        bill.Adornee = head
        bill.AlwaysOnTop = true
        bill.LightInfluence = 0
        pcall(function() bill.MaxDistance = 0 end)
        bill.Size = UDim2.fromOffset(178, 42)
        bill.StudsOffset = Vector3.new(0, 3.05, 0)
        bill.ResetOnSpawn = false
        bill.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        bill.Parent = MainGui

        local card = Instance.new("Frame")
        card.Size = UDim2.fromScale(1,1)
        card.BackgroundColor3 = Color3.fromRGB(8,8,10)
        card.BackgroundTransparency = 0.30
        card.BorderSizePixel = 0
        card.Parent = bill
        AddCorner(card, 10)

        local stroke = Instance.new("UIStroke")
        stroke.Name = "DB_TitleBorder"
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Thickness = 1.65
        stroke.Transparency = 0.08
        stroke.LineJoinMode = Enum.LineJoinMode.Round
        stroke.Parent = card
        local borderGrad = Instance.new("UIGradient")
        borderGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,55,75)),
            ColorSequenceKeypoint.new(.2, Color3.fromRGB(255,205,60)),
            ColorSequenceKeypoint.new(.4, Color3.fromRGB(70,235,125)),
            ColorSequenceKeypoint.new(.6, Color3.fromRGB(65,210,255)),
            ColorSequenceKeypoint.new(.8, Color3.fromRGB(115,95,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(245,75,205)),
        })
        borderGrad.Parent = stroke

        local l1 = Instance.new("TextLabel")
        l1.Name = "Line1"
        l1.Position = UDim2.fromOffset(6, 3)
        l1.Size = UDim2.new(1,-12,0,18)
        l1.BackgroundTransparency = 1
        l1.Text = cfg.Line1
        l1.TextSize = 13
        l1.Font = Enum.Font.GothamBlack
        l1.TextXAlignment = Enum.TextXAlignment.Center
        l1.TextYAlignment = Enum.TextYAlignment.Center
        l1.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        l1.TextStrokeTransparency = 0.48
        l1.Parent = card

        local l2 = Instance.new("TextLabel")
        l2.Name = "Line2"
        l2.Position = UDim2.fromOffset(6, 20)
        l2.Size = UDim2.new(1,-12,0,17)
        l2.BackgroundTransparency = 1
        l2.Text = cfg.Line2
        l2.TextSize = 11
        l2.Font = Enum.Font.GothamBold
        l2.TextXAlignment = Enum.TextXAlignment.Center
        l2.TextYAlignment = Enum.TextYAlignment.Center
        l2.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        l2.TextStrokeTransparency = 0.48
        l2.Parent = card

        local g1 = applyTextColor(l1, 0)
        local g2 = applyTextColor(l2, 0.12)
        if cfg.ColorMode == "彩虹" then
            local t = 0
            rainbowConn = RunService.RenderStepped:Connect(function(dt)
                t = (t + dt * 0.34) % 2
                local x = math.sin(t * math.pi) * 0.36
                if g1 and g1.Parent then g1.Offset = Vector2.new(x,0) end
                if g2 and g2.Parent then g2.Offset = Vector2.new(-x,0) end
                if borderGrad and borderGrad.Parent then borderGrad.Rotation = (borderGrad.Rotation + dt * 42) % 360 end
            end)
        end
        gui = bill
        task.spawn(syncPublic)
    end

    function api.Refresh()
        local player = Players.LocalPlayer
        local char = player and player.Character
        if char then render(char) else destroyLocal(); task.spawn(syncPublic) end
    end
    function api.SetEnabled(v) cfg.Enabled = not not v; api.Refresh() end
    function api.SetServerSync(v) cfg.ServerSync = not not v; task.spawn(syncPublic, true) end
    function api.SetText(line1, line2)
        cfg.Line1 = tostring(line1 or ""):sub(1, 48)
        cfg.Line2 = tostring(line2 or ""):sub(1, 48)
        if cfg.Line1 == "" then cfg.Line1 = "大肥鱼脚本" end
        api.Refresh()
    end
    function api.SetColor(mode)
        cfg.ColorMode = tostring(mode or "彩虹")
        api.Refresh()
    end
    function api.GetConfig() return cfg end
    function api.GetColors()
        return {"彩虹","白色","红色","橙色","黄色","绿色","青色","蓝色","紫色","粉色"}
    end
    function api.GetSyncStatus()
        return syncState.Status, syncState.Method, syncState.RemotePath, syncState.Verified
    end
    function api.HasPublicProvider()
        local p = env.DBTitleProvider
        return type(p)=="table" and type(p.Publish)=="function"
    end
    function api.RetryServerSync()
        task.spawn(syncPublic, true)
    end

    task.spawn(function()
        local player = Players.LocalPlayer
        if not player then return end
        player.CharacterAdded:Connect(function(char)
            task.wait(0.35)
            render(char)
        end)
        if player.Character then render(player.Character) end
        task.wait(2.5)
        if cfg.Enabled and cfg.ServerSync and not syncState.Verified then syncPublic(true) end
    end)

    return api
end)()

local DBSpatialAdjustOverlay = nil
local function DBDestroySpatialAdjustOverlay()
    if DBSpatialAdjustOverlay and DBSpatialAdjustOverlay.Parent then
        pcall(function() DBSpatialAdjustOverlay:Destroy() end)
    end
    DBSpatialAdjustOverlay = nil
end

local function DBStartSpatialAnchorAdjustment(onDone)
    DBDestroySpatialAdjustOverlay()
    task.spawn(function()
        if DBSpatial and type(DBSpatial.IsEnabled)=="function" and not DBSpatial.IsEnabled()
        and type(DBSpatial.SetEnabled)=="function" then
            pcall(function() DBSpatial.SetEnabled(true) end)
            task.wait(0.16)
        end
        if not (DBSpatial and type(DBSpatial.IsEnabled)=="function" and DBSpatial.IsEnabled()) then
            pcall(function() ShowDBNotification("3D面板调节", "空间模式尚未准备好，请先开启3D后重试", false) end)
            return
        end
        if type(DBSpatial.SetWorldAnchored)=="function" then
            pcall(function() DBSpatial.SetWorldAnchored(true) end)
        end
        task.wait(0.08)

        local overlay=Instance.new("Frame")
        overlay.Name="DB_SpatialAnchorAdjustOverlay_V145"
        overlay.Size=UDim2.fromScale(1,1)
        overlay.BackgroundTransparency=1
        overlay.BorderSizePixel=0
        overlay.Active=true
        overlay.ZIndex=970
        overlay.Parent=MainGui
        DBSpatialAdjustOverlay=overlay

        local shield=Instance.new("TextButton")
        shield.Name="InputShield"
        shield.Size=UDim2.fromScale(1,1)
        shield.BackgroundTransparency=1
        shield.BorderSizePixel=0
        shield.Text=""
        shield.AutoButtonColor=false
        shield.Selectable=false
        shield.Active=true
        shield.ZIndex=970
        shield.Parent=overlay

        local pad=Instance.new("Frame")
        pad.Name="DirectionPad"
        pad.AnchorPoint=Vector2.new(0.5,0.5)
        pad.Position=UDim2.new(1,-148,0.48,0)
        pad.Size=UDim2.fromOffset(132,132)
        pad.BackgroundColor3=Color3.fromRGB(22,24,29)
        pad.BackgroundTransparency=0.10
        pad.BorderSizePixel=0
        pad.ZIndex=975
        pad.Parent=overlay
        AddCorner(pad,999)
        local padStroke=Instance.new("UIStroke")
        padStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        padStroke.Thickness=1.0
        padStroke.Transparency=0.42
        padStroke.Color=Color3.fromRGB(205,211,222)
        padStroke.Parent=pad

        local center=Instance.new("Frame")
        center.Name="CenterMark"
        center.AnchorPoint=Vector2.new(0.5,0.5)
        center.Position=UDim2.fromScale(0.5,0.5)
        center.Size=UDim2.fromOffset(44,44)
        center.BackgroundColor3=Color3.fromRGB(35,38,45)
        center.BackgroundTransparency=0.06
        center.BorderSizePixel=0
        center.ZIndex=978
        center.Parent=pad
        AddCorner(center,999)

        local centerIcon=Instance.new("ImageLabel")
        centerIcon.Name="UserFourWayArrow"
        centerIcon.AnchorPoint=Vector2.new(0.5,0.5)
        centerIcon.Position=UDim2.fromScale(0.5,0.5)
        centerIcon.Size=UDim2.fromOffset(34,34)
        centerIcon.BackgroundTransparency=1
        centerIcon.BorderSizePixel=0
        centerIcon.Image=DBPanelAdjustIconAsset
        centerIcon.ImageColor3=Color3.fromRGB(238,240,245)
        centerIcon.ImageTransparency=0.03
        centerIcon.ScaleType=Enum.ScaleType.Fit
        centerIcon.ZIndex=980
        centerIcon.Visible=(DBPanelAdjustIconAsset~="")
        centerIcon.Parent=center

        local centerFallback=Instance.new("TextLabel")
        centerFallback.AnchorPoint=Vector2.new(0.5,0.5)
        centerFallback.Position=UDim2.fromScale(0.5,0.5)
        centerFallback.Size=UDim2.fromOffset(31,31)
        centerFallback.BackgroundTransparency=1
        centerFallback.Text="✥"
        centerFallback.TextColor3=Color3.fromRGB(232,235,242)
        centerFallback.TextSize=22
        centerFallback.Font=Enum.Font.GothamBlack
        centerFallback.ZIndex=979
        centerFallback.Visible=(DBPanelAdjustIconAsset=="")
        centerFallback.Parent=center

        local function makeDirectionButton(name,text,pos)
            local b=Instance.new("TextButton")
            b.Name=name
            b.AnchorPoint=Vector2.new(0.5,0.5)
            b.Position=pos
            b.Size=UDim2.fromOffset(36,36)
            b.BackgroundColor3=Color3.fromRGB(43,46,54)
            b.BackgroundTransparency=0.06
            b.BorderSizePixel=0
            b.AutoButtonColor=false
            b.Selectable=false
            b.Active=true
            b.Text=text
            b.TextColor3=Color3.fromRGB(242,244,248)
            b.TextSize=20
            b.Font=Enum.Font.GothamBlack
            b.ZIndex=982
            b.Parent=pad
            AddCorner(b,999)
            local st=Instance.new("UIStroke")
            st.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
            st.Thickness=0.8
            st.Transparency=0.62
            st.Color=Color3.fromRGB(210,216,226)
            st.Parent=b
            return b
        end

        local upButton=makeDirectionButton("MoveUp","↑",UDim2.fromScale(0.5,0.17))
        local downButton=makeDirectionButton("MoveDown","↓",UDim2.fromScale(0.5,0.83))
        local leftButton=makeDirectionButton("MoveLeft","←",UDim2.fromScale(0.17,0.5))
        local rightButton=makeDirectionButton("MoveRight","→",UDim2.fromScale(0.83,0.5))

        local confirm=Instance.new("TextButton")
        confirm.Name="Confirm"
        confirm.AnchorPoint=Vector2.new(0,0.5)
        confirm.Position=UDim2.new(1,12,0.5,0)
        confirm.Size=UDim2.fromOffset(64,36)
        confirm.BackgroundColor3=Color3.fromRGB(38,150,106)
        confirm.BackgroundTransparency=0.08
        confirm.BorderSizePixel=0
        confirm.AutoButtonColor=false
        confirm.Selectable=false
        confirm.Text="确定"
        confirm.TextColor3=Color3.fromRGB(250,252,252)
        confirm.TextSize=11
        confirm.Font=Enum.Font.GothamBold
        confirm.ZIndex=985
        confirm.Parent=pad
        AddCorner(confirm,999)
        local confirmStroke=Instance.new("UIStroke")
        confirmStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        confirmStroke.Thickness=0.8
        confirmStroke.Transparency=0.56
        confirmStroke.Color=Color3.fromRGB(222,238,231)
        confirmStroke.Parent=confirm

        local function currentOffsets()
            if DBSpatial and type(DBSpatial.GetAnchorAdjustment)=="function" then
                local ok,x,y=pcall(DBSpatial.GetAnchorAdjustment)
                if ok then return tonumber(x) or 0,tonumber(y) or 0 end
            end
            return tonumber(DBVisualSettings.SpatialAnchorOffsetX) or 0, tonumber(DBVisualSettings.SpatialAnchorOffsetY) or 0
        end

        local function setOffsets(x,y)
            x=math.clamp(tonumber(x) or 0,-4.0,4.0)
            y=math.clamp(tonumber(y) or 0,-3.0,3.0)
            if DBSpatial and type(DBSpatial.SetAnchorAdjustment)=="function" then
                pcall(function() DBSpatial.SetAnchorAdjustment(x,y) end)
            else
                DBVisualSettings.SpatialAnchorOffsetX=x
                DBVisualSettings.SpatialAnchorOffsetY=y
            end
        end

        local STEP_X=0.14
        local STEP_Y=0.12
        local lastNudgeAt=0
        local function nudge(dx,dy,button)
            local now=os.clock()
            if now-lastNudgeAt<0.045 then return end
            lastNudgeAt=now
            local x,y=currentOffsets()
            setOffsets(x+(dx or 0),y+(dy or 0))
            if button and button.Parent then
                local base=button.BackgroundColor3
                button.BackgroundColor3=Color3.fromRGB(74,78,90)
                task.delay(0.065,function()
                    if button and button.Parent then button.BackgroundColor3=base end
                end)
            end
        end
        upButton.Activated:Connect(function() nudge(0, STEP_Y,upButton) end)
        downButton.Activated:Connect(function() nudge(0,-STEP_Y,downButton) end)
        leftButton.Activated:Connect(function() nudge(-STEP_X,0,leftButton) end)
        rightButton.Activated:Connect(function() nudge(STEP_X,0,rightButton) end)

        confirm.Activated:Connect(function()
            if DBSpatial and type(DBSpatial.SetWorldAnchored)=="function" then
                pcall(function() DBSpatial.SetWorldAnchored(false) end)
            end
            DBDestroySpatialAdjustOverlay()
            if type(onDone)=="function" then task.defer(onDone) end
        end)
    end)
end

local DBSettingsUI = {}
function DBSettingsUI.Show()
DBClearRightList()
State.CurrentCategory = "设置"
local title =
Instance.new(
"TextLabel"
)
title.Size =
UDim2.new(
1,
-12,
0,
24
)
title.BackgroundTransparency = 1
title.Text = "设置"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 15
title.Font = Enum.Font.GothamBlack
title.TextXAlignment = Enum.TextXAlignment.Left
title.LayoutOrder = 1
title.ZIndex = 20
title.Parent = ListScroll
local titlePad =
Instance.new(
"UIPadding"
)
titlePad.PaddingLeft =
UDim.new(
0,
8
)
titlePad.Parent =
title
local row =
Instance.new(
"Frame"
)
row.Size =
UDim2.new(
1,
-12,
0,
74
)
row.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
row.BackgroundTransparency =
0.84
row.BorderSizePixel = 0
row.LayoutOrder = 2
row.ZIndex = 19
row.Parent = ListScroll
AddCorner(
row,
11
)
local stroke =
Instance.new(
"UIStroke"
)
stroke.ApplyStrokeMode =
Enum.ApplyStrokeMode.Border
stroke.Thickness = 0.8
stroke.Transparency = 0.56
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.LineJoinMode = Enum.LineJoinMode.Round
stroke.Parent = row
local message =
Instance.new(
"TextLabel"
)
message.Size =
UDim2.new(
1,
-20,
1,
0
)
message.Position =
UDim2.fromOffset(
10,
0
)
message.BackgroundTransparency = 1
message.Text = "持续更新中，尽情期待"
message.TextColor3 = Color3.fromRGB(255, 255, 255)
message.TextSize = 15
message.Font = Enum.Font.GothamBlack
message.TextXAlignment = Enum.TextXAlignment.Center
message.TextYAlignment = Enum.TextYAlignment.Center
message.ZIndex = 20
message.Parent = row

local transitionRow = Instance.new("Frame")
transitionRow.Name = "DB_TransitionStyleSettings"
transitionRow.Size = UDim2.new(1,-12,0,58)
transitionRow.BackgroundColor3 = Color3.fromRGB(255,255,255)
transitionRow.BackgroundTransparency = 0.84
transitionRow.BorderSizePixel = 0
transitionRow.LayoutOrder = 3
transitionRow.ZIndex = 45
transitionRow.ClipsDescendants = false
transitionRow.Parent = ListScroll
AddCorner(transitionRow,11)
local transitionStroke = Instance.new("UIStroke")
transitionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
transitionStroke.Thickness = 0.8
transitionStroke.Transparency = 0.56
transitionStroke.Color = Color3.fromRGB(255,255,255)
transitionStroke.LineJoinMode = Enum.LineJoinMode.Round
transitionStroke.Parent = transitionRow

local transitionLabel = Instance.new("TextLabel")
transitionLabel.Position = UDim2.fromOffset(10,0)
transitionLabel.Size = UDim2.new(0.44,-14,1,0)
transitionLabel.BackgroundTransparency = 1
transitionLabel.Text = "过渡动画样式"
transitionLabel.TextColor3 = Color3.fromRGB(250,250,252)
transitionLabel.TextSize = 12
transitionLabel.Font = Enum.Font.GothamBold
transitionLabel.TextXAlignment = Enum.TextXAlignment.Left
transitionLabel.TextTruncate = Enum.TextTruncate.AtEnd
transitionLabel.ZIndex = 47
transitionLabel.Parent = transitionRow

local transitionSelector = Instance.new("TextButton")
transitionSelector:SetAttribute("DB_SpatialPreserveBaseVisual",true)
transitionSelector.AnchorPoint = Vector2.new(1,0.5)
transitionSelector.Position = UDim2.new(1,-10,0.5,0)
transitionSelector.Size = UDim2.new(0.40,0,0,30)
transitionSelector.BackgroundColor3 = Color3.fromRGB(40,42,48)
transitionSelector.BackgroundTransparency = 0.10
transitionSelector.BorderSizePixel = 0
transitionSelector.AutoButtonColor = false
transitionSelector.Text = ""
transitionSelector.ZIndex = 48
transitionSelector.Parent = transitionRow
local transitionSelectorConstraint = Instance.new("UISizeConstraint")
transitionSelectorConstraint.MinSize = Vector2.new(112,30)
transitionSelectorConstraint.MaxSize = Vector2.new(142,30)
transitionSelectorConstraint.Parent = transitionSelector
AddCorner(transitionSelector,999)
local selectorValue = Instance.new("TextLabel")
selectorValue.Position = UDim2.fromOffset(12,0)
selectorValue.Size = UDim2.new(1,-44,1,0)
selectorValue.BackgroundTransparency = 1
selectorValue.Text = DBVisualSettings.TransitionStyle or "原版"
selectorValue.TextColor3 = Color3.fromRGB(242,242,246)
selectorValue.TextSize = 11
selectorValue.Font = Enum.Font.GothamBold
selectorValue.TextXAlignment = Enum.TextXAlignment.Left
selectorValue.ZIndex = 49
selectorValue.Parent = transitionSelector
local selectorKnob = Instance.new("Frame")
selectorKnob.AnchorPoint = Vector2.new(1,0.5)
selectorKnob.Position = UDim2.new(1,-5,0.5,0)
selectorKnob.Size = UDim2.fromOffset(22,22)
selectorKnob.BackgroundColor3 = Color3.fromRGB(238,238,242)
selectorKnob.BackgroundTransparency = 0.04
selectorKnob.BorderSizePixel = 0
selectorKnob.ZIndex = 50
selectorKnob.Parent = transitionSelector
AddCorner(selectorKnob,999)

local uiStylePopup = nil
local uiStyleRow = nil
local transitionPopup = Instance.new("Frame")
transitionPopup.AnchorPoint = Vector2.new(1,0)
transitionPopup.Position = UDim2.new(1,-10,1,4)
transitionPopup.Size = UDim2.fromOffset(142,112)
transitionPopup.BackgroundColor3 = Color3.fromRGB(20,21,25)
transitionPopup.BackgroundTransparency = 0.04
transitionPopup.BorderSizePixel = 0
transitionPopup.Visible = false
transitionPopup.ZIndex = 930
transitionPopup.Parent = transitionRow
AddCorner(transitionPopup,11)
local popupStroke = Instance.new("UIStroke")
popupStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
popupStroke.Thickness = 0.9
popupStroke.Transparency = 0.48
popupStroke.Color = Color3.fromRGB(220,222,230)
popupStroke.LineJoinMode = Enum.LineJoinMode.Round
popupStroke.Parent = transitionPopup
local popupScroll = Instance.new("ScrollingFrame")
popupScroll.Position = UDim2.fromOffset(5,5)
popupScroll.Size = UDim2.new(1,-10,1,-10)
popupScroll.BackgroundTransparency = 1
popupScroll.BorderSizePixel = 0
popupScroll.ScrollBarThickness = 2
popupScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
popupScroll.CanvasSize = UDim2.new()
popupScroll.ScrollingDirection = Enum.ScrollingDirection.Y
popupScroll.ZIndex = 931
popupScroll.Parent = transitionPopup
local popupLayout = Instance.new("UIListLayout")
popupLayout.Padding = UDim.new(0,4)
popupLayout.SortOrder = Enum.SortOrder.LayoutOrder
popupLayout.Parent = popupScroll
local transitionOptions = {"原版","增加模糊","老式款"}
local function refreshTransitionSelector()
    selectorValue.Text = DBVisualSettings.TransitionStyle or "原版"
end
for index, styleName in ipairs(transitionOptions) do
    local option = Instance.new("TextButton")
    option.Size = UDim2.new(1,-4,0,29)
    option.BackgroundColor3 = Color3.fromRGB(45,47,53)
    option.BackgroundTransparency = 0.10
    option.BorderSizePixel = 0
    option.AutoButtonColor = false
    option.Text = styleName
    option.TextColor3 = Color3.fromRGB(245,245,248)
    option.TextSize = 11
    option.Font = Enum.Font.GothamBold
    option.LayoutOrder = index
    option.ZIndex = 932
    option.Parent = popupScroll
    AddCorner(option,8)
    option.Activated:Connect(function()
        DBVisualSettings.TransitionStyle = styleName
        refreshTransitionSelector()
        transitionPopup.Visible = false
        transitionRow.ZIndex = 45
        ListScroll.ClipsDescendants = true
        ListScroll.ScrollingEnabled = true
    end)
end
transitionSelector.Activated:Connect(function()
    local show = not transitionPopup.Visible
    if uiStylePopup then uiStylePopup.Visible = false end
    if uiStyleRow then uiStyleRow.ZIndex = 45 end
    transitionPopup.Visible = show
    transitionRow.ZIndex = show and 920 or 45
    ListScroll.ClipsDescendants = not show
    ListScroll.ScrollingEnabled = not show
end)

local function show3DPanelSettings()
    DBClearRightList()
    State.CurrentCategory="设置/3D面板设置"

    local head=Instance.new("Frame")
    head.Name="DB_3DSettingsHeader"
    head.Size=UDim2.new(1,-12,0,42)
    head.BackgroundColor3=Color3.fromRGB(255,255,255)
    head.BackgroundTransparency=0.91
    head.BorderSizePixel=0
    head.LayoutOrder=1
    head.ZIndex=70
    head.Parent=ListScroll
    AddCorner(head,11)

    local backBtn=Instance.new("TextButton")
    backBtn.Position=UDim2.fromOffset(7,6)
    backBtn.Size=UDim2.fromOffset(34,30)
    backBtn.BackgroundColor3=Color3.fromRGB(255,255,255)
    backBtn.BackgroundTransparency=0.90
    backBtn.BorderSizePixel=0
    backBtn.AutoButtonColor=false
    backBtn.Text="←"
    backBtn.TextColor3=Color3.fromRGB(248,249,252)
    backBtn.TextSize=17
    backBtn.Font=Enum.Font.GothamBold
    backBtn.ZIndex=72
    backBtn.Parent=head
    AddCorner(backBtn,999)

    local headTitle=Instance.new("TextLabel")
    headTitle.Position=UDim2.fromOffset(50,0)
    headTitle.Size=UDim2.new(1,-60,1,0)
    headTitle.BackgroundTransparency=1
    headTitle.Text="3D面板设置"
    headTitle.TextColor3=Color3.fromRGB(252,252,254)
    headTitle.TextSize=14
    headTitle.Font=Enum.Font.GothamBlack
    headTitle.TextXAlignment=Enum.TextXAlignment.Left
    headTitle.TextTruncate=Enum.TextTruncate.AtEnd
    headTitle.ZIndex=72
    headTitle.Parent=head
    backBtn.Activated:Connect(function() DBSettingsUI.Show() end)

    local styleCard=Instance.new("Frame")
    styleCard.Name="DB_3DStyleCard"
    styleCard.Size=UDim2.new(1,-12,0,92)
    styleCard.BackgroundColor3=Color3.fromRGB(255,255,255)
    styleCard.BackgroundTransparency=0.90
    styleCard.BorderSizePixel=0
    styleCard.LayoutOrder=2
    styleCard.ZIndex=68
    styleCard.Parent=ListScroll
    AddCorner(styleCard,11)

    local styleTitle=Instance.new("TextLabel")
    styleTitle.Position=UDim2.fromOffset(11,7)
    styleTitle.Size=UDim2.new(1,-22,0,22)
    styleTitle.BackgroundTransparency=1
    styleTitle.Text="UI样式"
    styleTitle.TextColor3=Color3.fromRGB(250,250,253)
    styleTitle.TextSize=12
    styleTitle.Font=Enum.Font.GothamBold
    styleTitle.TextXAlignment=Enum.TextXAlignment.Left
    styleTitle.ZIndex=70
    styleTitle.Parent=styleCard

    local optionHost=Instance.new("Frame")
    optionHost.Position=UDim2.fromOffset(10,36)
    optionHost.Size=UDim2.new(1,-20,0,44)
    optionHost.BackgroundTransparency=1
    optionHost.BorderSizePixel=0
    optionHost.ZIndex=70
    optionHost.Parent=styleCard

    local styleButtons={}
    local options={"默认","中宽两窄"}
    local function refreshStyleButtons()
        local current=tostring(DBVisualSettings.SpatialStyle or "默认")
        for name,b in pairs(styleButtons) do
            if b and b.Parent then
                local selected=(name==current)
                b.BackgroundColor3=Color3.fromRGB(255,255,255)
                b.BackgroundTransparency=selected and 0.78 or 0.94
                b.TextColor3=Color3.fromRGB(250,250,252)
            end
        end
    end
    for i,name in ipairs(options) do
        local b=Instance.new("TextButton")
        b.Name="DB_3DStyle_"..name
        b:SetAttribute("DB_SpatialPersistentSelection",true)
        b.AnchorPoint=Vector2.new((i==1) and 0 or 1,0)
        b.Position=(i==1) and UDim2.new(0,0,0,0) or UDim2.new(1,0,0,0)
        b.Size=UDim2.new(0.485,0,1,0)
        b.BackgroundColor3=Color3.fromRGB(255,255,255)
        b.BackgroundTransparency=0.94
        b.BorderSizePixel=0
        b.AutoButtonColor=false
        b.Selectable=false
        b.Text=name
        b.TextColor3=Color3.fromRGB(250,250,252)
        b.TextSize=11
        b.Font=Enum.Font.GothamBold
        b.TextTruncate=Enum.TextTruncate.AtEnd
        b.ZIndex=71
        b.Parent=optionHost
        AddCorner(b,10)
        styleButtons[name]=b
        b.Activated:Connect(function()
            DBVisualSettings.SpatialStyle=name
            if DBSpatial and type(DBSpatial.SetStyle)=="function" then pcall(function() DBSpatial.SetStyle(name) end) end
            refreshStyleButtons()
        end)
    end
    refreshStyleButtons()

    local bgRow=Instance.new("Frame")
    bgRow.Name="DB_3DLogoBackgroundRow"
    bgRow.Size=UDim2.new(1,-12,0,62)
    bgRow.BackgroundColor3=Color3.fromRGB(255,255,255)
    bgRow.BackgroundTransparency=0.90
    bgRow.BorderSizePixel=0
    bgRow.LayoutOrder=3
    bgRow.ZIndex=68
    bgRow.Parent=ListScroll
    AddCorner(bgRow,11)

    local bgTitle=Instance.new("TextLabel")
    bgTitle.Position=UDim2.fromOffset(11,6)
    bgTitle.Size=UDim2.new(1,-120,0,22)
    bgTitle.BackgroundTransparency=1
    bgTitle.Text="默认背景"
    bgTitle.TextColor3=Color3.fromRGB(250,250,253)
    bgTitle.TextSize=12
    bgTitle.Font=Enum.Font.GothamBold
    bgTitle.TextXAlignment=Enum.TextXAlignment.Left
    bgTitle.ZIndex=70
    bgTitle.Parent=bgRow

    local bgHint=Instance.new("TextLabel")
    bgHint.Position=UDim2.fromOffset(11,29)
    bgHint.Size=UDim2.new(1,-120,0,18)
    bgHint.BackgroundTransparency=1
    bgHint.Text="半透明 大肥鱼 Logo · 三个面板同步"
    bgHint.TextColor3=Color3.fromRGB(184,190,202)
    bgHint.TextSize=9
    bgHint.Font=Enum.Font.GothamMedium
    bgHint.TextXAlignment=Enum.TextXAlignment.Left
    bgHint.TextTruncate=Enum.TextTruncate.AtEnd
    bgHint.ZIndex=70
    bgHint.Parent=bgRow

    local bgToggle=Instance.new("TextButton")
    bgToggle:SetAttribute("DB_SpatialPreserveBaseVisual",true)
    bgToggle.AnchorPoint=Vector2.new(1,0.5)
    bgToggle.Position=UDim2.new(1,-11,0.5,0)
    bgToggle.Size=UDim2.fromOffset(82,32)
    bgToggle.BackgroundTransparency=0.06
    bgToggle.BorderSizePixel=0
    bgToggle.AutoButtonColor=false
    bgToggle.Selectable=false
    bgToggle.TextSize=10
    bgToggle.Font=Enum.Font.GothamBold
    bgToggle.TextColor3=Color3.fromRGB(245,247,251)
    bgToggle.ZIndex=71
    bgToggle.Parent=bgRow
    AddCorner(bgToggle,999)
    local function refreshBgToggle()
        local enabled=DBVisualSettings.SpatialLogoBackgroundEnabled~=false
        bgToggle.Text=enabled and "显示" or "隐藏"
        bgToggle.BackgroundColor3=enabled and Color3.fromRGB(54,63,82) or Color3.fromRGB(31,34,40)
    end
    bgToggle.Activated:Connect(function()
        DBVisualSettings.SpatialLogoBackgroundEnabled=not (DBVisualSettings.SpatialLogoBackgroundEnabled~=false)
        refreshBgToggle()
        if DBSpatial and type(DBSpatial.RefreshPanelAppearance)=="function" then pcall(DBSpatial.RefreshPanelAppearance) end
    end)
    refreshBgToggle()

    local borderRow=Instance.new("Frame")
    borderRow.Name="DB_3DBorderRow"
    borderRow.Size=UDim2.new(1,-12,0,62)
    borderRow.BackgroundColor3=Color3.fromRGB(255,255,255)
    borderRow.BackgroundTransparency=0.90
    borderRow.BorderSizePixel=0
    borderRow.LayoutOrder=4
    borderRow.ZIndex=68
    borderRow.Parent=ListScroll
    AddCorner(borderRow,11)

    local borderTitle=Instance.new("TextLabel")
    borderTitle.Position=UDim2.fromOffset(11,6)
    borderTitle.Size=UDim2.new(1,-124,0,22)
    borderTitle.BackgroundTransparency=1
    borderTitle.Text="边框描边"
    borderTitle.TextColor3=Color3.fromRGB(250,250,253)
    borderTitle.TextSize=12
    borderTitle.Font=Enum.Font.GothamBold
    borderTitle.TextXAlignment=Enum.TextXAlignment.Left
    borderTitle.ZIndex=70
    borderTitle.Parent=borderRow

    local borderHint=Instance.new("TextLabel")
    borderHint.Position=UDim2.fromOffset(11,29)
    borderHint.Size=UDim2.new(1,-124,0,18)
    borderHint.BackgroundTransparency=1
    borderHint.Text="2D同款环绕彩虹 / 固定颜色 · 实时生效"
    borderHint.TextColor3=Color3.fromRGB(184,190,202)
    borderHint.TextSize=9
    borderHint.Font=Enum.Font.GothamMedium
    borderHint.TextXAlignment=Enum.TextXAlignment.Left
    borderHint.TextTruncate=Enum.TextTruncate.AtEnd
    borderHint.ZIndex=70
    borderHint.Parent=borderRow

    local borderSelector=Instance.new("TextButton")
    borderSelector:SetAttribute("DB_SpatialPreserveBaseVisual",true)
    borderSelector.AnchorPoint=Vector2.new(1,0.5)
    borderSelector.Position=UDim2.new(1,-11,0.5,0)
    borderSelector.Size=UDim2.fromOffset(92,32)
    borderSelector.BackgroundColor3=Color3.fromRGB(30,33,39)
    borderSelector.BackgroundTransparency=0.04
    borderSelector.BorderSizePixel=0
    borderSelector.AutoButtonColor=false
    borderSelector.Selectable=false
    borderSelector.TextColor3=Color3.fromRGB(246,248,252)
    borderSelector.TextSize=10
    borderSelector.Font=Enum.Font.GothamBold
    borderSelector.ZIndex=72
    borderSelector.Parent=borderRow
    AddCorner(borderSelector,999)

    local borderPopup=Instance.new("Frame")
    borderPopup.Name="DB_3DBorderPopup"
    borderPopup.AnchorPoint=Vector2.new(1,0.5)
    borderPopup.Position=UDim2.new(1,-10,0.5,0)
    borderPopup.Size=UDim2.fromOffset(124,164)
    borderPopup.BackgroundColor3=Color3.fromRGB(18,20,25)
    borderPopup.BackgroundTransparency=0.02
    borderPopup.BorderSizePixel=0
    borderPopup.Visible=false
    borderPopup.ZIndex=940
    borderPopup.Parent=borderRow
    AddCorner(borderPopup,10)
    local popupStroke=Instance.new("UIStroke")
    popupStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    popupStroke.Thickness=0.9
    popupStroke.Transparency=0.46
    popupStroke.Color=Color3.fromRGB(198,205,218)
    popupStroke.Parent=borderPopup

    local borderPopupScroll=Instance.new("ScrollingFrame")
    borderPopupScroll.Position=UDim2.fromOffset(5,5)
    borderPopupScroll.Size=UDim2.new(1,-10,1,-10)
    borderPopupScroll.BackgroundTransparency=1
    borderPopupScroll.BorderSizePixel=0
    borderPopupScroll.ScrollBarThickness=3
    borderPopupScroll.ScrollBarImageColor3=Color3.fromRGB(205,211,225)
    borderPopupScroll.ScrollBarImageTransparency=0.20
    borderPopupScroll.CanvasSize=UDim2.fromOffset(0,256)
    borderPopupScroll.AutomaticCanvasSize=Enum.AutomaticSize.None
    borderPopupScroll.ScrollingDirection=Enum.ScrollingDirection.Y
    borderPopupScroll.ScrollingEnabled=true
    borderPopupScroll.Active=true
    borderPopupScroll.ElasticBehavior=Enum.ElasticBehavior.Never
    borderPopupScroll.ZIndex=941
    borderPopupScroll.Parent=borderPopup
    local borderPopupLayout=Instance.new("UIListLayout")
    borderPopupLayout.Padding=UDim.new(0,4)
    borderPopupLayout.SortOrder=Enum.SortOrder.LayoutOrder
    borderPopupLayout.Parent=borderPopupScroll

    local borderModes={"默认","彩虹","黄色","绿色","红色","紫色","白色","橙色"}
    local borderModeButtons={}
    local borderPopupDragging=false
    local borderPopupDidDrag=false
    local borderPopupDragInput=nil
    local borderPopupDragStartY=0
    local borderPopupCanvasStart=0
    local function borderPopupMaxCanvasY()
        return math.max(0, 256 - borderPopupScroll.AbsoluteSize.Y)
    end
    borderPopupScroll.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
            borderPopupDragging=true
            borderPopupDidDrag=false
            borderPopupDragInput=input
            borderPopupDragStartY=input.Position.Y
            borderPopupCanvasStart=borderPopupScroll.CanvasPosition.Y
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not borderPopupDragging or input~=borderPopupDragInput then return end
        local delta=input.Position.Y-borderPopupDragStartY
        if math.abs(delta)>5 then borderPopupDidDrag=true end
        borderPopupScroll.CanvasPosition=Vector2.new(0,math.clamp(borderPopupCanvasStart-delta,0,borderPopupMaxCanvasY()))
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input==borderPopupDragInput then
            borderPopupDragging=false
            borderPopupDragInput=nil
            if borderPopupDidDrag then task.delay(0.08,function() borderPopupDidDrag=false end) end
        end
    end)
    local function refreshBorderSelector()
        local current=tostring(DBVisualSettings.SpatialBorderMode or "默认")
        borderSelector.Text=current
        for mode,b in pairs(borderModeButtons) do
            if b and b.Parent then
                b.Text=mode
                b.BackgroundTransparency=(mode==current) and 0.18 or 0.36
                b.TextColor3=(mode==current) and Color3.fromRGB(255,255,255) or Color3.fromRGB(225,229,238)
            end
        end
    end
    for index,mode in ipairs(borderModes) do
        local option=Instance.new("TextButton")
        option.Size=UDim2.new(1,-2,0,27)
        option.BackgroundColor3=Color3.fromRGB(49,52,61)
        option.BackgroundTransparency=0.36
        option.BorderSizePixel=0
        option.AutoButtonColor=false
        option.Selectable=false
        option.TextColor3=Color3.fromRGB(245,247,251)
        option.TextSize=10
        option.Font=Enum.Font.GothamBold
        option.TextXAlignment=Enum.TextXAlignment.Left
        option.LayoutOrder=index
        option.ZIndex=942
        option.Parent=borderPopupScroll
        AddCorner(option,8)
        local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,8); pad.Parent=option
        borderModeButtons[mode]=option
        option.Activated:Connect(function()
            if borderPopupDidDrag then return end
            DBVisualSettings.SpatialBorderMode=mode
            refreshBorderSelector()
            borderPopup.Visible=false
            borderRow.ZIndex=68
            ListScroll.ClipsDescendants=true
            ListScroll.ScrollingEnabled=true
            if DBSpatial and type(DBSpatial.RefreshPanelAppearance)=="function" then pcall(DBSpatial.RefreshPanelAppearance) end
        end)
    end
    borderSelector.Activated:Connect(function()
        local show=not borderPopup.Visible
        borderPopup.Visible=show
        borderRow.ZIndex=show and 930 or 68
        ListScroll.ClipsDescendants=not show
        ListScroll.ScrollingEnabled=not show
        if show then
            borderPopupScroll.ScrollingEnabled=true
            borderPopupScroll.Active=true
            borderPopupScroll.CanvasPosition=Vector2.new(0,0)
        end
    end)
    refreshBorderSelector()

    local adjust=Instance.new("TextButton")
    adjust:SetAttribute("DB_SpatialPreserveBaseVisual",true)
    adjust.Name="DB_AnchorFineTuneEntry"
    adjust.Size=UDim2.new(1,-12,0,78)
    adjust.BackgroundColor3=Color3.fromRGB(255,255,255)
    adjust.BackgroundTransparency=0.90
    adjust.BorderSizePixel=0
    adjust.AutoButtonColor=false
    adjust.Selectable=false
    adjust.Text=""
    adjust.LayoutOrder=5
    adjust.ZIndex=68
    adjust.Parent=ListScroll
    AddCorner(adjust,11)

    local adjustTitle=Instance.new("TextLabel")
    adjustTitle.Position=UDim2.fromOffset(11,8)
    adjustTitle.Size=UDim2.new(1,-118,0,24)
    adjustTitle.BackgroundTransparency=1
    adjustTitle.Text="置于原地面板调节"
    adjustTitle.TextColor3=Color3.fromRGB(250,250,253)
    adjustTitle.TextSize=12
    adjustTitle.Font=Enum.Font.GothamBold
    adjustTitle.TextXAlignment=Enum.TextXAlignment.Left
    adjustTitle.TextTruncate=Enum.TextTruncate.AtEnd
    adjustTitle.ZIndex=70
    adjustTitle.Parent=adjust

    local adjustHint=Instance.new("TextLabel")
    adjustHint.Position=UDim2.fromOffset(11,35)
    adjustHint.Size=UDim2.new(1,-118,0,25)
    adjustHint.BackgroundTransparency=1
    adjustHint.Text="点击详细调节区域"
    adjustHint.TextColor3=Color3.fromRGB(187,192,203)
    adjustHint.TextSize=9
    adjustHint.Font=Enum.Font.GothamMedium
    adjustHint.TextXAlignment=Enum.TextXAlignment.Left
    adjustHint.TextTruncate=Enum.TextTruncate.AtEnd
    adjustHint.ZIndex=70
    adjustHint.Parent=adjust

    local enter=Instance.new("TextLabel")
    enter.AnchorPoint=Vector2.new(1,0.5)
    enter.Position=UDim2.new(1,-12,0.5,0)
    enter.Size=UDim2.fromOffset(92,34)
    enter.BackgroundColor3=Color3.fromRGB(31,34,40)
    enter.BackgroundTransparency=0.06
    enter.BorderSizePixel=0
    enter.Text="详细调节  ›"
    enter.TextColor3=Color3.fromRGB(246,248,251)
    enter.TextSize=10
    enter.Font=Enum.Font.GothamBold
    enter.ZIndex=71
    enter.Parent=adjust
    AddCorner(enter,999)

    adjust.Activated:Connect(function()
        DBStartSpatialAnchorAdjustment(function()
            if DBSettingsUI and type(DBSettingsUI.Show3DPanelSettings)=="function" then
                DBSettingsUI.Show3DPanelSettings()
            end
        end)
    end)

    local note=Instance.new("TextLabel")
    note.Size=UDim2.new(1,-18,0,34)
    note.BackgroundTransparency=1
    note.Text="右侧圆形方向盘使用上/下/左/右四个箭头点按微调；中心四向图只作标识。点“确定”保存后再使用顶部绿色固定按钮。"
    note.TextColor3=Color3.fromRGB(170,176,190)
    note.TextSize=9
    note.Font=Enum.Font.GothamMedium
    note.TextWrapped=true
    note.TextXAlignment=Enum.TextXAlignment.Left
    note.TextYAlignment=Enum.TextYAlignment.Top
    note.LayoutOrder=6
    note.ZIndex=66
    note.Parent=ListScroll
end
DBSettingsUI.Show3DPanelSettings=show3DPanelSettings

uiStyleRow = Instance.new("Frame")
uiStyleRow.Name="DB_3DPanelSettingsEntry"
uiStyleRow.Size=UDim2.new(1,-12,0,62)
uiStyleRow.BackgroundColor3=Color3.fromRGB(255,255,255)
uiStyleRow.BackgroundTransparency=0.84
uiStyleRow.BorderSizePixel=0
uiStyleRow.LayoutOrder=4
uiStyleRow.ZIndex=45
uiStyleRow.Parent=ListScroll
AddCorner(uiStyleRow,11)
local uiStyleStroke=Instance.new("UIStroke")
uiStyleStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
uiStyleStroke.Thickness=0.8
uiStyleStroke.Transparency=0.56
uiStyleStroke.Color=Color3.fromRGB(255,255,255)
uiStyleStroke.LineJoinMode=Enum.LineJoinMode.Round
uiStyleStroke.Parent=uiStyleRow

local panelSettingsTitle=Instance.new("TextLabel")
panelSettingsTitle.Position=UDim2.fromOffset(10,5)
panelSettingsTitle.Size=UDim2.new(1,-122,0,24)
panelSettingsTitle.BackgroundTransparency=1
panelSettingsTitle.Text="3D面板设置"
panelSettingsTitle.TextColor3=Color3.fromRGB(250,250,252)
panelSettingsTitle.TextSize=12
panelSettingsTitle.Font=Enum.Font.GothamBold
panelSettingsTitle.TextXAlignment=Enum.TextXAlignment.Left
panelSettingsTitle.TextTruncate=Enum.TextTruncate.AtEnd
panelSettingsTitle.ZIndex=47
panelSettingsTitle.Parent=uiStyleRow

local panelSettingsHint=Instance.new("TextLabel")
panelSettingsHint.Position=UDim2.fromOffset(10,30)
panelSettingsHint.Size=UDim2.new(1,-122,0,20)
panelSettingsHint.BackgroundTransparency=1
panelSettingsHint.Text="UI样式 · 背景/描边 · 位置调节"
panelSettingsHint.TextColor3=Color3.fromRGB(190,194,205)
panelSettingsHint.TextSize=9
panelSettingsHint.Font=Enum.Font.GothamMedium
panelSettingsHint.TextXAlignment=Enum.TextXAlignment.Left
panelSettingsHint.TextTruncate=Enum.TextTruncate.AtEnd
panelSettingsHint.ZIndex=47
panelSettingsHint.Parent=uiStyleRow

local panelSettingsOpen=Instance.new("TextButton")
panelSettingsOpen.AnchorPoint=Vector2.new(1,0.5)
panelSettingsOpen.Position=UDim2.new(1,-10,0.5,0)
panelSettingsOpen.Size=UDim2.fromOffset(96,34)
panelSettingsOpen.BackgroundColor3=Color3.fromRGB(25,27,32)
panelSettingsOpen.BackgroundTransparency=0.04
panelSettingsOpen.BorderSizePixel=0
panelSettingsOpen.AutoButtonColor=false
panelSettingsOpen.Selectable=false
panelSettingsOpen.Text="进入  ›"
panelSettingsOpen.TextColor3=Color3.fromRGB(246,247,250)
panelSettingsOpen.TextSize=10
panelSettingsOpen.Font=Enum.Font.GothamBold
panelSettingsOpen.ZIndex=49
panelSettingsOpen.Parent=uiStyleRow
AddCorner(panelSettingsOpen,999)
panelSettingsOpen.Activated:Connect(show3DPanelSettings)

DBVisualSettings.SpatialNavBoxesEnabled = false

local spatialRow = Instance.new("Frame")
spatialRow.Name = "DB_SpatialModeSettings"
spatialRow.Size = UDim2.new(1,-12,0,58)
spatialRow.BackgroundColor3 = Color3.fromRGB(255,255,255)
spatialRow.BackgroundTransparency = 0.84
spatialRow.BorderSizePixel = 0
spatialRow.LayoutOrder = 5
spatialRow.ZIndex = 45
spatialRow.Parent = ListScroll
AddCorner(spatialRow,11)
local spatialStroke = Instance.new("UIStroke")
spatialStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
spatialStroke.Thickness = 0.8
spatialStroke.Transparency = 0.56
spatialStroke.Color = Color3.fromRGB(255,255,255)
spatialStroke.LineJoinMode = Enum.LineJoinMode.Round
spatialStroke.Parent = spatialRow

local spatialTitle = Instance.new("TextLabel")
spatialTitle.Position = UDim2.fromOffset(10,6)
spatialTitle.Size = UDim2.new(1,-138,0,22)
spatialTitle.BackgroundTransparency = 1
spatialTitle.Text = "三栏空间悬浮 · AR/VR"
spatialTitle.TextColor3 = Color3.fromRGB(250,250,252)
spatialTitle.TextSize = 12
spatialTitle.Font = Enum.Font.GothamBold
spatialTitle.TextXAlignment = Enum.TextXAlignment.Left
spatialTitle.TextTruncate = Enum.TextTruncate.AtEnd
spatialTitle.ZIndex = 47
spatialTitle.Parent = spatialRow

local spatialHint = Instance.new("TextLabel")
spatialHint.Position = UDim2.fromOffset(10,28)
spatialHint.Size = UDim2.new(1,-138,0,20)
spatialHint.BackgroundTransparency = 1
spatialHint.Text = "默认 / 中宽两窄 · 可跟随 / 实体锚定 / 退回2D"
spatialHint.TextColor3 = Color3.fromRGB(190,194,205)
spatialHint.TextSize = 9
spatialHint.Font = Enum.Font.GothamMedium
spatialHint.TextXAlignment = Enum.TextXAlignment.Left
spatialHint.TextTruncate = Enum.TextTruncate.AtEnd
spatialHint.ZIndex = 47
spatialHint.Parent = spatialRow

local spatialToggle = Instance.new("TextButton")
spatialToggle:SetAttribute("DB_SpatialPreserveBaseVisual",true)
spatialToggle.AnchorPoint = Vector2.new(1,0.5)
spatialToggle.Position = UDim2.new(1,-10,0.5,0)
spatialToggle.Size = UDim2.fromOffset(108,32)
spatialToggle.BackgroundColor3 = Color3.fromRGB(38,40,47)
spatialToggle.BackgroundTransparency = 0.08
spatialToggle.BorderSizePixel = 0
spatialToggle.AutoButtonColor = false
spatialToggle.TextColor3 = Color3.fromRGB(245,245,248)
spatialToggle.TextSize = 10
spatialToggle.Font = Enum.Font.GothamBold
spatialToggle.ZIndex = 49
spatialToggle.Parent = spatialRow
AddCorner(spatialToggle,999)
local function refreshSpatialToggle()
    local active = DBSpatial and type(DBSpatial.IsEnabled) == "function" and DBSpatial.IsEnabled()
    spatialToggle.Text = active and "关闭空间模式" or "开启空间模式"
    spatialToggle.BackgroundColor3 = active and Color3.fromRGB(35,94,82) or Color3.fromRGB(38,40,47)
end
refreshSpatialToggle()
spatialToggle.Activated:Connect(function()
    if DBSpatial and type(DBSpatial.SetEnabled) == "function" then
        DBSpatial.SetEnabled(not DBSpatial.IsEnabled())
        task.delay(0.06, refreshSpatialToggle)
    end
end)

local titleCfg = DBTitle.GetConfig()
local titleCard = Instance.new("Frame")
titleCard.Name = "DB_CustomTitleSettings"
titleCard.Size = UDim2.new(1,-12,0,286)
titleCard.BackgroundColor3 = Color3.fromRGB(255,255,255)
titleCard.BackgroundTransparency = 0.84
titleCard.BorderSizePixel = 0
titleCard.LayoutOrder = 7
titleCard.ZIndex = 19
titleCard.Parent = ListScroll
AddCorner(titleCard,11)
local titleStroke = Instance.new("UIStroke")
titleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
titleStroke.Thickness = 0.8
titleStroke.Transparency = 0.56
titleStroke.Color = Color3.fromRGB(255,255,255)
titleStroke.LineJoinMode = Enum.LineJoinMode.Round
titleStroke.Parent = titleCard

local titleName = Instance.new("TextLabel")
titleName.Position = UDim2.fromOffset(10,6)
titleName.Size = UDim2.new(1,-82,0,26)
titleName.BackgroundTransparency = 1
titleName.Text = "头顶宣传框"
titleName.TextColor3 = Color3.fromRGB(255,255,255)
titleName.TextSize = 14
titleName.Font = Enum.Font.GothamBlack
titleName.TextXAlignment = Enum.TextXAlignment.Left
titleName.ZIndex = 21
titleName.Parent = titleCard

local titleSwitch = Instance.new("TextButton")
titleSwitch:SetAttribute("DB_SpatialPreserveBaseVisual",true)
titleSwitch.AnchorPoint = Vector2.new(1,0.5)
titleSwitch.Position = UDim2.new(1,-10,0,20)
titleSwitch.Size = UDim2.fromOffset(48,24)
titleSwitch.BorderSizePixel = 0
titleSwitch.Text = ""
titleSwitch.AutoButtonColor = false
titleSwitch.ZIndex = 22
titleSwitch.Parent = titleCard
AddCorner(titleSwitch,999)
local titleKnob = Instance.new("Frame")
titleKnob.AnchorPoint = Vector2.new(0.5,0.5)
titleKnob.Size = UDim2.fromOffset(19,19)
titleKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
titleKnob.BorderSizePixel = 0
titleKnob.ZIndex = 23
titleKnob.Parent = titleSwitch
AddCorner(titleKnob,999)
local function refreshTitleSwitch()
    local on = DBTitle.GetConfig().Enabled
    titleSwitch.BackgroundColor3 = on and Color3.fromRGB(205,210,220) or Color3.fromRGB(62,65,72)
    titleKnob.Position = on and UDim2.new(1,-12,0.5,0) or UDim2.new(0,12,0.5,0)
end
refreshTitleSwitch()
titleSwitch.Activated:Connect(function()
    DBTitle.SetEnabled(not DBTitle.GetConfig().Enabled)
    refreshTitleSwitch()
end)

local titleEdit = Instance.new("TextBox")
titleEdit.Position = UDim2.fromOffset(10,38)
titleEdit.Size = UDim2.new(1,-20,0,58)
titleEdit.BackgroundColor3 = Color3.fromRGB(22,23,28)
titleEdit.BackgroundTransparency = 0.20
titleEdit.BorderSizePixel = 0
titleEdit.ClearTextOnFocus = false
titleEdit.MultiLine = true
titleEdit.TextWrapped = true
titleEdit.TextXAlignment = Enum.TextXAlignment.Left
titleEdit.TextYAlignment = Enum.TextYAlignment.Top
titleEdit.Text = titleCfg.Line1 .. "\\n" .. titleCfg.Line2
titleEdit.PlaceholderText = "第一行\\n第二行"
titleEdit.TextColor3 = Color3.fromRGB(255,255,255)
titleEdit.PlaceholderColor3 = Color3.fromRGB(150,155,165)
titleEdit.TextSize = 11
titleEdit.Font = Enum.Font.GothamBold
titleEdit.ZIndex = 21
titleEdit.Parent = titleCard
AddCorner(titleEdit,8)
local editPad=Instance.new("UIPadding")
editPad.PaddingLeft=UDim.new(0,8); editPad.PaddingRight=UDim.new(0,8); editPad.PaddingTop=UDim.new(0,6); editPad.Parent=titleEdit

local colorLabel = Instance.new("TextLabel")
colorLabel.Position = UDim2.fromOffset(10,101)
colorLabel.Size = UDim2.new(1,-20,0,18)
colorLabel.BackgroundTransparency = 1
colorLabel.Text = "颜色"
colorLabel.TextColor3 = Color3.fromRGB(235,235,240)
colorLabel.TextSize = 10
colorLabel.Font = Enum.Font.GothamBold
colorLabel.TextXAlignment = Enum.TextXAlignment.Left
colorLabel.ZIndex = 21
colorLabel.Parent = titleCard

local colorScroll = Instance.new("ScrollingFrame")
colorScroll.Position = UDim2.fromOffset(10,120)
colorScroll.Size = UDim2.new(1,-20,0,34)
colorScroll.BackgroundTransparency = 1
colorScroll.BorderSizePixel = 0
colorScroll.ScrollBarThickness = 2
colorScroll.ScrollingDirection = Enum.ScrollingDirection.X
colorScroll.CanvasSize = UDim2.fromOffset(#DBTitle.GetColors()*58,0)
colorScroll.ZIndex = 21
colorScroll.Parent = titleCard
local colorLayout = Instance.new("UIListLayout")
colorLayout.FillDirection = Enum.FillDirection.Horizontal
colorLayout.Padding = UDim.new(0,5)
colorLayout.SortOrder = Enum.SortOrder.LayoutOrder
colorLayout.Parent = colorScroll
for i, mode in ipairs(DBTitle.GetColors()) do
    local b=Instance.new("TextButton")
    b.Size=UDim2.fromOffset(53,28)
    b.BackgroundColor3=Color3.fromRGB(42,44,50)
    b.BackgroundTransparency=0.12
    b.BorderSizePixel=0
    b.Text=mode
    b.TextColor3=Color3.fromRGB(245,245,248)
    b.TextSize=9
    b.Font=Enum.Font.GothamBold
    b.AutoButtonColor=false
    b.LayoutOrder=i
    b.ZIndex=22
    b.Parent=colorScroll
    AddCorner(b,7)
    b.Activated:Connect(function() DBTitle.SetColor(mode) end)
end

local applyTitle = Instance.new("TextButton")
applyTitle.Position = UDim2.fromOffset(10,162)
applyTitle.Size = UDim2.new(1,-20,0,32)
applyTitle.BackgroundColor3 = Color3.fromRGB(42,44,50)
applyTitle.BackgroundTransparency = 0.10
applyTitle.BorderSizePixel = 0
applyTitle.Text = "应用称号"
applyTitle.TextColor3 = Color3.fromRGB(255,255,255)
applyTitle.TextSize = 11
applyTitle.Font = Enum.Font.GothamBlack
applyTitle.AutoButtonColor = false
applyTitle.ZIndex = 22
applyTitle.Parent = titleCard
AddCorner(applyTitle,8)
applyTitle.Activated:Connect(function()
    local text = tostring(titleEdit.Text or "")
    local first, second = text:match("([^\\n]*)\\n?(.*)")
    DBTitle.SetText(first, second)
end)

local syncButton = Instance.new("TextButton")
syncButton.Position = UDim2.fromOffset(10,200)
syncButton.Size = UDim2.new(1,-20,0,30)
syncButton.BackgroundColor3 = Color3.fromRGB(42,44,50)
syncButton.BackgroundTransparency = 0.10
syncButton.BorderSizePixel = 0
syncButton.Text = "重新检测公开同步"
syncButton.TextColor3 = Color3.fromRGB(255,255,255)
syncButton.TextSize = 10
syncButton.Font = Enum.Font.GothamBold
syncButton.AutoButtonColor = false
syncButton.ZIndex = 22
syncButton.Parent = titleCard
AddCorner(syncButton,8)

local titleNote = Instance.new("TextLabel")
titleNote.Position = UDim2.fromOffset(10,236)
titleNote.Size = UDim2.new(1,-20,0,42)
titleNote.BackgroundTransparency = 1
titleNote.TextWrapped = true
local function refreshSyncNote()
    local status, method, remotePath, verified = DBTitle.GetSyncStatus()
    titleNote.Text = "公开同步：" .. tostring(status) .. ((remotePath and remotePath ~= "") and ("\n接口：" .. remotePath) or "")
    titleNote.TextColor3 = verified and Color3.fromRGB(125,235,150) or Color3.fromRGB(190,194,204)
end
titleNote.TextSize = 8
titleNote.Font = Enum.Font.GothamMedium
titleNote.TextXAlignment = Enum.TextXAlignment.Left
titleNote.TextYAlignment = Enum.TextYAlignment.Top
titleNote.ZIndex = 21
titleNote.Parent = titleCard
refreshSyncNote()
syncButton.Activated:Connect(function()
    DBTitle.RetryServerSync()
    task.delay(1.6, refreshSyncNote)
end)

end
local DBAnnouncementUI = {}
local DB_LATEST_ANNOUNCEMENT = [==[
1.UI界边大改
  最新更新少女壁纸随意更改
  会不定更新壁纸内容
  也可以输入壁纸链接进行自定义
  功能栏重新分三行 第一行玩家信息 第二行功能显示 第三行功能选择
2.功能更改:
  DB AI和紧急关停全部删除
  服务器脚本归为一类（脚本合集）
  大肥鱼通用功能持续更新中
  主页好友在线显示删除

永不跑路的脚本
您的最佳选择
作者:大肥鱼
主编写:大肥鱼

3.大肥鱼通用更新:
  新增内置自瞄 距离/FOV/部位/可见性可调
  支持好友/敌人/我方/中立/NPC检测
  新增内置透视 玩家框/名字/血量/距离/类型可选
  透视距离最高支持1000000米
4.UI界面修复:
  6张内置壁纸全部重新适配
  保证面板区域100%填充 不再出现图片黑边
5.功能修复与新增:
  修复大肥鱼飞行无法加载
  修复自瞄/透视无法返回大肥鱼通用
  自瞄FOV和透视新增横向滑动颜色选择
  新增大肥鱼音乐播放器 搜索/筛选/歌单/播放模式
  新增实时音乐频谱和可拖动播放进度条

最近更新缓慢
请求谅解🙏
]==]
function DBAnnouncementUI.Show()
DBClearRightList()
State.CurrentCategory = "公告"
local pageTitle =
Instance.new(
"TextLabel"
)
pageTitle.Size =
UDim2.new(
1,
-12,
0,
24
)
pageTitle.BackgroundTransparency = 1
pageTitle.Text = "公告"
pageTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
pageTitle.TextSize = 15
pageTitle.Font = Enum.Font.GothamBlack
pageTitle.TextXAlignment = Enum.TextXAlignment.Left
pageTitle.LayoutOrder = 1
pageTitle.ZIndex = 20
pageTitle.Parent = ListScroll
local titlePad =
Instance.new(
"UIPadding"
)
titlePad.PaddingLeft =
UDim.new(
0,
8
)
titlePad.Parent =
pageTitle
local card =
Instance.new(
"Frame"
)
card.Size =
UDim2.new(
1,
-12,
0,
430
)
card.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
card.BackgroundTransparency =
0.84
card.BorderSizePixel = 0
card.LayoutOrder = 2
card.ZIndex = 19
card.Parent = ListScroll
AddCorner(
card,
11
)
local cardStroke =
Instance.new(
"UIStroke"
)
cardStroke.ApplyStrokeMode =
Enum.ApplyStrokeMode.Border
cardStroke.Thickness = 0.85
cardStroke.Transparency = 0.50
cardStroke.Color = Color3.fromRGB(255, 255, 255)
cardStroke.LineJoinMode = Enum.LineJoinMode.Round
cardStroke.Parent = card
local header =
Instance.new(
"TextLabel"
)
header.Position =
UDim2.fromOffset(
14,
9
)
header.Size =
UDim2.new(
1,
-28,
0,
28
)
header.BackgroundTransparency = 1
header.Text = "公告"
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.TextSize = 17
header.Font = Enum.Font.GothamBlack
header.TextXAlignment = Enum.TextXAlignment.Left
header.ZIndex = 20
header.Parent = card
local line =
Instance.new(
"Frame"
)
line.Position =
UDim2.fromOffset(
14,
40
)
line.Size =
UDim2.new(
1,
-28,
0,
1
)
line.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
line.BackgroundTransparency = 0.70
line.BorderSizePixel = 0
line.ZIndex = 20
line.Parent = card
local content =
Instance.new(
"TextLabel"
)
content.Position =
UDim2.fromOffset(
14,
50
)
content.Size =
UDim2.new(
1,
-28,
1,
-62
)
content.BackgroundTransparency = 1
content.Text = DB_LATEST_ANNOUNCEMENT
content.TextColor3 = Color3.fromRGB(255, 255, 255)
content.TextSize = 12
content.Font = Enum.Font.GothamMedium
content.TextWrapped = true
content.TextXAlignment = Enum.TextXAlignment.Left
content.TextYAlignment = Enum.TextYAlignment.Top
content.ZIndex = 20
content.Parent = card
end
local RenderRightList
local DBCombat =
(function()
local api = {}
local RunService =
game:GetService(
"RunService"
)
local UIS =
game:GetService(
"UserInputService"
)
local STUDS_PER_METER =
3.5714285714
local aim = {
Enabled = false,
MaxDistance = 1000,
FOVRadius = 130,
ShowFOV = true,
Visibility = true,
AliveOnly = true,
TargetPart = "头部",
Smoothness = 0.24,
FOVColor = Color3.fromRGB(255,255,255),
Enemy = true,
Teammate = false,
Friend = false,
Neutral = true,
NPC = true,
}
local esp = {
Enabled = false,
MaxDistance = 1500,
AliveOnly = true,
Enemy = true,
Teammate = true,
Friend = true,
Neutral = true,
NPC = true,
Box = true,
Name = true,
Health = true,
Distance = true,
Type = true,
TeamColors = true,
ESPColor = Color3.fromRGB(255,255,255),
}
local friendCache = {}
local npcCache = {}
local espObjects = {}
local lastNpcScan = 0
local lastEspStep = 0
local renderConnection = nil
local destroyed = false
local fov =
Instance.new(
"Frame"
)
fov.Name =
"DB_Aimbot_FOV"
fov.AnchorPoint =
Vector2.new(
0.5,
0.5
)
fov.BackgroundTransparency = 1
fov.BorderSizePixel = 0
fov.Active = false
fov.ZIndex = 950
fov.Visible = false
fov.Parent = MainGui
local fovCorner =
Instance.new(
"UICorner"
)
fovCorner.CornerRadius =
UDim.new(
1,
0
)
fovCorner.Parent =
fov
local fovStroke =
Instance.new(
"UIStroke"
)
fovStroke.ApplyStrokeMode =
Enum.ApplyStrokeMode.Border
fovStroke.Thickness = 1.4
fovStroke.Transparency = 0.12
fovStroke.Color =
Color3.fromRGB(
255,
255,
255
)
fovStroke.Parent =
fov
local function getHumanoid(model)
if not model then
return nil
end
return model:FindFirstChildOfClass(
"Humanoid"
)
end
local function getRoot(model)
if not model then
return nil
end
return
model:FindFirstChild(
"HumanoidRootPart"
)
or model:FindFirstChild(
"UpperTorso"
)
or model:FindFirstChild(
"Torso"
)
end
local function alive(model)
local humanoid =
getHumanoid(
model
)
return
humanoid
and humanoid.Health > 0
end
local function distanceMeters(model)
local myCharacter =
LocalPlayer.Character
local myRoot =
getRoot(
myCharacter
)
local targetRoot =
getRoot(
model
)
if not myRoot
or not targetRoot then
return math.huge
end
return
(
myRoot.Position
- targetRoot.Position
).Magnitude
/ STUDS_PER_METER
end
local function isFriend(player)
if not player
or player == LocalPlayer then
return false
end
local cached =
friendCache[
player.UserId
]
if cached ~= nil then
return cached
end
local result = false
pcall(function()
result =
LocalPlayer:IsFriendsWith(
player.UserId
)
end)
friendCache[
player.UserId
] =
result
return result
end
local function classifyPlayer(player)
if isFriend(
player
) then
return "好友"
end
local myTeam =
LocalPlayer.Team
local theirTeam =
player
and player.Team
if myTeam
and theirTeam then
if myTeam
== theirTeam then
return "我方"
end
return "敌人"
end
return "中立"
end
local function allowed(
kind,
config
)
if kind == "敌人" then
return config.Enemy
elseif kind == "我方" then
return config.Teammate
elseif kind == "好友" then
return config.Friend
elseif kind == "NPC" then
return config.NPC
end
return config.Neutral
end
local function kindColor(kind)
if kind == "敌人" then
return Color3.fromRGB(
255,
92,
92
)
elseif kind == "我方" then
return Color3.fromRGB(
90,
255,
130
)
elseif kind == "好友" then
return Color3.fromRGB(
90,
220,
255
)
elseif kind == "NPC" then
return Color3.fromRGB(
255,
220,
92
)
end
return Color3.fromRGB(
255,
255,
255
)
end
local function scanNPCs()
if os.clock()
- lastNpcScan < 1.35 then
return
end
lastNpcScan =
os.clock()
table.clear(
npcCache
)
local count = 0
for _,
obj in ipairs(
workspace:GetDescendants()
) do
if obj:IsA(
"Humanoid"
) then
local model =
obj.Parent
if model
and model:IsA(
"Model"
)
and not Players:GetPlayerFromCharacter(
model
)
and getRoot(
model
) then
count =
count + 1
npcCache[
count
] =
model
if count >= 160 then
break
end
end
end
end
end
local function entities(
includeNPC
)
local result = {}
for _,
player in ipairs(
Players:GetPlayers()
) do
if player
~= LocalPlayer
and player.Character then
result[
#result + 1
] = {
Model =
player.Character,
Player =
player,
Kind =
classifyPlayer(
player
)
}
end
end
if includeNPC then
scanNPCs()
for _,
model in ipairs(
npcCache
) do
if model
and model.Parent then
result[
#result + 1
] = {
Model =
model,
Player =
nil,
Kind =
"NPC"
}
end
end
end
return result
end
local function fixedPart(
model,
mode
)
if mode == "头部" then
return
model:FindFirstChild(
"Head"
)
or getRoot(
model
)
elseif mode == "胸部" then
return
model:FindFirstChild(
"UpperTorso"
)
or model:FindFirstChild(
"Torso"
)
or getRoot(
model
)
elseif mode == "腰部" then
return
model:FindFirstChild(
"HumanoidRootPart"
)
or getRoot(
model
)
end
return nil
end
local function targetPart(
model,
mode,
camera,
center
)
local fixed =
fixedPart(
model,
mode
)
if fixed then
return fixed
end
local candidates = {
model:FindFirstChild(
"Head"
),
model:FindFirstChild(
"UpperTorso"
),
model:FindFirstChild(
"Torso"
),
model:FindFirstChild(
"HumanoidRootPart"
),
}
local best = nil
local bestDistance =
math.huge
for _,
part in ipairs(
candidates
) do
if part
and part:IsA(
"BasePart"
) then
local screen,
visible =
camera:WorldToViewportPoint(
part.Position
)
if visible
and screen.Z > 0 then
local d =
(
Vector2.new(
screen.X,
screen.Y
)
- center
).Magnitude
if d
< bestDistance then
bestDistance = d
best = part
end
end
end
end
return
best
or getRoot(
model
)
end
local function canSee(
model,
part,
camera
)
local params =
RaycastParams.new()
params.FilterType =
Enum.RaycastFilterType.Exclude
local ignore = {}
if LocalPlayer.Character then
ignore[
#ignore + 1
] =
LocalPlayer.Character
end
ignore[
#ignore + 1
] =
model
params.FilterDescendantsInstances =
ignore
local origin =
camera.CFrame.Position
local direction =
part.Position
- origin
local hit =
workspace:Raycast(
origin,
direction,
params
)
return hit == nil
end
local function bestAimTarget()
local camera =
workspace.CurrentCamera
if not camera then
return nil
end
local vp =
camera.ViewportSize
local center =
Vector2.new(
vp.X / 2,
vp.Y / 2
)
local bestPart = nil
local bestScreenDistance =
math.huge
for _,
entity in ipairs(
entities(
aim.NPC
)
) do
local model =
entity.Model
if allowed(
entity.Kind,
aim
)
and (
not aim.AliveOnly
or alive(
model
)
) then
local meters =
distanceMeters(
model
)
if meters
<= aim.MaxDistance then
local part =
targetPart(
model,
aim.TargetPart,
camera,
center
)
if part then
local screen,
onScreen =
camera:WorldToViewportPoint(
part.Position
)
if onScreen
and screen.Z > 0 then
local screenDistance =
(
Vector2.new(
screen.X,
screen.Y
)
- center
).Magnitude
if screenDistance
<= aim.FOVRadius
and screenDistance
< bestScreenDistance
and (
not aim.Visibility
or canSee(
model,
part,
camera
)
) then
bestScreenDistance =
screenDistance
bestPart =
part
end
end
end
end
end
end
return bestPart
end
local function createEspObject(model)
local box =
Instance.new(
"Frame"
)
box.Name =
"DB_ESP_Box"
box.BackgroundTransparency = 1
box.BorderSizePixel = 0
box.Active = false
box.Visible = false
box.ZIndex = 930
box.Parent = MainGui
local stroke =
Instance.new(
"UIStroke"
)
stroke.Name =
"BoxStroke"
stroke.ApplyStrokeMode =
Enum.ApplyStrokeMode.Border
stroke.Thickness = 1.25
stroke.Transparency = 0.08
stroke.Parent = box
local name =
Instance.new(
"TextLabel"
)
name.Name =
"NameLabel"
name.AnchorPoint =
Vector2.new(
0,
1
)
name.Position =
UDim2.fromOffset(
0,
-3
)
name.Size =
UDim2.new(
1,
0,
0,
18
)
name.BackgroundTransparency = 1
name.TextColor3 = Color3.fromRGB(255, 255, 255)
name.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
name.TextStrokeTransparency = 0.25
name.TextSize = 12
name.Font = Enum.Font.GothamBlack
name.TextXAlignment = Enum.TextXAlignment.Center
name.ZIndex = 932
name.Parent = box
local info =
Instance.new(
"TextLabel"
)
info.Name =
"InfoLabel"
info.Position =
UDim2.new(
0,
0,
1,
3
)
info.Size =
UDim2.new(
1,
0,
0,
18
)
info.BackgroundTransparency = 1
info.TextColor3 = Color3.fromRGB(255, 255, 255)
info.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
info.TextStrokeTransparency = 0.25
info.TextSize = 11
info.Font = Enum.Font.GothamBold
info.TextXAlignment = Enum.TextXAlignment.Center
info.ZIndex = 932
info.Parent = box
local healthBack =
Instance.new(
"Frame"
)
healthBack.Name =
"HealthBack"
healthBack.AnchorPoint =
Vector2.new(
1,
0
)
healthBack.Position =
UDim2.fromOffset(
-4,
0
)
healthBack.Size =
UDim2.new(
0,
3,
1,
0
)
healthBack.BackgroundColor3 =
Color3.fromRGB(
0,
0,
0
)
healthBack.BackgroundTransparency =
0.35
healthBack.BorderSizePixel = 0
healthBack.ZIndex = 932
healthBack.Parent = box
local health =
Instance.new(
"Frame"
)
health.Name =
"HealthFill"
health.AnchorPoint =
Vector2.new(
0,
1
)
health.Position =
UDim2.fromScale(
0,
1
)
health.Size =
UDim2.fromScale(
1,
1
)
health.BackgroundColor3 =
Color3.fromRGB(
100,
255,
120
)
health.BorderSizePixel = 0
health.ZIndex = 933
health.Parent = healthBack
local result = {
Model = model,
Box = box,
Stroke = stroke,
Name = name,
Info = info,
HealthBack = healthBack,
Health = health,
}
espObjects[
model
] =
result
return result
end
local function getEspObject(model)
local obj =
espObjects[
model
]
if obj
and obj.Box
and obj.Box.Parent then
return obj
end
return
createEspObject(
model
)
end
local function screenBounds(
model,
camera
)
local ok,
cf,
size =
pcall(function()
local c,
s =
model:GetBoundingBox()
return c,
s
end)
if not ok
or not cf
or not size then
return nil
end
local hx =
size.X / 2
local hy =
size.Y / 2
local hz =
size.Z / 2
local minX =
math.huge
local minY =
math.huge
local maxX =
-math.huge
local maxY =
-math.huge
local any = false
for _,
x in ipairs({
-hx,
hx
}) do
for _,
y in ipairs({
-hy,
hy
}) do
for _,
z in ipairs({
-hz,
hz
}) do
local world =
cf:PointToWorldSpace(
Vector3.new(
x,
y,
z
)
)
local screen =
camera:WorldToViewportPoint(
world
)
if screen.Z > 0 then
any = true
minX =
math.min(
minX,
screen.X
)
minY =
math.min(
minY,
screen.Y
)
maxX =
math.max(
maxX,
screen.X
)
maxY =
math.max(
maxY,
screen.Y
)
end
end
end
end
if not any then
return nil
end
if maxX < 0
or maxY < 0
or minX > camera.ViewportSize.X
or minY > camera.ViewportSize.Y then
return nil
end
local width =
math.max(
8,
maxX - minX
)
local height =
math.max(
12,
maxY - minY
)
return minX,
minY,
width,
height
end
local function updateESP()
if not esp.Enabled then
for _,
obj in pairs(
espObjects
) do
if obj.Box then
obj.Box.Visible =
false
end
end
return
end
local camera =
workspace.CurrentCamera
if not camera then
return
end
local live = {}
for _,
entity in ipairs(
entities(
esp.NPC
)
) do
local model =
entity.Model
if allowed(
entity.Kind,
esp
)
and (
not esp.AliveOnly
or alive(
model
)
) then
local meters =
distanceMeters(
model
)
if meters
<= esp.MaxDistance then
local x,
y,
w,
h =
screenBounds(
model,
camera
)
if x then
live[
model
] =
true
local obj =
getEspObject(
model
)
local color =
esp.TeamColors
and kindColor(
entity.Kind
)
or esp.ESPColor
obj.Box.Position =
UDim2.fromOffset(
x,
y
)
obj.Box.Size =
UDim2.fromOffset(
w,
h
)
obj.Box.Visible =
true
obj.Stroke.Enabled =
esp.Box
obj.Stroke.Color =
color
obj.Name.TextColor3 =
color
obj.Info.TextColor3 =
color
local player =
entity.Player
if player then
obj.Name.Text =
player.DisplayName
.. " (@"
.. player.Name
.. ")"
else
obj.Name.Text =
model.Name
end
obj.Name.Visible =
esp.Name
local humanoid =
getHumanoid(
model
)
local infoParts = {}
if esp.Health
and humanoid then
infoParts[
#infoParts + 1
] =
"HP "
.. tostring(
math.floor(
humanoid.Health
+ 0.5
)
)
.. "/"
.. tostring(
math.floor(
humanoid.MaxHealth
+ 0.5
)
)
end
if esp.Distance then
infoParts[
#infoParts + 1
] =
tostring(
math.floor(
meters
+ 0.5
)
)
.. "m"
end
if esp.Type then
infoParts[
#infoParts + 1
] =
entity.Kind
end
obj.Info.Text =
table.concat(
infoParts,
"  |  "
)
obj.Info.Visible =
(
esp.Health
or esp.Distance
or esp.Type
)
obj.HealthBack.Visible =
esp.Health
and humanoid ~= nil
if humanoid then
local ratio =
math.clamp(
humanoid.Health
/ math.max(
1,
humanoid.MaxHealth
),
0,
1
)
obj.Health.Size =
UDim2.fromScale(
1,
ratio
)
obj.Health.BackgroundColor3 =
Color3.fromRGB(
math.floor(
255
* (
1 - ratio
)
),
math.floor(
255
* ratio
),
70
)
end
end
end
end
end
for model,
obj in pairs(
espObjects
) do
if not live[
model
] then
if obj.Box then
obj.Box.Visible =
false
end
if not model.Parent then
if obj.Box then
obj.Box:Destroy()
end
espObjects[
model
] =
nil
end
end
end
end
local function clearPage()
DBClearRightList()
ListScroll.CanvasPosition =
Vector2.new(
0,
0
)
end
local function rowFrame(
height,
order
)
local row =
Instance.new(
"Frame"
)
DBApplyRightFullWidthButton(
row,
height
)
row.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
row.BackgroundTransparency =
0.84
row.BorderSizePixel = 0
row.LayoutOrder = order
row.ZIndex = 20
row.Parent = ListScroll
AddCorner(
row,
9
)
local stroke =
Instance.new(
"UIStroke"
)
stroke.ApplyStrokeMode =
Enum.ApplyStrokeMode.Border
stroke.Thickness = 0.75
stroke.Transparency = 0.62
stroke.Color =
Color3.fromRGB(
255,
255,
255
)
stroke.Parent = row
return row
end
local function title(
textValue,
order
)
local label =
Instance.new(
"TextLabel"
)
label.Size =
UDim2.new(
1,
-12,
0,
24
)
label.BackgroundTransparency = 1
label.Text = textValue
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextSize = 15
label.Font = Enum.Font.GothamBlack
label.TextXAlignment = Enum.TextXAlignment.Left
label.LayoutOrder = order
label.ZIndex = 20
label.Parent = ListScroll
local pad =
Instance.new(
"UIPadding"
)
pad.PaddingLeft =
UDim.new(
0,
8
)
pad.Parent = label
end
local function backButton(
order
)
local btn =
Instance.new(
"TextButton"
)
DBApplyRightFullWidthButton(
btn,
30
)
btn.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
btn.BackgroundTransparency =
0.82
btn.BorderSizePixel = 0
btn.Text = "←  返回大肥鱼通用"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextSize = 12
btn.Font = Enum.Font.GothamBlack
btn.TextXAlignment = Enum.TextXAlignment.Left
btn.AutoButtonColor = false
btn.LayoutOrder = order
btn.ZIndex = 20
StyleLiquidButton(
btn,
9,
false
)
local pad =
Instance.new(
"UIPadding"
)
pad.PaddingLeft =
UDim.new(
0,
12
)
pad.Parent = btn
ApplySafeClickEffect(
btn,
function()
State.CurrentCategory =
"大肥鱼通用"
RenderRightList(
"大肥鱼通用"
)
end
)
btn.Parent =
ListScroll
end
local function toggle(
labelText,
config,
key,
order
)
local row =
rowFrame(
30,
order
)
local label =
Instance.new(
"TextLabel"
)
label.Position =
UDim2.fromOffset(
10,
0
)
label.Size =
UDim2.new(
1,
-70,
1,
0
)
label.BackgroundTransparency = 1
label.Text = labelText
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextSize = 12
label.Font = Enum.Font.GothamBold
label.TextXAlignment = Enum.TextXAlignment.Left
label.ZIndex = 21
label.Parent = row
local switch =
Instance.new(
"TextButton"
)
switch.AnchorPoint =
Vector2.new(
1,
0.5
)
switch.Position =
UDim2.new(
1,
-8,
0.5,
0
)
switch.Size =
UDim2.fromOffset(
48,
22
)
switch.BorderSizePixel = 0
switch.Text = ""
switch.AutoButtonColor = false
switch.ZIndex = 22
switch.Parent = row
AddCorner(
switch,
99
)
local dot =
Instance.new(
"Frame"
)
dot.AnchorPoint =
Vector2.new(
0.5,
0.5
)
dot.Size =
UDim2.fromOffset(
16,
16
)
dot.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
dot.BorderSizePixel = 0
dot.ZIndex = 23
dot.Parent = switch
AddCorner(
dot,
99
)
local function refresh()
local on =
config[
key
]
switch.BackgroundColor3 =
on
and Color3.fromRGB(
235,
235,
240
)
or Color3.fromRGB(
105,
105,
112
)
switch.BackgroundTransparency =
on
and 0.38
or 0.55
dot.Position =
on
and UDim2.new(
1,
-11,
0.5,
0
)
or UDim2.new(
0,
11,
0.5,
0
)
end
refresh()
switch.Activated:Connect(function()
config[
key
] =
not config[
key
]
TweenService:Create(
dot,
TweenInfo.new(
0.14,
Enum.EasingStyle.Quad,
Enum.EasingDirection.Out
),
{
Position =
config[key]
and UDim2.new(
1,
-11,
0.5,
0
)
or UDim2.new(
0,
11,
0.5,
0
)
}
):Play()
refresh()
end)
return row
end
local function numberInput(
labelText,
config,
key,
minimum,
maximum,
order,
suffix
)
local row =
rowFrame(
34,
order
)
local label =
Instance.new(
"TextLabel"
)
label.Position =
UDim2.fromOffset(
10,
0
)
label.Size =
UDim2.new(
0.48,
-10,
1,
0
)
label.BackgroundTransparency = 1
label.Text =
labelText
label.TextColor3 =
Color3.fromRGB(
255,
255,
255
)
label.TextSize = 11
label.Font = Enum.Font.GothamBold
label.TextXAlignment = Enum.TextXAlignment.Left
label.ZIndex = 21
label.Parent = row
local box =
Instance.new(
"TextBox"
)
box.AnchorPoint =
Vector2.new(
1,
0.5
)
box.Position =
UDim2.new(
1,
-54,
0.5,
0
)
box.Size =
UDim2.new(
0.34,
0,
0,
24
)
box.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
box.BackgroundTransparency =
0.82
box.BorderSizePixel = 0
box.ClearTextOnFocus = false
box.Text =
tostring(
config[
key
]
)
box.TextColor3 =
Color3.fromRGB(
255,
255,
255
)
box.TextSize = 11
box.Font = Enum.Font.GothamBlack
box.ZIndex = 22
box.Parent = row
AddCorner(
box,
7
)
local apply =
Instance.new(
"TextButton"
)
apply.AnchorPoint =
Vector2.new(
1,
0.5
)
apply.Position =
UDim2.new(
1,
-8,
0.5,
0
)
apply.Size =
UDim2.fromOffset(
40,
24
)
apply.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
apply.BackgroundTransparency =
0.78
apply.BorderSizePixel = 0
apply.Text = "应用"
apply.TextColor3 = Color3.fromRGB(255, 255, 255)
apply.TextSize = 10
apply.Font = Enum.Font.GothamBlack
apply.AutoButtonColor = false
apply.ZIndex = 22
apply.Parent = row
StyleLiquidButton(
apply,
7,
false
)
apply.Activated:Connect(function()
local value =
tonumber(
box.Text
)
if not value then
box.Text =
tostring(
config[
key
]
)
return
end
value =
math.clamp(
value,
minimum,
maximum
)
config[
key
] =
value
box.Text =
tostring(
value
)
if suffix then
label.Text =
labelText
end
end)
return row
end
local function cycle(
labelText,
config,
key,
values,
order
)
local row =
rowFrame(
32,
order
)
local label =
Instance.new(
"TextLabel"
)
label.Position =
UDim2.fromOffset(
10,
0
)
label.Size =
UDim2.new(
0.55,
0,
1,
0
)
label.BackgroundTransparency = 1
label.Text = labelText
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextSize = 11
label.Font = Enum.Font.GothamBold
label.TextXAlignment = Enum.TextXAlignment.Left
label.ZIndex = 21
label.Parent = row
local btn =
Instance.new(
"TextButton"
)
btn.AnchorPoint =
Vector2.new(
1,
0.5
)
btn.Position =
UDim2.new(
1,
-8,
0.5,
0
)
btn.Size =
UDim2.new(
0.38,
0,
0,
24
)
btn.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
btn.BackgroundTransparency =
0.82
btn.BorderSizePixel = 0
btn.Text =
tostring(
config[
key
]
)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextSize = 10
btn.Font = Enum.Font.GothamBlack
btn.AutoButtonColor = false
btn.ZIndex = 22
btn.Parent = row
StyleLiquidButton(
btn,
7,
false
)
btn.Activated:Connect(function()
local current =
config[
key
]
local index = 1
for i,
value in ipairs(
values
) do
if value
== current then
index = i
break
end
end
index =
index % #values
+ 1
config[
key
] =
values[
index
]
btn.Text =
tostring(
config[
key
]
)
end)
return row
end
local function slider(
labelText,
config,
key,
minimum,
maximum,
order,
integer
)
local row =
rowFrame(
46,
order
)
local label =
Instance.new(
"TextLabel"
)
label.Position =
UDim2.fromOffset(
10,
2
)
label.Size =
UDim2.new(
1,
-20,
0,
18
)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextSize = 11
label.Font = Enum.Font.GothamBold
label.TextXAlignment = Enum.TextXAlignment.Left
label.ZIndex = 21
label.Parent = row
local bar =
Instance.new(
"Frame"
)
bar.Position =
UDim2.new(
0,
12,
0,
31
)
bar.Size =
UDim2.new(
1,
-24,
0,
5
)
bar.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
bar.BackgroundTransparency =
0.68
bar.BorderSizePixel = 0
bar.Active = true
bar.ZIndex = 22
bar.Parent = row
AddCorner(
bar,
99
)
local fill =
Instance.new(
"Frame"
)
fill.Size =
UDim2.fromScale(
0,
1
)
fill.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
fill.BackgroundTransparency =
0.12
fill.BorderSizePixel = 0
fill.ZIndex = 23
fill.Parent = bar
AddCorner(
fill,
99
)
local knob =
Instance.new(
"Frame"
)
knob.AnchorPoint =
Vector2.new(
0.5,
0.5
)
knob.Size =
UDim2.fromOffset(
14,
14
)
knob.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
knob.BorderSizePixel = 0
knob.ZIndex = 24
knob.Parent = bar
AddCorner(
knob,
99
)
local dragging = false
local dragInput = nil
local function refresh()
local value =
math.clamp(
config[
key
],
minimum,
maximum
)
local ratio =
(
value
- minimum
)
/ (
maximum
- minimum
)
fill.Size =
UDim2.fromScale(
ratio,
1
)
knob.Position =
UDim2.fromScale(
ratio,
0.5
)
local shown =
integer
and math.floor(
value
+ 0.5
)
or math.floor(
value
* 100
+ 0.5
)
/ 100
label.Text =
labelText
.. "："
.. tostring(
shown
)
end
local function setFromInput(pos)
if not bar.Parent then
return
end
local x = DBSpatial and DBSpatial.InputAxis and DBSpatial.InputAxis(bar, pos, "X") or (pos and pos.X)
if not x then return end
local ratio =
math.clamp(
(
x
- bar.AbsolutePosition.X
)
/ math.max(
1,
bar.AbsoluteSize.X
),
0,
1
)
local value =
minimum
+ (
maximum
- minimum
)
* ratio
if integer then
value =
math.floor(
value
+ 0.5
)
end
config[
key
] =
value
refresh()
end
refresh()
bar.InputBegan:Connect(function(input)
if input.UserInputType
== Enum.UserInputType.MouseButton1
or input.UserInputType
== Enum.UserInputType.Touch then
dragging = true
dragInput =
input
setFromInput(
input.Position
)
end
end)
UIS.InputChanged:Connect(function(input)
if not dragging
or not row.Parent then
return
end
if input.UserInputType
== Enum.UserInputType.MouseMovement
or (
input.UserInputType
== Enum.UserInputType.Touch
and input
== dragInput
) then
setFromInput(
input.Position
)
end
end)
UIS.InputEnded:Connect(function(input)
if input.UserInputType
== Enum.UserInputType.MouseButton1
or input
== dragInput then
dragging = false
dragInput = nil
end
end)
return row
end

local function colorPicker(
labelText,
config,
key,
order
)
local row =
rowFrame(
34,
order
)

local label =
Instance.new(
"TextLabel"
)

label.Position =
UDim2.fromOffset(
10,
0
)

label.Size =
UDim2.new(
0.58,
0,
1,
0
)

label.BackgroundTransparency = 1
label.Text = labelText
label.TextColor3 = Color3.fromRGB(255,255,255)
label.TextSize = 11
label.Font = Enum.Font.GothamBold
label.TextXAlignment = Enum.TextXAlignment.Left
label.ZIndex = 21
label.Parent = row

local button =
Instance.new(
"TextButton"
)

button.AnchorPoint =
Vector2.new(
1,
0.5
)

button.Position =
UDim2.new(
1,
-8,
0.5,
0
)

button.Size =
UDim2.fromOffset(
72,
24
)

button.BackgroundColor3 =
config[key]

button.BackgroundTransparency =
0.12

button.BorderSizePixel = 0
button.Text = "颜色"
button.TextColor3 = Color3.fromRGB(255,255,255)
button.TextStrokeTransparency = 0.4
button.TextSize = 10
button.Font = Enum.Font.GothamBlack
button.AutoButtonColor = false
button.ZIndex = 22
button.Parent = row

StyleLiquidButton(
button,
7,
false
)

local paletteRow =
rowFrame(
0,
order + 1
)

paletteRow.Visible = false
paletteRow.ClipsDescendants = true

local palette =
Instance.new(
"ScrollingFrame"
)

palette.Position =
UDim2.fromOffset(
7,
5
)

palette.Size =
UDim2.new(
1,
-14,
1,
-10
)

palette.BackgroundTransparency = 1
palette.BorderSizePixel = 0
palette.ScrollBarThickness = 2
palette.ScrollingDirection = Enum.ScrollingDirection.X
palette.AutomaticCanvasSize = Enum.AutomaticSize.None
palette.CanvasSize = UDim2.fromOffset(514,0)
palette.ZIndex = 22
palette.Parent = paletteRow

local layout =
Instance.new(
"UIListLayout"
)

layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0,7)
layout.Parent = palette

local pad =
Instance.new(
"UIPadding"
)

pad.PaddingLeft = UDim.new(0,3)
pad.PaddingRight = UDim.new(0,3)
pad.Parent = palette

local colors = {
Color3.fromRGB(255,255,255),
Color3.fromRGB(255,80,80),
Color3.fromRGB(255,135,55),
Color3.fromRGB(255,215,60),
Color3.fromRGB(130,255,85),
Color3.fromRGB(45,235,150),
Color3.fromRGB(65,240,235),
Color3.fromRGB(80,175,255),
Color3.fromRGB(75,100,255),
Color3.fromRGB(135,90,255),
Color3.fromRGB(205,80,255),
Color3.fromRGB(255,80,205),
Color3.fromRGB(255,135,185),
Color3.fromRGB(185,185,195),
Color3.fromRGB(105,105,115),
}

for index,
color in ipairs(
colors
) do
local swatch =
Instance.new(
"TextButton"
)

swatch.Name =
"Color_" .. tostring(index)

swatch.Size =
UDim2.fromOffset(
28,
28
)

swatch.BackgroundColor3 = color
swatch.BackgroundTransparency = 0.03
swatch.BorderSizePixel = 0
swatch.Text = ""
swatch.AutoButtonColor = false
swatch.ZIndex = 23
swatch.Parent = palette

AddCorner(
swatch,
8
)

local swatchStroke =
Instance.new(
"UIStroke"
)

swatchStroke.Thickness = 0.9
swatchStroke.Transparency = 0.36
swatchStroke.Color = Color3.fromRGB(255,255,255)
swatchStroke.Parent = swatch

swatch.Activated:Connect(function()
config[key] = color
button.BackgroundColor3 = color

if config == aim then
fovStroke.Color = color
end
end)
end

button.Activated:Connect(function()
local show =
not paletteRow.Visible

paletteRow.Visible = show
paletteRow.Size =
show
and UDim2.new(
1,
-12,
0,
42
)
or UDim2.new(
1,
-12,
0,
0
)
end)

return row,
paletteRow
end

function api.ShowAimbot()
clearPage()
State.CurrentCategory =
"大肥鱼通用/自瞄"

backButton(1)
title("自瞄", 2)

toggle(
"自瞄总开关",
aim,
"Enabled",
3
)

numberInput(
"最大自瞄距离（米）",
aim,
"MaxDistance",
1,
1000000,
4
)

cycle(
"瞄准部位",
aim,
"TargetPart",
{
"头部",
"胸部",
"腰部",
"最近部位"
},
5
)

slider(
"FOV圈大小",
aim,
"FOVRadius",
35,
520,
6,
true
)

toggle(
"显示FOV圈",
aim,
"ShowFOV",
7
)

colorPicker(
"FOV圈颜色",
aim,
"FOVColor",
8
)

slider(
"瞄准平滑度",
aim,
"Smoothness",
0.05,
1.00,
10,
false
)

toggle(
"可见性检测",
aim,
"Visibility",
11
)

toggle(
"仅锁定存活目标",
aim,
"AliveOnly",
12
)

title(
"目标检测",
13
)

toggle(
"敌人",
aim,
"Enemy",
14
)

toggle(
"我方",
aim,
"Teammate",
15
)

toggle(
"好友",
aim,
"Friend",
16
)

toggle(
"中立玩家",
aim,
"Neutral",
17
)

toggle(
"NPC",
aim,
"NPC",
18
)
end

function api.ShowESP()
clearPage()
State.CurrentCategory =
"大肥鱼通用/透视"

backButton(1)
title("透视", 2)

toggle(
"透视总开关",
esp,
"Enabled",
3
)

numberInput(
"最远透视距离（米）",
esp,
"MaxDistance",
1,
1000000,
4
)

colorPicker(
"透视颜色",
esp,
"ESPColor",
5
)

toggle(
"按阵营自动着色",
esp,
"TeamColors",
7
)

title(
"显示内容",
8
)

toggle(
"玩家框",
esp,
"Box",
9
)

toggle(
"玩家名字",
esp,
"Name",
10
)

toggle(
"血量/血条",
esp,
"Health",
11
)

toggle(
"距离",
esp,
"Distance",
12
)

toggle(
"阵营/类型",
esp,
"Type",
13
)

toggle(
"仅显示存活目标",
esp,
"AliveOnly",
14
)

title(
"目标检测",
15
)

toggle(
"敌人",
esp,
"Enemy",
16
)

toggle(
"我方",
esp,
"Teammate",
17
)

toggle(
"好友",
esp,
"Friend",
18
)

toggle(
"中立玩家",
esp,
"Neutral",
19
)

toggle(
"NPC",
esp,
"NPC",
20
)
end

local function render(dt)
if destroyed then
return
end
local camera =
workspace.CurrentCamera
if camera then
local vp =
camera.ViewportSize
local diameter =
aim.FOVRadius
* 2
fov.Position =
UDim2.fromOffset(
vp.X / 2,
vp.Y / 2
)
fov.Size =
UDim2.fromOffset(
diameter,
diameter
)
fov.Visible =
aim.Enabled
and aim.ShowFOV
fovStroke.Color =
aim.FOVColor
if aim.Enabled
and not UIS:GetFocusedTextBox() then
local part =
bestAimTarget()
if part
and part.Parent then
local desired =
CFrame.lookAt(
camera.CFrame.Position,
part.Position
)
camera.CFrame =
camera.CFrame:Lerp(
desired,
math.clamp(
aim.Smoothness,
0.05,
1
)
)
end
end
end
lastEspStep =
lastEspStep
+ dt
if lastEspStep
>= 0.045 then
lastEspStep = 0
updateESP()
end
end
function api.Destroy()
if destroyed then
return
end
destroyed = true
if renderConnection then
renderConnection:Disconnect()
renderConnection = nil
end
if fov then
fov:Destroy()
end
for _,
obj in pairs(
espObjects
) do
if obj.Box then
obj.Box:Destroy()
end
end
table.clear(
espObjects
)
end
renderConnection =
RunService.RenderStepped:Connect(
render
)
pcall(function()
MainGui.Destroying:Connect(
function()
api.Destroy()
end
)
end)
return api
end)()
RenderRightList = function(categoryName)
HomePanel.Visible = false
if PlayerControlPanel then
PlayerControlPanel.Hide()
end
local oldDetail =
RightList:FindFirstChild(
"DB_ScriptCollectionDetail"
)
if oldDetail then
oldDetail:Destroy()
end
ListScroll.Visible = true
for _, child in ipairs(
ListScroll:GetChildren()
) do
if child:IsA("GuiObject") then
child:Destroy()
end
end
ListScroll.CanvasPosition =
Vector2.new(
0,
0
)
local list = ScriptDatabase[categoryName] or {}
for _, item in ipairs(list) do
local btn = Instance.new("TextButton")
btn.Name = item.Name
DBApplyRightFullWidthButton(
btn,
32
)
btn.BackgroundColor3 = UI.Button
btn.BackgroundTransparency = 0.24
btn.BorderSizePixel = 0
btn.Text = item.Name
btn.TextColor3 = UI.Text
btn.TextTransparency = 0
btn.TextSize = 12
btn.Font = Enum.Font.GothamBlack
btn.TextXAlignment = Enum.TextXAlignment.Left
btn.TextTruncate = Enum.TextTruncate.AtEnd
btn.AutoButtonColor = false
btn.ZIndex = 15
StyleLiquidButton(btn, 9, false)
if categoryName == "大肥鱼通用" then
btn.BackgroundColor3 = DBVisualSettings.ButtonBackground
btn.BackgroundTransparency = DBVisualSettings.ButtonTransparency
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextStrokeTransparency = 0.62
end
local pad = Instance.new("UIPadding")
pad.PaddingLeft = UDim.new(0, 12)
pad.PaddingRight = UDim.new(0, 12)
pad.Parent = btn
ApplySafeClickEffect(btn, function()
if item.Page == "Aimbot" then
DBCombat.ShowAimbot()
elseif item.Page == "ESP" then
DBCombat.ShowESP()
else
SafeLoadScript(item)
end
end)
btn.Parent = ListScroll
end
end

local DBMusic = (function()
    local api = {}

    local AssetService = game:GetService("AssetService")
    local SoundService = game:GetService("SoundService")
    local UIS = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local HttpService = game:GetService("HttpService")
    local ContentProvider = game:GetService("ContentProvider")

    local env = _G
    pcall(function()
        if type(getgenv) == "function" then
            env = getgenv()
        end
    end)

    local function currentProvider()
        return env.DBMusicProvider
    end

    local sound = workspace:FindFirstChild("DB_Music_Sound") or SoundService:FindFirstChild("DB_Music_Sound")
    if not sound then
        sound = Instance.new("Sound")
        sound.Name = "DB_Music_Sound"
    end
    sound.Parent = workspace
    sound.Volume = 2.40
    sound.Looped = false
    pcall(function() sound.PlaybackSpeed = 1 end)

    local PLATFORMS = {"全部", "网易云音乐", "QQ音乐", "酷狗音乐", "汽水音乐"}
    local REAL_PLATFORMS = {"网易云音乐", "QQ音乐", "酷狗音乐", "汽水音乐"}
    local FILTERS = {"全部", "单曲", "歌手", "专辑"}
    local PLAYLIST_PATH = "DB_MUSIC_PLAYLISTS.json"
    local CACHE_DIR = "DB_MUSIC_CACHE_V125"

    local state = {
        Platform = "全部",
        Filter = "全部",
        SearchKeyword = "",
        CodeInput = "",
        SearchResults = {},
        SearchToken = 0,
        Searching = false,

        Queue = {},
        QueueIndex = 0,
        CurrentTrack = nil,
        PlayToken = 0,
        ExternalPlaying = false,
        PlayStatus = "待机",
        Mode = "列表循环",
        MusicVolume = 2.40,
        GameVolume = 0.68,
        LastSearchUserEdit = 0,

        Playlists = {{Name = "我的收藏", Tracks = {}}},
        SelectedPlaylist = 1,

        Views = {},
        SearchPopups = {},
        CoverCache = {},
        AudioCache = {},
        AudioAssetOwners = {},
        AudioAssetUrls = {},
        AudioBodyOwners = {},

        AdvancedRoot = nil,
        AdvancedSurface = nil,
        AdvancedSearchBox = nil,
        AdvancedHotHost = nil,
        AdvancedHotPanel = nil,
        AdvancedPlaylistDrawer = nil,
        UpdateAdvancedLayout = nil,
        AdvancedHotIndex = 1,
        AdvancedHotCache = {},
        AdvancedHotLoading = {},
        AdvancedLastSwipe = 0,
        AdvancedVisualExpanded = false,
        AdvancedCarouselToken = 0,
        AdvancedOldPanelStrokes = nil,
        AdvancedOldPanelBackgroundTransparency = nil,
        AdvancedOldPanelClipsDescendants = nil,

        MinimizeHandler = nil,
        GameSoundBase = setmetatable({}, {__mode = "k"}),
        GameSoundConnections = setmetatable({}, {__mode = "k"}),
        GameSoundApplying = setmetatable({}, {__mode = "k"}),
        VolumeMixerRoot = nil,
        LastPlaybackError = "",
        PlaybackGeneration = 0,
        Destroyed = false,
        AudioGraph = nil,
        PlaybackBackend = "Sound",
        PlaybackPaused = false,
        PlaybackPausePosition = 0,
        SpectrumSmooth = {},
        SpectrumPrevious = {},
        SpectrumHistory = {},
        SpectrumPeak = {},
        SpectrumDrive = 0.85,
        SpectrumEnergy = 0,
        SpectrumCentroidFloor = 0.10,
        SpectrumCentroidCeil = 0.42,
        SpectrumAmpFloor = 0.035,
        SpectrumAmpCeil = 0.42,
        SpectrumPitchFloor = 0.06,
        SpectrumPitchCeil = 0.56,
        SpectrumGlobalPeak = 0.0025,
        SpectrumFallbackPhase = 0,
        SpectrumTrackKey = nil,
        LastVerifiedTrackId = nil,
        LastVerifiedDuration = 0,
    }

    sound.Volume = state.MusicVolume

    state.AudioGraph = {Available = false}
    pcall(function()
        for _, name in ipairs({"DB_Music_AudioPlayer", "DB_Music_AudioOutput", "DB_Music_AudioAnalyzer", "DB_Music_AudioWireOut", "DB_Music_AudioWireAnalyzer"}) do
            local old = workspace:FindFirstChild(name)
            if old then old:Destroy() end
        end
        local player = Instance.new("AudioPlayer")
        player.Name = "DB_Music_AudioPlayer"
        player.AutoLoad = true
        player.Volume = state.MusicVolume
        player.Looping = false
        player.Parent = workspace

        local output = Instance.new("AudioDeviceOutput")
        output.Name = "DB_Music_AudioOutput"
        output.Parent = workspace

        local analyzer = Instance.new("AudioAnalyzer")
        analyzer.Name = "DB_Music_AudioAnalyzer"
        analyzer.SpectrumEnabled = true
        pcall(function() analyzer.WindowSize = Enum.AudioWindowSize.Medium end)
        analyzer.Parent = workspace

        local wireOut = Instance.new("Wire")
        wireOut.Name = "DB_Music_AudioWireOut"
        wireOut.SourceInstance = player
        wireOut.TargetInstance = output
        wireOut.Parent = workspace

        local wireAnalyzer = Instance.new("Wire")
        wireAnalyzer.Name = "DB_Music_AudioWireAnalyzer"
        wireAnalyzer.SourceInstance = player
        wireAnalyzer.TargetInstance = analyzer
        wireAnalyzer.Parent = workspace

        state.AudioGraph = {
            Available = true,
            Player = player,
            Output = output,
            Analyzer = analyzer,
            WireOut = wireOut,
            WireAnalyzer = wireAnalyzer,
        }
    end)

    state.Playback = {}
    function state.Playback.IsPlaying()
        if state.PlaybackBackend == "AudioPlayer" and state.AudioGraph and state.AudioGraph.Player then
            local ok, value = pcall(function() return state.AudioGraph.Player.IsPlaying end)
            return ok and value == true
        end
        local ok, value = pcall(function() return sound.IsPlaying end)
        return ok and value == true
    end
    function state.Playback.TimeLength()
        if state.PlaybackBackend == "AudioPlayer" and state.AudioGraph and state.AudioGraph.Player then
            local ok, value = pcall(function() return tonumber(state.AudioGraph.Player.TimeLength) or 0 end)
            return ok and value or 0
        end
        local ok, value = pcall(function() return tonumber(sound.TimeLength) or 0 end)
        return ok and value or 0
    end
    function state.Playback.TimePosition()
        if state.PlaybackBackend == "AudioPlayer" and state.AudioGraph and state.AudioGraph.Player then
            local ok, value = pcall(function() return tonumber(state.AudioGraph.Player.TimePosition) or 0 end)
            return ok and value or 0
        end
        local ok, value = pcall(function() return tonumber(sound.TimePosition) or 0 end)
        return ok and value or 0
    end
    function state.Playback.Seek(value)
        value = math.max(0, tonumber(value) or 0)
        if state.PlaybackBackend == "AudioPlayer" and state.AudioGraph and state.AudioGraph.Player then
            pcall(function() state.AudioGraph.Player.TimePosition = value end)
        else
            pcall(function() sound.TimePosition = value end)
        end
    end
    function state.Playback.Stop(clearAsset)
        state.PlaybackPaused = false
        state.PlaybackPausePosition = 0
        if state.AudioGraph and state.AudioGraph.Player then
            pcall(function()
                state.AudioGraph.Player:Stop()
                state.AudioGraph.Player.TimePosition = 0
                state.AudioGraph.Player.Looping = false
                if clearAsset then
                    pcall(function() state.AudioGraph.Player.Asset = "" end)
                    pcall(function() state.AudioGraph.Player.AssetId = "" end)
                end
            end)
        end
        pcall(function()
            sound:Stop()
            sound.TimePosition = 0
            sound.Looped = false
            if clearAsset then sound.SoundId = "" end
        end)
    end
    function state.Playback.Pause()
        state.PlaybackPaused = true
        if state.PlaybackBackend == "AudioPlayer" and state.AudioGraph and state.AudioGraph.Player then
            local player = state.AudioGraph.Player
            local pos = 0
            pcall(function() pos = tonumber(player.TimePosition) or 0 end)
            state.PlaybackPausePosition = pos
            pcall(function() player:Stop() end)
            pcall(function()
                if math.abs((tonumber(player.TimePosition) or pos) - pos) > 0.08 then
                    player.TimePosition = pos
                end
            end)
        else
            local pos = 0
            pcall(function() pos = tonumber(sound.TimePosition) or 0 end)
            state.PlaybackPausePosition = pos
            pcall(function() sound:Pause() end)
            task.delay(0.04, function()
                if state.Destroyed or not state.PlaybackPaused or state.PlaybackBackend ~= "Sound" then return end
                local stillPlaying = false
                pcall(function() stillPlaying = sound.IsPlaying == true end)
                if stillPlaying then
                    pcall(function() sound:Stop() end)
                    pcall(function() sound.TimePosition = math.max(0, state.PlaybackPausePosition or pos) end)
                end
            end)
        end
    end
    function state.Playback.Resume()
        if state.PlaybackBackend == "AudioPlayer" and state.AudioGraph and state.AudioGraph.Player then
            local player = state.AudioGraph.Player
            pcall(function()
                player.TimePosition = math.max(0, state.PlaybackPausePosition or player.TimePosition or 0)
                player:Play()
            end)
        else
            local pos = math.max(0, tonumber(state.PlaybackPausePosition) or 0)
            pcall(function() sound.TimePosition = pos end)
            local resumed = pcall(function() sound:Resume() end)
            if not resumed then pcall(function() sound:Play() end) end
            task.delay(0.05, function()
                if state.Destroyed or state.PlaybackPaused then return end
                local playing = false
                pcall(function() playing = sound.IsPlaying == true end)
                if not playing then
                    pcall(function() sound.TimePosition = pos end)
                    pcall(function() sound:Play() end)
                end
            end)
        end
        state.PlaybackPaused = false
    end
    function state.Playback.GetSpectrum()
        if state.PlaybackBackend ~= "AudioPlayer" or not state.AudioGraph or not state.AudioGraph.Analyzer then
            return nil
        end
        local ok, spectrum = pcall(function() return state.AudioGraph.Analyzer:GetSpectrum() end)
        if ok and type(spectrum) == "table" and #spectrum > 3 then return spectrum end
        return nil
    end
    function state.Playback.GetRms()
        if state.PlaybackBackend == "AudioPlayer" and state.AudioGraph and state.AudioGraph.Analyzer then
            local ok, rms = pcall(function() return tonumber(state.AudioGraph.Analyzer.RmsLevel) or 0 end)
            if ok then return rms end
        end
        local loud = 0
        pcall(function() loud = tonumber(sound.PlaybackLoudness) or 0 end)
        return math.clamp(loud / 1000, 0, 1)
    end

    local function setMusicVolume(value)
        state.MusicVolume = math.clamp(tonumber(value) or 2.40, 0, 4.0)
        pcall(function() sound.Volume = state.MusicVolume end)
        if state.AudioGraph and state.AudioGraph.Player then
            pcall(function() state.AudioGraph.Player.Volume = state.MusicVolume end)
        end
    end

    local function applyGameSoundVolume(obj)
        if not obj or obj == sound or not obj:IsA("Sound") then
            return
        end
        local base = state.GameSoundBase[obj]
        if base == nil then
            base = tonumber(obj.Volume) or 0.5
            state.GameSoundBase[obj] = base
        end
        state.GameSoundApplying[obj] = true
        pcall(function()
            obj.Volume = math.clamp(base * state.GameVolume, 0, 10)
        end)
        state.GameSoundApplying[obj] = nil
    end

    local function trackGameSound(obj)
        if not obj or obj == sound or not obj:IsA("Sound") then
            return
        end
        if state.GameSoundConnections[obj] then
            applyGameSoundVolume(obj)
            return
        end
        state.GameSoundBase[obj] = tonumber(obj.Volume) or 0.5
        local conn = obj:GetPropertyChangedSignal("Volume"):Connect(function()
            if state.Destroyed or state.GameSoundApplying[obj] then
                return
            end
            local observed = tonumber(obj.Volume) or 0
            if state.GameVolume > 0.001 then
                state.GameSoundBase[obj] = observed / state.GameVolume
            else
                state.GameSoundBase[obj] = observed
            end
            applyGameSoundVolume(obj)
        end)
        state.GameSoundConnections[obj] = conn
        applyGameSoundVolume(obj)
    end

    local function setGameVolume(value)
        state.GameVolume = math.clamp(tonumber(value) or 0.82, 0, 1.0)
        for obj in pairs(state.GameSoundBase) do
            if obj and obj.Parent then
                applyGameSoundVolume(obj)
            end
        end
    end

    task.spawn(function()
        for _, obj in ipairs(game:GetDescendants()) do
            if state.Destroyed then
                return
            end
            if obj:IsA("Sound") and obj ~= sound then
                trackGameSound(obj)
            end
        end
    end)
    game.DescendantAdded:Connect(function(obj)
        if not state.Destroyed and obj:IsA("Sound") and obj ~= sound then
            trackGameSound(obj)
        end
    end)

    local function trim(value)
        return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
    end

    local function lower(value)
        return string.lower(tostring(value or ""))
    end

    local function normalizeSearchText(value)
        local text = lower(value)
        text = text:gsub("的", "")
        text = text:gsub("[%s%c%p]", "")
        text = text:gsub("[，。！？、·：；（）【】《》“”‘’—…]", "")
        return text
    end

    local function splitSearchTokens(value)
        local text = tostring(value or "")
        text = text:gsub("的", " ")
        text = text:gsub("[，,。%.！!？?、/|+&_%-—：:；;（）%(%)【】%[%]《》<>]", " ")
        local out, seen = {}, {}
        for token in text:gmatch("%S+") do
            local key = normalizeSearchText(token)
            if key ~= "" and not seen[key] then
                seen[key] = true
                out[#out + 1] = key
            end
        end
        if #out == 0 then
            local key = normalizeSearchText(value)
            if key ~= "" then out[1] = key end
        end
        return out
    end

    local function canonicalSongIdentity(track)
        if type(track) ~= "table" then return "" end
        return normalizeSearchText(track.Title) .. "|" .. normalizeSearchText(track.Artist)
    end

    local function stableTextHash(value)
        local text = tostring(value or "")
        local hash = 2166136261
        for index = 1, #text do
            hash = (hash * 16777619 + text:byte(index)) % 4294967291
        end
        return string.format("%08x", hash)
    end

    local function formatTime(value)
        value = math.max(0, tonumber(value) or 0)
        return string.format("%02d:%02d", math.floor(value / 60), math.floor(value % 60))
    end

    local function joinArtists(value)
        if type(value) == "string" then
            return value
        end
        if type(value) ~= "table" then
            return ""
        end
        local out = {}
        for _, item in ipairs(value) do
            if type(item) == "table" then
                local name = item.name or item.Name or item.title
                if name and name ~= "" then
                    out[#out + 1] = tostring(name)
                end
            elseif item ~= nil then
                out[#out + 1] = tostring(item)
            end
        end
        return table.concat(out, " / ")
    end

    local function trackIdentity(track)
        if type(track) ~= "table" then
            return ""
        end
        return tostring(track.Platform or "未知")
            .. "|"
            .. tostring(track.Key or track.Id or track.RobloxId or track.Url or track.Title or "")
    end

    local function normalizeTrack(raw, forcedPlatform)
        if type(raw) ~= "table" then
            return nil
        end

        local platform = forcedPlatform
            or raw.Platform
            or raw.Source
            or raw.source
            or raw.provider
            or "Roblox"

        local title = raw.Title or raw.Name or raw.title or raw.name or raw.songName or raw.songname or raw.song_name
        local artist = raw.Artist or raw.artist or raw.Singer or raw.singer or raw.singerName or raw.singername or raw.author_name
        local album = raw.Album or raw.album or raw.AlbumName or raw.albumName or raw.album_name
        local duration = raw.Duration or raw.duration or raw.interval or raw.timelength or 0
        local cover = raw.Cover or raw.cover or raw.CoverUrl or raw.coverUrl or raw.picUrl or raw.img
        local hot = raw.HotScore or raw.hot or raw.score or raw.popularity or raw.heat or raw.playCount or 0

        if type(artist) == "table" then
            artist = joinArtists(artist)
        end

        duration = tonumber(duration) or 0
        if duration > 10000 then
            duration = duration / 1000
        end

        local robloxId = raw.RobloxId
            or raw.AssetId
            or raw.assetId

        if not robloxId and platform == "Roblox" then
            robloxId = raw.Id or raw.id
        end

        if robloxId ~= nil then
            robloxId = tonumber(tostring(robloxId):match("%d+"))
        end

        local key = raw.Key
            or raw.ProviderId
            or raw.providerId
            or raw.SongMid
            or raw.songmid
            or raw.songMid
            or raw.Hash
            or raw.hash
            or raw.Id
            or raw.id
            or robloxId
            or raw.Url
            or raw.url

        if not title or tostring(title) == "" then
            title = key and ("音乐 " .. tostring(key)) or "未知歌曲"
        end

        if not artist or tostring(artist) == "" then
            artist = "未知歌手"
        end

        if not album or tostring(album) == "" then
            album = "未知专辑"
        end

        return {
            Platform = tostring(platform),
            Key = key,
            Id = raw.Id or raw.id,
            RobloxId = robloxId,
            Title = tostring(title),
            Artist = tostring(artist),
            Album = tostring(album),
            Duration = duration,
            Cover = cover and tostring(cover) or nil,
            HotScore = tonumber(hot) or 0,
            PlayableUrl = raw.PlayableUrl or raw.playableUrl or raw.AudioUrl or raw.audioUrl or raw.Url or raw.url,
            ExactPlayable = raw.ExactPlayable == true or raw.exactPlayable == true,
            SongMid = raw.SongMid or raw.songmid or raw.songMid,
            MediaMid = raw.MediaMid or raw.media_mid or raw.mediaMid,
            Hash = raw.Hash or raw.hash,
            AlbumId = raw.AlbumId or raw.album_id or raw.albumid,
            Raw = raw,
        }
    end

    local function serializeTrack(track)
        return {
            Platform = track.Platform,
            Key = track.Key,
            Id = track.Id,
            RobloxId = track.RobloxId,
            Title = track.Title,
            Artist = track.Artist,
            Album = track.Album,
            Duration = track.Duration,
            Cover = track.Cover,
            HotScore = track.HotScore,
            PlayableUrl = track.PlayableUrl,
            ExactPlayable = track.ExactPlayable == true,
            SongMid = track.SongMid,
            MediaMid = track.MediaMid,
            Hash = track.Hash,
            AlbumId = track.AlbumId,
        }
    end

    local function selectedPlaylist()
        if #state.Playlists == 0 then
            state.Playlists[1] = {Name = "我的收藏", Tracks = {}}
            state.SelectedPlaylist = 1
        end
        state.SelectedPlaylist = math.clamp(tonumber(state.SelectedPlaylist) or 1, 1, #state.Playlists)
        return state.Playlists[state.SelectedPlaylist]
    end

    local function cleanPlaylistName(name)
        name = trim(name):gsub("[%c\r\n\t]", " "):gsub("%s+", " ")
        if #name > 24 then name = name:sub(1, 24) end
        return name
    end

    local function clonePlaylistTrack(track)
        if type(track) ~= "table" then return nil end
        return normalizeTrack(serializeTrack(track), track.Platform)
    end

    local function loadPlaylists()
        if type(readfile) ~= "function" or type(isfile) ~= "function" then return end
        local ok, data = pcall(function()
            if not isfile(PLAYLIST_PATH) then return nil end
            return HttpService:JSONDecode(readfile(PLAYLIST_PATH))
        end)
        if not ok or type(data) ~= "table" or type(data.Playlists) ~= "table" then return end

        local loaded, usedNames = {}, {}
        for _, rawList in ipairs(data.Playlists) do
            if type(rawList) == "table" then
                local baseName = cleanPlaylistName(rawList.Name or "未命名歌单")
                if baseName == "" then baseName = "未命名歌单" end
                local name, suffix = baseName, 2
                while usedNames[lower(name)] do
                    name = baseName .. " " .. tostring(suffix)
                    suffix = suffix + 1
                end
                usedNames[lower(name)] = true

                local list = {Name = name, Tracks = {}}
                local seen = {}
                if type(rawList.Tracks) == "table" then
                    for _, rawTrack in ipairs(rawList.Tracks) do
                        local track = normalizeTrack(rawTrack, rawTrack.Platform)
                        local id = track and trackIdentity(track) or ""
                        if track and id ~= "" and not seen[id] then
                            seen[id] = true
                            list.Tracks[#list.Tracks + 1] = track
                            if #list.Tracks >= 500 then break end
                        end
                    end
                end
                loaded[#loaded + 1] = list
                if #loaded >= 40 then break end
            end
        end
        if #loaded > 0 then
            state.Playlists = loaded
            state.SelectedPlaylist = math.clamp(tonumber(data.SelectedPlaylist) or 1, 1, #loaded)
        end
    end

    local function savePlaylists()
        if type(writefile) ~= "function" then return false end
        local payload = {Version = 2, SelectedPlaylist = state.SelectedPlaylist, Playlists = {}}
        for _, list in ipairs(state.Playlists) do
            local out = {Name = cleanPlaylistName(list.Name), Tracks = {}}
            for _, track in ipairs(list.Tracks) do
                out.Tracks[#out.Tracks + 1] = serializeTrack(track)
            end
            payload.Playlists[#payload.Playlists + 1] = out
        end
        local ok = pcall(function()
            writefile(PLAYLIST_PATH, HttpService:JSONEncode(payload))
        end)
        return ok
    end

    loadPlaylists()

    local function playlistNotice(text)
        state.PlayStatus = tostring(text or "")
    end

    local function addToPlaylist(track)
        if not track then return false end
        local list = selectedPlaylist()
        if #list.Tracks >= 500 then
            playlistNotice("当前歌单已达到500首上限")
            return false
        end
        local id = trackIdentity(track)
        for _, existing in ipairs(list.Tracks) do
            if trackIdentity(existing) == id then
                playlistNotice("歌单中已经有这首歌")
                return false
            end
        end
        local copy = clonePlaylistTrack(track)
        if not copy then return false end
        list.Tracks[#list.Tracks + 1] = copy
        savePlaylists()
        playlistNotice("已添加到歌单 · " .. list.Name)
        return true
    end

    local function createPlaylist(name)
        if #state.Playlists >= 40 then playlistNotice("歌单数量已达到40个上限"); return false end
        name = cleanPlaylistName(name)
        if name == "" then playlistNotice("请输入歌单名称"); return false end
        for _, list in ipairs(state.Playlists) do
            if lower(list.Name) == lower(name) then playlistNotice("已经有同名歌单"); return false end
        end
        state.Playlists[#state.Playlists + 1] = {Name = name, Tracks = {}}
        state.SelectedPlaylist = #state.Playlists
        savePlaylists()
        playlistNotice("已创建歌单 · " .. name)
        return true
    end

    local function renameSelectedPlaylist(name)
        name = cleanPlaylistName(name)
        if name == "" then playlistNotice("请输入新名称"); return false end
        for index, list in ipairs(state.Playlists) do
            if index ~= state.SelectedPlaylist and lower(list.Name) == lower(name) then
                playlistNotice("已经有同名歌单")
                return false
            end
        end
        selectedPlaylist().Name = name
        savePlaylists()
        playlistNotice("歌单已重命名")
        return true
    end

    local function deleteSelectedPlaylist()
        local old = selectedPlaylist()
        if state.Queue == old.Tracks then
            state.Playback.Stop(true)
            state.Queue = {}
            state.QueueIndex = 0
            state.CurrentTrack = nil
        end
        if #state.Playlists <= 1 then
            state.Playlists[1] = {Name = "我的收藏", Tracks = {}}
            state.SelectedPlaylist = 1
        else
            table.remove(state.Playlists, state.SelectedPlaylist)
            state.SelectedPlaylist = math.clamp(state.SelectedPlaylist, 1, #state.Playlists)
        end
        savePlaylists()
        playlistNotice("歌单已删除")
    end

    local function clearSelectedPlaylist()
        local list = selectedPlaylist()
        if state.Queue == list.Tracks then
            state.Playback.Stop(true)
            state.Queue = {}
            state.QueueIndex = 0
            state.CurrentTrack = nil
        end
        list.Tracks = {}
        savePlaylists()
        playlistNotice("歌单已清空")
    end

    local function movePlaylistTrack(index, delta)
        local list = selectedPlaylist()
        local target = index + delta
        if index < 1 or index > #list.Tracks or target < 1 or target > #list.Tracks then return false end
        list.Tracks[index], list.Tracks[target] = list.Tracks[target], list.Tracks[index]
        if state.Queue == list.Tracks then
            if state.QueueIndex == index then state.QueueIndex = target
            elseif state.QueueIndex == target then state.QueueIndex = index end
        end
        savePlaylists()
        return true
    end

    local function removePlaylistTrack(index)
        local list = selectedPlaylist()
        if index < 1 or index > #list.Tracks then return false end
        local removingCurrent = state.Queue == list.Tracks and state.QueueIndex == index
        table.remove(list.Tracks, index)
        if state.Queue == list.Tracks then
            if removingCurrent then
                state.Playback.Stop(true)
                state.CurrentTrack = nil
                state.QueueIndex = math.min(index, #list.Tracks)
            elseif state.QueueIndex > index then
                state.QueueIndex = state.QueueIndex - 1
            end
        end
        savePlaylists()
        playlistNotice("已从歌单移除")
        return true
    end

    local function playSelectedPlaylist(startIndex)
        local list = selectedPlaylist()
        if #list.Tracks == 0 then playlistNotice("当前歌单没有音乐"); return false end
        startIndex = math.clamp(tonumber(startIndex) or 1, 1, #list.Tracks)
        return true, list.Tracks[startIndex], list.Tracks, startIndex
    end

    local function findExecutorFunction(name)
        local fn = type(env) == "table" and env[name] or nil
        if type(fn) == "function" then return fn end
        if type(_G) == "table" and type(_G[name]) == "function" then return _G[name] end
        local ok, found = pcall(function()
            if type(getfenv) == "function" then
                local scope = getfenv()
                if type(scope) == "table" then return scope[name] end
            end
        end)
        if ok and type(found) == "function" then return found end
        return nil
    end

    local function getRequestFunction()
        local fn = findExecutorFunction("request")
            or findExecutorFunction("http_request")
            or findExecutorFunction("httprequest")
            or findExecutorFunction("krnl_request")
            or findExecutorFunction("secure_request")
        if not fn and type(env.syn) == "table" then fn = env.syn.request end
        if not fn and type(env.http) == "table" then fn = env.http.request end
        if not fn and type(env.fluxus) == "table" then fn = env.fluxus.request end
        return fn
    end

    local function httpRequest(method, url, headers, body, redirectDepth)
        headers = headers or {}
        redirectDepth = tonumber(redirectDepth) or 0
        local requestFn = getRequestFunction()
        if type(requestFn) == "function" then
            local methodName = method or "GET"
            local requestShapes = {
                {Url=url, Method=methodName, Headers=headers, Redirect=true},
                {url=url, method=methodName, headers=headers, redirect=true},
            }
            if body ~= nil then
                requestShapes[1].Body = body
                requestShapes[2].body = body
            end
            for _, requestData in ipairs(requestShapes) do
                local ok, response = pcall(requestFn, requestData)
                if ok and type(response) == "string" and response ~= "" then
                    return true, response, {}, 200
                end
                if ok and type(response) == "table" then
                    local status = tonumber(response.StatusCode or response.Status or response.status_code or response.status) or 200
                    local responseHeaders = response.Headers or response.headers or response.ResponseHeaders or {}
                    local responseBody = response.Body or response.body or response.ResponseBody or response.response_body or response.Data or response.data
                    if status >= 300 and status < 400 and redirectDepth < 4 then
                        local location = responseHeaders.Location or responseHeaders.location
                        if type(location) == "string" and location ~= "" then
                            if location:sub(1,2) == "//" then location = "https:" .. location end
                            return httpRequest(methodName, location, headers, body, redirectDepth + 1)
                        end
                    end
                    if status < 400 and type(responseBody) == "string" then
                        return true, responseBody, responseHeaders, status
                    end
                end
            end
        end

        if (method or "GET") == "GET" then
            local ok, responseBody = pcall(function() return game:HttpGet(url, true) end)
            if ok and type(responseBody) == "string" and responseBody ~= "" then
                return true, responseBody, nil, 200
            end
            return false, tostring(responseBody or "网络请求失败"), nil, 0
        end
        return false, "当前执行器不支持该网络请求", nil, 0
    end

    local function httpGet(url, headers)
        return httpRequest("GET", url, headers, nil)
    end

    local function platformHeaders(platform, base)
        local headers = {}
        if type(base) == "table" then
            for key, value in pairs(base) do headers[key] = value end
        end
        return headers
    end

    local function decodeJsonBody(body)
        if type(body) ~= "string" then
            return nil
        end
        local text = body
        local firstBrace = text:find("{", 1, true)
        local lastBrace = text:match(".*()}")
        if firstBrace and lastBrace and (firstBrace > 1 or lastBrace < #text) then
            text = text:sub(firstBrace, lastBrace)
        end
        local ok, data = pcall(function()
            return HttpService:JSONDecode(text)
        end)
        return ok and data or nil
    end

    local function searchNetease(keyword)
        local url = "https://music.163.com/api/search/get/web?csrf_token=&type=1&offset=0&total=true&limit=40&s="
            .. HttpService:UrlEncode(keyword)
        local ok, body = httpGet(url, platformHeaders("网易云音乐", {
            ["User-Agent"] = "Mozilla/5.0",
            ["Referer"] = "https://music.163.com/",
        }))
        if not ok then
            return {}
        end
        local data = decodeJsonBody(body)
        local songs = data and data.result and data.result.songs
        if type(songs) ~= "table" then
            return {}
        end

        local out = {}
        for index, raw in ipairs(songs) do
            local artists = joinArtists(raw.artists or raw.ar)
            local album = raw.album or raw.al or {}
            local track = normalizeTrack({
                Platform = "网易云音乐",
                Key = raw.id,
                Id = raw.id,
                Title = raw.name,
                Artist = artists,
                Album = album.name,
                Duration = raw.duration or raw.dt,
                Cover = album.picUrl,
                HotScore = (tonumber(raw.popularity) or 0) + (25 - index) * 100,
            }, "网易云音乐")
            if track then
                out[#out + 1] = track
            end
        end
        return out
    end

    local function searchQQ(keyword)
        local url = "https://c.y.qq.com/soso/fcgi-bin/client_search_cp?p=1&n=40&format=json&w="
            .. HttpService:UrlEncode(keyword)
        local ok, body = httpGet(url, platformHeaders("QQ音乐", {
            ["User-Agent"] = "Mozilla/5.0",
            ["Referer"] = "https://y.qq.com/",
        }))
        if not ok then
            return {}
        end
        local data = decodeJsonBody(body)
        local songs = data and data.data and data.data.song and data.data.song.list
        if type(songs) ~= "table" then
            return {}
        end

        local out = {}
        for index, raw in ipairs(songs) do
            local artist = joinArtists(raw.singer)
            local cover = nil
            if raw.albummid and raw.albummid ~= "" then
                cover = "https://y.gtimg.cn/music/photo_new/T002R300x300M000"
                    .. tostring(raw.albummid)
                    .. ".jpg?max_age=2592000"
            end
            local track = normalizeTrack({
                Platform = "QQ音乐",
                Key = raw.songmid,
                SongMid = raw.songmid,
                MediaMid = raw.media_mid or (raw.file and raw.file.media_mid),
                Title = raw.songname,
                Artist = artist,
                Album = raw.albumname,
                Duration = raw.interval,
                Cover = cover,
                HotScore = (25 - index) * 100,
            }, "QQ音乐")
            if track then
                out[#out + 1] = track
            end
        end
        return out
    end

    local function parseKugouSongs(songs)
        if type(songs) ~= "table" then
            return {}
        end
        local out = {}
        for index, raw in ipairs(songs) do
            local title = raw.songname or raw.SongName or raw.filename or raw.FileName or raw.song_name
            local artist = raw.singername or raw.SingerName or raw.singer_name
            if (not title or title == "") and (raw.filename or raw.FileName) then
                local fileName = tostring(raw.filename or raw.FileName)
                local a, b = fileName:match("^(.-)%s*%-%s*(.+)$")
                if a and b then
                    artist = artist or a
                    title = b
                else
                    title = fileName
                end
            end
            local cover = raw.album_img or raw.album_img_9 or raw.img or raw.Image
            if cover then
                cover = tostring(cover):gsub("{size}", "300")
            end
            local hash = raw.hash or raw.FileHash or raw.filehash or raw.HQFileHash
            local albumId = raw.album_id or raw.albumid or raw.AlbumID
            local track = normalizeTrack({
                Platform = "酷狗音乐",
                Key = hash or raw.EMixSongID or raw.mixsongid,
                Hash = hash,
                AlbumId = albumId,
                Title = title,
                Artist = artist,
                Album = raw.album_name or raw.albumname or raw.AlbumName,
                Duration = raw.duration or raw.Duration or raw.timeLength,
                Cover = cover,
                HotScore = (tonumber(raw.hot or raw.Hot) or 0) + (30 - index) * 100,
            }, "酷狗音乐")
            if track then
                out[#out + 1] = track
            end
        end
        return out
    end

    local function searchKugou(keyword)
        local encoded = HttpService:UrlEncode(keyword)
        local urls = {
            "https://msearchcdn.kugou.com/api/v3/search/song?plat=0&version=9108&showtype=14&highlight=em&pagesize=40&page=1&tag_aggr=1&tagtype=%E5%85%A8%E9%83%A8&keyword=" .. encoded,
            "https://mobilecdn.kugou.com/api/v3/search/song?format=json&plat=0&version=9108&showtype=1&page=1&pagesize=40&keyword=" .. encoded,
            "https://songsearch.kugou.com/song_search_v2?keyword=" .. encoded .. "&page=1&pagesize=40&platform=WebFilter&userid=-1&clientver=2000",
        }
        for _, url in ipairs(urls) do
            local ok, body = httpGet(url, platformHeaders("酷狗音乐", {
                ["User-Agent"] = "Mozilla/5.0",
                ["Referer"] = "https://www.kugou.com/",
                ["Accept"] = "application/json,text/plain,*/*",
            }))
            if ok then
                local data = decodeJsonBody(body)
                local songs = data and data.data and (data.data.info or data.data.lists)
                local parsed = parseKugouSongs(songs)
                if #parsed > 0 then
                    return parsed
                end
            end
        end
        return {}
    end

    local function sodaArtist(raw)
        local artists = raw.artists or raw.artist_list or raw.singers or raw.artist
        if type(artists) == "table" then
            return joinArtists(artists)
        end
        return tostring(artists or raw.author or raw.singer or "未知歌手")
    end

    local function sodaCover(raw)
        local cover = raw.Cover or raw.cover or raw.url_cover or raw.cover_url or raw.image or raw.pic_url
        if type(cover) == "table" then
            if type(cover.urls) == "table" then
                cover = cover.urls[1]
            elseif type(cover.url_list) == "table" then
                cover = cover.url_list[1]
            else
                cover = cover.url or cover.uri
            end
        end
        return cover
    end

    local function normalizeSodaTrack(raw, index)
        if type(raw) ~= "table" then
            return nil
        end
        local trackRaw = raw
        if type(raw.entity) == "table" then
            local entity = raw.entity
            if type(entity.track_wrapper) == "table" and type(entity.track_wrapper.track) == "table" then
                trackRaw = entity.track_wrapper.track
            elseif type(entity.track) == "table" then
                trackRaw = entity.track
            end
        end
        if type(trackRaw.track) == "table" then
            trackRaw = trackRaw.track
        end
        local id = trackRaw.id or trackRaw.track_id or trackRaw.trackId or raw.track_id or raw.id
        local title = trackRaw.name or trackRaw.track_name or trackRaw.trackName or trackRaw.title
        if not id and not title then
            return nil
        end
        local album = trackRaw.album
        local albumName = type(album) == "table" and (album.name or album.title) or album
        local cover = sodaCover(trackRaw)
        if not cover and type(album) == "table" then
            cover = sodaCover(album)
        end
        return normalizeTrack({
            Platform = "汽水音乐",
            Key = id or title,
            Id = id,
            Title = title or ("汽水音乐 " .. tostring(id)),
            Artist = sodaArtist(trackRaw),
            Album = albumName or "汽水音乐",
            Duration = trackRaw.duration or trackRaw.duration_ms or trackRaw.durationMs or 0,
            Cover = cover,
            HotScore = (30 - (index or 1)) * 100,
            PlayableUrl = trackRaw.PlayableUrl or trackRaw.playable_url or trackRaw.music or trackRaw.audio_url,
            ExactPlayable = (trackRaw.PlayableUrl or trackRaw.playable_url or trackRaw.music or trackRaw.audio_url) ~= nil,
        }, "汽水音乐")
    end

    local function collectSodaTracks(node, out, seen, depth)
        if type(node) ~= "table" or (depth or 0) > 8 or #out >= 40 then
            return
        end
        local track = normalizeSodaTrack(node, #out + 1)
        if track then
            local id = trackIdentity(track)
            if id ~= "" and not seen[id] then
                seen[id] = true
                out[#out + 1] = track
            end
        end
        for _, value in pairs(node) do
            if type(value) == "table" then
                collectSodaTracks(value, out, seen, (depth or 0) + 1)
                if #out >= 40 then
                    return
                end
            end
        end
    end

    local function searchSodaDirect(keyword)
        local stamp = tostring(math.floor(os.clock() * 1000000) + math.random(100000000, 999999999))
        local params = {
            "aid=386088", "app_name=luna_pc", "region=cn", "geo_region=cn", "os_region=cn",
            "device_id=" .. stamp, "iid=" .. stamp,
            "version_name=3.5.1", "version_code=30050100", "channel=official", "build_mode=master",
            "ac=wifi", "tz_name=Asia%2FShanghai", "device_platform=windows", "device_type=Windows",
            "os_version=Windows%2011", "fp=" .. stamp,
            "q=" .. HttpService:UrlEncode(keyword), "cursor=0", "search_method=input",
        }
        local headers = {
            ["User-Agent"] = "LunaPC/3.5.1(408871041)",
            ["Accept"] = "application/json, text/plain, */*",
        }
        if env.DBMusicQishuiXHelios then headers["X-Helios"] = tostring(env.DBMusicQishuiXHelios) end
        if env.DBMusicQishuiXMedusa then headers["X-Medusa"] = tostring(env.DBMusicQishuiXMedusa) end
        local ok, body = httpGet("https://api.qishui.com/luna/pc/search/track?" .. table.concat(params, "&"), headers)
        if ok and type(body) == "string" and #body > 2 then
            local data = decodeJsonBody(body)
            if data then
                local out = {}
                collectSodaTracks(data, out, {}, 0)
                if #out > 0 then
                    return out
                end
            end
        end
        return {}
    end

    local function searchSodaPublicFallback(keyword)
        local url = "https://api.et15.com/api/OPENapi?type=qishuimusic&retype=json&msg="
            .. HttpService:UrlEncode(keyword)
        local ok, body = httpGet(url, { ["User-Agent"] = "Mozilla/5.0" })
        if not ok then
            return {}
        end
        local data = decodeJsonBody(body)
        local raw = data and data.data
        if type(raw) ~= "table" then
            return {}
        end
        local items = (#raw > 0) and raw or {raw}
        local out = {}
        for index, item in ipairs(items) do
            if type(item) == "table" and (item.title or item.name) then
                local trackId = tostring(item.link or ""):match("track_id=(%d+)")
                local track = normalizeTrack({
                    Platform = "汽水音乐",
                    Key = trackId or item.title,
                    Id = trackId,
                    Title = item.title or item.name,
                    Artist = item.singer or item.artist,
                    Album = "汽水音乐",
                    Cover = item.cover,
                    HotScore = (30 - index) * 100,
                }, "汽水音乐")
                if track then out[#out + 1] = track end
            end
        end
        return out
    end

    local function searchSoda(keyword)
        local custom = currentProvider()
        if type(custom) == "table" and custom.ExactCatalog == true and type(custom.Search) == "function" then
            local ok, result = pcall(custom.Search, keyword, "汽水音乐", state.Filter)
            if ok and type(result) == "table" then
                local out = {}
                for index, raw in ipairs(result) do
                    local track = normalizeTrack(raw, "汽水音乐")
                    if track then
                        if track.HotScore == 0 then
                            track.HotScore = (30 - index) * 100
                        end
                        out[#out + 1] = track
                    end
                end
                if #out > 0 then
                    return out
                end
            end
        end
        local direct = searchSodaDirect(keyword)
        if #direct > 0 then
            return direct
        end
        return searchSodaPublicFallback(keyword)
    end

    local function searchCustom(keyword, platform)
        local custom = currentProvider()
        if type(custom) ~= "table"
            or custom.ExactCatalog ~= true
            or type(custom.Search) ~= "function"
        then
            return nil
        end
        local ok, result = pcall(custom.Search, keyword, platform, state.Filter)
        if not ok or type(result) ~= "table" then
            return nil
        end
        local out = {}
        for index, raw in ipairs(result) do
            local track = normalizeTrack(raw, platform == "全部" and nil or platform)
            if track then
                if track.HotScore == 0 then
                    track.HotScore = (25 - index) * 100
                end
                out[#out + 1] = track
            end
        end
        return out
    end

    local function searchPlatform(keyword, platform)
        local custom = searchCustom(keyword, platform)
        if custom and #custom > 0 then
            return custom
        end

        if platform == "网易云音乐" then
            return searchNetease(keyword)
        elseif platform == "QQ音乐" then
            return searchQQ(keyword)
        elseif platform == "酷狗音乐" then
            return searchKugou(keyword)
        elseif platform == "汽水音乐" then
            return searchSoda(keyword)
        end
        return {}
    end

    local VERSION_MARKERS = {
        "翻唱", "cover", "remix", "dj", "现场", "live", "伴奏", "纯音乐",
        "片段", "剪辑", "加速", "慢速", "变速", "降调", "升调", "女声",
        "男声", "串烧", "铃声", "抖音版", "现场版", "伴奏版", "钢琴版",
    }
    local PLATFORM_PRIORITY = {
        ["网易云音乐"] = 4,
        ["QQ音乐"] = 3,
        ["酷狗音乐"] = 2,
        ["汽水音乐"] = 1,
        ["Roblox"] = 0,
    }

    local function resultFilterScore(track, keyword)
        local query = normalizeSearchText(keyword)
        if query == "" then return tonumber(track.HotScore) or 0 end

        local title = normalizeSearchText(track.Title)
        local artist = normalizeSearchText(track.Artist)
        local album = normalizeSearchText(track.Album)
        local combinedArtistTitle = artist .. title
        local combinedTitleArtist = title .. artist
        local rawHot = math.max(0, tonumber(track.HotScore) or 0)
        local score = math.min(rawHot, 25000) * 0.20 + math.log(rawHot + 1) * 180

        if title == query then score = score + 145000 end
        if artist == query then score = score + 52000 end
        if combinedArtistTitle == query or combinedTitleArtist == query then score = score + 220000 end
        if title:find(query, 1, true) then score = score + 42000 end
        if artist:find(query, 1, true) then score = score + 26000 end
        if album:find(query, 1, true) then score = score + 9000 end
        if combinedArtistTitle:find(query, 1, true) or combinedTitleArtist:find(query, 1, true) then score = score + 52000 end

        local tokens = splitSearchTokens(keyword)
        local covered = 0
        for tokenIndex, token in ipairs(tokens) do
            local hit = false
            if title == token then score = score + 76000; hit = true
            elseif title:find(token, 1, true) then score = score + 27000; hit = true end
            if artist == token then score = score + 66000; hit = true
            elseif artist:find(token, 1, true) then score = score + 22000; hit = true end
            if album == token then score = score + 12000; hit = true
            elseif album:find(token, 1, true) then score = score + 5000; hit = true end
            if hit then covered = covered + 1 end
            if tokenIndex == #tokens and title == token then score = score + 42000 end
        end
        if #tokens > 1 and covered == #tokens then score = score + 85000 end

        local queryLower = lower(keyword)
        local titleLower = lower(track.Title)
        for _, marker in ipairs(VERSION_MARKERS) do
            if titleLower:find(marker, 1, true) and not queryLower:find(marker, 1, true) then
                score = score - 72000
            end
        end

        if artist == "" or artist == normalizeSearchText("未知歌手") then score = score - 40000 end
        if album == "" or album == normalizeSearchText("未知专辑") then score = score - 7000 end
        local duration = tonumber(track.Duration) or 0
        if duration >= 75 and duration <= 720 then score = score + 5500
        elseif duration > 0 and duration < 40 then score = score - 18000 end
        if track.Cover and track.Cover ~= "" then score = score + 2500 end
        score = score + (PLATFORM_PRIORITY[track.Platform] or 0) * 120

        if state.Filter == "单曲" and title:find(query, 1, true) then score = score + 10000
        elseif state.Filter == "歌手" and artist:find(query, 1, true) then score = score + 12000
        elseif state.Filter == "专辑" and album:find(query, 1, true) then score = score + 12000 end
        return score
    end

    local function sortResults(results, keyword)
        table.sort(results, function(a, b)
            local scoreA = resultFilterScore(a, keyword)
            local scoreB = resultFilterScore(b, keyword)
            if math.abs(scoreA - scoreB) < 0.001 then
                local priorityA = PLATFORM_PRIORITY[a.Platform] or 0
                local priorityB = PLATFORM_PRIORITY[b.Platform] or 0
                if priorityA ~= priorityB then return priorityA > priorityB end
                local hotA = tonumber(a.HotScore) or 0
                local hotB = tonumber(b.HotScore) or 0
                if hotA ~= hotB then return hotA > hotB end
                return tostring(a.Title) < tostring(b.Title)
            end
            return scoreA > scoreB
        end)
    end

    local function buildSearchVariants(keyword)
        local out, seen = {}, {}
        local function push(value)
            value = trim(value)
            local key = normalizeSearchText(value)
            if value ~= "" and key ~= "" and not seen[key] then
                seen[key] = true
                out[#out + 1] = value
            end
        end
        push(keyword)
        local afterDe = tostring(keyword):match(".*的%s*(.+)$")
        if afterDe then push(afterDe) end
        local rawTokens = {}
        local tokenSource = tostring(keyword):gsub("的", " "):gsub("[，,。%.！!？?、/|+&_%-—：:；;（）%(%)【】%[%]《》<>]", " ")
        for token in tokenSource:gmatch("%S+") do rawTokens[#rawTokens + 1] = token end
        if #rawTokens >= 2 then push(rawTokens[#rawTokens]) end
        while #out > 2 do table.remove(out) end
        return out
    end

    local function searchPlatformSmart(keyword, platform)
        local variants = buildSearchVariants(keyword)
        local merged, seen = {}, {}
        for variantIndex, variant in ipairs(variants) do
            if variantIndex > 1 then
                local best = -math.huge
                for _, track in ipairs(merged) do best = math.max(best, resultFilterScore(track, keyword)) end
                if best >= 125000 then break end
            end
            local result = searchPlatform(variant, platform)
            if type(result) == "table" then
                for _, track in ipairs(result) do
                    local id = trackIdentity(track)
                    if id ~= "" and not seen[id] then
                        seen[id] = true
                        merged[#merged + 1] = track
                    end
                end
            end
        end
        return merged
    end

    local function performSearch(keyword, callback)
        keyword = trim(keyword)
        if keyword == "" then
            state.SearchResults = {}
            state.SearchKeyword = ""
            state.Searching = false
            if callback then callback(true, {}) end
            return
        end

        state.SearchToken = state.SearchToken + 1
        local token = state.SearchToken
        state.SearchKeyword = keyword
        state.Searching = true

        task.spawn(function()
            local merged = {}
            if state.Platform == "全部" then
                local pending = #REAL_PLATFORMS
                for _, platform in ipairs(REAL_PLATFORMS) do
                    task.spawn(function()
                        local ok, result = pcall(searchPlatformSmart, keyword, platform)
                        if ok and type(result) == "table" then
                            for _, track in ipairs(result) do merged[#merged + 1] = track end
                        end
                        pending = pending - 1
                    end)
                end
                local deadline = os.clock() + 7.2
                while pending > 0 and os.clock() < deadline and token == state.SearchToken do task.wait(0.04) end
            else
                local ok, result = pcall(searchPlatformSmart, keyword, state.Platform)
                if ok and type(result) == "table" then merged = result end
            end
            if token ~= state.SearchToken then return end

            local unique, final = {}, {}
            for _, track in ipairs(merged) do
                local id = trackIdentity(track)
                if id ~= "" and not unique[id] then
                    unique[id] = true
                    final[#final + 1] = track
                end
            end
            sortResults(final, keyword)
            while #final > 160 do table.remove(final) end
            state.SearchResults = final
            state.Searching = false
            if callback then callback(true, final) end
        end)
    end

    local function pushPlayableCandidate(out, seen, value)
        if value == nil then return end
        if type(value) == "table" then
            if value.SoundId or value.soundId then
                local soundId = tostring(value.SoundId or value.soundId)
                local key = "sound:" .. soundId
                if soundId ~= "" and not seen[key] then
                    seen[key] = true
                    out[#out + 1] = {SoundId = soundId}
                end
                return
            end
            local direct = value.Url or value.url or value.AudioUrl or value.audioUrl or value.PlayableUrl
            if direct then pushPlayableCandidate(out, seen, direct) end
            local nested = value.Candidates or value.candidates or value.Urls or value.urls
            if type(nested) == "table" then
                for _, item in ipairs(nested) do pushPlayableCandidate(out, seen, item) end
            elseif #value > 0 then
                for _, item in ipairs(value) do pushPlayableCandidate(out, seen, item) end
            end
            return
        end
        if type(value) ~= "string" then return end
        value = trim(value)
        if value == "" then return end
        if not value:match("^https?://") and not value:match("^rbxassetid://") and not value:match("^rbxasset://") then return end
        if not seen[value] then seen[value] = true; out[#out + 1] = value end
    end

    local function resolveNeteaseCandidates(track)
        local out, seen = {}, {}
        local id = track.Key or track.Id
        if not id then return out end
        id = tostring(id)
        for _, bitrate in ipairs({320000, 192000, 128000, 96000}) do
            local apiUrl = "https://music.163.com/api/song/enhance/player/url?ids=%5B"
                .. HttpService:UrlEncode(id) .. "%5D&br=" .. tostring(bitrate)
            local ok, body = httpGet(apiUrl, platformHeaders("网易云音乐", {
                ["User-Agent"] = "Mozilla/5.0", ["Referer"] = "https://music.163.com/",
            }))
            if ok then
                local data = decodeJsonBody(body)
                local item = data and data.data and data.data[1]
                if type(item) == "table" then pushPlayableCandidate(out, seen, item.url) end
            end
        end
        pushPlayableCandidate(out, seen, "https://music.163.com/song/media/outer/url?id=" .. id .. ".mp3")
        return out
    end

    local function resolveQQCandidates(track)
        local out, seen = {}, {}
        local songMid = track.SongMid or track.Key
        if not songMid or tostring(songMid) == "" then return out end
        local mediaMid = track.MediaMid or songMid
        local guid = tostring(math.random(100000000, 999999999))
        local function requestVkey(filename)
            local qqUin = tostring(env.DBMusicQQUin or "0")
            local param = {guid=guid, songmid={tostring(songMid)}, songtype={0}, uin=qqUin, loginflag=1, platform="20"}
            if filename then param.filename = {filename} end
            local requestData = {
                req_0={module="vkey.GetVkeyServer",method="CgiGetVkey",param=param},
                comm={uin=tonumber(env.DBMusicQQUin) or 0,format="json",ct=24,cv=0},
            }
            local url = "https://u.y.qq.com/cgi-bin/musicu.fcg?format=json&data="
                .. HttpService:UrlEncode(HttpService:JSONEncode(requestData))
            local ok, body = httpGet(url, platformHeaders("QQ音乐", {
                ["User-Agent"]="Mozilla/5.0",["Referer"]="https://y.qq.com/",["Accept"]="application/json,text/plain,*/*",
            }))
            if not ok then return end
            local data = decodeJsonBody(body)
            local req = data and data.req_0 and data.req_0.data
            local info = req and req.midurlinfo and req.midurlinfo[1]
            local sip = req and req.sip and req.sip[1]
            local purl = info and info.purl
            if type(sip)=="string" and type(purl)=="string" and purl~="" then pushPlayableCandidate(out,seen,sip..purl) end
        end
        for _, filename in ipairs({
            "M500"..tostring(mediaMid)..".mp3",
            "M800"..tostring(mediaMid)..".mp3",
            "C400"..tostring(mediaMid)..".m4a",
        }) do requestVkey(filename) end
        requestVkey(nil)
        return out
    end

    local function resolveKugouCandidates(track)
        local out, seen = {}, {}
        local hash = track.Hash or track.Key
        if not hash or tostring(hash)=="" then return out end
        local albumId=tostring(track.AlbumId or 0)
        local encodedHash=HttpService:UrlEncode(tostring(hash))
        local urls={
            "https://wwwapi.kugou.com/yy/index.php?r=play/getdata&hash="..encodedHash.."&appid=1014&platid=4&album_id="..HttpService:UrlEncode(albumId),
            "https://wwwapi.kugou.com/yy/index.php?r=play/getdata&mid=1&hash="..encodedHash.."&album_id="..HttpService:UrlEncode(albumId),
            "https://m.kugou.com/app/i/getSongInfo.php?cmd=playInfo&hash="..encodedHash,
        }
        for _,url in ipairs(urls) do
            local ok,body=httpGet(url,platformHeaders("酷狗音乐",{["User-Agent"]="Mozilla/5.0",["Referer"]="https://www.kugou.com/"}))
            if ok then
                local data=decodeJsonBody(body); local info=(data and data.data) or data
                if type(info)=="table" then
                    if not track.Cover and (info.img or info.album_img) then track.Cover=tostring(info.img or info.album_img):gsub("{size}","300") end
                    if (not track.Title or track.Title:find("编码",1,true)) and info.song_name then track.Title=tostring(info.song_name) end
                    if (not track.Artist or track.Artist=="未知歌手") and info.author_name then track.Artist=tostring(info.author_name) end
                    pushPlayableCandidate(out,seen,info.play_url_hq); pushPlayableCandidate(out,seen,info.play_url)
                    pushPlayableCandidate(out,seen,info.audio_url); pushPlayableCandidate(out,seen,info.url)
                end
            end
        end
        return out
    end

    local function collectSodaPlayableCandidates(node,out,seen,depth)
        if type(node)~="table" or (depth or 0)>8 or #out>=12 then return end
        for key,value in pairs(node) do
            local keyLower=lower(key)
            if type(value)=="string" and value:match("^https?://") then
                local media=keyLower:find("play",1,true) or keyLower:find("audio",1,true) or keyLower:find("main",1,true) or keyLower=="url" or keyLower:find("video",1,true)
                local cover=keyLower:find("cover",1,true) or keyLower:find("image",1,true) or keyLower:find("avatar",1,true) or keyLower:find("pic",1,true)
                if media and not cover then pushPlayableCandidate(out,seen,value) end
            elseif type(value)=="string" and (keyLower=="video_model" or keyLower=="videomodel") then
                local decoded=decodeJsonBody(value); if decoded then collectSodaPlayableCandidates(decoded,out,seen,(depth or 0)+1) end
            elseif type(value)=="table" then collectSodaPlayableCandidates(value,out,seen,(depth or 0)+1) end
            if #out>=12 then return end
        end
    end

    local function resolveSodaCandidates(track)
        local out,seen={},{}
        if track.ExactPlayable==true then pushPlayableCandidate(out,seen,track.PlayableUrl) end
        local id=track.Id or track.Key
        if id and tostring(id):match("%d+") then
            local urls={
                "https://beta-luna.douyin.com/luna/h5/seo_track?track_id="..HttpService:UrlEncode(tostring(id)).."&device_platform=web",
                "https://music.douyin.com/qishui/share/track?track_id="..HttpService:UrlEncode(tostring(id)),
            }
            for _,url in ipairs(urls) do
                local ok,body=httpGet(url,{["User-Agent"]="Mozilla/5.0"})
                if ok then local data=decodeJsonBody(body); if data then collectSodaPlayableCandidates(data,out,seen,0) end end
            end
        end
        return out
    end

    local function resolvePlayableCandidates(track)
        local out,seen={},{}
        local custom=currentProvider()
        if type(custom)=="table" and custom.ExactPlayback==true and type(custom.Resolve)=="function" then
            local ok,result=pcall(custom.Resolve,track); if ok then pushPlayableCandidate(out,seen,result) end
        end
        if track.Platform=="网易云音乐" then
            for _,item in ipairs(resolveNeteaseCandidates(track)) do pushPlayableCandidate(out,seen,item) end
        elseif track.Platform=="QQ音乐" then
            for _,item in ipairs(resolveQQCandidates(track)) do pushPlayableCandidate(out,seen,item) end
        elseif track.Platform=="酷狗音乐" then
            for _,item in ipairs(resolveKugouCandidates(track)) do pushPlayableCandidate(out,seen,item) end
        elseif track.Platform=="汽水音乐" then
            for _,item in ipairs(resolveSodaCandidates(track)) do pushPlayableCandidate(out,seen,item) end
        end
        if track.ExactPlayable==true then pushPlayableCandidate(out,seen,track.PlayableUrl) end
        return out
    end

    local function sanitizeFileName(value)
        value = tostring(value or ""):gsub("[^%w%-%_]", "_")
        if #value > 70 then
            value = value:sub(1, 70)
        end
        if value == "" then
            value = tostring(math.floor(os.clock() * 100000))
        end
        return value
    end

    local function extensionFromUrl(url, headers)
        local lowerUrl = lower(url)
        local contentType = ""
        if type(headers) == "table" then
            contentType = lower(headers["Content-Type"] or headers["content-type"] or "")
        end
        if lowerUrl:find(".m4a", 1, true) or contentType:find("audio/mp4", 1, true) or contentType:find("audio/aac", 1, true) then
            return ".m4a"
        elseif lowerUrl:find(".ogg", 1, true) or contentType:find("audio/ogg", 1, true) then
            return ".ogg"
        elseif lowerUrl:find(".wav", 1, true) or contentType:find("audio/wav", 1, true) then
            return ".wav"
        end
        return ".mp3"
    end

    local execWriteFile = findExecutorFunction("writefile")
    local execReadFile = findExecutorFunction("readfile")
    local execIsFile = findExecutorFunction("isfile")
    local execMakeFolder = findExecutorFunction("makefolder")
    local execDeleteFile = findExecutorFunction("delfile")

    local function getAssetLoaderCandidates()
        local out, seen = {}, {}
        local function push(fn)
            if type(fn) == "function" and not seen[fn] then seen[fn] = true; out[#out + 1] = fn end
        end
        push(findExecutorFunction("getcustomasset"))
        push(findExecutorFunction("getsynasset"))
        push(findExecutorFunction("getasset"))
        return out
    end

    local function looksLikeAudio(body, headers)
        if type(body) ~= "string" or #body < 2048 then
            return false, "音频响应过短/不是完整歌曲"
        end

        local head = body:sub(1, 64)
        local textHead = lower(head:gsub("^%s+", ""))
        local contentType = ""
        if type(headers) == "table" then
            contentType = lower(headers["Content-Type"] or headers["content-type"] or "")
        end

        if contentType:find("text/", 1, true)
            or contentType:find("application/json", 1, true)
            or contentType:find("application/javascript", 1, true)
            or textHead:sub(1, 1) == "<"
            or textHead:sub(1, 1) == "{"
            or textHead:sub(1, 1) == "["
        then
            return false, "平台返回的是网页/JSON，不是音频"
        end

        if head:sub(1, 3) == "ID3"
            or head:sub(1, 4) == "RIFF"
            or head:sub(1, 4) == "OggS"
            or (#head >= 12 and head:sub(5, 8) == "ftyp")
        then
            return true
        end

        local b1, b2 = head:byte(1, 2)
        if b1 == 0xFF and b2 and b2 >= 0xE0 then return true end
        if contentType:find("audio/", 1, true) then return true end
        return false, "返回内容无法识别为音频"
    end

    local function audioBodyFingerprint(body)
        if type(body) ~= "string" then return "" end
        local hash = 5381
        local step = math.max(1, math.floor(#body / 320))
        for index = 1, #body, step do
            hash = (hash * 33 + (body:byte(index) or 0)) % 2147483647
        end
        return tostring(#body) .. "_" .. tostring(hash)
    end

    local function candidateCacheIdentity(track, url)
        local trackKey = sanitizeFileName(trackIdentity(track)):sub(1, 48)
        return trackKey .. "_" .. stableTextHash(url)
    end

    local function tryLoadAssetPath(path)
        for _, loader in ipairs(getAssetLoaderCandidates()) do
            local ok, asset = pcall(loader, path)
            if ok and type(asset) == "string" and asset ~= "" then return asset end
        end
        return nil
    end

    local function loadAudioAsset(url, track)
        if type(url) == "table" and url.SoundId then return tostring(url.SoundId) end
        if type(url) ~= "string" or not url:match("^https?://") then
            return nil, "没有可播放地址"
        end

        local candidateKey = candidateCacheIdentity(track, url)
        local trackOwner = canonicalSongIdentity(track)
        if trackOwner == "|" or trackOwner == "" then trackOwner = trackIdentity(track) end
        if state.AudioCache[candidateKey] then return state.AudioCache[candidateKey] end

        local loaders = getAssetLoaderCandidates()
        local function acceptAsset(asset, sourceUrl)
            if type(asset) ~= "string" or asset == "" then return nil end
            local oldOwner = state.AudioAssetOwners[asset]
            local oldUrl = state.AudioAssetUrls[asset]
            if oldOwner and oldOwner ~= trackOwner then return nil end
            if oldUrl and sourceUrl and oldUrl ~= sourceUrl then return nil end
            state.AudioAssetOwners[asset] = trackOwner
            state.AudioAssetUrls[asset] = sourceUrl or url
            state.AudioCache[candidateKey] = asset
            return asset
        end

        local knownExtensions = {".mp3", ".ogg", ".wav", ".m4a"}
        local rootPrefix = "DBM125_" .. candidateKey
        local folderPrefix = CACHE_DIR .. "/" .. candidateKey

        local function tryDirectUrlRegistration()
            local directNames = {
                "getcustomassetfromurl", "getcustomasset_from_url", "getassetfromurl",
                "getsynassetfromurl", "getsynasset_from_url",
            }
            for _, name in ipairs(directNames) do
                local fn = findExecutorFunction(name)
                if type(fn) == "function" then
                    local done, value = false, nil
                    task.spawn(function()
                        local ok, asset = pcall(fn, url)
                        if ok then value = asset end
                        done = true
                    end)
                    local deadline = os.clock() + 3.8
                    while not done and os.clock() < deadline do task.wait(0.03) end
                    if done then
                        local accepted = acceptAsset(value, url)
                        if accepted then return accepted end
                    end
                end
            end
            return nil
        end

        local directAsset = tryDirectUrlRegistration()
        if directAsset then return directAsset end

        if type(execWriteFile) == "function" and #loaders > 0 then
            if type(execIsFile) == "function" then
                for _, ext in ipairs(knownExtensions) do
                    for _, path in ipairs({rootPrefix .. ext, folderPrefix .. ext}) do
                        local exists = false
                        pcall(function() exists = execIsFile(path) end)
                        if exists then
                            local cachedBody = nil
                            if type(execReadFile) == "function" then
                                pcall(function() cachedBody = execReadFile(path) end)
                            end
                            local cacheAccepted = true
                            if type(cachedBody) == "string" and #cachedBody > 0 then
                                local valid = looksLikeAudio(cachedBody, nil)
                                if not valid then
                                    cacheAccepted = false
                                    if type(execDeleteFile) == "function" then pcall(function() execDeleteFile(path) end) end
                                else
                                    local fingerprint = audioBodyFingerprint(cachedBody)
                                    local previousOwner = state.AudioBodyOwners[fingerprint]
                                    if previousOwner and previousOwner ~= trackOwner then
                                        cacheAccepted = false
                                        if type(execDeleteFile) == "function" then pcall(function() execDeleteFile(path) end) end
                                    else
                                        state.AudioBodyOwners[fingerprint] = trackOwner
                                    end
                                end
                            end
                            if cacheAccepted then
                                local asset = acceptAsset(tryLoadAssetPath(path), url)
                                if asset then return asset end
                            end
                        end
                    end
                end
            end

            local referer = "https://music.163.com/"
            if track.Platform == "QQ音乐" then referer = "https://y.qq.com/"
            elseif track.Platform == "酷狗音乐" then referer = "https://www.kugou.com/"
            elseif track.Platform == "汽水音乐" then referer = "https://www.douyin.com/" end

            local ok, body, responseHeaders = httpGet(url, platformHeaders(track.Platform, {
                ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/128 Safari/537.36",
                ["Referer"] = referer,
                ["Accept"] = "audio/mpeg,audio/ogg,audio/wav,audio/mp4,audio/aac,audio/*,*/*;q=0.8",
                ["Accept-Encoding"] = "identity",
            }))
            if ok then
                local valid, why = looksLikeAudio(body, responseHeaders)
                if valid then
                    local fingerprint = audioBodyFingerprint(body)
                    local previousOwner = state.AudioBodyOwners[fingerprint]
                    if previousOwner and previousOwner ~= trackOwner then
                        state.LastPlaybackError = "检测到平台/执行器复用了另一首歌的音频响应"
                    else
                        state.AudioBodyOwners[fingerprint] = trackOwner
                        local ext = extensionFromUrl(url, responseHeaders)
                        local rootPath = rootPrefix .. ext
                        local wrote = pcall(function() execWriteFile(rootPath, body) end)
                        if wrote then
                            local asset = acceptAsset(tryLoadAssetPath(rootPath), url)
                            if not asset and type(execMakeFolder) == "function" then
                                pcall(function() execMakeFolder(CACHE_DIR) end)
                                local folderPath = folderPrefix .. ext
                                if pcall(function() execWriteFile(folderPath, body) end) then
                                    asset = acceptAsset(tryLoadAssetPath(folderPath), url)
                                end
                            end
                            if asset then return asset end
                        end
                    end
                else
                    state.LastPlaybackError = tostring(why or "平台返回非音频")
                end
            else
                state.LastPlaybackError = tostring(body or "音频下载失败")
            end
        end

        if type(execWriteFile) ~= "function" or #loaders == 0 then
            return nil, "当前执行器没有稳定的本地音频资产接口"
        end
        return nil, state.LastPlaybackError ~= "" and state.LastPlaybackError or "音频下载/注册失败"
    end

    local function invalidateTrackAudioCache(track, url)
        local prefix = sanitizeFileName(trackIdentity(track)):sub(1, 48) .. "_"
        local keys = {}
        if type(url) == "string" and url ~= "" then
            keys[1] = candidateCacheIdentity(track, url)
        else
            for key in pairs(state.AudioCache) do
                if tostring(key):sub(1, #prefix) == prefix then keys[#keys + 1] = key end
            end
        end
        for _, key in ipairs(keys) do state.AudioCache[key] = nil end
        if type(execDeleteFile) ~= "function" then return end
        for _, key in ipairs(keys) do
            for _, ext in ipairs({".mp3", ".ogg", ".wav", ".m4a"}) do
                for _, path in ipairs({"DBM125_" .. key .. ext, CACHE_DIR .. "/" .. key .. ext}) do
                    local exists = true
                    if type(execIsFile) == "function" then
                        exists = false
                        pcall(function() exists = execIsFile(path) end)
                    end
                    if exists then pcall(function() execDeleteFile(path) end) end
                end
            end
        end
    end

    local function verifyCurrentTrackDuration(track, waitSeconds)
        local expected = tonumber(track and track.Duration) or 0
        local deadline = os.clock() + math.max(0, tonumber(waitSeconds) or 0)
        local observed = tonumber(state.Playback.TimeLength()) or 0
        while observed <= 0.5 and os.clock() < deadline and state.Playback.IsPlaying() do
            task.wait(0.09)
            observed = tonumber(state.Playback.TimeLength()) or 0
        end

        if observed <= 0.5 then return true, observed end
        if expected < 45 then return true, observed end

        local ratio = observed / math.max(1, expected)
        if expected >= 90 and observed >= 24 and observed <= 38 then
            return false, observed, "检测到约31秒异常/试听片段"
        end
        if ratio < 0.56 or ratio > 1.52 then
            return false, observed, "音频时长与原曲明显不符"
        end
        return true, observed
    end

    local function runWithTimeout(seconds, callback)
        local finished = false
        local packed = nil
        task.spawn(function()
            packed = table.pack(pcall(callback))
            finished = true
        end)
        local deadline = os.clock() + math.max(0.05, tonumber(seconds) or 1)
        while not finished and os.clock() < deadline do
            task.wait(0.025)
        end
        if not finished then
            return false, "timeout"
        end
        if not packed[1] then
            return false, tostring(packed[2])
        end
        return true, table.unpack(packed, 2, packed.n)
    end

    local function stopCurrent(clearAsset)
        state.ExternalPlaying = false
        state.Playback.Stop(clearAsset)
    end

    local function playSoundAsset(asset, token, maxWait)
        maxWait = tonumber(maxWait) or 6.5
        if token ~= state.PlayToken or not asset or tostring(asset) == "" then return false end
        asset = tostring(asset)
        state.Playback.Stop(true)
        task.wait(0.025)
        if token ~= state.PlayToken then return false end

        local hostedRobloxAsset = asset:match("^rbxassetid://") ~= nil
            or asset:find("roblox.com/asset", 1, true) ~= nil

        local function tryLegacySound(waitTime)
            state.PlaybackBackend = "Sound"
            local setOk = pcall(function()
                sound.Parent = workspace
                sound:Stop()
                sound.SoundId = ""
                sound.TimePosition = 0
                sound.Looped = state.Mode == "单曲循环"
                sound.Volume = state.MusicVolume
                sound.PlaybackSpeed = 1
                sound.SoundId = asset
            end)
            if not setOk then return false end
            task.spawn(function() pcall(function() ContentProvider:PreloadAsync({sound}) end) end)
            pcall(function() sound:Play() end)
            local deadline = os.clock() + math.max(1.0, waitTime or maxWait)
            local nextKick = os.clock() + 0.22
            local usedLocalFallback = false
            while token == state.PlayToken and os.clock() < deadline do
                local playing, loaded, length = false, false, 0
                pcall(function() playing = sound.IsPlaying end)
                pcall(function() loaded = sound.IsLoaded end)
                pcall(function() length = tonumber(sound.TimeLength) or 0 end)
                if playing then
                    state.PlaybackBackend = "Sound"
                    state.PlaybackPaused = false
                    return true
                end
                if (loaded or length > 0.05) and os.clock() >= nextKick then
                    nextKick = os.clock() + 0.34
                    if not usedLocalFallback then
                        usedLocalFallback = true
                        pcall(function() SoundService:PlayLocalSound(sound) end)
                    else
                        pcall(function() sound:Play() end)
                    end
                end
                task.wait(0.045)
            end
            pcall(function() sound:Stop() end)
            return false
        end

        local function tryAudioPlayer(waitTime)
            if not (state.AudioGraph and state.AudioGraph.Available and state.AudioGraph.Player) then return false end
            local player = state.AudioGraph.Player
            pcall(function() player:Stop() end)
            local setOk = false
            if hostedRobloxAsset then
                setOk = pcall(function()
                    player.AssetId = asset
                    player.Volume = state.MusicVolume
                    player.Looping = state.Mode == "单曲循环"
                    player.PlaybackSpeed = 1
                    player.TimePosition = 0
                end)
                if not setOk then
                    setOk = pcall(function() player.Asset = asset end)
                end
            else
                setOk = pcall(function()
                    player.Asset = asset
                    player.Volume = state.MusicVolume
                    player.Looping = state.Mode == "单曲循环"
                    player.PlaybackSpeed = 1
                    player.TimePosition = 0
                end)
                if not setOk then setOk = pcall(function() player.AssetId = asset end) end
            end
            if not setOk then return false end

            local deadline = os.clock() + math.max(1.0, waitTime or maxWait)
            local nextKick = 0
            while token == state.PlayToken and os.clock() < deadline do
                local ready, playing, length = false, false, 0
                pcall(function() ready = player.IsReady end)
                pcall(function() playing = player.IsPlaying end)
                pcall(function() length = tonumber(player.TimeLength) or 0 end)
                if playing then
                    state.PlaybackBackend = "AudioPlayer"
                    state.PlaybackPaused = false
                    return true
                end
                if (ready or length > 0.05) and os.clock() >= nextKick then
                    nextKick = os.clock() + 0.28
                    pcall(function() player:Play() end)
                end
                task.wait(0.045)
            end
            pcall(function() player:Stop() end)
            return false
        end

        if hostedRobloxAsset then
            if tryAudioPlayer(maxWait) then return true end
            state.Playback.Stop(false)
            if tryLegacySound(maxWait) then return true end
        else
            if tryLegacySound(maxWait) then return true end
            state.Playback.Stop(false)
            if tryAudioPlayer(maxWait) then return true end
        end
        return false
    end

    local function playTrack(track, queue, index)
        if not track then return end

        if type(queue) == "table" then
            state.Queue = queue
            state.QueueIndex = tonumber(index) or 1
        else
            state.Queue = {track}
            state.QueueIndex = 1
        end

        state.CurrentTrack = track
        state.PlayToken = state.PlayToken + 1
        state.PlaybackGeneration = state.PlaybackGeneration + 1
        local token = state.PlayToken
        state.PlayStatus = "加载中"
        state.LastPlaybackError = ""
        stopCurrent(true)

        task.spawn(function()
            local custom = currentProvider()
            if type(custom) == "table" and custom.ExactPlayback == true and type(custom.Play) == "function" then
                local okProvider, handled = runWithTimeout(2.5, function()
                    return custom.Play(track, sound)
                end)
                if token ~= state.PlayToken then return end
                if okProvider and handled == true then
                    state.ExternalPlaying = true
                    state.PlayStatus = "播放中 · 精确Provider"
                    return
                end
            end

            if track.RobloxId then
                local played = playSoundAsset("rbxassetid://" .. tostring(track.RobloxId), token, 2.4)
                if token == state.PlayToken then
                    state.PlayStatus = played and "播放中 · Roblox编码" or "Roblox编码播放失败"
                end
                return
            end

            state.PlayStatus = "解析原平台音频"
            local okResolve, candidates = runWithTimeout(8.0, function()
                return resolvePlayableCandidates(track)
            end)
            if token ~= state.PlayToken then return end
            if not okResolve or type(candidates) ~= "table" or #candidates == 0 then
                state.LastPlaybackError = tostring(candidates or "平台没有返回可播放地址")
                state.PlayStatus = "原歌播放失败 · 平台未返回可用原音源"
                return
            end

            local maxCandidates = math.min(#candidates, 10)
            local lastError = "没有候选音源"
            for candidateIndex = 1, maxCandidates do
                if token ~= state.PlayToken then return end
                local url = candidates[candidateIndex]
                state.PlayStatus = string.format("尝试原平台音频 %d/%d", candidateIndex, maxCandidates)

                local okAsset, asset, assetError = runWithTimeout(15.0, function()
                    return loadAudioAsset(url, track)
                end)
                if token ~= state.PlayToken then return end
                if okAsset and asset then
                    local played = playSoundAsset(asset, token, 5.2)
                    if token ~= state.PlayToken then return end
                    if played then
                        local validDuration, observedDuration, durationWhy = verifyCurrentTrackDuration(track, 3.8)
                        if validDuration then
                            state.LastVerifiedTrackId = trackIdentity(track)
                            state.LastVerifiedDuration = observedDuration or 0
                            state.PlayStatus = "播放中 · 原平台"

                            local verifiedUrl = url
                            task.delay(4.5, function()
                                if token ~= state.PlayToken or state.CurrentTrack ~= track then return end
                                local lateValid, _, lateWhy = verifyCurrentTrackDuration(track, 0)
                                if not lateValid then
                                    stopCurrent(true)
                                    invalidateTrackAudioCache(track, verifiedUrl)
                                    state.LastPlaybackError = lateWhy or "延迟核验发现音频不匹配"
                                    state.PlayStatus = "已拦截错误/试听音频 · 请重新点歌"
                                end
                            end)
                            return
                        end

                        stopCurrent(true)
                        invalidateTrackAudioCache(track, url)
                        lastError = durationWhy or "原平台音频与歌曲不匹配"
                    else
                        lastError = "当前执行器无法播放该候选格式"
                        invalidateTrackAudioCache(track, url)
                    end
                else
                    lastError = tostring(assetError or asset or "候选音频无法注册")
                end
                task.wait(0.04)
            end

            if token ~= state.PlayToken then return end
            state.LastPlaybackError = lastError
            state.PlayStatus = "原歌播放失败 · 已尝试全部精确候选音源"
        end)
    end

    local function nextTrack(automatic)
        if #state.Queue == 0 then
            return
        end
        if state.Mode == "单曲循环" and state.CurrentTrack then
            playTrack(state.CurrentTrack, state.Queue, state.QueueIndex)
            return
        end
        local nextIndex = state.QueueIndex + 1
        if nextIndex > #state.Queue then
            if state.Mode == "列表循环" then
                nextIndex = 1
            else
                if automatic then
                    stopCurrent()
                    state.PlayStatus = "播放完成"
                end
                return
            end
        end
        playTrack(state.Queue[nextIndex], state.Queue, nextIndex)
    end

    local function previousTrack()
        if #state.Queue == 0 then
            return
        end
        local index = state.QueueIndex - 1
        if index < 1 then
            index = state.Mode == "列表循环" and #state.Queue or 1
        end
        playTrack(state.Queue[index], state.Queue, index)
    end

    sound.Ended:Connect(function()
        if not state.Destroyed and state.PlaybackBackend == "Sound" then nextTrack(true) end
    end)
    if state.AudioGraph and state.AudioGraph.Player then
        state.AudioGraph.Player.Ended:Connect(function()
            if not state.Destroyed and state.PlaybackBackend == "AudioPlayer" then nextTrack(true) end
        end)
    end

    local function togglePause()
        local custom = currentProvider()
        if state.ExternalPlaying
            and type(custom) == "table"
            and type(custom.TogglePause) == "function"
        then
            local ok, handled = pcall(custom.TogglePause, state.CurrentTrack, sound)
            if ok and handled == true then return end
        end

        if state.Playback.IsPlaying() then
            state.Playback.Pause()
            state.PlayStatus = "已暂停"
        elseif state.CurrentTrack then
            if state.PlaybackPaused then
                state.Playback.Resume()
                state.PlayStatus = "播放中"
            else
                playTrack(state.CurrentTrack, state.Queue, state.QueueIndex)
            end
        end
    end

    local function lookupNeteaseTrackById(id)
        id = tostring(id or ""):match("(%d+)")
        if not id then return nil end
        local urls = {
            "https://music.163.com/api/song/detail/?ids=%5B" .. id .. "%5D",
            "https://music.163.com/api/song/detail?ids=%5B" .. id .. "%5D",
        }
        for _, url in ipairs(urls) do
            local ok, body = httpGet(url, platformHeaders("网易云音乐", {
                ["User-Agent"] = "Mozilla/5.0", ["Referer"] = "https://music.163.com/",
            }))
            if ok then
                local data = decodeJsonBody(body)
                local raw = data and data.songs and data.songs[1]
                if type(raw) == "table" then
                    local album = raw.album or raw.al or {}
                    return normalizeTrack({
                        Platform = "网易云音乐", Key = id, Id = id,
                        Title = raw.name or ("网易云音乐 " .. id),
                        Artist = joinArtists(raw.artists or raw.ar),
                        Album = album.name, Duration = raw.duration or raw.dt,
                        Cover = album.picUrl,
                    }, "网易云音乐")
                end
            end
        end
        return normalizeTrack({Platform="网易云音乐",Key=id,Id=id,Title="网易云音乐编码 "..id,Artist="原平台"}, "网易云音乐")
    end

    local function lookupQQTrackByMid(mid)
        mid = tostring(mid or ""):match("([%w%-_]+)")
        if not mid or mid == "" then return nil end
        local url = "https://c.y.qq.com/v8/fcg-bin/fcg_play_single_song.fcg?songmid="
            .. HttpService:UrlEncode(mid) .. "&format=json"
        local ok, body = httpGet(url, platformHeaders("QQ音乐", {
            ["User-Agent"]="Mozilla/5.0", ["Referer"]="https://y.qq.com/",
        }))
        if ok then
            local data = decodeJsonBody(body)
            local raw = data and data.data and data.data[1]
            if type(raw) == "table" then
                local album = raw.album or {}
                local file = raw.file or {}
                local albumMid = album.mid or raw.albummid
                local cover = albumMid and albumMid ~= "" and
                    ("https://y.gtimg.cn/music/photo_new/T002R300x300M000"..tostring(albumMid)..".jpg?max_age=2592000") or nil
                return normalizeTrack({
                    Platform="QQ音乐", Key=mid, SongMid=mid,
                    MediaMid=file.media_mid or raw.media_mid or mid,
                    Title=raw.name or raw.songname or ("QQ音乐 "..mid),
                    Artist=joinArtists(raw.singer),
                    Album=album.name or raw.albumname,
                    Duration=raw.interval, Cover=cover,
                }, "QQ音乐")
            end
        end
        return normalizeTrack({Platform="QQ音乐",Key=mid,SongMid=mid,MediaMid=mid,Title="QQ音乐编码 "..mid,Artist="原平台"}, "QQ音乐")
    end

    local function parseMusicCode(value)
        local raw = trim(value)
        if raw == "" then return nil, "请输入音乐编码或网址" end
        local compact = raw:gsub("%s+", "")
        local lowerCode = lower(compact)

        local robloxId = lowerCode:match("^rbxassetid://(%d+)$")
            or lowerCode:match("^rbx:(%d+)$")
            or lowerCode:match("^roblox:(%d+)$")
        if robloxId then
            return normalizeTrack({Platform="Roblox",Key=robloxId,RobloxId=robloxId,Title="Roblox音乐编码 "..robloxId,Artist="Roblox音频"}, "Roblox")
        end

        local neteaseId = lowerCode:match("^163:(%d+)$")
            or lowerCode:match("^wy:(%d+)$")
            or lowerCode:match("music%.163%.com.-[?&]id=(%d+)")
            or lowerCode:match("music%.163%.com/song/(%d+)")
        if neteaseId then return lookupNeteaseTrackById(neteaseId) end

        local qqMid = compact:match("^[Qq][Qq]:([%w%-_]+)$")
            or compact:match("y%.qq%.com/n/ryqq/songDetail/([%w%-_]+)")
            or compact:match("[?&]songmid=([%w%-_]+)")
        if qqMid then return lookupQQTrackByMid(qqMid) end

        local kugouHash = compact:match("^[Kk][Gg]:([%x]+)$")
            or compact:match("^[Kk][Uu][Gg][Oo][Uu]:([%x]+)$")
            or compact:match("[?&#]hash=([%x]+)")
        if kugouHash then
            return normalizeTrack({
                Platform="酷狗音乐", Key=kugouHash, Hash=kugouHash,
                Title="酷狗音乐编码 "..kugouHash:sub(1,10), Artist="原平台",
            }, "酷狗音乐")
        end

        local sodaId = lowerCode:match("^qs:(%d+)$")
            or lowerCode:match("^qishui:(%d+)$")
            or lowerCode:match("[?&]track_id=(%d+)")
            or lowerCode:match("/track/(%d+)")
        if sodaId then
            return normalizeTrack({
                Platform="汽水音乐", Key=sodaId, Id=sodaId,
                Title="汽水音乐编码 "..sodaId, Artist="原平台",
            }, "汽水音乐")
        end

        local directUrl = raw:match("^[Uu][Rr][Ll]:(https?://.+)$") or raw:match("^(https?://.+)$")
        if directUrl then
            local embeddedRoblox = directUrl:match("[?&]id=(%d+)")
            if directUrl:find("roblox.com", 1, true) and embeddedRoblox then
                return normalizeTrack({Platform="Roblox",Key=embeddedRoblox,RobloxId=embeddedRoblox,Title="Roblox音乐编码 "..embeddedRoblox,Artist="Roblox音频"}, "Roblox")
            end
            return normalizeTrack({
                Platform="音乐网址", Key=stableTextHash(directUrl),
                Title="音乐网址", Artist="直接网址", PlayableUrl=directUrl, ExactPlayable=true,
            }, "音乐网址")
        end

        if compact:match("^%d+$") then
            return normalizeTrack({
                Platform="Roblox", Key=compact, RobloxId=compact,
                Title="Roblox音乐编码 "..compact, Artist="Roblox音频",
            }, "Roblox")
        end
        return nil, "无法识别编码；支持数字、163:、qq:、kg:、qs:和https网址"
    end

    local function playMusicCode(value)
        state.CodeInput = trim(value)
        state.PlayStatus = "解析音乐编码"
        task.spawn(function()
            local ok, trackOrError, parseError = pcall(parseMusicCode, state.CodeInput)
            if not ok then
                state.PlayStatus = "音乐编码解析失败"
                state.LastPlaybackError = tostring(trackOrError)
                return
            end
            local track = trackOrError
            if not track then
                state.PlayStatus = tostring(parseError or "音乐编码无效")
                return
            end
            playTrack(track, {track}, 1)
        end)
    end

    local function setCover(imageLabel, fallbackLabel, track)
        if not imageLabel or not imageLabel.Parent then
            return
        end

        local cover = track and track.Cover
        if not cover or cover == "" then
            imageLabel.Image = ""
            if fallbackLabel then
                fallbackLabel.Visible = true
            end
            return
        end

        local cached = state.CoverCache[cover]
        if cached then
            imageLabel.Image = cached
            if fallbackLabel then
                fallbackLabel.Visible = cached == ""
            end
            return
        end

        imageLabel.Image = cover
        if fallbackLabel then
            fallbackLabel.Visible = false
        end

        task.spawn(function()
            local directNames = {
                "getcustomassetfromurl",
                "getcustomasset_from_url",
                "getassetfromurl",
                "getsynassetfromurl",
                "getsynasset_from_url",
            }
            for _, name in ipairs(directNames) do
                local fn = env[name]
                if type(fn) == "function" then
                    local ok, asset = pcall(fn, cover)
                    if ok and type(asset) == "string" and asset ~= "" then
                        state.CoverCache[cover] = asset
                        if imageLabel.Parent and state.CurrentTrack == track then
                            imageLabel.Image = asset
                            if fallbackLabel then
                                fallbackLabel.Visible = false
                            end
                        end
                        return
                    end
                end
            end

            local assetLoader = getcustomasset or getsynasset
            if type(writefile) ~= "function" or type(assetLoader) ~= "function" then
                state.CoverCache[cover] = cover
                return
            end

            local ok, body = httpGet(cover, {
                ["User-Agent"] = "Mozilla/5.0",
                ["Accept"] = "image/avif,image/webp,image/png,image/jpeg,image/*,*/*;q=0.8",
            })
            if not ok or type(body) ~= "string" or #body < 128 then
                state.CoverCache[cover] = cover
                return
            end

            local path = "DB_MUSIC_COVER_" .. sanitizeFileName(cover) .. ".jpg"
            local wrote = pcall(function()
                writefile(path, body)
            end)
            if not wrote then
                state.CoverCache[cover] = cover
                return
            end

            local okAsset, asset = pcall(assetLoader, path)
            if okAsset and type(asset) == "string" and asset ~= "" then
                state.CoverCache[cover] = asset
                if imageLabel.Parent and state.CurrentTrack == track then
                    imageLabel.Image = asset
                    if fallbackLabel then
                        fallbackLabel.Visible = false
                    end
                end
            else
                state.CoverCache[cover] = cover
            end
        end)
    end

    local function musicCard(parent, size, position, z, transparency)
        local frame = Instance.new("Frame")
        frame.Size = size
        frame.Position = position or UDim2.new()
        frame.BackgroundColor3 = Color3.fromRGB(72, 72, 76)
        frame.BackgroundTransparency = transparency or 0.20
        frame.BorderSizePixel = 0
        frame.ZIndex = z or 20
        frame.Parent = parent
        AddCorner(frame, 10)

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 0.75
        stroke.Transparency = 0.62
        stroke.Color = Color3.fromRGB(210, 210, 216)
        stroke.Parent = frame
        return frame
    end

    local function musicButton(parent, text, size, position, z)
        local button = Instance.new("TextButton")
        button.Size = size
        button.Position = position or UDim2.new()
        button.BackgroundColor3 = Color3.fromRGB(45, 45, 49)
        button.BackgroundTransparency = 0.14
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = Color3.fromRGB(245, 245, 248)
        button.TextSize = 10
        button.Font = Enum.Font.GothamBold
        button.AutoButtonColor = false
        button.ZIndex = z or 25
        button.Parent = parent
        AddCorner(button, 7)
        return button
    end

    local function makeRightCard(height, order)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -12, 0, height)
        card.BackgroundColor3 = Color3.fromRGB(72, 72, 76)
        card.BackgroundTransparency = 0.28
        card.BorderSizePixel = 0
        card.LayoutOrder = order
        card.ZIndex = 20
        card.Parent = ListScroll
        AddCorner(card, 10)

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 0.75
        stroke.Transparency = 0.66
        stroke.Color = Color3.fromRGB(210, 210, 216)
        stroke.Parent = card
        return card
    end

    local function makeRightTitle(textValue, order, large)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -12, 0, large and 31 or 23)
        label.BackgroundTransparency = 1
        label.Text = textValue
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = large and 18 or 13
        label.Font = Enum.Font.GothamBlack
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.LayoutOrder = order
        label.ZIndex = 22
        label.Parent = ListScroll
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 6)
        pad.Parent = label
        return label
    end

    local function createVolumeMixer()
        if state.VolumeMixerRoot and state.VolumeMixerRoot.Parent then return state.VolumeMixerRoot end
        if not PlayerProfileScroll or not PlayerProfileScroll.Parent then return nil end

        local root = Instance.new("Frame")
        root.Name = "DB_Music_VolumeMixer"
        root.Position = UDim2.fromOffset(5, 246)
        root.Size = UDim2.new(1, -10, 0, 232)
        root.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        root.BackgroundTransparency = 0.78
        root.BorderSizePixel = 0
        root.ZIndex = 22
        root.Parent = PlayerProfileScroll
        AddCorner(root, 12)
        AddDBEnchantedBorder(root, 1.25, true)

        local title = Instance.new("TextLabel")
        title.Position = UDim2.fromOffset(8, 6)
        title.Size = UDim2.new(1, -16, 0, 16)
        title.BackgroundTransparency = 1
        title.Text = "音量控制"
        title.TextColor3 = Color3.fromRGB(245,245,248)
        title.TextSize = 9
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 24
        title.Parent = root

        local hint = Instance.new("TextLabel")
        hint.Position = UDim2.fromOffset(8, 21)
        hint.Size = UDim2.new(1, -16, 0, 13)
        hint.BackgroundTransparency = 1
        hint.Text = "纵向拖动后才接管 · 轻碰不改"
        hint.TextColor3 = Color3.fromRGB(205,205,212)
        hint.TextSize = 6
        hint.Font = Enum.Font.GothamMedium
        hint.TextXAlignment = Enum.TextXAlignment.Left
        hint.ZIndex = 24
        hint.Parent = root

        local function makeVerticalSlider(name, x, getter, setter, maxValue, suffixScale)
            local label = Instance.new("TextLabel")
            label.Position = UDim2.fromOffset(x - 20, 36)
            label.Size = UDim2.fromOffset(40, 13)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = Color3.fromRGB(238,238,242)
            label.TextSize = 7
            label.Font = Enum.Font.GothamBold
            label.ZIndex = 25
            label.Parent = root

            local hitbox = Instance.new("Frame")
            hitbox.AnchorPoint = Vector2.new(0.5, 0)
            hitbox.Position = UDim2.fromOffset(x, 51)
            hitbox.Size = UDim2.fromOffset(28, 150)
            hitbox.BackgroundTransparency = 1
            hitbox.BorderSizePixel = 0
            hitbox.Active = true
            hitbox.ZIndex = 25
            hitbox.Parent = root

            local track = Instance.new("Frame")
            track.AnchorPoint = Vector2.new(0.5, 0)
            track.Position = UDim2.fromScale(0.5, 0)
            track.Size = UDim2.fromOffset(8, 150)
            track.BackgroundColor3 = Color3.fromRGB(38,38,42)
            track.BackgroundTransparency = 0.16
            track.BorderSizePixel = 0
            track.ZIndex = 26
            track.Parent = hitbox
            AddCorner(track, 99)

            local fill = Instance.new("Frame")
            fill.AnchorPoint = Vector2.new(0, 1)
            fill.Position = UDim2.fromScale(0, 1)
            fill.Size = UDim2.fromScale(1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(235,235,240)
            fill.BorderSizePixel = 0
            fill.ZIndex = 27
            fill.Parent = track
            AddCorner(fill, 99)

            local knob = Instance.new("Frame")
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Position = UDim2.fromScale(0.5, 0.5)
            knob.Size = UDim2.fromOffset(15, 8)
            knob.BackgroundColor3 = Color3.fromRGB(250,250,252)
            knob.BorderSizePixel = 0
            knob.ZIndex = 28
            knob.Parent = hitbox
            AddCorner(knob, 99)

            local valueLabel = Instance.new("TextLabel")
            valueLabel.Position = UDim2.fromOffset(x - 20, 205)
            valueLabel.Size = UDim2.fromOffset(40, 15)
            valueLabel.BackgroundTransparency = 1
            valueLabel.TextColor3 = Color3.fromRGB(238,238,242)
            valueLabel.TextSize = 7
            valueLabel.Font = Enum.Font.GothamMedium
            valueLabel.ZIndex = 25
            valueLabel.Parent = root

            local dragging = false
            local dragInput = nil
            local lastRatio = nil
            local previousScrollEnabled = nil

            local function lockProfileScroll(lock)
                if not PlayerProfileScroll or not PlayerProfileScroll.Parent then return end
                if lock then
                    if previousScrollEnabled == nil then previousScrollEnabled = PlayerProfileScroll.ScrollingEnabled end
                    PlayerProfileScroll.ScrollingEnabled = false
                else
                    if previousScrollEnabled ~= nil then PlayerProfileScroll.ScrollingEnabled = previousScrollEnabled end
                    previousScrollEnabled = nil
                end
            end

            local function refresh()
                local value = math.clamp(getter(), 0, maxValue)
                local ratio = maxValue > 0 and value / maxValue or 0
                fill.Size = UDim2.fromScale(1, ratio)
                knob.Position = UDim2.fromScale(0.5, 1 - ratio)
                valueLabel.Text = tostring(math.floor(value * suffixScale + 0.5)) .. "%"
                lastRatio = ratio
            end

            local function updateFromInput(pos)
                local y = DBSpatial and DBSpatial.InputAxis and DBSpatial.InputAxis(track, pos, "Y") or (pos and pos.Y)
                if not y then return end
                local ratio = 1 - math.clamp(
                    (y - track.AbsolutePosition.Y) / math.max(1, track.AbsoluteSize.Y),
                    0,
                    1
                )
                if lastRatio and math.abs(ratio - lastRatio) < 0.0015 then return end
                setter(ratio * maxValue)
                refresh()
            end

            hitbox.InputBegan:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.MouseButton1
                    and input.UserInputType ~= Enum.UserInputType.Touch then return end
                dragInput = input
                dragging = true
                lockProfileScroll(true)
                updateFromInput(input.Position)
            end)

            UIS.InputChanged:Connect(function(input)
                if not hitbox.Parent or not dragInput or not dragging then return end
                local valid = input.UserInputType == Enum.UserInputType.MouseMovement
                    or (input.UserInputType == Enum.UserInputType.Touch and input == dragInput)
                if valid then updateFromInput(input.Position) end
            end)

            UIS.InputEnded:Connect(function(input)
                if dragInput and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1) then
                    dragging = false
                    dragInput = nil
                    lockProfileScroll(false)
                end
            end)

            refresh()
            return refresh
        end

        local refreshGame = makeVerticalSlider(
            "游戏", 29,
            function() return state.GameVolume end,
            setGameVolume, 1.0, 100
        )
        local refreshMusic = makeVerticalSlider(
            "音乐", 66,
            function() return state.MusicVolume end,
            setMusicVolume, 4.0, 100
        )
        root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            refreshGame()
            refreshMusic()
        end)

        PlayerProfileScroll.CanvasSize = UDim2.fromOffset(0, 500)
        state.VolumeMixerRoot = root
        return root
    end

    local function clearNormalPage()
        state.SearchToken = state.SearchToken + 1
        state.Searching = false
        DBClearRightList()
        State.CurrentCategory = "音乐播放器"
        local keep = {}
        for _, popup in ipairs(state.SearchPopups) do
            if popup.Host == RightList then
                if popup.Root and popup.Root.Parent then
                    popup.Root:Destroy()
                end
            else
                keep[#keep + 1] = popup
            end
        end
        state.SearchPopups = keep
    end

    local function createHorizontalChips(parent, items, selectedValue, callback, z)
        local scroller = Instance.new("ScrollingFrame")
        scroller.Size = UDim2.fromScale(1, 1)
        scroller.BackgroundTransparency = 1
        scroller.BorderSizePixel = 0
        scroller.ScrollBarThickness = 0
        scroller.AutomaticCanvasSize = Enum.AutomaticSize.X
        scroller.CanvasSize = UDim2.new()
        scroller.ScrollingDirection = Enum.ScrollingDirection.X
        scroller.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
        scroller.ZIndex = z or 24
        scroller.Parent = parent

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.Padding = UDim.new(0, 5)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Parent = scroller

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 5)
        pad.PaddingRight = UDim.new(0, 5)
        pad.Parent = scroller

        for index, value in ipairs(items) do
            local measured = TextService:GetTextSize(
                tostring(value),
                9,
                Enum.Font.GothamBold,
                Vector2.new(240, 28)
            )
            local width = math.clamp(measured.X + 22, 48, 92)
            local button = musicButton(
                scroller,
                tostring(value),
                UDim2.fromOffset(width, 23),
                UDim2.new(),
                (z or 24) + 1
            )
            button.LayoutOrder = index
            if value == selectedValue then
                button.BackgroundColor3 = Color3.fromRGB(92, 92, 98)
                button.BackgroundTransparency = 0.02
            end
            button.Activated:Connect(function()
                callback(value)
            end)
        end
        return scroller
    end

    local function createSearchPopup(host, anchor, z)
        for index = #state.SearchPopups, 1, -1 do
            local old = state.SearchPopups[index]
            if not old or not old.Root or not old.Root.Parent or not old.Host or not old.Host.Parent then
                table.remove(state.SearchPopups, index)
            end
        end
        local root = Instance.new("Frame")
        root.Name = "DB_Music_SearchPopup"
        root.BackgroundColor3 = Color3.fromRGB(35, 35, 39)
        root.BackgroundTransparency = 0.04
        root.BorderSizePixel = 0
        root.Visible = false
        root.ClipsDescendants = true
        root.ZIndex = z
        root.Parent = host
        AddCorner(root, 10)

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 0.8
        stroke.Transparency = 0.42
        stroke.Color = Color3.fromRGB(225, 225, 232)
        stroke.Parent = root

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -8, 1, -8)
        scroll.Position = UDim2.fromOffset(4, 4)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 2
        scroll.ScrollBarImageColor3 = Color3.fromRGB(205, 205, 210)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.CanvasSize = UDim2.new()
        scroll.ScrollingDirection = Enum.ScrollingDirection.Y
        scroll.ZIndex = z + 1
        scroll.Parent = root

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 3)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = scroll

        local popup = {
            Root = root,
            Scroll = scroll,
            Layout = layout,
            Host = host,
            Anchor = anchor,
            Z = z,
        }
        state.SearchPopups[#state.SearchPopups + 1] = popup
        return popup
    end

    local function positionSearchPopup(popup, maxHeight)
        if not popup.Root.Parent or not popup.Anchor.Parent or not popup.Host.Parent then
            return
        end
        local hostPos = popup.Host.AbsolutePosition
        local anchorPos = popup.Anchor.AbsolutePosition
        local x = anchorPos.X - hostPos.X
        local y = anchorPos.Y - hostPos.Y + popup.Anchor.AbsoluteSize.Y + 4
        local width = popup.Anchor.AbsoluteSize.X
        local available = popup.Host.AbsoluteSize.Y - y - 5
        local height = math.clamp(maxHeight or 190, 90, math.max(90, available))
        popup.Root.Position = UDim2.fromOffset(x, y)
        popup.Root.Size = UDim2.fromOffset(width, math.min(maxHeight or 190, height))
    end

    local function clearPopupRows(popup)
        for _, child in ipairs(popup.Scroll:GetChildren()) do
            if child:IsA("GuiObject") and child ~= popup.Layout then
                child:Destroy()
            end
        end
    end

    local function showSearchPopup(popup, results, loadingText)
        if not popup.Root.Parent then
            return
        end
        clearPopupRows(popup)
        positionSearchPopup(popup, popup.Host == RightList and 185 or 205)
        popup.Root.Visible = true

        if loadingText then
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -6, 0, 34)
            label.BackgroundTransparency = 1
            label.Text = loadingText
            label.TextColor3 = Color3.fromRGB(228, 228, 234)
            label.TextSize = 10
            label.Font = Enum.Font.GothamMedium
            label.TextWrapped = true
            label.ZIndex = popup.Z + 2
            label.Parent = popup.Scroll
            return
        end

        if #results == 0 then
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -6, 0, 42)
            label.BackgroundTransparency = 1
            label.Text = state.Platform == "汽水音乐"
                and "暂无结果 · 汽水公开接口可能临时受签名限制"
                or "暂无搜索结果"
            label.TextColor3 = Color3.fromRGB(228, 228, 234)
            label.TextSize = 9
            label.Font = Enum.Font.GothamMedium
            label.TextWrapped = true
            label.ZIndex = popup.Z + 2
            label.Parent = popup.Scroll
            return
        end

        for index, track in ipairs(results) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -4, 0, 38)
            row.BackgroundColor3 = Color3.fromRGB(61, 61, 66)
            row.BackgroundTransparency = 0.16
            row.BorderSizePixel = 0
            row.LayoutOrder = index
            row.ZIndex = popup.Z + 2
            row.Parent = popup.Scroll
            AddCorner(row, 7)

            local playArea = Instance.new("TextButton")
            playArea.Size = UDim2.new(1, -40, 1, 0)
            playArea.BackgroundTransparency = 1
            playArea.BorderSizePixel = 0
            playArea.Text = ""
            playArea.AutoButtonColor = false
            playArea.ZIndex = popup.Z + 3
            playArea.Parent = row

            local title = Instance.new("TextLabel")
            title.Position = UDim2.fromOffset(8, 3)
            title.Size = UDim2.new(1, -8, 0, 17)
            title.BackgroundTransparency = 1
            title.Text = track.Title
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.TextSize = 9
            title.Font = Enum.Font.GothamBold
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.TextTruncate = Enum.TextTruncate.AtEnd
            title.ZIndex = popup.Z + 4
            title.Parent = playArea

            local meta = Instance.new("TextLabel")
            meta.Position = UDim2.fromOffset(8, 19)
            meta.Size = UDim2.new(1, -8, 0, 14)
            meta.BackgroundTransparency = 1
            meta.Text = track.Artist .. " · " .. track.Platform
            meta.TextColor3 = Color3.fromRGB(205, 205, 212)
            meta.TextSize = 8
            meta.Font = Enum.Font.GothamMedium
            meta.TextXAlignment = Enum.TextXAlignment.Left
            meta.TextTruncate = Enum.TextTruncate.AtEnd
            meta.ZIndex = popup.Z + 4
            meta.Parent = playArea

            local add = musicButton(row, "+", UDim2.fromOffset(28, 28), UDim2.new(1, -34, 0.5, -14), popup.Z + 5)
            add.TextSize = 15

            playArea.Activated:Connect(function()
                state.SearchResults = results
                playTrack(track, results, index)
                popup.Root.Visible = false
            end)

            add.Activated:Connect(function()
                local ok = addToPlaylist(track)
                add.Text = ok and "✓" or "有"
                task.delay(0.7, function()
                    if add.Parent then add.Text = "+" end
                end)
            end)
        end
    end

    local function bindSearchBox(searchBox, popup)
        local debounce = 0
        local focused = false

        local function launch()
            local keyword = trim(searchBox.Text)
            if keyword == "" then
                popup.Root.Visible = false
                state.SearchResults = {}
                return
            end
            state.SearchKeyword = keyword
            showSearchPopup(popup, {}, "搜索中…")
            performSearch(keyword, function(_, results)
                if searchBox.Parent and trim(searchBox.Text) == keyword then
                    showSearchPopup(popup, results)
                end
            end)
        end

        searchBox.Focused:Connect(function()
            focused = true
            state.LastSearchUserEdit = os.clock()
        end)

        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            if not focused or not searchBox:IsFocused() then return end
            debounce = debounce + 1
            local token = debounce
            local keyword = trim(searchBox.Text)
            state.LastSearchUserEdit = os.clock()
            if keyword == "" then
                popup.Root.Visible = false
                state.SearchResults = {}
                return
            end
            task.delay(0.42, function()
                if token == debounce
                    and focused
                    and searchBox.Parent
                    and searchBox:IsFocused()
                    and trim(searchBox.Text) == keyword
                    and os.clock() - (state.LastSearchUserEdit or 0) >= 0.36
                then
                    launch()
                end
            end)
        end)

        searchBox.FocusLost:Connect(function(enterPressed)
            focused = false
            debounce = debounce + 1
            if enterPressed then
                launch()
                return
            end
            task.delay(0.20, function()
                if popup.Root and popup.Root.Parent and not searchBox:IsFocused() then
                    popup.Root.Visible = false
                end
            end)
        end)

        return launch
    end

    local function createMirrorVisualizer(parent, count, z)
        local holder = Instance.new("Frame")
        holder.Size = UDim2.fromScale(1, 1)
        holder.BackgroundTransparency = 1
        holder.ClipsDescendants = true
        holder.ZIndex = z
        holder.Parent = parent

        local baseline = Instance.new("Frame")
        baseline.AnchorPoint = Vector2.new(0.5, 1)
        baseline.Position = UDim2.fromScale(0.5, 0.94)
        baseline.Size = UDim2.new(0.988, 0, 0, 1)
        baseline.BackgroundColor3 = Color3.fromRGB(200, 205, 214)
        baseline.BackgroundTransparency = 0.88
        baseline.BorderSizePixel = 0
        baseline.ZIndex = z
        baseline.Parent = holder

        local bars = {}
        count = math.max(24, math.floor(tonumber(count) or 48))
        local leftEdge = 0.012
        local usable = 0.976
        local cell = usable / count
        local widthScale = cell * 0.74
        for i = 1, count do
            local bar = Instance.new("Frame")
            bar.AnchorPoint = Vector2.new(0.5, 1)
            bar.Position = UDim2.new(leftEdge + (i - 0.5) * cell, 0, 0.94, 0)
            bar.Size = UDim2.new(widthScale, 0, 0.026, 0)
            bar.BackgroundColor3 = Color3.fromRGB(244, 190, 36)
            bar.BackgroundTransparency = 0.04
            bar.BorderSizePixel = 0
            bar.ZIndex = z + 1
            bar.Parent = holder
            AddCorner(bar, 2)
            bars[i] = {bar}
        end
        return holder, bars
    end

    local function createPlaybackVisualizer(parent, count, z)
        return createMirrorVisualizer(parent, math.max(28, math.floor(tonumber(count) or 44)), z)
    end

    local function bindSeek(progressBack)
        local dragging = false
        local dragInput = nil

        local function seek(pos)
            local x = DBSpatial and DBSpatial.InputAxis and DBSpatial.InputAxis(progressBack, pos, "X") or (pos and pos.X)
            if not x then return end
            local ratio = math.clamp(
                (x - progressBack.AbsolutePosition.X) / math.max(1, progressBack.AbsoluteSize.X),
                0,
                1
            )
            local length = state.Playback.TimeLength()
            if length > 0 then state.Playback.Seek(length * ratio) end
        end

        progressBack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch
            then
                dragging = true
                dragInput = input
                seek(input.Position)
            end
        end)

        UIS.InputChanged:Connect(function(input)
            if not dragging or not progressBack.Parent then
                return
            end
            local valid = input.UserInputType == Enum.UserInputType.MouseMovement
                or (input.UserInputType == Enum.UserInputType.Touch and input == dragInput)
            if valid then
                seek(input.Position)
            end
        end)

        UIS.InputEnded:Connect(function(input)
            if not dragging then
                return
            end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input == dragInput then
                dragging = false
                dragInput = nil
            end
        end)
    end

    local function registerPlayerView(view)
        state.Views[#state.Views + 1] = view
        return view
    end

    local function buildCompactPlayer(parent, layoutOrder)
        local card
        if parent == ListScroll then
            card = makeRightCard(96, layoutOrder)
        else
            card = musicCard(parent, UDim2.fromScale(1, 1), UDim2.new(), 690, 0.18)
        end

        local art = Instance.new("ImageLabel")
        art.Position = UDim2.fromOffset(8, 9)
        art.Size = UDim2.fromOffset(58, 58)
        art.BackgroundColor3 = Color3.fromRGB(48, 48, 52)
        art.BackgroundTransparency = 0.06
        art.BorderSizePixel = 0
        art.Image = ""
        art.ScaleType = Enum.ScaleType.Crop
        art.ZIndex = card.ZIndex + 2
        art.Parent = card
        AddCorner(art, 8)

        local artFallback = Instance.new("TextLabel")
        artFallback.Size = UDim2.fromScale(1, 1)
        artFallback.BackgroundTransparency = 1
        artFallback.Text = "♫"
        artFallback.TextColor3 = Color3.fromRGB(220, 220, 224)
        artFallback.TextSize = 22
        artFallback.Font = Enum.Font.GothamBlack
        artFallback.ZIndex = art.ZIndex + 1
        artFallback.Parent = art

        local title = Instance.new("TextLabel")
        title.Position = UDim2.fromOffset(74, 8)
        title.Size = UDim2.new(1, -118, 0, 20)
        title.BackgroundTransparency = 1
        title.Text = "尚未播放"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 11
        title.Font = Enum.Font.GothamBlack
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextTruncate = Enum.TextTruncate.AtEnd
        title.ZIndex = card.ZIndex + 2
        title.Parent = card

        local artist = Instance.new("TextLabel")
        artist.Position = UDim2.fromOffset(74, 28)
        artist.Size = UDim2.new(1, -118, 0, 16)
        artist.BackgroundTransparency = 1
        artist.Text = "选择一首音乐"
        artist.TextColor3 = Color3.fromRGB(205, 205, 212)
        artist.TextSize = 8
        artist.Font = Enum.Font.GothamMedium
        artist.TextXAlignment = Enum.TextXAlignment.Left
        artist.TextTruncate = Enum.TextTruncate.AtEnd
        artist.ZIndex = card.ZIndex + 2
        artist.Parent = card

        local add = musicButton(
            card,
            "+",
            UDim2.fromOffset(28, 28),
            UDim2.new(1, -34, 0, 8),
            card.ZIndex + 3
        )
        add.TextSize = 15
        add.Activated:Connect(function()
            if state.CurrentTrack then
                local ok = addToPlaylist(state.CurrentTrack)
                add.Text = ok and "✓" or "有"
                task.delay(0.7, function()
                    if add.Parent then
                        add.Text = "+"
                    end
                end)
            end
        end)

        local previous = musicButton(
            card,
            "◀",
            UDim2.fromOffset(32, 26),
            UDim2.new(0, 74, 0, 48),
            card.ZIndex + 3
        )
        local pause = musicButton(
            card,
            "▶",
            UDim2.fromOffset(38, 30),
            UDim2.new(0, 111, 0, 46),
            card.ZIndex + 3
        )
        pause.TextSize = 12
        local next = musicButton(
            card,
            "▶|",
            UDim2.fromOffset(32, 26),
            UDim2.new(0, 154, 0, 48),
            card.ZIndex + 3
        )

        previous.Activated:Connect(previousTrack)
        pause.Activated:Connect(togglePause)
        next.Activated:Connect(function()
            nextTrack(false)
        end)

        local progressBack = Instance.new("Frame")
        progressBack.Position = UDim2.new(0, 74, 1, -14)
        progressBack.Size = UDim2.new(1, -82, 0, 5)
        progressBack.BackgroundColor3 = Color3.fromRGB(128, 128, 134)
        progressBack.BackgroundTransparency = 0.28
        progressBack.BorderSizePixel = 0
        progressBack.Active = true
        progressBack.ZIndex = card.ZIndex + 3
        progressBack.Parent = card
        AddCorner(progressBack, 99)

        local progressFill = Instance.new("Frame")
        progressFill.Size = UDim2.fromScale(0, 1)
        progressFill.BackgroundColor3 = Color3.fromRGB(235, 235, 240)
        progressFill.BorderSizePixel = 0
        progressFill.ZIndex = card.ZIndex + 4
        progressFill.Parent = progressBack
        AddCorner(progressFill, 99)
        bindSeek(progressBack)

        local status = Instance.new("TextLabel")
        status.AnchorPoint = Vector2.new(1, 0)
        status.Position = UDim2.new(1, -8, 0, 49)
        status.Size = UDim2.new(0, 96, 0, 18)
        status.BackgroundTransparency = 1
        status.Text = ""
        status.TextColor3 = Color3.fromRGB(190, 190, 198)
        status.TextSize = 7
        status.Font = Enum.Font.GothamMedium
        status.TextXAlignment = Enum.TextXAlignment.Right
        status.TextTruncate = Enum.TextTruncate.AtEnd
        status.ZIndex = card.ZIndex + 2
        status.Parent = card

        return registerPlayerView({
            Root = card,
            Title = title,
            Artist = artist,
            Art = art,
            ArtFallback = artFallback,
            PlayButton = pause,
            ProgressFill = progressFill,
            Status = status,
            LastTrack = nil,
        })
    end

    local function buildAdvancedPlayer(parent)
        local title = Instance.new("TextLabel")
        title.Position = UDim2.fromOffset(8, 3)
        title.Size = UDim2.new(1, -86, 0, 15)
        title.BackgroundTransparency = 1
        title.Text = "尚未播放"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 11
        title.Font = Enum.Font.GothamBlack
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextTruncate = Enum.TextTruncate.AtEnd
        title.ZIndex = 714
        title.Parent = parent

        local status = Instance.new("TextLabel")
        status.AnchorPoint = Vector2.new(1, 0)
        status.Position = UDim2.new(1, -38, 0, 4)
        status.Size = UDim2.fromOffset(70, 14)
        status.BackgroundTransparency = 1
        status.Text = "选择歌曲"
        status.TextColor3 = Color3.fromRGB(198, 198, 205)
        status.TextSize = 8
        status.Font = Enum.Font.GothamMedium
        status.TextXAlignment = Enum.TextXAlignment.Right
        status.TextTruncate = Enum.TextTruncate.AtEnd
        status.ZIndex = 714
        status.Parent = parent

        local add = musicButton(
            parent,
            "+",
            UDim2.fromOffset(26, 24),
            UDim2.new(1, -30, 0, 3),
            716
        )
        add.TextSize = 14
        add.Activated:Connect(function()
            if state.CurrentTrack then
                local ok = addToPlaylist(state.CurrentTrack)
                add.Text = ok and "✓" or "有"
                task.delay(0.7, function()
                    if add.Parent then
                        add.Text = "+"
                    end
                end)
            end
        end)

        local previous = musicButton(parent, "◀", UDim2.fromOffset(29, 23), UDim2.new(0.5, -57, 0.56, -11), 716)
        local pause = musicButton(parent, "▶", UDim2.fromOffset(36, 27), UDim2.new(0.5, -18, 0.56, -13), 716)
        local next = musicButton(parent, "▶|", UDim2.fromOffset(29, 23), UDim2.new(0.5, 28, 0.56, -11), 716)
        pause.TextSize = 11
        previous.Activated:Connect(previousTrack)
        pause.Activated:Connect(togglePause)
        next.Activated:Connect(function()
            nextTrack(false)
        end)

        local progressBack = Instance.new("Frame")
        progressBack.AnchorPoint = Vector2.new(0, 1)
        progressBack.Position = UDim2.new(0, 8, 1, -6)
        progressBack.Size = UDim2.new(1, -16, 0, 4)
        progressBack.BackgroundColor3 = Color3.fromRGB(128, 128, 134)
        progressBack.BackgroundTransparency = 0.28
        progressBack.BorderSizePixel = 0
        progressBack.Active = true
        progressBack.ZIndex = 715
        progressBack.Parent = parent
        AddCorner(progressBack, 99)

        local progressFill = Instance.new("Frame")
        progressFill.Size = UDim2.fromScale(0, 1)
        progressFill.BackgroundColor3 = Color3.fromRGB(236, 236, 240)
        progressFill.BorderSizePixel = 0
        progressFill.ZIndex = 716
        progressFill.Parent = progressBack
        AddCorner(progressFill, 99)
        bindSeek(progressBack)

        return registerPlayerView({
            Root = parent,
            Title = title,
            Artist = nil,
            Art = nil,
            ArtFallback = nil,
            PlayButton = pause,
            ProgressFill = progressFill,
            Status = status,
            LastTrack = nil,
        })
    end

    local function fetchHotNetease()
        local ok, body = httpGet(
            "https://music.163.com/api/playlist/detail?id=3778678&updateTime=-1",
            {
                ["User-Agent"] = "Mozilla/5.0",
                ["Referer"] = "https://music.163.com/",
            }
        )
        if not ok then
            return {}
        end
        local data = decodeJsonBody(body)
        local songs = data and data.result and data.result.tracks
        if type(songs) ~= "table" then
            return {}
        end
        local out = {}
        for index, raw in ipairs(songs) do
            if index > 15 then
                break
            end
            local album = raw.album or raw.al or {}
            local track = normalizeTrack({
                Platform = "网易云音乐",
                Key = raw.id,
                Id = raw.id,
                Title = raw.name,
                Artist = joinArtists(raw.artists or raw.ar),
                Album = album.name,
                Duration = raw.duration or raw.dt,
                Cover = album.picUrl,
                HotScore = 20000 - index,
            }, "网易云音乐")
            if track then
                out[#out + 1] = track
            end
        end
        return out
    end

    local function fetchHotQQ()
        local ok, body = httpGet(
            "https://c.y.qq.com/v8/fcg-bin/fcg_v8_toplist_cp.fcg?topid=26&format=json",
            {
                ["User-Agent"] = "Mozilla/5.0",
                ["Referer"] = "https://y.qq.com/",
            }
        )
        if not ok then
            return {}
        end
        local data = decodeJsonBody(body)
        local songlist = data and data.songlist
        if type(songlist) ~= "table" then
            return {}
        end
        local out = {}
        for index, item in ipairs(songlist) do
            if index > 15 then
                break
            end
            local raw = item.data or item
            local cover = nil
            if raw.albummid and raw.albummid ~= "" then
                cover = "https://y.gtimg.cn/music/photo_new/T002R300x300M000"
                    .. tostring(raw.albummid)
                    .. ".jpg?max_age=2592000"
            end
            local track = normalizeTrack({
                Platform = "QQ音乐",
                Key = raw.songmid,
                SongMid = raw.songmid,
                MediaMid = raw.media_mid or (raw.file and raw.file.media_mid),
                Title = raw.songname,
                Artist = joinArtists(raw.singer),
                Album = raw.albumname,
                Duration = raw.interval,
                Cover = cover,
                HotScore = 20000 - index,
            }, "QQ音乐")
            if track then
                out[#out + 1] = track
            end
        end
        return out
    end

    local function fetchHotKugou()
        local urls = {
            "https://mobilecdnbj.kugou.com/api/v3/rank/newsong?version=9108&plat=0&with_cover=1&pagesize=15&type=1&area_code=1&page=1&with_res_tag=1",
            "https://mobilecdnbj.kugou.com/api/v3/rank/song?rankid=8888&page=1&pagesize=15&plat=0&version=9108",
        }
        for _, url in ipairs(urls) do
            local ok, body = httpGet(url, platformHeaders("酷狗音乐", {
                ["User-Agent"] = "Mozilla/5.0",
                ["Referer"] = "https://www.kugou.com/",
            }))
            if ok then
                local data = decodeJsonBody(body)
                local songs = data and data.data and data.data.info
                local out = parseKugouSongs(songs)
                if #out > 0 then
                    for index, track in ipairs(out) do track.HotScore = 20000 - index end
                    return out
                end
            end
        end
        local fallback = searchKugou("热门")
        for index, track in ipairs(fallback) do track.HotScore = 20000 - index end
        return fallback
    end

    local function fetchHot(platform)
        local cached = state.AdvancedHotCache[platform]
        if cached and os.clock() - cached.Time < 120 then
            return cached.Tracks
        end

        local custom = currentProvider()
        if type(custom) == "table" and custom.ExactCatalog == true and type(custom.Hot) == "function" then
            local ok, result = pcall(custom.Hot, platform)
            if ok and type(result) == "table" then
                local tracks = {}
                for index, raw in ipairs(result) do
                    local track = normalizeTrack(raw, platform)
                    if track then
                        if track.HotScore == 0 then
                            track.HotScore = 20000 - index
                        end
                        tracks[#tracks + 1] = track
                    end
                end
                if #tracks > 0 then
                    state.AdvancedHotCache[platform] = {Time = os.clock(), Tracks = tracks}
                    return tracks
                end
            end
        end

        local tracks = {}
        if platform == "网易云音乐" then
            tracks = fetchHotNetease()
        elseif platform == "QQ音乐" then
            tracks = fetchHotQQ()
        elseif platform == "酷狗音乐" then
            tracks = fetchHotKugou()
        elseif platform == "汽水音乐" then
            tracks = searchSoda("热门")
        end

        state.AdvancedHotCache[platform] = {Time = os.clock(), Tracks = tracks}
        return tracks
    end

    local function renderHotPanel()
        local host = state.AdvancedHotHost
        if not host or not host.Parent then
            return
        end

        for _, child in ipairs(host:GetChildren()) do
            if child:IsA("GuiObject") then
                child:Destroy()
            end
        end

        local platform = REAL_PLATFORMS[state.AdvancedHotIndex]
        local title = Instance.new("TextLabel")
        title.Position = UDim2.fromOffset(7, 5)
        title.Size = UDim2.new(1, -14, 0, 22)
        title.BackgroundTransparency = 1
        title.Text = platform .. " · 热度榜"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 11
        title.Font = Enum.Font.GothamBlack
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 705
        title.Parent = host

        local page = Instance.new("TextLabel")
        page.AnchorPoint = Vector2.new(1, 0)
        page.Position = UDim2.new(1, -6, 0, 5)
        page.Size = UDim2.fromOffset(32, 22)
        page.BackgroundTransparency = 1
        page.Text = tostring(state.AdvancedHotIndex) .. "/4"
        page.TextColor3 = Color3.fromRGB(190, 190, 198)
        page.TextSize = 8
        page.Font = Enum.Font.GothamMedium
        page.TextXAlignment = Enum.TextXAlignment.Right
        page.ZIndex = 706
        page.Parent = host

        local scroll = Instance.new("ScrollingFrame")
        scroll.Position = UDim2.fromOffset(5, 30)
        scroll.Size = UDim2.new(1, -10, 1, -35)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 2
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.CanvasSize = UDim2.new()
        scroll.ScrollingDirection = Enum.ScrollingDirection.Y
        scroll.ZIndex = 705
        scroll.Parent = host

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 3)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = scroll

        local cached = state.AdvancedHotCache[platform]
        if not cached then
            local loading = Instance.new("TextLabel")
            loading.Size = UDim2.new(1, -4, 0, 40)
            loading.BackgroundTransparency = 1
            loading.Text = "加载热度榜…"
            loading.TextColor3 = Color3.fromRGB(200, 200, 206)
            loading.TextSize = 8
            loading.Font = Enum.Font.GothamMedium
            loading.ZIndex = 706
            loading.Parent = scroll

            if not state.AdvancedHotLoading[platform] then
                state.AdvancedHotLoading[platform] = true
                task.spawn(function()
                    pcall(fetchHot, platform)
                    state.AdvancedHotLoading[platform] = nil
                    if state.AdvancedRoot
                        and state.AdvancedRoot.Parent
                        and REAL_PLATFORMS[state.AdvancedHotIndex] == platform
                    then
                        renderHotPanel()
                    end
                end)
            end
            return
        end

        local tracks = cached.Tracks or {}
        if #tracks == 0 then
            local empty = Instance.new("TextLabel")
            empty.Size = UDim2.new(1, -4, 0, 50)
            empty.BackgroundTransparency = 1
            empty.Text = platform == "汽水音乐"
                and "汽水热榜源暂时没有返回数据"
                or "暂时没有热榜数据"
            empty.TextColor3 = Color3.fromRGB(200, 200, 206)
            empty.TextSize = 8
            empty.Font = Enum.Font.GothamMedium
            empty.TextWrapped = true
            empty.ZIndex = 706
            empty.Parent = scroll
            return
        end

        for index, track in ipairs(tracks) do
            if index > 12 then
                break
            end
            local row = Instance.new("TextButton")
            row.Size = UDim2.new(1, -4, 0, 29)
            row.BackgroundColor3 = Color3.fromRGB(54, 54, 58)
            row.BackgroundTransparency = 0.20
            row.BorderSizePixel = 0
            row.Text = ""
            row.AutoButtonColor = false
            row.LayoutOrder = index
            row.ZIndex = 706
            row.Parent = scroll
            AddCorner(row, 6)

            local rank = Instance.new("TextLabel")
            rank.Position = UDim2.fromOffset(5, 0)
            rank.Size = UDim2.fromOffset(20, 29)
            rank.BackgroundTransparency = 1
            rank.Text = tostring(index)
            rank.TextColor3 = index <= 3
                and Color3.fromRGB(255, 255, 255)
                or Color3.fromRGB(180, 180, 188)
            rank.TextSize = 10
            rank.Font = Enum.Font.GothamBlack
            rank.ZIndex = 707
            rank.Parent = row

            local label = Instance.new("TextLabel")
            label.Position = UDim2.fromOffset(26, 3)
            label.Size = UDim2.new(1, -31, 1, -6)
            label.BackgroundTransparency = 1
            label.Text = track.Title .. "\n" .. track.Artist
            label.TextColor3 = Color3.fromRGB(238, 238, 242)
            label.TextSize = 9
            label.Font = Enum.Font.GothamMedium
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextYAlignment = Enum.TextYAlignment.Center
            label.TextTruncate = Enum.TextTruncate.AtEnd
            label.ZIndex = 707
            label.Parent = row

            row.Activated:Connect(function()
                playTrack(track, tracks, index)
            end)
        end
    end

    local function setAdvancedHotIndex(index)
        state.AdvancedHotIndex = ((index - 1) % #REAL_PLATFORMS) + 1
        state.AdvancedLastSwipe = os.clock()
        renderHotPanel()
    end

    local function setAdvancedPanelOwnership(active)
        if active then
            if not state.AdvancedOldPanelStrokes then state.AdvancedOldPanelStrokes = {} end
            local advancedRoot = state.AdvancedRoot
            for _, child in ipairs(Panel:GetDescendants()) do
                if child:IsA("UIStroke")
                    and child ~= PanelBorder
                    and not (advancedRoot and child:IsDescendantOf(advancedRoot))
                then
                    if state.AdvancedOldPanelStrokes[child] == nil then
                        state.AdvancedOldPanelStrokes[child] = child.Enabled
                    end
                    child.Enabled = false
                end
            end
            if state.AdvancedOldPanelBackgroundTransparency == nil then
                state.AdvancedOldPanelBackgroundTransparency = Panel.BackgroundTransparency
                state.AdvancedOldPanelClipsDescendants = Panel.ClipsDescendants
            end
            Panel.BackgroundTransparency = 1
            Panel.ClipsDescendants = false
        else
            for stroke, enabled in pairs(state.AdvancedOldPanelStrokes or {}) do
                if stroke and stroke.Parent then stroke.Enabled = enabled end
            end
            state.AdvancedOldPanelStrokes = nil
            if state.AdvancedOldPanelBackgroundTransparency ~= nil then
                Panel.BackgroundTransparency = state.AdvancedOldPanelBackgroundTransparency
                Panel.ClipsDescendants = state.AdvancedOldPanelClipsDescendants == true
            end
            state.AdvancedOldPanelBackgroundTransparency = nil
            state.AdvancedOldPanelClipsDescendants = nil
        end
    end

    local function buildAdvancedMode()
        if state.AdvancedRoot and state.AdvancedRoot.Parent then
            return state.AdvancedRoot
        end

        local root = Instance.new("Frame")
        root.Name = "DB_Music_Advanced"
        root.Position = UDim2.fromScale(0, 0)
        root.Size = UDim2.fromScale(1, 1)
        root.BackgroundTransparency = 1
        root.BorderSizePixel = 0
        root.ClipsDescendants = false
        root.ZIndex = 600
        root.Parent = Panel

        local surface = Instance.new("CanvasGroup")
        surface.Name = "AdvancedSurface"
        surface.Position = UDim2.fromOffset(2, 2)
        surface.Size = UDim2.new(1, -4, 1, -4)
        surface.BackgroundColor3 = Color3.fromRGB(5, 5, 7)
        surface.BackgroundTransparency = 0.08
        surface.BorderSizePixel = 0
        surface.ClipsDescendants = true
        surface.GroupTransparency = 0
        surface.GroupColor3 = Color3.fromRGB(255, 255, 255)
        surface.ZIndex = 600
        surface.Parent = root
        AddCorner(surface, CORNER_RADIUS)

        local advWallpaper = Instance.new("ImageLabel")
        advWallpaper.Name = "AdvancedWallpaper"
        advWallpaper.Position = UDim2.fromScale(0, 0)
        advWallpaper.Size = UDim2.fromScale(1, 1)
        advWallpaper.BackgroundTransparency = 1
        advWallpaper.BorderSizePixel = 0
        advWallpaper.ScaleType = Enum.ScaleType.Crop
        advWallpaper.ZIndex = 601
        advWallpaper.Parent = surface
        AddCorner(advWallpaper, CORNER_RADIUS)
        local function syncAdvancedWallpaper()
            if DBWallpaper and DBWallpaper.Layer then
                advWallpaper.Image = DBWallpaper.Layer.Image
                advWallpaper.ImageColor3 = DBWallpaper.Layer.ImageColor3
                advWallpaper.ImageTransparency = math.clamp((DBWallpaper.Layer.ImageTransparency or 0.45) + 0.12, 0, 1)
            end
        end
        syncAdvancedWallpaper()
        if DBWallpaper and DBWallpaper.Layer then
            DBWallpaper.Layer:GetPropertyChangedSignal("Image"):Connect(syncAdvancedWallpaper)
            DBWallpaper.Layer:GetPropertyChangedSignal("ImageColor3"):Connect(syncAdvancedWallpaper)
            DBWallpaper.Layer:GetPropertyChangedSignal("ImageTransparency"):Connect(syncAdvancedWallpaper)
        end

        local blackVeil = Instance.new("Frame")
        blackVeil.Position = UDim2.fromScale(0, 0)
        blackVeil.Size = UDim2.fromScale(1, 1)
        blackVeil.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        blackVeil.BackgroundTransparency = 0.38
        blackVeil.BorderSizePixel = 0
        blackVeil.ZIndex = 602
        blackVeil.Parent = surface
        AddCorner(blackVeil, CORNER_RADIUS)

        local outlineHost = Instance.new("Frame")
        outlineHost.Name = "AdvancedOutlineHost"
        outlineHost.Position = UDim2.fromOffset(3, 3)
        outlineHost.Size = UDim2.new(1, -6, 1, -6)
        outlineHost.BackgroundTransparency = 1
        outlineHost.BorderSizePixel = 0
        outlineHost.Active = false
        outlineHost.ZIndex = 899
        outlineHost.Parent = root
        AddCorner(outlineHost, CORNER_RADIUS)

        local outline = Instance.new("UIStroke")
        outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        outline.Thickness = 2.10
        outline.Transparency = 0.025
        outline.LineJoinMode = Enum.LineJoinMode.Round
        outline.Parent = outlineHost
        local advOutlineGradient = StartRainbowFlow(outline, 2.6, NumberSequence.new(0.025))
        advOutlineGradient.Color = DB_DEEP_RAINBOW_FLOW

        local header = Instance.new("Frame")
        header.Position = UDim2.fromOffset(3, 3)
        header.Size = UDim2.new(1, -6, 0, 28)
        header.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
        header.BackgroundTransparency = 0.18
        header.BorderSizePixel = 0
        header.ZIndex = 620
        header.Parent = surface
        AddCorner(header, math.max(6, CORNER_RADIUS - 4))

        local title = Instance.new("TextLabel")
        title.Position = UDim2.fromOffset(9, 2)
        title.Size = UDim2.new(1, -172, 0, 25)
        title.BackgroundTransparency = 1
        title.Text = "大肥鱼音乐播放器"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 16
        title.Font = Enum.Font.GothamBlack
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 622
        title.Parent = header
        local advancedTitleRainbow = StartRainbowFlow(title, 2.15, NumberSequence.new(0))
        advancedTitleRainbow.Color = RAINBOW_FLOW

        local playlistsButton = musicButton(
            header,
            "歌单",
            UDim2.fromOffset(42, 25),
            UDim2.new(1, -130, 0, 2),
            624
        )
        playlistsButton.TextSize = 8

        local minimize = musicButton(
            header,
            "−",
            UDim2.fromOffset(25, 25),
            UDim2.new(1, -84, 0, 2),
            624
        )
        minimize.TextSize = 18

        local back = musicButton(
            header,
            "←",
            UDim2.fromOffset(25, 25),
            UDim2.new(1, -56, 0, 2),
            624
        )
        back.TextSize = 14

        local exit = musicButton(
            header,
            "×",
            UDim2.fromOffset(25, 25),
            UDim2.new(1, -28, 0, 2),
            624
        )
        exit.TextSize = 16

        minimize.Activated:Connect(function()
            if type(state.MinimizeHandler) == "function" then
                state.MinimizeHandler()
            end
        end)

        back.Activated:Connect(function()
            root.Visible = false
            api.Show()
        end)

        exit.Activated:Connect(function()
            DBCloseScript()
        end)

        local playlistDrawer = musicCard(
            surface,
            UDim2.new(0.46, -7, 1, -39),
            UDim2.new(0.54, 0, 0, 33),
            840,
            0.08
        )
        playlistDrawer.Name = "PlaylistDrawer"
        playlistDrawer.Visible = false

        local function renderAdvancedPlaylistDrawer()
            for _, child in ipairs(playlistDrawer:GetChildren()) do
                if child:IsA("GuiObject") then child:Destroy() end
            end
            local drawerTitle = Instance.new("TextLabel")
            drawerTitle.Position = UDim2.fromOffset(8, 4)
            drawerTitle.Size = UDim2.new(1, -42, 0, 22)
            drawerTitle.BackgroundTransparency = 1
            drawerTitle.Text = "歌单 · " .. selectedPlaylist().Name
            drawerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            drawerTitle.TextSize = 11
            drawerTitle.Font = Enum.Font.GothamBlack
            drawerTitle.TextXAlignment = Enum.TextXAlignment.Left
            drawerTitle.TextTruncate = Enum.TextTruncate.AtEnd
            drawerTitle.ZIndex = 843
            drawerTitle.Parent = playlistDrawer

            local drawerClose = musicButton(playlistDrawer, "×", UDim2.fromOffset(26, 24), UDim2.new(1, -31, 0, 3), 844)
            drawerClose.TextSize = 14
            drawerClose.Activated:Connect(function() playlistDrawer.Visible = false end)

            local tabs = Instance.new("Frame")
            tabs.Position = UDim2.fromOffset(6, 30)
            tabs.Size = UDim2.new(1, -12, 0, 26)
            tabs.BackgroundTransparency = 1
            tabs.ZIndex = 843
            tabs.Parent = playlistDrawer
            local names = {}
            for _, list in ipairs(state.Playlists) do names[#names + 1] = list.Name end
            createHorizontalChips(tabs, names, selectedPlaylist().Name, function(value)
                for index, list in ipairs(state.Playlists) do if list.Name == value then state.SelectedPlaylist = index break end end
                savePlaylists(); renderAdvancedPlaylistDrawer()
            end, 844)

            local editBox = Instance.new("TextBox")
            editBox.Position = UDim2.fromOffset(6, 59)
            editBox.Size = UDim2.new(1, -12, 0, 25)
            editBox.BackgroundColor3 = Color3.fromRGB(48, 48, 52)
            editBox.BackgroundTransparency = 0.08
            editBox.BorderSizePixel = 0
            editBox.ClearTextOnFocus = false
            editBox.PlaceholderText = "新建 / 重命名歌单"
            editBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 188)
            editBox.Text = ""
            editBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            editBox.TextSize = 10
            editBox.Font = Enum.Font.GothamBold
            editBox.ZIndex = 844
            editBox.Parent = playlistDrawer
            AddCorner(editBox, 7)

            local topActions = {
                {"+新建", 6, 49, function() if createPlaylist(editBox.Text) then renderAdvancedPlaylistDrawer() end end},
                {"重命名", 59, 52, function() if renameSelectedPlaylist(editBox.Text) then renderAdvancedPlaylistDrawer() end end},
                {"全播", 115, 42, function()
                    local ok, first, queue, startIndex = playSelectedPlaylist(1)
                    if ok then playTrack(first, queue, startIndex) end
                end},
                {"清空", 161, 42, function() clearSelectedPlaylist(); renderAdvancedPlaylistDrawer() end},
                {"删除", 207, 42, function() deleteSelectedPlaylist(); renderAdvancedPlaylistDrawer() end},
            }
            for _, item in ipairs(topActions) do
                local b = musicButton(playlistDrawer, item[1], UDim2.fromOffset(item[3], 23), UDim2.fromOffset(item[2], 88), 844)
                b.TextSize = 9
                b.Activated:Connect(item[4])
            end

            local scroll = Instance.new("ScrollingFrame")
            scroll.Position = UDim2.fromOffset(6, 115)
            scroll.Size = UDim2.new(1, -12, 1, -121)
            scroll.BackgroundTransparency = 1
            scroll.BorderSizePixel = 0
            scroll.ScrollBarThickness = 2
            scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            scroll.CanvasSize = UDim2.new()
            scroll.ZIndex = 843
            scroll.Parent = playlistDrawer
            local layout = Instance.new("UIListLayout")
            layout.Padding = UDim.new(0, 3)
            layout.Parent = scroll

            local list = selectedPlaylist()
            if #list.Tracks == 0 then
                local empty = Instance.new("TextLabel")
                empty.Size = UDim2.new(1, -4, 0, 34)
                empty.BackgroundTransparency = 1
                empty.Text = "歌单暂无音乐 · 搜索结果点 + 添加"
                empty.TextColor3 = Color3.fromRGB(195, 195, 202)
                empty.TextSize = 10
                empty.Font = Enum.Font.GothamMedium
                empty.ZIndex = 844
                empty.Parent = scroll
            else
                for index, track in ipairs(list.Tracks) do
                    local row = Instance.new("Frame")
                    row.Size = UDim2.new(1, -4, 0, 31)
                    row.BackgroundColor3 = Color3.fromRGB(54, 54, 58)
                    row.BackgroundTransparency = 0.16
                    row.BorderSizePixel = 0
                    row.LayoutOrder = index
                    row.ZIndex = 844
                    row.Parent = scroll
                    AddCorner(row, 6)
                    local playArea = Instance.new("TextButton")
                    playArea.Size = UDim2.new(1, -88, 1, 0)
                    playArea.BackgroundTransparency = 1
                    playArea.Text = ""
                    playArea.ZIndex = 845
                    playArea.Parent = row
                    local label = Instance.new("TextLabel")
                    label.Position = UDim2.fromOffset(7, 2)
                    label.Size = UDim2.new(1, -7, 1, -4)
                    label.BackgroundTransparency = 1
                    label.Text = track.Title .. " · " .. track.Artist
                    label.TextColor3 = Color3.fromRGB(240, 240, 244)
                    label.TextSize = 9
                    label.Font = Enum.Font.GothamMedium
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.TextTruncate = Enum.TextTruncate.AtEnd
                    label.ZIndex = 846
                    label.Parent = playArea
                    playArea.Activated:Connect(function() playTrack(track, list.Tracks, index); playlistDrawer.Visible=false end)
                    local controls = {
                        {"↑", -84, function() if movePlaylistTrack(index,-1) then renderAdvancedPlaylistDrawer() end end},
                        {"↓", -57, function() if movePlaylistTrack(index,1) then renderAdvancedPlaylistDrawer() end end},
                        {"×", -30, function() if removePlaylistTrack(index) then renderAdvancedPlaylistDrawer() end end},
                    }
                    for _, info in ipairs(controls) do
                        local b=musicButton(row,info[1],UDim2.fromOffset(23,23),UDim2.new(1,info[2],0.5,-11),846)
                        b.Activated:Connect(info[3])
                    end
                end
            end
        end

        playlistsButton.Activated:Connect(function()
            playlistDrawer.Visible = not playlistDrawer.Visible
            if playlistDrawer.Visible then
                renderAdvancedPlaylistDrawer()
            end
        end)

        local searchBox = Instance.new("TextBox")
        searchBox.Position = UDim2.fromOffset(7, 33)
        searchBox.Size = UDim2.new(1, -14, 0, 29)
        searchBox.BackgroundColor3 = Color3.fromRGB(49, 49, 53)
        searchBox.BackgroundTransparency = 0.10
        searchBox.BorderSizePixel = 0
        searchBox.ClearTextOnFocus = false
        searchBox.PlaceholderText = "搜索歌曲 / 歌手 / 关键词"
        searchBox.PlaceholderColor3 = Color3.fromRGB(185, 185, 192)
        searchBox.Text = ""
        searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        searchBox.TextSize = 11
        searchBox.Font = Enum.Font.GothamBold
        searchBox.TextXAlignment = Enum.TextXAlignment.Left
        searchBox.ZIndex = 630
        searchBox.Parent = surface
        AddCorner(searchBox, 8)

        local searchPad = Instance.new("UIPadding")
        searchPad.PaddingLeft = UDim.new(0, 9)
        searchPad.PaddingRight = UDim.new(0, 9)
        searchPad.Parent = searchBox

        local filterRow = Instance.new("Frame")
        filterRow.Position = UDim2.fromOffset(7, 65)
        filterRow.Size = UDim2.new(1, -14, 0, 25)
        filterRow.BackgroundTransparency = 1
        filterRow.ZIndex = 630
        filterRow.Parent = surface

        local platformRow = Instance.new("Frame")
        platformRow.Position = UDim2.fromOffset(7, 91)
        platformRow.Size = UDim2.new(1, -14, 0, 25)
        platformRow.BackgroundTransparency = 1
        platformRow.ZIndex = 630
        platformRow.Parent = surface

        local advancedLaunchSearch = nil
        local function rebuildAdvancedChips()
            for _, child in ipairs(filterRow:GetChildren()) do
                child:Destroy()
            end
            for _, child in ipairs(platformRow:GetChildren()) do
                child:Destroy()
            end

            createHorizontalChips(filterRow, FILTERS, state.Filter, function(value)
                state.Filter = value
                rebuildAdvancedChips()
                if advancedLaunchSearch and trim(searchBox.Text) ~= "" then
                    advancedLaunchSearch()
                end
            end, 632)

            createHorizontalChips(platformRow, PLATFORMS, state.Platform, function(value)
                state.Platform = value
                rebuildAdvancedChips()
                if advancedLaunchSearch and trim(searchBox.Text) ~= "" then
                    advancedLaunchSearch()
                end
            end, 632)
        end
        rebuildAdvancedChips()

        local bodyHost = Instance.new("Frame")
        bodyHost.Position = UDim2.fromOffset(7, 120)
        bodyHost.Size = UDim2.new(1, -14, 1, -127)
        bodyHost.BackgroundTransparency = 1
        bodyHost.ZIndex = 650
        bodyHost.Parent = surface

        local hot = musicCard(
            bodyHost,
            UDim2.new(1 / 3, -4, 1, 0),
            UDim2.new(0, 0, 0, 0),
            660,
            0.20
        )
        hot.Name = "HotPanel"
        state.AdvancedHotHost = hot

        local visual = musicCard(
            bodyHost,
            UDim2.new(2 / 3, -3, 0, 100),
            UDim2.new(1 / 3, 5, 0, 0),
            660,
            0.20
        )
        visual.Name = "VisualizerPanel"

        local visualTitle = Instance.new("TextLabel")
        visualTitle.Position = UDim2.fromOffset(7, 4)
        visualTitle.Size = UDim2.new(1, -34, 0, 18)
        visualTitle.BackgroundTransparency = 1
        visualTitle.Text = "动态多色滚动律动"
        visualTitle.TextColor3 = Color3.fromRGB(232, 232, 237)
        visualTitle.TextSize = 10
        visualTitle.Font = Enum.Font.GothamBold
        visualTitle.TextXAlignment = Enum.TextXAlignment.Left
        visualTitle.ZIndex = 667
        visualTitle.Parent = visual

        local visualHost = Instance.new("Frame")
        visualHost.Position = UDim2.fromOffset(6, 22)
        visualHost.Size = UDim2.new(1, -12, 1, -28)
        visualHost.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
        visualHost.BackgroundTransparency = 0.34
        visualHost.ClipsDescendants = true
        visualHost.ZIndex = 666
        visualHost.Parent = visual
        AddCorner(visualHost, 8)

        local _, bigBars = createMirrorVisualizer(visualHost, 46, 668)

        local enlarge = Instance.new("TextButton")
        enlarge.Name = "ExpandVisualizer"
        enlarge.AnchorPoint = Vector2.new(1, 0)
        enlarge.Position = UDim2.new(1, -6, 0, 3)
        enlarge.Size = UDim2.fromOffset(18, 15)
        enlarge.BackgroundColor3 = Color3.fromRGB(58, 58, 63)
        enlarge.BackgroundTransparency = 0.10
        enlarge.BorderSizePixel = 0
        enlarge.Text = ""
        enlarge.AutoButtonColor = false
        enlarge.ZIndex = 672
        enlarge.Parent = visual
        AddCorner(enlarge, 5)
        local enlargeStroke = Instance.new("UIStroke")
        enlargeStroke.Color = Color3.fromRGB(210, 212, 220)
        enlargeStroke.Transparency = 0.48
        enlargeStroke.Thickness = 0.7
        enlargeStroke.Parent = enlarge
        local function visualCornerMark(x, y)
            local h = Instance.new("Frame")
            h.AnchorPoint = Vector2.new(x == 1 and 1 or 0, y == 1 and 1 or 0)
            h.Position = UDim2.fromScale(x, y)
            h.Size = UDim2.fromOffset(4, 1)
            h.BackgroundColor3 = Color3.fromRGB(238,238,242)
            h.BorderSizePixel = 0
            h.ZIndex = 673
            h.Parent = enlarge
            local v = Instance.new("Frame")
            v.AnchorPoint = h.AnchorPoint
            v.Position = UDim2.fromScale(x, y)
            v.Size = UDim2.fromOffset(1, 4)
            v.BackgroundColor3 = Color3.fromRGB(238,238,242)
            v.BorderSizePixel = 0
            v.ZIndex = 673
            v.Parent = enlarge
        end
        visualCornerMark(0,0); visualCornerMark(1,0); visualCornerMark(0,1); visualCornerMark(1,1)

        local player = musicCard(
            bodyHost,
            UDim2.new(2 / 3, -3, 0, 76),
            UDim2.new(1 / 3, 5, 1, -76),
            660,
            0.20
        )
        player.Name = "PlayerPanel"
        player.Visible = true
        player.BackgroundTransparency = 0.12
        local playerStroke = player:FindFirstChildOfClass("UIStroke")
        if playerStroke then playerStroke.Transparency = 0.42 end

        local miniWave = Instance.new("Frame")
        miniWave.Position = UDim2.new(0, 8, 0, 19)
        miniWave.Size = UDim2.new(1, -16, 1, -32)
        miniWave.BackgroundTransparency = 1
        miniWave.ClipsDescendants = true
        miniWave.ZIndex = 708
        miniWave.Parent = player
        local _, smallBars = createPlaybackVisualizer(miniWave, 44, 708)
        buildAdvancedPlayer(player)

        local function currentSplit()
            local bodyH = math.max(1, bodyHost.AbsoluteSize.Y)
            local idealPlayer = state.AdvancedVisualExpanded and (bodyH * 0.245) or (bodyH / 3)
            local playerH = state.AdvancedVisualExpanded
                and math.clamp(idealPlayer, 62, 88)
                or math.clamp(idealPlayer, 62, 88)
            if playerH > bodyH - 46 then
                playerH = math.max(46, bodyH * 0.46)
            end
            local upperH = math.max(42, bodyH - playerH - 4)
            return playerH, upperH
        end

        local function updateAdvancedLayout(animated)
            if not bodyHost.Parent then
                return
            end
            local playerH, upperH = currentSplit()
            local tweenInfo = TweenInfo.new(
                animated and 0.28 or 0.01,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            )
            local visualTargetPos
            local visualTargetSize
            if state.AdvancedVisualExpanded then
                visualTargetPos = UDim2.fromOffset(0, -87)
                visualTargetSize = UDim2.new(1, 0, 0, upperH + 87)
            else
                visualTargetPos = UDim2.new(1 / 3, 5, 0, 0)
                visualTargetSize = UDim2.new(2 / 3, -3, 0, upperH)
            end
            local playerTarget
            if state.AdvancedVisualExpanded then
                playerTarget = {
                    Position = UDim2.new(0, 0, 1, -playerH),
                    Size = UDim2.new(1, 0, 0, playerH),
                }
            else
                playerTarget = {
                    Position = UDim2.new(1 / 3, 5, 1, -playerH),
                    Size = UDim2.new(2 / 3, -3, 0, playerH),
                }
            end
            player.Visible = true
            local showSearchControls = not state.AdvancedVisualExpanded
            searchBox.Visible = showSearchControls
            filterRow.Visible = showSearchControls
            platformRow.Visible = showSearchControls
            if not showSearchControls then
                for _, pop in ipairs(state.SearchPopups) do
                    if pop and pop.Host == surface and pop.Root then pop.Root.Visible = false end
                end
            end
            if animated then
                TweenService:Create(visual, tweenInfo, {
                    Position = visualTargetPos,
                    Size = visualTargetSize,
                }):Play()
                TweenService:Create(player, tweenInfo, playerTarget):Play()
            else
                visual.Position = visualTargetPos
                visual.Size = visualTargetSize
                player.Position = playerTarget.Position
                player.Size = playerTarget.Size
            end
        end

        enlarge.Activated:Connect(function()
            state.AdvancedVisualExpanded = not state.AdvancedVisualExpanded
            hot.Visible = not state.AdvancedVisualExpanded
            updateAdvancedLayout(true)
        end)

        bodyHost:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            updateAdvancedLayout(false)
        end)
        task.defer(function()
            updateAdvancedLayout(false)
        end)

        local popup = createSearchPopup(surface, searchBox, 820)
        advancedLaunchSearch = bindSearchBox(searchBox, popup)

        state.AdvancedRoot = root
        state.AdvancedSurface = surface
        state.AdvancedSearchBox = searchBox
        state.AdvancedBigBars = bigBars
        state.AdvancedSmallBars = smallBars
        state.AdvancedHotPanel = hot
        state.AdvancedPlaylistDrawer = playlistDrawer
        state.UpdateAdvancedLayout = updateAdvancedLayout

        renderHotPanel()

        local swipe = {
            Active = false,
            Input = nil,
            Start = nil,
            Moved = false,
        }

        hot.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Touch
                and input.UserInputType ~= Enum.UserInputType.MouseButton1
            then
                return
            end
            swipe.Active = true
            swipe.Input = input
            swipe.Start = Vector2.new(input.Position.X, input.Position.Y)
            swipe.Moved = false
        end)

        UIS.InputChanged:Connect(function(input)
            if not swipe.Active or not swipe.Start or not hot.Parent then
                return
            end
            local valid = input.UserInputType == Enum.UserInputType.MouseMovement
                or (input.UserInputType == Enum.UserInputType.Touch and input == swipe.Input)
            if not valid then
                return
            end
            local now = Vector2.new(input.Position.X, input.Position.Y)
            if (now - swipe.Start).Magnitude > 9 then
                swipe.Moved = true
            end
        end)

        UIS.InputEnded:Connect(function(input)
            if not swipe.Active then
                return
            end
            local ended = input == swipe.Input
                or (swipe.Input
                    and swipe.Input.UserInputType == Enum.UserInputType.MouseButton1
                    and input.UserInputType == Enum.UserInputType.MouseButton1)
            if not ended then
                return
            end

            local finish = Vector2.new(input.Position.X, input.Position.Y)
            local delta = swipe.Start and (finish - swipe.Start) or Vector2.zero
            swipe.Active = false
            swipe.Input = nil
            swipe.Start = nil

            if math.abs(delta.X) >= 34 and math.abs(delta.X) > math.abs(delta.Y) then
                if delta.X < 0 then
                    setAdvancedHotIndex(state.AdvancedHotIndex + 1)
                else
                    setAdvancedHotIndex(state.AdvancedHotIndex - 1)
                end
            end
        end)

        state.AdvancedCarouselToken = state.AdvancedCarouselToken + 1
        local carouselToken = state.AdvancedCarouselToken
        task.spawn(function()
            while not state.Destroyed
                and state.AdvancedRoot
                and state.AdvancedRoot.Parent
                and carouselToken == state.AdvancedCarouselToken
            do
                task.wait(15)
                if state.AdvancedRoot
                    and state.AdvancedRoot.Parent
                    and state.AdvancedRoot.Visible
                    and os.clock() - state.AdvancedLastSwipe >= 8
                then
                    setAdvancedHotIndex(state.AdvancedHotIndex + 1)
                end
            end
        end)

        return root
    end

    local function renderPlaylistRows(order)
        local list = selectedPlaylist()
        for index, track in ipairs(list.Tracks) do
            if index > 120 then break end
            local row = makeRightCard(37, order)
            order = order + 1

            local title = Instance.new("TextLabel")
            title.Position = UDim2.fromOffset(8, 2)
            title.Size = UDim2.new(1, -130, 0, 17)
            title.BackgroundTransparency = 1
            title.Text = track.Title
            title.TextColor3 = Color3.fromRGB(248, 248, 250)
            title.TextSize = 9
            title.Font = Enum.Font.GothamBold
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.TextTruncate = Enum.TextTruncate.AtEnd
            title.ZIndex = 23
            title.Parent = row

            local meta = Instance.new("TextLabel")
            meta.Position = UDim2.fromOffset(8, 19)
            meta.Size = UDim2.new(1, -130, 0, 13)
            meta.BackgroundTransparency = 1
            meta.Text = track.Artist .. " · " .. track.Platform
            meta.TextColor3 = Color3.fromRGB(195, 195, 202)
            meta.TextSize = 7
            meta.Font = Enum.Font.GothamMedium
            meta.TextXAlignment = Enum.TextXAlignment.Left
            meta.TextTruncate = Enum.TextTruncate.AtEnd
            meta.ZIndex = 23
            meta.Parent = row

            local buttons = {
                {"▶", -118, function() playTrack(track, list.Tracks, index) end},
                {"↑", -89, function() if movePlaylistTrack(index, -1) then api.Show() end end},
                {"↓", -60, function() if movePlaylistTrack(index, 1) then api.Show() end end},
                {"×", -31, function() if removePlaylistTrack(index) then api.Show() end end},
            }
            for _, info in ipairs(buttons) do
                local button = musicButton(row, info[1], UDim2.fromOffset(26, 25), UDim2.new(1, info[2], 0.5, -12), 24)
                button.Activated:Connect(info[3])
            end
        end
        return order
    end

    function api.Show()
        createVolumeMixer()
        if DBSpatial and type(DBSpatial.DetachAdvancedMusic) == "function" then
            pcall(DBSpatial.DetachAdvancedMusic)
        end
        setAdvancedPanelOwnership(false)
        Body.Visible = true
        MoveBarHitArea.Visible = true
        ResizeHandle.Visible = true
        ResizeHandle.ZIndex = 994
        ResizeArcVisual.ZIndex = 995
        if state.AdvancedRoot and state.AdvancedRoot.Parent then
            state.AdvancedRoot.Visible = false
        end

        clearNormalPage()
        local order = 1

        makeRightTitle("音乐播放器", order, true)
        order = order + 1

        local searchCard = makeRightCard(36, order)
        order = order + 1

        local searchBox = Instance.new("TextBox")
        searchBox.Position = UDim2.fromOffset(6, 5)
        searchBox.Size = UDim2.new(1, -12, 0, 26)
        searchBox.BackgroundColor3 = Color3.fromRGB(49, 49, 53)
        searchBox.BackgroundTransparency = 0.10
        searchBox.BorderSizePixel = 0
        searchBox.ClearTextOnFocus = false
        searchBox.PlaceholderText = "搜索歌曲 / 歌手 / 关键词"
        searchBox.PlaceholderColor3 = Color3.fromRGB(185, 185, 192)
        searchBox.Text = state.SearchKeyword
        searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        searchBox.TextSize = 9
        searchBox.Font = Enum.Font.GothamBold
        searchBox.TextXAlignment = Enum.TextXAlignment.Left
        searchBox.ZIndex = 24
        searchBox.Parent = searchCard
        AddCorner(searchBox, 8)

        local searchPad = Instance.new("UIPadding")
        searchPad.PaddingLeft = UDim.new(0, 9)
        searchPad.PaddingRight = UDim.new(0, 9)
        searchPad.Parent = searchBox

        local filterCard = makeRightCard(30, order)
        order = order + 1
        createHorizontalChips(filterCard, FILTERS, state.Filter, function(value)
            state.Filter = value
            state.SearchResults = {}
            api.Show()
        end, 24)

        local platformCard = makeRightCard(30, order)
        order = order + 1
        createHorizontalChips(platformCard, PLATFORMS, state.Platform, function(value)
            state.Platform = value
            state.SearchResults = {}
            api.Show()
        end, 24)

        local codeCard = makeRightCard(38, order)
        order = order + 1
        local codeBox = Instance.new("TextBox")
        codeBox.Position = UDim2.fromOffset(6, 5)
        codeBox.Size = UDim2.new(1, -62, 0, 28)
        codeBox.BackgroundColor3 = Color3.fromRGB(49, 49, 53)
        codeBox.BackgroundTransparency = 0.10
        codeBox.BorderSizePixel = 0
        codeBox.ClearTextOnFocus = false
        codeBox.PlaceholderText = "音乐编码/网址：数字、163:、qq:、kg:、qs:"
        codeBox.PlaceholderColor3 = Color3.fromRGB(175, 178, 188)
        codeBox.Text = state.CodeInput
        codeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        codeBox.TextSize = 8
        codeBox.Font = Enum.Font.GothamBold
        codeBox.TextXAlignment = Enum.TextXAlignment.Left
        codeBox.ZIndex = 24
        codeBox.Parent = codeCard
        AddCorner(codeBox, 8)
        local codePad = Instance.new("UIPadding")
        codePad.PaddingLeft = UDim.new(0, 8)
        codePad.PaddingRight = UDim.new(0, 8)
        codePad.Parent = codeBox

        local codePlay = musicButton(
            codeCard,
            "播放",
            UDim2.fromOffset(50, 28),
            UDim2.new(1, -56, 0, 5),
            25
        )
        codePlay.TextSize = 8
        local function submitCode()
            state.CodeInput = trim(codeBox.Text)
            playMusicCode(state.CodeInput)
        end
        codePlay.Activated:Connect(submitCode)
        codeBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then submitCode() end
        end)

        local popup = createSearchPopup(RightList, searchBox, 540)
        bindSearchBox(searchBox, popup)

        buildCompactPlayer(ListScroll, order)
        order = order + 1

        makeRightTitle("歌单", order, false)
        order = order + 1

        local playlistTabs = makeRightCard(30, order)
        order = order + 1
        local names = {}
        for _, list in ipairs(state.Playlists) do
            names[#names + 1] = list.Name
        end
        createHorizontalChips(
            playlistTabs,
            names,
            selectedPlaylist().Name,
            function(value)
                for index, list in ipairs(state.Playlists) do
                    if list.Name == value then
                        state.SelectedPlaylist = index
                        break
                    end
                end
                savePlaylists()
                api.Show()
            end,
            24
        )

        local createCard = makeRightCard(72, order)
        order = order + 1

        local createBox = Instance.new("TextBox")
        createBox.Position = UDim2.fromOffset(6, 5)
        createBox.Size = UDim2.new(1, -61, 0, 25)
        createBox.BackgroundColor3 = Color3.fromRGB(49, 49, 53)
        createBox.BackgroundTransparency = 0.10
        createBox.BorderSizePixel = 0
        createBox.ClearTextOnFocus = false
        createBox.PlaceholderText = "新建 / 重命名歌单"
        createBox.PlaceholderColor3 = Color3.fromRGB(185, 185, 192)
        createBox.Text = ""
        createBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        createBox.TextSize = 9
        createBox.Font = Enum.Font.GothamBold
        createBox.ZIndex = 24
        createBox.Parent = createCard
        AddCorner(createBox, 7)

        local createButton = musicButton(createCard, "+新建", UDim2.fromOffset(49, 25), UDim2.new(1, -55, 0, 5), 25)
        createButton.TextSize = 8
        createButton.Activated:Connect(function()
            if createPlaylist(createBox.Text) then api.Show() end
        end)

        local actions = {
            {"全部播放", 6, 76, function()
                local ok, first, queue, startIndex = playSelectedPlaylist(1)
                if ok then playTrack(first, queue, startIndex) end
            end},
            {"重命名", 86, 62, function()
                if renameSelectedPlaylist(createBox.Text) then api.Show() end
            end},
            {"清空", 152, 46, function() clearSelectedPlaylist(); api.Show() end},
            {"删歌单", 202, 56, function() deleteSelectedPlaylist(); api.Show() end},
        }
        for _, item in ipairs(actions) do
            local b = musicButton(createCard, item[1], UDim2.fromOffset(item[3], 26), UDim2.fromOffset(item[2], 38), 25)
            b.TextSize = 8
            b.Activated:Connect(item[4])
        end

        order = renderPlaylistRows(order)

        local advancedCard = makeRightCard(42, order)
        order = order + 1

        local advanced = musicButton(
            advancedCard,
            "启动高级模式",
            UDim2.new(1, -12, 1, -10),
            UDim2.fromOffset(6, 5),
            25
        )
        advanced.TextSize = 11
        advanced.Activated:Connect(function()
            api.ShowAdvanced()
        end)
    end

    function api.ShowAdvanced()
        createVolumeMixer()
        local root = buildAdvancedMode()

        if DBSpatial and type(DBSpatial.IsEnabled) == "function" and DBSpatial.IsEnabled()
            and type(DBSpatial.AttachAdvancedMusic) == "function"
        then
            setAdvancedPanelOwnership(false)
            Body.Visible = true
            MoveBarHitArea.Visible = false
            ResizeHandle.Visible = false
            local attached = false
            pcall(function() attached = DBSpatial.AttachAdvancedMusic(root) == true end)
            if attached then
                root.Visible = true
                root.Position = UDim2.fromScale(0, 0)
                root.Size = UDim2.fromScale(1, 1)
                state.AdvancedVisualExpanded = false
                if state.AdvancedHotPanel and state.AdvancedHotPanel.Parent then state.AdvancedHotPanel.Visible = true end
                if state.AdvancedPlaylistDrawer and state.AdvancedPlaylistDrawer.Parent then state.AdvancedPlaylistDrawer.Visible = false end
                if type(state.UpdateAdvancedLayout) == "function" then state.UpdateAdvancedLayout(false) end
                renderHotPanel()
                return
            end
        end

        setAdvancedPanelOwnership(true)
        Body.Visible = false
        MoveBarHitArea.Visible = false
        ResizeHandle.Visible = true
        ResizeHandle.ZIndex = 1205
        ResizeArcVisual.ZIndex = 1206
        root.Visible = true
        root.Position = UDim2.fromScale(0, 0)
        root.Size = UDim2.fromScale(1, 1)
        state.AdvancedVisualExpanded = false
        if state.AdvancedHotPanel and state.AdvancedHotPanel.Parent then state.AdvancedHotPanel.Visible = true end
        if state.AdvancedPlaylistDrawer and state.AdvancedPlaylistDrawer.Parent then state.AdvancedPlaylistDrawer.Visible = false end
        if type(state.UpdateAdvancedLayout) == "function" then state.UpdateAdvancedLayout(false) end
        renderHotPanel()
    end

    function api.SetMinimizeHandler(handler)
        state.MinimizeHandler = function()
            if DBSpatial and type(DBSpatial.IsEnabled) == "function" and DBSpatial.IsEnabled()
                and type(DBSpatial.SetMinimized) == "function"
            then
                DBSpatial.SetMinimized(true)
                return
            end
            if type(handler) == "function" then handler() end
        end
    end

    function api.ToggleSpatialPlayback()
        togglePause()
    end
    function api.NextSpatialTrack()
        nextTrack(false)
    end
    function api.PreviousSpatialTrack()
        previousTrack()
    end
    function api.GetSpatialSnapshot()
        local track = state.CurrentTrack
        local rms = tonumber(state.SpatialSpectrumRms) or tonumber(state.Playback.GetRms()) or 0
        local playing = (not state.PlaybackPaused) and (state.Playback.IsPlaying() or rms > 0.0025)
        return {
            Title = track and tostring(track.Title or "") or "",
            Artist = track and tostring(track.Artist or "") or "",
            Platform = track and tostring(track.Platform or "") or "",
            Status = tostring(state.PlayStatus or ""),
            Playing = playing,
            Levels = state.SpatialSpectrumLevels or {},
            Rms = rms,
        }
    end

    function api.Destroy()
        if state.Destroyed then
            return
        end
        state.Destroyed = true
        state.SearchToken = state.SearchToken + 1
        state.PlayToken = state.PlayToken + 1
        state.AdvancedCarouselToken = state.AdvancedCarouselToken + 1
        state.Playback.Stop(true)
        if state.AudioGraph then
            for _, obj in pairs(state.AudioGraph) do
                if typeof(obj) == "Instance" and obj.Parent then pcall(function() obj:Destroy() end) end
            end
        end
        if state.AdvancedRoot and state.AdvancedRoot.Parent then state.AdvancedRoot:Destroy() end
        if state.VolumeMixerRoot and state.VolumeMixerRoot.Parent then state.VolumeMixerRoot:Destroy() end
        for _, conn in pairs(state.GameSoundConnections) do pcall(function() conn:Disconnect() end) end
        if sound and sound.Parent then sound:Destroy() end
    end

    local V129_WAVE_COLORS = {
        {0.00, Color3.fromRGB(78, 218, 86)},
        {0.24, Color3.fromRGB(55, 232, 108)},
        {0.50, Color3.fromRGB(26, 225, 162)},
        {0.72, Color3.fromRGB(20, 202, 211)},
        {0.88, Color3.fromRGB(27, 145, 238)},
        {1.00, Color3.fromRGB(41, 78, 238)},
    }

    local function v129WaveColor(level, isSmall)
        level = math.clamp(tonumber(level) or 0, 0, 1)
        local color = V129_WAVE_COLORS[#V129_WAVE_COLORS][2]
        for i = 1, #V129_WAVE_COLORS - 1 do
            local a, b = V129_WAVE_COLORS[i], V129_WAVE_COLORS[i + 1]
            if level <= b[1] then
                local t = math.clamp((level - a[1]) / math.max(0.0001, b[1] - a[1]), 0, 1)
                color = a[2]:Lerp(b[2], t)
                break
            end
        end
        local brightness = isSmall and (0.88 + level * 0.10) or (0.92 + level * 0.08)
        return Color3.new(
            math.clamp(color.R * brightness, 0, 1),
            math.clamp(color.G * brightness, 0, 1),
            math.clamp(color.B * brightness, 0, 1)
        )
    end

    state.SpectrumWaveHistory = state.SpectrumWaveHistory or {}
    state.SpectrumWaveLastSample = tonumber(state.SpectrumWaveLastSample) or 0
    state.SpectrumWaveInput = tonumber(state.SpectrumWaveInput) or 0
    state.SpectrumWavePeak = tonumber(state.SpectrumWavePeak) or 0.08
    state.SpatialLastPlaybackPosition = tonumber(state.SpatialLastPlaybackPosition) or 0
    state.SpatialPlaybackMotionUntil = tonumber(state.SpatialPlaybackMotionUntil) or 0

    local function v129CurrentStrength(spectrum, rms, playing, position)
        if not playing then
            local old = tonumber(state.SpectrumWaveInput) or 0
            state.SpectrumWaveInput = old * 0.72
            return state.SpectrumWaveInput
        end
        rms = math.clamp(tonumber(rms) or 0, 0, 1)
        local spectralRms, spectralPeak = 0, 0
        if type(spectrum) == "table" and #spectrum > 3 then
            local sumSq, count = 0, 0
            local step = math.max(1, math.floor(#spectrum / 96))
            for i = 1, #spectrum, step do
                local v = math.max(0, tonumber(spectrum[i]) or 0)
                sumSq = sumSq + v * v
                if v > spectralPeak then spectralPeak = v end
                count = count + 1
            end
            spectralRms = math.sqrt(sumSq / math.max(1, count))
        end

        local raw = math.max(rms * 0.95, spectralRms * 2.55, spectralPeak * 0.76)
        if raw < 0.0015 then
            local p = tonumber(position) or 0
            local pulseA = (math.sin(p * 5.35) + 1) * 0.5
            local pulseB = (math.sin(p * 9.70 + 0.8) + 1) * 0.5
            local pulseC = (math.sin(p * 2.15 + 1.6) + 1) * 0.5
            local hit = math.max(0, math.sin(p * 6.15)) ^ 5
            local target = math.clamp(0.10 + pulseA * 0.28 + pulseB * 0.18 + pulseC * 0.13 + hit * 0.31, 0.08, 0.92)
            local old = tonumber(state.SpectrumWaveInput) or 0
            local k = target > old and 0.58 or 0.24
            state.SpectrumWaveInput = math.clamp(old + (target - old) * k, 0, 1)
            return state.SpectrumWaveInput
        end

        local peak = math.max(0.015, tonumber(state.SpectrumWavePeak) or raw or 0.08)
        if raw > peak then peak = peak + (raw - peak) * 0.34 else peak = peak + (raw - peak) * 0.020 end
        peak = math.max(0.015, peak)
        state.SpectrumWavePeak = peak

        local target = math.clamp(raw / math.max(0.015, peak * 0.95), 0, 1.16)
        target = math.clamp((target - 0.020) / 0.98, 0, 1) ^ 0.86
        local old = tonumber(state.SpectrumWaveInput) or 0
        local k = target > old and 0.70 or 0.22
        state.SpectrumWaveInput = math.clamp(old + (target - old) * k, 0, 1)
        return state.SpectrumWaveInput
    end

    local function v129PushWaveSample(now, level)
        if now - (state.SpectrumWaveLastSample or 0) < (1 / 34) then return end
        state.SpectrumWaveLastSample = now
        local h = state.SpectrumWaveHistory
        table.insert(h, 1, {T = now, L = math.clamp(level, 0, 1)})
        while #h > 72 do table.remove(h) end
    end

    local function v129SampleHistory(now, delay)
        local h = state.SpectrumWaveHistory
        if type(h) ~= "table" or #h == 0 then return 0 end
        local target = now - math.max(0, delay or 0)
        if target >= h[1].T then return h[1].L or 0 end
        for i = 1, #h - 1 do
            local a, b = h[i], h[i + 1]
            if a.T >= target and b.T <= target then
                local span = math.max(0.0001, a.T - b.T)
                local t = math.clamp((a.T - target) / span, 0, 1)
                return (a.L or 0) + ((b.L or 0) - (a.L or 0)) * t
            end
        end
        return h[#h].L or 0
    end

    local function v129BuildMirroredLevels(count, now, stepDelay, playing)
        count = math.max(2, math.floor(tonumber(count) or 48))
        local out = table.create and table.create(count, 0) or {}
        local center = (count + 1) * 0.5
        for i = 1, count do
            local distance = math.floor(math.abs(i - center))
            local level = playing and v129SampleHistory(now, distance * stepDelay) or 0
            out[i] = math.clamp(level, 0, 1)
        end
        return out
    end

    local function v129UpdateBars(groups, groupKey, levels, playing, heightScale)
        if type(groups) ~= "table" or #groups == 0 then return end
        state.SpectrumSmooth[groupKey] = state.SpectrumSmooth[groupKey] or {}
        local sm = state.SpectrumSmooth[groupKey]
        local isSmall = groupKey == "small"
        local maxHeight = (isSmall and 0.58 or 0.91) * (heightScale or 1)
        local minHeight = isSmall and 0.020 or 0.018
        for i, group in ipairs(groups) do
            local target = playing and math.clamp(tonumber(levels[i]) or 0, 0, 1) or 0
            local old = tonumber(sm[i]) or 0
            local level = old + (target - old) * (target > old and 0.72 or 0.23)
            level = math.clamp(level, 0, 1); sm[i] = level
            local height = minHeight + (level ^ 0.86) * maxHeight
            local color = v129WaveColor(level, isSmall)
            for _, bar in ipairs(group) do
                if bar and bar.Parent then
                    bar.Size = UDim2.new(bar.Size.X.Scale, 0, height, 0)
                    bar.BackgroundColor3 = color
                    bar.BackgroundTransparency = playing and (isSmall and 0.07 or 0.01) or 0.66
                end
            end
        end
    end

    RunService.RenderStepped:Connect(function()
        if state.Destroyed then return end
        local spectrum = state.Playback.GetSpectrum()
        local rms = math.clamp(tonumber(state.Playback.GetRms()) or 0, 0, 1)
        local statusText = tostring(state.PlayStatus or "")
        local statusSaysPlaying = statusText:find("播放", 1, true) ~= nil and statusText:find("暂停", 1, true) == nil
        local length = state.Playback.TimeLength()
        local position = state.Playback.TimePosition()
        local now = os.clock()

        local lastPos = tonumber(state.SpatialLastPlaybackPosition) or position
        if position > lastPos + 0.003 or (lastPos > 1 and position + 0.35 < lastPos and not state.PlaybackPaused) then
            state.SpatialPlaybackMotionUntil = now + 0.42
        end
        state.SpatialLastPlaybackPosition = position
        local positionAdvancing = now < (tonumber(state.SpatialPlaybackMotionUntil) or 0)
        local playing = (not state.PlaybackPaused) and (state.Playback.IsPlaying() or rms > 0.0020 or statusSaysPlaying or positionAdvancing)

        for i = #state.Views, 1, -1 do
            local view = state.Views[i]
            if not view.Root or not view.Root.Parent then
                table.remove(state.Views, i)
            else
                local track = state.CurrentTrack
                if view.Title then view.Title.Text = track and track.Title or "尚未播放" end
                if view.Artist then view.Artist.Text = track and (track.Artist .. " · " .. track.Platform) or "选择一首音乐" end
                if view.Status then
                    local progressText = ""
                    if length > 0 then progressText = formatTime(position) .. " / " .. formatTime(length) end
                    view.Status.Text = progressText ~= "" and (state.PlayStatus .. " · " .. progressText) or state.PlayStatus
                end
                if view.PlayButton then view.PlayButton.Text = playing and "Ⅱ" or "▶" end
                if view.ProgressFill then
                    local ratio = length > 0 and math.clamp(position / length, 0, 1) or 0
                    view.ProgressFill.Size = UDim2.fromScale(ratio, 1)
                end
                if track ~= view.LastTrack then
                    view.LastTrack = track
                    if view.Art then setCover(view.Art, view.ArtFallback, track) end
                end
            end
        end

        local activeTrackKey = trackIdentity(state.CurrentTrack)
        if state.SpectrumTrackKey ~= activeTrackKey then
            state.SpectrumTrackKey = activeTrackKey
            state.SpectrumSmooth = {}
            state.SpectrumWaveHistory = {}
            state.SpectrumWaveLastSample = 0
            state.SpectrumWaveInput = 0
            state.SpectrumWavePeak = 0.08
            state.SpatialLastPlaybackPosition = position
            state.SpatialPlaybackMotionUntil = now
        end

        local strength = v129CurrentStrength(spectrum, rms, playing, position)
        v129PushWaveSample(now, strength)
        local bigLevels = v129BuildMirroredLevels(#(state.AdvancedBigBars or {}), now, 0.033, playing)
        local smallLevels = v129BuildMirroredLevels(#(state.AdvancedSmallBars or {}), now, 0.028, playing)
        local spatialLevels = v129BuildMirroredLevels(48, now, 0.031, playing)
        state.SpatialSpectrumLevels = spatialLevels
        state.SpatialSpectrumRms = strength
        v129UpdateBars(state.AdvancedBigBars, "big", bigLevels, playing, 1.00)
        v129UpdateBars(state.AdvancedSmallBars, "small", smallLevels, playing, 0.94)
    end)

    pcall(function()
        MainGui.Destroying:Connect(function()
            api.Destroy()
        end)
    end)

    task.defer(function()
        if not state.Destroyed then createVolumeMixer() end
    end)

    return api
end)()

local function DBCreateSimpleRailButton(
objectName,
labelText,
layoutOrder,
callback
)
local button =
Instance.new(
"TextButton"
)
button.Name =
objectName
DBApplyUnifiedButton(
button,
34
)
button.BackgroundColor3 =
DBVisualSettings.ButtonBackground
button.BackgroundTransparency =
DBVisualSettings.ButtonTransparency
button.BorderSizePixel = 0
button.Text = labelText
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 14
button.Font = Enum.Font.GothamBlack
button.TextXAlignment = Enum.TextXAlignment.Left
button.AutoButtonColor = false
button.ZIndex = 16
button.LayoutOrder = layoutOrder
StyleLiquidButton(
button,
11,
false
)
local pad =
Instance.new(
"UIPadding"
)
pad.PaddingLeft =
UDim.new(
0,
DB_UNIFIED_SIDE_PAD
)
pad.PaddingRight =
UDim.new(
0,
DB_UNIFIED_SIDE_PAD
)
pad.Parent =
button
ApplySafeClickEffect(
button,
callback
)
button.Parent =
MenuScroll
return button
end
DBCreateSimpleRailButton(
"Category_Announcement",
"公告",
0,
function()
DBAnnouncementUI.Show()
end
)
DBCreateSimpleRailButton(
"Category_UIInterface",
"UI界面",
6,
function()
DBUIInterfaceUI.Show()
end
)
DBCreateSimpleRailButton(
"Category_MusicPlayer",
"音乐播放器",
7,
function()
DBMusic.Show()
end
)
local categoriesOrder = {
"通用"
}
for categoryIndex, catName in ipairs(categoriesOrder) do
local btn = Instance.new("TextButton")
btn.Name = "Category_" .. catName
DBApplyUnifiedButton(
btn,
32
)
btn.BackgroundColor3 = UI.Button
btn.BackgroundTransparency = 0.24
btn.BorderSizePixel = 0
btn.Text = catName
btn.TextColor3 = UI.Text
btn.TextTransparency = 0
btn.TextSize = 14
btn.Font = Enum.Font.GothamBlack
btn.TextXAlignment = Enum.TextXAlignment.Left
btn.AutoButtonColor = false
btn.ZIndex = 15
btn.LayoutOrder = categoryIndex + 3
StyleLiquidButton(btn, 11, false)
local pad = Instance.new("UIPadding")
pad.PaddingLeft = UDim.new(0, DB_UNIFIED_SIDE_PAD)
pad.PaddingRight = UDim.new(0, DB_UNIFIED_SIDE_PAD)
pad.Parent = btn
ApplySafeClickEffect(btn, function()
State.CurrentCategory = catName
RenderRightList(catName)
end)
btn.Parent = MenuScroll
end
local HomeButton = Instance.new("TextButton")
HomeButton.Name = "Category_Home"
DBApplyUnifiedButton(
HomeButton,
34
)
HomeButton.BackgroundColor3 = DBVisualSettings.ButtonBackground
HomeButton.BackgroundTransparency = DBVisualSettings.ButtonTransparency
HomeButton.BorderSizePixel = 0
HomeButton.Text = ""
HomeButton.AutoButtonColor = false
HomeButton.ZIndex = 16
HomeButton.LayoutOrder = 1
HomeButton.Parent = MenuScroll
StyleLiquidButton(
HomeButton,
11,
false
)
local HomeButtonText = Instance.new("TextLabel")
HomeButtonText.Name = "RainbowText"
HomeButtonText.BackgroundTransparency = 1
HomeButtonText.Position = UDim2.fromOffset(DB_UNIFIED_SIDE_PAD, 0)
HomeButtonText.Size = UDim2.new(1, -(DB_UNIFIED_SIDE_PAD * 2), 1, 0)
HomeButtonText.Text = "主页"
HomeButtonText.TextColor3 = Color3.fromRGB(255, 255, 255)
HomeButtonText.TextSize = 14
HomeButtonText.Font = Enum.Font.GothamBlack
HomeButtonText.TextXAlignment = Enum.TextXAlignment.Left
HomeButtonText.TextYAlignment = Enum.TextYAlignment.Center
HomeButtonText.ZIndex = 17
HomeButtonText.Parent = HomeButton
AddDBEnchantedText(
HomeButtonText,
true
)
HomeButton.Activated:Connect(function()
ShowHomePage()
end)
local PlayerPanelButton = Instance.new("TextButton")
PlayerPanelButton.Name = "Category_Player_Panel"
DBApplyUnifiedButton(
PlayerPanelButton,
34
)
PlayerPanelButton.BackgroundColor3 =
DBVisualSettings.ButtonBackground
PlayerPanelButton.BackgroundTransparency =
DBVisualSettings.ButtonTransparency
PlayerPanelButton.BorderSizePixel = 0
PlayerPanelButton.Text = ""
PlayerPanelButton.AutoButtonColor = false
PlayerPanelButton.ZIndex = 16
PlayerPanelButton.LayoutOrder = 2
PlayerPanelButton.Parent = MenuScroll
StyleLiquidButton(
PlayerPanelButton,
11,
false
)
local PlayerPanelButtonText = Instance.new("TextLabel")
PlayerPanelButtonText.Name = "RainbowText"
PlayerPanelButtonText.BackgroundTransparency = 1
PlayerPanelButtonText.Position =
UDim2.fromOffset(
DB_UNIFIED_SIDE_PAD,
0
)
PlayerPanelButtonText.Size =
UDim2.new(
1,
-(
DB_UNIFIED_SIDE_PAD
* 2
),
1,
0
)
PlayerPanelButtonText.Text =
"玩家面板"
PlayerPanelButtonText.TextColor3 =
Color3.fromRGB(
255,
255,
255
)
PlayerPanelButtonText.TextSize = 14
PlayerPanelButtonText.Font = Enum.Font.GothamBlack
PlayerPanelButtonText.TextXAlignment =
Enum.TextXAlignment.Left
PlayerPanelButtonText.TextYAlignment =
Enum.TextYAlignment.Center
PlayerPanelButtonText.ZIndex = 17
PlayerPanelButtonText.Parent = PlayerPanelButton
AddDBEnchantedText(
PlayerPanelButtonText,
true
)
PlayerPanelButton.Activated:Connect(function()
ShowPlayerControlPanel()
end)
local DBGeneralButton = Instance.new("TextButton")
DBGeneralButton.Name = "Category_DB_General"
DBApplyUnifiedButton(
DBGeneralButton,
34
)
DBGeneralButton.BackgroundColor3 = DBVisualSettings.ButtonBackground
DBGeneralButton.BackgroundTransparency = DBVisualSettings.ButtonTransparency
DBGeneralButton.BorderSizePixel = 0
DBGeneralButton.Text = ""
DBGeneralButton.AutoButtonColor = false
DBGeneralButton.ZIndex = 16
DBGeneralButton.LayoutOrder = 3
DBGeneralButton.Parent = MenuScroll
StyleLiquidButton(
DBGeneralButton,
11,
false
)
local DBGeneralButtonText = Instance.new("TextLabel")
DBGeneralButtonText.Name = "RainbowText"
DBGeneralButtonText.BackgroundTransparency = 1
DBGeneralButtonText.Position = UDim2.fromOffset(DB_UNIFIED_SIDE_PAD, 0)
DBGeneralButtonText.Size = UDim2.new(1, -(DB_UNIFIED_SIDE_PAD * 2), 1, 0)
DBGeneralButtonText.Text = "大肥鱼通用"
DBGeneralButtonText.TextColor3 = Color3.fromRGB(255, 255, 255)
DBGeneralButtonText.TextSize = 14
DBGeneralButtonText.Font = Enum.Font.GothamBlack
DBGeneralButtonText.TextXAlignment = Enum.TextXAlignment.Left
DBGeneralButtonText.TextYAlignment = Enum.TextYAlignment.Center
DBGeneralButtonText.ZIndex = 17
DBGeneralButtonText.Parent = DBGeneralButton
DBGeneralButton.Activated:Connect(function()
State.CurrentCategory = "大肥鱼通用"
RenderRightList("大肥鱼通用")
end)
local ScriptCollectionButton =
Instance.new(
"TextButton"
)
ScriptCollectionButton.Name =
"Category_ScriptCollection"
DBApplyUnifiedButton(
ScriptCollectionButton,
34
)
ScriptCollectionButton.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
ScriptCollectionButton.BackgroundTransparency =
0.88
ScriptCollectionButton.BorderSizePixel = 0
ScriptCollectionButton.Text = "脚本合集"
ScriptCollectionButton.TextColor3 =
Color3.fromRGB(
255,
255,
255
)
ScriptCollectionButton.TextSize = 14
ScriptCollectionButton.Font =
Enum.Font.GothamBlack
ScriptCollectionButton.TextXAlignment =
Enum.TextXAlignment.Left
ScriptCollectionButton.AutoButtonColor = false
ScriptCollectionButton.ZIndex = 16
ScriptCollectionButton.LayoutOrder = 5
StyleLiquidButton(
ScriptCollectionButton,
11,
false
)
local ScriptCollectionPad =
Instance.new(
"UIPadding"
)
ScriptCollectionPad.PaddingLeft =
UDim.new(
0,
DB_UNIFIED_SIDE_PAD
)
ScriptCollectionPad.PaddingRight =
UDim.new(
0,
DB_UNIFIED_SIDE_PAD
)
ScriptCollectionPad.Parent =
ScriptCollectionButton
ApplySafeClickEffect(
ScriptCollectionButton,
function()
ScriptCollectionUI.Show()
end
)
ScriptCollectionButton.Parent =
MenuScroll
local SettingsButton =
Instance.new(
"TextButton"
)
SettingsButton.Name =
"Category_Settings"
DBApplyUnifiedButton(
SettingsButton,
34
)
SettingsButton.BackgroundColor3 =
Color3.fromRGB(
255,
255,
255
)
SettingsButton.BackgroundTransparency =
0.88
SettingsButton.BorderSizePixel = 0
SettingsButton.Text = "设置"
SettingsButton.TextColor3 =
Color3.fromRGB(
255,
255,
255
)
SettingsButton.TextSize = 14
SettingsButton.Font =
Enum.Font.GothamBlack
SettingsButton.TextXAlignment =
Enum.TextXAlignment.Left
SettingsButton.AutoButtonColor = false
SettingsButton.ZIndex = 16
SettingsButton.LayoutOrder = 8
StyleLiquidButton(
SettingsButton,
11,
false
)
local SettingsPad =
Instance.new(
"UIPadding"
)
SettingsPad.PaddingLeft =
UDim.new(
0,
DB_UNIFIED_SIDE_PAD
)
SettingsPad.PaddingRight =
UDim.new(
0,
DB_UNIFIED_SIDE_PAD
)
SettingsPad.Parent =
SettingsButton
ApplySafeClickEffect(
SettingsButton,
function()
DBSettingsUI.Show()
end
)
SettingsButton.Parent =
MenuScroll
ShowHomePage()
end
DBBuildHome()
local function DBApplySafeWhiteGlassPass()
local ok, err = pcall(function()
for _, descendant in ipairs(Panel:GetDescendants()) do
if descendant:IsA("UIStroke") then
local isOuterRainbow = descendant == PanelBorder
if not isOuterRainbow then
descendant.Color = Color3.fromRGB(255,255,255)
for _, child in ipairs(descendant:GetChildren()) do
if child:IsA("UIGradient") then child:Destroy() end
end
end
elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
for _, child in ipairs(descendant:GetChildren()) do
if child:IsA("UIGradient") and child.Name == "DB_EnchantTextFlow" then child:Destroy() end
end
end
end
if ProfileRailDivider then
ProfileRailDivider.BackgroundColor3 = Color3.fromRGB(255,255,255)
ProfileRailDivider.BackgroundTransparency = 0.88
end
if FunctionRailDivider then
FunctionRailDivider.BackgroundColor3 = Color3.fromRGB(255,255,255)
FunctionRailDivider.BackgroundTransparency = 0.88
end
for _, descendant in ipairs(Panel:GetDescendants()) do
if descendant:IsA("ScrollingFrame") then
descendant.Active = true
descendant.ScrollingEnabled = true
end
end
DBVisualSettings.ApplyButtonBorders()
end)
if not ok then warn("[大肥鱼 V92] 视觉清理失败：", err) end
end
DBApplySafeWhiteGlassPass()
DBVisualSettings.SetButtonBorders(false)
if PanelBorder then PanelBorder.Enabled=true; if PanelBorder.Parent then PanelBorder.Parent.Visible=true end end
local function SetPanelPosition(pos)
local safe =
ClampPosition(
pos,
Vector2.new(
panelWidth,
panelHeight
)
)
State.PanelPosition =
safe
Panel.Position =
UDim2.fromOffset(
safe.X,
safe.Y
)
end
local function SetButtonPosition(pos)
local vp = GetViewport()
local halfW = FLOATING_WIDTH / 2
local halfH = FLOATING_HEIGHT / 2
local new =
Vector2.new(
math.clamp(
pos.X,
-halfW,
vp.X + halfW
),
math.clamp(
pos.Y,
halfH,
vp.Y - halfH
)
)
State.ButtonPosition = new
FloatingButton.Position =
UDim2.fromOffset(
new.X,
new.Y
)
end
local vp = GetViewport()
SetPanelPosition(Vector2.new(vp.X/2, vp.Y/2))
SetButtonPosition(Vector2.new(vp.X * 0.5, FLOATING_HEIGHT / 2 + 10))

local function GetCollapsedPanelScale()
    local w = math.max(panelWidth, 1)
    local h = math.max(panelHeight, 1)
    local fit = math.min(FLOATING_WIDTH / w, FLOATING_HEIGHT / h)
    return math.clamp(fit, 0.075, 0.18)
end

local AppleTransition = {
    Progress = 1,
    Velocity = 0,
    Target = 1,
    Running = false,
    PanelTarget = State.PanelPosition,
    ButtonTarget = State.ButtonPosition,
    Direction = Vector2.new(0, 1),
    ButtonMorphTween = nil,
    ButtonMorphing = false,
    SceneBlur = nil,
}
local function GetTransitionStyle()
    local style = DBVisualSettings and DBVisualSettings.TransitionStyle or "原版"
    if style ~= "原版" and style ~= "增加模糊" and style ~= "老式款" then style = "原版" end
    return style
end
local function GetTransitionSceneBlur()
    if AppleTransition.SceneBlur and AppleTransition.SceneBlur.Parent then return AppleTransition.SceneBlur end
    local blur = Instance.new("BlurEffect")
    blur.Name = "DB_TransitionBlur_V125"
    blur.Size = 0
    blur.Enabled = false
    blur.Parent = game:GetService("Lighting")
    AppleTransition.SceneBlur = blur
    return blur
end

AppleTransition.BlurOverlay = Instance.new("Frame")
AppleTransition.BlurOverlay.Name = "DB_TransitionSoftFocus"
AppleTransition.BlurOverlay.Size = UDim2.fromScale(1, 1)
AppleTransition.BlurOverlay.BackgroundColor3 = Color3.fromRGB(226, 229, 235)
AppleTransition.BlurOverlay.BackgroundTransparency = 1
AppleTransition.BlurOverlay.BorderSizePixel = 0
AppleTransition.BlurOverlay.Active = false
AppleTransition.BlurOverlay.Visible = false
AppleTransition.BlurOverlay.ZIndex = 970
AppleTransition.BlurOverlay.Parent = Panel
AddCorner(AppleTransition.BlurOverlay, CORNER_RADIUS)
do
    local grad = Instance.new("UIGradient")
    grad.Rotation = 12
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.62),
        NumberSequenceKeypoint.new(0.28, 0.26),
        NumberSequenceKeypoint.new(0.72, 0.20),
        NumberSequenceKeypoint.new(1, 0.66),
    })
    grad.Parent = AppleTransition.BlurOverlay
end
function AppleTransition.ApplySoftFocus(p)
    p = math.clamp(p or AppleTransition.Progress, 0, 1)
    if GetTransitionStyle() ~= "增加模糊" then
        AppleTransition.BlurOverlay.Visible = false
        AppleTransition.BlurOverlay.BackgroundTransparency = 1
        Panel.GroupTransparency = 0
        if AppleTransition.SceneBlur and AppleTransition.SceneBlur.Parent then
            AppleTransition.SceneBlur.Size = 0
            AppleTransition.SceneBlur.Enabled = false
        end
        return
    end
    local amount
    if AppleTransition.Target == 0 then
        amount = math.clamp((0.88 - p) / 0.70, 0, 1)
        amount = amount * amount * (3 - 2 * amount)
    else
        local clear = math.clamp((p - 0.62) / 0.30, 0, 1)
        clear = clear * clear * (3 - 2 * clear)
        amount = 1 - clear
    end
    AppleTransition.BlurOverlay.Visible = AppleTransition.Running and amount > 0.025
    AppleTransition.BlurOverlay.BackgroundTransparency = 1 - amount * 0.10
    Panel.GroupTransparency = amount * 0.028
    local sceneBlur = GetTransitionSceneBlur()
    sceneBlur.Enabled = AppleTransition.Running and amount > 0.03
    sceneBlur.Size = math.floor(amount * 5 + 0.5)
end
function AppleTransition.ClearSoftFocus()
    AppleTransition.BlurOverlay.Visible = false
    AppleTransition.BlurOverlay.BackgroundTransparency = 1
    Panel.GroupTransparency = 0
    if AppleTransition.SceneBlur and AppleTransition.SceneBlur.Parent then
        AppleTransition.SceneBlur.Size = 0
        AppleTransition.SceneBlur.Enabled = false
    end
end

local function DBLerpVector2(a, b, t)
    return Vector2.new(
        a.X + (b.X - a.X) * t,
        a.Y + (b.Y - a.Y) * t
    )
end

local function ChooseAppleDirection(buttonPos, panelCenter)
    local delta = panelCenter - buttonPos
    if delta.Magnitude < 1 then
        return Vector2.new(0, 1)
    end
    return delta.Unit
end

local function BeginAppleGeometry()
    AppleTransition.PanelTarget = State.PanelPosition or Vector2.new(GetViewport().X / 2, GetViewport().Y / 2)
    AppleTransition.ButtonTarget = State.ButtonPosition or Vector2.new(GetViewport().X / 2, FLOATING_HEIGHT / 2 + 10)
    AppleTransition.Direction = ChooseAppleDirection(AppleTransition.ButtonTarget, AppleTransition.PanelTarget)
    Panel.AnchorPoint = Vector2.new(0.5, 0.5)
end

local function ApplyAppleTransition()
    local p = AppleTransition.Progress
    local travelP = math.clamp(p, 0, 1)
    local panelTarget = AppleTransition.PanelTarget or State.PanelPosition or Vector2.new(GetViewport().X / 2, GetViewport().Y / 2)
    local buttonTarget = AppleTransition.ButtonTarget or State.ButtonPosition or Vector2.new(GetViewport().X / 2, FLOATING_HEIGHT / 2 + 10)
    local direction = AppleTransition.Direction or ChooseAppleDirection(buttonTarget, panelTarget)
    local collapsedScale = GetCollapsedPanelScale()

    if GetTransitionStyle() == "老式款" then
        local buttonStage = 0.18
        Panel.AnchorPoint = Vector2.new(0.5, 0.5)
        Panel.Position = UDim2.fromOffset(panelTarget.X, panelTarget.Y)
        FloatingButton.Position = UDim2.fromOffset(buttonTarget.X, buttonTarget.Y)
        if travelP <= buttonStage then
            local bt = math.clamp(travelP / buttonStage, 0, 1)
            bt = bt * bt * (3 - 2 * bt)
            local width = math.max(2, FLOATING_WIDTH * (1 - bt) + 2 * bt)
            FloatingButton.Size = UDim2.fromOffset(width, FLOATING_HEIGHT)
            FloatingButton.Visible = true
            Panel.Visible = false
            DBStartupScale.Scale = 0.08
            Panel.GroupTransparency = 0
        else
            local pt = math.clamp((travelP - buttonStage) / (1 - buttonStage), 0, 1)
            pt = 1 - (1 - pt) * (1 - pt) * (1 - pt)
            FloatingButton.Visible = false
            FloatingButton.Size = UDim2.fromOffset(2, FLOATING_HEIGHT)
            Panel.Visible = true
            DBStartupScale.Scale = math.max(0.08, 0.08 + 0.92 * pt)
            Panel.GroupTransparency = (1 - pt) * 0.08
        end
        AppleTransition.ApplySoftFocus(travelP)
        return
    end

    local smoothP = travelP * travelP * (3 - 2 * travelP)
    local pos = DBLerpVector2(buttonTarget, panelTarget, smoothP)

    local leadCurve = math.sin(math.pi * smoothP)
    local leadDistance = math.clamp(math.min(panelWidth, panelHeight) * 0.055, 14, 30)
    pos = pos + direction * (leadCurve * leadDistance)

    Panel.AnchorPoint = Vector2.new(0.5, 0.5)
    Panel.Position = UDim2.fromOffset(pos.X, pos.Y)
    DBStartupScale.Scale = math.max(0.04, collapsedScale + (1 - collapsedScale) * smoothP)
    FloatingTransitionScale.Scale = 1

    local buttonExitPoint = 0.055

    if AppleTransition.Target == 0 then
        FloatingButton.Visible = false
        Panel.Visible = true
    else
        Panel.Visible = true
        FloatingButton.Visible = travelP <= buttonExitPoint and not AppleTransition.ButtonMorphing
    end
    AppleTransition.ApplySoftFocus(travelP)
end

local function CancelButtonMorph(makeFull)
    if AppleTransition.ButtonMorphTween then
        pcall(function() AppleTransition.ButtonMorphTween:Cancel() end)
        AppleTransition.ButtonMorphTween = nil
    end
    AppleTransition.ButtonMorphing = false
    if makeFull then
        FloatingButton.Size = UDim2.fromOffset(FLOATING_WIDTH, FLOATING_HEIGHT)
    end
end

local function RevealFloatingButton()
    CancelButtonMorph(false)
    AppleTransition.ButtonMorphing = true

    FloatingButton.Position = UDim2.fromOffset(AppleTransition.ButtonTarget.X, AppleTransition.ButtonTarget.Y)
    FloatingButton.Size = UDim2.fromOffset(2, FLOATING_HEIGHT)
    FloatingButton.Visible = true
    FloatingTransitionScale.Scale = 1

    local tween = TweenService:Create(
        FloatingButton,
        TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.fromOffset(FLOATING_WIDTH, FLOATING_HEIGHT)}
    )
    AppleTransition.ButtonMorphTween = tween
    tween:Play()

    task.spawn(function()
        tween.Completed:Wait()
        if AppleTransition.ButtonMorphTween ~= tween then return end
        AppleTransition.ButtonMorphTween = nil
        AppleTransition.ButtonMorphing = false
        FloatingButton.Size = UDim2.fromOffset(FLOATING_WIDTH, FLOATING_HEIGHT)

        if AppleTransition.Target == 0 and not AppleTransition.Running and AppleTransition.Progress <= 0.001 then
            State.Minimized = true
            State.Animating = false
        end
    end)
end

local function SetAppleTarget(expanded)
    if not AppleTransition.Running then
        BeginAppleGeometry()
    end

    if expanded and AppleTransition.ButtonMorphing then
        CancelButtonMorph(true)
    end

    AppleTransition.Target = expanded and 1 or 0
    AppleTransition.Running = true
    State.Animating = true

    if expanded then
        FloatingButton.Size = UDim2.fromOffset(FLOATING_WIDTH, FLOATING_HEIGHT)
        FloatingButton.Visible = true
        Panel.Visible = true
    end
end

local function Minimize()
    if State.Minimized and not AppleTransition.Running then return end
    SetAppleTarget(false)
end

pcall(function()
    if DBMusic and type(DBMusic.SetMinimizeHandler) == "function" then
        DBMusic.SetMinimizeHandler(Minimize)
    end
end)

local function Restore()
    if (not State.Minimized) and (not AppleTransition.Running) and AppleTransition.Progress >= 0.999 then return end
    SetAppleTarget(true)
end

local function DBCreateSpatialController_130(layoutMode)
    local Controller = { Enabled = false }
    local narrowMode = tostring(layoutMode or "默认") == "中宽两窄"
do
    local Lighting = game:GetService("Lighting")
    local S = {
        Enabled=false, Closing=false, Progress=0, Velocity=0,
        LookVector=nil, UpVector=nil, RenderConnection=nil, WorldFolder=nil,
        Surfaces={}, Bars={}, Original={}, ProfileOriginal={},
        PreviousPanelVisible=true, PreviousFloatingVisible=false, PreviousMinimized=false,
        AdvancedRoot=nil, AdvancedOriginal=nil,
        CenterTitle=nil, MusicTitle=nil, MusicStatus=nil, MusicPlayButton=nil,
        SpectrumAccumulator=0, LastSnapshot=nil, LastError=nil,
        Minimized=false, MinimizeTarget=0, MinimizeProgress=0, MinimizeVelocity=0,
        Blur=nil, BlurOwned=false, Mini=nil,
        JoystickTouch=false, JoystickInputs={},
        FocusName="Center", PanelMotion={},
        StyleOriginal={}, StyleConnections={}, StyleAdded={}, NavButtons={}, ActionButtons={}, NavSelected=nil, LastNavCategory=nil,
        BackGhostAccumulator=0, UpdateErrorCount=0, BorderPhase=0,
        AnchorTarget=false, AnchorBlend=0, AnchorVelocity=0, AnchorLayout=nil, AnchorButton=nil, AnchorIcon=nil, AnchorIconFallback=nil,
    }
    local FOLDER_NAME = "DB_SpatialHUD_V130"
    local BAR_COUNT = 48
    local PANEL_DEPTH = 0.03

    local function clamp01(v) return math.clamp(tonumber(v) or 0,0,1) end
    local function smooth(v) v=clamp01(v); return v*v*(3-2*v) end
    local function easeOut(v) v=clamp01(v); return 1-(1-v)^3 end
    local function destroy(obj) if obj and obj.Parent then pcall(function() obj:Destroy() end) end end
    local function remember(obj)
        if not obj or S.Original[obj] then return end
        S.Original[obj]={Parent=obj.Parent,Position=obj.Position,Size=obj.Size,AnchorPoint=obj.AnchorPoint,Visible=obj.Visible,ClipsDescendants=obj.ClipsDescendants}
    end
    local function restore(obj)
        local sv=obj and S.Original[obj]
        if not obj or not sv then return end
        pcall(function()
            obj.Parent=sv.Parent; obj.Position=sv.Position; obj.Size=sv.Size; obj.AnchorPoint=sv.AnchorPoint
            obj.Visible=sv.Visible; obj.ClipsDescendants=sv.ClipsDescendants
        end)
        S.Original[obj]=nil
    end
    local function removeStale()
        for _,name in ipairs({"DB_SpatialHUD_V126","DB_SpatialHUD_V127","DB_SpatialHUD_V128",FOLDER_NAME}) do
            local old=workspace:FindFirstChild(name); if old then destroy(old) end
        end
        if __dbPlayerGui then
            for _,child in ipairs(__dbPlayerGui:GetChildren()) do
                if child:IsA("SurfaceGui") and (child.Name:find("DB_Spatial_V126",1,true) or child.Name:find("DB_Spatial_V127",1,true) or child.Name:find("DB_Spatial_V128",1,true) or child.Name:find("DB_Spatial_V130",1,true)) then
                    destroy(child)
                end
            end
        end
    end
    local function makePart(name,w,h)
        local part=Instance.new("Part")
        part.Name=name; part.Anchored=true; part.CanCollide=false; part.CanTouch=false; part.CanQuery=true; part.CastShadow=false
        part.Transparency=1
        part.Color=Color3.fromRGB(12,15,22)
        part.Material=Enum.Material.SmoothPlastic
        part.Reflectance=0
        part.Size=Vector3.new(w,h,PANEL_DEPTH); part.Parent=S.WorldFolder
        return part
    end
    local function makeSurface(name,wStud,hStud,canvasW,canvasH,titleText)
        local part=makePart("DB_AR130_"..name.."_Panel",wStud,hStud)
        local surface=Instance.new("SurfaceGui")
        surface.ResetOnSpawn=false
        surface.Name="DB_Spatial_V130_"..name; surface.Adornee=part; surface.Face=Enum.NormalId.Front; surface.Active=true
        surface.AlwaysOnTop=(name=="MusicStrip")
        surface.LightInfluence=0; surface.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize
        surface.CanvasSize=Vector2.new(canvasW,canvasH); surface.ClipsDescendants=false; surface.MaxDistance=0
        surface.ZOffset=(name=="Center" and 0.055 or 0.018); surface.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; surface.Parent=__dbPlayerGui

        local backSurface=Instance.new("SurfaceGui")
        backSurface.ResetOnSpawn=false
        backSurface.Name="DB_Spatial_V138_"..name.."_Back"; backSurface.Adornee=part; backSurface.Face=Enum.NormalId.Back
        backSurface.Active=false; backSurface.AlwaysOnTop=false; backSurface.LightInfluence=0
        backSurface.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize; backSurface.CanvasSize=Vector2.new(canvasW,canvasH)
        backSurface.ClipsDescendants=false; backSurface.MaxDistance=0; backSurface.ZOffset=0.010
        backSurface.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; backSurface.Parent=__dbPlayerGui

        local root=Instance.new("Frame")
        root.Name="SpatialGlassRoot"; root.Size=UDim2.fromScale(1,1); root.BackgroundColor3=Color3.fromRGB(5,7,12)
        root.BackgroundTransparency=(name=="Center" and 0.09 or 0.17); root.BorderSizePixel=0; root.ClipsDescendants=true; root.Active=true; root.ZIndex=10; root.Parent=surface
        AddCorner(root,20)
        local borderHost=Instance.new("Frame")
        borderHost.Position=UDim2.fromOffset(3,3); borderHost.Size=UDim2.new(1,-6,1,-6); borderHost.BackgroundTransparency=1
        borderHost.BorderSizePixel=0; borderHost.ZIndex=250; borderHost.Parent=root; AddCorner(borderHost,18)
        local spatialBorderStroke=Instance.new("UIStroke")
        spatialBorderStroke.Name="DB_SpatialStaticBorder"; spatialBorderStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        spatialBorderStroke.Thickness=1.55; spatialBorderStroke.Transparency=0.24; spatialBorderStroke.Color=Color3.new(1,1,1)
        spatialBorderStroke.LineJoinMode=Enum.LineJoinMode.Round; spatialBorderStroke.Parent=borderHost
        local spatialBorderGradient=Instance.new("UIGradient")
        spatialBorderGradient.Name="DB_SpatialRainbowFlow_V146"
        spatialBorderGradient.Color=DB_DEEP_RAINBOW_FLOW
        spatialBorderGradient.Transparency=NumberSequence.new(0)
        spatialBorderGradient.Rotation=-180
        spatialBorderGradient.Enabled=true
        spatialBorderGradient.Parent=spatialBorderStroke
        local spatialBorderGradientTween=TweenService:Create(
            spatialBorderGradient,
            TweenInfo.new(2.75,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1,false,0),
            {Rotation=180}
        )
        spatialBorderGradientTween:Play()

        local logoBackground=nil
        local logoFallback=nil
        if name=="Left" or name=="Center" or name=="Right" then
            logoBackground=Instance.new("ImageLabel")
            logoBackground.Name="DB_SpatialLogoBackground_V145"
            logoBackground.AnchorPoint=Vector2.new(0.5,0.5)
            logoBackground.Position=UDim2.fromScale(0.5,0.54)
            logoBackground.Size=UDim2.fromScale(name=="Center" and 0.42 or 0.48, name=="Center" and 0.50 or 0.54)
            logoBackground.BackgroundTransparency=1
            logoBackground.BorderSizePixel=0
            logoBackground.Image=DBSharedLogoAsset
            logoBackground.ImageColor3=Color3.fromRGB(184,194,218)
            logoBackground.ImageTransparency=0.80
            logoBackground.ScaleType=Enum.ScaleType.Fit
            logoBackground.Active=false
            logoBackground.ZIndex=12
            logoBackground.Visible=(DBSharedLogoAsset~="") and (DBVisualSettings.SpatialLogoBackgroundEnabled~=false)
            logoBackground.Parent=root

            logoFallback=Instance.new("TextLabel")
            logoFallback.Name="DB_SpatialLogoFallback_V145"
            logoFallback.AnchorPoint=Vector2.new(0.5,0.5)
            logoFallback.Position=UDim2.fromScale(0.5,0.54)
            logoFallback.Size=UDim2.fromScale(0.46,0.46)
            logoFallback.BackgroundTransparency=1
            logoFallback.Text="鱼"
            logoFallback.TextColor3=Color3.fromRGB(174,185,212)
            logoFallback.TextTransparency=0.84
            logoFallback.TextSize=name=="Center" and 96 or 74
            logoFallback.Font=Enum.Font.GothamBlack
            logoFallback.Active=false
            logoFallback.ZIndex=12
            logoFallback.Visible=(DBSharedLogoAsset=="") and (DBVisualSettings.SpatialLogoBackgroundEnabled~=false)
            logoFallback.Parent=root
        end

        local highlight=Instance.new("Frame")
        highlight.Position=UDim2.fromOffset(10,8); highlight.Size=UDim2.new(1,-20,0,1); highlight.BackgroundColor3=Color3.fromRGB(255,255,255)
        highlight.BackgroundTransparency=1; highlight.BorderSizePixel=0; highlight.ZIndex=27; highlight.Parent=root
        local glassStroke=Instance.new("UIStroke")
        glassStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; glassStroke.Thickness=0.85; glassStroke.Transparency=0.80
        glassStroke.Color=Color3.fromRGB(224,234,255); glassStroke.LineJoinMode=Enum.LineJoinMode.Round; glassStroke.Parent=root
        local header=Instance.new("Frame")
        header.Position=UDim2.fromOffset(8,7); header.Size=UDim2.new(1,-16,0,30); header.BackgroundColor3=Color3.fromRGB(255,255,255)
        header.BackgroundTransparency=0.90; header.BorderSizePixel=0; header.ZIndex=30; header.Active=true; header.Parent=root; AddCorner(header,11)
        local title=Instance.new("TextLabel")
        title.Position=UDim2.fromOffset(10,0); title.Size=UDim2.new(1,-20,1,0); title.BackgroundTransparency=1; title.Text=titleText
        title.TextColor3=Color3.fromRGB(248,250,255); title.TextSize=13; title.Font=Enum.Font.GothamBold
        title.TextXAlignment=Enum.TextXAlignment.Left; title.TextYAlignment=Enum.TextYAlignment.Center; title.TextTruncate=Enum.TextTruncate.AtEnd
        title.ZIndex=33; title.Parent=header
        local content=Instance.new("Frame")
        content.Position=UDim2.fromOffset(8,42); content.Size=UDim2.new(1,-16,1,-50); content.BackgroundTransparency=1
        content.BorderSizePixel=0; content.ClipsDescendants=true; content.Active=true; content.ZIndex=20; content.Parent=root
        local frost=Instance.new("Frame")
        frost.Size=UDim2.fromScale(1,1); frost.BackgroundColor3=Color3.fromRGB(218,228,246); frost.BackgroundTransparency=1
        frost.BorderSizePixel=0; frost.ZIndex=245; frost.Active=false; frost.Parent=root; AddCorner(frost,20)
        local pack={Name=name,Part=part,Surface=surface,BackSurface=backSurface,BackRoot=nil,Root=root,Header=header,Title=title,ContentHost=content,Frost=frost,WidthStud=wStud,HeightStud=hStud,
            BorderStroke=spatialBorderStroke,BorderGradient=spatialBorderGradient,LogoBackground=logoBackground,LogoFallback=logoFallback}
        S.Surfaces[name]=pack; return pack
    end

    local DB_SPATIAL_BORDER_COLORS = {
        ["默认"]=Color3.fromRGB(0,0,0),
        ["黄色"]=Color3.fromRGB(255,220,80),
        ["绿色"]=Color3.fromRGB(82,235,133),
        ["红色"]=Color3.fromRGB(255,93,111),
        ["紫色"]=Color3.fromRGB(183,116,255),
        ["白色"]=Color3.fromRGB(238,242,250),
        ["橙色"]=Color3.fromRGB(255,158,74),
    }
    local function refreshPanelAppearance()
        local logoEnabled=DBVisualSettings.SpatialLogoBackgroundEnabled~=false
        local borderMode=tostring(DBVisualSettings.SpatialBorderMode or "默认")
        for name,pack in pairs(S.Surfaces) do
            if pack.LogoBackground then
                pack.LogoBackground.Visible=logoEnabled and DBSharedLogoAsset~=""
                pack.LogoBackground.ImageColor3=Color3.fromRGB(184,194,218)
                pack.LogoBackground.ImageTransparency=0.80
            end
            if pack.LogoFallback then
                pack.LogoFallback.Visible=logoEnabled and DBSharedLogoAsset==""
                pack.LogoFallback.TextColor3=Color3.fromRGB(174,185,212)
                pack.LogoFallback.TextTransparency=0.84
            end
            if pack.BorderStroke then
                if borderMode=="彩虹" then
                    pack.BorderStroke.Color=Color3.new(1,1,1)
                    pack.BorderStroke.Transparency=0.18
                    if pack.BorderGradient then
                        pack.BorderGradient.Enabled=true
                        pack.BorderGradient.Color=DB_DEEP_RAINBOW_FLOW
                    end
                else
                    if pack.BorderGradient then pack.BorderGradient.Enabled=false end
                    pack.BorderStroke.Color=DB_SPATIAL_BORDER_COLORS[borderMode] or Color3.fromRGB(0,0,0)
                    pack.BorderStroke.Transparency=(borderMode=="默认") and 0.16 or 0.34
                end
            end
        end
    end

    local function refreshBackGhost(pack)
        if not pack or not pack.BackSurface or not pack.Root then return end
        if pack.BackRoot and pack.BackRoot.Parent then destroy(pack.BackRoot) end
        local ok, ghost = pcall(function() return pack.Root:Clone() end)
        if not ok or not ghost then return end
        ghost.Name="SpatialBackGhost"
        ghost.Active=false
        for _,d in ipairs(ghost:GetDescendants()) do
            if d:IsA("GuiButton") then
                d.Active=false; pcall(function() d.Selectable=false end); pcall(function() d.AutoButtonColor=false end)
            end
            if d:IsA("ScrollingFrame") then d.Active=false; d.ScrollingEnabled=false end
            if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                d.TextTransparency=math.max(d.TextTransparency,0.24)
                d.TextStrokeTransparency=1
                if d.BackgroundTransparency<1 then d.BackgroundTransparency=math.max(d.BackgroundTransparency,0.38) end
            elseif d:IsA("ImageLabel") or d:IsA("ImageButton") then
                d.ImageTransparency=math.max(d.ImageTransparency,0.20)
                if d.BackgroundTransparency<1 then d.BackgroundTransparency=math.max(d.BackgroundTransparency,0.40) end
            elseif d:IsA("Frame") or d:IsA("CanvasGroup") then
                if d.BackgroundTransparency<1 then d.BackgroundTransparency=math.max(d.BackgroundTransparency,0.42) end
            elseif d:IsA("UIStroke") then
                d.Transparency=math.max(d.Transparency,0.74)
            end
        end
        ghost.Parent=pack.BackSurface
        pack.BackRoot=ghost
    end

    local function wireButton(button,callback)
        local last=0
        local activeInput=nil
        local startPos=nil
        local startedAt=0
        local moved=false
        local moveLimit=20
        local MAX_HOLD=0.68
        local function fire()
            local now=os.clock(); if now-last<0.14 then return end
            last=now; pcall(callback)
        end
        local function resetGesture()
            activeInput=nil; startPos=nil; startedAt=0; moved=false
        end
        local function matchesEnd(input)
            if not activeInput then return false end
            if activeInput.UserInputType==Enum.UserInputType.Touch then return input==activeInput end
            return input.UserInputType==Enum.UserInputType.MouseButton1
        end
        button.InputBegan:Connect(function(input)
            if not S.Enabled or S.Closing then return end
            if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
            activeInput=input
            startPos=Vector2.new(input.Position.X,input.Position.Y)
            startedAt=os.clock(); moved=false
            local cam=workspace.CurrentCamera
            local vh=(cam and cam.ViewportSize.Y) or 720
            moveLimit=math.clamp(vh*0.028,16,24)
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not activeInput or not startPos then return end
            local pos=nil
            if activeInput.UserInputType==Enum.UserInputType.Touch then
                if input~=activeInput then return end
                pos=Vector2.new(input.Position.X,input.Position.Y)
            else
                if input.UserInputType~=Enum.UserInputType.MouseMovement then return end
                pos=Vector2.new(input.Position.X,input.Position.Y)
            end
            if pos and (pos-startPos).Magnitude>moveLimit then moved=true end
        end)
        local function finish(input)
            if not matchesEnd(input) then return end
            local held=os.clock()-startedAt
            local okTap=(not moved) and held<=MAX_HOLD and S.Enabled and not S.Closing
            resetGesture()
            if okTap then fire() end
        end
        button.InputEnded:Connect(finish)
        UserInputService.InputEnded:Connect(finish)
        return button
    end

    local function addFocusCatcher(pack)
        if not pack or not pack.Root then return end
        local b=Instance.new("TextButton")
        b.Name="DB_CarouselFocus"; b.Size=UDim2.fromScale(1,1); b.BackgroundTransparency=1; b.BorderSizePixel=0
        b.Text=""; b.AutoButtonColor=false; b.Active=true; b.Visible=false; b.ZIndex=238; b.Parent=pack.Root
        pack.FocusButton=b
        wireButton(b,function()
            if S.Enabled and not S.Closing and pack.Name~="MusicStrip" then S.FocusName=pack.Name end
        end)
    end

    local panelTapInput=nil
    local panelTapStart=nil
    local panelTapStartedAt=0
    local panelTapMoved=false
    local panelTapPack=nil
    local function panelPackAtScreen(pos)
        if narrowMode or S.AnchorBlend>0.10 or S.AnchorTarget then return nil end
        if not S.Enabled or S.Closing or S.MinimizeProgress>0.15 then return nil end
        local cam=workspace.CurrentCamera; if not cam or not pos then return nil end
        local parts={}; local byPart={}
        for _,name in ipairs({"Left","Center","Right"}) do
            local pack=S.Surfaces[name]
            if pack and pack.Part and pack.Part.Parent then
                table.insert(parts,pack.Part); byPart[pack.Part]=pack
            end
        end
        if #parts==0 then return nil end
        local params=RaycastParams.new()
        params.FilterType=Enum.RaycastFilterType.Include
        params.FilterDescendantsInstances=parts
        params.IgnoreWater=true
        local ray=cam:ViewportPointToRay(pos.X,pos.Y)
        local hit=workspace:Raycast(ray.Origin,ray.Direction*80,params)
        return hit and byPart[hit.Instance] or nil
    end
    UserInputService.InputBegan:Connect(function(input)
        if not S.Enabled or S.Closing then return end
        if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
        if panelTapInput then return end
        local cam=workspace.CurrentCamera; local vp=cam and cam.ViewportSize
        if input.UserInputType==Enum.UserInputType.Touch and vp
        and input.Position.X<=vp.X*0.36 and input.Position.Y>=vp.Y*0.53 then return end
        local pos=Vector2.new(input.Position.X,input.Position.Y)
        local pack=panelPackAtScreen(pos)
        if not pack then return end
        panelTapInput=input; panelTapStart=pos; panelTapStartedAt=os.clock(); panelTapMoved=false; panelTapPack=pack
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not panelTapInput or not panelTapStart then return end
        local pos=nil
        if panelTapInput.UserInputType==Enum.UserInputType.Touch then
            if input~=panelTapInput then return end
            pos=Vector2.new(input.Position.X,input.Position.Y)
        else
            if input.UserInputType~=Enum.UserInputType.MouseMovement then return end
            pos=Vector2.new(input.Position.X,input.Position.Y)
        end
        local cam=workspace.CurrentCamera; local vh=(cam and cam.ViewportSize.Y) or 720
        local limit=math.clamp(vh*0.030,17,25)
        if pos and (pos-panelTapStart).Magnitude>limit then panelTapMoved=true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if not panelTapInput then return end
        local ended=(panelTapInput.UserInputType==Enum.UserInputType.Touch and input==panelTapInput)
            or (panelTapInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1)
        if not ended then return end
        local endPos=Vector2.new(input.Position.X,input.Position.Y)
        if panelTapInput.UserInputType==Enum.UserInputType.MouseButton1 then
            local ok,p=pcall(function() return UserInputService:GetMouseLocation() end)
            if ok and p then endPos=p end
        end
        local held=os.clock()-panelTapStartedAt
        local startPack=panelTapPack
        local endPack=panelPackAtScreen(endPos)
        local shouldSwitch=(not panelTapMoved) and held<=0.72 and startPack and endPack==startPack
            and startPack.Name~=S.FocusName and S.Enabled and not S.Closing
        panelTapInput=nil; panelTapStart=nil; panelTapStartedAt=0; panelTapMoved=false; panelTapPack=nil
        if shouldSwitch then S.FocusName=startPack.Name end
    end)

    local function makeMusicStrip()
        local p=makeSurface("MusicStrip",4.72,0.68,520,72,"")
        p.Surface.AlwaysOnTop=true; p.Header.Visible=false; p.ContentHost.Position=UDim2.fromOffset(6,6); p.ContentHost.Size=UDim2.new(1,-12,1,-12)
        local function btn(txt,x,w)
            local b=Instance.new("TextButton")
            b.Position=UDim2.fromOffset(x,5); b.Size=UDim2.fromOffset(w,49); b.BackgroundColor3=Color3.fromRGB(255,255,255)
            b.BackgroundTransparency=0.85; b.BorderSizePixel=0; b.AutoButtonColor=false; b.Text=txt
            b.TextColor3=Color3.fromRGB(248,248,252); b.TextSize=txt=="▶" and 18 or 25; b.Font=Enum.Font.GothamBold; b.ZIndex=45
            b.Active=true; b.Parent=p.ContentHost; AddCorner(b,12); return b
        end
        local prev=btn("‹",2,48); local play=btn("▶",54,54); local nextB=btn("›",112,48); S.MusicPlayButton=play
        local title=Instance.new("TextLabel")
        title.Position=UDim2.fromOffset(172,4); title.Size=UDim2.new(1,-180,0,27); title.BackgroundTransparency=1; title.Text="大肥鱼 环绕音效"
        title.TextColor3=Color3.fromRGB(250,250,253); title.TextSize=13; title.Font=Enum.Font.GothamBold; title.TextXAlignment=Enum.TextXAlignment.Left
        title.TextTruncate=Enum.TextTruncate.AtEnd; title.ZIndex=40; title.Parent=p.ContentHost; S.MusicTitle=title
        local status=Instance.new("TextLabel")
        status.Position=UDim2.fromOffset(172,31); status.Size=UDim2.new(1,-180,0,21); status.BackgroundTransparency=1; status.Text="点 ▶ 播放 / 暂停 · 轻触右侧打开播放器"
        status.TextColor3=Color3.fromRGB(182,195,211); status.TextSize=10; status.Font=Enum.Font.GothamMedium; status.TextXAlignment=Enum.TextXAlignment.Left
        status.TextTruncate=Enum.TextTruncate.AtEnd; status.ZIndex=40; status.Parent=p.ContentHost; S.MusicStatus=status
        local open=Instance.new("TextButton")
        open.Position=UDim2.fromOffset(166,0); open.Size=UDim2.new(1,-166,1,0); open.BackgroundTransparency=1; open.BorderSizePixel=0
        open.Text=""; open.AutoButtonColor=false; open.Active=true; open.ZIndex=46; open.Parent=p.ContentHost
        wireButton(prev,function() if DBMusic and type(DBMusic.PreviousSpatialTrack)=="function" then DBMusic.PreviousSpatialTrack() end end)
        wireButton(play,function() if DBMusic and type(DBMusic.ToggleSpatialPlayback)=="function" then DBMusic.ToggleSpatialPlayback() end end)
        wireButton(nextB,function() if DBMusic and type(DBMusic.NextSpatialTrack)=="function" then DBMusic.NextSpatialTrack() end end)
        wireButton(open,function() if DBMusic and type(DBMusic.ShowAdvanced)=="function" then DBMusic.ShowAdvanced() end end)
        return p
    end

    local function makeMiniButton()
        local part=makePart("DB_AR130_MiniButton",2.04,0.52)
        local surface=Instance.new("SurfaceGui")
        surface.ResetOnSpawn=false
        surface.Name="DB_Spatial_V130_Mini"; surface.Adornee=part; surface.Face=Enum.NormalId.Front; surface.Active=true; surface.AlwaysOnTop=true
        surface.LightInfluence=0; surface.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize; surface.CanvasSize=Vector2.new(230,58); surface.ZOffset=0.04
        surface.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; surface.Enabled=false; surface.Parent=__dbPlayerGui
        local root=Instance.new("Frame")
        root.Size=UDim2.fromScale(1,1); root.BackgroundColor3=Color3.fromRGB(5,8,14); root.BackgroundTransparency=0.09; root.BorderSizePixel=0
        root.ClipsDescendants=true; root.Active=true; root.ZIndex=10; root.Parent=surface; AddCorner(root,999)
        local border=Instance.new("Frame")
        border.Position=UDim2.fromOffset(3,3); border.Size=UDim2.new(1,-6,1,-6); border.BackgroundTransparency=1; border.BorderSizePixel=0; border.ZIndex=30
        border.Parent=root; AddCorner(border,999)
        local miniStroke=Instance.new("UIStroke"); miniStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; miniStroke.Thickness=1.05
        miniStroke.Transparency=0.56; miniStroke.Color=Color3.fromRGB(214,222,235); miniStroke.LineJoinMode=Enum.LineJoinMode.Round; miniStroke.Parent=border
        local button=Instance.new("TextButton")
        button.Size=UDim2.fromScale(1,1); button.BackgroundTransparency=1; button.BorderSizePixel=0; button.Text="大肥鱼脚本  ·  展开空间面板"
        button.TextColor3=Color3.fromRGB(250,250,253); button.TextSize=13; button.Font=Enum.Font.GothamBlack; button.AutoButtonColor=false
        button.Active=true; button.ZIndex=35; button.Parent=root; wireButton(button,function() Controller.SetMinimized(false) end)
        local pack={Name="Mini",Part=part,Surface=surface,Root=root,Button=button,WidthStud=2.04,HeightStud=0.52}
        S.Surfaces.Mini=pack; S.Mini=pack; return pack
    end

    local function makeBars()
        S.Bars={}
        for i=1,BAR_COUNT do
            local b=Instance.new("Part")
            b.Name=string.format("DB_AR130_Wave_%02d",i); b.Anchored=true; b.CanCollide=false; b.CanTouch=false; b.CanQuery=false; b.CastShadow=false
            b.Material=Enum.Material.Neon; b.Size=Vector3.new(0.14,0.055,0.18); b.Transparency=0.10; b.Color=Color3.fromRGB(70,225,94); b.Parent=S.WorldFolder
            S.Bars[i]=b
        end
    end
    local function colorFor(level)
        level=clamp01(level)
        if level<0.24 then return Color3.fromRGB(78,218,86):Lerp(Color3.fromRGB(55,232,108),level/0.24) end
        if level<0.52 then return Color3.fromRGB(55,232,108):Lerp(Color3.fromRGB(26,225,162),(level-0.24)/0.28) end
        if level<0.78 then return Color3.fromRGB(26,225,162):Lerp(Color3.fromRGB(20,202,211),(level-0.52)/0.26) end
        return Color3.fromRGB(20,202,211):Lerp(Color3.fromRGB(41,78,238),(level-0.78)/0.22)
    end
    local function sampleLevel(levels,index,count)
        if type(levels)~="table" or #levels==0 then return 0 end
        local pos=1+((index-1)/math.max(1,count-1))*math.max(0,#levels-1); local a=math.floor(pos); local bb=math.min(#levels,a+1); local t=pos-a
        return clamp01((tonumber(levels[a]) or 0)+((tonumber(levels[bb]) or 0)-(tonumber(levels[a]) or 0))*t)
    end
    local function snapshot()
        local snap=nil
        if DBMusic and type(DBMusic.GetSpatialSnapshot)=="function" then local ok,r=pcall(DBMusic.GetSpatialSnapshot); if ok and type(r)=="table" then snap=r end end
        snap=snap or {Title="",Artist="",Platform="",Status="",Playing=false,Levels={},Rms=0}; S.LastSnapshot=snap
        if S.MusicTitle and S.MusicTitle.Parent then S.MusicTitle.Text=snap.Title~="" and (snap.Title..(snap.Artist~="" and (" · "..snap.Artist) or "")) or "大肥鱼 环绕音效" end
        if S.MusicStatus and S.MusicStatus.Parent then S.MusicStatus.Text=(snap.Platform~="" and (snap.Platform.." · ") or "")..(snap.Status~="" and snap.Status or "点 ▶ 播放 / 暂停") end
        if S.MusicPlayButton and S.MusicPlayButton.Parent then S.MusicPlayButton.Text=snap.Playing and "Ⅱ" or "▶" end
        return snap
    end

    local function updateBars(basis,openP,collapse,dt)
        S.SpectrumAccumulator=S.SpectrumAccumulator+dt; if S.SpectrumAccumulator<1/30 then return end
        S.SpectrumAccumulator=S.SpectrumAccumulator%(1/30)
        local snap=snapshot(); local levels=snap.Levels or {}; local maxLevel=0
        for i=1,#levels do local v=tonumber(levels[i]) or 0; if v>maxLevel then maxLevel=v end end
        local status=tostring(snap.Status or "")
        local active=(snap.Playing==true) or (tonumber(snap.Rms) or 0)>0.002 or maxLevel>0.006 or (status:find("播放",1,true)~=nil and status:find("暂停",1,true)==nil)
        local origin=basis.Position; local right=basis.RightVector; local up=basis.UpVector; local look=basis.LookVector
        local radius=5.40; local maxAngle=math.rad(72); local collapseFade=1-smooth(math.clamp((collapse-0.62)/0.38,0,1))
        local clock=os.clock(); local center=(BAR_COUNT+1)*0.5
        for i,b in ipairs(S.Bars) do
            if b and b.Parent then
                local t=(i-1)/math.max(1,BAR_COUNT-1); local theta=-maxAngle+(maxAngle*2)*t
                local level=sampleLevel(levels,i,BAR_COUNT)
                if active and maxLevel<0.003 then
                    local d=math.floor(math.abs(i-center)); local phase=clock-d*0.055
                    level=math.clamp(0.12+0.30*((math.sin(phase*5.0)+1)*0.5)+0.18*((math.sin(phase*9.2+0.8)+1)*0.5)+0.25*(math.max(0,math.sin(phase*6.2))^5),0.08,0.90)
                elseif not active then level=0 end
                local orbit=active and math.rad(math.sin(clock*1.55)*3.6) or 0
                local ripple=active and math.rad(math.sin(clock*5.2+(i-center)*0.44)*(0.45+level*2.35)) or 0
                local animatedTheta=theta+orbit+ripple
                local height=0.055+(level^0.84)*2.42
                local dir=look*math.cos(animatedTheta)+right*math.sin(animatedTheta)
                local radialPulse=active and (math.sin(clock*4.6+i*0.31)*0.035*level) or 0
                local base=origin+dir*(radius+radialPulse)-up*2.10
                local pos=base+up*(height*0.5)
                b.Size=Vector3.new(0.14+level*0.035,height,0.18+level*0.055)
                local roll=active and math.rad(math.sin(clock*7.4+i*0.63)*(1.8+level*7.2)) or 0
                local yaw=active and math.rad(math.sin(clock*4.1-i*0.37)*(0.8+level*3.8)) or 0
                b.CFrame=CFrame.lookAt(pos,origin+look*0.55-up*1.05,up)*CFrame.Angles(0,yaw,roll)
                b.Color=colorFor(level)
                b.Transparency=math.clamp((active and 0.06 or 0.70)+(1-openP)*0.14+(1-collapseFade)*0.90,0.04,0.97)
            end
        end
    end

    local function saveProfile(obj,props)
        if not obj or S.ProfileOriginal[obj] then return end
        local sv={}
        for _,prop in ipairs(props) do local ok,val=pcall(function() return obj[prop] end); if ok then sv[prop]=val end end
        S.ProfileOriginal[obj]=sv
    end
    local function restoreProfileLayout()
        for obj,sv in pairs(S.ProfileOriginal) do
            if obj and obj.Parent then for prop,val in pairs(sv) do pcall(function() obj[prop]=val end) end end
        end
        S.ProfileOriginal={}
    end
    local function applyProfileLayout()
        if not PlayerInfoCard or not PlayerInfoCard.Parent then return end
        saveProfile(PlayerInfoCard,{"Size","Position"})
        saveProfile(PlayerAvatar,{"Position","Size","ScaleType","Visible"})
        saveProfile(PlayerNameLabel,{"Position","Size","TextSize"})
        saveProfile(PlayerAgeLabel,{"Position","Size","TextSize"})
        saveProfile(PlayerUsernameLabel,{"Position","Size","TextSize"})
        if PlayerInfoTitle then saveProfile(PlayerInfoTitle,{"Position","Size","TextSize"}) end
        PlayerInfoCard.Size=UDim2.new(1,-10,0,188); PlayerInfoCard.Position=UDim2.fromOffset(5,4)
        if PlayerInfoTitle then PlayerInfoTitle.Position=UDim2.fromOffset(9,6); PlayerInfoTitle.Size=UDim2.new(1,-18,0,18); PlayerInfoTitle.TextSize=11 end
        PlayerAvatar.Visible=true; PlayerAvatar.Position=UDim2.fromOffset(10,30); PlayerAvatar.Size=UDim2.fromOffset(66,66); PlayerAvatar.ScaleType=Enum.ScaleType.Fit
        PlayerNameLabel.Position=UDim2.fromOffset(10,102); PlayerNameLabel.Size=UDim2.new(1,-20,0,26); PlayerNameLabel.TextSize=10
        PlayerAgeLabel.Position=UDim2.fromOffset(10,129); PlayerAgeLabel.Size=UDim2.new(1,-20,0,24); PlayerAgeLabel.TextSize=9
        PlayerUsernameLabel.Position=UDim2.fromOffset(10,154); PlayerUsernameLabel.Size=UDim2.new(1,-20,0,27); PlayerUsernameLabel.TextSize=9
        local viewport=PlayerInfoCard:FindFirstChild("Player3DViewport")
        if viewport then saveProfile(viewport,{"Position","Size","Visible"}); viewport.Visible=false end
        local sw=PlayerInfoCard:FindFirstChild("Player3DSwitch")
        if sw then saveProfile(sw,{"Position","Size","Visible"}); sw.Visible=false end
        local mixer=PlayerProfileScroll and PlayerProfileScroll:FindFirstChild("DB_Music_VolumeMixer")
        if mixer then saveProfile(mixer,{"Position","Size"}); mixer.Position=UDim2.fromOffset(5,196); mixer.Size=UDim2.new(1,-10,0,188) end
        if PlayerProfileScroll then saveProfile(PlayerProfileScroll,{"CanvasSize"}); PlayerProfileScroll.CanvasSize=UDim2.fromOffset(0,394) end
    end

    local function attach(obj,pack)
        if not obj or not pack then return end
        remember(obj); obj.Parent=pack.ContentHost; obj.AnchorPoint=Vector2.new(0,0); obj.Position=UDim2.fromScale(0,0); obj.Size=UDim2.fromScale(1,1)
        obj.Visible=true; obj.ClipsDescendants=true
        for _,d in ipairs(obj:GetDescendants()) do
            if d:IsA("GuiButton") then d.Active=true end
            if d:IsA("ScrollingFrame") then d.Active=true; d.ScrollingEnabled=true end
        end
    end
    local restoreSpatialStyles
    local function restoreRails() if restoreSpatialStyles then restoreSpatialStyles() end; restore(PlayerProfileRail); restore(RightList); restore(LeftMenu); restoreProfileLayout() end
    local function getBlur()
        local blur=Lighting:FindFirstChild("DB_SpatialTransitionBlur_V130")
        if not blur then blur=Instance.new("BlurEffect"); blur.Name="DB_SpatialTransitionBlur_V130"; blur.Size=0; blur.Parent=Lighting; S.BlurOwned=true end
        S.Blur=blur; return blur
    end
    local function setBlur(amount) local blur=S.Blur or getBlur(); if blur then pcall(function() blur.Size=math.clamp(amount or 0,0,14) end) end end

    local function saveStyle(obj,props)
        if not obj then return end
        local sv=S.StyleOriginal[obj]
        if not sv then sv={}; S.StyleOriginal[obj]=sv end
        for _,prop in ipairs(props) do
            if sv[prop]==nil then
                local ok,val=pcall(function() return obj[prop] end)
                if ok then sv[prop]=val end
            end
        end
    end
    local function rememberStyleAdded(obj)
        if obj then table.insert(S.StyleAdded,obj) end
        return obj
    end
    restoreSpatialStyles = function()
        for _,c in ipairs(S.StyleConnections) do pcall(function() c:Disconnect() end) end
        S.StyleConnections={}
        for obj,sv in pairs(S.StyleOriginal) do
            if obj and obj.Parent then
                for prop,val in pairs(sv) do pcall(function() obj[prop]=val end) end
                if obj:IsA("GuiButton") then
                    obj:SetAttribute("DB_SpatialNavButton",nil)
                    obj:SetAttribute("DB_SpatialSelected",nil)
                    obj:SetAttribute("DB_SpatialPressActive",nil)
                    obj:SetAttribute("DB_SpatialPulseUntil",nil)
                    obj:SetAttribute("DB_SpatialActionButton",nil)
                    obj:SetAttribute("DB_SpatialActionBaseTransparency",nil)
                    obj:SetAttribute("DB_SpatialActionBaseColor",nil)
                    obj:SetAttribute("DB_SpatialActionPulseUntil",nil)
                end
            end
        end
        for _,obj in ipairs(S.StyleAdded) do if obj and obj.Parent then pcall(function() obj:Destroy() end) end end
        S.StyleAdded={}
        S.StyleOriginal={}; S.NavButtons={}; S.ActionButtons={}; S.NavSelected=nil; S.NavSelectionLockUntil=0; S.LastNavCategory=nil
    end
    local function hideStrokes(root)
        if not root then return end
        for _,d in ipairs(root:GetDescendants()) do
            if d:IsA("UIStroke") then saveStyle(d,{"Transparency"}); d.Transparency=1 end
        end
    end
    local function styleCenterRow(obj)
        if not obj or not obj.Parent then return end
        if obj:IsA("Frame") then
            if obj.BackgroundTransparency < 0.999 then
                saveStyle(obj,{"BackgroundColor3","BackgroundTransparency"})
                obj.BackgroundColor3=Color3.fromRGB(255,255,255)
                obj.BackgroundTransparency=math.max(obj.BackgroundTransparency,0.90)
            end
            hideStrokes(obj)
        end
    end
    local function navLabel(btn)
        if not btn then return "" end
        local text=tostring(btn.Text or "")
        if text~="" then return text end
        for _,d in ipairs(btn:GetChildren()) do
            if d:IsA("TextLabel") and tostring(d.Text or "")~="" then return tostring(d.Text) end
        end
        return ""
    end
    local NAV_SELECTED_TRANSPARENCY=0.80
    local NAV_TAP_PULSE=0.08

    local function navMatchesCurrent(btn)
        local label=navLabel(btn)
        local current=tostring(State.CurrentCategory or "")
        if label=="" then return false end
        if current==label then return true end
        if current:sub(1,#label+1)==label.."/" then return true end
        return false
    end

    local function styleNavButton(btn)
        if not btn or not btn:IsA("TextButton") then return end
        if btn:GetAttribute("DB_SpatialPersistentSelection")==true then return end
        if not table.find(S.NavButtons,btn) then table.insert(S.NavButtons,btn) end
        saveStyle(btn,{"Size","BackgroundColor3","BackgroundTransparency","TextSize","Selectable","AutoButtonColor"})
        btn:SetAttribute("DB_SpatialNavButton",true)
        btn:SetAttribute("DB_SpatialSelected",false)
        btn:SetAttribute("DB_SpatialPressActive",false)
        btn:SetAttribute("DB_SpatialPulseUntil",0)
        btn.BackgroundColor3=Color3.fromRGB(255,255,255)
        btn.BackgroundTransparency=1
        btn.Selectable=false
        btn.AutoButtonColor=false
        btn.Size=UDim2.new(btn.Size.X.Scale,btn.Size.X.Offset,0,28)
        if btn.TextSize>12 then btn.TextSize=12 end
        for _,d in ipairs(btn:GetChildren()) do
            if d:IsA("UIStroke") then saveStyle(d,{"Transparency"}); d.Transparency=1
            elseif d:IsA("UICorner") then saveStyle(d,{"CornerRadius"}); d.CornerRadius=UDim.new(0,7) end
        end

        local activeInput=nil
        local startPos=nil
        local startedAt=0
        local moved=false
        local moveLimit=18
        local function matchesEnd(input)
            if not activeInput then return false end
            if activeInput.UserInputType==Enum.UserInputType.Touch then return input==activeInput end
            return input.UserInputType==Enum.UserInputType.MouseButton1
        end
        local c1=btn.InputBegan:Connect(function(input)
            if not S.Enabled or S.Closing then return end
            if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
            activeInput=input
            startPos=Vector2.new(input.Position.X,input.Position.Y)
            startedAt=os.clock()
            moved=false
            local cam=workspace.CurrentCamera
            local vh=(cam and cam.ViewportSize.Y) or 720
            moveLimit=math.clamp(vh*0.021,13,19)
            btn:SetAttribute("DB_SpatialPressActive",false)
            btn:SetAttribute("DB_SpatialPulseUntil",0)
        end)
        local c2=UserInputService.InputChanged:Connect(function(input)
            if not activeInput or not startPos then return end
            local pos=nil
            if activeInput.UserInputType==Enum.UserInputType.Touch then
                if input~=activeInput then return end
                pos=Vector2.new(input.Position.X,input.Position.Y)
            else
                if input.UserInputType~=Enum.UserInputType.MouseMovement then return end
                pos=Vector2.new(input.Position.X,input.Position.Y)
            end
            if pos and (pos-startPos).Magnitude>moveLimit then moved=true end
        end)
        local function finish(input)
            if not matchesEnd(input) then return end
            local validTap=(not moved) and (os.clock()-startedAt)<=0.66 and S.Enabled and not S.Closing
            activeInput=nil
            startPos=nil
            startedAt=0
            moved=false
            if validTap then
                S.NavSelected=btn
                S.NavSelectionLockUntil=os.clock()+0.32
                btn:SetAttribute("DB_SpatialPulseUntil",os.clock()+NAV_TAP_PULSE)
            else
                btn:SetAttribute("DB_SpatialPulseUntil",0)
            end
        end
        local c3=btn.InputEnded:Connect(finish)
        local c4=UserInputService.InputEnded:Connect(finish)
        table.insert(S.StyleConnections,c1); table.insert(S.StyleConnections,c2); table.insert(S.StyleConnections,c3); table.insert(S.StyleConnections,c4)
    end

    local ACTION_FLASH_TIME=0.10
    local ACTION_FLASH_TRANSPARENCY=0.50
    local ACTION_BASE_COLOR=Color3.fromRGB(42,44,50)
    local ACTION_BASE_TRANSPARENCY=0.10

    local function actionUsesOwnVisual(btn)
        if not btn then return true end
        if btn:GetAttribute("DB_SpatialNavButton")==true then return true end
        if btn:GetAttribute("DB_SpatialPersistentSelection")==true then return true end
        if btn:GetAttribute("DB_SpatialPreserveBaseVisual")==true then return true end
        if tostring(btn.Text or "")=="" then return true end
        local name=string.lower(tostring(btn.Name or ""))
        if string.find(name,"toggle",1,true)
        or string.find(name,"switch",1,true)
        or string.find(name,"selector",1,true)
        or string.find(name,"slider",1,true) then
            return true
        end
        return false
    end

    local function restoreActionButtonVisual(btn)
        if not btn or not btn.Parent then return end
        btn.BackgroundColor3=ACTION_BASE_COLOR
        btn.BackgroundTransparency=ACTION_BASE_TRANSPARENCY
        btn.Selectable=false
        btn.AutoButtonColor=false
    end

    local function styleActionButton(btn)
        if not btn or not btn:IsA("TextButton") then return end
        if actionUsesOwnVisual(btn) then return end
        if btn:GetAttribute("DB_SpatialActionButton")==true then
            restoreActionButtonVisual(btn)
            return
        end
        if not table.find(S.ActionButtons,btn) then table.insert(S.ActionButtons,btn) end

        saveStyle(btn,{"BackgroundColor3","BackgroundTransparency","Selectable","AutoButtonColor"})
        btn:SetAttribute("DB_SpatialActionButton",true)
        btn:SetAttribute("DB_SpatialActionBaseTransparency",ACTION_BASE_TRANSPARENCY)
        btn:SetAttribute("DB_SpatialActionBaseColor",ACTION_BASE_COLOR)
        btn:SetAttribute("DB_SpatialActionPulseUntil",0)
        btn.Selectable=false
        btn.AutoButtonColor=false
        restoreActionButtonVisual(btn)

        local activeInput=nil
        local startPos=nil
        local startedAt=0
        local moved=false
        local moveLimit=18

        local function matchesEnd(input)
            if not activeInput then return false end
            if activeInput.UserInputType==Enum.UserInputType.Touch then return input==activeInput end
            return input.UserInputType==Enum.UserInputType.MouseButton1
        end

        local c1=btn.InputBegan:Connect(function(input)
            if not S.Enabled or S.Closing then return end
            if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
            activeInput=input
            startPos=Vector2.new(input.Position.X,input.Position.Y)
            startedAt=os.clock()
            moved=false
            local cam=workspace.CurrentCamera
            local vh=(cam and cam.ViewportSize.Y) or 720
            moveLimit=math.clamp(vh*0.021,13,19)
            btn:SetAttribute("DB_SpatialActionPulseUntil",0)
            restoreActionButtonVisual(btn)
        end)

        local c2=UserInputService.InputChanged:Connect(function(input)
            if not activeInput or not startPos then return end
            local pos=nil
            if activeInput.UserInputType==Enum.UserInputType.Touch then
                if input~=activeInput then return end
                pos=Vector2.new(input.Position.X,input.Position.Y)
            else
                if input.UserInputType~=Enum.UserInputType.MouseMovement then return end
                pos=Vector2.new(input.Position.X,input.Position.Y)
            end
            if pos and (pos-startPos).Magnitude>moveLimit then
                moved=true
                btn:SetAttribute("DB_SpatialActionPulseUntil",0)
                restoreActionButtonVisual(btn)
            end
        end)

        local function finish(input)
            if not matchesEnd(input) then return end
            local validTap=(not moved) and (os.clock()-startedAt)<=0.62 and S.Enabled and not S.Closing
            activeInput=nil
            startPos=nil
            startedAt=0
            moved=false

            if validTap and btn.Parent then
                btn:SetAttribute("DB_SpatialActionPulseUntil",os.clock()+ACTION_FLASH_TIME)
            else
                btn:SetAttribute("DB_SpatialActionPulseUntil",0)
                task.defer(function() restoreActionButtonVisual(btn) end)
            end
        end

        local c3=btn.InputEnded:Connect(finish)
        local c4=UserInputService.InputEnded:Connect(finish)
        table.insert(S.StyleConnections,c1); table.insert(S.StyleConnections,c2); table.insert(S.StyleConnections,c3); table.insert(S.StyleConnections,c4)
    end

    local function refreshActionStyle()
        if not S.Enabled then return end
        local now=os.clock()
        for i=#S.ActionButtons,1,-1 do
            local btn=S.ActionButtons[i]
            if not (btn and btn.Parent) then
                table.remove(S.ActionButtons,i)
            elseif btn:GetAttribute("DB_SpatialActionButton")==true then
                local pulseUntil=tonumber(btn:GetAttribute("DB_SpatialActionPulseUntil")) or 0
                btn.Selectable=false
                btn.AutoButtonColor=false
                if pulseUntil>now then
                    btn.BackgroundColor3=Color3.fromRGB(255,255,255)
                    btn.BackgroundTransparency=ACTION_FLASH_TRANSPARENCY
                else
                    btn:SetAttribute("DB_SpatialActionPulseUntil",0)
                    restoreActionButtonVisual(btn)
                end
            end
        end
    end

    local function refreshNavStyle()
        if not S.Enabled then return end
        local now=os.clock()

        local lockUntil=tonumber(S.NavSelectionLockUntil) or 0
        local currentCategory=tostring(State.CurrentCategory or "")
        local categoryChanged=(S.LastNavCategory~=currentCategory)
        if now>=lockUntil and (S.NavSelected==nil or categoryChanged) then
            for _,b in ipairs(S.NavButtons) do
                if b and b.Parent and navMatchesCurrent(b) then
                    S.NavSelected=b
                    break
                end
            end
        end
        S.LastNavCategory=currentCategory

        for _,b in ipairs(S.NavButtons) do
            if b and b.Parent then
                local selected=(S.NavSelected==b)
                b:SetAttribute("DB_SpatialSelected",selected)
                b.BackgroundColor3=Color3.fromRGB(255,255,255)
                local pulseUntil=tonumber(b:GetAttribute("DB_SpatialPulseUntil")) or 0
                if selected then
                    b.BackgroundTransparency=NAV_SELECTED_TRANSPARENCY
                elseif pulseUntil>now then
                    b.BackgroundTransparency=0.86
                else
                    b.BackgroundTransparency=1
                end
                for _,d in ipairs(b:GetChildren()) do if d:IsA("UIStroke") then d.Transparency=1 end end
            end
        end

    end

    local function applySpatialVisualStyle()
        if PlayerInfoCard then
            saveStyle(PlayerInfoCard,{"BackgroundColor3","BackgroundTransparency"})
            PlayerInfoCard.BackgroundColor3=Color3.fromRGB(255,255,255); PlayerInfoCard.BackgroundTransparency=0.92
            hideStrokes(PlayerInfoCard)
        end
        local mixer=PlayerProfileScroll and PlayerProfileScroll:FindFirstChild("DB_Music_VolumeMixer")
        if mixer then
            saveStyle(mixer,{"BackgroundColor3","BackgroundTransparency"})
            mixer.BackgroundColor3=Color3.fromRGB(255,255,255); mixer.BackgroundTransparency=0.92
            hideStrokes(mixer)
        end
        if ProfileRailDivider then saveStyle(ProfileRailDivider,{"BackgroundTransparency"}); ProfileRailDivider.BackgroundTransparency=1 end
        if FunctionRailDivider then saveStyle(FunctionRailDivider,{"BackgroundTransparency"}); FunctionRailDivider.BackgroundTransparency=1 end

        if ListScroll then
            for _,child in ipairs(ListScroll:GetChildren()) do styleCenterRow(child) end
            local conn=ListScroll.ChildAdded:Connect(function(child)
                task.defer(function() if child and child.Parent then styleCenterRow(child) end end)
            end)
            table.insert(S.StyleConnections,conn)
        end
        if RightList then
            for _,d in ipairs(RightList:GetDescendants()) do if d:IsA("TextButton") then styleActionButton(d) end end
            local actionConn=RightList.DescendantAdded:Connect(function(d)
                if d:IsA("TextButton") then
                    task.defer(function()
                        if d and d.Parent then styleActionButton(d) end
                    end)
                end
            end)
            table.insert(S.StyleConnections,actionConn)
        end

        if MenuLayout then saveStyle(MenuLayout,{"Padding"}); MenuLayout.Padding=UDim.new(0,3) end
        if SpecialMenuLayout then saveStyle(SpecialMenuLayout,{"Padding"}); SpecialMenuLayout.Padding=UDim.new(0,3) end
        for _,host in ipairs({MenuScroll,SpecialMenuScroll}) do
            if host then
                for _,d in ipairs(host:GetDescendants()) do if d:IsA("TextButton") then styleNavButton(d) end end
                local conn=host.DescendantAdded:Connect(function(d) if d:IsA("TextButton") then task.defer(function() styleNavButton(d); refreshNavStyle() end) end end)
                table.insert(S.StyleConnections,conn)
            end
        end
        refreshNavStyle()
    end

    local function buildAnchorLayout()
        local cam=workspace.CurrentCamera; if not cam then return nil end
        local center=S.Surfaces.Center; local left=S.Surfaces.Left; local rightP=S.Surfaces.Right
        if not center or not left or not rightP then return nil end
        local char=LocalPlayer.Character
        local hrp=char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not hrp.Parent then return nil end
        local head=char and char:FindFirstChild("Head")
        local refPos=hrp.Position

        local f=cam.CFrame.LookVector; f=Vector3.new(f.X,0,f.Z)
        if f.Magnitude<0.08 then local q=hrp.CFrame.LookVector; f=Vector3.new(q.X,0,q.Z) end
        if f.Magnitude<0.08 then f=Vector3.new(0,0,-1) else f=f.Unit end

        local anchorDistance=narrowMode and 5.95 or 6.25
        local front=refPos+f*anchorDistance
        local desiredCenterY=(head and (head.Position.Y+0.18)) or (hrp.Position.Y+2.25)
        local centerPos=Vector3.new(front.X,desiredCenterY,front.Z)

        local toward=Vector3.new(refPos.X-centerPos.X,0,refPos.Z-centerPos.Z)
        if toward.Magnitude<0.08 then toward=-f else toward=toward.Unit end

        local xOffset=math.clamp(tonumber(DBVisualSettings.SpatialAnchorOffsetX) or 0,-4.0,4.0)
        local yOffset=math.clamp(tonumber(DBVisualSettings.SpatialAnchorOffsetY) or 0,-3.0,3.0)
        local screenRight=cam.CFrame.RightVector
        screenRight=Vector3.new(screenRight.X,0,screenRight.Z)
        if screenRight.Magnitude<0.08 then
            screenRight=Vector3.new(-f.Z,0,f.X)
        else
            screenRight=screenRight.Unit
        end
        centerPos=centerPos+screenRight*xOffset+Vector3.new(0,yOffset,0)

        local baseCf=CFrame.lookAt(centerPos,centerPos+toward,Vector3.new(0,1,0))
        local pitch=math.rad(-7.5)
        local centerCf=baseCf*CFrame.Angles(pitch,0,0)

        local gap=0.07
        local leftOffset=center.WidthStud*0.5+left.WidthStud*0.5+gap
        local rightOffset=center.WidthStud*0.5+rightP.WidthStud*0.5+gap
        local leftY=(left.HeightStud-center.HeightStud)*0.5
        local rightY=(rightP.HeightStud-center.HeightStud)*0.5
        local wing=narrowMode and math.rad(13.5) or math.rad(17.5)
        local wingForward=narrowMode and -0.18 or -0.24
        return {
            Center={CFrame=centerCf,Size=Vector3.new(center.WidthStud,center.HeightStud,PANEL_DEPTH)},
            Left={CFrame=centerCf*CFrame.new(-leftOffset,leftY,wingForward)*CFrame.Angles(0,-wing,0),Size=Vector3.new(left.WidthStud,left.HeightStud,PANEL_DEPTH)},
            Right={CFrame=centerCf*CFrame.new(rightOffset,rightY,wingForward)*CFrame.Angles(0,wing,0),Size=Vector3.new(rightP.WidthStud,rightP.HeightStud,PANEL_DEPTH)},
        }
    end
    local function setAnchorTarget(enabled)
        enabled=enabled==true
        if enabled then
            local layout=buildAnchorLayout(); if not layout then return false end
            S.AnchorLayout=layout; S.AnchorTarget=true
        else
            S.AnchorTarget=false
        end
        if S.AnchorButton and S.AnchorButton.Parent then
            local col=enabled and Color3.fromRGB(54,235,103) or Color3.fromRGB(66,214,105)
            S.AnchorButton.TextColor3=col
            S.AnchorButton.TextTransparency=1
            S.AnchorButton.BackgroundTransparency=1
            if S.AnchorIcon and S.AnchorIcon.Parent then S.AnchorIcon.ImageColor3=col; S.AnchorIcon.ImageTransparency=0 end
            if S.AnchorIconFallback and S.AnchorIconFallback.Parent then S.AnchorIconFallback.TextColor3=col; S.AnchorIconFallback.TextTransparency=0 end
        end
        if enabled then
            task.defer(function()
                for _,pack in pairs(S.Surfaces) do refreshBackGhost(pack) end
            end)
        end
        return true
    end

    local function build()
        removeStale(); local folder=Instance.new("Folder"); folder.Name=FOLDER_NAME; folder.Parent=workspace; S.WorldFolder=folder
        local left = narrowMode and makeSurface("Left",2.28,4.08,250,408,"玩家") or makeSurface("Left",4.28,4.02,430,402,"玩家")
        local center=makeSurface("Center",5.72,4.28,560,428,"主页")
        local right = narrowMode and makeSurface("Right",2.28,4.08,250,408,"功能") or makeSurface("Right",4.36,4.06,440,406,"功能")
        makeMiniButton(); S.CenterTitle=center.Title
        if not narrowMode then addFocusCatcher(left); addFocusCatcher(center); addFocusCatcher(right) end
        S.FocusName="Center"

        local function headerIcon(text,x,w,color,size)
            local b=Instance.new("TextButton")
            b.AnchorPoint=Vector2.new(1,0.5); b.Position=UDim2.new(1,x,0.5,0); b.Size=UDim2.fromOffset(w,24)
            b.BackgroundTransparency=1; b.BorderSizePixel=0; b.Text=text; b.TextColor3=color; b.TextSize=size or 17
            b.Font=Enum.Font.GothamBold; b.AutoButtonColor=false; b.Active=true; b.ZIndex=66; b.Parent=center.Header
            return b
        end
        local anchorBtn=headerIcon("",-6,38,Color3.fromRGB(66,214,105),18)
        anchorBtn.BackgroundTransparency=1; anchorBtn.TextTransparency=1
        local anchorImage=Instance.new("ImageLabel")
        anchorImage.Name="DB_WorldAnchorSwapIcon_V141"
        anchorImage.AnchorPoint=Vector2.new(0.5,0.5); anchorImage.Position=UDim2.fromScale(0.5,0.5); anchorImage.Size=UDim2.fromOffset(30,22)
        anchorImage.BackgroundTransparency=1; anchorImage.BorderSizePixel=0; anchorImage.Image=DBAnchorIconAsset
        anchorImage.ImageColor3=Color3.fromRGB(66,214,105); anchorImage.ImageTransparency=0; anchorImage.ScaleType=Enum.ScaleType.Fit
        anchorImage.ZIndex=67; anchorImage.Parent=anchorBtn
        local anchorFallback=Instance.new("TextLabel")
        anchorFallback.Name="DB_WorldAnchorSwapFallback_V141"
        anchorFallback.AnchorPoint=Vector2.new(0.5,0.5); anchorFallback.Position=UDim2.fromScale(0.5,0.5); anchorFallback.Size=UDim2.fromOffset(31,22)
        anchorFallback.BackgroundTransparency=1; anchorFallback.Text="⇵"; anchorFallback.Rotation=90; anchorFallback.TextColor3=Color3.fromRGB(66,214,105)
        anchorFallback.TextSize=20; anchorFallback.Font=Enum.Font.GothamBlack; anchorFallback.TextTransparency=0; anchorFallback.ZIndex=67
        anchorFallback.Visible=(DBAnchorIconAsset==""); anchorFallback.Parent=anchorBtn
        anchorImage.Visible=(DBAnchorIconAsset~="")
        S.AnchorButton=anchorBtn; S.AnchorIcon=anchorImage; S.AnchorIconFallback=anchorFallback
        local minBtn=headerIcon("−",-44,28,Color3.fromRGB(248,248,252),18)
        local back=headerIcon("←",-74,28,Color3.fromRGB(248,248,252),18)
        wireButton(back,function() setAnchorTarget(false); Controller.SetEnabled(false) end)
        wireButton(minBtn,function() if S.AnchorTarget or S.AnchorBlend>0.04 then setAnchorTarget(false) end; Controller.SetMinimized(true) end)
        wireButton(anchorBtn,function() setAnchorTarget(not S.AnchorTarget) end)
        center.Title.Size=UDim2.new(1,-116,1,0)

        applyProfileLayout(); attach(PlayerProfileRail,left); attach(RightList,center); attach(LeftMenu,right)
        applySpatialVisualStyle()
        refreshPanelAppearance()
        refreshBackGhost(left); refreshBackGhost(center); refreshBackGhost(right)
        getBlur(); setBlur(0)
        return left,center,right,nil
    end
    local function destroyWorld()
        for _,p in pairs(S.Surfaces) do
            if p.BackRoot then destroy(p.BackRoot) end
            if p.BackSurface then destroy(p.BackSurface) end
            if p.Surface then destroy(p.Surface) end
        end
        S.Surfaces={}; S.Mini=nil; destroy(S.WorldFolder); S.WorldFolder=nil; S.Bars={}; S.MusicTitle=nil; S.MusicStatus=nil; S.MusicPlayButton=nil; S.CenterTitle=nil
        S.AnchorTarget=false; S.AnchorBlend=0; S.AnchorVelocity=0; S.AnchorLayout=nil; S.AnchorButton=nil; S.AnchorIcon=nil; S.AnchorIconFallback=nil; S.BackGhostAccumulator=0
        setBlur(0); if S.BlurOwned and S.Blur then destroy(S.Blur) end; S.Blur=nil; S.BlurOwned=false
    end
    local function finalize()
        if DBSpatial and type(Controller.DetachAdvancedMusic)=="function" then pcall(Controller.DetachAdvancedMusic) end
        restoreRails(); destroyWorld(); S.Enabled=false; S.Closing=false; S.Progress=0; S.Velocity=0; S.LookVector=nil; S.UpVector=nil
        S.Minimized=false; S.MinimizeTarget=0; S.MinimizeProgress=0; S.MinimizeVelocity=0
        DBVisualSettings.SpatialModeEnabled=false; Controller.Enabled=false
        State.Minimized=S.PreviousMinimized==true; Panel.Visible=S.PreviousPanelVisible==true; FloatingButton.Visible=S.PreviousFloatingVisible==true
        if State.Minimized then Panel.Visible=false; FloatingButton.Visible=true elseif not Panel.Visible then Panel.Visible=true end
        DBStartupScale.Scale=1; State.Animating=false
        if S.RenderConnection then pcall(function() S.RenderConnection:Disconnect() end); S.RenderConnection=nil end
    end

    local function cameraBasis(cam,dt)
        local currentLook=cam.CFrame.LookVector; local currentUp=cam.CFrame.UpVector
        if not S.LookVector then S.LookVector=currentLook; S.UpVector=currentUp end
        if S.LookVector:Dot(currentLook)<0.48 then S.LookVector=currentLook; S.UpVector=currentUp
        else
            local a=1-math.exp(-dt*12.5); S.LookVector=(S.LookVector:Lerp(currentLook,a)).Unit; S.UpVector=(S.UpVector:Lerp(currentUp,a)).Unit
        end
        return CFrame.lookAt(cam.CFrame.Position,cam.CFrame.Position+S.LookVector,S.UpVector)
    end
    local function setMainSurfaceEnabled(enabled)
        for name,p in pairs(S.Surfaces) do if name~="Mini" and p.Surface then p.Surface.Enabled=enabled end end
    end

    UserInputService.InputBegan:Connect(function(input)
        if not S.Enabled or input.UserInputType~=Enum.UserInputType.Touch then return end
        local cam=workspace.CurrentCamera; local vp=cam and cam.ViewportSize; if not vp then return end
        if input.Position.X <= vp.X*0.36 and input.Position.Y >= vp.Y*0.53 then S.JoystickInputs[input]=true; S.JoystickTouch=true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if S.JoystickInputs[input] then S.JoystickInputs[input]=nil; S.JoystickTouch=next(S.JoystickInputs)~=nil end
    end)

    local function update(dt)
        if not S.Enabled then return end
        local cam=workspace.CurrentCamera; if not cam then return end
        local target=S.Closing and 0 or 1; local accel=(target-S.Progress)*(S.Closing and 74 or 86)-S.Velocity*19
        S.Velocity=S.Velocity+accel*dt; S.Progress=math.clamp(S.Progress+S.Velocity*dt,-0.02,1.03)
        local p=clamp01(S.Progress); local openP=easeOut(p)
        local mTarget=clamp01(S.MinimizeTarget); local mAccel=(mTarget-S.MinimizeProgress)*90-S.MinimizeVelocity*19
        S.MinimizeVelocity=S.MinimizeVelocity+mAccel*dt; S.MinimizeProgress=math.clamp(S.MinimizeProgress+S.MinimizeVelocity*dt,-0.025,1.025)
        if math.abs(mTarget-S.MinimizeProgress)<0.002 and math.abs(S.MinimizeVelocity)<0.028 then S.MinimizeProgress=mTarget; S.MinimizeVelocity=0 end
        local collapse=clamp01(S.MinimizeProgress)

        local basis=cameraBasis(cam,dt); local origin=basis.Position; local right=basis.RightVector; local up=basis.UpVector; local look=basis.LookVector
        local hover=math.sin(os.clock()*1.05)*0.014*(1-collapse); origin=origin+up*(0.30+hover)
        local center=S.Surfaces.Center; local left=S.Surfaces.Left; local rightP=S.Surfaces.Right; local music=S.Surfaces.MusicStrip; local mini=S.Mini

        local focus=origin+look*0.78+up*0.20
        local musicBase=origin+look*4.55+up*(2.66-(1-openP)*0.24)
        local order={"Left","Center","Right"}
        local a=smooth(math.clamp(collapse/0.50,0,1))
        local c=smooth(math.clamp((collapse-0.70)/0.30,0,1))
        local merge=origin+look*4.40+up*0.04
        local finalY=math.max(0.045,1-0.955*c); local finalX=1-0.18*c
        local follow=1-math.exp(-dt*13.8)

        local anchorGoal=S.AnchorTarget and 1 or 0
        local anchorAccel=(anchorGoal-S.AnchorBlend)*82-S.AnchorVelocity*17.5
        S.AnchorVelocity=S.AnchorVelocity+anchorAccel*dt
        S.AnchorBlend=math.clamp(S.AnchorBlend+S.AnchorVelocity*dt,-0.02,1.02)
        if math.abs(anchorGoal-S.AnchorBlend)<0.0025 and math.abs(S.AnchorVelocity)<0.025 then S.AnchorBlend=anchorGoal; S.AnchorVelocity=0 end
        local anchorMix=smooth(math.clamp(S.AnchorBlend,0,1))
        if not S.AnchorTarget and anchorMix<0.002 then S.AnchorLayout=nil end
        if S.AnchorButton and S.AnchorButton.Parent then
            local activeAnchor=(S.AnchorTarget or anchorMix>0.5)
            local col=activeAnchor and Color3.fromRGB(54,235,103) or Color3.fromRGB(66,214,105)
            S.AnchorButton.TextColor3=col; S.AnchorButton.TextTransparency=1; S.AnchorButton.BackgroundTransparency=1
            if S.AnchorIcon and S.AnchorIcon.Parent then S.AnchorIcon.ImageColor3=col; S.AnchorIcon.ImageTransparency=0 end
            if S.AnchorIconFallback and S.AnchorIconFallback.Parent then S.AnchorIconFallback.TextColor3=col; S.AnchorIconFallback.TextTransparency=0 end
        end

        local function applyTransform(pack,targetCf,targetSize,top)
            if not pack or not pack.Part then return end
            local finalCf=targetCf; local finalSize=targetSize
            local anchor=S.AnchorLayout and S.AnchorLayout[pack.Name]
            if anchor and anchorMix>0 then
                finalCf=targetCf:Lerp(anchor.CFrame,anchorMix)
                finalSize=targetSize:Lerp(anchor.Size,anchorMix)
            end
            pack.MotionCFrame=pack.MotionCFrame or finalCf
            pack.MotionCFrame=pack.MotionCFrame:Lerp(finalCf,follow)
            pack.Part.CFrame=pack.MotionCFrame
            pack.Part.Size=finalSize
            pack.Part.Transparency=1
            pack.Surface.AlwaysOnTop=(anchorMix>0.10) and false or top
            if pack.BackSurface then
                pack.BackSurface.AlwaysOnTop=false
                pack.BackSurface.Enabled=(anchorMix>0.035)
            end
            if pack.Frost then pack.Frost.BackgroundTransparency=1 end
        end

        if narrowMode then
            local center=S.Surfaces.Center; local left=S.Surfaces.Left; local rightP=S.Surfaces.Right
            local centerPos=origin+look*(4.48-(1-openP)*0.28)+up*0.04
            local gap=0.08
            local leftOffset=(center.WidthStud*0.5+left.WidthStud*0.5+gap)*openP
            local rightOffset=(center.WidthStud*0.5+rightP.WidthStud*0.5+gap)*openP
            local centerCf=CFrame.lookAt(centerPos,focus,up)
            local leftCf=CFrame.lookAt(centerPos-right*leftOffset+look*0.04,focus,up)
            local rightCf=CFrame.lookAt(centerPos+right*rightOffset+look*0.04,focus,up)
            local sizeScale=(1-0.05*a)*finalX
            applyTransform(center,centerCf,Vector3.new(center.WidthStud*sizeScale,center.HeightStud*finalY,PANEL_DEPTH),true)
            applyTransform(left,leftCf,Vector3.new(left.WidthStud*sizeScale,left.HeightStud*finalY,PANEL_DEPTH),false)
            applyTransform(rightP,rightCf,Vector3.new(rightP.WidthStud*sizeScale,rightP.HeightStud*finalY,PANEL_DEPTH),false)
            if left.FocusButton then left.FocusButton.Visible=false end; if rightP.FocusButton then rightP.FocusButton.Visible=false end
        else
            local selected=2
            for i,n in ipairs(order) do if n==S.FocusName then selected=i break end end
            for i,n in ipairs(order) do
                local pack=S.Surfaces[n]
                if pack and pack.Part then
                    local d=(i-selected)%3
                    local slot=(d==0 and 0) or (d==1 and 1) or -1
                    local basePos
                    if slot==0 then basePos=origin+look*(4.35-(1-openP)*0.30)+up*0.04
                    elseif slot<0 then basePos=origin+look*5.45-right*(3.55*openP)+up*0.03
                    else basePos=origin+look*5.45+right*(3.55*openP)+up*0.03 end
                    local CENTER_SLOT_WIDTH=5.72
                    local CENTER_SLOT_HEIGHT=4.28
                    local SIDE_SLOT_WIDTH=3.02
                    local SIDE_SLOT_HEIGHT=4.04
                    local pos=basePos:Lerp(merge+right*(slot*0.055)+look*(slot==0 and 0 or 0.09),a)
                    local collapseWidth=(1-0.07*a)*finalX
                    local targetWidth=((slot==0) and CENTER_SLOT_WIDTH or SIDE_SLOT_WIDTH)*collapseWidth
                    local targetHeight=((slot==0) and CENTER_SLOT_HEIGHT or SIDE_SLOT_HEIGHT)*finalY
                    local targetCf=CFrame.lookAt(pos,focus,up)*CFrame.Angles(0,0,math.rad(-slot*1.4))
                    applyTransform(pack,targetCf,Vector3.new(targetWidth,targetHeight,PANEL_DEPTH),slot==0)
                    if pack.FocusButton then pack.FocusButton.Visible=(slot~=0 and collapse<0.91 and anchorMix<0.08) end
                end
            end
        end
        if S.CenterTitle then S.CenterTitle.Text=tostring(State.CurrentCategory or "主页") end
        if music and music.Part then
            local musicTarget=merge+up*1.43-look*0.02
            local musicPos=musicBase:Lerp(musicTarget,a)
            music.Part.CFrame=CFrame.lookAt(musicPos,focus,up)
            local widthScale=(1-0.20*a)*(1-0.10*c); local heightScale=math.max(0.08,1-0.90*c)
            music.Part.Size=Vector3.new(music.WidthStud*widthScale,music.HeightStud*heightScale,0.03)
        end

        local frostLevel=math.clamp((collapse-0.62)/0.31,0,1)
        for name,pack in pairs(S.Surfaces) do if name~="Mini" and pack.Frost then pack.Frost.BackgroundTransparency=1-frostLevel*0.27 end end
        local blurPhase=0
        if collapse>0.62 and collapse<0.995 then blurPhase=math.sin(math.clamp((collapse-0.62)/0.375,0,1)*math.pi) end
        setBlur(10.5*blurPhase)
        setMainSurfaceEnabled(collapse<0.988 and p>0.02)

        if mini and mini.Part and mini.Surface then
            local miniP=smooth(math.clamp((collapse-0.855)/0.145,0,1))
            local miniPos=origin+look*4.36+up*2.40
            mini.Part.CFrame=CFrame.lookAt(miniPos,origin+look*0.50+up*0.35,up)
            mini.Part.Size=Vector3.new(mini.WidthStud*math.max(0.055,miniP),mini.HeightStud*math.max(0.07,miniP),0.03)
            mini.Surface.Enabled=miniP>0.035 and p>0.02
        end

        if anchorMix>0.06 then
            S.BackGhostAccumulator=S.BackGhostAccumulator+dt
            if S.BackGhostAccumulator>=0.85 then
                S.BackGhostAccumulator=0
                for _,pack in pairs(S.Surfaces) do refreshBackGhost(pack) end
            end
        else
            S.BackGhostAccumulator=0
        end

        refreshNavStyle()
        refreshActionStyle()
        refreshPanelAppearance()
        if left and left.Surface then
            local moving=false; local char=LocalPlayer.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
            if hum then moving=hum.MoveDirection.Magnitude>0.025 end
            left.Surface.Active=(not moving) and (not S.JoystickTouch) and collapse<0.96
            left.Part.CanQuery=(not moving) and (not S.JoystickTouch) and collapse<0.96
        end
        if S.Closing and p<0.012 and math.abs(S.Velocity)<0.14 then task.defer(finalize) end
    end

    function Controller.RefreshVisualStyle()
        if S.Enabled then refreshNavStyle(); refreshActionStyle(); refreshPanelAppearance() end
    end
    function Controller.RefreshPanelAppearance()
        if not S.Enabled then return false end
        refreshPanelAppearance()
        task.defer(function()
            if not S.Enabled then return end
            for _,pack in pairs(S.Surfaces) do
                if pack.Name~="Mini" then refreshBackGhost(pack) end
            end
        end)
        return true
    end
    function Controller.IsWorldAnchored() return S.AnchorTarget==true or S.AnchorBlend>0.5 end
    function Controller.SetWorldAnchored(v) return setAnchorTarget(v==true) end
    function Controller.ToggleWorldAnchored() return setAnchorTarget(not S.AnchorTarget) end
    function Controller.GetAnchorAdjustment()
        return tonumber(DBVisualSettings.SpatialAnchorOffsetX) or 0, tonumber(DBVisualSettings.SpatialAnchorOffsetY) or 0
    end
    function Controller.SetAnchorAdjustment(x,y)
        x=math.clamp(tonumber(x) or 0,-4.0,4.0)
        y=math.clamp(tonumber(y) or 0,-3.0,3.0)
        DBVisualSettings.SpatialAnchorOffsetX=x
        DBVisualSettings.SpatialAnchorOffsetY=y
        if S.Enabled and not S.Closing and (S.AnchorTarget or S.AnchorBlend>0.04) then
            local layout=buildAnchorLayout()
            if layout then S.AnchorLayout=layout end
        end
        return x,y
    end
    function Controller.IsEnabled() return S.Enabled and not S.Closing end
    function Controller.IsActive() return S.Enabled==true end
    function Controller.IsMinimized() return S.Enabled and S.MinimizeTarget>0.5 end
    function Controller.GetLastError() return S.LastError end
    function Controller.SetMinimized(minimized)
        if not S.Enabled or S.Closing then return end
        S.Minimized=minimized==true; S.MinimizeTarget=S.Minimized and 1 or 0; State.Minimized=S.Minimized; State.Animating=true
        if not S.Minimized then setMainSurfaceEnabled(true) end
        task.delay(0.75,function() if S.Enabled and not S.Closing and math.abs(S.MinimizeProgress-S.MinimizeTarget)<0.02 then State.Animating=false end end)
    end
    function Controller.ToggleMinimized() Controller.SetMinimized(not Controller.IsMinimized()) end
    function Controller.AttachAdvancedMusic(root)
        if not S.Enabled or S.Closing or S.MinimizeTarget>0.5 or not root then return false end
        local center=S.Surfaces.Center; if not center or not center.ContentHost then return false end
        if S.AdvancedRoot==root and root.Parent==center.ContentHost then return true end
        Controller.DetachAdvancedMusic(); S.AdvancedRoot=root
        S.AdvancedOriginal={Parent=root.Parent,Position=root.Position,Size=root.Size,AnchorPoint=root.AnchorPoint,Visible=root.Visible}
        if RightList and RightList.Parent then RightList.Visible=false end
        root.Parent=center.ContentHost; root.AnchorPoint=Vector2.new(0,0); root.Position=UDim2.fromScale(0,0); root.Size=UDim2.fromScale(1,1); root.Visible=true
        return true
    end
    function Controller.DetachAdvancedMusic()
        local root,sv=S.AdvancedRoot,S.AdvancedOriginal
        if root and sv then pcall(function() root.Parent=sv.Parent or Panel; root.Position=sv.Position; root.Size=sv.Size; root.AnchorPoint=sv.AnchorPoint; root.Visible=sv.Visible==true end) end
        S.AdvancedRoot=nil; S.AdvancedOriginal=nil; if RightList and RightList.Parent then RightList.Visible=true end
    end
    function Controller.SetEnabled(enabled)
        enabled=enabled==true
        if enabled then
            if S.Enabled then S.Closing=false; DBVisualSettings.SpatialModeEnabled=true; Controller.Enabled=true; if S.MinimizeTarget>0.5 then Controller.SetMinimized(false) end; return end
            S.PreviousPanelVisible=Panel.Visible; S.PreviousFloatingVisible=FloatingButton.Visible; S.PreviousMinimized=State.Minimized
            AppleTransition.Running=false; AppleTransition.Velocity=0; AppleTransition.ClearSoftFocus(); State.Animating=true; DBStartupScale.Scale=1
            local ok,err=pcall(build)
            if not ok then
                S.LastError=tostring(err); warn("[大肥鱼 V139] 空间模式构建失败，已自动回退2D: ",err); restoreRails(); destroyWorld(); State.Animating=false
                DBVisualSettings.SpatialModeEnabled=false; Controller.Enabled=false; S.Enabled=false; S.Closing=false
                Panel.Visible = (S.PreviousPanelVisible ~= false)
                FloatingButton.Visible = (S.PreviousFloatingVisible == true)
                State.Minimized = (S.PreviousMinimized == true)
                return
            end
            Panel.Visible=false; FloatingButton.Visible=false; S.Enabled=true; S.Closing=false; S.Progress=0.04; S.Velocity=0
            S.LookVector=nil; S.UpVector=nil; S.Minimized=false; S.MinimizeTarget=0; S.MinimizeProgress=0; S.MinimizeVelocity=0
            S.AnchorTarget=false; S.AnchorBlend=0; S.AnchorVelocity=0; S.AnchorLayout=nil
            DBVisualSettings.SpatialModeEnabled=true; Controller.Enabled=true; S.LastError=nil
            if S.RenderConnection then pcall(function() S.RenderConnection:Disconnect() end) end
            S.RenderConnection=RunService.RenderStepped:Connect(function(dt)
                dt=math.min(dt,1/30)
                local okUpdate,errUpdate=pcall(update,dt)
                if not okUpdate then
                    S.UpdateErrorCount=(S.UpdateErrorCount or 0)+1
                    S.LastError=tostring(errUpdate); warn("[大肥鱼 V139] 空间更新错误: ",errUpdate)
                    if S.UpdateErrorCount>=2 then
                        if S.RenderConnection then pcall(function() S.RenderConnection:Disconnect() end); S.RenderConnection=nil end
                        task.defer(function()
                            pcall(function() finalize() end)
                            DBVisualSettings.SpatialModeEnabled=false; Controller.Enabled=false; S.Enabled=false; S.Closing=false
                            Panel.Visible=true; FloatingButton.Visible=false; State.Minimized=false; State.Animating=false
                            pcall(function() ShowDBNotification("空间模式已回退", "检测到3D运行异常，已恢复2D界面", false) end)
                        end)
                    end
                else
                    S.UpdateErrorCount=0
                end
            end)
        else
            if not S.Enabled then return end
            S.Closing=true; S.MinimizeTarget=0; S.AnchorTarget=false; setBlur(0); setMainSurfaceEnabled(true)
            DBVisualSettings.SpatialModeEnabled=false; Controller.Enabled=false
        end
    end
    function Controller.Destroy(force)
        if S.RenderConnection then pcall(function() S.RenderConnection:Disconnect() end); S.RenderConnection=nil end
        if S.Enabled or S.WorldFolder then finalize() else removeStale() end
    end

end
    return Controller
end

local function DBCreateSpatialController_131()
    local Controller = { Enabled = false }
do
    local Lighting = game:GetService("Lighting")
    local S = {
        Enabled=false, Closing=false, Progress=0, Velocity=0,
        LookVector=nil, UpVector=nil, RenderConnection=nil, WorldFolder=nil,
        Surfaces={}, Bars={}, Original={}, ProfileOriginal={},
        PreviousPanelVisible=true, PreviousFloatingVisible=false, PreviousMinimized=false,
        AdvancedRoot=nil, AdvancedOriginal=nil,
        CenterTitle=nil, MusicTitle=nil, MusicStatus=nil, MusicPlayButton=nil,
        SpectrumAccumulator=0, LastSnapshot=nil, LastError=nil,
        Minimized=false, MinimizeTarget=0, MinimizeProgress=0, MinimizeVelocity=0,
        Blur=nil, BlurOwned=false, Mini=nil,
        JoystickTouch=false, JoystickInputs={},
        FocusMode=false, FocusProgress=0, FocusVelocity=0, RevealImpulse=0, LastFocusLook=nil,
    }
    local FOLDER_NAME = "DB_SpatialHUD_V131"
    local BAR_COUNT = 48

    local function clamp01(v) return math.clamp(tonumber(v) or 0,0,1) end
    local function smooth(v) v=clamp01(v); return v*v*(3-2*v) end
    local function easeOut(v) v=clamp01(v); return 1-(1-v)^3 end
    local function destroy(obj) if obj and obj.Parent then pcall(function() obj:Destroy() end) end end
    local function remember(obj)
        if not obj or S.Original[obj] then return end
        S.Original[obj]={Parent=obj.Parent,Position=obj.Position,Size=obj.Size,AnchorPoint=obj.AnchorPoint,Visible=obj.Visible,ClipsDescendants=obj.ClipsDescendants}
    end
    local function restore(obj)
        local sv=obj and S.Original[obj]
        if not obj or not sv then return end
        pcall(function()
            obj.Parent=sv.Parent; obj.Position=sv.Position; obj.Size=sv.Size; obj.AnchorPoint=sv.AnchorPoint
            obj.Visible=sv.Visible; obj.ClipsDescendants=sv.ClipsDescendants
        end)
        S.Original[obj]=nil
    end
    local function removeStale()
        for _,name in ipairs({"DB_SpatialHUD_V126","DB_SpatialHUD_V127","DB_SpatialHUD_V128",FOLDER_NAME}) do
            local old=workspace:FindFirstChild(name); if old then destroy(old) end
        end
        if __dbPlayerGui then
            for _,child in ipairs(__dbPlayerGui:GetChildren()) do
                if child:IsA("SurfaceGui") and (child.Name:find("DB_Spatial_V126",1,true) or child.Name:find("DB_Spatial_V127",1,true) or child.Name:find("DB_Spatial_V128",1,true) or child.Name:find("DB_Spatial_V131",1,true)) then
                    destroy(child)
                end
            end
        end
    end
    local function makePart(name,w,h)
        local part=Instance.new("Part")
        part.Name=name; part.Anchored=true; part.CanCollide=false; part.CanTouch=false; part.CanQuery=true; part.CastShadow=false
        part.Transparency=1; part.Color=Color3.fromRGB(12,15,22); part.Material=Enum.Material.SmoothPlastic
        part.Size=Vector3.new(w,h,0.03); part.Parent=S.WorldFolder
        return part
    end
    local function makeSurface(name,wStud,hStud,canvasW,canvasH,titleText)
        local part=makePart("DB_AR131_"..name.."_Panel",wStud,hStud)
        local surface=Instance.new("SurfaceGui")
        surface.ResetOnSpawn=false
        surface.Name="DB_Spatial_V131_"..name; surface.Adornee=part; surface.Face=Enum.NormalId.Front; surface.Active=true
        surface.AlwaysOnTop=(name=="Left" or name=="Right" or name=="MusicStrip")
        surface.LightInfluence=0; surface.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize
        surface.CanvasSize=Vector2.new(canvasW,canvasH); surface.ClipsDescendants=false; surface.MaxDistance=0
        surface.ZOffset=(name=="Center" and 0.055 or 0.018); surface.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; surface.Parent=__dbPlayerGui

        local root=Instance.new("Frame")
        root.Name="SpatialGlassRoot"; root.Size=UDim2.fromScale(1,1); root.BackgroundColor3=Color3.fromRGB(5,7,12)
        root.BackgroundTransparency=(name=="Center" and 0.09 or 0.17); root.BorderSizePixel=0; root.ClipsDescendants=true; root.Active=true; root.ZIndex=10; root.Parent=surface
        AddCorner(root,20)
        local borderHost=Instance.new("Frame")
        borderHost.Position=UDim2.fromOffset(3,3); borderHost.Size=UDim2.new(1,-6,1,-6); borderHost.BackgroundTransparency=1
        borderHost.BorderSizePixel=0; borderHost.ZIndex=250; borderHost.Parent=root; AddCorner(borderHost,18)
        local spatialBorderStroke=Instance.new("UIStroke")
        spatialBorderStroke.Name="DB_SpatialStaticBorder"; spatialBorderStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        spatialBorderStroke.Thickness=1.15; spatialBorderStroke.Transparency=0.58; spatialBorderStroke.Color=Color3.fromRGB(214,222,235)
        spatialBorderStroke.LineJoinMode=Enum.LineJoinMode.Round; spatialBorderStroke.Parent=borderHost
        local highlight=Instance.new("Frame")
        highlight.Position=UDim2.fromOffset(10,8); highlight.Size=UDim2.new(1,-20,0,1); highlight.BackgroundColor3=Color3.fromRGB(255,255,255)
        highlight.BackgroundTransparency=1; highlight.BorderSizePixel=0; highlight.ZIndex=27; highlight.Parent=root
        local glassStroke=Instance.new("UIStroke")
        glassStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; glassStroke.Thickness=0.85; glassStroke.Transparency=0.50
        glassStroke.Color=Color3.fromRGB(224,234,255); glassStroke.LineJoinMode=Enum.LineJoinMode.Round; glassStroke.Parent=root
        local header=Instance.new("Frame")
        header.Position=UDim2.fromOffset(8,7); header.Size=UDim2.new(1,-16,0,30); header.BackgroundColor3=Color3.fromRGB(255,255,255)
        header.BackgroundTransparency=0.90; header.BorderSizePixel=0; header.ZIndex=30; header.Active=true; header.Parent=root; AddCorner(header,11)
        local title=Instance.new("TextLabel")
        title.Position=UDim2.fromOffset(10,0); title.Size=UDim2.new(1,-20,1,0); title.BackgroundTransparency=1; title.Text=titleText
        title.TextColor3=Color3.fromRGB(248,250,255); title.TextSize=13; title.Font=Enum.Font.GothamBold
        title.TextXAlignment=Enum.TextXAlignment.Left; title.TextYAlignment=Enum.TextYAlignment.Center; title.TextTruncate=Enum.TextTruncate.AtEnd
        title.ZIndex=33; title.Parent=header
        local content=Instance.new("Frame")
        content.Position=UDim2.fromOffset(8,42); content.Size=UDim2.new(1,-16,1,-50); content.BackgroundTransparency=1
        content.BorderSizePixel=0; content.ClipsDescendants=true; content.Active=true; content.ZIndex=20; content.Parent=root
        local frost=Instance.new("Frame")
        frost.Size=UDim2.fromScale(1,1); frost.BackgroundColor3=Color3.fromRGB(218,228,246); frost.BackgroundTransparency=1
        frost.BorderSizePixel=0; frost.ZIndex=245; frost.Active=false; frost.Parent=root; AddCorner(frost,20)
        local pack={Name=name,Part=part,Surface=surface,Root=root,Header=header,Title=title,ContentHost=content,Frost=frost,WidthStud=wStud,HeightStud=hStud}
        S.Surfaces[name]=pack; return pack
    end

    local function wireButton(button,callback)
        local last=0
        local activeInput=nil
        local startPos=nil
        local startedAt=0
        local moved=false
        local moveLimit=20
        local MAX_HOLD=0.68
        local function fire()
            local now=os.clock(); if now-last<0.14 then return end
            last=now; pcall(callback)
        end
        local function resetGesture()
            activeInput=nil; startPos=nil; startedAt=0; moved=false
        end
        local function matchesEnd(input)
            if not activeInput then return false end
            if activeInput.UserInputType==Enum.UserInputType.Touch then return input==activeInput end
            return input.UserInputType==Enum.UserInputType.MouseButton1
        end
        button.InputBegan:Connect(function(input)
            if not S.Enabled or S.Closing then return end
            if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
            activeInput=input
            startPos=Vector2.new(input.Position.X,input.Position.Y)
            startedAt=os.clock(); moved=false
            local cam=workspace.CurrentCamera
            local vh=(cam and cam.ViewportSize.Y) or 720
            moveLimit=math.clamp(vh*0.028,16,24)
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not activeInput or not startPos then return end
            local pos=nil
            if activeInput.UserInputType==Enum.UserInputType.Touch then
                if input~=activeInput then return end
                pos=Vector2.new(input.Position.X,input.Position.Y)
            else
                if input.UserInputType~=Enum.UserInputType.MouseMovement then return end
                pos=Vector2.new(input.Position.X,input.Position.Y)
            end
            if pos and (pos-startPos).Magnitude>moveLimit then moved=true end
        end)
        local function finish(input)
            if not matchesEnd(input) then return end
            local held=os.clock()-startedAt
            local okTap=(not moved) and held<=MAX_HOLD and S.Enabled and not S.Closing
            resetGesture()
            if okTap then fire() end
        end
        button.InputEnded:Connect(finish)
        UserInputService.InputEnded:Connect(finish)
        return button
    end

    local function makeMusicStrip()
        local p=makeSurface("MusicStrip",4.72,0.68,520,72,"")
        p.Surface.AlwaysOnTop=true; p.Header.Visible=false; p.ContentHost.Position=UDim2.fromOffset(6,6); p.ContentHost.Size=UDim2.new(1,-12,1,-12)
        local function btn(txt,x,w)
            local b=Instance.new("TextButton")
            b.Position=UDim2.fromOffset(x,5); b.Size=UDim2.fromOffset(w,49); b.BackgroundColor3=Color3.fromRGB(255,255,255)
            b.BackgroundTransparency=0.85; b.BorderSizePixel=0; b.AutoButtonColor=false; b.Text=txt
            b.TextColor3=Color3.fromRGB(248,248,252); b.TextSize=txt=="▶" and 18 or 25; b.Font=Enum.Font.GothamBold; b.ZIndex=45
            b.Active=true; b.Parent=p.ContentHost; AddCorner(b,12); return b
        end
        local prev=btn("‹",2,48); local play=btn("▶",54,54); local nextB=btn("›",112,48); S.MusicPlayButton=play
        local title=Instance.new("TextLabel")
        title.Position=UDim2.fromOffset(172,4); title.Size=UDim2.new(1,-180,0,27); title.BackgroundTransparency=1; title.Text="大肥鱼 环绕音效"
        title.TextColor3=Color3.fromRGB(250,250,253); title.TextSize=13; title.Font=Enum.Font.GothamBold; title.TextXAlignment=Enum.TextXAlignment.Left
        title.TextTruncate=Enum.TextTruncate.AtEnd; title.ZIndex=40; title.Parent=p.ContentHost; S.MusicTitle=title
        local status=Instance.new("TextLabel")
        status.Position=UDim2.fromOffset(172,31); status.Size=UDim2.new(1,-180,0,21); status.BackgroundTransparency=1; status.Text="点 ▶ 播放 / 暂停 · 轻触右侧打开播放器"
        status.TextColor3=Color3.fromRGB(182,195,211); status.TextSize=10; status.Font=Enum.Font.GothamMedium; status.TextXAlignment=Enum.TextXAlignment.Left
        status.TextTruncate=Enum.TextTruncate.AtEnd; status.ZIndex=40; status.Parent=p.ContentHost; S.MusicStatus=status
        local open=Instance.new("TextButton")
        open.Position=UDim2.fromOffset(166,0); open.Size=UDim2.new(1,-166,1,0); open.BackgroundTransparency=1; open.BorderSizePixel=0
        open.Text=""; open.AutoButtonColor=false; open.Active=true; open.ZIndex=46; open.Parent=p.ContentHost
        wireButton(prev,function() if DBMusic and type(DBMusic.PreviousSpatialTrack)=="function" then DBMusic.PreviousSpatialTrack() end end)
        wireButton(play,function() if DBMusic and type(DBMusic.ToggleSpatialPlayback)=="function" then DBMusic.ToggleSpatialPlayback() end end)
        wireButton(nextB,function() if DBMusic and type(DBMusic.NextSpatialTrack)=="function" then DBMusic.NextSpatialTrack() end end)
        wireButton(open,function() if DBMusic and type(DBMusic.ShowAdvanced)=="function" then DBMusic.ShowAdvanced() end end)
        return p
    end

    local function makeMiniButton()
        local part=makePart("DB_AR131_MiniButton",2.04,0.52)
        local surface=Instance.new("SurfaceGui")
        surface.ResetOnSpawn=false
        surface.Name="DB_Spatial_V131_Mini"; surface.Adornee=part; surface.Face=Enum.NormalId.Front; surface.Active=true; surface.AlwaysOnTop=true
        surface.LightInfluence=0; surface.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize; surface.CanvasSize=Vector2.new(230,58); surface.ZOffset=0.04
        surface.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; surface.Enabled=false; surface.Parent=__dbPlayerGui
        local root=Instance.new("Frame")
        root.Size=UDim2.fromScale(1,1); root.BackgroundColor3=Color3.fromRGB(5,8,14); root.BackgroundTransparency=0.09; root.BorderSizePixel=0
        root.ClipsDescendants=true; root.Active=true; root.ZIndex=10; root.Parent=surface; AddCorner(root,999)
        local border=Instance.new("Frame")
        border.Position=UDim2.fromOffset(3,3); border.Size=UDim2.new(1,-6,1,-6); border.BackgroundTransparency=1; border.BorderSizePixel=0; border.ZIndex=30
        border.Parent=root; AddCorner(border,999)
        local miniStroke=Instance.new("UIStroke"); miniStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; miniStroke.Thickness=1.05
        miniStroke.Transparency=0.56; miniStroke.Color=Color3.fromRGB(214,222,235); miniStroke.LineJoinMode=Enum.LineJoinMode.Round; miniStroke.Parent=border
        local button=Instance.new("TextButton")
        button.Size=UDim2.fromScale(1,1); button.BackgroundTransparency=1; button.BorderSizePixel=0; button.Text="大肥鱼脚本  ·  展开空间面板"
        button.TextColor3=Color3.fromRGB(250,250,253); button.TextSize=13; button.Font=Enum.Font.GothamBlack; button.AutoButtonColor=false
        button.Active=true; button.ZIndex=35; button.Parent=root; wireButton(button,function() Controller.SetMinimized(false) end)
        local pack={Name="Mini",Part=part,Surface=surface,Root=root,Button=button,WidthStud=2.04,HeightStud=0.52}
        S.Surfaces.Mini=pack; S.Mini=pack; return pack
    end

    local function makeBars()
        S.Bars={}
        for i=1,BAR_COUNT do
            local b=Instance.new("Part")
            b.Name=string.format("DB_AR131_Wave_%02d",i); b.Anchored=true; b.CanCollide=false; b.CanTouch=false; b.CanQuery=false; b.CastShadow=false
            b.Material=Enum.Material.Neon; b.Size=Vector3.new(0.14,0.055,0.18); b.Transparency=0.10; b.Color=Color3.fromRGB(70,225,94); b.Parent=S.WorldFolder
            S.Bars[i]=b
        end
    end
    local function colorFor(level)
        level=clamp01(level)
        if level<0.24 then return Color3.fromRGB(78,218,86):Lerp(Color3.fromRGB(55,232,108),level/0.24) end
        if level<0.52 then return Color3.fromRGB(55,232,108):Lerp(Color3.fromRGB(26,225,162),(level-0.24)/0.28) end
        if level<0.78 then return Color3.fromRGB(26,225,162):Lerp(Color3.fromRGB(20,202,211),(level-0.52)/0.26) end
        return Color3.fromRGB(20,202,211):Lerp(Color3.fromRGB(41,78,238),(level-0.78)/0.22)
    end
    local function sampleLevel(levels,index,count)
        if type(levels)~="table" or #levels==0 then return 0 end
        local pos=1+((index-1)/math.max(1,count-1))*math.max(0,#levels-1); local a=math.floor(pos); local bb=math.min(#levels,a+1); local t=pos-a
        return clamp01((tonumber(levels[a]) or 0)+((tonumber(levels[bb]) or 0)-(tonumber(levels[a]) or 0))*t)
    end
    local function snapshot()
        local snap=nil
        if DBMusic and type(DBMusic.GetSpatialSnapshot)=="function" then local ok,r=pcall(DBMusic.GetSpatialSnapshot); if ok and type(r)=="table" then snap=r end end
        snap=snap or {Title="",Artist="",Platform="",Status="",Playing=false,Levels={},Rms=0}; S.LastSnapshot=snap
        if S.MusicTitle and S.MusicTitle.Parent then S.MusicTitle.Text=snap.Title~="" and (snap.Title..(snap.Artist~="" and (" · "..snap.Artist) or "")) or "大肥鱼 环绕音效" end
        if S.MusicStatus and S.MusicStatus.Parent then S.MusicStatus.Text=(snap.Platform~="" and (snap.Platform.." · ") or "")..(snap.Status~="" and snap.Status or "点 ▶ 播放 / 暂停") end
        if S.MusicPlayButton and S.MusicPlayButton.Parent then S.MusicPlayButton.Text=snap.Playing and "Ⅱ" or "▶" end
        return snap
    end

    local function updateBars(basis,openP,collapse,dt)
        S.SpectrumAccumulator=S.SpectrumAccumulator+dt; if S.SpectrumAccumulator<1/30 then return end
        S.SpectrumAccumulator=S.SpectrumAccumulator%(1/30)
        local snap=snapshot(); local levels=snap.Levels or {}; local maxLevel=0
        for i=1,#levels do local v=tonumber(levels[i]) or 0; if v>maxLevel then maxLevel=v end end
        local status=tostring(snap.Status or "")
        local active=(snap.Playing==true) or (tonumber(snap.Rms) or 0)>0.002 or maxLevel>0.006 or (status:find("播放",1,true)~=nil and status:find("暂停",1,true)==nil)
        local origin=basis.Position; local right=basis.RightVector; local up=basis.UpVector; local look=basis.LookVector
        local radius=5.40; local maxAngle=math.rad(72); local collapseFade=1-smooth(math.clamp((collapse-0.62)/0.38,0,1))
        local clock=os.clock(); local center=(BAR_COUNT+1)*0.5
        for i,b in ipairs(S.Bars) do
            if b and b.Parent then
                local t=(i-1)/math.max(1,BAR_COUNT-1); local theta=-maxAngle+(maxAngle*2)*t
                local level=sampleLevel(levels,i,BAR_COUNT)
                if active and maxLevel<0.003 then
                    local d=math.floor(math.abs(i-center)); local phase=clock-d*0.055
                    level=math.clamp(0.12+0.30*((math.sin(phase*5.0)+1)*0.5)+0.18*((math.sin(phase*9.2+0.8)+1)*0.5)+0.25*(math.max(0,math.sin(phase*6.2))^5),0.08,0.90)
                elseif not active then level=0 end
                local orbit=active and math.rad(math.sin(clock*1.55)*3.6) or 0
                local ripple=active and math.rad(math.sin(clock*5.2+(i-center)*0.44)*(0.45+level*2.35)) or 0
                local animatedTheta=theta+orbit+ripple
                local height=0.055+(level^0.84)*2.42
                local dir=look*math.cos(animatedTheta)+right*math.sin(animatedTheta)
                local radialPulse=active and (math.sin(clock*4.6+i*0.31)*0.035*level) or 0
                local base=origin+dir*(radius+radialPulse)-up*2.10
                local pos=base+up*(height*0.5)
                b.Size=Vector3.new(0.14+level*0.035,height,0.18+level*0.055)
                local roll=active and math.rad(math.sin(clock*7.4+i*0.63)*(1.8+level*7.2)) or 0
                local yaw=active and math.rad(math.sin(clock*4.1-i*0.37)*(0.8+level*3.8)) or 0
                b.CFrame=CFrame.lookAt(pos,origin+look*0.55-up*1.05,up)*CFrame.Angles(0,yaw,roll)
                b.Color=colorFor(level)
                b.Transparency=math.clamp((active and 0.06 or 0.70)+(1-openP)*0.14+(1-collapseFade)*0.90,0.04,0.97)
            end
        end
    end

    local function saveProfile(obj,props)
        if not obj or S.ProfileOriginal[obj] then return end
        local sv={}
        for _,prop in ipairs(props) do local ok,val=pcall(function() return obj[prop] end); if ok then sv[prop]=val end end
        S.ProfileOriginal[obj]=sv
    end
    local function restoreProfileLayout()
        for obj,sv in pairs(S.ProfileOriginal) do
            if obj and obj.Parent then for prop,val in pairs(sv) do pcall(function() obj[prop]=val end) end end
        end
        S.ProfileOriginal={}
    end
    local function applyProfileLayout()
        if not PlayerInfoCard or not PlayerInfoCard.Parent then return end
        saveProfile(PlayerInfoCard,{"Size","Position"})
        saveProfile(PlayerAvatar,{"Position","Size","ScaleType","Visible"})
        saveProfile(PlayerNameLabel,{"Position","Size","TextSize"})
        saveProfile(PlayerAgeLabel,{"Position","Size","TextSize"})
        saveProfile(PlayerUsernameLabel,{"Position","Size","TextSize"})
        if PlayerInfoTitle then saveProfile(PlayerInfoTitle,{"Position","Size","TextSize"}) end
        PlayerInfoCard.Size=UDim2.new(1,-10,0,188); PlayerInfoCard.Position=UDim2.fromOffset(5,4)
        if PlayerInfoTitle then PlayerInfoTitle.Position=UDim2.fromOffset(9,6); PlayerInfoTitle.Size=UDim2.new(1,-18,0,18); PlayerInfoTitle.TextSize=11 end
        PlayerAvatar.Visible=true; PlayerAvatar.Position=UDim2.fromOffset(10,30); PlayerAvatar.Size=UDim2.fromOffset(66,66); PlayerAvatar.ScaleType=Enum.ScaleType.Fit
        PlayerNameLabel.Position=UDim2.fromOffset(10,102); PlayerNameLabel.Size=UDim2.new(1,-20,0,26); PlayerNameLabel.TextSize=10
        PlayerAgeLabel.Position=UDim2.fromOffset(10,129); PlayerAgeLabel.Size=UDim2.new(1,-20,0,24); PlayerAgeLabel.TextSize=9
        PlayerUsernameLabel.Position=UDim2.fromOffset(10,154); PlayerUsernameLabel.Size=UDim2.new(1,-20,0,27); PlayerUsernameLabel.TextSize=9
        local viewport=PlayerInfoCard:FindFirstChild("Player3DViewport")
        if viewport then saveProfile(viewport,{"Position","Size","Visible"}); viewport.Visible=false end
        local sw=PlayerInfoCard:FindFirstChild("Player3DSwitch")
        if sw then saveProfile(sw,{"Position","Size","Visible"}); sw.Visible=false end
        local mixer=PlayerProfileScroll and PlayerProfileScroll:FindFirstChild("DB_Music_VolumeMixer")
        if mixer then saveProfile(mixer,{"Position","Size"}); mixer.Position=UDim2.fromOffset(5,196); mixer.Size=UDim2.new(1,-10,0,188) end
        if PlayerProfileScroll then saveProfile(PlayerProfileScroll,{"CanvasSize"}); PlayerProfileScroll.CanvasSize=UDim2.fromOffset(0,394) end
    end

    local function attach(obj,pack)
        if not obj or not pack then return end
        remember(obj); obj.Parent=pack.ContentHost; obj.AnchorPoint=Vector2.new(0,0); obj.Position=UDim2.fromScale(0,0); obj.Size=UDim2.fromScale(1,1)
        obj.Visible=true; obj.ClipsDescendants=true
        for _,d in ipairs(obj:GetDescendants()) do
            if d:IsA("GuiButton") then d.Active=true end
            if d:IsA("ScrollingFrame") then d.Active=true; d.ScrollingEnabled=true end
        end
    end
    local function restoreRails() restore(PlayerProfileRail); restore(RightList); restore(LeftMenu); restoreProfileLayout() end
    local function getBlur()
        local blur=Lighting:FindFirstChild("DB_SpatialTransitionBlur_V131")
        if not blur then blur=Instance.new("BlurEffect"); blur.Name="DB_SpatialTransitionBlur_V131"; blur.Size=0; blur.Parent=Lighting; S.BlurOwned=true end
        S.Blur=blur; return blur
    end
    local function setBlur(amount) local blur=S.Blur or getBlur(); if blur then pcall(function() blur.Size=math.clamp(amount or 0,0,14) end) end end

    local function build()
        removeStale(); local folder=Instance.new("Folder"); folder.Name=FOLDER_NAME; folder.Parent=workspace; S.WorldFolder=folder
        local left=makeSurface("Left",3.62,4.02,360,402,"玩家")
        local center=makeSurface("Center",5.42,4.28,540,428,"主页")
        local right=makeSurface("Right",3.72,4.06,380,406,"功能")
        local music=makeMusicStrip(); makeMiniButton(); S.CenterTitle=center.Title
        local focusTap=Instance.new("TextButton")
        focusTap.AnchorPoint=Vector2.new(1,0.5); focusTap.Position=UDim2.new(1,-5,0.5,0); focusTap.Size=UDim2.fromOffset(82,22)
        focusTap.BackgroundColor3=Color3.fromRGB(255,255,255); focusTap.BackgroundTransparency=0.87; focusTap.BorderSizePixel=0
        focusTap.Text="点击聚焦"; focusTap.TextColor3=Color3.fromRGB(250,250,253); focusTap.TextSize=10; focusTap.Font=Enum.Font.GothamBold
        focusTap.AutoButtonColor=false; focusTap.Active=true; focusTap.ZIndex=66; focusTap.Parent=center.Header; AddCorner(focusTap,999)
        center.Title.Size=UDim2.new(1,-102,1,0)
        wireButton(focusTap,function() S.FocusMode=not S.FocusMode; if S.FocusMode then S.RevealImpulse=0 end end)

        local back=Instance.new("TextButton")
        back.AnchorPoint=Vector2.new(1,0.5); back.Position=UDim2.new(1,-5,0.5,0); back.Size=UDim2.fromOffset(61,22)
        back.BackgroundColor3=Color3.fromRGB(255,255,255); back.BackgroundTransparency=0.84; back.BorderSizePixel=0; back.Text="返回2D"
        back.TextColor3=Color3.fromRGB(248,248,252); back.TextSize=10; back.Font=Enum.Font.GothamBold; back.AutoButtonColor=false; back.Active=true
        back.ZIndex=62; back.Parent=right.Header; AddCorner(back,999); wireButton(back,function() Controller.SetEnabled(false) end)
        local minBtn=Instance.new("TextButton")
        minBtn.AnchorPoint=Vector2.new(1,0.5); minBtn.Position=UDim2.new(1,-72,0.5,0); minBtn.Size=UDim2.fromOffset(27,22)
        minBtn.BackgroundColor3=Color3.fromRGB(255,255,255); minBtn.BackgroundTransparency=0.84; minBtn.BorderSizePixel=0; minBtn.Text="−"
        minBtn.TextColor3=Color3.fromRGB(248,248,252); minBtn.TextSize=18; minBtn.Font=Enum.Font.GothamBold; minBtn.AutoButtonColor=false; minBtn.Active=true
        minBtn.ZIndex=64; minBtn.Parent=right.Header; AddCorner(minBtn,999); wireButton(minBtn,function() Controller.SetMinimized(true) end)
        right.Title.Size=UDim2.new(1,-112,1,0)

        applyProfileLayout(); attach(PlayerProfileRail,left); attach(RightList,center); attach(LeftMenu,right); makeBars(); getBlur(); setBlur(0)
        return left,center,right,music
    end
    local function destroyWorld()
        for _,p in pairs(S.Surfaces) do if p.Surface then destroy(p.Surface) end end
        S.Surfaces={}; S.Mini=nil; destroy(S.WorldFolder); S.WorldFolder=nil; S.Bars={}; S.MusicTitle=nil; S.MusicStatus=nil; S.MusicPlayButton=nil; S.CenterTitle=nil
        setBlur(0); if S.BlurOwned and S.Blur then destroy(S.Blur) end; S.Blur=nil; S.BlurOwned=false
    end
    local function finalize()
        if DBSpatial and type(Controller.DetachAdvancedMusic)=="function" then pcall(Controller.DetachAdvancedMusic) end
        restoreRails(); destroyWorld(); S.Enabled=false; S.Closing=false; S.Progress=0; S.Velocity=0; S.LookVector=nil; S.UpVector=nil
        S.Minimized=false; S.MinimizeTarget=0; S.MinimizeProgress=0; S.MinimizeVelocity=0
        DBVisualSettings.SpatialModeEnabled=false; Controller.Enabled=false
        State.Minimized=S.PreviousMinimized==true; Panel.Visible=S.PreviousPanelVisible==true; FloatingButton.Visible=S.PreviousFloatingVisible==true
        if State.Minimized then Panel.Visible=false; FloatingButton.Visible=true elseif not Panel.Visible then Panel.Visible=true end
        DBStartupScale.Scale=1; State.Animating=false
        if S.RenderConnection then pcall(function() S.RenderConnection:Disconnect() end); S.RenderConnection=nil end
    end

    local function cameraBasis(cam,dt)
        local currentLook=cam.CFrame.LookVector; local currentUp=cam.CFrame.UpVector
        if not S.LookVector then S.LookVector=currentLook; S.UpVector=currentUp end
        if S.LookVector:Dot(currentLook)<0.48 then S.LookVector=currentLook; S.UpVector=currentUp
        else
            local a=1-math.exp(-dt*12.5); S.LookVector=(S.LookVector:Lerp(currentLook,a)).Unit; S.UpVector=(S.UpVector:Lerp(currentUp,a)).Unit
        end
        return CFrame.lookAt(cam.CFrame.Position,cam.CFrame.Position+S.LookVector,S.UpVector)
    end
    local function setMainSurfaceEnabled(enabled)
        for name,p in pairs(S.Surfaces) do if name~="Mini" and p.Surface then p.Surface.Enabled=enabled end end
    end

    UserInputService.InputBegan:Connect(function(input)
        if not S.Enabled or input.UserInputType~=Enum.UserInputType.Touch then return end
        local cam=workspace.CurrentCamera; local vp=cam and cam.ViewportSize; if not vp then return end
        if input.Position.X <= vp.X*0.36 and input.Position.Y >= vp.Y*0.53 then S.JoystickInputs[input]=true; S.JoystickTouch=true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if S.JoystickInputs[input] then S.JoystickInputs[input]=nil; S.JoystickTouch=next(S.JoystickInputs)~=nil end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if S.Enabled and S.FocusMode and (input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement) and not S.JoystickTouch then
            S.RevealImpulse=1
        end
    end)

    local function update(dt)
        if not S.Enabled then return end
        local cam=workspace.CurrentCamera; if not cam then return end
        local target=S.Closing and 0 or 1; local accel=(target-S.Progress)*(S.Closing and 74 or 86)-S.Velocity*19
        S.Velocity=S.Velocity+accel*dt; S.Progress=math.clamp(S.Progress+S.Velocity*dt,-0.02,1.03)
        local p=clamp01(S.Progress); local openP=easeOut(p)
        local mTarget=clamp01(S.MinimizeTarget); local mAccel=(mTarget-S.MinimizeProgress)*90-S.MinimizeVelocity*19
        S.MinimizeVelocity=S.MinimizeVelocity+mAccel*dt; S.MinimizeProgress=math.clamp(S.MinimizeProgress+S.MinimizeVelocity*dt,-0.025,1.025)
        if math.abs(mTarget-S.MinimizeProgress)<0.002 and math.abs(S.MinimizeVelocity)<0.028 then S.MinimizeProgress=mTarget; S.MinimizeVelocity=0 end
        local collapse=clamp01(S.MinimizeProgress)
        local fTarget=S.FocusMode and 1 or 0
        local fAccel=(fTarget-S.FocusProgress)*105-S.FocusVelocity*20
        S.FocusVelocity=S.FocusVelocity+fAccel*dt; S.FocusProgress=math.clamp(S.FocusProgress+S.FocusVelocity*dt,-0.03,1.03)
        local f=clamp01(S.FocusProgress)

        local basis=cameraBasis(cam,dt); local origin=basis.Position; local right=basis.RightVector; local up=basis.UpVector; local look=basis.LookVector
        local hover=math.sin(os.clock()*1.05)*0.014*(1-collapse); origin=origin+up*(0.30+hover)
        local center=S.Surfaces.Center; local left=S.Surfaces.Left; local rightP=S.Surfaces.Right; local music=S.Surfaces.MusicStrip; local mini=S.Mini

        local viewMotion=0
        if S.LastFocusLook then viewMotion=1-math.clamp(S.LastFocusLook:Dot(basis.LookVector),-1,1) end
        S.LastFocusLook=basis.LookVector
        if S.FocusMode and viewMotion>0.00045 then S.RevealImpulse=1 end
        S.RevealImpulse=math.max(0,(S.RevealImpulse or 0)*math.exp(-dt*2.35)-dt*0.03)
        local reveal=clamp01(S.RevealImpulse)
        local squeeze=f*(1-reveal*0.90)
        local focus=origin+look*0.72+up*0.20
        local centerFar=origin+look*5.22+up*0.02
        local centerNear=origin+look*3.72+up*0.05
        local centerBase=centerFar:Lerp(centerNear,f)
        local sideOffset=3.18+(1.18-3.18)*squeeze
        local sideDepth=4.72+(4.18-4.72)*squeeze
        local leftBase=origin+look*sideDepth-right*(sideOffset*openP)+up*0.02
        local rightBase=origin+look*sideDepth+right*(sideOffset*openP)+up*0.02
        local musicFar=origin+look*4.50+up*(2.66-(1-openP)*0.24)
        local musicNear=centerBase+up*1.66+look*0.10
        local musicBase=musicFar:Lerp(musicNear,squeeze)
        local a=smooth(math.clamp(collapse/0.50,0,1))
        local c=smooth(math.clamp((collapse-0.70)/0.30,0,1))
        local merge=centerBase+look*0.045
        local leftPos=leftBase:Lerp(merge-right*0.045+look*0.075,a)
        local rightPos=rightBase:Lerp(merge+right*0.045+look*0.105,a)
        local centerPos=centerBase
        local musicTarget=merge+up*1.43-look*0.02
        local musicPos=musicBase:Lerp(musicTarget,a)
        local finalY=math.max(0.045,1-0.955*c); local finalX=1-0.18*c
        local sideScale=(1-0.43*squeeze)*(1-0.06*a)*finalX
        local centerScale=(1+0.16*f)*finalX
        if center and center.Part then
            center.Part.CFrame=CFrame.lookAt(centerPos,focus,up); center.Part.Size=Vector3.new(center.WidthStud*centerScale,center.HeightStud*finalY*(1+0.08*f),0.03)
            center.Surface.AlwaysOnTop=(f>0.38)
            if S.CenterTitle then S.CenterTitle.Text=tostring(State.CurrentCategory or "主页") end
        end
        if left and left.Part then
            left.Part.CFrame=CFrame.lookAt(leftPos,focus,up); left.Part.Size=Vector3.new(left.WidthStud*sideScale,left.HeightStud*finalY,0.03)
            left.Surface.AlwaysOnTop=(f<=0.38); if left.Frost then left.Frost.BackgroundTransparency=1-0.24*squeeze end
        end
        if rightP and rightP.Part then
            rightP.Part.CFrame=CFrame.lookAt(rightPos,focus,up); rightP.Part.Size=Vector3.new(rightP.WidthStud*sideScale,rightP.HeightStud*finalY,0.03)
            rightP.Surface.AlwaysOnTop=(f<=0.38); if rightP.Frost then rightP.Frost.BackgroundTransparency=1-0.24*squeeze end
        end
        if music and music.Part then
            music.Part.CFrame=CFrame.lookAt(musicPos,focus,up)
            local widthScale=(1-0.32*squeeze)*(1-0.20*a)*(1-0.10*c); local heightScale=math.max(0.08,(1-0.20*squeeze)*(1-0.90*c))
            music.Part.Size=Vector3.new(music.WidthStud*widthScale,music.HeightStud*heightScale,0.03)
            if music.Frost then music.Frost.BackgroundTransparency=1-0.20*squeeze end
        end

        local frostLevel=math.clamp((collapse-0.62)/0.31,0,1)
        for name,pack in pairs(S.Surfaces) do if name~="Mini" and pack.Frost then pack.Frost.BackgroundTransparency=1-frostLevel*0.27 end end
        local blurPhase=0
        if collapse>0.62 and collapse<0.995 then blurPhase=math.sin(math.clamp((collapse-0.62)/0.375,0,1)*math.pi) end
        setBlur(10.5*blurPhase)
        setMainSurfaceEnabled(collapse<0.988 and p>0.02)

        if mini and mini.Part and mini.Surface then
            local miniP=smooth(math.clamp((collapse-0.855)/0.145,0,1))
            local miniPos=origin+look*4.36+up*2.40
            mini.Part.CFrame=CFrame.lookAt(miniPos,origin+look*0.50+up*0.35,up)
            mini.Part.Size=Vector3.new(mini.WidthStud*math.max(0.055,miniP),mini.HeightStud*math.max(0.07,miniP),0.03)
            mini.Surface.Enabled=miniP>0.035 and p>0.02
        end

        updateBars(basis,openP,collapse,dt)
        if left and left.Surface then
            local moving=false; local char=LocalPlayer.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
            if hum then moving=hum.MoveDirection.Magnitude>0.025 end
            left.Surface.Active=(not moving) and (not S.JoystickTouch) and collapse<0.96
            left.Part.CanQuery=(not moving) and (not S.JoystickTouch) and collapse<0.96
        end
        if S.Closing and p<0.012 and math.abs(S.Velocity)<0.14 then task.defer(finalize) end
    end

    function Controller.IsEnabled() return S.Enabled and not S.Closing end
    function Controller.IsActive() return S.Enabled==true end
    function Controller.IsMinimized() return S.Enabled and S.MinimizeTarget>0.5 end
    function Controller.GetLastError() return S.LastError end
    function Controller.SetMinimized(minimized)
        if not S.Enabled or S.Closing then return end
        S.Minimized=minimized==true; S.MinimizeTarget=S.Minimized and 1 or 0; State.Minimized=S.Minimized; State.Animating=true
        if not S.Minimized then setMainSurfaceEnabled(true) end
        task.delay(0.75,function() if S.Enabled and not S.Closing and math.abs(S.MinimizeProgress-S.MinimizeTarget)<0.02 then State.Animating=false end end)
    end
    function Controller.ToggleMinimized() Controller.SetMinimized(not Controller.IsMinimized()) end
    function Controller.AttachAdvancedMusic(root)
        if not S.Enabled or S.Closing or S.MinimizeTarget>0.5 or not root then return false end
        local center=S.Surfaces.Center; if not center or not center.ContentHost then return false end
        if S.AdvancedRoot==root and root.Parent==center.ContentHost then return true end
        Controller.DetachAdvancedMusic(); S.AdvancedRoot=root
        S.AdvancedOriginal={Parent=root.Parent,Position=root.Position,Size=root.Size,AnchorPoint=root.AnchorPoint,Visible=root.Visible}
        if RightList and RightList.Parent then RightList.Visible=false end
        root.Parent=center.ContentHost; root.AnchorPoint=Vector2.new(0,0); root.Position=UDim2.fromScale(0,0); root.Size=UDim2.fromScale(1,1); root.Visible=true
        return true
    end
    function Controller.DetachAdvancedMusic()
        local root,sv=S.AdvancedRoot,S.AdvancedOriginal
        if root and sv then pcall(function() root.Parent=sv.Parent or Panel; root.Position=sv.Position; root.Size=sv.Size; root.AnchorPoint=sv.AnchorPoint; root.Visible=sv.Visible==true end) end
        S.AdvancedRoot=nil; S.AdvancedOriginal=nil; if RightList and RightList.Parent then RightList.Visible=true end
    end
    function Controller.SetEnabled(enabled)
        enabled=enabled==true
        if enabled then
            if S.Enabled then S.Closing=false; DBVisualSettings.SpatialModeEnabled=true; Controller.Enabled=true; if S.MinimizeTarget>0.5 then Controller.SetMinimized(false) end; return end
            S.PreviousPanelVisible=Panel.Visible; S.PreviousFloatingVisible=FloatingButton.Visible; S.PreviousMinimized=State.Minimized
            AppleTransition.Running=false; AppleTransition.Velocity=0; AppleTransition.ClearSoftFocus(); State.Animating=true; DBStartupScale.Scale=1
            local ok,err=pcall(build)
            if not ok then
                S.LastError=tostring(err); warn("[大肥鱼 V131] 空间模式构建失败: ",err); restoreRails(); destroyWorld(); State.Animating=false
                DBVisualSettings.SpatialModeEnabled=false; Controller.Enabled=false; return
            end
            Panel.Visible=false; FloatingButton.Visible=false; S.Enabled=true; S.Closing=false; S.Progress=0.04; S.Velocity=0
            S.LookVector=nil; S.UpVector=nil; S.Minimized=false; S.MinimizeTarget=0; S.MinimizeProgress=0; S.MinimizeVelocity=0
            DBVisualSettings.SpatialModeEnabled=true; Controller.Enabled=true; S.LastError=nil
            if S.RenderConnection then pcall(function() S.RenderConnection:Disconnect() end) end
            S.RenderConnection=RunService.RenderStepped:Connect(function(dt)
                dt=math.min(dt,1/30)
                local okUpdate,errUpdate=pcall(update,dt)
                if not okUpdate then
                    S.LastError=tostring(errUpdate); warn("[大肥鱼 V131] 空间更新错误: ",errUpdate)
                    for _,pack in pairs(S.Surfaces) do if pack.Part then pack.Part.Transparency=1 end end
                end
            end)
        else
            if not S.Enabled then return end
            S.Closing=true; S.MinimizeTarget=0; setBlur(0); setMainSurfaceEnabled(true)
            DBVisualSettings.SpatialModeEnabled=false; Controller.Enabled=false
        end
    end
    function Controller.Destroy(force)
        if S.RenderConnection then pcall(function() S.RenderConnection:Disconnect() end); S.RenderConnection=nil end
        if S.Enabled or S.WorldFolder then finalize() else removeStale() end
    end

end
    return Controller
end

local function DBCreateSpatialController_132()
    local Controller = { Enabled = false }
do
    local Lighting = game:GetService("Lighting")
    local S = {
        Enabled=false, Closing=false, Progress=0, Velocity=0,
        LookVector=nil, UpVector=nil, RenderConnection=nil, WorldFolder=nil,
        Surfaces={}, Bars={}, Original={}, ProfileOriginal={},
        PreviousPanelVisible=true, PreviousFloatingVisible=false, PreviousMinimized=false,
        AdvancedRoot=nil, AdvancedOriginal=nil,
        CenterTitle=nil, MusicTitle=nil, MusicStatus=nil, MusicPlayButton=nil,
        SpectrumAccumulator=0, LastSnapshot=nil, LastError=nil,
        Minimized=false, MinimizeTarget=0, MinimizeProgress=0, MinimizeVelocity=0,
        Blur=nil, BlurOwned=false, Mini=nil,
        JoystickTouch=false, JoystickInputs={},
    }
    local FOLDER_NAME = "DB_SpatialHUD_V132"
    local BAR_COUNT = 48

    local function clamp01(v) return math.clamp(tonumber(v) or 0,0,1) end
    local function smooth(v) v=clamp01(v); return v*v*(3-2*v) end
    local function easeOut(v) v=clamp01(v); return 1-(1-v)^3 end
    local function destroy(obj) if obj and obj.Parent then pcall(function() obj:Destroy() end) end end
    local function remember(obj)
        if not obj or S.Original[obj] then return end
        S.Original[obj]={Parent=obj.Parent,Position=obj.Position,Size=obj.Size,AnchorPoint=obj.AnchorPoint,Visible=obj.Visible,ClipsDescendants=obj.ClipsDescendants}
    end
    local function restore(obj)
        local sv=obj and S.Original[obj]
        if not obj or not sv then return end
        pcall(function()
            obj.Parent=sv.Parent; obj.Position=sv.Position; obj.Size=sv.Size; obj.AnchorPoint=sv.AnchorPoint
            obj.Visible=sv.Visible; obj.ClipsDescendants=sv.ClipsDescendants
        end)
        S.Original[obj]=nil
    end
    local function removeStale()
        for _,name in ipairs({"DB_SpatialHUD_V126","DB_SpatialHUD_V127","DB_SpatialHUD_V128",FOLDER_NAME}) do
            local old=workspace:FindFirstChild(name); if old then destroy(old) end
        end
        if __dbPlayerGui then
            for _,child in ipairs(__dbPlayerGui:GetChildren()) do
                if child:IsA("SurfaceGui") and (child.Name:find("DB_Spatial_V126",1,true) or child.Name:find("DB_Spatial_V127",1,true) or child.Name:find("DB_Spatial_V128",1,true) or child.Name:find("DB_Spatial_V132",1,true)) then
                    destroy(child)
                end
            end
        end
    end
    local function makePart(name,w,h)
        local part=Instance.new("Part")
        part.Name=name; part.Anchored=true; part.CanCollide=false; part.CanTouch=false; part.CanQuery=true; part.CastShadow=false
        part.Transparency=1; part.Color=Color3.fromRGB(12,15,22); part.Material=Enum.Material.SmoothPlastic
        part.Size=Vector3.new(w,h,0.03); part.Parent=S.WorldFolder
        return part
    end
    local function makeSurface(name,wStud,hStud,canvasW,canvasH,titleText)
        local part=makePart("DB_AR132_"..name.."_Panel",wStud,hStud)
        local surface=Instance.new("SurfaceGui")
        surface.ResetOnSpawn=false
        surface.Name="DB_Spatial_V132_"..name; surface.Adornee=part; surface.Face=Enum.NormalId.Front; surface.Active=true
        surface.AlwaysOnTop=(name=="MusicStrip")
        surface.LightInfluence=0; surface.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize
        surface.CanvasSize=Vector2.new(canvasW,canvasH); surface.ClipsDescendants=false; surface.MaxDistance=0
        surface.ZOffset=(name=="Center" and 0.055 or 0.018); surface.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; surface.Parent=__dbPlayerGui

        local root=Instance.new("Frame")
        root.Name="SpatialGlassRoot"; root.Size=UDim2.fromScale(1,1); root.BackgroundColor3=Color3.fromRGB(5,7,12)
        root.BackgroundTransparency=(name=="Center" and 0.09 or 0.17); root.BorderSizePixel=0; root.ClipsDescendants=true; root.Active=true; root.ZIndex=10; root.Parent=surface
        AddCorner(root,20)
        local borderHost=Instance.new("Frame")
        borderHost.Position=UDim2.fromOffset(3,3); borderHost.Size=UDim2.new(1,-6,1,-6); borderHost.BackgroundTransparency=1
        borderHost.BorderSizePixel=0; borderHost.ZIndex=250; borderHost.Parent=root; AddCorner(borderHost,18)
        local spatialBorderStroke=Instance.new("UIStroke")
        spatialBorderStroke.Name="DB_SpatialStaticBorder"; spatialBorderStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        spatialBorderStroke.Thickness=1.15; spatialBorderStroke.Transparency=0.58; spatialBorderStroke.Color=Color3.fromRGB(214,222,235)
        spatialBorderStroke.LineJoinMode=Enum.LineJoinMode.Round; spatialBorderStroke.Parent=borderHost
        local highlight=Instance.new("Frame")
        highlight.Position=UDim2.fromOffset(10,8); highlight.Size=UDim2.new(1,-20,0,1); highlight.BackgroundColor3=Color3.fromRGB(255,255,255)
        highlight.BackgroundTransparency=1; highlight.BorderSizePixel=0; highlight.ZIndex=27; highlight.Parent=root
        local glassStroke=Instance.new("UIStroke")
        glassStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; glassStroke.Thickness=0.85; glassStroke.Transparency=0.50
        glassStroke.Color=Color3.fromRGB(224,234,255); glassStroke.LineJoinMode=Enum.LineJoinMode.Round; glassStroke.Parent=root
        local header=Instance.new("Frame")
        header.Position=UDim2.fromOffset(8,7); header.Size=UDim2.new(1,-16,0,30); header.BackgroundColor3=Color3.fromRGB(255,255,255)
        header.BackgroundTransparency=0.90; header.BorderSizePixel=0; header.ZIndex=30; header.Active=true; header.Parent=root; AddCorner(header,11)
        local title=Instance.new("TextLabel")
        title.Position=UDim2.fromOffset(10,0); title.Size=UDim2.new(1,-20,1,0); title.BackgroundTransparency=1; title.Text=titleText
        title.TextColor3=Color3.fromRGB(248,250,255); title.TextSize=13; title.Font=Enum.Font.GothamBold
        title.TextXAlignment=Enum.TextXAlignment.Left; title.TextYAlignment=Enum.TextYAlignment.Center; title.TextTruncate=Enum.TextTruncate.AtEnd
        title.ZIndex=33; title.Parent=header
        local content=Instance.new("Frame")
        content.Position=UDim2.fromOffset(8,42); content.Size=UDim2.new(1,-16,1,-50); content.BackgroundTransparency=1
        content.BorderSizePixel=0; content.ClipsDescendants=true; content.Active=true; content.ZIndex=20; content.Parent=root
        local frost=Instance.new("Frame")
        frost.Size=UDim2.fromScale(1,1); frost.BackgroundColor3=Color3.fromRGB(218,228,246); frost.BackgroundTransparency=1
        frost.BorderSizePixel=0; frost.ZIndex=245; frost.Active=false; frost.Parent=root; AddCorner(frost,20)
        local pack={Name=name,Part=part,Surface=surface,Root=root,Header=header,Title=title,ContentHost=content,Frost=frost,WidthStud=wStud,HeightStud=hStud}
        S.Surfaces[name]=pack; return pack
    end

    local function wireButton(button,callback)
        local last=0
        local activeInput=nil
        local startPos=nil
        local startedAt=0
        local moved=false
        local moveLimit=20
        local MAX_HOLD=0.68
        local function fire()
            local now=os.clock(); if now-last<0.14 then return end
            last=now; pcall(callback)
        end
        local function resetGesture()
            activeInput=nil; startPos=nil; startedAt=0; moved=false
        end
        local function matchesEnd(input)
            if not activeInput then return false end
            if activeInput.UserInputType==Enum.UserInputType.Touch then return input==activeInput end
            return input.UserInputType==Enum.UserInputType.MouseButton1
        end
        button.InputBegan:Connect(function(input)
            if not S.Enabled or S.Closing then return end
            if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
            activeInput=input
            startPos=Vector2.new(input.Position.X,input.Position.Y)
            startedAt=os.clock(); moved=false
            local cam=workspace.CurrentCamera
            local vh=(cam and cam.ViewportSize.Y) or 720
            moveLimit=math.clamp(vh*0.028,16,24)
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not activeInput or not startPos then return end
            local pos=nil
            if activeInput.UserInputType==Enum.UserInputType.Touch then
                if input~=activeInput then return end
                pos=Vector2.new(input.Position.X,input.Position.Y)
            else
                if input.UserInputType~=Enum.UserInputType.MouseMovement then return end
                pos=Vector2.new(input.Position.X,input.Position.Y)
            end
            if pos and (pos-startPos).Magnitude>moveLimit then moved=true end
        end)
        local function finish(input)
            if not matchesEnd(input) then return end
            local held=os.clock()-startedAt
            local okTap=(not moved) and held<=MAX_HOLD and S.Enabled and not S.Closing
            resetGesture()
            if okTap then fire() end
        end
        button.InputEnded:Connect(finish)
        UserInputService.InputEnded:Connect(finish)
        return button
    end

    local function makeMusicStrip()
        local p=makeSurface("MusicStrip",4.72,0.68,520,72,"")
        p.Surface.AlwaysOnTop=true; p.Header.Visible=false; p.ContentHost.Position=UDim2.fromOffset(6,6); p.ContentHost.Size=UDim2.new(1,-12,1,-12)
        local function btn(txt,x,w)
            local b=Instance.new("TextButton")
            b.Position=UDim2.fromOffset(x,5); b.Size=UDim2.fromOffset(w,49); b.BackgroundColor3=Color3.fromRGB(255,255,255)
            b.BackgroundTransparency=0.85; b.BorderSizePixel=0; b.AutoButtonColor=false; b.Text=txt
            b.TextColor3=Color3.fromRGB(248,248,252); b.TextSize=txt=="▶" and 18 or 25; b.Font=Enum.Font.GothamBold; b.ZIndex=45
            b.Active=true; b.Parent=p.ContentHost; AddCorner(b,12); return b
        end
        local prev=btn("‹",2,48); local play=btn("▶",54,54); local nextB=btn("›",112,48); S.MusicPlayButton=play
        local title=Instance.new("TextLabel")
        title.Position=UDim2.fromOffset(172,4); title.Size=UDim2.new(1,-180,0,27); title.BackgroundTransparency=1; title.Text="大肥鱼 环绕音效"
        title.TextColor3=Color3.fromRGB(250,250,253); title.TextSize=13; title.Font=Enum.Font.GothamBold; title.TextXAlignment=Enum.TextXAlignment.Left
        title.TextTruncate=Enum.TextTruncate.AtEnd; title.ZIndex=40; title.Parent=p.ContentHost; S.MusicTitle=title
        local status=Instance.new("TextLabel")
        status.Position=UDim2.fromOffset(172,31); status.Size=UDim2.new(1,-180,0,21); status.BackgroundTransparency=1; status.Text="点 ▶ 播放 / 暂停 · 轻触右侧打开播放器"
        status.TextColor3=Color3.fromRGB(182,195,211); status.TextSize=10; status.Font=Enum.Font.GothamMedium; status.TextXAlignment=Enum.TextXAlignment.Left
        status.TextTruncate=Enum.TextTruncate.AtEnd; status.ZIndex=40; status.Parent=p.ContentHost; S.MusicStatus=status
        local open=Instance.new("TextButton")
        open.Position=UDim2.fromOffset(166,0); open.Size=UDim2.new(1,-166,1,0); open.BackgroundTransparency=1; open.BorderSizePixel=0
        open.Text=""; open.AutoButtonColor=false; open.Active=true; open.ZIndex=46; open.Parent=p.ContentHost
        wireButton(prev,function() if DBMusic and type(DBMusic.PreviousSpatialTrack)=="function" then DBMusic.PreviousSpatialTrack() end end)
        wireButton(play,function() if DBMusic and type(DBMusic.ToggleSpatialPlayback)=="function" then DBMusic.ToggleSpatialPlayback() end end)
        wireButton(nextB,function() if DBMusic and type(DBMusic.NextSpatialTrack)=="function" then DBMusic.NextSpatialTrack() end end)
        wireButton(open,function() if DBMusic and type(DBMusic.ShowAdvanced)=="function" then DBMusic.ShowAdvanced() end end)
        return p
    end

    local function makeMiniButton()
        local part=makePart("DB_AR132_MiniButton",2.04,0.52)
        local surface=Instance.new("SurfaceGui")
        surface.ResetOnSpawn=false
        surface.Name="DB_Spatial_V132_Mini"; surface.Adornee=part; surface.Face=Enum.NormalId.Front; surface.Active=true; surface.AlwaysOnTop=true
        surface.LightInfluence=0; surface.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize; surface.CanvasSize=Vector2.new(230,58); surface.ZOffset=0.04
        surface.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; surface.Enabled=false; surface.Parent=__dbPlayerGui
        local root=Instance.new("Frame")
        root.Size=UDim2.fromScale(1,1); root.BackgroundColor3=Color3.fromRGB(5,8,14); root.BackgroundTransparency=0.09; root.BorderSizePixel=0
        root.ClipsDescendants=true; root.Active=true; root.ZIndex=10; root.Parent=surface; AddCorner(root,999)
        local border=Instance.new("Frame")
        border.Position=UDim2.fromOffset(3,3); border.Size=UDim2.new(1,-6,1,-6); border.BackgroundTransparency=1; border.BorderSizePixel=0; border.ZIndex=30
        border.Parent=root; AddCorner(border,999)
        local miniStroke=Instance.new("UIStroke"); miniStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; miniStroke.Thickness=1.05
        miniStroke.Transparency=0.56; miniStroke.Color=Color3.fromRGB(214,222,235); miniStroke.LineJoinMode=Enum.LineJoinMode.Round; miniStroke.Parent=border
        local button=Instance.new("TextButton")
        button.Size=UDim2.fromScale(1,1); button.BackgroundTransparency=1; button.BorderSizePixel=0; button.Text="大肥鱼脚本  ·  展开空间面板"
        button.TextColor3=Color3.fromRGB(250,250,253); button.TextSize=13; button.Font=Enum.Font.GothamBlack; button.AutoButtonColor=false
        button.Active=true; button.ZIndex=35; button.Parent=root; wireButton(button,function() Controller.SetMinimized(false) end)
        local pack={Name="Mini",Part=part,Surface=surface,Root=root,Button=button,WidthStud=2.04,HeightStud=0.52}
        S.Surfaces.Mini=pack; S.Mini=pack; return pack
    end

    local function makeBars()
        S.Bars={}
        for i=1,BAR_COUNT do
            local b=Instance.new("Part")
            b.Name=string.format("DB_AR132_Wave_%02d",i); b.Anchored=true; b.CanCollide=false; b.CanTouch=false; b.CanQuery=false; b.CastShadow=false
            b.Material=Enum.Material.Neon; b.Size=Vector3.new(0.14,0.055,0.18); b.Transparency=0.10; b.Color=Color3.fromRGB(70,225,94); b.Parent=S.WorldFolder
            S.Bars[i]=b
        end
    end
    local function colorFor(level)
        level=clamp01(level)
        if level<0.24 then return Color3.fromRGB(78,218,86):Lerp(Color3.fromRGB(55,232,108),level/0.24) end
        if level<0.52 then return Color3.fromRGB(55,232,108):Lerp(Color3.fromRGB(26,225,162),(level-0.24)/0.28) end
        if level<0.78 then return Color3.fromRGB(26,225,162):Lerp(Color3.fromRGB(20,202,211),(level-0.52)/0.26) end
        return Color3.fromRGB(20,202,211):Lerp(Color3.fromRGB(41,78,238),(level-0.78)/0.22)
    end
    local function sampleLevel(levels,index,count)
        if type(levels)~="table" or #levels==0 then return 0 end
        local pos=1+((index-1)/math.max(1,count-1))*math.max(0,#levels-1); local a=math.floor(pos); local bb=math.min(#levels,a+1); local t=pos-a
        return clamp01((tonumber(levels[a]) or 0)+((tonumber(levels[bb]) or 0)-(tonumber(levels[a]) or 0))*t)
    end
    local function snapshot()
        local snap=nil
        if DBMusic and type(DBMusic.GetSpatialSnapshot)=="function" then local ok,r=pcall(DBMusic.GetSpatialSnapshot); if ok and type(r)=="table" then snap=r end end
        snap=snap or {Title="",Artist="",Platform="",Status="",Playing=false,Levels={},Rms=0}; S.LastSnapshot=snap
        if S.MusicTitle and S.MusicTitle.Parent then S.MusicTitle.Text=snap.Title~="" and (snap.Title..(snap.Artist~="" and (" · "..snap.Artist) or "")) or "大肥鱼 环绕音效" end
        if S.MusicStatus and S.MusicStatus.Parent then S.MusicStatus.Text=(snap.Platform~="" and (snap.Platform.." · ") or "")..(snap.Status~="" and snap.Status or "点 ▶ 播放 / 暂停") end
        if S.MusicPlayButton and S.MusicPlayButton.Parent then S.MusicPlayButton.Text=snap.Playing and "Ⅱ" or "▶" end
        return snap
    end

    local function updateBars(basis,openP,collapse,dt)
        S.SpectrumAccumulator=S.SpectrumAccumulator+dt; if S.SpectrumAccumulator<1/30 then return end
        S.SpectrumAccumulator=S.SpectrumAccumulator%(1/30)
        local snap=snapshot(); local levels=snap.Levels or {}; local maxLevel=0
        for i=1,#levels do local v=tonumber(levels[i]) or 0; if v>maxLevel then maxLevel=v end end
        local status=tostring(snap.Status or "")
        local active=(snap.Playing==true) or (tonumber(snap.Rms) or 0)>0.002 or maxLevel>0.006 or (status:find("播放",1,true)~=nil and status:find("暂停",1,true)==nil)
        local origin=basis.Position; local right=basis.RightVector; local up=basis.UpVector; local look=basis.LookVector
        local radius=5.40; local maxAngle=math.rad(72); local collapseFade=1-smooth(math.clamp((collapse-0.62)/0.38,0,1))
        local clock=os.clock(); local center=(BAR_COUNT+1)*0.5
        for i,b in ipairs(S.Bars) do
            if b and b.Parent then
                local t=(i-1)/math.max(1,BAR_COUNT-1); local theta=-maxAngle+(maxAngle*2)*t
                local level=sampleLevel(levels,i,BAR_COUNT)
                if active and maxLevel<0.003 then
                    local d=math.floor(math.abs(i-center)); local phase=clock-d*0.055
                    level=math.clamp(0.12+0.30*((math.sin(phase*5.0)+1)*0.5)+0.18*((math.sin(phase*9.2+0.8)+1)*0.5)+0.25*(math.max(0,math.sin(phase*6.2))^5),0.08,0.90)
                elseif not active then level=0 end
                local orbit=active and math.rad(math.sin(clock*1.55)*3.6) or 0
                local ripple=active and math.rad(math.sin(clock*5.2+(i-center)*0.44)*(0.45+level*2.35)) or 0
                local animatedTheta=theta+orbit+ripple
                local height=0.055+(level^0.84)*2.42
                local dir=look*math.cos(animatedTheta)+right*math.sin(animatedTheta)
                local radialPulse=active and (math.sin(clock*4.6+i*0.31)*0.035*level) or 0
                local base=origin+dir*(radius+radialPulse)-up*2.10
                local pos=base+up*(height*0.5)
                b.Size=Vector3.new(0.14+level*0.035,height,0.18+level*0.055)
                local roll=active and math.rad(math.sin(clock*7.4+i*0.63)*(1.8+level*7.2)) or 0
                local yaw=active and math.rad(math.sin(clock*4.1-i*0.37)*(0.8+level*3.8)) or 0
                b.CFrame=CFrame.lookAt(pos,origin+look*0.55-up*1.05,up)*CFrame.Angles(0,yaw,roll)
                b.Color=colorFor(level)
                b.Transparency=math.clamp((active and 0.06 or 0.70)+(1-openP)*0.14+(1-collapseFade)*0.90,0.04,0.97)
            end
        end
    end

    local function saveProfile(obj,props)
        if not obj or S.ProfileOriginal[obj] then return end
        local sv={}
        for _,prop in ipairs(props) do local ok,val=pcall(function() return obj[prop] end); if ok then sv[prop]=val end end
        S.ProfileOriginal[obj]=sv
    end
    local function restoreProfileLayout()
        for obj,sv in pairs(S.ProfileOriginal) do
            if obj and obj.Parent then for prop,val in pairs(sv) do pcall(function() obj[prop]=val end) end end
        end
        S.ProfileOriginal={}
    end
    local function applyProfileLayout()
        if not PlayerInfoCard or not PlayerInfoCard.Parent then return end
        saveProfile(PlayerInfoCard,{"Size","Position"})
        saveProfile(PlayerAvatar,{"Position","Size","ScaleType","Visible"})
        saveProfile(PlayerNameLabel,{"Position","Size","TextSize"})
        saveProfile(PlayerAgeLabel,{"Position","Size","TextSize"})
        saveProfile(PlayerUsernameLabel,{"Position","Size","TextSize"})
        if PlayerInfoTitle then saveProfile(PlayerInfoTitle,{"Position","Size","TextSize"}) end
        PlayerInfoCard.Size=UDim2.new(1,-10,0,188); PlayerInfoCard.Position=UDim2.fromOffset(5,4)
        if PlayerInfoTitle then PlayerInfoTitle.Position=UDim2.fromOffset(9,6); PlayerInfoTitle.Size=UDim2.new(1,-18,0,18); PlayerInfoTitle.TextSize=11 end
        PlayerAvatar.Visible=true; PlayerAvatar.Position=UDim2.fromOffset(10,30); PlayerAvatar.Size=UDim2.fromOffset(66,66); PlayerAvatar.ScaleType=Enum.ScaleType.Fit
        PlayerNameLabel.Position=UDim2.fromOffset(10,102); PlayerNameLabel.Size=UDim2.new(1,-20,0,26); PlayerNameLabel.TextSize=10
        PlayerAgeLabel.Position=UDim2.fromOffset(10,129); PlayerAgeLabel.Size=UDim2.new(1,-20,0,24); PlayerAgeLabel.TextSize=9
        PlayerUsernameLabel.Position=UDim2.fromOffset(10,154); PlayerUsernameLabel.Size=UDim2.new(1,-20,0,27); PlayerUsernameLabel.TextSize=9
        local viewport=PlayerInfoCard:FindFirstChild("Player3DViewport")
        if viewport then saveProfile(viewport,{"Position","Size","Visible"}); viewport.Visible=false end
        local sw=PlayerInfoCard:FindFirstChild("Player3DSwitch")
        if sw then saveProfile(sw,{"Position","Size","Visible"}); sw.Visible=false end
        local mixer=PlayerProfileScroll and PlayerProfileScroll:FindFirstChild("DB_Music_VolumeMixer")
        if mixer then saveProfile(mixer,{"Position","Size"}); mixer.Position=UDim2.fromOffset(5,196); mixer.Size=UDim2.new(1,-10,0,188) end
        if PlayerProfileScroll then saveProfile(PlayerProfileScroll,{"CanvasSize"}); PlayerProfileScroll.CanvasSize=UDim2.fromOffset(0,394) end
    end

    local function attach(obj,pack)
        if not obj or not pack then return end
        remember(obj); obj.Parent=pack.ContentHost; obj.AnchorPoint=Vector2.new(0,0); obj.Position=UDim2.fromScale(0,0); obj.Size=UDim2.fromScale(1,1)
        obj.Visible=true; obj.ClipsDescendants=true
        for _,d in ipairs(obj:GetDescendants()) do
            if d:IsA("GuiButton") then d.Active=true end
            if d:IsA("ScrollingFrame") then d.Active=true; d.ScrollingEnabled=true end
        end
    end
    local function restoreRails() restore(PlayerProfileRail); restore(RightList); restore(LeftMenu); restoreProfileLayout() end
    local function getBlur()
        local blur=Lighting:FindFirstChild("DB_SpatialTransitionBlur_V132")
        if not blur then blur=Instance.new("BlurEffect"); blur.Name="DB_SpatialTransitionBlur_V132"; blur.Size=0; blur.Parent=Lighting; S.BlurOwned=true end
        S.Blur=blur; return blur
    end
    local function setBlur(amount) local blur=S.Blur or getBlur(); if blur then pcall(function() blur.Size=math.clamp(amount or 0,0,14) end) end end

    local function build()
        removeStale(); local folder=Instance.new("Folder"); folder.Name=FOLDER_NAME; folder.Parent=workspace; S.WorldFolder=folder
        local left=makeSurface("Left",3.42,4.72,350,472,"玩家 / 音量")
        local center=makeSurface("Center",6.42,4.72,650,472,"主控制台")
        local right=makeSurface("Right",3.62,4.72,370,472,"功能导航")
        local music=makeMusicStrip(); makeMiniButton(); S.CenterTitle=center.Title
        left.Root.BackgroundTransparency=0.11; center.Root.BackgroundTransparency=0.08; right.Root.BackgroundTransparency=0.11

        local back=Instance.new("TextButton")
        back.AnchorPoint=Vector2.new(1,0.5); back.Position=UDim2.new(1,-5,0.5,0); back.Size=UDim2.fromOffset(61,22)
        back.BackgroundColor3=Color3.fromRGB(255,255,255); back.BackgroundTransparency=0.84; back.BorderSizePixel=0; back.Text="返回2D"
        back.TextColor3=Color3.fromRGB(248,248,252); back.TextSize=10; back.Font=Enum.Font.GothamBold; back.AutoButtonColor=false; back.Active=true
        back.ZIndex=62; back.Parent=right.Header; AddCorner(back,999); wireButton(back,function() Controller.SetEnabled(false) end)
        local minBtn=Instance.new("TextButton")
        minBtn.AnchorPoint=Vector2.new(1,0.5); minBtn.Position=UDim2.new(1,-72,0.5,0); minBtn.Size=UDim2.fromOffset(27,22)
        minBtn.BackgroundColor3=Color3.fromRGB(255,255,255); minBtn.BackgroundTransparency=0.84; minBtn.BorderSizePixel=0; minBtn.Text="−"
        minBtn.TextColor3=Color3.fromRGB(248,248,252); minBtn.TextSize=18; minBtn.Font=Enum.Font.GothamBold; minBtn.AutoButtonColor=false; minBtn.Active=true
        minBtn.ZIndex=64; minBtn.Parent=right.Header; AddCorner(minBtn,999); wireButton(minBtn,function() Controller.SetMinimized(true) end)
        right.Title.Size=UDim2.new(1,-112,1,0)

        applyProfileLayout(); attach(PlayerProfileRail,left); attach(RightList,center); attach(LeftMenu,right); makeBars(); getBlur(); setBlur(0)
        return left,center,right,music
    end
    local function destroyWorld()
        for _,p in pairs(S.Surfaces) do if p.Surface then destroy(p.Surface) end end
        S.Surfaces={}; S.Mini=nil; destroy(S.WorldFolder); S.WorldFolder=nil; S.Bars={}; S.MusicTitle=nil; S.MusicStatus=nil; S.MusicPlayButton=nil; S.CenterTitle=nil
        setBlur(0); if S.BlurOwned and S.Blur then destroy(S.Blur) end; S.Blur=nil; S.BlurOwned=false
    end
    local function finalize()
        if DBSpatial and type(Controller.DetachAdvancedMusic)=="function" then pcall(Controller.DetachAdvancedMusic) end
        restoreRails(); destroyWorld(); S.Enabled=false; S.Closing=false; S.Progress=0; S.Velocity=0; S.LookVector=nil; S.UpVector=nil
        S.Minimized=false; S.MinimizeTarget=0; S.MinimizeProgress=0; S.MinimizeVelocity=0
        DBVisualSettings.SpatialModeEnabled=false; Controller.Enabled=false
        State.Minimized=S.PreviousMinimized==true; Panel.Visible=S.PreviousPanelVisible==true; FloatingButton.Visible=S.PreviousFloatingVisible==true
        if State.Minimized then Panel.Visible=false; FloatingButton.Visible=true elseif not Panel.Visible then Panel.Visible=true end
        DBStartupScale.Scale=1; State.Animating=false
        if S.RenderConnection then pcall(function() S.RenderConnection:Disconnect() end); S.RenderConnection=nil end
    end

    local function cameraBasis(cam,dt)
        local currentLook=cam.CFrame.LookVector; local currentUp=cam.CFrame.UpVector
        if not S.LookVector then S.LookVector=currentLook; S.UpVector=currentUp end
        if S.LookVector:Dot(currentLook)<0.48 then S.LookVector=currentLook; S.UpVector=currentUp
        else
            local a=1-math.exp(-dt*12.5); S.LookVector=(S.LookVector:Lerp(currentLook,a)).Unit; S.UpVector=(S.UpVector:Lerp(currentUp,a)).Unit
        end
        return CFrame.lookAt(cam.CFrame.Position,cam.CFrame.Position+S.LookVector,S.UpVector)
    end
    local function setMainSurfaceEnabled(enabled)
        for name,p in pairs(S.Surfaces) do if name~="Mini" and p.Surface then p.Surface.Enabled=enabled end end
    end

    UserInputService.InputBegan:Connect(function(input)
        if not S.Enabled or input.UserInputType~=Enum.UserInputType.Touch then return end
        local cam=workspace.CurrentCamera; local vp=cam and cam.ViewportSize; if not vp then return end
        if input.Position.X <= vp.X*0.36 and input.Position.Y >= vp.Y*0.53 then S.JoystickInputs[input]=true; S.JoystickTouch=true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if S.JoystickInputs[input] then S.JoystickInputs[input]=nil; S.JoystickTouch=next(S.JoystickInputs)~=nil end
    end)

    local function update(dt)
        if not S.Enabled then return end
        local cam=workspace.CurrentCamera; if not cam then return end
        local target=S.Closing and 0 or 1; local accel=(target-S.Progress)*(S.Closing and 74 or 86)-S.Velocity*19
        S.Velocity=S.Velocity+accel*dt; S.Progress=math.clamp(S.Progress+S.Velocity*dt,-0.02,1.03)
        local p=clamp01(S.Progress); local openP=easeOut(p)
        local mTarget=clamp01(S.MinimizeTarget); local mAccel=(mTarget-S.MinimizeProgress)*90-S.MinimizeVelocity*19
        S.MinimizeVelocity=S.MinimizeVelocity+mAccel*dt; S.MinimizeProgress=math.clamp(S.MinimizeProgress+S.MinimizeVelocity*dt,-0.025,1.025)
        if math.abs(mTarget-S.MinimizeProgress)<0.002 and math.abs(S.MinimizeVelocity)<0.028 then S.MinimizeProgress=mTarget; S.MinimizeVelocity=0 end
        local collapse=clamp01(S.MinimizeProgress)

        local basis=cameraBasis(cam,dt); local origin=basis.Position; local right=basis.RightVector; local up=basis.UpVector; local look=basis.LookVector
        local hover=math.sin(os.clock()*1.05)*0.014*(1-collapse); origin=origin+up*(0.30+hover)
        local center=S.Surfaces.Center; local left=S.Surfaces.Left; local rightP=S.Surfaces.Right; local music=S.Surfaces.MusicStrip; local mini=S.Mini

        local focus=origin+look*0.66+up*0.16
        local centerBase=origin+look*(4.62-(1-openP)*0.30)+up*0.02
        local leftBase=origin+look*5.05-right*(4.55*openP)+up*0.02
        local rightBase=origin+look*5.05+right*(4.72*openP)+up*0.02
        local musicBase=origin+look*4.54+up*(2.95-(1-openP)*0.22)
        local a=smooth(math.clamp(collapse/0.50,0,1))
        local c=smooth(math.clamp((collapse-0.70)/0.30,0,1))
        local merge=centerBase+look*0.045
        local leftPos=leftBase:Lerp(merge-right*0.05+look*0.08,a)
        local rightPos=rightBase:Lerp(merge+right*0.05+look*0.10,a)
        local musicPos=musicBase:Lerp(merge+up*1.50,a)
        local finalY=math.max(0.045,1-0.955*c); local finalX=1-0.18*c
        local sideX=(1-0.045*a)*finalX
        if center and center.Part then
            center.Part.CFrame=CFrame.lookAt(centerBase,focus,up); center.Part.Size=Vector3.new(center.WidthStud*finalX,center.HeightStud*finalY,0.03)
            if S.CenterTitle then S.CenterTitle.Text=tostring(State.CurrentCategory or "主控制台") end
        end
        if left and left.Part then left.Part.CFrame=CFrame.lookAt(leftPos,focus,up); left.Part.Size=Vector3.new(left.WidthStud*sideX,left.HeightStud*finalY,0.03) end
        if rightP and rightP.Part then rightP.Part.CFrame=CFrame.lookAt(rightPos,focus,up); rightP.Part.Size=Vector3.new(rightP.WidthStud*sideX,rightP.HeightStud*finalY,0.03) end
        if music and music.Part then
            music.Part.CFrame=CFrame.lookAt(musicPos,focus,up)
            local widthScale=(1-0.16*a)*(1-0.10*c); local heightScale=math.max(0.08,1-0.90*c)
            music.Part.Size=Vector3.new(music.WidthStud*widthScale,music.HeightStud*heightScale,0.03)
        end

        local frostLevel=math.clamp((collapse-0.62)/0.31,0,1)
        for name,pack in pairs(S.Surfaces) do if name~="Mini" and pack.Frost then pack.Frost.BackgroundTransparency=1-frostLevel*0.27 end end
        local blurPhase=0
        if collapse>0.62 and collapse<0.995 then blurPhase=math.sin(math.clamp((collapse-0.62)/0.375,0,1)*math.pi) end
        setBlur(10.5*blurPhase)
        setMainSurfaceEnabled(collapse<0.988 and p>0.02)

        if mini and mini.Part and mini.Surface then
            local miniP=smooth(math.clamp((collapse-0.855)/0.145,0,1))
            local miniPos=origin+look*4.36+up*2.40
            mini.Part.CFrame=CFrame.lookAt(miniPos,origin+look*0.50+up*0.35,up)
            mini.Part.Size=Vector3.new(mini.WidthStud*math.max(0.055,miniP),mini.HeightStud*math.max(0.07,miniP),0.03)
            mini.Surface.Enabled=miniP>0.035 and p>0.02
        end

        updateBars(basis,openP,collapse,dt)
        if left and left.Surface then
            local moving=false; local char=LocalPlayer.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
            if hum then moving=hum.MoveDirection.Magnitude>0.025 end
            left.Surface.Active=(not moving) and (not S.JoystickTouch) and collapse<0.96
            left.Part.CanQuery=(not moving) and (not S.JoystickTouch) and collapse<0.96
        end
        if S.Closing and p<0.012 and math.abs(S.Velocity)<0.14 then task.defer(finalize) end
    end

    function Controller.IsEnabled() return S.Enabled and not S.Closing end
    function Controller.IsActive() return S.Enabled==true end
    function Controller.IsMinimized() return S.Enabled and S.MinimizeTarget>0.5 end
    function Controller.GetLastError() return S.LastError end
    function Controller.SetMinimized(minimized)
        if not S.Enabled or S.Closing then return end
        S.Minimized=minimized==true; S.MinimizeTarget=S.Minimized and 1 or 0; State.Minimized=S.Minimized; State.Animating=true
        if not S.Minimized then setMainSurfaceEnabled(true) end
        task.delay(0.75,function() if S.Enabled and not S.Closing and math.abs(S.MinimizeProgress-S.MinimizeTarget)<0.02 then State.Animating=false end end)
    end
    function Controller.ToggleMinimized() Controller.SetMinimized(not Controller.IsMinimized()) end
    function Controller.AttachAdvancedMusic(root)
        if not S.Enabled or S.Closing or S.MinimizeTarget>0.5 or not root then return false end
        local center=S.Surfaces.Center; if not center or not center.ContentHost then return false end
        if S.AdvancedRoot==root and root.Parent==center.ContentHost then return true end
        Controller.DetachAdvancedMusic(); S.AdvancedRoot=root
        S.AdvancedOriginal={Parent=root.Parent,Position=root.Position,Size=root.Size,AnchorPoint=root.AnchorPoint,Visible=root.Visible}
        if RightList and RightList.Parent then RightList.Visible=false end
        root.Parent=center.ContentHost; root.AnchorPoint=Vector2.new(0,0); root.Position=UDim2.fromScale(0,0); root.Size=UDim2.fromScale(1,1); root.Visible=true
        return true
    end
    function Controller.DetachAdvancedMusic()
        local root,sv=S.AdvancedRoot,S.AdvancedOriginal
        if root and sv then pcall(function() root.Parent=sv.Parent or Panel; root.Position=sv.Position; root.Size=sv.Size; root.AnchorPoint=sv.AnchorPoint; root.Visible=sv.Visible==true end) end
        S.AdvancedRoot=nil; S.AdvancedOriginal=nil; if RightList and RightList.Parent then RightList.Visible=true end
    end
    function Controller.SetEnabled(enabled)
        enabled=enabled==true
        if enabled then
            if S.Enabled then S.Closing=false; DBVisualSettings.SpatialModeEnabled=true; Controller.Enabled=true; if S.MinimizeTarget>0.5 then Controller.SetMinimized(false) end; return end
            S.PreviousPanelVisible=Panel.Visible; S.PreviousFloatingVisible=FloatingButton.Visible; S.PreviousMinimized=State.Minimized
            AppleTransition.Running=false; AppleTransition.Velocity=0; AppleTransition.ClearSoftFocus(); State.Animating=true; DBStartupScale.Scale=1
            local ok,err=pcall(build)
            if not ok then
                S.LastError=tostring(err); warn("[大肥鱼 V132] 空间模式构建失败: ",err); restoreRails(); destroyWorld(); State.Animating=false
                DBVisualSettings.SpatialModeEnabled=false; Controller.Enabled=false; return
            end
            Panel.Visible=false; FloatingButton.Visible=false; S.Enabled=true; S.Closing=false; S.Progress=0.04; S.Velocity=0
            S.LookVector=nil; S.UpVector=nil; S.Minimized=false; S.MinimizeTarget=0; S.MinimizeProgress=0; S.MinimizeVelocity=0
            DBVisualSettings.SpatialModeEnabled=true; Controller.Enabled=true; S.LastError=nil
            if S.RenderConnection then pcall(function() S.RenderConnection:Disconnect() end) end
            S.RenderConnection=RunService.RenderStepped:Connect(function(dt)
                dt=math.min(dt,1/30)
                local okUpdate,errUpdate=pcall(update,dt)
                if not okUpdate then
                    S.LastError=tostring(errUpdate); warn("[大肥鱼 V132] 空间更新错误: ",errUpdate)
                    for _,pack in pairs(S.Surfaces) do if pack.Part then pack.Part.Transparency=1 end end
                end
            end)
        else
            if not S.Enabled then return end
            S.Closing=true; S.MinimizeTarget=0; setBlur(0); setMainSurfaceEnabled(true)
            DBVisualSettings.SpatialModeEnabled=false; Controller.Enabled=false
        end
    end
    function Controller.Destroy(force)
        if S.RenderConnection then pcall(function() S.RenderConnection:Disconnect() end); S.RenderConnection=nil end
        if S.Enabled or S.WorldFolder then finalize() else removeStale() end
    end

end
    return Controller
end

local function DBCreateSpatialController_133()
    local Controller = { Enabled = false }
do
    local Lighting = game:GetService("Lighting")
    local S = {
        Enabled=false, Closing=false, Progress=0, Velocity=0,
        LookVector=nil, UpVector=nil, RenderConnection=nil, WorldFolder=nil,
        Surfaces={}, Bars={}, Original={}, ProfileOriginal={},
        PreviousPanelVisible=true, PreviousFloatingVisible=false, PreviousMinimized=false,
        AdvancedRoot=nil, AdvancedOriginal=nil,
        CenterTitle=nil, MusicTitle=nil, MusicStatus=nil, MusicPlayButton=nil,
        SpectrumAccumulator=0, LastSnapshot=nil, LastError=nil,
        Minimized=false, MinimizeTarget=0, MinimizeProgress=0, MinimizeVelocity=0,
        Blur=nil, BlurOwned=false, Mini=nil,
        JoystickTouch=false, JoystickInputs={},
        DeckCards={}, DeckSelected=1, DeckMode="Detail",
    }
    local FOLDER_NAME = "DB_SpatialHUD_V133"
    local BAR_COUNT = 48

    local function clamp01(v) return math.clamp(tonumber(v) or 0,0,1) end
    local function smooth(v) v=clamp01(v); return v*v*(3-2*v) end
    local function easeOut(v) v=clamp01(v); return 1-(1-v)^3 end
    local function destroy(obj) if obj and obj.Parent then pcall(function() obj:Destroy() end) end end
    local function remember(obj)
        if not obj or S.Original[obj] then return end
        S.Original[obj]={Parent=obj.Parent,Position=obj.Position,Size=obj.Size,AnchorPoint=obj.AnchorPoint,Visible=obj.Visible,ClipsDescendants=obj.ClipsDescendants}
    end
    local function restore(obj)
        local sv=obj and S.Original[obj]
        if not obj or not sv then return end
        pcall(function()
            obj.Parent=sv.Parent; obj.Position=sv.Position; obj.Size=sv.Size; obj.AnchorPoint=sv.AnchorPoint
            obj.Visible=sv.Visible; obj.ClipsDescendants=sv.ClipsDescendants
        end)
        S.Original[obj]=nil
    end
    local function removeStale()
        for _,name in ipairs({"DB_SpatialHUD_V126","DB_SpatialHUD_V127","DB_SpatialHUD_V128",FOLDER_NAME}) do
            local old=workspace:FindFirstChild(name); if old then destroy(old) end
        end
        if __dbPlayerGui then
            for _,child in ipairs(__dbPlayerGui:GetChildren()) do
                if child:IsA("SurfaceGui") and (child.Name:find("DB_Spatial_V126",1,true) or child.Name:find("DB_Spatial_V127",1,true) or child.Name:find("DB_Spatial_V128",1,true) or child.Name:find("DB_Spatial_V133",1,true)) then
                    destroy(child)
                end
            end
        end
    end
    local function makePart(name,w,h)
        local part=Instance.new("Part")
        part.Name=name; part.Anchored=true; part.CanCollide=false; part.CanTouch=false; part.CanQuery=true; part.CastShadow=false
        part.Transparency=1; part.Color=Color3.fromRGB(12,15,22); part.Material=Enum.Material.SmoothPlastic
        part.Size=Vector3.new(w,h,0.03); part.Parent=S.WorldFolder
        return part
    end
    local function makeSurface(name,wStud,hStud,canvasW,canvasH,titleText)
        local part=makePart("DB_AR133_"..name.."_Panel",wStud,hStud)
        local surface=Instance.new("SurfaceGui")
        surface.ResetOnSpawn=false
        surface.Name="DB_Spatial_V133_"..name; surface.Adornee=part; surface.Face=Enum.NormalId.Front; surface.Active=true
        surface.AlwaysOnTop=(name=="Center" or name=="MusicStrip")
        surface.LightInfluence=0; surface.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize
        surface.CanvasSize=Vector2.new(canvasW,canvasH); surface.ClipsDescendants=false; surface.MaxDistance=0
        surface.ZOffset=(name=="Center" and 0.055 or 0.018); surface.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; surface.Parent=__dbPlayerGui

        local root=Instance.new("Frame")
        root.Name="SpatialGlassRoot"; root.Size=UDim2.fromScale(1,1); root.BackgroundColor3=Color3.fromRGB(5,7,12)
        root.BackgroundTransparency=(name=="Center" and 0.09 or 0.17); root.BorderSizePixel=0; root.ClipsDescendants=true; root.Active=true; root.ZIndex=10; root.Parent=surface
        AddCorner(root,20)
        local borderHost=Instance.new("Frame")
        borderHost.Position=UDim2.fromOffset(3,3); borderHost.Size=UDim2.new(1,-6,1,-6); borderHost.BackgroundTransparency=1
        borderHost.BorderSizePixel=0; borderHost.ZIndex=250; borderHost.Parent=root; AddCorner(borderHost,18)
        local spatialBorderStroke=Instance.new("UIStroke")
        spatialBorderStroke.Name="DB_SpatialStaticBorder"; spatialBorderStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        spatialBorderStroke.Thickness=1.15; spatialBorderStroke.Transparency=0.58; spatialBorderStroke.Color=Color3.fromRGB(214,222,235)
        spatialBorderStroke.LineJoinMode=Enum.LineJoinMode.Round; spatialBorderStroke.Parent=borderHost
        local highlight=Instance.new("Frame")
        highlight.Position=UDim2.fromOffset(10,8); highlight.Size=UDim2.new(1,-20,0,1); highlight.BackgroundColor3=Color3.fromRGB(255,255,255)
        highlight.BackgroundTransparency=1; highlight.BorderSizePixel=0; highlight.ZIndex=27; highlight.Parent=root
        local glassStroke=Instance.new("UIStroke")
        glassStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; glassStroke.Thickness=0.85; glassStroke.Transparency=0.50
        glassStroke.Color=Color3.fromRGB(224,234,255); glassStroke.LineJoinMode=Enum.LineJoinMode.Round; glassStroke.Parent=root
        local header=Instance.new("Frame")
        header.Position=UDim2.fromOffset(8,7); header.Size=UDim2.new(1,-16,0,30); header.BackgroundColor3=Color3.fromRGB(255,255,255)
        header.BackgroundTransparency=0.90; header.BorderSizePixel=0; header.ZIndex=30; header.Active=true; header.Parent=root; AddCorner(header,11)
        local title=Instance.new("TextLabel")
        title.Position=UDim2.fromOffset(10,0); title.Size=UDim2.new(1,-20,1,0); title.BackgroundTransparency=1; title.Text=titleText
        title.TextColor3=Color3.fromRGB(248,250,255); title.TextSize=13; title.Font=Enum.Font.GothamBold
        title.TextXAlignment=Enum.TextXAlignment.Left; title.TextYAlignment=Enum.TextYAlignment.Center; title.TextTruncate=Enum.TextTruncate.AtEnd
        title.ZIndex=33; title.Parent=header
        local content=Instance.new("Frame")
        content.Position=UDim2.fromOffset(8,42); content.Size=UDim2.new(1,-16,1,-50); content.BackgroundTransparency=1
        content.BorderSizePixel=0; content.ClipsDescendants=true; content.Active=true; content.ZIndex=20; content.Parent=root
        local frost=Instance.new("Frame")
        frost.Size=UDim2.fromScale(1,1); frost.BackgroundColor3=Color3.fromRGB(218,228,246); frost.BackgroundTransparency=1
        frost.BorderSizePixel=0; frost.ZIndex=245; frost.Active=false; frost.Parent=root; AddCorner(frost,20)
        local pack={Name=name,Part=part,Surface=surface,Root=root,Header=header,Title=title,ContentHost=content,Frost=frost,WidthStud=wStud,HeightStud=hStud}
        S.Surfaces[name]=pack; return pack
    end

    local function wireButton(button,callback)
        local last=0
        local activeInput=nil
        local startPos=nil
        local startedAt=0
        local moved=false
        local moveLimit=20
        local MAX_HOLD=0.68
        local function fire()
            local now=os.clock(); if now-last<0.14 then return end
            last=now; pcall(callback)
        end
        local function resetGesture()
            activeInput=nil; startPos=nil; startedAt=0; moved=false
        end
        local function matchesEnd(input)
            if not activeInput then return false end
            if activeInput.UserInputType==Enum.UserInputType.Touch then return input==activeInput end
            return input.UserInputType==Enum.UserInputType.MouseButton1
        end
        button.InputBegan:Connect(function(input)
            if not S.Enabled or S.Closing then return end
            if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
            activeInput=input
            startPos=Vector2.new(input.Position.X,input.Position.Y)
            startedAt=os.clock(); moved=false
            local cam=workspace.CurrentCamera
            local vh=(cam and cam.ViewportSize.Y) or 720
            moveLimit=math.clamp(vh*0.028,16,24)
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not activeInput or not startPos then return end
            local pos=nil
            if activeInput.UserInputType==Enum.UserInputType.Touch then
                if input~=activeInput then return end
                pos=Vector2.new(input.Position.X,input.Position.Y)
            else
                if input.UserInputType~=Enum.UserInputType.MouseMovement then return end
                pos=Vector2.new(input.Position.X,input.Position.Y)
            end
            if pos and (pos-startPos).Magnitude>moveLimit then moved=true end
        end)
        local function finish(input)
            if not matchesEnd(input) then return end
            local held=os.clock()-startedAt
            local okTap=(not moved) and held<=MAX_HOLD and S.Enabled and not S.Closing
            resetGesture()
            if okTap then fire() end
        end
        button.InputEnded:Connect(finish)
        UserInputService.InputEnded:Connect(finish)
        return button
    end

    local function makeMusicStrip()
        local p=makeSurface("MusicStrip",4.72,0.68,520,72,"")
        p.Surface.AlwaysOnTop=true; p.Header.Visible=false; p.ContentHost.Position=UDim2.fromOffset(6,6); p.ContentHost.Size=UDim2.new(1,-12,1,-12)
        local function btn(txt,x,w)
            local b=Instance.new("TextButton")
            b.Position=UDim2.fromOffset(x,5); b.Size=UDim2.fromOffset(w,49); b.BackgroundColor3=Color3.fromRGB(255,255,255)
            b.BackgroundTransparency=0.85; b.BorderSizePixel=0; b.AutoButtonColor=false; b.Text=txt
            b.TextColor3=Color3.fromRGB(248,248,252); b.TextSize=txt=="▶" and 18 or 25; b.Font=Enum.Font.GothamBold; b.ZIndex=45
            b.Active=true; b.Parent=p.ContentHost; AddCorner(b,12); return b
        end
        local prev=btn("‹",2,48); local play=btn("▶",54,54); local nextB=btn("›",112,48); S.MusicPlayButton=play
        local title=Instance.new("TextLabel")
        title.Position=UDim2.fromOffset(172,4); title.Size=UDim2.new(1,-180,0,27); title.BackgroundTransparency=1; title.Text="大肥鱼 环绕音效"
        title.TextColor3=Color3.fromRGB(250,250,253); title.TextSize=13; title.Font=Enum.Font.GothamBold; title.TextXAlignment=Enum.TextXAlignment.Left
        title.TextTruncate=Enum.TextTruncate.AtEnd; title.ZIndex=40; title.Parent=p.ContentHost; S.MusicTitle=title
        local status=Instance.new("TextLabel")
        status.Position=UDim2.fromOffset(172,31); status.Size=UDim2.new(1,-180,0,21); status.BackgroundTransparency=1; status.Text="点 ▶ 播放 / 暂停 · 轻触右侧打开播放器"
        status.TextColor3=Color3.fromRGB(182,195,211); status.TextSize=10; status.Font=Enum.Font.GothamMedium; status.TextXAlignment=Enum.TextXAlignment.Left
        status.TextTruncate=Enum.TextTruncate.AtEnd; status.ZIndex=40; status.Parent=p.ContentHost; S.MusicStatus=status
        local open=Instance.new("TextButton")
        open.Position=UDim2.fromOffset(166,0); open.Size=UDim2.new(1,-166,1,0); open.BackgroundTransparency=1; open.BorderSizePixel=0
        open.Text=""; open.AutoButtonColor=false; open.Active=true; open.ZIndex=46; open.Parent=p.ContentHost
        wireButton(prev,function() if DBMusic and type(DBMusic.PreviousSpatialTrack)=="function" then DBMusic.PreviousSpatialTrack() end end)
        wireButton(play,function() if DBMusic and type(DBMusic.ToggleSpatialPlayback)=="function" then DBMusic.ToggleSpatialPlayback() end end)
        wireButton(nextB,function() if DBMusic and type(DBMusic.NextSpatialTrack)=="function" then DBMusic.NextSpatialTrack() end end)
        wireButton(open,function() if DBMusic and type(DBMusic.ShowAdvanced)=="function" then DBMusic.ShowAdvanced() end end)
        return p
    end

    local function makeMiniButton()
        local part=makePart("DB_AR133_MiniButton",2.04,0.52)
        local surface=Instance.new("SurfaceGui")
        surface.ResetOnSpawn=false
        surface.Name="DB_Spatial_V133_Mini"; surface.Adornee=part; surface.Face=Enum.NormalId.Front; surface.Active=true; surface.AlwaysOnTop=true
        surface.LightInfluence=0; surface.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize; surface.CanvasSize=Vector2.new(230,58); surface.ZOffset=0.04
        surface.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; surface.Enabled=false; surface.Parent=__dbPlayerGui
        local root=Instance.new("Frame")
        root.Size=UDim2.fromScale(1,1); root.BackgroundColor3=Color3.fromRGB(5,8,14); root.BackgroundTransparency=0.09; root.BorderSizePixel=0
        root.ClipsDescendants=true; root.Active=true; root.ZIndex=10; root.Parent=surface; AddCorner(root,999)
        local border=Instance.new("Frame")
        border.Position=UDim2.fromOffset(3,3); border.Size=UDim2.new(1,-6,1,-6); border.BackgroundTransparency=1; border.BorderSizePixel=0; border.ZIndex=30
        border.Parent=root; AddCorner(border,999)
        local miniStroke=Instance.new("UIStroke"); miniStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; miniStroke.Thickness=1.05
        miniStroke.Transparency=0.56; miniStroke.Color=Color3.fromRGB(214,222,235); miniStroke.LineJoinMode=Enum.LineJoinMode.Round; miniStroke.Parent=border
        local button=Instance.new("TextButton")
        button.Size=UDim2.fromScale(1,1); button.BackgroundTransparency=1; button.BorderSizePixel=0; button.Text="大肥鱼脚本  ·  展开空间面板"
        button.TextColor3=Color3.fromRGB(250,250,253); button.TextSize=13; button.Font=Enum.Font.GothamBlack; button.AutoButtonColor=false
        button.Active=true; button.ZIndex=35; button.Parent=root; wireButton(button,function() Controller.SetMinimized(false) end)
        local pack={Name="Mini",Part=part,Surface=surface,Root=root,Button=button,WidthStud=2.04,HeightStud=0.52}
        S.Surfaces.Mini=pack; S.Mini=pack; return pack
    end

    local function makeDeckCard(label,index,callback,isPlayer)
        local part=makePart("DB_AR133_Card_"..tostring(index),1.72,0.78)
        local surface=Instance.new("SurfaceGui")
        surface.ResetOnSpawn=false
        surface.Name="DB_Spatial_V133_Card_"..tostring(index); surface.Adornee=part; surface.Face=Enum.NormalId.Front; surface.Active=true
        surface.AlwaysOnTop=false; surface.LightInfluence=0; surface.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize; surface.CanvasSize=Vector2.new(190,86)
        surface.ZOffset=0.025; surface.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; surface.Parent=__dbPlayerGui
        local root=Instance.new("Frame")
        root.Size=UDim2.fromScale(1,1); root.BackgroundColor3=Color3.fromRGB(6,8,14); root.BackgroundTransparency=0.12; root.BorderSizePixel=0
        root.ClipsDescendants=true; root.ZIndex=10; root.Parent=surface; AddCorner(root,16)
        local border=Instance.new("Frame"); border.Position=UDim2.fromOffset(3,3); border.Size=UDim2.new(1,-6,1,-6); border.BackgroundTransparency=1; border.BorderSizePixel=0; border.ZIndex=30; border.Parent=root; AddCorner(border,14)
        local cardStroke=Instance.new("UIStroke"); cardStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; cardStroke.Thickness=1.0
        cardStroke.Transparency=0.57; cardStroke.Color=Color3.fromRGB(214,222,235); cardStroke.LineJoinMode=Enum.LineJoinMode.Round; cardStroke.Parent=border
        if isPlayer then
            local img=Instance.new("ImageLabel"); img.Position=UDim2.fromOffset(10,11); img.Size=UDim2.fromOffset(54,54); img.BackgroundColor3=Color3.fromRGB(255,255,255); img.BackgroundTransparency=0.88; img.BorderSizePixel=0; img.Image=(PlayerAvatar and PlayerAvatar.Image) or ""; img.ScaleType=Enum.ScaleType.Crop; img.ZIndex=20; img.Parent=root; AddCorner(img,12)
            local t=Instance.new("TextLabel"); t.Position=UDim2.fromOffset(72,9); t.Size=UDim2.new(1,-80,1,-18); t.BackgroundTransparency=1; t.Text="玩家信息\n"..tostring(LocalPlayer.DisplayName or LocalPlayer.Name); t.TextWrapped=true; t.TextColor3=Color3.fromRGB(250,250,253); t.TextSize=13; t.Font=Enum.Font.GothamBold; t.TextXAlignment=Enum.TextXAlignment.Left; t.TextYAlignment=Enum.TextYAlignment.Center; t.ZIndex=20; t.Parent=root
        else
            local t=Instance.new("TextLabel"); t.Position=UDim2.fromOffset(12,8); t.Size=UDim2.new(1,-24,1,-16); t.BackgroundTransparency=1; t.Text=label; t.TextColor3=Color3.fromRGB(250,250,253); t.TextSize=14; t.Font=Enum.Font.GothamBlack; t.TextWrapped=true; t.ZIndex=20; t.Parent=root
        end
        local hit=Instance.new("TextButton"); hit.Size=UDim2.fromScale(1,1); hit.BackgroundTransparency=1; hit.BorderSizePixel=0; hit.Text=""; hit.AutoButtonColor=false; hit.Active=true; hit.ZIndex=40; hit.Parent=root
        local pack={Name="Deck"..index,Part=part,Surface=surface,Root=root,Button=hit,WidthStud=1.72,HeightStud=0.78,Index=index,Label=label}
        S.Surfaces[pack.Name]=pack; table.insert(S.DeckCards,pack)
        wireButton(hit,function() S.DeckSelected=index; if callback then callback() end end)
        return pack
    end

    local function makeBars()
        S.Bars={}
        for i=1,BAR_COUNT do
            local b=Instance.new("Part")
            b.Name=string.format("DB_AR133_Wave_%02d",i); b.Anchored=true; b.CanCollide=false; b.CanTouch=false; b.CanQuery=false; b.CastShadow=false
            b.Material=Enum.Material.Neon; b.Size=Vector3.new(0.14,0.055,0.18); b.Transparency=0.10; b.Color=Color3.fromRGB(70,225,94); b.Parent=S.WorldFolder
            S.Bars[i]=b
        end
    end
    local function colorFor(level)
        level=clamp01(level)
        if level<0.24 then return Color3.fromRGB(78,218,86):Lerp(Color3.fromRGB(55,232,108),level/0.24) end
        if level<0.52 then return Color3.fromRGB(55,232,108):Lerp(Color3.fromRGB(26,225,162),(level-0.24)/0.28) end
        if level<0.78 then return Color3.fromRGB(26,225,162):Lerp(Color3.fromRGB(20,202,211),(level-0.52)/0.26) end
        return Color3.fromRGB(20,202,211):Lerp(Color3.fromRGB(41,78,238),(level-0.78)/0.22)
    end
    local function sampleLevel(levels,index,count)
        if type(levels)~="table" or #levels==0 then return 0 end
        local pos=1+((index-1)/math.max(1,count-1))*math.max(0,#levels-1); local a=math.floor(pos); local bb=math.min(#levels,a+1); local t=pos-a
        return clamp01((tonumber(levels[a]) or 0)+((tonumber(levels[bb]) or 0)-(tonumber(levels[a]) or 0))*t)
    end
    local function snapshot()
        local snap=nil
        if DBMusic and type(DBMusic.GetSpatialSnapshot)=="function" then local ok,r=pcall(DBMusic.GetSpatialSnapshot); if ok and type(r)=="table" then snap=r end end
        snap=snap or {Title="",Artist="",Platform="",Status="",Playing=false,Levels={},Rms=0}; S.LastSnapshot=snap
        if S.MusicTitle and S.MusicTitle.Parent then S.MusicTitle.Text=snap.Title~="" and (snap.Title..(snap.Artist~="" and (" · "..snap.Artist) or "")) or "大肥鱼 环绕音效" end
        if S.MusicStatus and S.MusicStatus.Parent then S.MusicStatus.Text=(snap.Platform~="" and (snap.Platform.." · ") or "")..(snap.Status~="" and snap.Status or "点 ▶ 播放 / 暂停") end
        if S.MusicPlayButton and S.MusicPlayButton.Parent then S.MusicPlayButton.Text=snap.Playing and "Ⅱ" or "▶" end
        return snap
    end

    local function updateBars(basis,openP,collapse,dt)
        S.SpectrumAccumulator=S.SpectrumAccumulator+dt; if S.SpectrumAccumulator<1/30 then return end
        S.SpectrumAccumulator=S.SpectrumAccumulator%(1/30)
        local snap=snapshot(); local levels=snap.Levels or {}; local maxLevel=0
        for i=1,#levels do local v=tonumber(levels[i]) or 0; if v>maxLevel then maxLevel=v end end
        local status=tostring(snap.Status or "")
        local active=(snap.Playing==true) or (tonumber(snap.Rms) or 0)>0.002 or maxLevel>0.006 or (status:find("播放",1,true)~=nil and status:find("暂停",1,true)==nil)
        local origin=basis.Position; local right=basis.RightVector; local up=basis.UpVector; local look=basis.LookVector
        local radius=5.40; local maxAngle=math.rad(72); local collapseFade=1-smooth(math.clamp((collapse-0.62)/0.38,0,1))
        local clock=os.clock(); local center=(BAR_COUNT+1)*0.5
        for i,b in ipairs(S.Bars) do
            if b and b.Parent then
                local t=(i-1)/math.max(1,BAR_COUNT-1); local theta=-maxAngle+(maxAngle*2)*t
                local level=sampleLevel(levels,i,BAR_COUNT)
                if active and maxLevel<0.003 then
                    local d=math.floor(math.abs(i-center)); local phase=clock-d*0.055
                    level=math.clamp(0.12+0.30*((math.sin(phase*5.0)+1)*0.5)+0.18*((math.sin(phase*9.2+0.8)+1)*0.5)+0.25*(math.max(0,math.sin(phase*6.2))^5),0.08,0.90)
                elseif not active then level=0 end
                local orbit=active and math.rad(math.sin(clock*1.55)*3.6) or 0
                local ripple=active and math.rad(math.sin(clock*5.2+(i-center)*0.44)*(0.45+level*2.35)) or 0
                local animatedTheta=theta+orbit+ripple
                local height=0.055+(level^0.84)*2.42
                local dir=look*math.cos(animatedTheta)+right*math.sin(animatedTheta)
                local radialPulse=active and (math.sin(clock*4.6+i*0.31)*0.035*level) or 0
                local base=origin+dir*(radius+radialPulse)-up*2.10
                local pos=base+up*(height*0.5)
                b.Size=Vector3.new(0.14+level*0.035,height,0.18+level*0.055)
                local roll=active and math.rad(math.sin(clock*7.4+i*0.63)*(1.8+level*7.2)) or 0
                local yaw=active and math.rad(math.sin(clock*4.1-i*0.37)*(0.8+level*3.8)) or 0
                b.CFrame=CFrame.lookAt(pos,origin+look*0.55-up*1.05,up)*CFrame.Angles(0,yaw,roll)
                b.Color=colorFor(level)
                b.Transparency=math.clamp((active and 0.06 or 0.70)+(1-openP)*0.14+(1-collapseFade)*0.90,0.04,0.97)
            end
        end
    end

    local function saveProfile(obj,props)
        if not obj or S.ProfileOriginal[obj] then return end
        local sv={}
        for _,prop in ipairs(props) do local ok,val=pcall(function() return obj[prop] end); if ok then sv[prop]=val end end
        S.ProfileOriginal[obj]=sv
    end
    local function restoreProfileLayout()
        for obj,sv in pairs(S.ProfileOriginal) do
            if obj and obj.Parent then for prop,val in pairs(sv) do pcall(function() obj[prop]=val end) end end
        end
        S.ProfileOriginal={}
    end
    local function applyProfileLayout()
        if not PlayerInfoCard or not PlayerInfoCard.Parent then return end
        saveProfile(PlayerInfoCard,{"Size","Position"})
        saveProfile(PlayerAvatar,{"Position","Size","ScaleType","Visible"})
        saveProfile(PlayerNameLabel,{"Position","Size","TextSize"})
        saveProfile(PlayerAgeLabel,{"Position","Size","TextSize"})
        saveProfile(PlayerUsernameLabel,{"Position","Size","TextSize"})
        if PlayerInfoTitle then saveProfile(PlayerInfoTitle,{"Position","Size","TextSize"}) end
        PlayerInfoCard.Size=UDim2.new(1,-10,0,188); PlayerInfoCard.Position=UDim2.fromOffset(5,4)
        if PlayerInfoTitle then PlayerInfoTitle.Position=UDim2.fromOffset(9,6); PlayerInfoTitle.Size=UDim2.new(1,-18,0,18); PlayerInfoTitle.TextSize=11 end
        PlayerAvatar.Visible=true; PlayerAvatar.Position=UDim2.fromOffset(10,30); PlayerAvatar.Size=UDim2.fromOffset(66,66); PlayerAvatar.ScaleType=Enum.ScaleType.Fit
        PlayerNameLabel.Position=UDim2.fromOffset(10,102); PlayerNameLabel.Size=UDim2.new(1,-20,0,26); PlayerNameLabel.TextSize=10
        PlayerAgeLabel.Position=UDim2.fromOffset(10,129); PlayerAgeLabel.Size=UDim2.new(1,-20,0,24); PlayerAgeLabel.TextSize=9
        PlayerUsernameLabel.Position=UDim2.fromOffset(10,154); PlayerUsernameLabel.Size=UDim2.new(1,-20,0,27); PlayerUsernameLabel.TextSize=9
        local viewport=PlayerInfoCard:FindFirstChild("Player3DViewport")
        if viewport then saveProfile(viewport,{"Position","Size","Visible"}); viewport.Visible=false end
        local sw=PlayerInfoCard:FindFirstChild("Player3DSwitch")
        if sw then saveProfile(sw,{"Position","Size","Visible"}); sw.Visible=false end
        local mixer=PlayerProfileScroll and PlayerProfileScroll:FindFirstChild("DB_Music_VolumeMixer")
        if mixer then saveProfile(mixer,{"Position","Size"}); mixer.Position=UDim2.fromOffset(5,196); mixer.Size=UDim2.new(1,-10,0,188) end
        if PlayerProfileScroll then saveProfile(PlayerProfileScroll,{"CanvasSize"}); PlayerProfileScroll.CanvasSize=UDim2.fromOffset(0,394) end
    end

    local function attach(obj,pack)
        if not obj or not pack then return end
        remember(obj); obj.Parent=pack.ContentHost; obj.AnchorPoint=Vector2.new(0,0); obj.Position=UDim2.fromScale(0,0); obj.Size=UDim2.fromScale(1,1)
        obj.Visible=true; obj.ClipsDescendants=true
        for _,d in ipairs(obj:GetDescendants()) do
            if d:IsA("GuiButton") then d.Active=true end
            if d:IsA("ScrollingFrame") then d.Active=true; d.ScrollingEnabled=true end
        end
    end
    local function restoreRails() restore(PlayerProfileRail); restore(RightList); restore(LeftMenu); restoreProfileLayout() end
    local function getBlur()
        local blur=Lighting:FindFirstChild("DB_SpatialTransitionBlur_V133")
        if not blur then blur=Instance.new("BlurEffect"); blur.Name="DB_SpatialTransitionBlur_V133"; blur.Size=0; blur.Parent=Lighting; S.BlurOwned=true end
        S.Blur=blur; return blur
    end
    local function setBlur(amount) local blur=S.Blur or getBlur(); if blur then pcall(function() blur.Size=math.clamp(amount or 0,0,14) end) end end

    local function build()
        removeStale(); local folder=Instance.new("Folder"); folder.Name=FOLDER_NAME; folder.Parent=workspace; S.WorldFolder=folder
        local center=makeSurface("Center",5.92,4.22,590,422,"功能卡片 · 主页")
        local music=makeMusicStrip(); makeMiniButton(); S.CenterTitle=center.Title
        local back=Instance.new("TextButton")
        back.AnchorPoint=Vector2.new(1,0.5); back.Position=UDim2.new(1,-5,0.5,0); back.Size=UDim2.fromOffset(61,22); back.BackgroundColor3=Color3.fromRGB(255,255,255); back.BackgroundTransparency=0.84; back.BorderSizePixel=0; back.Text="返回2D"; back.TextColor3=Color3.fromRGB(248,248,252); back.TextSize=10; back.Font=Enum.Font.GothamBold; back.AutoButtonColor=false; back.Active=true; back.ZIndex=62; back.Parent=center.Header; AddCorner(back,999); wireButton(back,function() Controller.SetEnabled(false) end)
        local minBtn=Instance.new("TextButton")
        minBtn.AnchorPoint=Vector2.new(1,0.5); minBtn.Position=UDim2.new(1,-72,0.5,0); minBtn.Size=UDim2.fromOffset(27,22); minBtn.BackgroundColor3=Color3.fromRGB(255,255,255); minBtn.BackgroundTransparency=0.84; minBtn.BorderSizePixel=0; minBtn.Text="−"; minBtn.TextColor3=Color3.fromRGB(248,248,252); minBtn.TextSize=18; minBtn.Font=Enum.Font.GothamBold; minBtn.AutoButtonColor=false; minBtn.Active=true; minBtn.ZIndex=64; minBtn.Parent=center.Header; AddCorner(minBtn,999); wireButton(minBtn,function() Controller.SetMinimized(true) end)
        center.Title.Size=UDim2.new(1,-112,1,0)
        remember(RightList); remember(PlayerProfileRail)
        RightList.Parent=center.ContentHost; RightList.AnchorPoint=Vector2.new(0,0); RightList.Position=UDim2.fromScale(0,0); RightList.Size=UDim2.fromScale(1,1); RightList.Visible=true; RightList.ClipsDescendants=true
        PlayerProfileRail.Parent=center.ContentHost; PlayerProfileRail.AnchorPoint=Vector2.new(0,0); PlayerProfileRail.Position=UDim2.fromScale(0,0); PlayerProfileRail.Size=UDim2.fromScale(1,1); PlayerProfileRail.Visible=false; PlayerProfileRail.ClipsDescendants=true
        local function showDetail(title,fn)
            PlayerProfileRail.Visible=false; RightList.Visible=true; if fn then pcall(fn) end; if center.Title then center.Title.Text="功能卡片 · "..title end
        end
        local function showPlayer()
            RightList.Visible=false; PlayerProfileRail.Visible=true; if center.Title then center.Title.Text="功能卡片 · 玩家信息" end
        end
        S.DeckCards={}; S.DeckSelected=1
        makeDeckCard("玩家信息",1,showPlayer,true)
        makeDeckCard("主页",2,function() showDetail("主页",ShowHomePage) end)
        makeDeckCard("玩家面板",3,function() showDetail("玩家面板",ShowPlayerControlPanel) end)
        makeDeckCard("大肥鱼通用",4,function() showDetail("大肥鱼通用",function() State.CurrentCategory="大肥鱼通用"; RenderRightList("大肥鱼通用") end) end)
        makeDeckCard("通用",5,function() showDetail("通用",function() State.CurrentCategory="通用"; RenderRightList("通用") end) end)
        makeDeckCard("公告",6,function() showDetail("公告",function() DBAnnouncementUI.Show() end) end)
        makeDeckCard("脚本合集",7,function() showDetail("脚本合集",function() ScriptCollectionUI.Show() end) end)
        makeDeckCard("UI界面",8,function() showDetail("UI界面",function() DBUIInterfaceUI.Show() end) end)
        makeDeckCard("音乐播放器",9,function() showDetail("音乐播放器",function() DBMusic.Show() end) end)
        makeDeckCard("设置",10,function() showDetail("设置",function() DBSettingsUI.Show() end) end)
        showPlayer(); makeBars(); getBlur(); setBlur(0)
        return nil,center,nil,music
    end
    local function destroyWorld()
        for _,p in pairs(S.Surfaces) do if p.Surface then destroy(p.Surface) end end
        S.Surfaces={}; S.Mini=nil; destroy(S.WorldFolder); S.WorldFolder=nil; S.Bars={}; S.MusicTitle=nil; S.MusicStatus=nil; S.MusicPlayButton=nil; S.CenterTitle=nil
        setBlur(0); if S.BlurOwned and S.Blur then destroy(S.Blur) end; S.Blur=nil; S.BlurOwned=false
    end
    local function finalize()
        if DBSpatial and type(Controller.DetachAdvancedMusic)=="function" then pcall(Controller.DetachAdvancedMusic) end
        restoreRails(); destroyWorld(); S.Enabled=false; S.Closing=false; S.Progress=0; S.Velocity=0; S.LookVector=nil; S.UpVector=nil
        S.Minimized=false; S.MinimizeTarget=0; S.MinimizeProgress=0; S.MinimizeVelocity=0
        DBVisualSettings.SpatialModeEnabled=false; Controller.Enabled=false
        State.Minimized=S.PreviousMinimized==true; Panel.Visible=S.PreviousPanelVisible==true; FloatingButton.Visible=S.PreviousFloatingVisible==true
        if State.Minimized then Panel.Visible=false; FloatingButton.Visible=true elseif not Panel.Visible then Panel.Visible=true end
        DBStartupScale.Scale=1; State.Animating=false
        if S.RenderConnection then pcall(function() S.RenderConnection:Disconnect() end); S.RenderConnection=nil end
    end

    local function cameraBasis(cam,dt)
        local currentLook=cam.CFrame.LookVector; local currentUp=cam.CFrame.UpVector
        if not S.LookVector then S.LookVector=currentLook; S.UpVector=currentUp end
        if S.LookVector:Dot(currentLook)<0.48 then S.LookVector=currentLook; S.UpVector=currentUp
        else
            local a=1-math.exp(-dt*12.5); S.LookVector=(S.LookVector:Lerp(currentLook,a)).Unit; S.UpVector=(S.UpVector:Lerp(currentUp,a)).Unit
        end
        return CFrame.lookAt(cam.CFrame.Position,cam.CFrame.Position+S.LookVector,S.UpVector)
    end
    local function setMainSurfaceEnabled(enabled)
        for name,p in pairs(S.Surfaces) do if name~="Mini" and p.Surface then p.Surface.Enabled=enabled end end
    end

    UserInputService.InputBegan:Connect(function(input)
        if not S.Enabled or input.UserInputType~=Enum.UserInputType.Touch then return end
        local cam=workspace.CurrentCamera; local vp=cam and cam.ViewportSize; if not vp then return end
        if input.Position.X <= vp.X*0.36 and input.Position.Y >= vp.Y*0.53 then S.JoystickInputs[input]=true; S.JoystickTouch=true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if S.JoystickInputs[input] then S.JoystickInputs[input]=nil; S.JoystickTouch=next(S.JoystickInputs)~=nil end
    end)

    local function update(dt)
        if not S.Enabled then return end
        local cam=workspace.CurrentCamera; if not cam then return end
        local target=S.Closing and 0 or 1; local accel=(target-S.Progress)*(S.Closing and 74 or 86)-S.Velocity*19
        S.Velocity=S.Velocity+accel*dt; S.Progress=math.clamp(S.Progress+S.Velocity*dt,-0.02,1.03)
        local p=clamp01(S.Progress); local openP=easeOut(p)
        local mTarget=clamp01(S.MinimizeTarget); local mAccel=(mTarget-S.MinimizeProgress)*90-S.MinimizeVelocity*19
        S.MinimizeVelocity=S.MinimizeVelocity+mAccel*dt; S.MinimizeProgress=math.clamp(S.MinimizeProgress+S.MinimizeVelocity*dt,-0.025,1.025)
        if math.abs(mTarget-S.MinimizeProgress)<0.002 and math.abs(S.MinimizeVelocity)<0.028 then S.MinimizeProgress=mTarget; S.MinimizeVelocity=0 end
        local collapse=clamp01(S.MinimizeProgress)

        local basis=cameraBasis(cam,dt); local origin=basis.Position; local right=basis.RightVector; local up=basis.UpVector; local look=basis.LookVector
        local hover=math.sin(os.clock()*1.05)*0.014*(1-collapse); origin=origin+up*(0.30+hover)
        local center=S.Surfaces.Center; local left=S.Surfaces.Left; local rightP=S.Surfaces.Right; local music=S.Surfaces.MusicStrip; local mini=S.Mini

        local focus=origin+look*0.72+up*0.22
        local centerBase=origin+look*(4.48-(1-openP)*0.28)-up*0.20
        local musicBase=origin+look*4.44+up*(2.82-(1-openP)*0.22)
        local a=smooth(math.clamp(collapse/0.50,0,1)); local c=smooth(math.clamp((collapse-0.70)/0.30,0,1))
        local merge=centerBase+up*0.42+look*0.04
        local finalY=math.max(0.045,1-0.955*c); local finalX=1-0.18*c
        if center and center.Part then
            center.Part.CFrame=CFrame.lookAt(centerBase,focus,up); center.Part.Size=Vector3.new(center.WidthStud*finalX,center.HeightStud*finalY,0.03)
        end
        local selected=math.clamp(tonumber(S.DeckSelected) or 1,1,math.max(1,#S.DeckCards))
        local follow=1-math.exp(-dt*14.5)
        for i,pack in ipairs(S.DeckCards) do
            if pack and pack.Part then
                local rel=i-selected; local absRel=math.abs(rel); local visible=absRel<=4
                local x=rel*1.08; local z=3.82+absRel*0.16; local y=2.18-absRel*0.035
                local pos=origin+look*z+right*x+up*y
                local scale=math.max(0.62,1-absRel*0.095)
                if absRel==0 then pos=pos-look*0.18; scale=1.05 end
                pos=pos:Lerp(merge+right*(rel*0.035)+up*0.30,a)
                scale=scale*(1-0.08*a)*finalX
                local targetCf=CFrame.lookAt(pos,focus+up*0.40,up)*CFrame.Angles(0,0,math.rad(-rel*1.8))
                pack.MotionCFrame=pack.MotionCFrame or targetCf; pack.MotionScale=pack.MotionScale or scale
                pack.MotionCFrame=pack.MotionCFrame:Lerp(targetCf,follow); pack.MotionScale=pack.MotionScale+(scale-pack.MotionScale)*follow
                pack.Part.CFrame=pack.MotionCFrame; pack.Part.Size=Vector3.new(pack.WidthStud*pack.MotionScale,pack.HeightStud*finalY,0.03)
                pack.Surface.Enabled=visible and collapse<0.988; pack.Surface.AlwaysOnTop=(absRel==0)
                pack.Root.BackgroundTransparency=(absRel==0) and 0.06 or math.min(0.38,0.13+absRel*0.055)
            end
        end
        if music and music.Part then
            local musicPos=musicBase:Lerp(merge+up*1.44,a); music.Part.CFrame=CFrame.lookAt(musicPos,focus,up)
            local widthScale=(1-0.18*a)*(1-0.10*c); local heightScale=math.max(0.08,1-0.90*c)
            music.Part.Size=Vector3.new(music.WidthStud*widthScale,music.HeightStud*heightScale,0.03)
        end

        local frostLevel=math.clamp((collapse-0.62)/0.31,0,1)
        for name,pack in pairs(S.Surfaces) do if name~="Mini" and pack.Frost then pack.Frost.BackgroundTransparency=1-frostLevel*0.27 end end
        local blurPhase=0
        if collapse>0.62 and collapse<0.995 then blurPhase=math.sin(math.clamp((collapse-0.62)/0.375,0,1)*math.pi) end
        setBlur(10.5*blurPhase)
        setMainSurfaceEnabled(collapse<0.988 and p>0.02)

        if mini and mini.Part and mini.Surface then
            local miniP=smooth(math.clamp((collapse-0.855)/0.145,0,1))
            local miniPos=origin+look*4.36+up*2.40
            mini.Part.CFrame=CFrame.lookAt(miniPos,origin+look*0.50+up*0.35,up)
            mini.Part.Size=Vector3.new(mini.WidthStud*math.max(0.055,miniP),mini.HeightStud*math.max(0.07,miniP),0.03)
            mini.Surface.Enabled=miniP>0.035 and p>0.02
        end

        updateBars(basis,openP,collapse,dt)
        if left and left.Surface then
            local moving=false; local char=LocalPlayer.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
            if hum then moving=hum.MoveDirection.Magnitude>0.025 end
            left.Surface.Active=(not moving) and (not S.JoystickTouch) and collapse<0.96
            left.Part.CanQuery=(not moving) and (not S.JoystickTouch) and collapse<0.96
        end
        if S.Closing and p<0.012 and math.abs(S.Velocity)<0.14 then task.defer(finalize) end
    end

    function Controller.IsEnabled() return S.Enabled and not S.Closing end
    function Controller.IsActive() return S.Enabled==true end
    function Controller.IsMinimized() return S.Enabled and S.MinimizeTarget>0.5 end
    function Controller.GetLastError() return S.LastError end
    function Controller.SetMinimized(minimized)
        if not S.Enabled or S.Closing then return end
        S.Minimized=minimized==true; S.MinimizeTarget=S.Minimized and 1 or 0; State.Minimized=S.Minimized; State.Animating=true
        if not S.Minimized then setMainSurfaceEnabled(true) end
        task.delay(0.75,function() if S.Enabled and not S.Closing and math.abs(S.MinimizeProgress-S.MinimizeTarget)<0.02 then State.Animating=false end end)
    end
    function Controller.ToggleMinimized() Controller.SetMinimized(not Controller.IsMinimized()) end
    function Controller.AttachAdvancedMusic(root)
        if not S.Enabled or S.Closing or S.MinimizeTarget>0.5 or not root then return false end
        local center=S.Surfaces.Center; if not center or not center.ContentHost then return false end
        if S.AdvancedRoot==root and root.Parent==center.ContentHost then return true end
        Controller.DetachAdvancedMusic(); S.AdvancedRoot=root
        S.AdvancedOriginal={Parent=root.Parent,Position=root.Position,Size=root.Size,AnchorPoint=root.AnchorPoint,Visible=root.Visible}
        if RightList and RightList.Parent then RightList.Visible=false end
        root.Parent=center.ContentHost; root.AnchorPoint=Vector2.new(0,0); root.Position=UDim2.fromScale(0,0); root.Size=UDim2.fromScale(1,1); root.Visible=true
        return true
    end
    function Controller.DetachAdvancedMusic()
        local root,sv=S.AdvancedRoot,S.AdvancedOriginal
        if root and sv then pcall(function() root.Parent=sv.Parent or Panel; root.Position=sv.Position; root.Size=sv.Size; root.AnchorPoint=sv.AnchorPoint; root.Visible=sv.Visible==true end) end
        S.AdvancedRoot=nil; S.AdvancedOriginal=nil; if RightList and RightList.Parent then RightList.Visible=true end
    end
    function Controller.SetEnabled(enabled)
        enabled=enabled==true
        if enabled then
            if S.Enabled then S.Closing=false; DBVisualSettings.SpatialModeEnabled=true; Controller.Enabled=true; if S.MinimizeTarget>0.5 then Controller.SetMinimized(false) end; return end
            S.PreviousPanelVisible=Panel.Visible; S.PreviousFloatingVisible=FloatingButton.Visible; S.PreviousMinimized=State.Minimized
            AppleTransition.Running=false; AppleTransition.Velocity=0; AppleTransition.ClearSoftFocus(); State.Animating=true; DBStartupScale.Scale=1
            local ok,err=pcall(build)
            if not ok then
                S.LastError=tostring(err); warn("[大肥鱼 V133] 空间模式构建失败: ",err); restoreRails(); destroyWorld(); State.Animating=false
                DBVisualSettings.SpatialModeEnabled=false; Controller.Enabled=false; return
            end
            Panel.Visible=false; FloatingButton.Visible=false; S.Enabled=true; S.Closing=false; S.Progress=0.04; S.Velocity=0
            S.LookVector=nil; S.UpVector=nil; S.Minimized=false; S.MinimizeTarget=0; S.MinimizeProgress=0; S.MinimizeVelocity=0
            DBVisualSettings.SpatialModeEnabled=true; Controller.Enabled=true; S.LastError=nil
            if S.RenderConnection then pcall(function() S.RenderConnection:Disconnect() end) end
            S.RenderConnection=RunService.RenderStepped:Connect(function(dt)
                dt=math.min(dt,1/30)
                local okUpdate,errUpdate=pcall(update,dt)
                if not okUpdate then
                    S.LastError=tostring(errUpdate); warn("[大肥鱼 V133] 空间更新错误: ",errUpdate)
                    for _,pack in pairs(S.Surfaces) do if pack.Part then pack.Part.Transparency=1 end end
                end
            end)
        else
            if not S.Enabled then return end
            S.Closing=true; S.MinimizeTarget=0; setBlur(0); setMainSurfaceEnabled(true)
            DBVisualSettings.SpatialModeEnabled=false; Controller.Enabled=false
        end
    end
    function Controller.Destroy(force)
        if S.RenderConnection then pcall(function() S.RenderConnection:Disconnect() end); S.RenderConnection=nil end
        if S.Enabled or S.WorldFolder then finalize() else removeStale() end
    end

end
    return Controller
end

local DBSpatialStyleControllers = {
    ["默认"] = DBCreateSpatialController_130("默认"),
    ["中宽两窄"] = DBCreateSpatialController_130("中宽两窄"),
}
local DBSpatialCurrentStyle = nil
local DBSpatialCurrentController = nil

local function DBNormalizeSpatialStyle(style)
    style = tostring(style or "")
    if style=="两小一大" or style=="三大" or style=="电脑屏" or style=="多任务" then style="默认" end
    if DBSpatialStyleControllers[style] then return style end
    return "默认"
end

local function DBGetSpatialController()
    if DBSpatialCurrentController then return DBSpatialCurrentController end
    local style = DBNormalizeSpatialStyle(DBVisualSettings.SpatialStyle)
    DBSpatialCurrentStyle = style
    DBSpatialCurrentController = DBSpatialStyleControllers[style]
    DBVisualSettings.SpatialStyle = style
    return DBSpatialCurrentController
end

function DBSpatial.GetStyle()
    return DBSpatialCurrentStyle or DBNormalizeSpatialStyle(DBVisualSettings.SpatialStyle)
end
function DBSpatial.RefreshPanelAppearance()
    local ctrl=DBGetSpatialController()
    if ctrl and type(ctrl.RefreshPanelAppearance)=="function" then
        local ok,result=pcall(ctrl.RefreshPanelAppearance)
        return ok and result~=false
    end
    return false
end

function DBSpatial.SetStyle(style)
    style = DBNormalizeSpatialStyle(style)
    local old = DBGetSpatialController()
    if DBSpatialCurrentStyle == style and old then
        DBVisualSettings.SpatialStyle = style
        return true
    end

    local wasActive = false
    local wasMinimized = false
    if old then
        if type(old.IsActive) == "function" then pcall(function() wasActive = old.IsActive() == true end) end
        if type(old.IsMinimized) == "function" then pcall(function() wasMinimized = old.IsMinimized() == true end) end
        if type(old.Destroy) == "function" then pcall(function() old.Destroy(true) end) end
    end

    DBSpatialCurrentStyle = style
    DBSpatialCurrentController = DBSpatialStyleControllers[style]
    DBVisualSettings.SpatialStyle = style
    DBSpatial.Enabled = false

    if wasActive and DBSpatialCurrentController and type(DBSpatialCurrentController.SetEnabled) == "function" then
        pcall(function() DBSpatialCurrentController.SetEnabled(true) end)
        if wasMinimized and type(DBSpatialCurrentController.SetMinimized) == "function" then
            task.delay(0.12,function()
                if DBSpatialCurrentController and type(DBSpatialCurrentController.SetMinimized)=="function" then
                    pcall(function() DBSpatialCurrentController.SetMinimized(true) end)
                end
            end)
        end
    end
    DBSpatial.Enabled = wasActive
    return true
end

function DBSpatial.IsEnabled()
    local c=DBGetSpatialController(); return c and type(c.IsEnabled)=="function" and c.IsEnabled() or false
end
function DBSpatial.IsActive()
    local c=DBGetSpatialController(); return c and type(c.IsActive)=="function" and c.IsActive() or false
end
function DBSpatial.IsMinimized()
    local c=DBGetSpatialController(); return c and type(c.IsMinimized)=="function" and c.IsMinimized() or false
end
function DBSpatial.GetLastError()
    local c=DBGetSpatialController(); return c and type(c.GetLastError)=="function" and c.GetLastError() or nil
end
function DBSpatial.SetEnabled(enabled)
    local c=DBGetSpatialController(); if not c or type(c.SetEnabled)~="function" then return end
    c.SetEnabled(enabled==true); DBSpatial.Enabled = enabled==true and DBSpatial.IsActive()
end
function DBSpatial.SetMinimized(minimized)
    local c=DBGetSpatialController(); if c and type(c.SetMinimized)=="function" then return c.SetMinimized(minimized) end
end
function DBSpatial.ToggleMinimized()
    local c=DBGetSpatialController(); if c and type(c.ToggleMinimized)=="function" then return c.ToggleMinimized() end
end
function DBSpatial.AttachAdvancedMusic(root)
    local c=DBGetSpatialController(); if c and type(c.AttachAdvancedMusic)=="function" then return c.AttachAdvancedMusic(root) end
    return false
end
function DBSpatial.DetachAdvancedMusic()
    local c=DBGetSpatialController(); if c and type(c.DetachAdvancedMusic)=="function" then return c.DetachAdvancedMusic() end
end
function DBSpatial.RefreshVisualStyle()
    local c=DBGetSpatialController(); if c and type(c.RefreshVisualStyle)=="function" then return c.RefreshVisualStyle() end
end
function DBSpatial.IsWorldAnchored()
    local c=DBGetSpatialController(); return c and type(c.IsWorldAnchored)=="function" and c.IsWorldAnchored() or false
end
function DBSpatial.SetWorldAnchored(v)
    local c=DBGetSpatialController(); if c and type(c.SetWorldAnchored)=="function" then return c.SetWorldAnchored(v==true) end
end
function DBSpatial.ToggleWorldAnchored()
    local c=DBGetSpatialController(); if c and type(c.ToggleWorldAnchored)=="function" then return c.ToggleWorldAnchored() end
end
function DBSpatial.GetAnchorAdjustment()
    local c=DBGetSpatialController()
    if c and type(c.GetAnchorAdjustment)=="function" then return c.GetAnchorAdjustment() end
    return tonumber(DBVisualSettings.SpatialAnchorOffsetX) or 0, tonumber(DBVisualSettings.SpatialAnchorOffsetY) or 0
end
function DBSpatial.SetAnchorAdjustment(x,y)
    local c=DBGetSpatialController()
    if c and type(c.SetAnchorAdjustment)=="function" then return c.SetAnchorAdjustment(x,y) end
    DBVisualSettings.SpatialAnchorOffsetX=math.clamp(tonumber(x) or 0,-4.0,4.0)
    DBVisualSettings.SpatialAnchorOffsetY=math.clamp(tonumber(y) or 0,-3.0,3.0)
    return DBVisualSettings.SpatialAnchorOffsetX,DBVisualSettings.SpatialAnchorOffsetY
end
function DBSpatial.Destroy(force)
    local c=DBGetSpatialController(); if c and type(c.Destroy)=="function" then c.Destroy(force) end
    DBSpatial.Enabled=false
end

local DBSpatialRespawnToken=0
local DBSpatialHealthMeta={
    ["默认"]={Folder="DB_SpatialHUD_V130",Prefix="DB_Spatial_V130_",Min=4},
    ["中宽两窄"]={Folder="DB_SpatialHUD_V130",Prefix="DB_Spatial_V130_",Min=4},
}
local function DBSpatialSurfacesHealthy(style)
    local meta=DBSpatialHealthMeta[style]; if not meta then return false end
    local folder=workspace:FindFirstChild(meta.Folder)
    if not folder or not __dbPlayerGui or not workspace.CurrentCamera then return false end
    local count=0
    for _,child in ipairs(__dbPlayerGui:GetChildren()) do
        if child:IsA("SurfaceGui") and child.Name:sub(1,#meta.Prefix)==meta.Prefix and child.Parent then
            local adornee=child.Adornee
            if adornee and adornee:IsA("BasePart") and adornee.Parent==folder then count=count+1 end
        end
    end
    return count>=meta.Min
end
local function DBSpatialRebuildOnce(style,wasMinimized,token)
    local c=DBGetSpatialController()
    if c and type(c.Destroy)=="function" then pcall(function() c.Destroy(true) end) end
    task.wait(0.10)
    if token~=DBSpatialRespawnToken then return false end
    DBSpatialCurrentStyle=style
    DBSpatialCurrentController=DBSpatialStyleControllers[style]
    DBVisualSettings.SpatialStyle=style
    DBVisualSettings.SpatialModeEnabled=true
    if DBSpatial and type(DBSpatial.SetEnabled)=="function" then pcall(function() DBSpatial.SetEnabled(true) end) end
    task.wait(0.16)
    if token~=DBSpatialRespawnToken then return false end
    local healthy=DBSpatialSurfacesHealthy(style) and DBSpatial.IsActive()
    if healthy and wasMinimized and DBSpatial and type(DBSpatial.SetMinimized)=="function" then
        task.delay(0.10,function()
            if token==DBSpatialRespawnToken and DBSpatial.IsActive() then pcall(function() DBSpatial.SetMinimized(true) end) end
        end)
    end
    return healthy
end
local function DBRecoverSpatialAfterRespawn(character)
    DBSpatialRespawnToken=DBSpatialRespawnToken+1
    local token=DBSpatialRespawnToken
    task.spawn(function()
        if character then
            pcall(function() character:WaitForChild("Humanoid",5) end)
            pcall(function() character:WaitForChild("HumanoidRootPart",5) end)
        end
        task.wait(0.62)
        if token~=DBSpatialRespawnToken then return end
        local wanted=(DBVisualSettings.SpatialModeEnabled==true) or (DBSpatial and type(DBSpatial.IsActive)=="function" and DBSpatial.IsActive())
        if not wanted then return end
        local style=DBNormalizeSpatialStyle(DBVisualSettings.SpatialStyle)
        local wasMinimized=DBSpatial and type(DBSpatial.IsMinimized)=="function" and DBSpatial.IsMinimized() or false
        for attempt=1,3 do
            if token~=DBSpatialRespawnToken then return end
            if DBSpatialSurfacesHealthy(style) and DBSpatial.IsActive() then
                Panel.Visible=false; FloatingButton.Visible=false
                return
            end
            local ok=DBSpatialRebuildOnce(style,wasMinimized,token)
            if ok then
                Panel.Visible=false; FloatingButton.Visible=false
                return
            end
            task.wait(0.28+attempt*0.12)
        end
        DBVisualSettings.SpatialModeEnabled=true
    end)
end
LocalPlayer.CharacterAdded:Connect(function(character)
    DBRecoverSpatialAfterRespawn(character)
end)

DBSpatial.SetStyle(DBVisualSettings.SpatialStyle or "默认")
task.delay(1.0,function()
    if DBVisualSettings.SpatialModeEnabled and DBSpatial and type(DBSpatial.SetEnabled)=="function" and not DBSpatial.IsActive() then
        local okEnable, errEnable = pcall(function() DBSpatial.SetEnabled(true) end)
        if (not okEnable) or (not DBSpatial.IsActive()) then
            if not okEnable then warn("[大肥鱼 V139] 自动进入空间模式失败，保留2D: ", errEnable) end
            DBVisualSettings.SpatialModeEnabled=false
            Panel.Visible=true; FloatingButton.Visible=false; State.Minimized=false; State.Animating=false
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if not AppleTransition.Running then return end
    dt = math.min(dt, 1 / 30)

    local stiffness = 135
    local damping = 19
    local displacement = AppleTransition.Target - AppleTransition.Progress
    local acceleration = displacement * stiffness - AppleTransition.Velocity * damping
    AppleTransition.Velocity = AppleTransition.Velocity + acceleration * dt
    AppleTransition.Progress = AppleTransition.Progress + AppleTransition.Velocity * dt

    AppleTransition.Progress = math.clamp(AppleTransition.Progress, -0.018, 1.028)

    local collapseCutoff = 0.13
    if GetTransitionStyle() ~= "老式款"
        and AppleTransition.Target == 0
        and AppleTransition.Velocity <= 0
        and AppleTransition.Progress <= collapseCutoff
    then
        AppleTransition.Progress = 0
        AppleTransition.Velocity = 0
        AppleTransition.Running = false

        AppleTransition.ClearSoftFocus()
        Panel.Visible = false
        Panel.AnchorPoint = Vector2.new(0.5, 0.5)
        Panel.Position = UDim2.fromOffset(AppleTransition.PanelTarget.X, AppleTransition.PanelTarget.Y)
        DBStartupScale.Scale = 1

        FloatingButton.Visible = false
        State.Minimized = true
        State.ButtonHidden = false
        State.HideSide = "none"

        RevealFloatingButton()
        return
    end

    ApplyAppleTransition()

    local nearTarget = math.abs(AppleTransition.Target - AppleTransition.Progress) < 0.0022
    local slowEnough = math.abs(AppleTransition.Velocity) < 0.024
    if nearTarget and slowEnough then
        AppleTransition.Progress = AppleTransition.Target
        AppleTransition.Velocity = 0
        AppleTransition.Running = false
        ApplyAppleTransition()

        if AppleTransition.Target == 0 then
            AppleTransition.ClearSoftFocus()
            Panel.Visible = false
            Panel.AnchorPoint = Vector2.new(0.5, 0.5)
            Panel.Position = UDim2.fromOffset(AppleTransition.PanelTarget.X, AppleTransition.PanelTarget.Y)
            DBStartupScale.Scale = 1
            State.Minimized = true
            State.ButtonHidden = false
            State.HideSide = "none"

            if GetTransitionStyle() == "老式款" then
                FloatingButton.Position = UDim2.fromOffset(AppleTransition.ButtonTarget.X, AppleTransition.ButtonTarget.Y)
                FloatingButton.Size = UDim2.fromOffset(FLOATING_WIDTH, FLOATING_HEIGHT)
                FloatingButton.Visible = true
                FloatingTransitionScale.Scale = 1
                State.Animating = false
            else
                FloatingButton.Visible = false
                if AppleTransition.Target == 0 and not AppleTransition.Running and State.Minimized then
                    RevealFloatingButton()
                end
            end
        else
            AppleTransition.ClearSoftFocus()
            Panel.AnchorPoint = Vector2.new(0.5, 0.5)
            Panel.Position = UDim2.fromOffset(AppleTransition.PanelTarget.X, AppleTransition.PanelTarget.Y)
            DBStartupScale.Scale = 1
            Panel.Visible = true
            FloatingButton.Visible = false
            FloatingButton.Size = UDim2.fromOffset(FLOATING_WIDTH, FLOATING_HEIGHT)
            FloatingTransitionScale.Scale = 1
            State.Minimized = false
            CancelButtonMorph(true)
            State.Animating = false
        end
        if AppleTransition.Target ~= 0 then
            State.Animating = false
        end
    end
end)

local function EnableDrag(handle, getPos, setPos)
local dragging = false
local startInput, startObj, touchInput
local beganPos = nil
handle.InputBegan:Connect(function(inp)
if State.Animating then return end
if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
dragging = true
startInput = inp.Position
startObj = getPos()
beganPos = inp.Position
if inp.UserInputType == Enum.UserInputType.Touch then touchInput = inp end
end
end)
UserInputService.InputChanged:Connect(function(inp)
if not dragging then return end
if inp.UserInputType == Enum.UserInputType.MouseMovement then
if not startInput then return end
setPos(startObj + (inp.Position - startInput))
elseif inp.UserInputType == Enum.UserInputType.Touch and inp == touchInput then
setPos(startObj + (inp.Position - startInput))
end
end)
UserInputService.InputEnded:Connect(function(inp)
if inp.UserInputType == Enum.UserInputType.MouseButton1 or (inp.UserInputType == Enum.UserInputType.Touch and inp == touchInput) then
dragging = false
startInput = nil; startObj = nil; touchInput = nil
beganPos = nil
end
end)
end
DBV139 = {}
function DBV139.InputXY(input)
return Vector2.new(input.Position.X, input.Position.Y)
end
DBV139.moveDragging = false
DBV139.moveStartPointer = nil
DBV139.moveStartPanelPos = nil
DBV139.moveTouchInput = nil
function DBV139.SetMoveBarMagic(active)
if active then
TweenService:Create(MoveBar, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(250,250,252), BackgroundTransparency = 0}):Play()
else
TweenService:Create(MoveBar, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(150,150,156), BackgroundTransparency = 0.04}):Play()
end
end
DBV139.activePanelGesture = nil
DBV139.resizing = false
DBV139.resizeArmed = false
DBV139.resizeStartPointer = nil
DBV139.resizeStartSize = nil
DBV139.resizeStartPosition = nil
DBV139.resizeTouchInput = nil
function DBV139.SetResizeMagic(active)
local targetColor = active and Color3.fromRGB(250,250,252) or Color3.fromRGB(150,150,156)
local targetTransparency = active and 0 or 0.04
TweenService:Create(
ResizeArcVisual,
TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
{TextColor3 = targetColor, TextTransparency = targetTransparency}
):Play()
end
MoveBarHitArea.InputBegan:Connect(function(input)
if State.Animating
or State.Minimized
or DBV139.activePanelGesture ~= nil then
return
end
if input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch then
DBV139.activePanelGesture = "move"
ResizeHandle.Active = false
DBV139.resizing = false
DBV139.resizeArmed = false
DBV139.resizeTouchInput = nil
DBV139.moveDragging = true
DBV139.moveStartPointer = DBV139.InputXY(input)
DBV139.moveStartPanelPos = State.PanelPosition
if input.UserInputType == Enum.UserInputType.Touch then
DBV139.moveTouchInput = input
else
DBV139.moveTouchInput = nil
end
DBV139.SetMoveBarMagic(true)
end
end)
ResizeHandle.InputBegan:Connect(function(input)
if State.Animating
or State.Minimized
or DBV139.activePanelGesture ~= nil then
return
end
if input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch then
DBV139.activePanelGesture = "resize"
MoveBarHitArea.Active = false
DBV139.moveDragging = false
DBV139.moveTouchInput = nil
DBV139.resizeArmed = true
DBV139.resizing = false
DBV139.resizeStartPointer = DBV139.InputXY(input)
DBV139.resizeStartSize = Vector2.new(panelWidth, panelHeight)
DBV139.resizeStartPosition = State.PanelPosition
if input.UserInputType == Enum.UserInputType.Touch then
DBV139.resizeTouchInput = input
else
DBV139.resizeTouchInput = nil
end
DBV139.SetResizeMagic(true)
end
end)
UserInputService.InputChanged:Connect(function(input)
if DBV139.activePanelGesture == "move"
and DBV139.moveDragging then
local isMouseMove =
input.UserInputType == Enum.UserInputType.MouseMovement
local isCorrectTouch =
input.UserInputType == Enum.UserInputType.Touch
and input == DBV139.moveTouchInput
if isMouseMove or isCorrectTouch then
local pointer = DBV139.InputXY(input)
local delta = pointer - DBV139.moveStartPointer
SetPanelPosition(
DBV139.moveStartPanelPos + delta
)
end
return
end
if DBV139.activePanelGesture == "resize"
and DBV139.resizeArmed then
local isMouseMove =
input.UserInputType == Enum.UserInputType.MouseMovement
local isCorrectTouch =
input.UserInputType == Enum.UserInputType.Touch
and input == DBV139.resizeTouchInput
if isMouseMove or isCorrectTouch then
local pointer = DBV139.InputXY(input)
local delta = pointer - DBV139.resizeStartPointer
if not DBV139.resizing then
if delta.Magnitude < 5 then
return
end
DBV139.resizing = true
end
local vpNow = GetViewport()
local maxW = vpNow.X
local maxH = vpNow.Y
local minW = math.min(MIN_PANEL_WIDTH, maxW)
local minH = math.min(MIN_PANEL_HEIGHT, maxH)
local newW = math.clamp(
DBV139.resizeStartSize.X + delta.X,
minW,
maxW
)
local newH = math.clamp(
DBV139.resizeStartSize.Y + delta.Y,
minH,
maxH
)
local usedDX = newW - DBV139.resizeStartSize.X
local usedDY = newH - DBV139.resizeStartSize.Y
panelWidth = newW
panelHeight = newH
Panel.Size = UDim2.fromOffset(
panelWidth,
panelHeight
)
SetPanelPosition(
DBV139.resizeStartPosition
+ Vector2.new(
usedDX / 2,
usedDY / 2
)
)
end
end
end)
UserInputService.InputEnded:Connect(function(input)
if DBV139.activePanelGesture == "move"
and DBV139.moveDragging then
local endedMouse =
input.UserInputType == Enum.UserInputType.MouseButton1
local endedTouch =
input.UserInputType == Enum.UserInputType.Touch
and input == DBV139.moveTouchInput
if endedMouse or endedTouch then
DBV139.moveDragging = false
DBV139.moveStartPointer = nil
DBV139.moveStartPanelPos = nil
DBV139.moveTouchInput = nil
DBV139.SetMoveBarMagic(false)
DBV139.activePanelGesture = nil
ResizeHandle.Active = true
end
return
end
if DBV139.activePanelGesture == "resize"
and DBV139.resizeArmed then
local endedMouse =
input.UserInputType == Enum.UserInputType.MouseButton1
local endedTouch =
input.UserInputType == Enum.UserInputType.Touch
and input == DBV139.resizeTouchInput
if endedMouse or endedTouch then
DBV139.resizing = false
DBV139.resizeArmed = false
DBV139.resizeStartPointer = nil
DBV139.resizeStartSize = nil
DBV139.resizeStartPosition = nil
DBV139.resizeTouchInput = nil
DBV139.SetResizeMagic(false)
DBV139.activePanelGesture = nil
MoveBarHitArea.Active = true
end
end
end)
task.spawn(function()
local camera = workspace.CurrentCamera
if not camera then
return
end
camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
if State.Minimized then
return
end
local vpNow = GetViewport()
local maxW = vpNow.X
local maxH = vpNow.Y
panelWidth = math.clamp(
panelWidth,
math.min(MIN_PANEL_WIDTH, maxW),
maxW
)
panelHeight = math.clamp(
panelHeight,
math.min(MIN_PANEL_HEIGHT, maxH),
maxH
)
Panel.Size = UDim2.fromOffset(
panelWidth,
panelHeight
)
SetPanelPosition(
State.PanelPosition
or Vector2.new(vpNow.X / 2, vpNow.Y / 2)
)
end)
end)
DBV139.btnDragging = false
DBV139.btnDragStartPos = nil
DBV139.btnDragStartMouse = nil
DBV139.btnTouchInput = nil
FloatingDragZone.InputBegan:Connect(function(input)
if input.UserInputType
~= Enum.UserInputType.MouseButton1
and input.UserInputType
~= Enum.UserInputType.Touch then
return
end
DBV139.btnDragging = true
DBV139.btnDragStartPos = FloatingButton.Position
DBV139.btnDragStartMouse = input.Position
if input.UserInputType
== Enum.UserInputType.Touch then
DBV139.btnTouchInput = input
end
end)
UserInputService.InputChanged:Connect(function(input)
if not DBV139.btnDragging then
return
end
if input.UserInputType
== Enum.UserInputType.Touch then
if input ~= DBV139.btnTouchInput then
return
end
elseif input.UserInputType
~= Enum.UserInputType.MouseMovement then
return
end
local delta =
input.Position
- DBV139.btnDragStartMouse
local vp = GetViewport()
local halfW = FLOATING_WIDTH / 2
local halfH = FLOATING_HEIGHT / 2
local newX =
math.clamp(
DBV139.btnDragStartPos.X.Offset
+ delta.X,
-halfW,
vp.X + halfW
)
local newY =
math.clamp(
DBV139.btnDragStartPos.Y.Offset
+ delta.Y,
halfH,
vp.Y - halfH
)
FloatingButton.Position =
UDim2.fromOffset(
newX,
newY
)
State.ButtonPosition =
Vector2.new(
newX,
newY
)
end)
UserInputService.InputEnded:Connect(function(input)
if not DBV139.btnDragging then
return
end
local ended =
input.UserInputType
== Enum.UserInputType.MouseButton1
or (
input.UserInputType
== Enum.UserInputType.Touch
and input == DBV139.btnTouchInput
)
if not ended then
return
end
DBV139.btnDragging = false
DBV139.btnDragStartPos = nil
DBV139.btnDragStartMouse = nil
DBV139.btnTouchInput = nil
local x =
FloatingButton.Position.X.Offset
State.ButtonHidden =
x <= -FLOATING_WIDTH / 2
or x >= GetViewport().X + FLOATING_WIDTH / 2
State.HideSide =
x < 0
and "left"
or (
x > GetViewport().X
and "right"
or "none"
)
end)
function DBV139.ConnectDBStrictTap(guiObject, callback)
    local activeInput = nil
    local startPos = nil
    local moved = false
    local startTime = 0
    local TAP_MOVE_THRESHOLD = 11
    local TAP_MAX_HOLD = 0.55

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        if activeInput ~= nil then return end
        activeInput = input
        startPos = Vector2.new(input.Position.X, input.Position.Y)
        startTime = os.clock()
        moved = false
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not activeInput or not startPos then return end
        local isTracked = false
        if activeInput.UserInputType == Enum.UserInputType.Touch then
            isTracked = input == activeInput
        else
            isTracked = input.UserInputType == Enum.UserInputType.MouseMovement
        end
        if not isTracked then return end
        local now = Vector2.new(input.Position.X, input.Position.Y)
        if (now - startPos).Magnitude > TAP_MOVE_THRESHOLD then
            moved = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if not activeInput then return end
        local ended = input == activeInput
            or (activeInput.UserInputType == Enum.UserInputType.MouseButton1
                and input.UserInputType == Enum.UserInputType.MouseButton1)
        if not ended then return end

        local heldFor = os.clock() - startTime
        local shouldTap = (not moved) and heldFor <= TAP_MAX_HOLD
        activeInput = nil
        startPos = nil
        startTime = 0
        moved = false
        if shouldTap then
            callback()
        end
    end)
end

DBV139.ConnectDBStrictTap(FloatingOpenZone, function()
    Restore()
end)

DBV139.__DBExitButton = Header:FindFirstChild("Exit")
if DBV139.__DBExitButton then
DBV139.__DBExitButton.Activated:Connect(DBCloseScript)
end

DBV139.ConnectDBStrictTap(CloseBtn, function()
    Minimize()
end)
Panel.Visible = true
FloatingButton.Visible = false
State.Minimized = false
State.ButtonHidden = false
State.HideSide = "none"
DBStartupScale.Scale = 0.18
DBV139.__DBReadyViewport =
GetViewport()
SetPanelPosition(
Vector2.new(
DBV139.__DBReadyViewport.X / 2,
DBV139.__DBReadyViewport.Y / 2
)
)
DBV139.__DBStartupTarget = State.PanelPosition
Panel.Position = UDim2.fromOffset(DBV139.__DBStartupTarget.X, DBV139.__DBStartupTarget.Y + 24)
for _,
descendant in ipairs(
Panel:GetDescendants()
) do
if descendant:IsA(
"ScrollingFrame"
) then
descendant.Active = true
descendant.ScrollingEnabled = true
end
end
DBV139.__dbStartupMoveTween = TweenService:Create(
    Panel,
    TweenInfo.new(0.46, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    {Position = UDim2.fromOffset(DBV139.__DBStartupTarget.X, DBV139.__DBStartupTarget.Y)}
)
DBV139.__dbStartupTween = TweenService:Create(
    DBStartupScale,
    TweenInfo.new(0.56, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {Scale = 1}
)
DBV139.__dbStartupMoveTween:Play()
DBV139.__dbStartupTween:Play()
if IntroGui and IntroGui.Parent then
    if DBSharedLogoAsset ~= "" and IntroLogo and IntroLogo.Parent then
        TweenService:Create(IntroLogo, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
    elseif IntroLogoFallback and IntroLogoFallback.Parent then
        TweenService:Create(IntroLogoFallback, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
    end
end
DBV139.__dbStartupTween.Completed:Wait()
AppleTransition.Progress = 1
AppleTransition.Target = 1
AppleTransition.Velocity = 0
AppleTransition.Running = false
State.Minimized = false
State.Animating = false
if IntroGui and IntroGui.Parent then IntroGui:Destroy() end

ShowDBNotification(
"加载成功",
"欢迎使用大肥鱼脚本 8.90",
true
)
print("✅ 大肥鱼脚本 8.90 已加载 · V139 138加载修复 / 编译降压 / 空间失败自动回退2D")
