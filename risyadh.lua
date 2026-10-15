local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local Market = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local PPS = game:GetService("ProximityPromptService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local lp = Players.LocalPlayer

local env = (getgenv and getgenv()) or _G
if env.RisyadhUnload then pcall(env.RisyadhUnload) end

local okHost, host = pcall(function()
    return (gethui and gethui()) or game:GetService("CoreGui")
end)
if not okHost or not host then host = lp:WaitForChild("PlayerGui") end
local old = host:FindFirstChild("RisyadhHub")
if old then old:Destroy() end

-- ===== THEME =====
local C = {
    bg = Color3.fromRGB(12, 12, 12),
    side = Color3.fromRGB(8, 8, 8),
    card = Color3.fromRGB(18, 18, 18),
    head = Color3.fromRGB(26, 26, 26),
    item = Color3.fromRGB(30, 30, 30),
    line = Color3.fromRGB(44, 44, 44),
    accent = Color3.fromRGB(245, 245, 245),
    text = Color3.fromRGB(240, 240, 240),
    mute = Color3.fromRGB(125, 125, 125),
    off = Color3.fromRGB(62, 62, 62),
    good = Color3.fromRGB(235, 235, 235),
    warn = Color3.fromRGB(170, 170, 170),
    bad = Color3.fromRGB(110, 110, 110),
}
local F = Enum.Font.Gotham
local FM = Enum.Font.GothamMedium
local FB = Enum.Font.GothamBold
local LEFT = Enum.TextXAlignment.Left
local CENTER = Enum.TextXAlignment.Center

-- Ikon: nama ikon vektor (digambar pakai Frame) ATAU "rbxassetid://ID"
local I = {
    home = "home", main = "gamepad", player = "user", settings = "settings",
    fps = "gauge", ping = "wifi", search = "search", collapse = "minimize",
    rejoin = "refresh", hop = "shuffle", lowest = "users", copy = "copy",
    name = "eyeoff", avatar = "avatar", chev = "chevright",
    pointer = "pointer", move = "move", fly = "plane", ui = "monitor", sys = "cpu",
    badge = "badge",
}

local conns = {}
local function track(c) conns[#conns + 1] = c return c end
local ord = 0
local function nextOrd() ord += 1 return ord end

local function new(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end
local function round(o, r) new("UICorner", {CornerRadius = UDim.new(0, r or 8)}, o) end
local function stroke(o, col, th) return new("UIStroke", {Color = col or C.line, Thickness = th or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, o) end
local function label(parent, text, ts, col, font, pos, sz, align)
    return new("TextLabel", {
        BackgroundTransparency = 1, Text = text, TextSize = ts, TextColor3 = col,
        Font = font or F, Position = pos or UDim2.new(), Size = sz or UDim2.new(1, 0, 1, 0),
        TextXAlignment = align or LEFT, TextTruncate = Enum.TextTruncate.AtEnd,
    }, parent)
end
local function pressFx(b, r)
    local fx = new("Frame", {
        Name = "PressFx", BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1,
        BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = b.ZIndex + 5, Active = false,
    }, b)
    round(fx, r or 8)
    local function to(t) TweenService:Create(fx, TweenInfo.new(0.12), {BackgroundTransparency = t}):Play() end
    local function pr(i) return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch end
    b.InputBegan:Connect(function(i) if pr(i) then to(0.55) end end)
    b.InputEnded:Connect(function(i) if pr(i) then to(1) end end)
end
local Controls = {}

-- ===== VECTOR ICONS (grid 24x24, gaya Lucide) =====
local ICON = {}
local iconMeta = setmetatable({}, {__mode = "k"})

local function arcPts(cx, cy, r, a1, a2)
    local p, n = {}, 12
    for i = 0, n do
        local a = math.rad(a1 + (a2 - a1) * i / n)
        p[#p + 1] = {cx + r * math.cos(a), cy + r * math.sin(a)}
    end
    return p
end
local function bez(x0, y0, x1, y1, x2, y2)
    local p, n = {}, 12
    for i = 0, n do
        local t = i / n
        local u = 1 - t
        p[#p + 1] = {u * u * x0 + 2 * u * t * x1 + t * t * x2, u * u * y0 + 2 * u * t * y1 + t * t * y2}
    end
    return p
end

ICON.home = function(b)
    b.poly({{3, 10}, {12, 3}, {21, 10}})
    b.poly({{5, 8.7}, {5, 21}, {19, 21}, {19, 8.7}})
    b.poly({{9.5, 21}, {9.5, 14}, {14.5, 14}, {14.5, 21}})
end
ICON.gamepad = function(b)
    b.rect(2, 6, 20, 12, 6)
    b.seg(6, 12, 10, 12)
    b.seg(8, 10, 8, 14)
    b.dot(15.5, 11, 1.1)
    b.dot(18, 13.2, 1.1)
end
ICON.user = function(b)
    b.ring(12, 7.5, 4)
    b.arc(12, 21, 7.5, 180, 360)
end
ICON.settings = function(b)
    for i = 0, 7 do
        local a = math.rad(i * 45)
        b.seg(12 + 7 * math.cos(a), 12 + 7 * math.sin(a), 12 + 9.6 * math.cos(a), 12 + 9.6 * math.sin(a), 3.4)
    end
    b.ring(12, 12, 6.6)
    b.ring(12, 12, 2.6)
end
ICON.gauge = function(b)
    b.arc(12, 14, 9, 150, 390)
    b.seg(12, 14, 17, 9)
    b.dot(12, 14, 1.2)
end
ICON.wifi = function(b)
    b.arc(12, 19, 15, 232, 308)
    b.arc(12, 19, 10, 232, 308)
    b.arc(12, 19, 5, 232, 308)
    b.dot(12, 19, 1.3)
end
ICON.search = function(b)
    b.ring(10.5, 10.5, 7)
    b.seg(16, 16, 21, 21)
end
ICON.minimize = function(b)
    b.poly({{14, 4}, {14, 10}, {20, 10}})
    b.poly({{10, 20}, {10, 14}, {4, 14}})
    b.seg(14, 10, 21, 3)
    b.seg(10, 14, 3, 21)
end
ICON.refresh = function(b)
    b.arc(12, 12, 9, 190, 340)
    b.arc(12, 12, 9, 10, 160)
    b.poly({{20.7, 3.5}, {20.7, 8.5}, {15.7, 8.5}})
    b.poly({{3.3, 20.5}, {3.3, 15.5}, {8.3, 15.5}})
end
ICON.shuffle = function(b)
    b.poly({{16, 3}, {21, 3}, {21, 8}})
    b.seg(4, 20, 21, 3)
    b.poly({{21, 16}, {21, 21}, {16, 21}})
    b.seg(15, 15, 21, 21)
    b.seg(4, 4, 9, 9)
end
ICON.users = function(b)
    b.ring(9, 7, 4)
    b.arc(9, 19, 7, 180, 360)
    b.seg(2, 19, 2, 21)
    b.seg(16, 19, 16, 21)
    b.arc(16, 7, 4, 270, 450)
    b.arc(16.5, 19, 5.5, 270, 360)
    b.seg(22, 19, 22, 21)
end
ICON.copy = function(b)
    b.rect(8, 8, 13, 13, 2)
    b.poly({{16, 8}, {16, 4}, {14, 2}, {4, 2}, {2, 4}, {2, 14}, {4, 16}, {8, 16}})
end
ICON.eyeoff = function(b)
    b.line(bez(2, 12, 12, 0, 22, 12))
    b.line(bez(2, 12, 12, 24, 22, 12))
    b.ring(12, 12, 3)
    b.seg(3, 3, 21, 21)
end
ICON.avatar = function(b)
    b.ring(9, 7.5, 3.8)
    b.arc(9, 21, 7, 180, 360)
    b.seg(17.5, 8, 21.5, 12)
    b.seg(21.5, 8, 17.5, 12)
end
ICON.badge = function(b)
    b.ring(12, 12, 8)
    b.dot(12, 12, 3)
end
ICON.chevdown = function(b) b.poly({{6, 9}, {12, 15}, {18, 9}}) end
ICON.chevright = function(b) b.poly({{9, 6}, {15, 12}, {9, 18}}) end
ICON.pointer = function(b)
    b.poly({{5, 3}, {5, 18.5}, {9, 15}, {12, 21.5}, {14.8, 20.2}, {11.8, 13.8}, {17, 13.5}}, true)
end
ICON.move = function(b)
    b.seg(12, 2, 12, 22)
    b.seg(2, 12, 22, 12)
    b.poly({{9, 5}, {12, 2}, {15, 5}})
    b.poly({{9, 19}, {12, 22}, {15, 19}})
    b.poly({{5, 9}, {2, 12}, {5, 15}})
    b.poly({{19, 9}, {22, 12}, {19, 15}})
end
ICON.plane = function(b)
    b.poly({{22, 2}, {15, 22}, {11, 13}, {2, 9}}, true)
    b.seg(22, 2, 11, 13)
end
ICON.monitor = function(b)
    b.rect(2, 3, 20, 14, 2)
    b.seg(8, 21, 16, 21)
    b.seg(12, 17, 12, 21)
end
ICON.cpu = function(b)
    b.rect(5, 5, 14, 14, 2)
    b.rect(9, 9, 6, 6, 1)
    for _, v in ipairs({9, 15}) do
        b.seg(v, 2, v, 5) b.seg(v, 19, v, 22)
        b.seg(2, v, 5, v) b.seg(19, v, 22, v)
    end
end

ICON.folder = function(b)
    b.poly({{3, 6}, {9, 6}, {11, 9}, {21, 9}, {21, 19}, {3, 19}, {3, 6}})
end
ICON.eye = function(b)
    b.line(bez(2, 12, 12, 0, 22, 12))
    b.line(bez(2, 12, 12, 24, 22, 12))
    b.ring(12, 12, 3)
end
ICON.sun = function(b)
    b.ring(12, 12, 4)
    for i = 0, 7 do
        local a = math.rad(i * 45)
        b.seg(12 + 7.5 * math.cos(a), 12 + 7.5 * math.sin(a), 12 + 10 * math.cos(a), 12 + 10 * math.sin(a))
    end
end
ICON.pin = function(b)
    b.arc(12, 10, 7, 155, 385)
    b.poly({{5.7, 13}, {12, 22}, {18.3, 13}})
    b.ring(12, 10, 2.4)
end
local function drawIcon(box, name, col, px)
    local meta = iconMeta[box]
    if meta and meta.root then meta.root:Destroy() end
    col = col or (meta and meta.col) or Color3.new(1, 1, 1)
    px = px or (meta and meta.px) or 16
    local def = ICON[name]
    if not def then return false end
    local k = px / 24
    local th = math.max(1.6, 2 * k)
    local root = new("Frame", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(px, px),
    }, box)
    local parts = {}
    local function fillPart(f)
        f.BackgroundColor3 = col
        f.BorderSizePixel = 0
        parts[#parts + 1] = {f, "fill"}
    end
    local b = {}
    function b.seg(x1, y1, x2, y2, w)
        local t = w and (w * k) or th
        local dx, dy = (x2 - x1) * k, (y2 - y1) * k
        local len = math.sqrt(dx * dx + dy * dy)
        local f = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset((x1 + x2) / 2 * k, (y1 + y2) / 2 * k),
            Size = UDim2.fromOffset(len + (w and 0 or t), t),
            Rotation = math.deg(math.atan2(dy, dx)),
        }, root)
        new("UICorner", {CornerRadius = UDim.new(0.5, 0)}, f)
        fillPart(f)
    end
    function b.line(p)
        for i = 1, #p - 1 do b.seg(p[i][1], p[i][2], p[i + 1][1], p[i + 1][2]) end
    end
    function b.poly(p, closed)
        b.line(p)
        if closed then b.seg(p[#p][1], p[#p][2], p[1][1], p[1][2]) end
    end
    function b.arc(cx, cy, r, a1, a2) b.line(arcPts(cx, cy, r, a1, a2)) end
    function b.rect(x, y, w, h, r)
        local f = new("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(x * k + th / 2, y * k + th / 2),
            Size = UDim2.fromOffset(w * k - th, h * k - th),
        }, root)
        new("UICorner", {CornerRadius = UDim.new(0, math.max(0, (r or 0) * k - th / 2))}, f)
        local st = new("UIStroke", {Color = col, Thickness = th, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, f)
        parts[#parts + 1] = {st, "stroke"}
    end
    function b.ring(cx, cy, r) b.rect(cx - r, cy - r, r * 2, r * 2, r) end
    function b.dot(cx, cy, r)
        local f = new("Frame", {
            Position = UDim2.fromOffset((cx - r) * k, (cy - r) * k),
            Size = UDim2.fromOffset(r * 2 * k, r * 2 * k),
        }, root)
        new("UICorner", {CornerRadius = UDim.new(0.5, 0)}, f)
        fillPart(f)
    end
    def(b)
    iconMeta[box] = {root = root, parts = parts, name = name, col = col, px = px}
    return true
end

local function ico(parent, g, ts, col, pos, sz)
    if type(g) == "string" and g:find("rbxassetid") then
        return new("ImageLabel", {
            BackgroundTransparency = 1, Image = g, ImageColor3 = col,
            Position = pos or UDim2.new(), Size = sz or UDim2.fromOffset(16, 16), ScaleType = Enum.ScaleType.Fit,
        }, parent)
    end
    if ICON[g] then
        local box = new("Frame", {
            BackgroundTransparency = 1, Position = pos or UDim2.new(), Size = sz or UDim2.fromOffset(16, 16),
        }, parent)
        drawIcon(box, g, col, math.floor(ts + 2))
        return box
    end
    return label(parent, g, ts, col, FM, pos, sz, CENTER)
end
local function tint(o, c)
    local meta = iconMeta[o]
    if meta then
        meta.col = c
        for _, p in ipairs(meta.parts) do
            if p[2] == "stroke" then p[1].Color = c else p[1].BackgroundColor3 = c end
        end
    elseif o:IsA("ImageLabel") then
        o.ImageColor3 = c
    else
        o.TextColor3 = c
    end
end
local function setIcon(o, g)
    if iconMeta[o] then
        drawIcon(o, g)
    elseif o:IsA("ImageLabel") then
        o.Image = g
    else
        o.Text = g
    end
end
local function isPress(i)
    return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end
local function isMove(i)
    return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end

local function makeDraggable(handle, target)
    local dragging, start, orig, moved = false, nil, nil, false
    track(handle.InputBegan:Connect(function(i)
        if isPress(i) then
            dragging, start, orig, moved = true, i.Position, target.Position, false
        end
    end))
    track(UIS.InputChanged:Connect(function(i)
        if dragging and isMove(i) then
            local d = i.Position - start
            if d.Magnitude > 6 then moved = true end
            target.Position = UDim2.new(orig.X.Scale, orig.X.Offset + d.X, orig.Y.Scale, orig.Y.Offset + d.Y)
        end
    end))
    track(UIS.InputEnded:Connect(function(i)
        if isPress(i) then dragging = false end
    end))
    return function() return moved end
end

-- pencarian
local searchables = {}
local function reg(row, name) searchables[#searchables + 1] = {row = row, name = name:lower()} end

-- ===== WINDOW =====
local gui = new("ScreenGui", {
    Name = "RisyadhHub", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true,
}, host)

local main = new("CanvasGroup", {
    Size = UDim2.fromScale(0.62, 0.94), Position = UDim2.fromScale(0.57, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = C.bg, BorderSizePixel = 0, Active = true, GroupTransparency = 1,
}, gui)
round(main, 14)
stroke(main, C.line, 1)
new("UISizeConstraint", {MinSize = Vector2.new(430, 240)}, main)
local uiScale = new("UIScale", {Scale = 1}, main)
local userScale = 1
local menuOpen = false
local menuToken = 0
local function setMenu(v)
    menuToken += 1
    local my = menuToken
    menuOpen = v
    if v then
        main.GroupTransparency = 1
        uiScale.Scale = userScale * 0.7
        main.Visible = true
        TweenService:Create(uiScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = userScale}):Play()
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
    else
        TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = userScale * 0.8}):Play()
        TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {GroupTransparency = 1}):Play()
        task.delay(0.22, function()
            if menuToken == my then
                main.Visible = false
                uiScale.Scale = userScale
            end
        end)
    end
end
main.Visible = false

local side = new("Frame", {Size = UDim2.new(0, 150, 1, 0), BackgroundColor3 = C.side, BorderSizePixel = 0, Active = true}, main)
round(side, 14)
new("Frame", {Position = UDim2.new(1, -16, 0, 0), Size = UDim2.new(0, 16, 1, 0), BackgroundColor3 = C.side, BorderSizePixel = 0}, side)
new("Frame", {Position = UDim2.new(1, -1, 0, 0), Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = C.line, BorderSizePixel = 0}, side)

local logo = new("Frame", {Position = UDim2.fromOffset(12, 14), Size = UDim2.fromOffset(32, 32), BackgroundColor3 = C.item, BorderSizePixel = 0}, side)
round(logo, 16)
stroke(logo, C.line, 1)

-- ===== LOGO (tertanam, tidak perlu upload) =====
local LOGO_B64 = "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"

local function b64dec(data)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local lookup = {}
    for k = 1, 64 do lookup[chars:byte(k)] = k - 1 end
    local out, n, buf, bits = {}, 0, 0, 0
    for k = 1, #data do
        local v = lookup[data:byte(k)]
        if v then
            buf = buf * 64 + v
            bits += 6
            if bits >= 8 then
                bits -= 8
                n += 1
                out[n] = string.char(math.floor(buf / 2 ^ bits) % 256)
                buf = buf % 2 ^ bits
            end
        end
    end
    return table.concat(out)
end

local function loadLogo()
    if not (writefile and getcustomasset) then return nil end
    local ok, res = pcall(function()
        writefile("risyadh_logo.png", b64dec(LOGO_B64))
        return getcustomasset("risyadh_logo.png")
    end)
    if ok then return res end
end

local logoImg = loadLogo()
if logoImg then
    new("ImageLabel", {
        BackgroundTransparency = 1, Image = logoImg, ImageColor3 = Color3.new(1, 1, 1),
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(24, 24), ScaleType = Enum.ScaleType.Fit,
    }, logo)
else
    label(logo, "R", 16, Color3.new(1, 1, 1), FB, nil, nil, CENTER)
end
label(side, "Risyadh Hub", 13, C.text, FM, UDim2.fromOffset(52, 13), UDim2.new(1, -58, 0, 18))
label(side, "v2.1", 10, C.mute, F, UDim2.fromOffset(52, 30), UDim2.new(1, -58, 0, 14))

local tabList = new("Frame", {Position = UDim2.fromOffset(8, 66), Size = UDim2.new(1, -16, 1, -150), BackgroundTransparency = 1}, side)
new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, tabList)

-- profil bawah
new("Frame", {Position = UDim2.new(0, 8, 1, -76), Size = UDim2.new(1, -24, 0, 1), BackgroundColor3 = C.line, BorderSizePixel = 0}, side)
local prof = new("Frame", {Position = UDim2.new(0, 8, 1, -66), Size = UDim2.new(1, -24, 0, 56), BackgroundColor3 = C.card, BorderSizePixel = 0}, side)
round(prof, 10)
stroke(prof)
local pav = new("ImageLabel", {
    Position = UDim2.fromOffset(8, 12), Size = UDim2.fromOffset(32, 32), BackgroundColor3 = C.item,
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. lp.UserId .. "&w=150&h=150",
}, prof)
round(pav, 16)
local dot = new("Frame", {Position = UDim2.fromOffset(30, 34), Size = UDim2.fromOffset(10, 10), BackgroundColor3 = C.good, BorderSizePixel = 0}, prof)
round(dot, 5)
stroke(dot, C.card, 2)
label(prof, lp.DisplayName, 11, C.text, FM, UDim2.fromOffset(48, 11), UDim2.new(1, -66, 0, 16))
local profGame = label(prof, "...", 10, C.mute, F, UDim2.fromOffset(48, 28), UDim2.new(1, -66, 0, 14))
ico(prof, I.chev, 12, C.mute, UDim2.new(1, -20, 0, 0), UDim2.fromOffset(16, 56))

local content = new("Frame", {Position = UDim2.new(0, 150, 0, 0), Size = UDim2.new(1, -150, 1, 0), BackgroundTransparency = 1}, main)
local header = new("Frame", {Size = UDim2.new(1, 0, 0, 56), BackgroundTransparency = 1, Active = true}, content)
local titleIcon = ico(header, I.home, 18, C.accent, UDim2.fromOffset(14, 0), UDim2.fromOffset(26, 56))
local title = label(header, "Home", 16, C.text, FM, UDim2.fromOffset(44, 0), UDim2.new(1, -270, 1, 0))

local searchWrap = new("Frame", {Position = UDim2.new(1, -212, 0, 14), Size = UDim2.fromOffset(160, 30), BackgroundTransparency = 1}, header)
ico(searchWrap, I.search, 16, C.mute, UDim2.new(), UDim2.fromOffset(20, 28))
local search = new("TextBox", {
    Position = UDim2.fromOffset(26, 0), Size = UDim2.new(1, -26, 0, 28), BackgroundTransparency = 1,
    Text = "", PlaceholderText = "Search", PlaceholderColor3 = C.mute, TextColor3 = C.text,
    Font = F, TextSize = 12, TextXAlignment = LEFT, ClearTextOnFocus = false,
}, searchWrap)
new("Frame", {Position = UDim2.new(0, 0, 0, 29), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = C.line, BorderSizePixel = 0}, searchWrap)
search:GetPropertyChangedSignal("Text"):Connect(function()
    local q = search.Text:lower()
    for _, s in ipairs(searchables) do
        if s.row.Parent then s.row.Visible = (q == "") or (s.name:find(q, 1, true) ~= nil) end
    end
end)

local minBtn = new("TextButton", {
    Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -42, 0, 14),
    BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
}, header)
ico(minBtn, I.collapse, 17, C.mute, UDim2.new(), UDim2.fromOffset(30, 30))
minBtn.Activated:Connect(function() setMenu(false) end)

local pages = new("Frame", {
    Position = UDim2.new(0, 0, 0, 56), Size = UDim2.new(1, 0, 1, -56),
    BackgroundTransparency = 1, ClipsDescendants = true,
}, content)

makeDraggable(header, main)
makeDraggable(side, main)

-- tombol melayang (kotak grid)
local fab = new("TextButton", {
    Size = UDim2.fromOffset(52, 52), Position = UDim2.new(0, 10, 1, -70),
    BackgroundColor3 = C.side, Text = "", AutoButtonColor = false, Active = true,
}, gui)
round(fab, 26)
stroke(fab, C.line, 1)
pressFx(fab, 26)
if logoImg then
    local fi = new("ImageLabel", {
        BackgroundTransparency = 1, Image = logoImg, AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, -10, 1, -10), ScaleType = Enum.ScaleType.Crop,
        Active = false,
    }, fab)
    new("UICorner", {CornerRadius = UDim.new(1, 0)}, fi)
else
    label(fab, "R", 24, Color3.new(1, 1, 1), FB, nil, nil, CENTER)
end
local fabMoved = makeDraggable(fab, fab)
fab.Activated:Connect(function()
    if fabMoved() then return end
    setMenu(not menuOpen)
    TweenService:Create(fab, TweenInfo.new(0.1), {Size = UDim2.fromOffset(44, 44)}):Play()
    task.delay(0.1, function()
        TweenService:Create(fab, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(52, 52)}):Play()
    end)
end)

-- ===== COMPONENTS =====
local tabs = {}
local function newTab(name, icon, heading)
    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = C.item, BackgroundTransparency = 1,
        Text = "", AutoButtonColor = false, LayoutOrder = nextOrd(),
    }, tabList)
    round(btn, 9)
    pressFx(btn, 9)
    local ic = ico(btn, icon, 15, C.mute, UDim2.fromOffset(8, 0), UDim2.fromOffset(24, 36))
    local lb = label(btn, name, 12, C.mute, FM, UDim2.fromOffset(38, 0), UDim2.new(1, -42, 1, 0))
    local page = new("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = C.accent,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
    }, pages)
    new("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    new("UIPadding", {
        PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
        PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 14),
    }, page)
    local entry = {heading = heading}
    local function pick()
        for _, t in ipairs(tabs) do
            t.page.Visible = false
            t.btn.BackgroundTransparency = 1
            t.lb.TextColor3 = C.mute
            tint(t.ic, C.mute)
        end
        page.Position = UDim2.fromOffset(0, 14)
        page.Visible = true
        TweenService:Create(page, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new()}):Play()
        btn.BackgroundTransparency = 0
        lb.TextColor3 = C.text
        tint(ic, C.text)
        title.Text = entry.heading or name
        setIcon(titleIcon, icon)
    end
    btn.Activated:Connect(pick)
    entry.btn, entry.page, entry.pick, entry.lb, entry.ic = btn, page, pick, lb, ic
    tabs[#tabs + 1] = entry
    return page
end

local function twoCol(page)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, LayoutOrder = nextOrd(),
    }, page)
    local function col(pos)
        local f = new("Frame", {
            Size = UDim2.new(0.5, -5, 0, 0), Position = pos,
            AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
        }, row)
        new("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder}, f)
        return f
    end
    return col(UDim2.new(0, 0, 0, 0)), col(UDim2.new(0.5, 5, 0, 0))
end

local function card(parent, name, icon)
    local f = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = C.card, BorderSizePixel = 0, LayoutOrder = nextOrd(),
    }, parent)
    round(f, 12)
    stroke(f)
    new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, f)
    local head = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = C.head, Text = "",
        AutoButtonColor = false, LayoutOrder = 0,
    }, f)
    round(head, 12)
    pressFx(head, 12)
    ico(head, icon, 14, C.accent, UDim2.fromOffset(10, 0), UDim2.fromOffset(22, 36))
    label(head, name, 12, C.text, FM, UDim2.fromOffset(36, 0), UDim2.new(1, -70, 1, 0))
    local chev = ico(head, "chevdown", 12, C.mute, UDim2.new(1, -30, 0, 0), UDim2.fromOffset(20, 36))
    local body = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, LayoutOrder = 1,
    }, f)
    new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, body)
    new("UIPadding", {
        PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 10),
    }, body)
    head.Activated:Connect(function()
        body.Visible = not body.Visible
        setIcon(chev, body.Visible and "chevdown" or "chevright")
    end)
    return body, f
end

local function toggle(parent, name, default, cb, noSave)
    local row = new("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = nextOrd()}, parent)
    reg(row, name)
    label(row, name, 12, C.text, F, UDim2.new(), UDim2.new(1, -50, 1, 0))
    local sw = new("TextButton", {
        Size = UDim2.fromOffset(40, 20), Position = UDim2.new(1, -40, 0.5, -10),
        BackgroundColor3 = C.off, Text = "", AutoButtonColor = false,
    }, row)
    round(sw, 10)
    pressFx(sw, 10)
    local knob = new("Frame", {
        Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(3, 3),
        BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
    }, sw)
    round(knob, 7)
    local state = default or false
    local function render()
        TweenService:Create(sw, TweenInfo.new(0.15), {BackgroundColor3 = state and C.accent or C.off}):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = state and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3),
            BackgroundColor3 = state and C.bg or Color3.new(1, 1, 1),
        }):Play()
    end
    render()
    local h = {
        get = function() return state end,
        set = function(v)
            v = v and true or false
            if v == state then return end
            state = v
            render()
            task.spawn(cb, state)
        end,
    }
    sw.Activated:Connect(function()
        state = not state
        render()
        task.spawn(cb, state)
    end)
    if not noSave then Controls[name] = h end
    return h
end

local function slider(parent, name, mn, mx, def, cb, suffix, noSave)
    suffix = suffix or ""
    local row = new("Frame", {Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1, LayoutOrder = nextOrd()}, parent)
    reg(row, name)
    label(row, name, 12, C.text, F, UDim2.new(), UDim2.new(1, -62, 0, 22))
    local box = new("Frame", {
        Size = UDim2.fromOffset(54, 22), Position = UDim2.new(1, -54, 0, 0),
        BackgroundColor3 = C.item, BorderSizePixel = 0,
    }, row)
    round(box, 6)
    local val = label(box, def .. suffix, 11, C.accent, FM, nil, nil, CENTER)
    local tr = new("Frame", {
        Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 32),
        BackgroundColor3 = C.off, BorderSizePixel = 0,
    }, row)
    round(tr, 3)
    local fill = new("Frame", {
        Size = UDim2.new((def - mn) / (mx - mn), 0, 1, 0), BackgroundColor3 = C.accent, BorderSizePixel = 0,
    }, tr)
    round(fill, 3)
    local knob = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(12, 12), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
    }, fill)
    round(knob, 6)
    stroke(knob, C.bg, 2)
    local hit = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, 22),
        BackgroundTransparency = 1, Text = "",
    }, row)
    local scroller = parent:FindFirstAncestorOfClass("ScrollingFrame")
    local dragging = false
    local curv = def
    local function apply(v)
        v = math.clamp(math.floor(v + 0.5), mn, mx)
        curv = v
        fill.Size = UDim2.new((v - mn) / (mx - mn), 0, 1, 0)
        val.Text = v .. suffix
        task.spawn(cb, v)
    end
    local function set(x)
        local a = math.clamp((x - tr.AbsolutePosition.X) / math.max(tr.AbsoluteSize.X, 1), 0, 1)
        apply(mn + (mx - mn) * a)
    end
    hit.InputBegan:Connect(function(i)
        if isPress(i) then
            dragging = true
            if scroller then scroller.ScrollingEnabled = false end
            set(i.Position.X)
        end
    end)
    track(UIS.InputChanged:Connect(function(i)
        if dragging and isMove(i) then set(i.Position.X) end
    end))
    track(UIS.InputEnded:Connect(function(i)
        if isPress(i) and dragging then
            dragging = false
            if scroller then scroller.ScrollingEnabled = true end
        end
    end))
    local h = {get = function() return curv end, set = function(v) if type(v) == "number" then apply(v) end end}
    if not noSave then Controls[name] = h end
    return h
end

local function button(parent, name, cb)
    local b = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.item, Text = name,
        TextColor3 = C.text, Font = FM, TextSize = 12, LayoutOrder = nextOrd(),
    }, parent)
    round(b, 8)
    pressFx(b, 8)
    reg(b, name)
    b.Activated:Connect(function() task.spawn(cb) end)
    return b
end

local function flash(b, txt, orig)
    b.Text = txt
    task.delay(1.5, function() if b.Parent then b.Text = orig end end)
end

local function dropdown(parent, name, options, default, cb, noSave)
    local full = (name == "")
    local wrap = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = nextOrd()}, parent)
    new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, wrap)
    local row = new("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = 0}, wrap)
    reg(wrap, full and "config" or name)
    if not full then label(row, name, 12, C.text, F, UDim2.new(), UDim2.new(0.42, 0, 1, 0)) end
    local btn = new("TextButton", {
        Size = full and UDim2.new(1, 0, 1, 0) or UDim2.new(0.58, 0, 1, 0),
        Position = full and UDim2.new() or UDim2.new(0.42, 0, 0, 0),
        BackgroundColor3 = C.item, Text = "", AutoButtonColor = false,
    }, row)
    round(btn, 8)
    stroke(btn)
    pressFx(btn, 8)
    local cur = label(btn, default ~= nil and tostring(default) or "--", 11, C.text, FM, UDim2.fromOffset(10, 0), UDim2.new(1, -30, 1, 0))
    ico(btn, "chevdown", 11, C.mute, UDim2.new(1, -22, 0, 0), UDim2.fromOffset(16, 30))
    local list = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.card,
        BorderSizePixel = 0, Visible = false, LayoutOrder = 1,
    }, wrap)
    round(list, 8)
    stroke(list)
    new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, list)
    new("UIPadding", {PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3), PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3)}, list)
    local value = default
    local opts = options
    local h = {}
    local rebuild
    local function choose(v, silent)
        value = v
        cur.Text = (v ~= nil) and tostring(v) or "--"
        list.Visible = false
        if rebuild then rebuild() end
        if not silent then task.spawn(cb, v) end
    end
    rebuild = function()
        for _, c in ipairs(list:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, o in ipairs(opts) do
            local ob = new("TextButton", {
                Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = C.item, BackgroundTransparency = (o == value) and 0 or 1,
                Text = tostring(o), TextColor3 = C.text, Font = F, TextSize = 11, AutoButtonColor = false, LayoutOrder = nextOrd(),
            }, list)
            round(ob, 6)
            pressFx(ob, 6)
            ob.Activated:Connect(function() choose(o) end)
        end
    end
    rebuild()
    btn.Activated:Connect(function() list.Visible = not list.Visible end)
    function h.get() return value end
    function h.set(v)
        for _, o in ipairs(opts) do
            if o == v then choose(v) return end
        end
    end
    function h.setOptions(newOpts, keep)
        opts = newOpts
        local found = false
        for _, o in ipairs(opts) do if o == value then found = true end end
        if not found or not keep then
            value = nil
            cur.Text = "--"
        end
        rebuild()
    end
    function h.pick(v) choose(v, true) end
    if not noSave then Controls[name] = h end
    return h
end

local function btnPair(parent, nameA, cbA, nameB, cbB)
    local row = new("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = nextOrd()}, parent)
    new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, row)
    local function mk(txt, cb)
        local b = new("TextButton", {
            Size = UDim2.new(0.5, -3, 1, 0), BackgroundColor3 = C.item, Text = txt,
            TextColor3 = C.text, Font = FM, TextSize = 11, AutoButtonColor = false, LayoutOrder = nextOrd(),
        }, row)
        round(b, 8)
        pressFx(b, 8)
        b.Activated:Connect(function() task.spawn(cb, b, txt) end)
    end
    mk(nameA, cbA)
    mk(nameB, cbB)
end

-- ===== FEATURES =====
local State = {
    WalkSpeed = false, Speed = 32, InfJump = false, Noclip = false, Fly = false, FlySpeed = 60, Instant = false,
    ESP = false, Fullbright = false, FOVOn = false, FOV = 90, AntiAFK = false,
    ESPHL = true, ESPDist = true, ESPEgg = false, ESPBrain = false,
    AutoClick = false, ClickDelay = 200,
    AutoHome = true, HatchCd = 3, PlaceCd = 4,
    JumpOn = false, Jump = 50, NoFog = false,
}

local function hum()
    local c = lp.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function root()
    local c = lp.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local flyBV, flyBG
local function stopFly()
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
    local h = hum()
    if h then h.PlatformStand = false end
end
local function startFly()
    local r, h = root(), hum()
    if not r or not h then return end
    stopFly()
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = r
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    flyBG.P = 9e4
    flyBG.CFrame = r.CFrame
    flyBG.Parent = r
    h.PlatformStand = true
end

track(RunService.Heartbeat:Connect(function()
    if State.WalkSpeed then
        local h = hum()
        if h then h.WalkSpeed = State.Speed end
    end
    if State.JumpOn then
        local h = hum()
        if h then
            h.UseJumpPower = true
            h.JumpPower = State.Jump
        end
    end
end))
track(UIS.JumpRequest:Connect(function()
    if State.InfJump then
        local h = hum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))
track(RunService.Stepped:Connect(function()
    if State.Noclip and lp.Character then
        for _, p in ipairs(lp.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end))
track(RunService.RenderStepped:Connect(function()
    if not State.Fly or not flyBV then return end
    local camera, h = workspace.CurrentCamera, hum()
    if not camera or not h then return end
    local look = camera.CFrame.LookVector
    local dir = h.MoveDirection
    local vel = Vector3.zero
    if dir.Magnitude > 0 then
        local flat = Vector3.new(look.X, 0, look.Z)
        local fwd = flat.Magnitude > 0 and dir:Dot(flat.Unit) or 0
        vel = dir * State.FlySpeed + Vector3.new(0, look.Y * fwd * State.FlySpeed, 0)
    end
    -- naik: Space / tombol jump HP, turun: Shift
    local up = (UIS:IsKeyDown(Enum.KeyCode.Space) or h.Jump) and 1 or 0
    local down = UIS:IsKeyDown(Enum.KeyCode.LeftShift) and 1 or 0
    vel += Vector3.new(0, (up - down) * State.FlySpeed, 0)
    flyBV.Velocity = vel
    flyBG.CFrame = camera.CFrame
end))
track(lp.CharacterAdded:Connect(function()
    task.wait(1)
    if State.Fly then startFly() end
end))
track(PPS.PromptButtonHoldBegan:Connect(function(p)
    if State.Instant and fireproximityprompt then fireproximityprompt(p) end
end))

-- ===== FITUR TAMBAHAN =====
local alive = true
local Base = {} -- jembatan antar bagian (promptPart, Base.itemFolder, Go Home, Go Safe)

-- rarity: dibaca dari atribut/value "Rarity", kalau nggak ada dari kata di nama item
Base.RARITIES = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"}
Base.rarityOf = function(inst)
    local v = inst:GetAttribute("Rarity")
    if type(v) == "string" and v ~= "" then return v:lower() end
    local c = inst:FindFirstChild("Rarity")
    if c and c:IsA("ValueBase") then
        local ok, val = pcall(function() return c.Value end)
        if ok and type(val) == "string" and val ~= "" then return val:lower() end
    end
    local n = inst.Name:lower()
    for i = #Base.RARITIES, 1, -1 do -- dari yang paling langka, biar "uncommon" nggak kebaca "common"
        local r = Base.RARITIES[i]:lower()
        if n:find(r, 1, true) then return r end
    end
end
-- set kosong = semua lolos; rarity nggak kebaca = lolos
Base.rarityPass = function(inst, set)
    if not set or next(set) == nil then return true end
    local r = Base.rarityOf(inst)
    if not r then return true end
    return set[r] == true
end

-- dropdown pilih banyak (1 baris, buka -> centang). emptyText = teks saat nggak ada yang dipilih
function Base.multiSelect(parent, name, options, cb, emptyText)
    emptyText = emptyText or "All"
    local wrap = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = nextOrd()}, parent)
    new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, wrap)
    local row = new("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = 0}, wrap)
    reg(wrap, name)
    label(row, name, 12, C.text, F, UDim2.new(), UDim2.new(0.42, 0, 1, 0))
    local btn = new("TextButton", {
        Size = UDim2.new(0.58, 0, 1, 0), Position = UDim2.new(0.42, 0, 0, 0),
        BackgroundColor3 = C.item, Text = "", AutoButtonColor = false,
    }, row)
    round(btn, 8)
    stroke(btn)
    pressFx(btn, 8)
    local cur = label(btn, emptyText, 11, C.text, FM, UDim2.fromOffset(10, 0), UDim2.new(1, -30, 1, 0))
    ico(btn, "chevdown", 11, C.mute, UDim2.new(1, -22, 0, 0), UDim2.fromOffset(16, 30))
    local list = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.card,
        BorderSizePixel = 0, Visible = false, LayoutOrder = 1,
    }, wrap)
    round(list, 8)
    stroke(list)
    new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, list)
    new("UIPadding", {PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3), PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3)}, list)

    local sel, boxes, allBox = {}, {}, nil
    local function refresh(fire)
        local names, lower = {}, {}
        for _, o in ipairs(options) do
            local on = sel[o] == true
            boxes[o].BackgroundColor3 = on and C.accent or C.off
            if on then names[#names + 1] = o lower[o:lower()] = true end
        end
        allBox.BackgroundColor3 = (#names == #options) and C.accent or C.off
        cur.Text = (#names == 0) and emptyText or table.concat(names, ", ")
        if fire then task.spawn(cb, lower) end
    end
    local function addRow(text, onClick)
        local b = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = C.item, BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false, LayoutOrder = nextOrd(),
        }, list)
        round(b, 6)
        pressFx(b, 6)
        label(b, text, 11, C.text, F, UDim2.fromOffset(8, 0), UDim2.new(1, -34, 1, 0))
        local box = new("Frame", {
            Size = UDim2.fromOffset(12, 12), Position = UDim2.new(1, -22, 0.5, -6),
            BackgroundColor3 = C.off, BorderSizePixel = 0,
        }, b)
        round(box, 3)
        b.Activated:Connect(onClick)
        return box
    end
    allBox = addRow("Select all", function()
        local full = true
        for _, o in ipairs(options) do if not sel[o] then full = false end end
        sel = {}
        if not full then for _, o in ipairs(options) do sel[o] = true end end
        refresh(true)
    end)
    for _, o in ipairs(options) do
        boxes[o] = addRow(o, function()
            sel[o] = (not sel[o]) or nil
            refresh(true)
        end)
    end
    btn.Activated:Connect(function() list.Visible = not list.Visible end)
    refresh(false)
    local h = {
        get = function()
            local t = {}
            for _, o in ipairs(options) do if sel[o] then t[#t + 1] = o end end
            return t
        end,
        set = function(v)
            sel = {}
            if type(v) == "table" then
                for _, o in ipairs(v) do
                    for _, op in ipairs(options) do if op == o then sel[op] = true end end
                end
            end
            refresh(true)
        end,
    }
    Controls[name] = h
    return h
end
local origLight = {
    Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
    FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
}
local origFOV = (workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView) or 70

local function applyLight()
    if State.Fullbright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
    end
    if State.NoFog then Lighting.FogEnd = 1e6 end
end
local function restoreLight()
    Lighting.Brightness = origLight.Brightness
    Lighting.ClockTime = origLight.ClockTime
    Lighting.GlobalShadows = origLight.GlobalShadows
    Lighting.Ambient = origLight.Ambient
    Lighting.OutdoorAmbient = origLight.OutdoorAmbient
    Lighting.FogEnd = origLight.FogEnd
    Lighting.FogStart = origLight.FogStart
end

-- ESP pemain
local espFolder = new("Folder", {Name = "ESP"}, gui)
local espObjs = {}
local function clearESP(plr)
    local e = espObjs[plr]
    if e then
        -- cuma hancurin objek ESP-nya sendiri. JANGAN e.head: itu Head karakter pemain lain
        if e.hl then pcall(function() e.hl:Destroy() end) end
        if e.bb then pcall(function() e.bb:Destroy() end) end
        espObjs[plr] = nil
    end
end
local function applyESP(plr)
    clearESP(plr)
    if plr == lp or not State.ESP then return end
    local ch = plr.Character
    if not ch then return end
    local head = ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
    if not head then return end
    local e = {head = head, name = plr.DisplayName}
    if State.ESPHL then
        local hl = Instance.new("Highlight")
        hl.FillColor = C.accent
        hl.OutlineColor = Color3.new(1, 1, 1)
        hl.FillTransparency = 0.7
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = ch
        e.hl = hl
    end
    local bb = Instance.new("BillboardGui")
    bb.Adornee = head
    bb.AlwaysOnTop = true
    bb.Size = UDim2.fromOffset(140, 30)
    bb.StudsOffset = Vector3.new(0, 2.6, 0)
    bb.Parent = espFolder
    e.bb = bb
    e.lbl = new("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = plr.DisplayName,
        TextColor3 = Color3.new(1, 1, 1), TextStrokeTransparency = 0.4, Font = FB, TextSize = 12,
    }, bb)
    espObjs[plr] = e
end
local function setESP(v)
    State.ESP = v
    for _, p in ipairs(Players:GetPlayers()) do
        if v then applyESP(p) else clearESP(p) end
    end
end
local function hookPlayer(plr)
    if plr == lp then return end
    track(plr.CharacterAdded:Connect(function()
        task.wait(0.5)
        if State.ESP then applyESP(plr) end
    end))
    if plr.Character and State.ESP then applyESP(plr) end
end
for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
track(Players.PlayerAdded:Connect(hookPlayer))
track(Players.PlayerRemoving:Connect(clearESP))

-- cache ProximityPrompt untuk Auto Prompt
local prompts = {}
for _, d in ipairs(workspace:GetDescendants()) do
    if d:IsA("ProximityPrompt") then prompts[d] = true end
end
track(workspace.DescendantAdded:Connect(function(d)
    if d:IsA("ProximityPrompt") then prompts[d] = true end
end))
track(workspace.DescendantRemoving:Connect(function(d) prompts[d] = nil end))

-- bagian BasePart dari sebuah ProximityPrompt (buat nempelin label / marker)
function Base.promptPart(p)
    local par = p.Parent
    if par and par:IsA("Attachment") then par = par.Parent end
    if par and par:IsA("Model") then par = par.PrimaryPart or par:FindFirstChildWhichIsA("BasePart", true) end
    if par and par:IsA("BasePart") then return par end
end

-- Item ESP: label melayang di prompt Egg / Brainrot terdekat (maks 40)
Base.itemFolder = new("Folder", {Name = "ItemESP"}, gui)
task.spawn(function()
    while alive do
        task.wait(1.5)
        Base.itemFolder:ClearAllChildren()
        local r = root()
        if r and (State.ESPEgg or State.ESPBrain) then
            local found = {}
            for p in pairs(prompts) do
                if p.Parent and p.Enabled then
                    local tx = ((p.ActionText or "") .. " " .. (p.ObjectText or "") .. " " .. p.Parent.Name):lower()
                    local isEgg = State.ESPEgg and tx:find("egg", 1, true)
                    -- brainrot di game ini namanya macem-macem (nggak selalu ada kata "brain"),
                    -- jadi prompt "Steal" juga dihitung sebagai brainrot
                    local isBrain = State.ESPBrain and (tx:find("brain", 1, true)
                        or (p.ActionText or ""):lower():find("steal", 1, true))
                    if isEgg or isBrain then
                        local part = Base.promptPart(p)
                        if part then
                            found[#found + 1] = {
                                part = part, d = (part.Position - r.Position).Magnitude,
                                text = (p.ObjectText ~= "" and p.ObjectText or p.Parent.Name),
                                col = isEgg and Color3.fromRGB(255, 210, 90) or Color3.fromRGB(255, 120, 200),
                            }
                        end
                    end
                end
            end
            table.sort(found, function(a, b) return a.d < b.d end)
            for i = 1, math.min(#found, 40) do
                local f = found[i]
                local bb = new("BillboardGui", {
                    Adornee = f.part, AlwaysOnTop = true, Size = UDim2.fromOffset(150, 20), StudsOffset = Vector3.new(0, 3, 0),
                }, Base.itemFolder)
                new("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
                    Text = f.text .. "  [" .. math.floor(f.d) .. "m]", TextColor3 = f.col,
                    TextStrokeTransparency = 0.4, Font = FB, TextSize = 11,
                }, bb)
            end
        end
    end
end)

task.spawn(function()
    while alive do
        task.wait(0.25)
        applyLight()
        local r = root()
        if r and State.ESP then
            for _, e in pairs(espObjs) do
                if e.lbl and e.head and e.head.Parent then
                    local d = math.floor((e.head.Position - r.Position).Magnitude)
                    e.lbl.Text = State.ESPDist and (e.name .. "  [" .. d .. "m]") or e.name
                end
            end
        end
    end
end)

track(RunService.RenderStepped:Connect(function()
    if State.FOVOn then
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = State.FOV end
    end
end))
track(lp.Idled:Connect(function()
    if State.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end))

local function restoreAll()
    alive = false
    setESP(false)
    restoreLight()
    pcall(function() Base.itemFolder:ClearAllChildren() end)
    if Base.stopSpec then pcall(Base.stopSpec) end
    local cam = workspace.CurrentCamera
    if cam and State.FOVOn then cam.FieldOfView = origFOV end
end

-- server hop
local function httpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and type(res) == "string" and res ~= "" then return res end
    local req = (syn and syn.request) or request or http_request
    if req then
        local ok2, r = pcall(req, {Url = url, Method = "GET"})
        if ok2 and r and type(r.Body) == "string" then return r.Body end
    end
end
local function serverList()
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
    local body = httpGet(url)
    if not body then return nil end
    local ok, res = pcall(function() return HttpService:JSONDecode(body) end)
    if ok and res and res.data then return res.data end
    return nil
end
local function hop(lowest)
    local list = serverList()
    if not list then return false end
    local cand = {}
    for _, s in ipairs(list) do
        if s.id ~= game.JobId and s.playing < s.maxPlayers then cand[#cand + 1] = s end
    end
    if #cand == 0 then return false end
    local pick
    if lowest then
        table.sort(cand, function(a, b) return a.playing < b.playing end)
        pick = cand[1]
    else
        pick = cand[math.random(1, #cand)]
    end
    TeleportService:TeleportToPlaceInstance(game.PlaceId, pick.id, lp)
    return true
end

-- ===== HOME =====
local home = newTab("Home", I.home, "Welcome!")

-- banner
local banner = new("Frame", {Size = UDim2.new(1, 0, 0, 96), BackgroundColor3 = C.card, BorderSizePixel = 0, LayoutOrder = nextOrd(), ClipsDescendants = true}, home)
round(banner, 12)
stroke(banner)
label(banner, "WELCOME BACK", 9, C.mute, FM, UDim2.fromOffset(16, 14), UDim2.new(0.6, 0, 0, 14))
local nameLbl = label(banner, lp.DisplayName, 22, C.text, FB, UDim2.fromOffset(16, 30), UDim2.new(0.6, 0, 0, 30))
local userLbl = label(banner, "@" .. lp.Name, 11, C.mute, F, UDim2.fromOffset(16, 60), UDim2.new(0.6, 0, 0, 16))
local bust = new("ImageLabel", {
    BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -10, 1, 0),
    Size = UDim2.fromOffset(92, 92), ScaleType = Enum.ScaleType.Fit,
    Image = "rbxthumb://type=AvatarBust&id=" .. lp.UserId .. "&w=150&h=150",
}, banner)

-- statistik
local statsCard = new("Frame", {Size = UDim2.new(1, 0, 0, 152), BackgroundColor3 = C.card, BorderSizePixel = 0, LayoutOrder = nextOrd()}, home)
round(statsCard, 12)
stroke(statsCard)

local N = 30
local function makeBars(parent, pos, sz)
    local holder = new("Frame", {BackgroundTransparency = 1, Position = pos, Size = sz}, parent)
    local bars, hist = {}, {}
    for i = 1, N do
        hist[i] = 0
        bars[i] = new("Frame", {
            AnchorPoint = Vector2.new(0, 1), Position = UDim2.new((i - 1) / N, 0, 1, 0),
            Size = UDim2.new(1 / N, -2, 0, 10), BackgroundColor3 = C.off, BorderSizePixel = 0,
        }, holder)
        round(bars[i], 2)
    end
    return function(v, max, col)
        table.remove(hist, 1)
        hist[#hist + 1] = v
        for i = 1, N do
            local h = math.clamp(hist[i] / max, 0, 1)
            bars[i].Size = UDim2.new(1 / N, -2, 0, 10 + math.floor(h * 10))
            bars[i].BackgroundColor3 = (i == N) and col or C.off
        end
    end
end

ico(statsCard, I.fps, 12, C.mute, UDim2.fromOffset(16, 12), UDim2.fromOffset(14, 14))
label(statsCard, "FPS", 10, C.mute, FM, UDim2.fromOffset(34, 12), UDim2.new(0.5, -40, 0, 14))
local fpsVal = label(statsCard, "-", 24, C.good, FB, UDim2.fromOffset(16, 28), UDim2.new(0.5, -24, 0, 32))
local fpsBars = makeBars(statsCard, UDim2.fromOffset(16, 64), UDim2.new(0.5, -28, 0, 22))
ico(statsCard, I.ping, 12, C.mute, UDim2.new(0.5, 8, 0, 12), UDim2.fromOffset(14, 14))
label(statsCard, "PING", 10, C.mute, FM, UDim2.new(0.5, 26, 0, 12), UDim2.new(0.5, -40, 0, 14))
local pingVal = label(statsCard, "-", 24, C.good, FB, UDim2.new(0.5, 8, 0, 28), UDim2.new(0.5, -24, 0, 32))
local pingBars = makeBars(statsCard, UDim2.new(0.5, 8, 0, 64), UDim2.new(0.5, -28, 0, 22))

local plrVal = label(statsCard, "-", 15, C.text, FM, UDim2.fromOffset(16, 100), UDim2.new(0.5, -24, 0, 20))
label(statsCard, "PLAYERS", 9, C.mute, FM, UDim2.fromOffset(16, 122), UDim2.new(0.5, -24, 0, 14))
local sessVal = label(statsCard, "0s", 15, C.text, FM, UDim2.new(0.5, 8, 0, 100), UDim2.new(0.5, -24, 0, 20))
label(statsCard, "SESSION", 9, C.mute, FM, UDim2.new(0.5, 8, 0, 122), UDim2.new(0.5, -24, 0, 14))

local t0 = os.clock()
local function fmtTime(s)
    s = math.floor(s)
    if s < 60 then return s .. "s" end
    if s < 3600 then return math.floor(s / 60) .. "m " .. (s % 60) .. "s" end
    return math.floor(s / 3600) .. "h " .. math.floor((s % 3600) / 60) .. "m"
end

local frames, acc = 0, 0
track(RunService.RenderStepped:Connect(function(dt)
    frames += 1
    acc += dt
    if acc < 0.5 then return end
    local fps = math.floor(frames / acc + 0.5)
    frames, acc = 0, 0
    local fc = fps >= 50 and C.good or (fps >= 30 and C.warn or C.bad)
    fpsVal.Text = tostring(fps)
    fpsVal.TextColor3 = fc
    fpsBars(fps, 120, fc)

    local ping = 0
    pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5) end)
    local pc = ping <= 100 and C.good or (ping <= 200 and C.warn or C.bad)
    pingVal.Text = ping .. "ms"
    pingVal.TextColor3 = pc
    pingBars(ping, 300, pc)

    plrVal.Text = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
    sessVal.Text = fmtTime(os.clock() - t0)
end))

-- kartu game
local gameCard = new("Frame", {Size = UDim2.new(1, 0, 0, 172), BackgroundColor3 = C.card, BorderSizePixel = 0, LayoutOrder = nextOrd()}, home)
round(gameCard, 12)
stroke(gameCard)
local gIcon = new("ImageLabel", {
    Position = UDim2.fromOffset(16, 16), Size = UDim2.fromOffset(44, 44), BackgroundColor3 = C.item,
    Image = "rbxthumb://type=GameIcon&id=" .. game.GameId .. "&w=150&h=150",
}, gameCard)
round(gIcon, 10)
local gameName = label(gameCard, "...", 15, C.text, FM, UDim2.fromOffset(70, 16), UDim2.new(1, -86, 0, 22))
local gameSub = label(gameCard, "", 11, C.mute, F, UDim2.fromOffset(70, 40), UDim2.new(1, -86, 0, 16))
local function refreshSub(creator)
    gameSub.Text = (creator and ("by " .. creator .. "  ·  ") or "") .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers .. " players"
end
refreshSub()
task.spawn(function()
    local ok, info = pcall(function() return Market:GetProductInfo(game.PlaceId) end)
    if ok and info and info.Name then
        gameName.Text = info.Name
        profGame.Text = info.Name
        local cr = info.Creator and info.Creator.Name
        refreshSub(cr)
        for _, t in ipairs(tabs) do
            if t.page == home then t.heading = "Welcome to " .. info.Name .. "!" end
        end
        if tabs[1] and tabs[1].page.Visible then title.Text = tabs[1].heading end
        env.RisyadhGameName = info.Name
    else
        gameName.Text = "Place " .. game.PlaceId
        profGame.Text = "Place " .. game.PlaceId
    end
end)

local btnRow = new("Frame", {Position = UDim2.fromOffset(16, 72), Size = UDim2.new(1, -32, 0, 64), BackgroundTransparency = 1}, gameCard)
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
}, btnRow)
local function rowBtn(glyph, txt, cb)
    local b = new("TextButton", {
        Size = UDim2.new(0.25, -6, 1, 0), BackgroundColor3 = C.item, Text = "",
        AutoButtonColor = false, LayoutOrder = nextOrd(),
    }, btnRow)
    round(b, 10)
    stroke(b)
    pressFx(b, 10)
    ico(b, glyph, 18, C.text, UDim2.new(0, 0, 0, 8), UDim2.new(1, 0, 0, 24))
    local lb = label(b, txt, 11, C.mute, FM, UDim2.new(0, 0, 0, 38), UDim2.new(1, 0, 0, 16), CENTER)
    b.Activated:Connect(function() task.spawn(cb, lb, txt) end)
end
rowBtn(I.rejoin, "Rejoin", function()
    if #Players:GetPlayers() <= 1 then
        -- server sepi: instance yang sama nggak bisa dimasuki lagi, jadi cari server baru
        pcall(function() TeleportService:Teleport(game.PlaceId, lp) end)
    else
        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp) end)
    end
end)
rowBtn(I.hop, "Hop", function(b, t)
    flash(b, "...", t)
    if not hop(false) then flash(b, "Gagal", t) end
end)
rowBtn(I.lowest, "Lowest", function(b, t)
    flash(b, "...", t)
    if not hop(true) then flash(b, "Gagal", t) end
end)
rowBtn(I.copy, "Job ID", function(b, t)
    if setclipboard then
        setclipboard(game.JobId)
        flash(b, "Tersalin", t)
    else
        flash(b, "No clip", t)
    end
end)

local jid = game.JobId
local jshort = (#jid > 14) and (jid:sub(1, 8) .. "..." .. jid:sub(-4)) or (jid ~= "" and jid or "-")
label(gameCard, "Job " .. jshort .. "  ·  Place " .. game.PlaceId, 10, C.mute, F, UDim2.fromOffset(16, 144), UDim2.new(1, -32, 0, 16))

-- ===== MAIN =====
local mainTab = newTab("Main", I.main)
local OV = {}
do
    local box = new("Frame", {Size = UDim2.new(1, 0, 0, 58), BackgroundColor3 = C.card, BorderSizePixel = 0, LayoutOrder = nextOrd()}, mainTab)
    round(box, 12)
    stroke(box)
    new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder}, box)
    local names = {"STATUS", "STEALS", "SAFE SPOT", "TREADMILL"}
    local keys = {"status", "steals", "safe", "tread"}
    for k = 1, 4 do
        local tile = new("Frame", {Size = UDim2.new(0.25, 0, 1, 0), BackgroundTransparency = 1, LayoutOrder = k}, box)
        label(tile, names[k], 9, C.mute, FM, UDim2.fromOffset(14, 10), UDim2.new(1, -14, 0, 12))
        OV[keys[k]] = label(tile, "-", 15, C.text, FB, UDim2.fromOffset(14, 26), UDim2.new(1, -14, 0, 22))
        if k < 4 then
            new("Frame", {Position = UDim2.new(1, -1, 0, 12), Size = UDim2.new(0, 1, 1, -24), BackgroundColor3 = C.line, BorderSizePixel = 0}, tile)
        end
    end
end
local ml, mr = twoCol(mainTab)

-- tab Egg: Egg Farm + pengaturan base sendiri
local eggTab = newTab("Egg", I.badge, "Egg Farm")
local el, er = twoCol(eggTab)
local buildClient -- kartu Client dipasang di tab Settings

-- ===== AUTO: Treadmill, Safe Spot, Reconnect =====
-- dibungkus function sendiri biar jatah local (maks 200 per function) tidak habis
;(function()
    State.AutoTread, State.RunInPlace = false, false
    State.AutoSafe, State.PickFilter, State.ReturnDelay = false, "Egg/Brainrot", 0
    State.AutoReconnect = false
    State.AutoSteal, State.StealRange, State.StealTP, State.StealDelay, State.Steals = false, 15, true, 300, 0

    local treadCF, safeCF, lastCF, homeCF
    local homeAuto = false -- true = Home diset otomatis dari titik respawn (manual Set Home menimpa ini)
    -- Biasanya karakter respawn di base sendiri. Home otomatis ikut respawn terakhir,
    -- tapi tidak pernah menimpa Home yang kamu set manual.
    track(lp.CharacterAdded:Connect(function(ch)
        if not State.AutoHome or (homeCF and not homeAuto) then return end
        local hrp = ch:WaitForChild("HumanoidRootPart", 5)
        if not hrp then return end
        task.wait(1)
        if not State.AutoHome or (homeCF and not homeAuto) then return end
        homeCF = hrp.CFrame
        homeAuto = true
    end))
    local treadManual = false
    local atSafe = false
    local safePart
    local lastFind = 0

    local function posTable(cf) return cf and {cf.X, cf.Y, cf.Z} or nil end
    local function fromTable(v) if type(v) == "table" and #v == 3 then return CFrame.new(v[1], v[2], v[3]) end end

    -- cari treadmill otomatis. Lokasinya bisa beda tiap server, jadi dicari ulang berkala
    -- dan diprioritaskan yang dekat penanda "Your Base" / base milik lo.
    local treadCands, baseMarks = {}, {}
    local function classify(d)
        local n = d.Name:lower()
        if (d:IsA("BasePart") or d:IsA("Model")) and (n:find("treadmill") or n:find("tread mill")) then return 1 end
        if d:IsA("TextLabel") or d:IsA("TextButton") then
            local tx = tostring(d.Text):lower()
            if tx:find("treadmill") then return 2 end
            if tx:find("your base") then return "base" end
            local nm, dn = lp.Name:lower(), lp.DisplayName:lower()
            if (tx:find(nm, 1, true) or (#dn > 2 and tx:find(dn, 1, true)))
                and (tx:find("base", 1, true) or tx:find("plot", 1, true) or tx:find("house", 1, true)) then
                return "base"
            end
        end
        if d:IsA("ProximityPrompt") and ((d.ActionText or "") .. " " .. (d.ObjectText or "")):lower():find("treadmill") then return 2 end
        if (d:IsA("BasePart") or d:IsA("Model")) and n:find("conveyor") then return 3 end
    end
    local function addCand(d)
        local ok, tier = pcall(classify, d)
        if not (ok and tier) then return end
        if d:IsDescendantOf(gui) then return end
        if lp.Character and d:IsDescendantOf(lp.Character) then return end
        if tier == "base" then baseMarks[d] = true else treadCands[d] = tier end
    end
    local function scanTree(r0)
        for i, d in ipairs(r0:GetDescendants()) do
            addCand(d)
            if i % 4000 == 0 then task.wait() end
        end
    end
    task.spawn(function()
        scanTree(workspace)
        local pg = lp:FindFirstChildOfClass("PlayerGui")
        if pg then
            scanTree(pg)
            track(pg.DescendantAdded:Connect(addCand))
            track(pg.DescendantRemoving:Connect(function(d) baseMarks[d] = nil treadCands[d] = nil end))
        end
    end)
    track(workspace.DescendantAdded:Connect(addCand))
    track(workspace.DescendantRemoving:Connect(function(d) treadCands[d] = nil baseMarks[d] = nil end))

    local function guiPart(d)
        local cur = d.Parent
        if d:IsA("ProximityPrompt") then
            if cur and cur:IsA("Attachment") then cur = cur.Parent end
            return cur
        end
        while cur and not cur:IsA("SurfaceGui") and not cur:IsA("BillboardGui") and cur ~= game do cur = cur.Parent end
        if cur and (cur:IsA("SurfaceGui") or cur:IsA("BillboardGui")) then
            local a = cur.Adornee or cur.Parent
            if a and a:IsA("Attachment") then a = a.Parent end
            return a
        end
    end
    local function smallModelTop(part)
        local cur = part.Parent
        for _ = 1, 3 do
            if not cur or cur == workspace then break end
            if cur:IsA("Model") and not cur:FindFirstChildOfClass("Humanoid") then
                local ok, cf, size = pcall(function() return cur:GetBoundingBox() end)
                if ok and size.Magnitude <= 40 then return cf + Vector3.new(0, size.Y / 2 + 3, 0) end
            end
            cur = cur.Parent
        end
    end
    local function candCF(d)
        if d:IsA("BasePart") then
            return d.CFrame + Vector3.new(0, d.Size.Y / 2 + 3, 0)
        elseif d:IsA("Model") then
            local ok, cf, size = pcall(function() return d:GetBoundingBox() end)
            if ok then return cf + Vector3.new(0, size.Y / 2 + 3, 0) end
            return nil
        end
        local part = guiPart(d)
        if part and part:IsA("BasePart") then
            return smallModelTop(part) or (part.CFrame + Vector3.new(0, part.Size.Y / 2 + 3, 0))
        end
    end
    local function detectedAnchor()
        local r = root()
        local best, bd
        for d in pairs(baseMarks) do
            if d.Parent then
                local part = guiPart(d)
                local p
                if part and part:IsA("BasePart") then p = part.Position
                elseif part and part:IsA("Model") then p = part:GetPivot().Position end
                if p then
                    local dist = r and (p - r.Position).Magnitude or 0
                    if not bd or dist < bd then best, bd = p, dist end
                end
            end
        end
        return best
    end
    -- base sendiri: titik Home yang kamu set manual diprioritaskan, kalau kosong baru deteksi otomatis
    local function anchorPos()
        if homeCF then return homeCF.Position end
        return detectedAnchor()
    end
    local function matchesMe(v) return v == lp or v == lp.UserId or v == lp.Name or v == lp.DisplayName end
    local function isMine(d)
        local cur = d
        for _ = 1, 8 do
            cur = cur and cur.Parent
            if not cur or cur == workspace or cur == game then break end
            if cur.Name == lp.Name or cur.Name == tostring(lp.UserId) then return true end
            for _, v in pairs(cur:GetAttributes()) do
                if matchesMe(v) then return true end
            end
            for _, c in ipairs(cur:GetChildren()) do
                if c:IsA("ValueBase") then
                    local ok, v = pcall(function() return c.Value end)
                    if ok and matchesMe(v) then return true end
                end
            end
        end
        return false
    end
    -- true kalau objek ini jelas milik pemain LAIN (nama / atribut / value di induknya cocok)
    local function matchesOther(v)
        if v == nil or v == "" then return false end
        for _, pl2 in ipairs(Players:GetPlayers()) do
            if pl2 ~= lp and (v == pl2 or v == pl2.UserId or v == pl2.Name or v == pl2.DisplayName) then return true end
        end
        return false
    end
    local otherCache = setmetatable({}, {__mode = "k"})
    local function ownedByOther(d)
        local c = otherCache[d]
        if c and os.clock() - c.t < 5 then return c.v end
        local res = false
        local cur = d
        for _ = 1, 8 do
            cur = cur and cur.Parent
            if not cur or cur == workspace or cur == game then break end
            if matchesOther(cur.Name) then res = true break end
            for _, v in pairs(cur:GetAttributes()) do
                if matchesOther(v) then res = true break end
            end
            if res then break end
            for _, ch in ipairs(cur:GetChildren()) do
                if ch:IsA("ValueBase") then
                    local ok, v = pcall(function() return ch.Value end)
                    if ok and matchesOther(v) then res = true break end
                end
            end
            if res then break end
        end
        otherCache[d] = {v = res, t = os.clock()}
        return res
    end
    local function findTreadmill()
        local anchor = anchorPos()
        local r = root()
        local function pass(gate)
            local ref = anchor or (r and r.Position)
            local best, bRank, bTier, bDist
            for d, tier in pairs(treadCands) do
                if d.Parent then
                    local cf = candCF(d)
                    if cf then
                        local dist = ref and (cf.Position - ref).Magnitude or 0
                        if not (gate and anchor and dist > 150) then
                            local rank = isMine(d) and 0 or 1
                            if not best or rank < bRank
                                or (rank == bRank and (tier < bTier or (tier == bTier and dist < bDist))) then
                                best, bRank, bTier, bDist = cf, rank, tier, dist
                            end
                        end
                    end
                end
            end
            return best
        end
        return pass(true) or pass(false)
    end

    local function ensureSafe()
        if safeCF then return true end
        local r = root()
        if not r then return false end
        if not safePart or not safePart.Parent then
            safePart = Instance.new("Part")
            safePart.Name = "RisyadhSafe"
            safePart.Anchored = true
            safePart.Size = Vector3.new(40, 2, 40)
            safePart.Transparency = 0.6
            safePart.Position = r.Position + Vector3.new(0, 500, 0)
            safePart.Parent = workspace
        end
        safeCF = safePart.CFrame + Vector3.new(0, 4, 0)
        return true
    end
    track(gui.Destroying:Connect(function()
        if safePart then pcall(function() safePart:Destroy() end) end
    end))

    local function goSafe()
        local r = root()
        if not r or not ensureSafe() then return end
        if not atSafe then lastCF = r.CFrame end
        atSafe = true
        r.CFrame = safeCF
        local d = State.ReturnDelay
        if d > 0 then
            task.delay(d, function()
                local r2 = root()
                if r2 and lastCF and atSafe then
                    atSafe = false
                    r2.CFrame = lastCF
                end
            end)
        end
    end

    Base.goHome = function()
        local r = root()
        if not r then return false end
        if homeCF then r.CFrame = homeCF return true end
        local a = detectedAnchor()
        if a then r.CFrame = CFrame.new(a + Vector3.new(0, 4, 0)) return true end
        return false
    end
    Base.goSafe = function() goSafe() end

    -- Treadmill
    local tm = card(mr, "Treadmill", I.move)
    toggle(tm, "Auto Treadmill", false, function(v)
        State.AutoTread = v
        atSafe = false
        if v and not treadManual then
            treadCF = findTreadmill()
            lastFind = os.clock()
        end
    end)
    toggle(tm, "Run in Place", false, function(v) State.RunInPlace = v end)
    -- Set Spot / Find itu opsional; Auto Treadmill nyari treadmill sendiri
    btnPair(tm, "Set Spot", function(b, t)
        local r = root()
        if r then treadCF = r.CFrame treadManual = true flash(b, "Tersimpan", t) end
    end, "Find", function(b, t)
        local cf = findTreadmill()
        if cf then treadCF = cf treadManual = false flash(b, "Ketemu", t) else flash(b, "Nggak ada", t) end
    end)
    Controls["Treadmill Spot"] = {get = function() return posTable(treadCF) end, set = function(v) local cf = fromTable(v) if cf then treadCF = cf treadManual = true end end}

    -- Auto Steal
    local lastSafeTrig = 0
    local function triggerSafe()
        if os.clock() - lastSafeTrig < 1.5 then return end
        lastSafeTrig = os.clock()
        task.spawn(function()
            task.wait(State.StealDelay / 1000)
            goSafe()
        end)
    end
    local handled = setmetatable({}, {__mode = "k"})
    local function isSteal(p)
        return ((p.ActionText or ""):lower():find("steal")) ~= nil
    end
    local function onSteal(p)
        if handled[p] and os.clock() - handled[p] < 1.5 then return end
        handled[p] = os.clock()
        State.Steals += 1
        if State.StealTP then triggerSafe() end
    end
    track(PPS.PromptTriggered:Connect(function(p, plr)
        if plr == lp and isSteal(p) then onSteal(p) end
    end))
    task.spawn(function()
        while alive do
            task.wait(0.3)
            if State.AutoSteal and fireproximityprompt and not atSafe then
                local r = root()
                if r then
                    for p in pairs(prompts) do
                        if p.Parent and p.Enabled and isSteal(p) and (not handled[p] or os.clock() - handled[p] > 1.5) then
                            local par = p.Parent
                            local pos = par:IsA("BasePart") and par.Position or (par:IsA("Attachment") and par.WorldPosition) or nil
                            if pos and (pos - r.Position).Magnitude <= State.StealRange then
                                if pcall(fireproximityprompt, p) then onSteal(p) end
                                break
                            end
                        end
                    end
                end
            end
        end
    end)

    local as = card(ml, "Auto Steal", I.pointer)
    toggle(as, "Auto Steal", false, function(v) State.AutoSteal = v end)
    slider(as, "Steal Range", 5, 60, 15, function(v) State.StealRange = v end, " st")
    toggle(as, "TP to Safe after Steal", true, function(v) State.StealTP = v end)
    slider(as, "TP Delay", 0, 3000, 300, function(v) State.StealDelay = v end, "ms")

    -- Interact
    local ia = card(mr, "Interact", I.pointer)
    toggle(ia, "Instant Prompt", false, function(v) State.Instant = v end)
    toggle(ia, "Auto Click Tool", false, function(v) State.AutoClick = v end)
    slider(ia, "Click Delay", 50, 2000, 200, function(v) State.ClickDelay = v end, "ms")
    task.spawn(function()
        while alive do
            task.wait(State.ClickDelay / 1000)
            if State.AutoClick and not atSafe then
                local ch = lp.Character
                local tl = ch and ch:FindFirstChildOfClass("Tool")
                if tl then pcall(function() tl:Activate() end) end
            end
        end
    end)

    -- Safe spot
    local sf = card(ml, "Safe Spot", "pin")
    toggle(sf, "Auto TP on Pickup", false, function(v) State.AutoSafe = v end)
    dropdown(sf, "Pickup Filter", {"Egg/Brainrot", "Any tool"}, "Egg/Brainrot", function(v) State.PickFilter = v end)
    slider(sf, "Return After", 0, 30, 0, function(v) State.ReturnDelay = v end, "s")
    btnPair(sf, "Set Safe", function(b, t)
        local r = root()
        if r then safeCF = r.CFrame flash(b, "Tersimpan", t) end
    end, "Go Safe", function(b, t)
        goSafe()
        flash(b, "OK", t)
    end)
    button(sf, "Back From Safe", function()
        local r = root()
        if r and lastCF then atSafe = false r.CFrame = lastCF end
    end)
    Controls["Safe Spot"] = {get = function() return posTable(safeCF) end, set = function(v) safeCF = fromTable(v) or safeCF end}

    -- deteksi pickup tool baru
    local seen = setmetatable({}, {__mode = "k"})
    local function nameMatch(n)
        n = n:lower()
        return n:find("egg") or n:find("brainrot") or n:find("brain")
    end
    local function onTool(tool)
        if not tool:IsA("Tool") or seen[tool] then return end
        seen[tool] = true
        if not State.AutoSafe then return end
        if State.PickFilter == "Egg/Brainrot" and not nameMatch(tool.Name) then return end
        triggerSafe()
    end
    local function hookContainer(c)
        if not c then return end
        for _, t in ipairs(c:GetChildren()) do if t:IsA("Tool") then seen[t] = true end end
        track(c.ChildAdded:Connect(function(t) task.spawn(onTool, t) end))
    end
    hookContainer(lp:FindFirstChildOfClass("Backpack"))
    hookContainer(lp.Character)
    track(lp.ChildAdded:Connect(function(c) if c:IsA("Backpack") then hookContainer(c) end end))
    track(lp.CharacterAdded:Connect(function(ch) task.wait(0.3) hookContainer(ch) end))

    -- ===== EGG FARM: auto place, auto hatch, auto farm =====
    State.AutoPlaceEgg, State.AutoHatch, State.AutoFarmEgg = false, false, false
    State.EggDelay, State.EggRange = 1.5, 25
    State.EggRarity = {}
    State.BaseRadius, State.PlaceMode, State.AutoCollectBase = 60, "Auto", false

    local function pText(p)
        return ((p.ActionText or "") .. " " .. (p.ObjectText or "") .. " " .. (p.Parent and p.Parent.Name or "")):lower()
    end
    local function pPos(p)
        local par = p.Parent
        if not par then return nil end
        if par:IsA("BasePart") then return par.Position end
        if par:IsA("Attachment") then return par.WorldPosition end
        if par:IsA("Model") then return par:GetPivot().Position end
    end
    local function holdingEgg()
        local ch = lp.Character
        if not ch then return nil end
        for _, t in ipairs(ch:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find("egg") and Base.rarityPass(t, State.EggRarity) then return t end
        end
    end
    local function firstEggTool()
        local bp = lp:FindFirstChildOfClass("Backpack")
        if not bp then return nil end
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find("egg") and Base.rarityPass(t, State.EggRarity) then return t end
        end
    end
    -- cari prompt berdasarkan kata kunci. mineOnly = cuma yang ada di base sendiri.
    -- Kalau Home sudah di-set: hanya yang dalam radius Base Radius dari Home.
    -- Hasil diurutkan: milik sendiri dulu, lalu yang paling dekat ke base.
    local function findPrompts(words, mineOnly)
        local anchor = anchorPos()
        local r = root()
        local list = {}
        for p in pairs(prompts) do
            if p.Parent and p.Enabled then
                local tx = pText(p)
                for _, w in ipairs(words) do
                    if tx:find(w, 1, true) then
                        local pos = pPos(p)
                        if pos then
                            local mine = isMine(p)
                            local ok = true
                            if mineOnly then
                                -- base sendiri = milik kita ATAU dalam Base Radius dari Home,
                                -- tapi yang jelas milik pemain lain (base tetangga) selalu dibuang
                                if ownedByOther(p) then
                                    ok = false
                                elseif mine then
                                    ok = true
                                else
                                    ok = anchor ~= nil and (pos - anchor).Magnitude <= State.BaseRadius
                                end
                            end
                            if ok then
                                list[#list + 1] = {
                                    p = p, pos = pos, rank = mine and 0 or 1,
                                    d = anchor and (pos - anchor).Magnitude or (r and (pos - r.Position).Magnitude or 0),
                                }
                            end
                        end
                        break
                    end
                end
            end
        end
        table.sort(list, function(a, b)
            if a.rank ~= b.rank then return a.rank < b.rank end
            return a.d < b.d
        end)
        return list
    end
    -- teleport sebentar ke dekat target, jalanin fn, lalu balik
    local function useAt(pos, fn)
        local r = root()
        if not r then return end
        local back = r.CFrame
        local far = (pos - r.Position).Magnitude > 10
        if far then
            r.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            task.wait(0.15)
        end
        pcall(fn)
        if far then
            task.wait(0.1)
            local r2 = root()
            if r2 then r2.CFrame = back end
        end
    end

    local hatchCd = setmetatable({}, {__mode = "k"})
    local function doHatch()
        local hl = findPrompts({"hatch"}, true)
        if #hl == 0 and Base.trigger then Base.trigger({"hatch"}) end -- fallback: tombol UI / remote
        for _, e in ipairs(hl) do
            if atSafe or not (State.AutoHatch or State.AutoFarmEgg) then return end
            if not pText(e.p):find("steal", 1, true) and (not hatchCd[e.p] or os.clock() - hatchCd[e.p] > State.HatchCd) then
                hatchCd[e.p] = os.clock()
                useAt(e.pos, function() fireproximityprompt(e.p) end)
                task.wait(0.3)
            end
        end
    end

    local placeCd = setmetatable({}, {__mode = "k"})
    local function doPlace()
        local tool = holdingEgg()
        if not tool then
            local t = firstEggTool()
            local h = hum()
            if not (t and h) then return end
            h:EquipTool(t)
            task.wait(0.25)
            tool = holdingEgg()
            if not tool then return end
        end
        -- 1) prompt tempat taruh telur di base sendiri (paling dekat ke Home dulu).
        --    Spot yang baru dipakai dilewati sebentar supaya telur nggak ditaruh di spot yang sama terus.
        if State.PlaceMode ~= "Tool Click" then
            local spots = findPrompts({"place", "plant", "incubat", "nest"}, true)
            local usable = 0
            for _, e in ipairs(spots) do
                local tx = pText(e.p)
                if not (tx:find("hatch", 1, true) or tx:find("collect", 1, true) or tx:find("steal", 1, true)
                    or tx:find("buy", 1, true)) then
                    usable += 1
                    if not placeCd[e.p] or os.clock() - placeCd[e.p] > State.PlaceCd then
                        placeCd[e.p] = os.clock()
                        useAt(e.pos, function() fireproximityprompt(e.p) end)
                        return
                    end
                end
            end
            if usable > 0 or State.PlaceMode == "Prompt" then return end
        end
        -- 2) fallback: pindah ke base sendiri lalu klik pakai tool di tanah
        local anchor = anchorPos()
        local r = root()
        if not (anchor and r) then return end
        local back = r.CFrame
        local off = Vector3.new(math.random(-6, 6), 0, math.random(-6, 6))
        r.CFrame = CFrame.new(anchor + off + Vector3.new(0, 4, 0))
        task.wait(0.2)
        pcall(function() tool:Activate() end)
        task.wait(0.2)
        local r2 = root()
        if r2 then r2.CFrame = back end
    end

    local function doCollect()
        local r = root()
        if not r then return end
        local words = {"collect", "claim", "pick", "grab", "take"}
        for _, e in ipairs(findPrompts(words, false)) do
            if atSafe or not State.AutoFarmEgg then return end
            if pText(e.p):find("egg") and not pText(e.p):find("steal") then
                if isMine(e.p) then
                    useAt(e.pos, function() fireproximityprompt(e.p) end)
                elseif (e.pos - r.Position).Magnitude <= State.EggRange then
                    pcall(fireproximityprompt, e.p)
                end
                task.wait(0.2)
            end
        end
    end

    local baseCd = setmetatable({}, {__mode = "k"})
    local function doCollectBase()
        for _, e in ipairs(findPrompts({"collect", "claim"}, true)) do
            if atSafe or not State.AutoCollectBase then return end
            if not pText(e.p):find("steal") and (not baseCd[e.p] or os.clock() - baseCd[e.p] > 2) then
                baseCd[e.p] = os.clock()
                useAt(e.pos, function() fireproximityprompt(e.p) end)
                task.wait(0.25)
            end
        end
    end

    Base.useAt, Base.findPrompts, Base.pText = useAt, findPrompts, pText
    Base.atSafe = function() return atSafe end

    local eggBusy = false
    task.spawn(function()
        while alive do
            task.wait(State.EggDelay)
            if (State.AutoPlaceEgg or State.AutoHatch or State.AutoFarmEgg or State.AutoCollectBase) and fireproximityprompt and not atSafe and not eggBusy then
                eggBusy = true
                pcall(function()
                    if State.AutoFarmEgg then doCollect() end
                    if State.AutoCollectBase then doCollectBase() end
                    if State.AutoHatch or State.AutoFarmEgg then doHatch() end
                    if State.AutoPlaceEgg or State.AutoFarmEgg then doPlace() end
                end)
                eggBusy = false
            end
        end
    end)

    local eg = card(el, "Egg Farm", I.badge)
    toggle(eg, "Auto Place Egg", false, function(v) State.AutoPlaceEgg = v end)
    toggle(eg, "Auto Hatch Egg", false, function(v) State.AutoHatch = v end)
    toggle(eg, "Auto Farm Egg", false, function(v) State.AutoFarmEgg = v end)
    toggle(eg, "Auto Collect Base", false, function(v) State.AutoCollectBase = v end)
    Base.multiSelect(eg, "Egg Rarities", Base.RARITIES, function(set) State.EggRarity = set end, "All")
    slider(eg, "Egg Delay", 300, 5000, 1500, function(v) State.EggDelay = v / 1000 end, "ms")

    -- My Base: titik rumah sendiri, dipakai Auto Place / Hatch / Collect
    local mb = card(er, "My Base", I.home)
    btnPair(mb, "Set Home", function(b, t)
        local r = root()
        if r then homeCF = r.CFrame homeAuto = false flash(b, "Tersimpan", t) end
    end, "Go Home", function(b, t)
        local r = root()
        if r and homeCF then r.CFrame = homeCF flash(b, "OK", t) else flash(b, "Set dulu", t) end
    end)
    btnPair(mb, "Detect Base", function(b, t)
        local a = detectedAnchor()
        if a then homeCF = CFrame.new(a + Vector3.new(0, 4, 0)) homeAuto = false flash(b, "Ketemu", t) else flash(b, "Nggak ada", t) end
    end, "Clear Home", function(b, t)
        homeCF = nil
        homeAuto = false
        flash(b, "Dihapus", t)
    end)
    slider(mb, "Base Radius", 20, 200, 60, function(v) State.BaseRadius = v end, " st")
    -- cek apakah script beneran ngenalin base lo: P = tempat taruh, H = hatch, C = collect
    local scanBtn
    scanBtn = button(mb, "Scan Base", function()
        local np = #findPrompts({"place", "plant", "incubat", "nest"}, true)
        local nh = #findPrompts({"hatch"}, true)
        local nc = #findPrompts({"collect", "claim"}, true)
        flash(scanBtn, ("P%d  H%d  C%d"):format(np, nh, nc), "Scan Base")
    end)
    Controls["Home Base"] = {get = function() return posTable(homeCF) end, set = function(v) homeCF = fromTable(v) or homeCF homeAuto = false end}

    -- loop treadmill
    local lastTick = 0
    track(RunService.Heartbeat:Connect(function()
        if not State.AutoTread or atSafe then return end
        local r = root()
        if not r then return end
        if State.RunInPlace then
            local h = hum()
            if h then h:Move(Vector3.new(0, 0, -1), true) end
        end
        if os.clock() - lastTick < 0.5 then return end
        lastTick = os.clock()
        if not treadManual and os.clock() - lastFind > (treadCF and 5 or 2) then
            lastFind = os.clock()
            local cf = findTreadmill()
            if cf then treadCF = cf end
        end
        if treadCF and (r.Position - treadCF.Position).Magnitude > 8 then
            r.CFrame = treadCF
        end
    end))

    task.spawn(function()
        while alive do
            task.wait(0.4)
            if not OV.status.Parent then break end
            local st = "Idle"
            if atSafe then st = "At safe"
            elseif State.AutoSteal then st = "Stealing"
            elseif State.AutoPlaceEgg or State.AutoHatch or State.AutoFarmEgg or State.AutoCollectBase then
                st = anchorPos() and "Egg Farm" or "Set Home"
            elseif State.AutoTread then st = "Treadmill" end
            OV.status.Text = st
            OV.steals.Text = tostring(State.Steals)
            OV.safe.Text = safeCF and "Set" or "Auto"
            OV.tread.Text = treadCF and (treadManual and "Set" or "Found") or (State.AutoTread and "Searching" or "Auto")
        end
    end)

    -- Client: dipasang di tab Settings lewat buildClient(kolom)
    buildClient = function(col)
        local cl = card(col, "Client", I.sys)
        toggle(cl, "Anti AFK", false, function(v) State.AntiAFK = v end)
        local GuiService = game:GetService("GuiService")
        local reconnecting = false
        local function reconnect()
            if reconnecting or not State.AutoReconnect then return end
            reconnecting = true
            task.spawn(function()
                for _ = 1, 20 do
                    if not State.AutoReconnect or not alive then break end
                    pcall(function() TeleportService:Teleport(game.PlaceId, lp) end)
                    task.wait(8)
                end
                reconnecting = false
            end)
        end
        toggle(cl, "Auto Reconnect on Kick", false, function(v) State.AutoReconnect = v end)
        track(GuiService.ErrorMessageChanged:Connect(function()
            if State.AutoReconnect and GuiService:GetErrorMessage() ~= "" then
                task.wait(1.5)
                reconnect()
            end
        end))
        task.spawn(function()
            pcall(function()
                local cg = game:GetService("CoreGui")
                local pg = cg:WaitForChild("RobloxPromptGui", 15)
                local ov = pg and pg:WaitForChild("promptOverlay", 15)
                if ov then
                    track(ov.ChildAdded:Connect(function(c)
                        if c.Name == "ErrorPrompt" and State.AutoReconnect then
                            task.wait(1.5)
                            reconnect()
                        end
                    end))
                end
            end)
        end)
        toggle(cl, "FPS Boost", false, function(v)
            pcall(function()
                settings().Rendering.QualityLevel = v and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
            end)
        end)
        toggle(cl, "Unlock FPS", false, function(v)
            if setfpscap then pcall(setfpscap, v and 240 or 60) end
        end)
    end
end)()

-- ===== FITUR BARU: Rebirth, Sell, God Mode, Debug =====
;(function()
    local RS = game:GetService("ReplicatedStorage")
    local GuiService = game:GetService("GuiService")
    local VIM
    pcall(function() VIM = game:GetService("VirtualInputManager") end)
    State.AutoRebirth, State.AutoSell, State.GodMode = false, false, false
    State.SellRarity, State.KeepMutated = {}, true

    -- cache remote
    local remotes = {}
    local function addRemote(d)
        if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then remotes[d] = d.Name:lower() end
    end
    task.spawn(function()
        for i, d in ipairs(RS:GetDescendants()) do
            addRemote(d)
            if i % 3000 == 0 then task.wait() end
        end
    end)
    track(RS.DescendantAdded:Connect(addRemote))
    track(RS.DescendantRemoving:Connect(function(d) remotes[d] = nil end))

    local DENY = {"robux", "r$", "buy", "skip", "gift", "purchase", "gamepass", "trade", "delete", "steal", "product"}
    local function denied(tx)
        for _, x in ipairs(DENY) do
            if tx:find(x, 1, true) then return true end
        end
        return false
    end
    local function has(tx, w, whole)
        if whole then return (" " .. tx .. " "):find("%A" .. w .. "%A") ~= nil end
        return tx:find(w, 1, true) ~= nil
    end
    local function shown(d)
        local cur = d
        while cur and cur ~= game do
            if cur:IsA("GuiObject") and not cur.Visible then return false end
            if cur:IsA("ScreenGui") and not cur.Enabled then return false end
            cur = cur.Parent
        end
        return true
    end
    local function asButton(d)
        local cur = d
        for _ = 1, 4 do
            if not cur or cur:IsA("LayerCollector") then return nil end
            if cur:IsA("GuiButton") then return cur end
            cur = cur.Parent
        end
    end
    local function btnTexts(b)
        local t = {b.Name:lower()}
        if b:IsA("TextButton") then t[#t + 1] = b.Text:lower() end
        for _, d in ipairs(b:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") then t[#t + 1] = d.Text:lower() end
        end
        return table.concat(t, " ")
    end
    -- cari tombol UI yang kelihatan dan teks/namanya cocok kata kunci
    local function findButtons(words, whole)
        local pg = lp:FindFirstChildOfClass("PlayerGui")
        local out, seen = {}, {}
        if not pg then return out end
        for i, d in ipairs(pg:GetDescendants()) do
            if d:IsA("GuiButton") or d:IsA("TextLabel") then
                local own = d.Name:lower()
                if d:IsA("TextLabel") or d:IsA("TextButton") then own = own .. " " .. d.Text:lower() end
                for _, w in ipairs(words) do
                    if has(own, w, whole) then
                        local b = asButton(d)
                        if b and not seen[b] and shown(b) then
                            local tx = btnTexts(b)
                            if not denied(tx) then
                                seen[b] = true
                                out[#out + 1] = {b = b, tx = tx}
                            end
                        end
                        break
                    end
                end
            end
            if i % 3000 == 0 then task.wait() end
        end
        return out
    end
    local function fireBtn(b)
        if getconnections then
            for _, ev in ipairs({b.Activated, b.MouseButton1Click, b.MouseButton1Down, b.MouseButton1Up}) do
                local ok, cs = pcall(getconnections, ev)
                if ok and type(cs) == "table" and #cs > 0 then
                    for _, c in ipairs(cs) do pcall(function() c:Fire() end) end
                    return true
                end
            end
        end
        -- fallback: klik layar beneran (dilewati kalau kena menu hub ini)
        if VIM and b.AbsoluteSize.X > 0 then
            local pos = b.AbsolutePosition + b.AbsoluteSize / 2
            local sg = b:FindFirstAncestorOfClass("ScreenGui")
            if sg and not sg.IgnoreGuiInset then pos = pos + GuiService:GetGuiInset() end
            if main.Visible then
                local mp, ms = main.AbsolutePosition, main.AbsoluteSize
                if pos.X >= mp.X and pos.X <= mp.X + ms.X and pos.Y >= mp.Y and pos.Y <= mp.Y + ms.Y then return false end
            end
            return pcall(function()
                VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                task.wait(0.05)
                VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
            end)
        end
        return false
    end
    local RDENY = {"buy", "purchase", "robux", "gift", "steal", "trade", "delete", "product", "gamepass", "skip"}
    local function fireRemote(words)
        local fired = false
        for r, n in pairs(remotes) do
            for _, w in ipairs(words) do
                if n:find(w, 1, true) then
                    local bad = false
                    for _, x in ipairs(RDENY) do
                        if n:find(x, 1, true) then bad = true break end
                    end
                    if not bad then
                        task.spawn(pcall, function()
                            if r:IsA("RemoteEvent") then r:FireServer() else r:InvokeServer() end
                        end)
                        fired = true
                    end
                    break
                end
            end
        end
        return fired
    end
    Base.clickGui = function(words, whole)
        for _, c in ipairs(findButtons(words, whole)) do
            if fireBtn(c.b) then return true end
        end
        return false
    end
    Base.trigger = function(words)
        return Base.clickGui(words) or fireRemote(words)
    end

    -- ===== Auto Rebirth =====
    task.spawn(function()
        while alive do
            task.wait(3)
            if State.AutoRebirth then
                pcall(function()
                    local cands = findButtons({"rebirth"})
                    local did = false
                    for _, c in ipairs(cands) do
                        local pct = c.tx:match("(%d+)%s*%%")
                        if not pct or tonumber(pct) >= 100 then
                            if fireBtn(c.b) then did = true break end
                        end
                    end
                    if did then
                        task.wait(0.7)
                        if not Base.clickGui({"confirm", "yes"}, true) then Base.clickGui({"rebirth now"}) end
                    elseif #cands == 0 then
                        fireRemote({"rebirth"})
                    end
                end)
            end
        end
    end)

    -- ===== Auto Sell (cuma item Tool yang rarity-nya kebaca dan dipilih) =====
    local function sellOnce()
        local sel = State.SellRarity
        if next(sel) == nil then return end
        local bp, h = lp:FindFirstChildOfClass("Backpack"), hum()
        if not (bp and h) then return end
        local list = {}
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                local r = Base.rarityOf(t)
                if r and sel[r] then
                    local mut = t.Name:lower():find("mutat", 1, true) or t:GetAttribute("Mutated") or t:GetAttribute("Mutation")
                    if not (State.KeepMutated and mut) then list[#list + 1] = t end
                end
            end
        end
        for i = 1, math.min(#list, 8) do
            if not State.AutoSell or (Base.atSafe and Base.atSafe()) then return end
            h:EquipTool(list[i])
            task.wait(0.2)
            local done = false
            if fireproximityprompt then
                for _, e in ipairs(Base.findPrompts({"sell"}, false)) do
                    if not Base.pText(e.p):find("steal", 1, true) then
                        Base.useAt(e.pos, function() fireproximityprompt(e.p) end)
                        done = true
                        break
                    end
                end
            end
            if not done then Base.trigger({"sell"}) end
            task.wait(0.3)
        end
        pcall(function() h:UnequipTools() end)
    end
    task.spawn(function()
        while alive do
            task.wait(2)
            if State.AutoSell then pcall(sellOnce) end
        end
    end)

    -- ===== God Mode: kunci health lokal, anti knockback / ragdoll / stun =====
    local lastVel = Vector3.zero
    local function setStates(on)
        local h = hum()
        if not h then return end
        for _, st in ipairs({Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.FallingDown}) do
            pcall(function() h:SetStateEnabled(st, on) end)
        end
    end
    Base.setGod = function(v)
        State.GodMode = v
        lastVel = Vector3.zero
        setStates(not v)
    end
    track(lp.CharacterAdded:Connect(function()
        task.wait(1)
        lastVel = Vector3.zero
        if State.GodMode then setStates(false) end
    end))
    track(RunService.Heartbeat:Connect(function()
        if not State.GodMode then return end
        local h, r = hum(), root()
        if not (h and r) then return end
        if h.Health > 0 and h.Health < h.MaxHealth then pcall(function() h.Health = h.MaxHealth end) end
        if h.PlatformStand and not State.Fly then h.PlatformStand = false end
        local st = h:GetState()
        if st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown then
            h:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        local v = r.AssemblyLinearVelocity
        local limit = math.max(70, (State.WalkSpeed and State.Speed or 16) * 2.5, State.Fly and State.FlySpeed * 2.5 or 0)
        local dx, dz = v.X - lastVel.X, v.Z - lastVel.Z
        if math.sqrt(dx * dx + dz * dz) > limit then
            r.AssemblyLinearVelocity = Vector3.new(lastVel.X, v.Y, lastVel.Z)
            v = r.AssemblyLinearVelocity
        end
        lastVel = v
        if r.AssemblyAngularVelocity.Magnitude > 30 then r.AssemblyAngularVelocity = Vector3.zero end
    end))

    -- ===== Debug dump (kirim hasilnya biar nama remote/tombol game bisa dipasang pas) =====
    local function dump()
        local L = {}
        local function add(x) L[#L + 1] = tostring(x):sub(1, 200) end
        add("== Risyadh Debug ==")
        add("Place " .. game.PlaceId .. " | " .. tostring(env.RisyadhGameName))
        add("-- Remotes")
        local rl = {}
        for r in pairs(remotes) do rl[#rl + 1] = r.ClassName .. " " .. r:GetFullName() end
        table.sort(rl)
        for i = 1, math.min(#rl, 300) do add(rl[i]) end
        add("-- Buttons (kelihatan)")
        local pg = lp:FindFirstChildOfClass("PlayerGui")
        local n = 0
        if pg then
            for i, d in ipairs(pg:GetDescendants()) do
                if d:IsA("GuiButton") and shown(d) and n < 200 then
                    n += 1
                    add(d:GetFullName() .. " | " .. btnTexts(d):sub(1, 60))
                end
                if i % 3000 == 0 then task.wait() end
            end
        end
        add("-- Tools")
        local function tl(c)
            if not c then return end
            for _, t in ipairs(c:GetChildren()) do
                if t:IsA("Tool") then
                    local a = {}
                    for k, v in pairs(t:GetAttributes()) do a[#a + 1] = k .. "=" .. tostring(v) end
                    for _, ch in ipairs(t:GetChildren()) do
                        if ch:IsA("ValueBase") then a[#a + 1] = ch.Name .. "=" .. tostring(ch.Value) end
                    end
                    add(t.Name .. " {" .. table.concat(a, ", ") .. "}")
                end
            end
        end
        tl(lp:FindFirstChildOfClass("Backpack"))
        tl(lp.Character)
        add("-- Prompts")
        local seenP, c2 = {}, 0
        for p in pairs(prompts) do
            local k = (p.ActionText or "") .. " / " .. (p.ObjectText or "") .. " / " .. (p.Parent and p.Parent.Name or "")
            if not seenP[k] and c2 < 80 then seenP[k] = true c2 += 1 add(k) end
        end
        add("-- Player")
        for k, v in pairs(lp:GetAttributes()) do add(k .. "=" .. tostring(v)) end
        local ls = lp:FindFirstChild("leaderstats")
        if ls then
            for _, ch in ipairs(ls:GetChildren()) do
                if ch:IsA("ValueBase") then add(ch.Name .. "=" .. tostring(ch.Value)) end
            end
        end
        local text = table.concat(L, "\n")
        local ok = false
        if setclipboard then ok = pcall(setclipboard, text) end
        if writefile then pcall(writefile, "RisyadhHub_debug.txt", text) end
        return ok
    end

    -- ===== UI =====
    local sellC = card(el, "Auto Sell", I.pointer)
    toggle(sellC, "Auto Sell", false, function(v) State.AutoSell = v end)
    Base.multiSelect(sellC, "Sell Rarities", Base.RARITIES, function(set) State.SellRarity = set end, "None")
    toggle(sellC, "Keep Mutated", true, function(v) State.KeepMutated = v end)

    local rbC = card(er, "Rebirth", I.badge)
    toggle(rbC, "Auto Rebirth", false, function(v) State.AutoRebirth = v end)

    local dbC = card(er, "Debug", I.sys)
    local dbBtn
    dbBtn = button(dbC, "Copy Debug Info", function()
        flash(dbBtn, "...", "Copy Debug Info")
        local ok = dump()
        flash(dbBtn, ok and "Tersalin" or "Cek file", "Copy Debug Info")
    end)
end)()

-- ===== PLAYER =====
do
local player = newTab("Player", I.player)
local pl, pr = twoCol(player)

local mv = card(pl, "Movement", I.move)
toggle(mv, "WalkSpeed", false, function(v)
    State.WalkSpeed = v
    if not v then local h = hum() if h then h.WalkSpeed = 16 end end
end)
slider(mv, "Speed", 16, 200, State.Speed, function(v) State.Speed = v end)
toggle(mv, "Infinite Jump", false, function(v) State.InfJump = v end)
toggle(mv, "Noclip", false, function(v) State.Noclip = v end)
toggle(mv, "God Mode", false, function(v) if Base.setGod then Base.setGod(v) end end)
toggle(mv, "Jump Power", false, function(v)
    State.JumpOn = v
    if not v then local h = hum() if h then h.JumpPower = 50 end end
end)
slider(mv, "Jump Height", 50, 250, State.Jump, function(v) State.Jump = v end)
button(mv, "Reset Character", function()
    local h = hum()
    if h then h.Health = 0 end
end)

local fl = card(pr, "Fly", I.fly)
toggle(fl, "Fly", false, function(v)
    State.Fly = v
    if v then startFly() else stopFly() end
end)
slider(fl, "Fly Speed", 20, 300, State.FlySpeed, function(v) State.FlySpeed = v end)

local tp = card(pr, "Teleport", "pin")
btnPair(tp, "Go Home", function(b, t)
    flash(b, Base.goHome and Base.goHome() and "OK" or "Set Home dulu", t)
end, "Go Safe", function(b, t)
    if Base.goSafe then Base.goSafe() flash(b, "OK", t) end
end)

-- pilih pemain (dropdown) -> Teleport / Spectate
local plrMap, plrDD = {}, nil
local spectating
local function stopSpec()
    spectating = nil
    local cam, h = workspace.CurrentCamera, hum()
    if cam and h then cam.CameraSubject = h end
end
Base.stopSpec = stopSpec
local function refreshPlayers()
    plrMap = {}
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local l = p.DisplayName .. " (@" .. p.Name .. ")"
            plrMap[l] = p
            names[#names + 1] = l
        end
    end
    table.sort(names)
    plrDD.setOptions(names, true)
end
plrDD = dropdown(tp, "Player", {}, nil, function() end, true)
refreshPlayers()
local function selPlayer()
    local v = plrDD.get()
    return v and plrMap[v] or nil
end
btnPair(tp, "Teleport", function(b, t)
    local p = selPlayer()
    local r = root()
    local tr = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    if r and tr then
        r.CFrame = tr.CFrame * CFrame.new(0, 0, 4)
        flash(b, "OK", t)
    else
        flash(b, "Pilih player", t)
    end
end, "Spectate", function(b, t)
    if spectating then stopSpec() flash(b, "Stop", t) return end
    local p = selPlayer()
    local h = p and p.Character and p.Character:FindFirstChildOfClass("Humanoid")
    if h and workspace.CurrentCamera then
        spectating = p
        workspace.CurrentCamera.CameraSubject = h
        flash(b, "Nonton", t)
    else
        flash(b, "Pilih player", t)
    end
end)
track(Players.PlayerAdded:Connect(function() task.wait(0.3) refreshPlayers() end))
track(Players.PlayerRemoving:Connect(function(p)
    if p == spectating then stopSpec() end
    task.delay(0.2, refreshPlayers)
end))
track(lp.CharacterAdded:Connect(function() if spectating then task.wait(0.5) stopSpec() end end))

end

-- ===== VISUAL =====
do
local visual = newTab("Visual", "eye")
local vl, vr = twoCol(visual)

local esp = card(vl, "ESP", "eye")
toggle(esp, "ESP Players", false, setESP)
toggle(esp, "Highlight", true, function(v)
    State.ESPHL = v
    if State.ESP then setESP(true) end
end)
toggle(esp, "Show Distance", true, function(v) State.ESPDist = v end)

local itemC = card(vl, "Item ESP", "eye")
toggle(itemC, "Egg ESP", false, function(v) State.ESPEgg = v end)
toggle(itemC, "Brainrot ESP", false, function(v) State.ESPBrain = v end)

local world = card(vr, "World", "sun")
toggle(world, "Fullbright", false, function(v)
    State.Fullbright = v
    if not v then restoreLight() end
end)
toggle(world, "No Fog", false, function(v)
    State.NoFog = v
    if not v then restoreLight() end
end)
toggle(world, "FOV Changer", false, function(v)
    State.FOVOn = v
    if not v then
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = origFOV end
    end
end)
slider(world, "FOV", 40, 120, State.FOV, function(v) State.FOV = v end)

end

-- ===== SETTINGS =====
do
local settingsTab = newTab("Settings", I.settings)
local sl, sr = twoCol(settingsTab)

-- Menu
local menuC = card(sl, "Menu", I.ui)

local toggleKey = Enum.KeyCode.RightControl
local binding = false
local keyRow = new("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = nextOrd()}, menuC)
reg(keyRow, "Toggle UI")
label(keyRow, "Toggle UI", 12, C.text, F, UDim2.new(), UDim2.new(0.5, 0, 1, 0))
local keyBtn = new("TextButton", {
    Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), BackgroundColor3 = C.item,
    Text = toggleKey.Name, TextColor3 = C.text, Font = FM, TextSize = 11, AutoButtonColor = false,
}, keyRow)
round(keyBtn, 8)
stroke(keyBtn)
pressFx(keyBtn, 8)
keyBtn.Activated:Connect(function()
    binding = true
    keyBtn.Text = "..."
end)
track(UIS.InputBegan:Connect(function(i, gp)
    if binding then
        if i.UserInputType == Enum.UserInputType.Keyboard then
            binding = false
            if i.KeyCode ~= Enum.KeyCode.Escape then toggleKey = i.KeyCode end
            keyBtn.Text = toggleKey.Name
        end
        return
    end
    if gp then return end
    if i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode == toggleKey then
        setMenu(not menuOpen)
    end
end))
Controls["Toggle UI"] = {
    get = function() return toggleKey.Name end,
    set = function(v)
        local ok, k = pcall(function() return Enum.KeyCode[v] end)
        if ok and k then toggleKey = k keyBtn.Text = k.Name end
    end,
}

local function applyFab(v)
    if v == "Always" then fab.Visible = true
    elseif v == "Mobile only" then fab.Visible = UIS.TouchEnabled
    else fab.Visible = not UIS.KeyboardEnabled end -- Hidden: tetap muncul kalau nggak ada keyboard, biar nggak terkunci
end
dropdown(menuC, "Toggle button", {"Always", "Mobile only", "Hidden"}, "Always", applyFab)
-- matiin semua fitur sekaligus (darurat). Toggle tampilan bawaan-ON dibiarkan.
local keepOn = {["Highlight"] = true, ["Show Distance"] = true, ["TP to Safe after Steal"] = true, ["Keep Mutated"] = true}
button(menuC, "Disable All Features", function()
    for k, h in pairs(Controls) do
        if not keepOn[k] then
            local ok, v = pcall(h.get)
            if ok and v == true then pcall(h.set, false) end
        end
    end
end)
button(menuC, "Unload Hub", function()
    if env.RisyadhUnload then env.RisyadhUnload() end
end)
buildClient(sl)

-- Configs
local cfgC = card(sr, "Configs", "folder")
local FS_OK = (writefile and readfile and isfile and listfiles and makefolder and isfolder) and true or false
local DIR = "RisyadhHub"
local function ensureDir()
    if not isfolder(DIR) then makefolder(DIR) end
end
local function cfgPath(n) return DIR .. "/" .. n .. ".json" end
local function listCfgs()
    local out = {}
    if not FS_OK then return out end
    pcall(function()
        ensureDir()
        for _, f in ipairs(listfiles(DIR)) do
            local n = tostring(f):match("([^/\\]+)%.json$")
            if n then out[#out + 1] = n end
        end
    end)
    table.sort(out)
    return out
end
local function collect()
    local t = {}
    for k, h in pairs(Controls) do
        local ok, v = pcall(h.get)
        if ok and v ~= nil then t[k] = v end
    end
    return t
end
local function applyCfg(t)
    for k, v in pairs(t) do
        local h = Controls[k]
        if h then pcall(h.set, v) end
    end
end
local function writeCfg(n)
    ensureDir()
    writefile(cfgPath(n), HttpService:JSONEncode(collect()))
end
local function readCfg(n)
    local ok, t = pcall(function() return HttpService:JSONDecode(readfile(cfgPath(n))) end)
    if ok and type(t) == "table" then return t end
end

local nameBox = new("TextBox", {
    Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.item, Text = "", PlaceholderText = "config name",
    PlaceholderColor3 = C.mute, TextColor3 = C.text, Font = F, TextSize = 11, ClearTextOnFocus = false,
    LayoutOrder = nextOrd(),
}, cfgC)
round(nameBox, 8)
stroke(nameBox)
local cfgSel
local cfgDD = dropdown(cfgC, "", listCfgs(), nil, function(v) cfgSel = v end, true)
local function refreshCfgs(selectName)
    cfgDD.setOptions(listCfgs(), false)
    cfgSel = nil
    if selectName then
        cfgDD.setOptions(listCfgs(), false)
        cfgDD.pick(selectName)
        cfgSel = selectName
    end
end
local function cleanName(n)
    n = (n or ""):gsub("[^%w_%- ]", ""):gsub("^%s+", ""):gsub("%s+$", "")
    return n
end

btnPair(cfgC, "Create", function(b, t)
    if not FS_OK then flash(b, "No FS", t) return end
    local n = cleanName(nameBox.Text)
    if n == "" then flash(b, "Isi nama", t) return end
    local ok = pcall(writeCfg, n)
    if ok then refreshCfgs(n) flash(b, "Dibuat", t) else flash(b, "Gagal", t) end
end, "Save", function(b, t)
    if not FS_OK then flash(b, "No FS", t) return end
    local n = cfgSel or cleanName(nameBox.Text)
    if not n or n == "" then flash(b, "Pilih config", t) return end
    local ok = pcall(writeCfg, n)
    if ok then refreshCfgs(n) flash(b, "Tersimpan", t) else flash(b, "Gagal", t) end
end)
btnPair(cfgC, "Load", function(b, t)
    if not (FS_OK and cfgSel) then flash(b, "Pilih config", t) return end
    local d = readCfg(cfgSel)
    if d then applyCfg(d) flash(b, "Dimuat", t) else flash(b, "Gagal", t) end
end, "Delete", function(b, t)
    if not (FS_OK and cfgSel and delfile) then flash(b, "Pilih config", t) return end
    pcall(delfile, cfgPath(cfgSel))
    refreshCfgs()
    flash(b, "Dihapus", t)
end)
btnPair(cfgC, "Set autoload", function(b, t)
    if not (FS_OK and cfgSel) then flash(b, "Pilih config", t) return end
    local ok = pcall(function() ensureDir() writefile(DIR .. "/autoload.txt", cfgSel) end)
    flash(b, ok and "Autoload" or "Gagal", t)
end, "Clear autoload", function(b, t)
    if not FS_OK then flash(b, "No FS", t) return end
    pcall(function() writefile(DIR .. "/autoload.txt", "") end)
    flash(b, "Dihapus", t)
end)

-- Interface
local ui = card(sl, "Interface", I.ui)
slider(ui, "UI Scale", 60, 120, 100, function(v) userScale = v / 100 uiScale.Scale = userScale end, "%")

task.defer(function()
    if not FS_OK then return end
    task.wait(0.5)
    local ok, n = pcall(function()
        return isfile(DIR .. "/autoload.txt") and readfile(DIR .. "/autoload.txt") or ""
    end)
    n = ok and cleanName(n) or ""
    if n ~= "" then
        local d = readCfg(n)
        if d then
            applyCfg(d)
            refreshCfgs(n)
        end
    end
end)
end

-- ===== UNLOAD =====
env.RisyadhUnload = function()
    pcall(restoreAll)
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    stopFly()
    local h = hum()
    if h then h.WalkSpeed = 16 end
    if gui then gui:Destroy() end
    env.RisyadhUnload = nil
end

tabs[1].pick()

setMenu(true)
