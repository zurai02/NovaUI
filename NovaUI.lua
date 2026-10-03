--[[
╔══════════════════════════════════════════════════════════════════════════════════╗
║  N O V A U I   ·   v 6 . 0   ·   " L u m e n "                                ║
╠══════════════════════════════════════════════════════════════════════════════════╣
║  Beautiful · Fast · Depth-layered · Mobile + PC · Zero external assets          ║
║  22 themes · 37 components · KeySystem · Config save/load                       ║
╠══════════════════════════════════════════════════════════════════════════════════╣
║  VISUAL DESIGN SYSTEM (v6 - completely reworked from flat v5)                   ║
║                                                                                  ║
║  Every surface is now physically lit. The light source is top-left.             ║
║                                                                                  ║
║  DEPTH LAYERS (bottom → top)                                                    ║
║    0. Multi-layer gaussian-simulated window shadow (4 frames)                   ║
║    1. Window background  — base colour                                           ║
║    2. Inner vignette     — darkens edges, draws focus to centre                  ║
║    3. Tab rail           — slightly lighter than background                      ║
║    4. Top bar            — lit gradient (bright top → base bottom)               ║
║    5. Accent strip       — 6-stop colour gradient + 28px glow bloom below        ║
║    6. Component card     — elevated surface with:                                ║
║         · 2px top-edge highlight (fades left+right)                              ║
║         · 16px bottom inner shadow (card feels thick)                            ║
║         · Surface gradient (Elevated → Elevated-2% darker)                       ║
║    7. Interactive layer  — buttons, thumbs, dots, fills                          ║
║         · Shine sweep on upper 48% (white, 78% transparent)                     ║
║         · Accent glow bloom on selection                                         ║
║    8. Glow halos         — tab indicator, slider thumb, toggle dot                ║
║    9. Tooltips + overlays                                                        ║
║   10. Notifications (glass gradient + left accent strip + drain bar)             ║
║                                                                                  ║
║  ANIMATION PRINCIPLES                                                            ║
║    · All transitions use Quint/Out for snappy settle                             ║
║    · Hover: 100ms (fast response)                                                ║
║    · Press: 70ms scale-down, 200ms Back/Out spring back                          ║
║    · Selection: 280ms Back/Out for organic feel                                  ║
║    · Glow expansion on drag: 120ms; contraction: 180ms Back/Out                 ║
║    · Ripple: 550ms Quint, centred on click position                              ║
║                                                                                  ║
║  MICRO-OPTIMISATIONS                                                             ║
║    · local yield/spawn/defer/delay  (task.* single lookup)                       ║
║    · local floor/ceil/clamp/max/min/abs/sqrt/sin/cos/rad/pi/huge                ║
║    · TweenInfo pool: int key = floor(dur*1000)|style<<13|dir<<19                ║
║    · New(cls,props,children) factory — replaces all Instance.new()              ║
║    · Enum locals: MB1 TOUCH MMOVE KBD ESC SORT AS_Y XL XR QUINT BACK etc.     ║
║    · Shadow guard: skips RenderStepped when Main.AbsolutePosition unchanged    ║
║    · SetFlag early-exit when value identical                                     ║
║    · Spinner orbit phases pre-computed at creation                               ║
║    · Skeleton shimmer: tick()%period keeps offset bounded forever                ║
║    · Connection pool: count-tracked array, no table.insert                       ║
║    · IsMobile() memoised into local `mob` at CreateWindow time                  ║
║    · zi() per-tab ZIndex snapshot; `local z = zi()` per component               ║
╚══════════════════════════════════════════════════════════════════════════════════╝
]]

-- ══ SERVICES ══════════════════════════════════════════════════════════════════
local TS   = game:GetService("TweenService")
local UIS  = game:GetService("UserInputService")
local RS   = game:GetService("RunService")
local PLR  = game:GetService("Players")
local HTTP = game:GetService("HttpService")
local LP   = PLR.LocalPlayer
local PG   = LP:WaitForChild("PlayerGui")

-- ══ TASK ALIASES ══════════════════════════════════════════════════════════════
local yield = task.wait
local spawn = task.spawn
local defer = task.defer
local delay = task.delay

-- ══ MATH ALIASES ══════════════════════════════════════════════════════════════
local floor = math.floor
local ceil  = math.ceil
local clamp = math.clamp
local max   = math.max
local min   = math.min
local abs   = math.abs
local sqrt  = math.sqrt
local sin   = math.sin
local cos   = math.cos
local rad   = math.rad
local huge  = math.huge
local pi    = math.pi

-- ══ ENUM LOCALS ══════════════════════════════════════════════════════════════
local MB1   = Enum.UserInputType.MouseButton1
local TOUCH = Enum.UserInputType.Touch
local MMOVE = Enum.UserInputType.MouseMovement
local KBD   = Enum.UserInputType.Keyboard
local ESC   = Enum.KeyCode.Escape
local UDEND = Enum.UserInputState.End
local AS_Y  = Enum.AutomaticSize.Y
local AS_X  = Enum.AutomaticSize.X
local XL    = Enum.TextXAlignment.Left
local XR    = Enum.TextXAlignment.Right
local XC    = Enum.TextXAlignment.Center
local YT    = Enum.TextYAlignment.Top
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
local CROP  = Enum.ScaleType.Crop
local BORD  = Enum.ApplyStrokeMode.Border

-- ══ INSTANCE FACTORY ══════════════════════════════════════════════════════════
local function New(cls, props, children)
	local i = Instance.new(cls)
	if props then for k,v in next,props do i[k]=v end end
	if children then for _,c in next,children do c.Parent=i end end
	return i
end

-- ══ TWEEN POOL ════════════════════════════════════════════════════════════════
local _TI = {}
local function T(obj, goal, dur, sty, dir)
	dur = dur or 0.22; sty = sty or QUINT; dir = dir or OUT
	local k = floor(dur*1000) + sty.Value*8192 + dir.Value*524288
	local ti = _TI[k]
	if not ti then ti = TweenInfo.new(dur,sty,dir); _TI[k]=ti end
	local tw = TS:Create(obj,ti,goal); tw:Play(); return tw
end

-- ══ COLOUR HELPERS ════════════════════════════════════════════════════════════
local C3 = Color3.fromRGB
local function Lighten(c,a) a=a or .07; local h,s,v=c:ToHSV(); return Color3.fromHSV(h,max(0,s-a*.25),clamp(v+a,0,1)) end
local function Darken(c,a)  a=a or .07; local h,s,v=c:ToHSV(); return Color3.fromHSV(h,min(1,s+a*.15),clamp(v-a,0,1)) end
local function LerpC(a,b,t) return Color3.new(a.R+(b.R-a.R)*t, a.G+(b.G-a.G)*t, a.B+(b.B-a.B)*t) end
local _hf = "#%02X%02X%02X"
local function ToHex(c) return _hf:format(floor(c.R*255+.5),floor(c.G*255+.5),floor(c.B*255+.5)) end
local function FromHex(s)
	s=s:gsub("^#",""); if #s~=6 then return Color3.new(1,1,1) end
	return C3(tonumber(s:sub(1,2),16) or 0, tonumber(s:sub(3,4),16) or 0, tonumber(s:sub(5,6),16) or 0)
end

-- ══ MISC HELPERS ══════════════════════════════════════════════════════════════
local function Round(n,p) local f=10^(p or 0); return floor(n*f+.5)/f end
local function Trim(s) return (s:gsub("^%s*(.-)%s*$","%1")) end
local function C01(x) return clamp(x,0,1) end

-- ══ VISUAL DEPTH SYSTEM ═══════════════════════════════════════════════════════
-- Top-edge highlight: 2px bright line that fades at edges (glass bevel)
local function TopHL(frame, z)
	local zv = (type(z)=="number" and z or (frame.ZIndex or 1)) + 1
	-- Primary highlight edge
	New("Frame",{Name="HL1",Size=UDim2.new(1,-16,0,1),Position=UDim2.new(0,8,0,0),
		BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.68,
		BorderSizePixel=0,ZIndex=zv,Parent=frame},{
		New("UIGradient",{Transparency=NumberSequence.new({
			NumberSequenceKeypoint.new(0,.97),NumberSequenceKeypoint.new(.2,.68),
			NumberSequenceKeypoint.new(.8,.68),NumberSequenceKeypoint.new(1,.97),
		})}),
	})
	-- Softer secondary glow under it
	New("Frame",{Name="HL2",Size=UDim2.new(1,-32,0,1),Position=UDim2.new(0,16,0,1),
		BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.88,
		BorderSizePixel=0,ZIndex=zv,Parent=frame})
	-- Bottom inner shadow (makes card feel thick)
	New("Frame",{Name="BSH",Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,1,-20),
		BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,
		BorderSizePixel=0,ZIndex=zv,Parent=frame},{
		New("UIGradient",{
			Color=ColorSequence.new(C3(0,0,0),C3(0,0,0)),
			Transparency=NumberSequence.new({
				NumberSequenceKeypoint.new(0,.82),NumberSequenceKeypoint.new(1,.97),
			}),Rotation=90,
		}),
	})
end

-- Surface gradient: makes a flat frame look like a lit surface
local function SurfaceGrad(frame, baseCol)
	New("UIGradient",{
		Color=ColorSequence.new({
			ColorSequenceKeypoint.new(0, Lighten(baseCol,.055)),
			ColorSequenceKeypoint.new(1, Darken(baseCol,.02)),
		}),Rotation=90,Parent=frame,
	})
end

-- Shine layer: upper-half white highlight for glass/plastic feel
local function ShineLayer(parent, z, alpha)
	alpha = alpha or 0.82
	return New("Frame",{Name="SH",Size=UDim2.new(1,0,.5,0),Position=UDim2.new(0,0,0,0),
		BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,
		BorderSizePixel=0,ZIndex=(type(z)=="number" and z or 2)+2,Parent=parent},{
		New("UICorner",{CornerRadius=UDim.new(0,11)}),
		New("UIGradient",{
			Color=ColorSequence.new(Color3.new(1,1,1),Color3.new(1,1,1)),
			Transparency=NumberSequence.new({
				NumberSequenceKeypoint.new(0,alpha),NumberSequenceKeypoint.new(1,1),
			}),Rotation=90,
		}),
	})
end

-- Accent glow ring (bloom effect behind selected elements)
local function GlowRing(parent, col, sz, z)
	return New("Frame",{Name="GR",AnchorPoint=Vector2.new(.5,.5),
		Position=UDim2.new(.5,0,.5,0),Size=UDim2.fromOffset(sz,sz),
		BackgroundColor3=col,BackgroundTransparency=0.70,
		BorderSizePixel=0,ZIndex=(type(z)=="number" and z or 2)-1,Parent=parent},{
		New("UICorner",{CornerRadius=UDim.new(1,0)}),
		New("UIGradient",{
			Color=ColorSequence.new(col,col),
			Transparency=NumberSequence.new({
				NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.35,.55),
				NumberSequenceKeypoint.new(.65,.55),NumberSequenceKeypoint.new(1,1),
			}),
		}),
	})
end

-- ══ INTERACTION HELPERS ═══════════════════════════════════════════════════════
local function HoverBg(inst, base, hover)
	inst.MouseEnter:Connect(function() T(inst,{BackgroundColor3=hover},.10) end)
	inst.MouseLeave:Connect(function() T(inst,{BackgroundColor3=base},.16) end)
end

local function PressAnim(btn)
	local sc = New("UIScale",{Scale=1,Parent=btn}); local held=false
	btn.MouseButton1Down:Connect(function() held=true; T(sc,{Scale=.955},.07,QUAD) end)
	local function up() if not held then return end; held=false; T(sc,{Scale=1},.22,BACK,OUT) end
	btn.MouseButton1Up:Connect(up)
	btn.MouseLeave:Connect(function() if not held then T(sc,{Scale=1},.22,BACK,OUT) end end)
end

local function Ripple(parent, pos, col)
	col = col or Color3.new(1,1,1)
	local a = parent.AbsolutePosition; local s = parent.AbsoluteSize
	local cx = pos and (pos.X-a.X) or s.X*.5
	local cy = pos and (pos.Y-a.Y) or s.Y*.5
	local maxR = sqrt(s.X^2+s.Y^2)*1.2
	local c = New("Frame",{Name="RIP",AnchorPoint=Vector2.new(.5,.5),
		Position=UDim2.new(0,cx,0,cy),Size=UDim2.new(0,4,0,4),
		BackgroundColor3=col,BackgroundTransparency=0.65,
		BorderSizePixel=0,ZIndex=(parent.ZIndex or 1)+8,Parent=parent},
		{New("UICorner",{CornerRadius=UDim.new(1,0)})})
	T(c,{Size=UDim2.new(0,maxR*2,0,maxR*2),BackgroundTransparency=1},.55,QUINT)
	delay(.56,function() if c and c.Parent then c:Destroy() end end)
end

local function Tooltip(parent, theme, text)
	if not text or text=="" then return end
	local badge = New("TextLabel",{Text="?",Font=Enum.Font.GothamBold,TextSize=10,
		TextColor3=theme.SubText,BackgroundColor3=theme.Elevated,
		AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),
		Size=UDim2.new(0,17,0,17),ZIndex=8,Parent=parent},{
		New("UICorner",{CornerRadius=UDim.new(1,0)}),
		New("UIStroke",{Color=theme.StrokeStrong,Thickness=1}),
	})
	local tip = New("Frame",{BackgroundColor3=theme.TooltipBg,BackgroundTransparency=1,
		AutomaticSize=AS_Y,Size=UDim2.new(0,210,0,0),ZIndex=30,Parent=badge},{
		New("UICorner",{CornerRadius=UDim.new(0,10)}),
		New("UIStroke",{Name="TS",Color=theme.StrokeStrong,Thickness=1,Transparency=1}),
		New("UIPadding",{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10),
			PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,8)}),
		New("TextLabel",{Text=text,Font=Enum.Font.Gotham,TextSize=12,
			TextColor3=theme.Text,TextWrapped=true,TextXAlignment=XL,
			BackgroundTransparency=1,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=31}),
	})
	local tSk = tip:FindFirstChild("TS")
	local function show()
		local sY=badge.AbsolutePosition.Y; local vp=workspace.CurrentCamera.ViewportSize
		if sY<vp.Y*.35 then tip.AnchorPoint=Vector2.new(.5,0); tip.Position=UDim2.new(.5,0,1,8)
		else tip.AnchorPoint=Vector2.new(.5,1); tip.Position=UDim2.new(.5,0,0,-8) end
		tip.Visible=true; T(tip,{BackgroundTransparency=0},.12)
		if tSk then T(tSk,{Transparency=0},.12) end
	end
	local function hide()
		T(tip,{BackgroundTransparency=1},.10)
		if tSk then T(tSk,{Transparency=1},.10) end
		delay(.11,function() if tip and tip.Parent then tip.Visible=false end end)
	end
	badge.MouseEnter:Connect(show); badge.MouseLeave:Connect(hide)
	if UIS.TouchEnabled then
		badge.InputBegan:Connect(function(i) if i.UserInputType==TOUCH then if tip.Visible then hide() else show() end end end)
	end
end

local function MakeDraggable(handle, target, conns)
	local n=#conns; local dragging,di,ds,sp
	n=n+1; conns[n]=handle.InputBegan:Connect(function(i)
		if i.UserInputType==MB1 or i.UserInputType==TOUCH then
			dragging=true; ds=i.Position; sp=target.Position
			i.Changed:Connect(function() if i.UserInputState==UDEND then dragging=false end end)
		end
	end)
	n=n+1; conns[n]=handle.InputChanged:Connect(function(i)
		if i.UserInputType==MMOVE or i.UserInputType==TOUCH then di=i end
	end)
	n=n+1; conns[n]=UIS.InputChanged:Connect(function(i)
		if i==di and dragging then
			local d=i.Position-ds
			target.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
		end
	end)
end

-- ══ 22 THEMES ═════════════════════════════════════════════════════════════════
local Themes = {}
local function FT(t)
	t.AccentLight   = t.AccentLight   or Lighten(t.Accent,.16)
	t.AccentDark    = t.AccentDark    or Darken(t.Accent,.12)
	t.AccentBg      = t.AccentBg      or Darken(t.Accent,.42)
	t.ElevatedHover = t.ElevatedHover or Lighten(t.Elevated,.07)
	t.StrokeStrong  = t.StrokeStrong  or Lighten(t.Stroke,.08)
	t.MutedText     = t.MutedText     or Darken(t.SubText,.14)
	t.SuccessBg     = t.SuccessBg     or Darken(t.Success,.40)
	t.DangerBg      = t.DangerBg      or Darken(t.Danger,.40)
	t.WarningBg     = t.WarningBg     or Darken(t.Warning,.40)
	t.Info          = t.Info          or C3(78,160,245)
	t.InfoBg        = t.InfoBg        or Darken(t.Info,.40)
	t.TooltipBg     = t.TooltipBg     or t.Elevated
	t.Tooltip       = t.Tooltip       or t.StrokeStrong
	return t
end

Themes.Dark      = FT{Background=C3(12,14,19),Secondary=C3(18,21,28),Elevated=C3(26,30,40),ElevatedHover=C3(32,37,50),Accent=C3(255,185,50),AccentLight=C3(255,215,108),AccentDark=C3(205,142,18),AccentBg=C3(40,31,8),Text=C3(238,240,250),SubText=C3(135,142,160),MutedText=C3(70,76,92),Stroke=C3(34,39,52),StrokeStrong=C3(48,55,72),Success=C3(68,215,130),SuccessBg=C3(8,34,20),Danger=C3(242,88,84),DangerBg=C3(40,8,8),Warning=C3(255,188,50),WarningBg=C3(40,32,8),Info=C3(78,160,245),InfoBg=C3(8,22,44),TooltipBg=C3(22,26,36),Tooltip=C3(48,55,72)}
Themes.Light     = FT{Background=C3(244,246,252),Secondary=C3(255,255,255),Elevated=C3(235,238,246),ElevatedHover=C3(225,229,240),Accent=C3(188,104,16),AccentLight=C3(214,138,46),AccentDark=C3(158,80,6),AccentBg=C3(255,244,220),Text=C3(14,16,24),SubText=C3(86,93,112),MutedText=C3(156,163,180),Stroke=C3(214,218,230),StrokeStrong=C3(190,196,212),Success=C3(26,156,84),SuccessBg=C3(220,248,232),Danger=C3(206,50,46),DangerBg=C3(252,226,224),Warning=C3(176,113,6),WarningBg=C3(254,244,216),Info=C3(28,113,208),InfoBg=C3(218,234,255),TooltipBg=C3(255,255,255),Tooltip=C3(214,218,230)}
Themes.Ocean     = FT{Background=C3(7,15,27),Secondary=C3(11,22,38),Elevated=C3(15,30,50),ElevatedHover=C3(19,38,63),Accent=C3(45,192,236),AccentLight=C3(98,216,252),AccentDark=C3(20,150,198),AccentBg=C3(5,24,42),Text=C3(220,234,248),SubText=C3(110,150,174),Stroke=C3(16,42,64),StrokeStrong=C3(24,56,82),Success=C3(56,213,160),Danger=C3(230,86,86),Warning=C3(240,188,50)}
Themes.Amethyst  = FT{Background=C3(11,9,21),Secondary=C3(17,14,31),Elevated=C3(25,21,43),ElevatedHover=C3(31,27,55),Accent=C3(176,140,255),AccentLight=C3(202,174,255),AccentDark=C3(146,106,226),AccentBg=C3(21,13,41),Text=C3(234,230,250),SubText=C3(142,133,170),Stroke=C3(35,29,57),StrokeStrong=C3(49,41,77),Success=C3(96,213,143),Danger=C3(236,92,113),Warning=C3(238,184,52)}
Themes.Emerald   = FT{Background=C3(7,15,12),Secondary=C3(11,23,18),Elevated=C3(15,33,26),ElevatedHover=C3(19,43,34),Accent=C3(60,218,146),AccentLight=C3(103,236,176),AccentDark=C3(34,176,110),AccentBg=C3(5,27,17),Text=C3(220,238,228),SubText=C3(106,156,130),Stroke=C3(17,47,35),StrokeStrong=C3(25,62,47),Success=C3(90,220,150),Danger=C3(228,93,88),Warning=C3(238,184,52)}
Themes.Neon      = FT{Background=C3(5,7,13),Secondary=C3(9,11,19),Elevated=C3(13,17,27),ElevatedHover=C3(17,23,37),Accent=C3(0,238,158),AccentLight=C3(78,250,198),AccentDark=C3(0,183,123),AccentBg=C3(0,26,16),Text=C3(226,238,232),SubText=C3(98,138,120),Stroke=C3(13,37,27),StrokeStrong=C3(19,51,39),Success=C3(0,238,158),Danger=C3(238,58,98),Warning=C3(238,208,38)}
Themes.Rose      = FT{Background=C3(19,9,13),Secondary=C3(27,13,19),Elevated=C3(37,19,27),ElevatedHover=C3(47,25,35),Accent=C3(250,98,146),AccentLight=C3(255,146,183),AccentDark=C3(208,66,110),AccentBg=C3(43,9,21),Text=C3(248,230,237),SubText=C3(168,123,143),Stroke=C3(53,27,39),StrokeStrong=C3(71,37,53),Success=C3(86,213,136),Danger=C3(250,78,78),Warning=C3(250,188,48)}
Themes.Slate     = FT{Background=C3(13,15,21),Secondary=C3(19,22,31),Elevated=C3(27,31,43),ElevatedHover=C3(33,38,54),Accent=C3(118,143,246),AccentLight=C3(156,178,255),AccentDark=C3(86,110,218),AccentBg=C3(13,17,47),Text=C3(230,232,246),SubText=C3(128,136,163),Stroke=C3(35,41,59),StrokeStrong=C3(49,57,79),Success=C3(70,208,128),Danger=C3(238,86,82),Warning=C3(244,186,48)}
Themes.Midnight  = FT{Background=C3(4,5,9),Secondary=C3(8,10,17),Elevated=C3(13,15,27),ElevatedHover=C3(19,22,39),Accent=C3(140,98,255),AccentLight=C3(178,146,255),AccentDark=C3(98,62,208),AccentBg=C3(17,9,43),Text=C3(232,230,252),SubText=C3(128,122,160),Stroke=C3(25,21,47),StrokeStrong=C3(37,32,67),Success=C3(86,213,138),Danger=C3(238,78,98),Warning=C3(236,184,48)}
Themes.Copper    = FT{Background=C3(15,9,7),Secondary=C3(23,15,11),Elevated=C3(33,21,15),ElevatedHover=C3(43,29,21),Accent=C3(208,116,56),AccentLight=C3(238,154,88),AccentDark=C3(166,84,28),AccentBg=C3(39,17,7),Text=C3(248,236,226),SubText=C3(164,128,104),Stroke=C3(49,29,19),StrokeStrong=C3(69,43,29),Success=C3(78,208,126),Danger=C3(234,78,72),Warning=C3(236,180,52)}
Themes.Crimson   = FT{Background=C3(13,5,7),Secondary=C3(21,9,11),Elevated=C3(31,13,17),ElevatedHover=C3(43,17,23),Accent=C3(218,46,70),AccentLight=C3(246,94,110),AccentDark=C3(170,26,46),AccentBg=C3(43,7,13),Text=C3(252,234,236),SubText=C3(170,116,124),Stroke=C3(53,19,25),StrokeStrong=C3(75,29,37),Success=C3(66,208,126),Danger=C3(250,78,78),Warning=C3(250,184,48)}
Themes.Arctic    = FT{Background=C3(7,11,19),Secondary=C3(11,17,29),Elevated=C3(17,25,43),ElevatedHover=C3(23,33,57),Accent=C3(138,208,255),AccentLight=C3(178,228,255),AccentDark=C3(98,168,228),AccentBg=C3(7,19,39),Text=C3(218,234,252),SubText=C3(108,146,178),Stroke=C3(19,35,59),StrokeStrong=C3(27,49,81),Success=C3(66,213,158),Danger=C3(228,78,86),Warning=C3(238,194,58)}
Themes.Forest    = FT{Background=C3(7,11,7),Secondary=C3(11,17,11),Elevated=C3(17,27,17),ElevatedHover=C3(23,37,21),Accent=C3(106,190,86),AccentLight=C3(146,218,118),AccentDark=C3(70,148,54),AccentBg=C3(7,23,7),Text=C3(218,236,216),SubText=C3(108,156,106),Stroke=C3(19,41,19),StrokeStrong=C3(27,59,25),Success=C3(78,208,98),Danger=C3(228,86,78),Warning=C3(236,194,52)}
Themes.Sakura    = FT{Background=C3(21,11,15),Secondary=C3(31,15,21),Elevated=C3(43,21,31),ElevatedHover=C3(57,27,41),Accent=C3(240,146,166),AccentLight=C3(255,184,198),AccentDark=C3(198,108,130),AccentBg=C3(47,13,23),Text=C3(252,234,241),SubText=C3(178,138,153),Stroke=C3(61,27,39),StrokeStrong=C3(85,39,55),Success=C3(86,208,138),Danger=C3(246,78,90),Warning=C3(248,186,54)}
Themes.Void      = FT{Background=C3(3,3,5),Secondary=C3(7,7,11),Elevated=C3(11,11,19),ElevatedHover=C3(17,17,29),Accent=C3(118,78,255),AccentLight=C3(158,118,255),AccentDark=C3(78,46,208),AccentBg=C3(15,7,39),Text=C3(228,226,248),SubText=C3(118,113,153),Stroke=C3(19,17,39),StrokeStrong=C3(29,27,57),Success=C3(78,208,138),Danger=C3(236,70,94),Warning=C3(234,186,52)}
Themes.Lemon     = FT{Background=C3(13,13,7),Secondary=C3(21,21,11),Elevated=C3(29,29,15),ElevatedHover=C3(39,39,19),Accent=C3(226,216,38),AccentLight=C3(246,236,86),AccentDark=C3(178,170,18),AccentBg=C3(35,33,5),Text=C3(242,242,218),SubText=C3(166,163,118),Stroke=C3(43,41,19),StrokeStrong=C3(59,57,27),Success=C3(78,213,126),Danger=C3(228,78,78),Warning=C3(226,216,38)}
Themes.Dusk      = FT{Background=C3(15,11,19),Secondary=C3(23,17,31),Elevated=C3(33,25,45),ElevatedHover=C3(45,33,61),Accent=C3(198,128,255),AccentLight=C3(226,166,255),AccentDark=C3(156,86,218),AccentBg=C3(35,17,51),Text=C3(238,230,252),SubText=C3(158,138,188),Stroke=C3(47,33,67),StrokeStrong=C3(65,47,93),Success=C3(86,208,143),Danger=C3(236,82,102),Warning=C3(238,188,54)}
Themes.Cobalt    = FT{Background=C3(5,9,19),Secondary=C3(9,15,31),Elevated=C3(13,21,47),ElevatedHover=C3(19,29,63),Accent=C3(58,138,255),AccentLight=C3(108,178,255),AccentDark=C3(26,94,218),AccentBg=C3(7,15,47),Text=C3(218,230,252),SubText=C3(98,136,188),Stroke=C3(15,27,61),StrokeStrong=C3(21,39,83),Success=C3(66,213,146),Danger=C3(230,78,86),Warning=C3(236,190,52)}
Themes.Rust      = FT{Background=C3(15,9,5),Secondary=C3(23,13,7),Elevated=C3(35,19,9),ElevatedHover=C3(47,27,13),Accent=C3(198,98,46),AccentLight=C3(232,136,78),AccentDark=C3(154,68,22),AccentBg=C3(39,15,5),Text=C3(248,234,220),SubText=C3(168,126,98),Stroke=C3(51,27,13),StrokeStrong=C3(73,39,17),Success=C3(76,206,126),Danger=C3(232,74,68),Warning=C3(232,180,52)}
Themes.Obsidian  = FT{Background=C3(9,9,11),Secondary=C3(14,14,19),Elevated=C3(21,21,29),ElevatedHover=C3(29,29,41),Accent=C3(178,163,255),AccentLight=C3(210,198,255),AccentDark=C3(136,116,226),AccentBg=C3(23,17,47),Text=C3(236,236,252),SubText=C3(143,138,173),Stroke=C3(31,29,51),StrokeStrong=C3(45,43,71),Success=C3(84,210,140),Danger=C3(236,80,96),Warning=C3(236,188,54),TooltipBg=C3(17,15,31)}
Themes.Carbon    = FT{Background=C3(9,9,9),Secondary=C3(15,15,15),Elevated=C3(23,23,23),ElevatedHover=C3(31,31,31),Accent=C3(238,238,238),AccentLight=C3(255,255,255),AccentDark=C3(188,188,188),AccentBg=C3(37,37,37),Text=C3(238,238,238),SubText=C3(153,153,153),MutedText=C3(78,78,78),Stroke=C3(37,37,37),StrokeStrong=C3(53,53,53),Success=C3(78,213,128),SuccessBg=C3(11,31,17),Danger=C3(238,78,78),DangerBg=C3(39,9,9),Warning=C3(238,188,48),WarningBg=C3(39,29,7),Info=C3(78,158,246),InfoBg=C3(9,21,45),TooltipBg=C3(19,19,19),Tooltip=C3(53,53,53)}
Themes.Horizon   = FT{Background=C3(14,9,17),Secondary=C3(21,14,27),Elevated=C3(31,19,39),ElevatedHover=C3(41,27,53),Accent=C3(255,138,78),AccentLight=C3(255,178,118),AccentDark=C3(208,98,46),AccentBg=C3(47,19,7),Text=C3(252,236,228),SubText=C3(173,138,153),Stroke=C3(51,31,57),StrokeStrong=C3(71,45,79),Success=C3(86,213,138),Danger=C3(238,78,98),Warning=C3(255,138,78),TooltipBg=C3(27,15,35)}

-- ══ MOBILE DETECTION ══════════════════════════════════════════════════════════
local function IsMobile() return UIS.TouchEnabled and not UIS.KeyboardEnabled end
local function ScalePx(n,m) return floor(n*(m and 1.15 or 1)+.5) end

-- ══ LIBRARY ROOT ══════════════════════════════════════════════════════════════
local NovaUI   = {}
NovaUI.__index = NovaUI
NovaUI.Flags   = {}; NovaUI.Windows = {}; NovaUI.Themes = Themes
NovaUI.Version = "6.0"; NovaUI._cbs = {}

function NovaUI:SetFlag(f,v)
	if NovaUI.Flags[f]==v then return end
	NovaUI.Flags[f]=v
	local cb=NovaUI._cbs[f]; if cb then for _,fn in next,cb do spawn(fn,v) end end
end
function NovaUI:GetFlag(f) return NovaUI.Flags[f] end
function NovaUI:OnFlagChanged(f,fn)
	if not NovaUI._cbs[f] then NovaUI._cbs[f]={} end
	NovaUI._cbs[f][#NovaUI._cbs[f]+1]=fn
end
function NovaUI:ResetFlags()
	for f in next,NovaUI.Flags do NovaUI.Flags[f]=nil
		local cb=NovaUI._cbs[f]; if cb then for _,fn in next,cb do spawn(fn,nil) end end
	end
end
function NovaUI:SetGlobalTheme(t) for _,w in next,NovaUI.Windows do w:SetTheme(t) end end

-- ══ KEY SYSTEM ════════════════════════════════════════════════════════════════
function NovaUI:CreateKeySystem(opts)
	opts=opts or {}
	local mob=IsMobile(); local t=Themes[opts.Theme] or Themes.Dark
	local keys=opts.Keys or {}; local save=opts.SaveKey~=false; local attr=opts.AttributeName or "NovaUIKey"
	if save then
		local sv=LP:GetAttribute(attr)
		if type(sv)=="string" then
			local ok=#keys==0; for _,k in next,keys do if sv==k then ok=true; break end end
			if ok then if opts.OnSuccess then spawn(opts.OnSuccess,sv) end; return {Destroy=function()end} end
		end
	end
	local sg=New("ScreenGui",{Name="NovaUI_Key",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=200,Parent=PG})
	New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=C3(0,0,0),BackgroundTransparency=0.42,BorderSizePixel=0,ZIndex=0,Parent=sg})
	local W=mob and 330 or 400
	local card=New("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),
		Size=UDim2.fromOffset(W,0),AutomaticSize=AS_Y,BackgroundColor3=t.Secondary,
		BackgroundTransparency=1,ZIndex=1,Parent=sg},{
		New("UICorner",{CornerRadius=UDim.new(0,20)}),
		New("UIStroke",{Color=t.StrokeStrong,Thickness=1}),
		New("UIPadding",{PaddingLeft=UDim.new(0,26),PaddingRight=UDim.new(0,26),PaddingTop=UDim.new(0,26),PaddingBottom=UDim.new(0,24)}),
		New("UIListLayout",{Padding=UDim.new(0,14),SortOrder=SORT}),
	})
	SurfaceGrad(card, t.Secondary)
	-- Accent top strip
	New("Frame",{Size=UDim2.new(1,0,0,4),BackgroundColor3=t.Accent,BorderSizePixel=0,ZIndex=2,Parent=card},{
		New("UICorner",{CornerRadius=UDim.new(0,4)}),
		New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,t.AccentDark),ColorSequenceKeypoint.new(.5,t.AccentLight),ColorSequenceKeypoint.new(1,t.AccentDark)})}),
	})
	New("TextLabel",{Text="🔑",Font=Enum.Font.Gotham,TextSize=ScalePx(30,mob),BackgroundTransparency=1,TextXAlignment=XC,Size=UDim2.new(1,0,0,40),ZIndex=2,Parent=card})
	New("TextLabel",{Text=opts.Title or "Key Required",Font=Enum.Font.GothamBold,TextSize=ScalePx(18,mob),TextColor3=t.Text,BackgroundTransparency=1,TextXAlignment=XC,TextWrapped=true,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=2,Parent=card})
	New("TextLabel",{Text=opts.Subtitle or "Enter your key to continue.",Font=Enum.Font.Gotham,TextSize=ScalePx(13,mob),TextColor3=t.SubText,BackgroundTransparency=1,TextXAlignment=XC,TextWrapped=true,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=2,Parent=card})
	local iH=New("Frame",{BackgroundColor3=t.Elevated,Size=UDim2.new(1,0,0,ScalePx(44,mob)),ZIndex=2,Parent=card},{
		New("UICorner",{CornerRadius=UDim.new(0,12)}),New("UIStroke",{Name="IS",Color=t.Stroke,Thickness=1}),
	})
	SurfaceGrad(iH,t.Elevated)
	local kb=New("TextBox",{Text="",PlaceholderText="Enter key here…",Font=Enum.Font.Code,TextSize=ScalePx(13,mob),TextColor3=t.Text,PlaceholderColor3=t.MutedText,BackgroundTransparency=1,ClearTextOnFocus=false,TextXAlignment=XL,Position=UDim2.new(0,14,0,0),Size=UDim2.new(1,-28,1,0),ZIndex=3,Parent=iH})
	local isk=iH:FindFirstChild("IS")
	kb.Focused:Connect(function() if isk then T(isk,{Color=t.Accent,Thickness=1.8},.14) end end)
	kb.FocusLost:Connect(function() if isk then T(isk,{Color=t.Stroke,Thickness=1},.14) end end)
	local stLbl=New("TextLabel",{Text="",Font=Enum.Font.GothamMedium,TextSize=ScalePx(12,mob),TextColor3=t.Danger,BackgroundTransparency=1,TextXAlignment=XC,TextWrapped=true,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),Visible=false,ZIndex=2,Parent=card})
	local sub=New("TextButton",{Text="Unlock",Font=Enum.Font.GothamBold,TextSize=ScalePx(14,mob),TextColor3=C3(12,12,12),BackgroundColor3=t.Accent,Size=UDim2.new(1,0,0,ScalePx(42,mob)),ZIndex=2,Parent=card},{
		New("UICorner",{CornerRadius=UDim.new(0,12)}),
		New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,t.AccentLight),ColorSequenceKeypoint.new(.5,t.Accent),ColorSequenceKeypoint.new(1,t.AccentDark)}),Rotation=90}),
	})
	ShineLayer(sub,2,.78); PressAnim(sub)
	card.Size=UDim2.fromOffset(W*.88,0)
	T(card,{Size=UDim2.fromOffset(W,0),BackgroundTransparency=0},.30,BACK,OUT)
	local attempts=0
	local function tryKey(input)
		input=Trim(input)
		if input=="" then stLbl.Text="Please enter a key."; stLbl.TextColor3=t.Warning; stLbl.Visible=true; return end
		attempts+=1
		local ok=#keys==0; for _,k in next,keys do if input==k then ok=true; break end end
		if ok then
			stLbl.Text="✓  Key accepted!"; stLbl.TextColor3=t.Success; stLbl.Visible=true
			T(sub,{BackgroundColor3=t.Success},.18)
			if save then pcall(LP.SetAttribute,LP,attr,input) end
			yield(.55); T(card,{BackgroundTransparency=1,Size=UDim2.fromOffset(W*.9,0)},.20)
			yield(.22); sg:Destroy(); if opts.OnSuccess then spawn(opts.OnSuccess,input) end
		else
			stLbl.Text=("✕  Invalid key. (attempt %d)"):format(attempts); stLbl.TextColor3=t.Danger; stLbl.Visible=true
			local orig=card.Position
			for i=1,4 do T(card,{Position=orig+UDim2.fromOffset(i%2==0 and 9 or -9,0)},.05); yield(.055) end
			T(card,{Position=orig},.10)
			if opts.OnFail then spawn(opts.OnFail,input) end
		end
	end
	sub.MouseButton1Click:Connect(function() tryKey(kb.Text) end)
	kb.FocusLost:Connect(function(e) if e then tryKey(kb.Text) end end)
	return {Destroy=function() pcall(sg.Destroy,sg) end}
end

-- ══ CREATE WINDOW ═════════════════════════════════════════════════════════════
function NovaUI:CreateWindow(cfg)
	cfg=cfg or {}
	local theme = typeof(cfg.Theme)=="table" and FT(cfg.Theme) or (Themes[cfg.Theme] or Themes.Dark)
	local mob   = IsMobile()
	local vp    = workspace.CurrentCamera.ViewportSize
	local title = cfg.Title or "NovaUI"; local sub = cfg.Subtitle or ""
	local size  = cfg.Size or (mob and UDim2.fromOffset(min(vp.X-16,480),min(vp.Y-20,560)) or UDim2.fromOffset(620,440))
	local tKey  = cfg.ToggleKey or Enum.KeyCode.RightControl
	local iPos  = cfg.Position or (mob and UDim2.fromOffset(8,10) or UDim2.new(.5,-size.X.Offset/2,.5,-size.Y.Offset/2))

	-- Connection pool
	local conns={};local nConn=0
	local function track(c) nConn+=1; conns[nConn]=c; return c end

	-- Theme broadcast
	local themeL={};local nTL=0
	local function onTheme(fn) nTL+=1; themeL[nTL]=fn end

	-- Component API registry
	local comps={}

	-- Shared drag dispatcher
	local dragMv,dragEn=nil,nil
	local function beginDrag(mv,en) dragMv=mv; dragEn=en end
	track(UIS.InputChanged:Connect(function(i)
		if dragMv and (i.UserInputType==MMOVE or i.UserInputType==TOUCH) then dragMv(i) end
	end))
	track(UIS.InputEnded:Connect(function(i)
		if dragEn and (i.UserInputType==MB1 or i.UserInputType==TOUCH) then
			local fn=dragEn; dragMv=nil; dragEn=nil; fn(i)
		end
	end))

	-- ── ScreenGui ───────────────────────────────────────────────────────────
	local SG=New("ScreenGui",{Name="NovaUI_"..title:gsub("%s+",""),ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=100,Parent=PG})

	-- ── 4-layer gaussian-simulated shadow ────────────────────────────────────
	local Shadow=New("Frame",{Name="Shadow",AnchorPoint=Vector2.new(.5,.5),
		Position=UDim2.new(.5,0,.5,16),
		Size=UDim2.fromOffset(size.X.Offset+90,size.Y.Offset+90),
		BackgroundTransparency=1,ZIndex=0,Parent=SG},{
		New("Frame",{Name="SL1",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,12),Size=UDim2.new(1,0,1,0),BackgroundColor3=C3(0,0,0),BackgroundTransparency=.90,BorderSizePixel=0},{New("UICorner",{CornerRadius=UDim.new(0,44)})}),
		New("Frame",{Name="SL2",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,8),Size=UDim2.new(.84,0,.84,0),BackgroundColor3=C3(0,0,0),BackgroundTransparency=.80,BorderSizePixel=0},{New("UICorner",{CornerRadius=UDim.new(0,36)})}),
		New("Frame",{Name="SL3",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,5),Size=UDim2.new(.68,0,.68,0),BackgroundColor3=C3(0,0,0),BackgroundTransparency=.65,BorderSizePixel=0},{New("UICorner",{CornerRadius=UDim.new(0,28)})}),
		New("Frame",{Name="SL4",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,2),Size=UDim2.new(.52,0,.52,0),BackgroundColor3=C3(0,0,0),BackgroundTransparency=.46,BorderSizePixel=0},{New("UICorner",{CornerRadius=UDim.new(0,20)})}),
	})
	local function setShadowA(a)
		for _,n in next,{"SL1","SL2","SL3","SL4"} do
			local f=Shadow:FindFirstChild(n)
			if f then f.BackgroundTransparency=clamp(f.BackgroundTransparency+(1-a),0,1) end
		end
	end
	local function fadeShadow(a,d)
		local targets={SL1=.90,SL2=.80,SL3=.65,SL4=.46}
		for n,base in next,targets do
			local f=Shadow:FindFirstChild(n)
			if f then T(f,{BackgroundTransparency=base+(1-a)*(1-base)},d) end
		end
	end
	fadeShadow(1,.01)

	-- ── Main window frame ────────────────────────────────────────────────────
	local Main=New("Frame",{Name="Main",Size=size,Position=iPos,
		BackgroundColor3=theme.Background,BorderSizePixel=0,ClipsDescendants=true,ZIndex=1,Parent=SG},{
		New("UICorner",{CornerRadius=UDim.new(0,20)}),
		New("UIStroke",{Name="MS",Color=theme.StrokeStrong,Thickness=1}),
	})
	local msk=Main:FindFirstChild("MS")
	-- Surface gradient on main background
	New("UIGradient",{Color=ColorSequence.new({
		ColorSequenceKeypoint.new(0,Lighten(theme.Background,.04)),
		ColorSequenceKeypoint.new(1,theme.Background),
	}),Rotation=90,Parent=Main})
	-- Inner vignette (darkens edges, focuses eye to centre)
	New("Frame",{Name="Vign",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=2,Parent=Main},{
		New("UIGradient",{
			Color=ColorSequence.new(C3(0,0,0),C3(0,0,0)),
			Transparency=NumberSequence.new({
				NumberSequenceKeypoint.new(0,.55),NumberSequenceKeypoint.new(.14,1),
				NumberSequenceKeypoint.new(.86,1),NumberSequenceKeypoint.new(1,.55),
			}),
		}),
	})

	-- Shadow tracks Main position (prevAP guard skips unchanged frames)
	local prevAP=Main.AbsolutePosition
	track(RS.RenderStepped:Connect(function()
		local ap=Main.AbsolutePosition; if ap==prevAP then return end; prevAP=ap
		local as=Main.AbsoluteSize
		Shadow.Position=UDim2.fromOffset(ap.X+as.X*.5,ap.Y+as.Y*.5+16)
		Shadow.Size=UDim2.fromOffset(as.X+90,as.Y+90)
	end))

	-- Entrance spring animation
	Main.Size=UDim2.new(0,size.X.Offset*.86,0,size.Y.Offset*.86)
	Main.BackgroundTransparency=1
	if msk then msk.Transparency=1 end
	T(Main,{Size=size,BackgroundTransparency=0},.34,BACK,OUT)
	fadeShadow(0,.42)
	if msk then T(msk,{Transparency=0},.36) end

	-- ── Top bar ──────────────────────────────────────────────────────────────
	local TBH=mob and 60 or 52
	local TopBar=New("Frame",{Name="TB",Size=UDim2.new(1,0,0,TBH),BackgroundColor3=theme.Secondary,BorderSizePixel=0,ZIndex=2,Parent=Main},{
		New("UICorner",{CornerRadius=UDim.new(0,18)}),
		-- Top bar lit gradient
		New("UIGradient",{Color=ColorSequence.new({
			ColorSequenceKeypoint.new(0,Lighten(theme.Secondary,.10)),
			ColorSequenceKeypoint.new(1,theme.Secondary),
		}),Rotation=90}),
	})
	-- Fill bottom radius gap
	New("Frame",{Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,1,-20),BackgroundColor3=theme.Secondary,BorderSizePixel=0,ZIndex=2,Parent=TopBar})
	-- Top bar separator
	local topSep=New("Frame",{Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,1),BackgroundColor3=theme.Stroke,BorderSizePixel=0,ZIndex=3,Parent=TopBar})
	-- Top bar top-edge highlight
	New("Frame",{Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,0,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.70,BorderSizePixel=0,ZIndex=5,Parent=TopBar},{
		New("UIGradient",{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.15,.70),NumberSequenceKeypoint.new(.85,.70),NumberSequenceKeypoint.new(1,1)})}),
	})

	-- Traffic-light buttons
	local function WinBtn(x,col,sym,fn)
		local b=New("TextButton",{Text="",Font=Enum.Font.GothamBold,TextSize=14,TextColor3=C3(0,0,0),BackgroundColor3=col,Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,x,.5,-7),ZIndex=5,Parent=TopBar},{New("UICorner",{CornerRadius=UDim.new(1,0)})})
		b.MouseEnter:Connect(function() b.Text=sym end); b.MouseLeave:Connect(function() b.Text="" end)
		b.MouseButton1Click:Connect(fn); return b
	end
	WinBtn(16,C3(255,95,87),"✕",function()
		T(Main,{Size=UDim2.fromOffset(size.X.Offset,0),BackgroundTransparency=1},.18)
		fadeShadow(1,.18); yield(.20); SG.Enabled=false
	end)
	local exH,exW=size.Y.Offset,size.X.Offset
	if not mob then
		local minimized=false
		WinBtn(34,C3(255,189,46),"−",function()
			minimized=not minimized
			if minimized then exH=Main.Size.Y.Offset; exW=Main.Size.X.Offset end
			T(Main,{Size=UDim2.new(0,exW,0,minimized and TBH or exH)},.22)
			local rh=Main:FindFirstChild("RH"); if rh then rh.Visible=not minimized end
		end)
		local maxed=false
		WinBtn(52,C3(40,205,65),"⊕",function()
			maxed=not maxed
			if maxed then exW=Main.Size.X.Offset; exH=Main.Size.Y.Offset; T(Main,{Size=UDim2.fromOffset(vp.X,vp.Y),Position=UDim2.new(0,0,0,0)},.26,QUINT)
			else T(Main,{Size=UDim2.fromOffset(exW,exH),Position=UDim2.new(.5,-exW/2,.5,-exH/2)},.26,QUINT) end
		end)
	end

	local titleLbl=New("TextLabel",{Name="TIT",Text=title,Font=Enum.Font.GothamBold,TextSize=mob and 18 or 15,TextColor3=theme.Text,TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,80,0,mob and 11 or 9),Size=UDim2.new(1,-104,0,mob and 24 or 20),ZIndex=3,Parent=TopBar})
	local subtLbl
	if sub~="" then subtLbl=New("TextLabel",{Name="SUB",Text=sub,Font=Enum.Font.Gotham,TextSize=11,TextColor3=theme.SubText,TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,80,0,30),Size=UDim2.new(1,-104,0,15),ZIndex=3,Parent=TopBar}) end
	if not mob then MakeDraggable(TopBar,Main,conns) end

	-- ── Accent top strip + glow bloom ────────────────────────────────────────
	local AStrip=New("Frame",{Name="AS",Size=UDim2.new(1,0,0,4),BackgroundColor3=theme.Accent,BorderSizePixel=0,ZIndex=10,Parent=Main})
	local aGrad=New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Darken(theme.AccentDark,.06)),ColorSequenceKeypoint.new(.12,theme.AccentDark),ColorSequenceKeypoint.new(.38,theme.AccentLight),ColorSequenceKeypoint.new(.62,theme.AccentLight),ColorSequenceKeypoint.new(.88,theme.AccentDark),ColorSequenceKeypoint.new(1,Darken(theme.AccentDark,.06))}),Parent=AStrip})
	-- Glow bloom below the strip
	local ABloom=New("Frame",{Name="AB",Size=UDim2.new(1,0,0,32),Position=UDim2.new(0,0,0,4),BackgroundColor3=theme.Accent,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=9,Parent=Main},{
		New("UIGradient",{Color=ColorSequence.new(theme.AccentLight,theme.Accent),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.65),NumberSequenceKeypoint.new(1,1)}),Rotation=90}),
	})

	-- ── Resize handle ────────────────────────────────────────────────────────
	local RH=New("Frame",{Name="RH",AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-5,1,-5),Size=UDim2.new(0,22,0,22),BackgroundTransparency=1,Visible=not mob,ZIndex=5,Parent=Main})
	for i=1,3 do New("Frame",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-2,1,-2-(i-1)*5),Size=UDim2.new(0,10-(i-1)*2,0,2),Rotation=-45,BackgroundColor3=theme.StrokeStrong,BorderSizePixel=0,Parent=RH}) end
	do local sp,ss; local mSz=mob and Vector2.new(280,200) or Vector2.new(440,300)
		track(RH.InputBegan:Connect(function(i)
			if i.UserInputType==MB1 or i.UserInputType==TOUCH then sp=i.Position; ss=Main.Size
				beginDrag(function(mi) Main.Size=UDim2.new(0,max(mSz.X,ss.X.Offset+(mi.Position-sp).X),0,max(mSz.Y,ss.Y.Offset+(mi.Position-sp).Y)) end,function()end)
			end
		end))
	end

	-- ── Tab rail ─────────────────────────────────────────────────────────────
	local RAIL=mob and 44 or 162
	local TabRail=New("Frame",{Name="TR",Size=UDim2.new(0,RAIL,1,-TBH),Position=UDim2.new(0,0,0,TBH),BackgroundColor3=theme.Secondary,BorderSizePixel=0,ZIndex=1,Parent=Main})
	-- Rail lit gradient
	New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Secondary,.05)),ColorSequenceKeypoint.new(1,Darken(theme.Secondary,.02))}),Rotation=90,Parent=TabRail})
	New("Frame",{Position=UDim2.new(1,0,0,0),Size=UDim2.new(0,1,1,0),BackgroundColor3=theme.Stroke,BorderSizePixel=0,ZIndex=2,Parent=TabRail})
	local TLH=New("Frame",{Name="TLH",BackgroundTransparency=1,Size=UDim2.new(1,-16,1,-16),Position=UDim2.new(0,8,0,8),ZIndex=2,Parent=TabRail})
	New("UIListLayout",{Padding=UDim.new(0,3),SortOrder=SORT,Parent=TLH})

	-- ── Page container ───────────────────────────────────────────────────────
	local PCon=New("Frame",{Name="PC",Size=UDim2.new(1,-RAIL,1,-TBH),Position=UDim2.new(0,RAIL,0,TBH),BackgroundTransparency=1,ZIndex=1,Parent=Main})

	-- ── Notification holder ──────────────────────────────────────────────────
	local nW=mob and (vp.X-24) or 310
	local NH=New("Frame",{Name="NH",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,12),Size=UDim2.new(0,nW,1,-24),BackgroundTransparency=1,ZIndex=50,Parent=SG})
	New("UIListLayout",{Padding=UDim.new(0,9),HorizontalAlignment=HALR,SortOrder=SORT,Parent=NH})

	-- Toggle key
	track(UIS.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==tKey then SG.Enabled=not SG.Enabled end end))

	-- ── Window object ────────────────────────────────────────────────────────
	local Window={ScreenGui=SG,Main=Main,Theme=theme,_mob=mob,_tabs={},_firstTab=nil,_conns=conns,_themeL=themeL,_comps=comps}
	setmetatable(Window,{__index=NovaUI})

	function Window:SetTheme(nt)
		local t=typeof(nt)=="table" and FT(nt) or (Themes[nt] or Themes.Dark)
		self.Theme=t; theme=t
		Main.BackgroundColor3=t.Background; TopBar.BackgroundColor3=t.Secondary
		TabRail.BackgroundColor3=t.Secondary; topSep.BackgroundColor3=t.Stroke
		AStrip.BackgroundColor3=t.Accent; titleLbl.TextColor3=t.Text
		if subtLbl then subtLbl.TextColor3=t.SubText end
		if msk then msk.Color=t.StrokeStrong end
		aGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Darken(t.AccentDark,.06)),ColorSequenceKeypoint.new(.12,t.AccentDark),ColorSequenceKeypoint.new(.38,t.AccentLight),ColorSequenceKeypoint.new(.62,t.AccentLight),ColorSequenceKeypoint.new(.88,t.AccentDark),ColorSequenceKeypoint.new(1,Darken(t.AccentDark,.06))})
		for i=1,nTL do pcall(themeL[i],t) end
	end
	function Window:GetTab(n) for _,tb in next,self._tabs do if tb._name==n then return tb end end end
	function Window:RemoveTab(n)
		for i,tb in next,self._tabs do if tb._name==n then
			T(tb.Button,{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0)},.18); yield(.19)
			tb.Page:Destroy(); tb.Button:Destroy(); table.remove(self._tabs,i)
			if self._firstTab==tb and self._tabs[1] then self._firstTab=nil; self._tabs[1].Button.MouseButton1Click:Fire() end; return
		end end
	end
	function Window:GetApi(flag) return comps[flag] end
	function Window:Destroy()
		for i=1,nConn do local c=conns[i]; if c and typeof(c)=="RBXScriptConnection" and c.Connected then c:Disconnect() end end
		if SG then SG:Destroy() end
		for i,w in next,NovaUI.Windows do if w==self then table.remove(NovaUI.Windows,i); break end end
	end

	-- ══ CREATE TAB ════════════════════════════════════════════════════════════
	function Window:CreateTab(tabName,icon)
		local Page=New("ScrollingFrame",{Name=tabName,BackgroundTransparency=1,Size=UDim2.new(1,-24,1,-22),Position=UDim2.new(0,12,0,11),CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=AS_Y,ScrollBarThickness=mob and 6 or 3,ScrollBarImageColor3=theme.Accent,ScrollingDirection=SCRY,BorderSizePixel=0,Visible=false,ZIndex=2,Parent=PCon})
		New("UIListLayout",{Padding=UDim.new(0,8),SortOrder=SORT,Parent=Page})
		New("UIPadding",{PaddingBottom=UDim.new(0,14),Parent=Page})

		local hasIcon=type(icon)=="string" and icon~=""
		local btnH=mob and 46 or 36
		local TabBtn=New("TextButton",{Name=tabName,Text=mob and "" or tabName,Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=theme.SubText,TextXAlignment=XL,BackgroundColor3=theme.Elevated,BackgroundTransparency=1,Size=UDim2.new(1,0,0,btnH),ZIndex=3,Parent=TLH},{
			New("UICorner",{CornerRadius=UDim.new(0,11)}),
			New("UIPadding",{PaddingLeft=UDim.new(0,mob and 0 or (hasIcon and 40 or 14))}),
		})
		-- Indicator bar
		local Ind=New("Frame",{Name="IND",AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,0,.5,0),Size=UDim2.new(0,3,0,0),BackgroundColor3=theme.Accent,BorderSizePixel=0,ZIndex=4,Parent=TabBtn},{New("UICorner",{CornerRadius=UDim.new(1,0)})})
		-- Indicator glow halo
		local IndGlow=New("Frame",{Name="INDG",AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,-5,.5,0),Size=UDim2.new(0,13,0,0),BackgroundColor3=theme.Accent,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=3,Parent=TabBtn},{
			New("UICorner",{CornerRadius=UDim.new(1,0)}),
			New("UIGradient",{Color=ColorSequence.new(theme.Accent,theme.Accent),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.42,.55),NumberSequenceKeypoint.new(1,1)})}),
		})
		local tabImg
		if hasIcon then tabImg=New("ImageLabel",{Image=icon,BackgroundTransparency=1,ImageColor3=theme.SubText,AnchorPoint=mob and Vector2.new(.5,.5) or Vector2.new(0,.5),Position=mob and UDim2.new(.5,0,.5,0) or UDim2.new(0,10,.5,-9),Size=UDim2.fromOffset(mob and 22 or 18,mob and 22 or 18),ZIndex=4,Parent=TabBtn}) end

		local Tab={Page=Page,Button=TabBtn,Selected=false,_name=tabName}

		local function selTab()
			for _,tb in next,Window._tabs do
				tb.Page.Visible=false; tb.Selected=false
				T(tb.Button,{BackgroundTransparency=1,TextColor3=theme.SubText},.15)
				local ind=tb.Button:FindFirstChild("IND"); if ind then T(ind,{Size=UDim2.new(0,3,0,0)},.15,QUAD) end
				local indg=tb.Button:FindFirstChild("INDG"); if indg then T(indg,{Size=UDim2.new(0,13,0,0),BackgroundTransparency=1},.15,QUAD) end
				local img=tb.Button:FindFirstChildOfClass("ImageLabel"); if img then T(img,{ImageColor3=theme.SubText},.15) end
			end
			Page.Visible=true; Tab.Selected=true
			local orig=Page.Position; Page.Position=orig+UDim2.fromOffset(0,12)
			T(Page,{Position=orig},.24,QUINT)
			T(TabBtn,{BackgroundTransparency=0,BackgroundColor3=theme.Elevated,TextColor3=theme.Text},.15)
			T(Ind,{Size=UDim2.new(0,3,0,24)},.30,BACK,OUT)
			T(IndGlow,{Size=UDim2.new(0,13,0,30),BackgroundTransparency=.88},.30,BACK,OUT)
			if tabImg then T(tabImg,{ImageColor3=theme.Accent},.15) end
		end
		TabBtn.MouseButton1Click:Connect(selTab)
		TabBtn.MouseEnter:Connect(function() if not Tab.Selected then T(TabBtn,{BackgroundTransparency=.5,BackgroundColor3=theme.Elevated},.10) end end)
		TabBtn.MouseLeave:Connect(function() if not Tab.Selected then T(TabBtn,{BackgroundTransparency=1},.16) end end)

		local ntabs=#Window._tabs+1; Window._tabs[ntabs]=Tab
		if not Window._firstTab then Window._firstTab=Tab; selTab() end

		local _pageZ=Page.ZIndex or 2
		local function zi() return _pageZ+1 end

		onTheme(function(t)
			Ind.BackgroundColor3=t.Accent; IndGlow.BackgroundColor3=t.Accent
			if Tab.Selected then TabBtn.BackgroundColor3=t.Elevated; TabBtn.TextColor3=t.Text
			else TabBtn.TextColor3=t.SubText end
			if tabImg then tabImg.ImageColor3=Tab.Selected and t.Accent or t.SubText end
		end)

		-- ══ COMPONENTS ════════════════════════════════════════════════════════

		local function makeCard(h, extraChildren)
			local z=zi()
			local kids={New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1})}
			-- Surface gradient on every card
			kids[#kids+1]=New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.04)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90})
			if extraChildren then for _,c in next,extraChildren do kids[#kids+1]=c end end
			local f=New("Frame",{BackgroundColor3=theme.Elevated,Size=UDim2.new(1,0,0,h),ZIndex=z,Parent=Page},kids)
			TopHL(f,z)
			return f,z
		end

		function Tab:CreateSection(text)
			local z=zi()
			local h=New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,34),Parent=Page})
			New("TextLabel",{Text=text:upper(),Font=Enum.Font.GothamBold,TextSize=10,TextColor3=theme.Accent,TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,2,0,2),Size=UDim2.new(1,-4,0,18),ZIndex=z,Parent=h})
			-- Accent underline with gradient
			New("Frame",{Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1),BackgroundColor3=theme.Accent,BorderSizePixel=0,Parent=h},{
				New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,theme.Accent),ColorSequenceKeypoint.new(.6,theme.AccentDark),ColorSequenceKeypoint.new(1,theme.Background)})}),
			})
		end

		function Tab:CreateLabel(text)
			return New("TextLabel",{Text=text,Font=Enum.Font.Gotham,TextSize=13,TextColor3=theme.SubText,TextWrapped=true,TextXAlignment=XL,BackgroundTransparency=1,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=zi(),Parent=Page})
		end

		function Tab:CreateParagraph(opts)
			opts=opts or {}; local z=zi()
			local card=New("Frame",{BackgroundColor3=theme.Elevated,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=z,Parent=Page},{
				New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1}),
				New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.05)),ColorSequenceKeypoint.new(1,theme.Elevated)}),Rotation=90}),
				New("UIPadding",{PaddingLeft=UDim.new(0,18),PaddingRight=UDim.new(0,14),PaddingTop=UDim.new(0,12),PaddingBottom=UDim.new(0,12)}),
				New("UIListLayout",{Padding=UDim.new(0,5),SortOrder=SORT}),
			})
			TopHL(card,z)
			-- Left accent bar with gradient
			New("Frame",{Size=UDim2.new(0,3,1,-24),Position=UDim2.new(0,0,0,12),BackgroundColor3=theme.Accent,BorderSizePixel=0,ZIndex=z+1,Parent=card},{
				New("UICorner",{CornerRadius=UDim.new(1,0)}),
				New("UIGradient",{Color=ColorSequence.new(theme.AccentLight,theme.AccentDark),Rotation=90}),
			})
			if opts.Title then New("TextLabel",{Text=opts.Title,Font=Enum.Font.GothamBold,TextSize=13,TextColor3=theme.Text,TextWrapped=true,TextXAlignment=XL,BackgroundTransparency=1,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=z+1,Parent=card}) end
			New("TextLabel",{Text=opts.Content or "",Font=Enum.Font.Gotham,TextSize=12,TextColor3=theme.SubText,TextWrapped=true,TextXAlignment=XL,BackgroundTransparency=1,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=z+1,Parent=card})
		end

		function Tab:CreateDivider()
			local z=zi()
			New("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=theme.Stroke,BorderSizePixel=0,Parent=Page},{
				New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,theme.Background),ColorSequenceKeypoint.new(.1,theme.Stroke),ColorSequenceKeypoint.new(.9,theme.Stroke),ColorSequenceKeypoint.new(1,theme.Background)})}),
			})
		end

		function Tab:CreateSeparatorLabel(text)
			local z=zi()
			local h=New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,24),Parent=Page})
			New("Frame",{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,0,.5,0),Size=UDim2.new(.34,0,0,1),BackgroundColor3=theme.Stroke,BorderSizePixel=0,Parent=h},{New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,theme.Background),ColorSequenceKeypoint.new(1,theme.Stroke)})})})
			New("TextLabel",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),Size=UDim2.new(.3,0,1,0),BackgroundTransparency=1,Text=text,Font=Enum.Font.GothamMedium,TextSize=11,TextColor3=theme.SubText,ZIndex=z,Parent=h})
			New("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),Size=UDim2.new(.34,0,0,1),BackgroundColor3=theme.Stroke,BorderSizePixel=0,Parent=h},{New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,theme.Stroke),ColorSequenceKeypoint.new(1,theme.Background)})})})
		end

		function Tab:CreateDividerAction(opts)
			opts=opts or {}; local z=zi()
			local h=New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,30),Parent=Page})
			New("Frame",{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,0,.5,0),Size=UDim2.new(1,-92,0,1),BackgroundColor3=theme.Stroke,BorderSizePixel=0,Parent=h},{New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,theme.Background),ColorSequenceKeypoint.new(.3,theme.Stroke),ColorSequenceKeypoint.new(1,theme.Stroke)})})})
			local btn=New("TextButton",{Text=opts.Label or "Action",Font=Enum.Font.GothamMedium,TextSize=11,TextColor3=theme.Accent,BackgroundColor3=theme.AccentBg,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),Size=UDim2.new(0,84,0,24),ZIndex=z,Parent=h},{New("UICorner",{CornerRadius=UDim.new(0,8)}),New("UIStroke",{Color=theme.AccentDark,Thickness=1})})
			PressAnim(btn); ShineLayer(btn,z,.85)
			btn.MouseButton1Click:Connect(function() Ripple(btn,UIS:GetMouseLocation(),theme.Accent); if opts.Callback then spawn(opts.Callback) end end)
		end

		function Tab:CreateBanner(opts)
			opts=opts or {}; local z=zi()
			local h=opts.Height or (mob and 84 or 96)
			local bg=opts.AccentColor or theme.AccentBg
			local frame=New("Frame",{BackgroundColor3=bg,Size=UDim2.new(1,0,0,h),ClipsDescendants=true,ZIndex=z,Parent=Page},{New("UICorner",{CornerRadius=UDim.new(0,16)}),New("UIStroke",{Color=Darken(bg,.18),Thickness=1})})
			if opts.Image then New("ImageLabel",{Image=opts.Image,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ScaleType=CROP,ImageTransparency=.36,ZIndex=z+1,Parent=frame}) end
			New("Frame",{BackgroundColor3=C3(0,0,0),BackgroundTransparency=.40,Size=UDim2.new(1,0,1,0),ZIndex=z+2,Parent=frame},{New("UIGradient",{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.08),NumberSequenceKeypoint.new(1,.62)}),Rotation=90})})
			TopHL(frame,z)
			if opts.Title then New("TextLabel",{Text=opts.Title,Font=Enum.Font.GothamBold,TextSize=mob and 16 or 17,TextColor3=Color3.new(1,1,1),TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,18,.5,-14),Size=UDim2.new(1,-36,0,22),ZIndex=z+3,Parent=frame}) end
			if opts.Subtitle then New("TextLabel",{Text=opts.Subtitle,Font=Enum.Font.Gotham,TextSize=mob and 11 or 12,TextColor3=C3(218,218,228),TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,18,.5,10),Size=UDim2.new(1,-36,0,17),ZIndex=z+3,Parent=frame}) end
			if opts.Callback then local hit=New("TextButton",{Text="",AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=z+5,Parent=frame}); PressAnim(hit); hit.MouseButton1Click:Connect(function() Ripple(frame,UIS:GetMouseLocation(),Color3.new(1,1,1)); spawn(opts.Callback) end) end
		end

		function Tab:CreateCodeBlock(opts)
			opts=opts or {}; local z=zi()
			local h=opts.Height or (mob and 84 or 104)
			local bg=Darken(theme.Background,.08)
			local frame=New("Frame",{BackgroundColor3=bg,Size=UDim2.new(1,0,0,h+32),ClipsDescendants=true,ZIndex=z,Parent=Page},{New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=theme.Stroke,Thickness=1})})
			local bar=New("Frame",{BackgroundColor3=theme.Elevated,Size=UDim2.new(1,0,0,30),ZIndex=z+1,Parent=frame},{New("UICorner",{CornerRadius=UDim.new(0,12)}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.06)),ColorSequenceKeypoint.new(1,theme.Elevated)}),Rotation=90})})
			New("Frame",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-14),BackgroundColor3=theme.Elevated,BorderSizePixel=0,ZIndex=z+1,Parent=bar})
			if opts.Language then New("TextLabel",{Text=opts.Language:upper(),Font=Enum.Font.Code,TextSize=10,TextColor3=theme.Accent,BackgroundTransparency=1,Position=UDim2.new(0,12,0,0),Size=UDim2.new(.5,0,1,0),ZIndex=z+2,Parent=bar}) end
			local copied=false
			local copyBtn=New("TextButton",{Text="Copy",Font=Enum.Font.GothamMedium,TextSize=10,TextColor3=theme.SubText,BackgroundColor3=theme.Background,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-8,.5,0),Size=UDim2.new(0,46,0,19),ZIndex=z+2,Parent=bar},{New("UICorner",{CornerRadius=UDim.new(0,6)}),New("UIStroke",{Color=theme.Stroke,Thickness=1})})
			copyBtn.MouseButton1Click:Connect(function()
				if copied then return end; copied=true; copyBtn.Text="✓"; copyBtn.TextColor3=theme.Success
				if opts.OnCopy then spawn(opts.OnCopy,opts.Code or "") end
				delay(2,function() copied=false; copyBtn.Text="Copy"; copyBtn.TextColor3=theme.SubText end)
			end)
			local scr=New("ScrollingFrame",{BackgroundTransparency=1,Position=UDim2.new(0,12,0,34),Size=UDim2.new(1,-24,1,-40),CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=AS_Y,ScrollBarThickness=mob and 4 or 2,ScrollBarImageColor3=theme.Stroke,ScrollingDirection=SCRY,BorderSizePixel=0,ZIndex=z+1,Parent=frame})
			local codeLbl=New("TextLabel",{Text=opts.Code or "",Font=Enum.Font.Code,TextSize=mob and 11 or 12,TextColor3=theme.Text,TextWrapped=false,TextXAlignment=XL,TextYAlignment=YT,BackgroundTransparency=1,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=z+2,Parent=scr})
			return {SetCode=function(c) codeLbl.Text=c end}
		end

		function Tab:CreateButton(opts)
			opts=opts or {}; local z=zi()
			local h=mob and 46 or 40
			local btn=New("TextButton",{Text=opts.Name or "Button",Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=theme.Text,BackgroundColor3=theme.Elevated,Size=UDim2.new(1,0,0,h),ZIndex=z,Parent=Page},{
				New("UICorner",{CornerRadius=UDim.new(0,14)}),
				New("UIStroke",{Name="S",Color=theme.StrokeStrong,Thickness=1}),
				New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.06)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90}),
			})
			TopHL(btn,z)
			local shine=ShineLayer(btn,z,.84); PressAnim(btn)
			Tooltip(btn,theme,opts.Info)
			local sk=btn:FindFirstChild("S")
			btn.MouseEnter:Connect(function()
				T(btn,{BackgroundColor3=theme.ElevatedHover},.10)
				T(shine,{BackgroundTransparency=.90},.12)
				if sk then T(sk,{Color=Lighten(theme.StrokeStrong,.14),Thickness=1.3},.12) end
			end)
			btn.MouseLeave:Connect(function()
				T(btn,{BackgroundColor3=theme.Elevated},.16)
				T(shine,{BackgroundTransparency=1},.16)
				if sk then T(sk,{Color=theme.StrokeStrong,Thickness=1},.16) end
			end)
			btn.MouseButton1Click:Connect(function()
				Ripple(btn,UIS:GetMouseLocation())
				T(btn,{BackgroundColor3=theme.AccentBg},.07)
				if sk then T(sk,{Color=theme.Accent,Thickness=1.8},.07) end
				T(shine,{BackgroundTransparency=.76},.07)
				delay(.18,function()
					T(btn,{BackgroundColor3=theme.Elevated},.28)
					if sk then T(sk,{Color=theme.StrokeStrong,Thickness=1},.28) end
					T(shine,{BackgroundTransparency=1},.28)
				end)
				if opts.Callback then spawn(opts.Callback) end
			end)
			return btn
		end

		function Tab:CreateAccentButton(opts)
			opts=opts or {}; local z=zi()
			local btn=New("TextButton",{Text=opts.Name or "Button",Font=Enum.Font.GothamBold,TextSize=13,TextColor3=C3(11,11,11),BackgroundColor3=theme.Accent,Size=UDim2.new(1,0,0,mob and 46 or 40),ZIndex=z,Parent=Page},{
				New("UICorner",{CornerRadius=UDim.new(0,14)}),
				New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,theme.AccentLight),ColorSequenceKeypoint.new(.45,theme.Accent),ColorSequenceKeypoint.new(1,theme.AccentDark)}),Rotation=90}),
			})
			local gr=btn:FindFirstChildOfClass("UIGradient")
			ShineLayer(btn,z,.75); PressAnim(btn)
			btn.MouseEnter:Connect(function() if gr then T(gr,{Offset=Vector2.new(0,-.12)},.15) end end)
			btn.MouseLeave:Connect(function() if gr then T(gr,{Offset=Vector2.new(0,0)},.18) end end)
			btn.MouseButton1Click:Connect(function()
				Ripple(btn,UIS:GetMouseLocation(),Color3.new(1,1,1))
				if opts.Callback then spawn(opts.Callback) end
			end)
			Tooltip(btn,theme,opts.Info); return btn
		end

		function Tab:CreateToggle(opts)
			opts=opts or {}; local z=zi()
			local state=opts.CurrentValue==true
			local rH=mob and 48 or 40
			local holder=New("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=theme.Elevated,Size=UDim2.new(1,0,0,rH),ZIndex=z,Parent=Page},{
				New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1}),
				New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.05)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90}),
			})
			TopHL(holder,z); PressAnim(holder); HoverBg(holder,theme.Elevated,theme.ElevatedHover)
			New("TextLabel",{Text=opts.Name or "Toggle",Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=theme.Text,TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,14,0,0),Size=UDim2.new(1,-72,1,0),ZIndex=z+1,Parent=holder})
			Tooltip(holder,theme,opts.Info)
			local pill=New("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-14,.5,0),Size=UDim2.new(0,46,0,27),BackgroundColor3=state and theme.Accent or theme.Stroke,ZIndex=z+1,Parent=holder},{
				New("UICorner",{CornerRadius=UDim.new(1,0)}),
				New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.72),NumberSequenceKeypoint.new(1,.88)}),Rotation=90}),
			})
			local dot=New("Frame",{AnchorPoint=Vector2.new(0,.5),Position=state and UDim2.new(1,-23,.5,0) or UDim2.new(0,3,.5,0),Size=UDim2.new(0,21,0,21),BackgroundColor3=Color3.new(1,1,1),ZIndex=z+3,Parent=pill},{
				New("UICorner",{CornerRadius=UDim.new(1,0)}),
				New("UIStroke",{Color=C3(0,0,0),Thickness=1,Transparency=.82}),
				New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,C3(235,235,235))}),Rotation=90}),
			})
			-- Dot shadow/glow ring
			local dotGlow=GlowRing(pill,theme.Accent,31,z+2)
			dotGlow.AnchorPoint=Vector2.new(0,.5)
			dotGlow.Position=state and UDim2.new(1,-23,.5,0) or UDim2.new(0,3,.5,0)
			dotGlow.BackgroundTransparency=state and .82 or 1
			local function setState(v)
				state=v
				T(pill,{BackgroundColor3=v and theme.Accent or theme.Stroke},.20)
				local tp=v and UDim2.new(1,-23,.5,0) or UDim2.new(0,3,.5,0)
				T(dot,{Position=tp},.22,BACK,OUT)
				T(dotGlow,{Position=tp,BackgroundTransparency=v and .82 or 1},.22,BACK,OUT)
				NovaUI:SetFlag(opts.Flag,v); if opts.Callback then spawn(opts.Callback,v) end
			end
			holder.MouseButton1Click:Connect(function() setState(not state) end)
			if opts.Flag then NovaUI.Flags[opts.Flag]=state end
			local api={Set=setState,Get=function() return state end}
			if opts.Flag then comps[opts.Flag]=api end; return api
		end
		Tab.CreateSwitch=Tab.CreateToggle

		function Tab:CreateSlider(opts)
			opts=opts or {}; local z=zi()
			local mn=(opts.Range and opts.Range[1]) or 0; local mx_=(opts.Range and opts.Range[2]) or 100
			local inc=opts.Increment or 1; local val=clamp(opts.CurrentValue or mn,mn,mx_)
			local holder=New("Frame",{BackgroundColor3=theme.Elevated,Size=UDim2.new(1,0,0,mob and 62 or 54),ZIndex=z,Parent=Page},{
				New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1}),
				New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.05)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90}),
			})
			TopHL(holder,z)
			New("TextLabel",{Text=opts.Name or "Slider",Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=theme.Text,TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,14,0,9),Size=UDim2.new(1,-28,0,19),ZIndex=z+1,Parent=holder})
			Tooltip(holder,theme,opts.Info)
			local vLbl=New("TextLabel",{Text=tostring(val),Font=Enum.Font.GothamBold,TextSize=12,TextColor3=theme.Accent,TextXAlignment=XR,BackgroundTransparency=1,Position=UDim2.new(0,14,0,9),Size=UDim2.new(1,-28,0,19),ZIndex=z+1,Parent=holder})
			-- Touch hitbox (20px tall) behind 5px track
			local hit=New("Frame",{Position=UDim2.new(0,14,0,34),Size=UDim2.new(1,-28,0,mob and 26 or 19),BackgroundTransparency=1,ZIndex=z+1,Parent=holder})
			local bar=New("Frame",{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,0,.5,0),Size=UDim2.new(1,0,0,5),BackgroundColor3=theme.Stroke,ZIndex=z+1,Parent=hit},{New("UICorner",{CornerRadius=UDim.new(1,0)})})
			-- Fill with 3-stop gradient
			local fill=New("Frame",{Size=UDim2.new((val-mn)/(mx_-mn),0,1,0),BackgroundColor3=theme.Accent,ZIndex=z+2,Parent=bar},{
				New("UICorner",{CornerRadius=UDim.new(1,0)}),
				New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,theme.AccentDark),ColorSequenceKeypoint.new(.5,theme.AccentLight),ColorSequenceKeypoint.new(1,theme.Accent)})}),
			})
			-- Fill shine
			New("Frame",{Size=UDim2.new(1,0,.6,0),Position=UDim2.new(0,0,0,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.80,BorderSizePixel=0,ZIndex=z+3,Parent=fill},{New("UICorner",{CornerRadius=UDim.new(1,0)})})
			local tSz=mob and 22 or 18
			-- Glow ring (behind thumb)
			local tGlow=New("Frame",{Name="TG",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new((val-mn)/(mx_-mn),0,.5,0),Size=UDim2.fromOffset(tSz+10,tSz+10),BackgroundColor3=theme.Accent,BackgroundTransparency=.72,BorderSizePixel=0,ZIndex=z+3,Parent=bar},{New("UICorner",{CornerRadius=UDim.new(1,0)})})
			-- Thumb
			local thumb=New("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new((val-mn)/(mx_-mn),0,.5,0),Size=UDim2.fromOffset(tSz,tSz),BackgroundColor3=Color3.new(1,1,1),ZIndex=z+4,Parent=bar},{
				New("UICorner",{CornerRadius=UDim.new(1,0)}),New("UIStroke",{Color=theme.Accent,Thickness=2.5}),
				New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,C3(234,234,234))}),Rotation=90}),
			})
			local lastV=val
			local function fire(v) if v~=lastV then lastV=v; NovaUI:SetFlag(opts.Flag,v); if opts.Callback then spawn(opts.Callback,v) end end end
			local function setA(a,imm)
				a=C01(a); local raw=floor((mn+(mx_-mn)*a)/inc+.5)*inc; raw=clamp(raw,mn,mx_); val=raw
				vLbl.Text=tostring(Round(raw,2)); local fa=(raw-mn)/(mx_-mn)
				if imm then fill.Size=UDim2.new(fa,0,1,0); thumb.Position=UDim2.new(fa,0,.5,0); tGlow.Position=UDim2.new(fa,0,.5,0)
				else T(fill,{Size=UDim2.new(fa,0,1,0)},.07); T(thumb,{Position=UDim2.new(fa,0,.5,0)},.07); T(tGlow,{Position=UDim2.new(fa,0,.5,0)},.07) end
				fire(raw)
			end
			hit.InputBegan:Connect(function(i)
				if i.UserInputType==MB1 or i.UserInputType==TOUCH then
					local big=tSz+6
					T(thumb,{Size=UDim2.fromOffset(big,big)},.10)
					T(tGlow,{Size=UDim2.fromOffset(big+12,big+12),BackgroundTransparency=.58},.12)
					setA((i.Position.X-hit.AbsolutePosition.X)/hit.AbsoluteSize.X,true)
					beginDrag(function(mi) setA((mi.Position.X-hit.AbsolutePosition.X)/hit.AbsoluteSize.X,true) end,
					function() T(thumb,{Size=UDim2.fromOffset(tSz,tSz)},.20,BACK,OUT); T(tGlow,{Size=UDim2.fromOffset(tSz+10,tSz+10),BackgroundTransparency=.72},.18); fire(val) end)
				end
			end)
			if opts.Flag then NovaUI.Flags[opts.Flag]=val end
			local api={Set=function(v) setA((v-mn)/(mx_-mn)) end,Get=function() return val end}
			if opts.Flag then comps[opts.Flag]=api end; return api
		end

		function Tab:CreateStepSlider(opts)
			opts=opts or {}; local z=zi()
			local steps=opts.Steps or {"Low","Med","High"}; local nS=#steps
			local cur=clamp(opts.DefaultStep or 1,1,nS)
			local holder=New("Frame",{BackgroundColor3=theme.Elevated,Size=UDim2.new(1,0,0,mob and 66 or 60),ZIndex=z,Parent=Page},{
				New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1}),
				New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.05)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90}),
			})
			TopHL(holder,z)
			New("TextLabel",{Text=opts.Name or "Step",Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=theme.Text,TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,14,0,9),Size=UDim2.new(.6,0,0,19),ZIndex=z+1,Parent=holder})
			Tooltip(holder,theme,opts.Info)
			local vLbl=New("TextLabel",{Text=steps[cur],Font=Enum.Font.GothamBold,TextSize=12,TextColor3=theme.Accent,TextXAlignment=XR,BackgroundTransparency=1,Position=UDim2.new(0,14,0,9),Size=UDim2.new(1,-28,0,19),ZIndex=z+1,Parent=holder})
			local hit=New("Frame",{Position=UDim2.new(0,14,0,34),Size=UDim2.new(1,-28,0,mob and 24 or 18),BackgroundTransparency=1,ZIndex=z+1,Parent=holder})
			local tr=New("Frame",{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,0,.5,0),Size=UDim2.new(1,0,0,4),BackgroundColor3=theme.Stroke,ZIndex=z+1,Parent=hit},{New("UICorner",{CornerRadius=UDim.new(1,0)})})
			local fl=New("Frame",{Size=UDim2.new((cur-1)/max(nS-1,1),0,1,0),BackgroundColor3=theme.Accent,ZIndex=z+2,Parent=tr},{New("UICorner",{CornerRadius=UDim.new(1,0)}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,theme.AccentDark),ColorSequenceKeypoint.new(.5,theme.AccentLight),ColorSequenceKeypoint.new(1,theme.Accent)})})})
			local dSz=mob and 14 or 12; local dots={}
			for i=1,nS do local a=(i-1)/max(nS-1,1); dots[i]=New("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(a,0,.5,0),Size=UDim2.fromOffset(dSz,dSz),BackgroundColor3=i<=cur and theme.Accent or theme.Stroke,ZIndex=z+3,Parent=tr},{New("UICorner",{CornerRadius=UDim.new(1,0)})}) end
			local tSz=mob and 22 or 18; local tGl=New("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new((cur-1)/max(nS-1,1),0,.5,0),Size=UDim2.fromOffset(tSz+10,tSz+10),BackgroundColor3=theme.Accent,BackgroundTransparency=.72,BorderSizePixel=0,ZIndex=z+3,Parent=tr},{New("UICorner",{CornerRadius=UDim.new(1,0)})})
			local thumb=New("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new((cur-1)/max(nS-1,1),0,.5,0),Size=UDim2.fromOffset(tSz,tSz),BackgroundColor3=Color3.new(1,1,1),ZIndex=z+4,Parent=tr},{New("UICorner",{CornerRadius=UDim.new(1,0)}),New("UIStroke",{Color=theme.Accent,Thickness=2}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,C3(234,234,234))}),Rotation=90})})
			local function setCur(i)
				cur=clamp(i,1,nS); vLbl.Text=steps[cur]; local a=(cur-1)/max(nS-1,1)
				T(fl,{Size=UDim2.new(a,0,1,0)},.16); T(thumb,{Position=UDim2.new(a,0,.5,0)},.16,BACK,OUT); T(tGl,{Position=UDim2.new(a,0,.5,0)},.16,BACK,OUT)
				for j,d in next,dots do T(d,{BackgroundColor3=j<=cur and theme.Accent or theme.Stroke},.12) end
				NovaUI:SetFlag(opts.Flag,cur); if opts.Callback then spawn(opts.Callback,cur,steps[cur]) end
			end
			hit.InputBegan:Connect(function(i)
				if i.UserInputType==MB1 or i.UserInputType==TOUCH then
					T(thumb,{Size=UDim2.fromOffset(tSz+6,tSz+6)},.10); T(tGl,{BackgroundTransparency=.58},.12)
					setCur(floor(C01((i.Position.X-hit.AbsolutePosition.X)/hit.AbsoluteSize.X)*(nS-1)+.5)+1)
					beginDrag(function(mi) setCur(floor(C01((mi.Position.X-hit.AbsolutePosition.X)/hit.AbsoluteSize.X)*(nS-1)+.5)+1) end,
					function() T(thumb,{Size=UDim2.fromOffset(tSz,tSz)},.20,BACK,OUT); T(tGl,{BackgroundTransparency=.72},.18) end)
				end
			end)
			if opts.Flag then NovaUI.Flags[opts.Flag]=cur end
			local api={Set=setCur,Get=function() return cur,steps[cur] end}
			if opts.Flag then comps[opts.Flag]=api end; return api
		end

		function Tab:CreateDropdown(opts)
			opts=opts or {}; local z=zi()
			local options=opts.Options or {}; local multi=opts.MultiSelect==true
			local current=opts.CurrentOption or options[1]; local selected={}; local open=false
			if multi then for _,v in next,opts.CurrentOptions or {} do selected[v]=true end end
			local holder=New("Frame",{BackgroundColor3=theme.Elevated,Size=UDim2.new(1,0,0,40),ClipsDescendants=true,ZIndex=z,Parent=Page},{
				New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1}),
				New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.05)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90}),
			})
			TopHL(holder,z)
			local head=New("TextButton",{Text="",AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.new(1,0,0,40),ZIndex=z+1,Parent=holder})
			head.MouseEnter:Connect(function() T(holder,{BackgroundColor3=theme.ElevatedHover},.10) end)
			head.MouseLeave:Connect(function() T(holder,{BackgroundColor3=theme.Elevated},.16) end)
			New("TextLabel",{Text=opts.Name or "Dropdown",Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=theme.Text,TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,14,0,0),Size=UDim2.new(.55,0,0,40),ZIndex=z+2,Parent=head})
			local function mTxt() local n=0; for _ in next,selected do n+=1 end; if n==0 then return "None" elseif n==1 then for v in next,selected do return tostring(v) end else return n.." selected" end end
			local vLbl=New("TextLabel",{Text=multi and mTxt() or tostring(current or ""),Font=Enum.Font.Gotham,TextSize=12,TextColor3=theme.SubText,TextXAlignment=XR,BackgroundTransparency=1,Position=UDim2.new(.55,0,0,0),Size=UDim2.new(.45,-32,0,40),ZIndex=z+2,Parent=head})
			local chev=New("TextLabel",{Text="▾",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=theme.SubText,BackgroundTransparency=1,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-14,.5,0),Size=UDim2.new(0,14,0,14),ZIndex=z+2,Parent=head})
			New("Frame",{Position=UDim2.new(0,10,0,40),Size=UDim2.new(1,-20,0,1),BackgroundColor3=theme.Stroke,BorderSizePixel=0,ZIndex=z+1,Parent=holder})
			local lH=New("Frame",{Position=UDim2.new(0,4,0,44),Size=UDim2.new(1,-8,0,0),BackgroundTransparency=1,ZIndex=z+1,Parent=holder})
			New("UIListLayout",{Padding=UDim.new(0,2),SortOrder=SORT,Parent=lH})
			local rH=mob and 38 or 30
			local function rebuild()
				for _,c in next,lH:GetChildren() do if c:IsA("TextButton") then c:Destroy() end end
				for _,opt in next,options do
					local isSel=multi and selected[opt]==true or (not multi and current==opt)
					local row=New("TextButton",{Text=(isSel and "✓  " or "    ")..tostring(opt),Font=Enum.Font.Gotham,TextSize=12,TextColor3=isSel and theme.Accent or theme.SubText,TextXAlignment=XL,BackgroundColor3=theme.Elevated,BackgroundTransparency=isSel and .5 or 1,Size=UDim2.new(1,0,0,rH),ZIndex=z+2,Parent=lH},{New("UICorner",{CornerRadius=UDim.new(0,10)}),New("UIPadding",{PaddingLeft=UDim.new(0,10)})})
					row.MouseEnter:Connect(function() T(row,{BackgroundTransparency=.42,BackgroundColor3=theme.ElevatedHover},.08) end)
					row.MouseLeave:Connect(function() T(row,{BackgroundTransparency=isSel and .5 or 1},.12) end)
					row.MouseButton1Click:Connect(function()
						if multi then if selected[opt] then selected[opt]=nil else selected[opt]=true end; vLbl.Text=mTxt(); local l={}; for v in next,selected do l[#l+1]=v end; NovaUI:SetFlag(opts.Flag,l); if opts.Callback then spawn(opts.Callback,l) end; rebuild()
						else current=opt; vLbl.Text=tostring(opt); NovaUI:SetFlag(opts.Flag,opt); if opts.Callback then spawn(opts.Callback,opt) end; open=false; T(holder,{Size=UDim2.new(1,0,0,40)},.16); T(chev,{Rotation=0},.16); rebuild() end
					end)
				end
			end
			rebuild()
			track(UIS.InputBegan:Connect(function(i)
				if not open then return end
				if i.UserInputType==MB1 or i.UserInputType==TOUCH then
					defer(function() local mp=UIS:GetMouseLocation(); local ap=holder.AbsolutePosition; local as=holder.AbsoluteSize; if mp.X<ap.X or mp.X>ap.X+as.X or mp.Y<ap.Y or mp.Y>ap.Y+as.Y then open=false; T(holder,{Size=UDim2.new(1,0,0,40)},.16); T(chev,{Rotation=0},.16) end end)
				end
			end))
			head.MouseButton1Click:Connect(function()
				open=not open; local maxR=mob and 5 or 8; local rpx=mob and 38 or 30
				T(holder,{Size=UDim2.new(1,0,0,open and (44+min(#options,maxR)*rpx+4) or 40)},.20,QUINT)
				T(chev,{Rotation=open and 180 or 0},.18)
			end)
			if opts.Flag then if multi then local l={}; for v in next,selected do l[#l+1]=v end; NovaUI.Flags[opts.Flag]=l else NovaUI.Flags[opts.Flag]=current end end
			local api={
				Set=function(v) if multi then selected={}; for _,x in next,v do selected[x]=true end else current=v end; vLbl.Text=multi and mTxt() or tostring(v); rebuild() end,
				Get=function() if multi then local l={}; for v in next,selected do l[#l+1]=v end; return l end; return current end,
				Refresh=function(no) options=no; if not multi then local ok=false; for _,v in next,options do if v==current then ok=true; break end end; if not ok then current=options[1] end else for v in next,selected do local f=false; for _,nv in next,options do if nv==v then f=true; break end end; if not f then selected[v]=nil end end end; vLbl.Text=multi and mTxt() or tostring(current or ""); rebuild() end,
			}
			if opts.Flag then comps[opts.Flag]=api end; return api
		end

		function Tab:CreateInput(opts)
			opts=opts or {}; local z=zi()
			local holder=New("Frame",{BackgroundColor3=theme.Elevated,Size=UDim2.new(1,0,0,mob and 46 or 40),ZIndex=z,Parent=Page},{
				New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Name="S",Color=theme.Stroke,Thickness=1}),
				New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.05)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90}),
			})
			TopHL(holder,z)
			if opts.Name then New("TextLabel",{Text=opts.Name,Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=theme.SubText,TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,14,0,0),Size=UDim2.new(.4,0,1,0),ZIndex=z+1,Parent=holder}) end
			local bx=opts.Name and .4 or 0
			local box=New("TextBox",{Text=opts.DefaultText or "",PlaceholderText=opts.PlaceholderText or (opts.Name and "Enter value…" or "Enter text…"),Font=Enum.Font.Gotham,TextSize=13,TextColor3=theme.Text,PlaceholderColor3=theme.MutedText,ClearTextOnFocus=false,BackgroundTransparency=1,Position=UDim2.new(bx,opts.Name and 0 or 14,0,0),Size=UDim2.new(1-bx,opts.Name and -14 or -28,1,0),TextXAlignment=XL,ZIndex=z+1,Parent=holder})
			local sk=holder:FindFirstChild("S")
			box.Focused:Connect(function() if sk then T(sk,{Color=theme.Accent,Thickness=1.8},.14) end end)
			box.FocusLost:Connect(function(e) if sk then T(sk,{Color=theme.Stroke,Thickness=1},.14) end; NovaUI:SetFlag(opts.Flag,box.Text); if opts.Callback then spawn(opts.Callback,box.Text,e) end end)
			if opts.Flag then NovaUI.Flags[opts.Flag]=box.Text end
			local api={Set=function(v) box.Text=v end,Get=function() return box.Text end}
			if opts.Flag then comps[opts.Flag]=api end; return api
		end

		function Tab:CreateTextArea(opts)
			opts=opts or {}; local z=zi(); local h=opts.Height or 84
			local holder=New("Frame",{BackgroundColor3=theme.Elevated,Size=UDim2.new(1,0,0,h+4),ZIndex=z,Parent=Page},{
				New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Name="S",Color=theme.Stroke,Thickness=1}),
				New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.05)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90}),
			})
			if opts.Name then New("TextLabel",{Text=opts.Name,Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=theme.SubText,TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,14,0,4),Size=UDim2.new(1,-28,0,16),ZIndex=z+1,Parent=holder}) end
			local yO=opts.Name and 22 or 0
			local box=New("TextBox",{Text=opts.DefaultText or "",PlaceholderText=opts.PlaceholderText or "Enter text…",Font=Enum.Font.Gotham,TextSize=12,TextColor3=theme.Text,PlaceholderColor3=theme.MutedText,ClearTextOnFocus=false,MultiLine=true,TextWrapped=true,TextXAlignment=XL,TextYAlignment=YT,BackgroundTransparency=1,Position=UDim2.new(0,14,0,yO+2),Size=UDim2.new(1,-28,0,h-yO),ZIndex=z+1,Parent=holder})
			local sk=holder:FindFirstChild("S")
			box.Focused:Connect(function() if sk then T(sk,{Color=theme.Accent,Thickness=1.8},.14) end end)
			box.FocusLost:Connect(function(e) if sk then T(sk,{Color=theme.Stroke,Thickness=1},.14) end; NovaUI:SetFlag(opts.Flag,box.Text); if opts.Callback then spawn(opts.Callback,box.Text,e) end end)
			if opts.Flag then NovaUI.Flags[opts.Flag]=box.Text end
			local api={Set=function(v) box.Text=v end,Get=function() return box.Text end}
			if opts.Flag then comps[opts.Flag]=api end; return api
		end

		function Tab:CreateNumberInput(opts)
			opts=opts or {}; local z=zi()
			local mn_=opts.Min or 0; local mx_=opts.Max or 100; local step=opts.Step or 1
			local val=clamp(opts.DefaultValue or mn_,mn_,mx_)
			local holder=New("Frame",{BackgroundColor3=theme.Elevated,Size=UDim2.new(1,0,0,mob and 46 or 40),ZIndex=z,Parent=Page},{
				New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Name="S",Color=theme.Stroke,Thickness=1}),
				New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.05)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90}),
			})
			TopHL(holder,z); Tooltip(holder,theme,opts.Info)
			if opts.Name then New("TextLabel",{Text=opts.Name,Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=theme.Text,TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,14,0,0),Size=UDim2.new(.5,0,1,0),ZIndex=z+1,Parent=holder}) end
			local box=New("TextBox",{Text=tostring(val),Font=Enum.Font.GothamBold,TextSize=13,TextColor3=theme.Text,TextXAlignment=XC,BackgroundTransparency=1,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-66,.5,0),Size=UDim2.new(0,58,0,28),ZIndex=z+1,Parent=holder})
			local function apply(v) v=clamp(floor(v/step+.5)*step,mn_,mx_); val=v; box.Text=tostring(Round(v,2)); NovaUI:SetFlag(opts.Flag,v); if opts.Callback then spawn(opts.Callback,v) end end
			local function mkBtn(sym,pos,cb)
				local b=New("TextButton",{Text=sym,Font=Enum.Font.GothamBold,TextSize=17,TextColor3=theme.Accent,BackgroundColor3=theme.AccentBg,AnchorPoint=Vector2.new(1,.5),Position=pos,Size=UDim2.new(0,28,0,28),ZIndex=z+1,Parent=holder},{New("UICorner",{CornerRadius=UDim.new(0,9)}),New("UIStroke",{Color=theme.AccentDark,Thickness=1})})
				PressAnim(b); ShineLayer(b,z+1,.86); b.MouseButton1Click:Connect(cb); return b
			end
			mkBtn("−",UDim2.new(1,-128,.5,0),function() apply(val-step) end)
			mkBtn("+",UDim2.new(1,-8,.5,0),function() apply(val+step) end)
			local sk=holder:FindFirstChild("S")
			box.Focused:Connect(function() if sk then T(sk,{Color=theme.Accent,Thickness=1.8},.14) end end)
			box.FocusLost:Connect(function() if sk then T(sk,{Color=theme.Stroke,Thickness=1},.14) end; local n=tonumber(box.Text); if n then apply(n) else box.Text=tostring(val) end end)
			if opts.Flag then NovaUI.Flags[opts.Flag]=val end
			local api={Set=apply,Get=function() return val end}
			if opts.Flag then comps[opts.Flag]=api end; return api
		end

		function Tab:CreateKeybind(opts)
			opts=opts or {}; local z=zi()
			local bound=opts.CurrentKeybind or Enum.KeyCode.Unknown; local listening=false
			local holder=New("Frame",{BackgroundColor3=theme.Elevated,Size=UDim2.new(1,0,0,mob and 46 or 40),ZIndex=z,Parent=Page},{
				New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1}),
				New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.05)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90}),
			})
			TopHL(holder,z); HoverBg(holder,theme.Elevated,theme.ElevatedHover)
			New("TextLabel",{Text=opts.Name or "Keybind",Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=theme.Text,TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,14,0,0),Size=UDim2.new(1,-118,1,0),ZIndex=z+1,Parent=holder})
			Tooltip(holder,theme,opts.Info)
			local pill=New("TextButton",{Text=bound==Enum.KeyCode.Unknown and "—" or bound.Name,Font=Enum.Font.GothamBold,TextSize=11,TextColor3=theme.Accent,BackgroundColor3=theme.AccentBg,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-12,.5,0),Size=UDim2.new(0,96,0,26),ZIndex=z+1,Parent=holder},{New("UICorner",{CornerRadius=UDim.new(0,8)}),New("UIStroke",{Color=theme.AccentDark,Thickness=1})})
			ShineLayer(pill,z+1,.88)
			local function cancel() if not listening then return end; listening=false; pill.Text=bound==Enum.KeyCode.Unknown and "—" or bound.Name; T(pill,{TextColor3=theme.Accent},.12) end
			pill.MouseButton1Click:Connect(function() listening=true; pill.Text="…"; T(pill,{TextColor3=theme.SubText},.10) end)
			track(UIS.InputBegan:Connect(function(i,gp)
				if not listening then return end
				if i.UserInputType==KBD then if i.KeyCode==ESC then cancel(); return end; bound=i.KeyCode; pill.Text=bound.Name; T(pill,{TextColor3=theme.Accent},.12); listening=false; NovaUI:SetFlag(opts.Flag,bound); if opts.Callback then spawn(opts.Callback,bound) end
				elseif i.UserInputType==MB1 then local mp=i.Position; local ap=pill.AbsolutePosition; local as=pill.AbsoluteSize; if mp.X<ap.X or mp.X>ap.X+as.X or mp.Y<ap.Y or mp.Y>ap.Y+as.Y then cancel() end end
			end))
			if opts.Flag then NovaUI.Flags[opts.Flag]=bound end
			local api={Set=function(v) bound=v; pill.Text=v.Name end,Get=function() return bound end}
			if opts.Flag then comps[opts.Flag]=api end; return api
		end

		function Tab:CreateColorPicker(opts)
			opts=opts or {}; local z=zi()
			local color=opts.CurrentColor or C3(255,185,50); local open=false
			local holder=New("Frame",{BackgroundColor3=theme.Elevated,Size=UDim2.new(1,0,0,40),ClipsDescendants=true,ZIndex=z,Parent=Page},{
				New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1}),
				New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.05)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90}),
			})
			TopHL(holder,z)
			local head=New("TextButton",{Text="",AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.new(1,0,0,40),ZIndex=z+1,Parent=holder})
			head.MouseEnter:Connect(function() T(holder,{BackgroundColor3=theme.ElevatedHover},.10) end)
			head.MouseLeave:Connect(function() T(holder,{BackgroundColor3=theme.Elevated},.16) end)
			New("TextLabel",{Text=opts.Name or "Color",Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=theme.Text,TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,14,0,0),Size=UDim2.new(1,-104,1,0),ZIndex=z+2,Parent=head})
			local hexLbl=New("TextLabel",{Text=ToHex(color),Font=Enum.Font.Code,TextSize=10,TextColor3=theme.SubText,TextXAlignment=XR,BackgroundTransparency=1,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-50,.5,0),Size=UDim2.new(0,54,0,20),ZIndex=z+2,Parent=head})
			local swatch=New("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-14,.5,0),Size=UDim2.new(0,30,0,30),BackgroundColor3=color,ZIndex=z+2,Parent=head},{New("UICorner",{CornerRadius=UDim.new(0,9)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1})}); ShineLayer(swatch,z+2,.80)
			local panel=New("Frame",{Position=UDim2.new(0,14,0,46),Size=UDim2.new(1,-28,0,140),BackgroundTransparency=1,ZIndex=z+1,Parent=holder})
			local cC={R=C3(232,88,84),G=C3(68,210,130),B=C3(78,156,248)}; local chans={}
			local function applyColor() color=C3(chans.R.get(),chans.G.get(),chans.B.get()); swatch.BackgroundColor3=color; hexLbl.Text=ToHex(color); NovaUI:SetFlag(opts.Flag,color); if opts.Callback then spawn(opts.Callback,color) end end
			local function makeChan(lbl,init,y)
				local row=New("Frame",{Position=UDim2.new(0,0,0,y),Size=UDim2.new(1,0,0,32),BackgroundTransparency=1,ZIndex=z+2,Parent=panel})
				New("TextLabel",{Text=lbl,Font=Enum.Font.GothamBold,TextSize=11,TextColor3=cC[lbl],BackgroundTransparency=1,Size=UDim2.new(0,14,1,0),ZIndex=z+3,Parent=row})
				local vl=New("TextLabel",{Text=tostring(init),Font=Enum.Font.Gotham,TextSize=10,TextColor3=theme.SubText,TextXAlignment=XR,BackgroundTransparency=1,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),Size=UDim2.new(0,29,1,0),ZIndex=z+3,Parent=row})
				local bH=New("Frame",{Position=UDim2.new(0,18,.5,-11),Size=UDim2.new(1,-52,0,22),BackgroundTransparency=1,ZIndex=z+3,Parent=row})
				local bar_=New("Frame",{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,0,.5,0),Size=UDim2.new(1,0,0,6),BackgroundColor3=theme.Stroke,ZIndex=z+3,Parent=bH},{New("UICorner",{CornerRadius=UDim.new(1,0)})})
				local fill_=New("Frame",{Size=UDim2.new(init/255,0,1,0),BackgroundColor3=cC[lbl],ZIndex=z+4,Parent=bar_},{New("UICorner",{CornerRadius=UDim.new(1,0)})}); New("Frame",{Size=UDim2.new(1,0,.6,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.80,BorderSizePixel=0,ZIndex=z+5,Parent=fill_},{New("UICorner",{CornerRadius=UDim.new(1,0)})})
				local cv=init
				local function setRaw(a) a=C01(a); cv=floor(a*255+.5); vl.Text=tostring(cv); fill_.Size=UDim2.new(a,0,1,0); applyColor() end
				bH.InputBegan:Connect(function(i) if i.UserInputType==MB1 or i.UserInputType==TOUCH then setRaw((i.Position.X-bH.AbsolutePosition.X)/bH.AbsoluteSize.X); beginDrag(function(mi) setRaw((mi.Position.X-bH.AbsolutePosition.X)/bH.AbsoluteSize.X) end,function()end) end end)
				return {get=function() return cv end,setV=function(v) cv=v; vl.Text=tostring(v); fill_.Size=UDim2.new(v/255,0,1,0) end}
			end
			local r0,g0,b0=floor(color.R*255),floor(color.G*255),floor(color.B*255)
			chans.R=makeChan("R",r0,0); chans.G=makeChan("G",g0,38); chans.B=makeChan("B",b0,76)
			local hr=New("Frame",{Position=UDim2.new(0,0,0,116),Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,ZIndex=z+2,Parent=panel})
			New("TextLabel",{Text="HEX",Font=Enum.Font.GothamBold,TextSize=10,TextColor3=theme.SubText,BackgroundTransparency=1,Size=UDim2.new(0,30,1,0),ZIndex=z+3,Parent=hr})
			local hbox=New("TextBox",{Text=ToHex(color),Font=Enum.Font.Code,TextSize=11,TextColor3=theme.Text,PlaceholderText="#RRGGBB",PlaceholderColor3=theme.MutedText,ClearTextOnFocus=false,BackgroundColor3=Darken(theme.Elevated,.04),Position=UDim2.new(0,36,0,0),Size=UDim2.new(1,-36,1,0),ZIndex=z+3,Parent=hr},{New("UICorner",{CornerRadius=UDim.new(0,7)}),New("UIStroke",{Color=theme.Stroke,Thickness=1}),New("UIPadding",{PaddingLeft=UDim.new(0,7)})})
			hbox.FocusLost:Connect(function() local ok,nc=pcall(FromHex,hbox.Text); if ok and nc then chans.R.setV(floor(nc.R*255)); chans.G.setV(floor(nc.G*255)); chans.B.setV(floor(nc.B*255)); applyColor() end; hbox.Text=ToHex(color) end)
			local cpH=mob and 214 or 182
			head.MouseButton1Click:Connect(function() open=not open; T(holder,{Size=UDim2.new(1,0,0,open and cpH or 40)},.20) end)
			if opts.Flag then NovaUI.Flags[opts.Flag]=color end
			local api={Set=function(v) color=v; swatch.BackgroundColor3=v; hexLbl.Text=ToHex(v); hbox.Text=ToHex(v); chans.R.setV(floor(v.R*255)); chans.G.setV(floor(v.G*255)); chans.B.setV(floor(v.B*255)) end,Get=function() return color end}
			if opts.Flag then comps[opts.Flag]=api end; return api
		end

		function Tab:CreateProgress(opts)
			opts=opts or {}; local z=zi(); local val=clamp(opts.Value or 0,0,100)
			local holder=New("Frame",{BackgroundColor3=theme.Elevated,Size=UDim2.new(1,0,0,56),ZIndex=z,Parent=Page},{New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.05)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90})})
			TopHL(holder,z)
			New("TextLabel",{Text=opts.Name or "Progress",Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=theme.Text,TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,14,0,9),Size=UDim2.new(1,-28,0,19),ZIndex=z+1,Parent=holder})
			local pLbl=New("TextLabel",{Text=tostring(val).."%",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=theme.Accent,TextXAlignment=XR,BackgroundTransparency=1,Position=UDim2.new(0,14,0,9),Size=UDim2.new(1,-28,0,19),ZIndex=z+1,Parent=holder})
			local trk=New("Frame",{Position=UDim2.new(0,14,0,38),Size=UDim2.new(1,-28,0,8),BackgroundColor3=theme.Stroke,ZIndex=z+1,Parent=holder},{New("UICorner",{CornerRadius=UDim.new(1,0)})})
			local fill=New("Frame",{Size=UDim2.new(val/100,0,1,0),BackgroundColor3=theme.Accent,ZIndex=z+2,Parent=trk},{New("UICorner",{CornerRadius=UDim.new(1,0)}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,theme.AccentDark),ColorSequenceKeypoint.new(.5,theme.AccentLight),ColorSequenceKeypoint.new(1,theme.Accent)})})})
			New("Frame",{Size=UDim2.new(1,0,.6,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.80,BorderSizePixel=0,ZIndex=z+3,Parent=fill},{New("UICorner",{CornerRadius=UDim.new(1,0)})})
			local function setV(v) v=clamp(v,0,100); val=v; pLbl.Text=tostring(Round(v,1)).."%"; T(fill,{Size=UDim2.new(v/100,0,1,0)},.32); T(fill,{BackgroundColor3=v>=100 and theme.Success or theme.Accent},.26) end
			return {Set=setV,Get=function() return val end}
		end

		function Tab:CreateBadge(opts)
			opts=opts or {}; local z=zi()
			local function tC(tp) if tp=="Success" then return theme.SuccessBg,theme.Success elseif tp=="Danger" then return theme.DangerBg,theme.Danger elseif tp=="Warning" then return theme.WarningBg,theme.Warning elseif tp=="Info" then return theme.InfoBg,theme.Info elseif tp=="Accent" then return theme.AccentBg,theme.Accent else return theme.Elevated,theme.SubText end end
			local bg,tx=tC(opts.Type or "Default")
			local row=New("Frame",{BackgroundTransparency=1,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=z,Parent=Page},{New("UIListLayout",{FillDirection=HFILL,Padding=UDim.new(0,6),SortOrder=SORT})})
			local badge=New("TextLabel",{Text=opts.Name or "Badge",Font=Enum.Font.GothamBold,TextSize=11,TextColor3=tx,BackgroundColor3=bg,Size=UDim2.new(0,0,0,24),AutomaticSize=AS_X,ZIndex=z+1,Parent=row},{New("UICorner",{CornerRadius=UDim.new(1,0)}),New("UIPadding",{PaddingLeft=UDim.new(0,11),PaddingRight=UDim.new(0,11)})}); ShineLayer(badge,z+1,.82)
			return {SetText=function(t) badge.Text=t end,SetType=function(tp) local b2,t2=tC(tp); badge.BackgroundColor3=b2; badge.TextColor3=t2 end}
		end

		function Tab:CreateImage(opts)
			opts=opts or {}; local z=zi(); local h=opts.Height or 124
			local frame=New("Frame",{BackgroundColor3=theme.Elevated,Size=UDim2.new(1,0,0,h),ClipsDescendants=true,ZIndex=z,Parent=Page},{New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1})})
			local img=New("ImageLabel",{Image=opts.Image or "",BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=z+1,ScaleType=CROP,Parent=frame})
			if opts.Caption then local cap=New("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,32),BackgroundColor3=C3(0,0,0),BackgroundTransparency=.30,ZIndex=z+2,Parent=frame}); New("TextLabel",{Text=opts.Caption,Font=Enum.Font.Gotham,TextSize=12,TextColor3=Color3.new(1,1,1),TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-12,1,0),ZIndex=z+3,Parent=cap}) end
			return {SetImage=function(id) img.Image=id end,GetImage=function() return img.Image end}
		end

		function Tab:CreateList(opts)
			opts=opts or {}; local z=zi()
			local items=opts.Items or {}; local maxV=opts.MaxVisible or 6; local rH=mob and 44 or 36
			local lH=min(#items,maxV)*rH
			local frame=New("Frame",{BackgroundColor3=theme.Elevated,Size=UDim2.new(1,0,0,opts.Name and lH+30 or lH),ClipsDescendants=true,ZIndex=z,Parent=Page},{New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1})})
			local hdrH=0
			if opts.Name then hdrH=30; local hdr=New("Frame",{BackgroundColor3=Lighten(theme.Elevated,.03),Size=UDim2.new(1,0,0,hdrH),ZIndex=z+1,Parent=frame},{New("UICorner",{CornerRadius=UDim.new(0,12)}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.07)),ColorSequenceKeypoint.new(1,Lighten(theme.Elevated,.02))}),Rotation=90})}); New("Frame",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-14),BackgroundColor3=Lighten(theme.Elevated,.03),BorderSizePixel=0,ZIndex=z+1,Parent=hdr}); New("TextLabel",{Text=opts.Name,Font=Enum.Font.GothamBold,TextSize=11,TextColor3=theme.SubText,TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-12,1,0),ZIndex=z+2,Parent=hdr}) end
			local scr=New("ScrollingFrame",{BackgroundTransparency=1,Position=UDim2.new(0,0,0,hdrH),Size=UDim2.new(1,0,1,-hdrH),CanvasSize=UDim2.new(0,0,0,#items*rH),ScrollBarThickness=mob and 5 or 3,ScrollBarImageColor3=theme.Accent,ScrollingDirection=SCRY,BorderSizePixel=0,ZIndex=z+1,Parent=frame})
			New("UIListLayout",{Padding=UDim.new(0,0),SortOrder=SORT,Parent=scr})
			local sel,rows=nil,{}
			for i,item in next,items do
				local even=i%2==0; local row=New("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=even and Darken(theme.Elevated,.03) or theme.Elevated,Size=UDim2.new(1,0,0,rH),ZIndex=z+2,Parent=scr})
				if item.Icon then New("ImageLabel",{Image=item.Icon,BackgroundTransparency=1,ImageColor3=theme.SubText,Position=UDim2.new(0,10,.5,-8),Size=UDim2.fromOffset(16,16),ZIndex=z+3,Parent=row}) end
				New("TextLabel",{Text=item.Label or tostring(i),Font=Enum.Font.Gotham,TextSize=13,TextColor3=theme.Text,TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,item.Icon and 34 or 12,0,0),Size=UDim2.new(1,-30,1,0),ZIndex=z+3,Parent=row})
				if item.Value then New("TextLabel",{Text=tostring(item.Value),Font=Enum.Font.Gotham,TextSize=11,TextColor3=theme.SubText,TextXAlignment=XR,BackgroundTransparency=1,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-12,.5,0),Size=UDim2.new(0,80,0,18),ZIndex=z+3,Parent=row}) end
				if i<#items then New("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,1),BackgroundColor3=theme.Stroke,BorderSizePixel=0,ZIndex=z+3,Parent=row}) end
				local base=row.BackgroundColor3
				row.MouseEnter:Connect(function() if sel~=i then T(row,{BackgroundColor3=theme.ElevatedHover},.08) end end)
				row.MouseLeave:Connect(function() if sel~=i then T(row,{BackgroundColor3=base},.12) end end)
				row.MouseButton1Click:Connect(function()
					if sel and rows[sel] then T(rows[sel],{BackgroundColor3=sel%2==0 and Darken(theme.Elevated,.03) or theme.Elevated},.12) end
					sel=i; T(row,{BackgroundColor3=theme.AccentBg},.14); Ripple(row,UIS:GetMouseLocation())
					if item.Callback then spawn(item.Callback,item) end; if opts.OnSelect then spawn(opts.OnSelect,item,i) end
				end)
				rows[i]=row
			end
			return {GetSelected=function() return sel and items[sel] end,Deselect=function() if sel and rows[sel] then local si=sel; T(rows[si],{BackgroundColor3=si%2==0 and Darken(theme.Elevated,.03) or theme.Elevated},.12) end; sel=nil end}
		end

		function Tab:CreateTimeline(opts)
			opts=opts or {}; local z=zi(); local events=opts.Events or {}
			local holder=New("Frame",{BackgroundColor3=theme.Elevated,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=z,Parent=Page},{New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.05)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90}),New("UIPadding",{PaddingLeft=UDim.new(0,18),PaddingRight=UDim.new(0,16),PaddingTop=UDim.new(0,14),PaddingBottom=UDim.new(0,14)}),New("UIListLayout",{Padding=UDim.new(0,0),SortOrder=SORT})})
			TopHL(holder,z)
			if opts.Title then New("TextLabel",{Text=opts.Title,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=theme.Accent,TextXAlignment=XL,BackgroundTransparency=1,Size=UDim2.new(1,0,0,24),ZIndex=z+1,Parent=holder}) end
			local function tc(tp) if tp=="Success" then return theme.Success elseif tp=="Danger" then return theme.Danger elseif tp=="Warning" then return theme.Warning elseif tp=="Info" then return theme.Info else return theme.Accent end end
			for i,ev in next,events do
				local col=tc(ev.Type); local rH=ev.Detail and (mob and 62 or 54) or (mob and 46 or 38)
				local row=New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,rH),ZIndex=z+1,Parent=holder})
				if i<#events then New("Frame",{Position=UDim2.new(0,7,0,20),Size=UDim2.new(0,2,1,-20),BackgroundColor3=theme.Stroke,BorderSizePixel=0,ZIndex=z+2,Parent=row}) end
				local dot=New("Frame",{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(0,8,0,7),Size=UDim2.fromOffset(16,16),BackgroundColor3=col,ZIndex=z+3,Parent=row},{New("UICorner",{CornerRadius=UDim.new(1,0)})}); ShineLayer(dot,z+3,.74)
				New("TextLabel",{Text=ev.Label or "Event",Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=theme.Text,TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,30,0,5),Size=UDim2.new(1,-84,0,18),ZIndex=z+3,Parent=row})
				if ev.Time then New("TextLabel",{Text=tostring(ev.Time),Font=Enum.Font.Gotham,TextSize=11,TextColor3=theme.SubText,TextXAlignment=XR,BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,5),Size=UDim2.new(0,72,0,18),ZIndex=z+3,Parent=row}) end
				if ev.Detail then New("TextLabel",{Text=ev.Detail,Font=Enum.Font.Gotham,TextSize=11,TextColor3=theme.SubText,TextWrapped=true,TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,30,0,25),Size=UDim2.new(1,-38,0,20),ZIndex=z+3,Parent=row}) end
			end
		end

		function Tab:CreateTable(opts)
			opts=opts or {}; local z=zi()
			local cols=opts.Columns or {}; local nC=max(1,#cols); local cW=1/nC
			local holder=New("Frame",{BackgroundColor3=theme.Elevated,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=z,Parent=Page},{New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1}),New("UIListLayout",{Padding=UDim.new(0,0),SortOrder=SORT})})
			local hdr=New("Frame",{Name="TH",BackgroundColor3=Lighten(theme.Elevated,.06),Size=UDim2.new(1,0,0,34),ClipsDescendants=true,ZIndex=z+1,Parent=holder},{New("UICorner",{CornerRadius=UDim.new(0,12)}),New("UIListLayout",{FillDirection=HFILL,SortOrder=SORT}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.10)),ColorSequenceKeypoint.new(1,Lighten(theme.Elevated,.04))}),Rotation=90})}); New("Frame",{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,1,-16),BackgroundColor3=Lighten(theme.Elevated,.06),BorderSizePixel=0,ZIndex=z+1,Parent=hdr})
			for _,col in next,cols do New("TextLabel",{Text=col,Font=Enum.Font.GothamBold,TextSize=11,TextColor3=theme.SubText,TextXAlignment=XL,BackgroundTransparency=1,Size=UDim2.new(cW,0,1,0),ZIndex=z+2,Parent=hdr},{New("UIPadding",{PaddingLeft=UDim.new(0,12)})}) end
			local ri=0
			local function addRow(data)
				ri+=1; local even=ri%2==0
				local row=New("Frame",{Name="DR",BackgroundColor3=even and Darken(theme.Elevated,.02) or theme.Elevated,Size=UDim2.new(1,0,0,mob and 38 or 32),ZIndex=z+1,Parent=holder},{New("UIListLayout",{FillDirection=HFILL,SortOrder=SORT})})
				for j=1,nC do New("TextLabel",{Text=tostring(data[j] or ""),Font=Enum.Font.Gotham,TextSize=12,TextColor3=theme.Text,TextXAlignment=XL,BackgroundTransparency=1,Size=UDim2.new(cW,0,1,0),ZIndex=z+2,Parent=row},{New("UIPadding",{PaddingLeft=UDim.new(0,12)})}) end
				local hit=New("TextButton",{Text="",AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=z+3,Parent=row})
				local base=row.BackgroundColor3
				hit.MouseEnter:Connect(function() T(row,{BackgroundColor3=theme.ElevatedHover},.08) end); hit.MouseLeave:Connect(function() T(row,{BackgroundColor3=base},.12) end)
				if opts.OnRowClick then hit.MouseButton1Click:Connect(function() spawn(opts.OnRowClick,data,ri) end) end
				return row
			end
			for _,row in next,opts.Rows or {} do addRow(row) end
			New("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=theme.Stroke,BorderSizePixel=0,Parent=holder})
			return {AddRow=function(d) return addRow(d) end,Clear=function() ri=0; for _,c in next,holder:GetChildren() do if c.Name=="DR" then c:Destroy() end end end}
		end

		function Tab:CreateSearchBar(opts)
			opts=opts or {}; local z=zi()
			local holder=New("Frame",{BackgroundColor3=theme.Elevated,Size=UDim2.new(1,0,0,mob and 46 or 40),ZIndex=z,Parent=Page},{New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Name="S",Color=theme.Stroke,Thickness=1}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.06)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90})})
			New("TextLabel",{Text="⌕",Font=Enum.Font.GothamBold,TextSize=18,TextColor3=theme.SubText,BackgroundTransparency=1,Position=UDim2.new(0,11,0,0),Size=UDim2.new(0,26,1,0),ZIndex=z+1,Parent=holder})
			local box=New("TextBox",{Text="",PlaceholderText=opts.Placeholder or "Search…",Font=Enum.Font.Gotham,TextSize=13,TextColor3=theme.Text,PlaceholderColor3=theme.MutedText,ClearTextOnFocus=false,BackgroundTransparency=1,Position=UDim2.new(0,38,0,0),Size=UDim2.new(1,-50,1,0),TextXAlignment=XL,ZIndex=z+1,Parent=holder})
			local sk=holder:FindFirstChild("S"); box.Focused:Connect(function() if sk then T(sk,{Color=theme.Accent,Thickness=1.8},.14) end end); box.FocusLost:Connect(function() if sk then T(sk,{Color=theme.Stroke,Thickness=1},.14) end end)
			local clrBtn=New("TextButton",{Text="✕",Font=Enum.Font.GothamBold,TextSize=11,TextColor3=theme.SubText,BackgroundTransparency=1,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-9,.5,0),Size=UDim2.new(0,20,0,20),Visible=false,ZIndex=z+2,Parent=holder})
			box:GetPropertyChangedSignal("Text"):Connect(function() clrBtn.Visible=box.Text~=""; if opts.OnChanged then spawn(opts.OnChanged,box.Text) end end)
			clrBtn.MouseButton1Click:Connect(function() box.Text=""; clrBtn.Visible=false; if opts.OnChanged then spawn(opts.OnChanged,"") end end)
			return {Get=function() return box.Text end,Set=function(v) box.Text=v end,Clear=function() box.Text="" end}
		end

		function Tab:CreateGrid(opts)
			opts=opts or {}; local z=zi(); local items=opts.Items or {}; local cols=opts.Columns or 2
			local holder=New("Frame",{BackgroundTransparency=1,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=z,Parent=Page},{New("UIGridLayout",{CellSize=UDim2.new(1/cols,-4,0,mob and 46 or 38),CellPadding=UDim2.new(0,4,0,4),SortOrder=SORT})})
			local cells={}
			for i,item in next,items do
				local btn=New("TextButton",{Text=item.Name or tostring(i),Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=theme.Text,BackgroundColor3=theme.Elevated,Size=UDim2.new(0,0,0,0),ZIndex=z+1,Parent=holder},{New("UICorner",{CornerRadius=UDim.new(0,12)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.06)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90})})
				ShineLayer(btn,z+1,.84); PressAnim(btn); HoverBg(btn,theme.Elevated,theme.ElevatedHover)
				if item.Callback then btn.MouseButton1Click:Connect(function() Ripple(btn,UIS:GetMouseLocation()); spawn(item.Callback) end) end
				cells[i]=btn
			end
			return {Cells=cells}
		end

		-- Pure-Lua spinner: 3 dots orbit a faint ring track. Zero external assets.
		function Tab:CreateSpinner(opts)
			opts=opts or {}; local z=zi()
			local holder=New("Frame",{BackgroundColor3=theme.Elevated,Size=UDim2.new(1,0,0,50),ZIndex=z,Parent=Page},{New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.05)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90})})
			TopHL(holder,z)
			local lbl=New("TextLabel",{Text=opts.Name or "Loading…",Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=theme.SubText,TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,56,0,0),Size=UDim2.new(1,-70,1,0),ZIndex=z+1,Parent=holder})
			local ring=New("Frame",{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,13,.5,0),Size=UDim2.new(0,30,0,30),BackgroundTransparency=1,ZIndex=z+1,Parent=holder})
			New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=z+1,Parent=ring},{New("UICorner",{CornerRadius=UDim.new(1,0)}),New("UIStroke",{Color=theme.Stroke,Thickness=2,ApplyStrokeMode=BORD})})
			local N=3; local R=11; local DS=6; local half=DS*.5; local s2pi=(2*pi)/N
			local phases={}; for i=1,N do phases[i]=(i-1)*s2pi end
			local dots={}
			for i=1,N do dots[i]=New("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromOffset(15,15),Size=UDim2.fromOffset(DS,DS),BackgroundColor3=theme.Accent,BackgroundTransparency=(i-1)*(0.56/N),ZIndex=z+2,Parent=ring},{New("UICorner",{CornerRadius=UDim.new(1,0)})}) end
			local spinConn=nil
			local function startSpin()
				if spinConn then pcall(spinConn.Disconnect,spinConn) end
				local angle=0
				spinConn=RS.Heartbeat:Connect(function(dt) angle=angle+dt*290; local ar=angle*(pi/180); for i=1,N do local a=ar+phases[i]; dots[i].Position=UDim2.fromOffset(15+R*cos(a)-half,15+R*sin(a)-half) end end)
				track(spinConn)
			end
			startSpin()
			return {SetText=function(t) lbl.Text=t end,Stop=function() if spinConn then spinConn:Disconnect(); spinConn=nil end; ring.Visible=false end,Start=function() ring.Visible=true; startSpin() end}
		end

		function Tab:CreateAlert(opts)
			opts=opts or {}; local z=zi()
			local function ac(tp) if tp=="Success" then return theme.SuccessBg,theme.Success elseif tp=="Danger" then return theme.DangerBg,theme.Danger elseif tp=="Warning" then return theme.WarningBg,theme.Warning else return theme.InfoBg,theme.Info end end
			local bg,col=ac(opts.Type or "Info"); local icons={Info="ℹ",Success="✓",Danger="✕",Warning="⚠"}
			local holder=New("Frame",{BackgroundColor3=bg,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=z,Parent=Page},{New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=col,Thickness=1,Transparency=.60}),New("UIPadding",{PaddingLeft=UDim.new(0,46),PaddingRight=UDim.new(0,14),PaddingTop=UDim.new(0,11),PaddingBottom=UDim.new(0,11)}),New("UIListLayout",{Padding=UDim.new(0,4),SortOrder=SORT})})
			TopHL(holder,z)
			-- Left colour bar with gradient
			New("Frame",{Size=UDim2.new(0,4,1,-22),Position=UDim2.new(0,0,0,11),BackgroundColor3=col,BorderSizePixel=0,ZIndex=z+1,Parent=holder},{New("UICorner",{CornerRadius=UDim.new(1,0)}),New("UIGradient",{Color=ColorSequence.new(Lighten(col,.12),col),Rotation=90})})
			-- Icon circle with shine
			local ic=New("TextLabel",{Text=icons[opts.Type or "Info"] or "ℹ",Font=Enum.Font.GothamBold,TextSize=14,TextColor3=col,BackgroundColor3=Darken(bg,.06),AnchorPoint=Vector2.new(0,0),Position=UDim2.new(0,10,0,11),Size=UDim2.new(0,26,0,26),ZIndex=z+2,Parent=holder},{New("UICorner",{CornerRadius=UDim.new(1,0)})}); ShineLayer(ic,z+2,.76)
			if opts.Title then New("TextLabel",{Text=opts.Title,Font=Enum.Font.GothamBold,TextSize=13,TextColor3=col,TextWrapped=true,TextXAlignment=XL,BackgroundTransparency=1,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=z+1,Parent=holder}) end
			local mLbl=New("TextLabel",{Text=opts.Message or "",Font=Enum.Font.Gotham,TextSize=12,TextColor3=col,TextWrapped=true,TextXAlignment=XL,BackgroundTransparency=1,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=z+1,Parent=holder})
			return {SetMessage=function(t) mLbl.Text=t end}
		end

		function Tab:CreateRating(opts)
			opts=opts or {}; local z=zi(); local maxS=opts.Max or 5; local cur=opts.Value or 0
			local holder=New("Frame",{BackgroundColor3=theme.Elevated,Size=UDim2.new(1,0,0,mob and 52 or 46),ZIndex=z,Parent=Page},{New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.05)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90})})
			TopHL(holder,z)
			if opts.Name then New("TextLabel",{Text=opts.Name,Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=theme.Text,TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,14,0,0),Size=UDim2.new(.5,0,1,0),ZIndex=z+1,Parent=holder}) end
			local sh=New("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-14,.5,0),Size=UDim2.fromOffset(maxS*28,28),BackgroundTransparency=1,ZIndex=z+1,Parent=holder})
			New("UIListLayout",{FillDirection=HFILL,Padding=UDim.new(0,3),SortOrder=SORT,Parent=sh})
			local stars={}
			local function upd(v) for i,s in next,stars do T(s,{TextColor3=i<=v and theme.Accent or theme.Stroke},.12) end end
			for i=1,maxS do
				local s=New("TextButton",{Text="★",Font=Enum.Font.GothamBold,TextSize=22,TextColor3=i<=cur and theme.Accent or theme.Stroke,BackgroundTransparency=1,Size=UDim2.new(0,24,0,28),ZIndex=z+2,Parent=sh})
				s.MouseEnter:Connect(function() upd(i) end); s.MouseLeave:Connect(function() upd(cur) end)
				s.MouseButton1Click:Connect(function() cur=i; upd(cur); NovaUI:SetFlag(opts.Flag,cur); if opts.Callback then spawn(opts.Callback,cur) end end)
				stars[i]=s
			end
			if opts.Flag then NovaUI.Flags[opts.Flag]=cur end
			local api={Set=function(v) cur=v; upd(v) end,Get=function() return cur end}
			if opts.Flag then comps[opts.Flag]=api end; return api
		end

		function Tab:CreateRadioGroup(opts)
			opts=opts or {}; local z=zi(); local options=opts.Options or {}; local cur=opts.DefaultOption or options[1]
			local holder=New("Frame",{BackgroundColor3=theme.Elevated,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=z,Parent=Page},{New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.05)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90}),New("UIPadding",{PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14),PaddingTop=UDim.new(0,12),PaddingBottom=UDim.new(0,12)}),New("UIListLayout",{Padding=UDim.new(0,7),SortOrder=SORT})})
			TopHL(holder,z)
			if opts.Name then New("TextLabel",{Text=opts.Name,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=theme.Accent,TextXAlignment=XL,BackgroundTransparency=1,Size=UDim2.new(1,0,0,20),ZIndex=z+1,Parent=holder}) end
			Tooltip(holder,theme,opts.Info)
			local btns={}
			local function updR(sel)
				for opt,rb in next,btns do local me=opt==sel; T(rb.o,{BackgroundColor3=me and theme.Accent or theme.Stroke},.16); T(rb.i,{BackgroundColor3=me and Color3.new(1,1,1) or theme.Stroke,Size=me and UDim2.fromOffset(9,9) or UDim2.fromOffset(0,0)},.16,BACK,OUT); rb.l.TextColor3=me and theme.Text or theme.SubText end
			end
			for _,opt in next,options do
				local rH=mob and 38 or 28
				local row=New("TextButton",{Text="",AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.new(1,0,0,rH),ZIndex=z+1,Parent=holder})
				local o=New("Frame",{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,0,.5,0),Size=UDim2.fromOffset(20,20),BackgroundColor3=opt==cur and theme.Accent or theme.Stroke,ZIndex=z+2,Parent=row},{New("UICorner",{CornerRadius=UDim.new(1,0)}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(opt==cur and theme.Accent or theme.Stroke,.06)),ColorSequenceKeypoint.new(1,opt==cur and theme.Accent or theme.Stroke)}),Rotation=90})})
				local i_=New("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),Size=opt==cur and UDim2.fromOffset(9,9) or UDim2.fromOffset(0,0),BackgroundColor3=Color3.new(1,1,1),ZIndex=z+3,Parent=o},{New("UICorner",{CornerRadius=UDim.new(1,0)})})
				local l=New("TextLabel",{Text=tostring(opt),Font=Enum.Font.Gotham,TextSize=13,TextColor3=opt==cur and theme.Text or theme.SubText,TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,28,0,0),Size=UDim2.new(1,-28,1,0),ZIndex=z+2,Parent=row})
				btns[opt]={o=o,i=i_,l=l}
				row.MouseEnter:Connect(function() if opt~=cur then l.TextColor3=theme.Text end end)
				row.MouseLeave:Connect(function() if opt~=cur then l.TextColor3=theme.SubText end end)
				row.MouseButton1Click:Connect(function() cur=opt; updR(opt); NovaUI:SetFlag(opts.Flag,opt); if opts.Callback then spawn(opts.Callback,opt) end end)
			end
			if opts.Flag then NovaUI.Flags[opts.Flag]=cur end
			local api={Set=function(v) cur=v; updR(v) end,Get=function() return cur end}
			if opts.Flag then comps[opts.Flag]=api end; return api
		end

		function Tab:CreateChipGroup(opts)
			opts=opts or {}; local z=zi()
			local options=opts.Options or {}; local multi=opts.MultiSelect~=false; local maxSel=opts.MaxSelect or huge; local selected={}
			for _,v in next,opts.DefaultSelected or {} do selected[v]=true end
			local holder=New("Frame",{BackgroundColor3=theme.Elevated,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=z,Parent=Page},{New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.05)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90}),New("UIPadding",{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12),PaddingTop=UDim.new(0,11),PaddingBottom=UDim.new(0,11)}),New("UIListLayout",{Padding=UDim.new(0,7),SortOrder=SORT})})
			TopHL(holder,z)
			if opts.Name then New("TextLabel",{Text=opts.Name,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=theme.Accent,TextXAlignment=XL,BackgroundTransparency=1,Size=UDim2.new(1,0,0,20),ZIndex=z+1,Parent=holder}) end
			local crow=New("Frame",{BackgroundTransparency=1,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=z+1,Parent=holder},{New("UIListLayout",{FillDirection=HFILL,Padding=UDim.new(0,7),SortOrder=SORT,Wraps=true})})
			local chips={}; local cH=mob and 34 or 28
			local function updChip(opt)
				local ch=chips[opt]; if not ch then return end; local sel=selected[opt]==true
				T(ch,{BackgroundColor3=sel and theme.AccentBg or theme.Elevated,TextColor3=sel and theme.Accent or theme.SubText},.14)
				local sk=ch:FindFirstChildOfClass("UIStroke"); if sk then T(sk,{Color=sel and theme.Accent or theme.StrokeStrong,Thickness=sel and 1.5 or 1},.14) end
			end
			for _,opt in next,options do
				local sel=selected[opt]==true
				local ch=New("TextButton",{Text=" "..tostring(opt).." ",Font=Enum.Font.GothamMedium,TextSize=mob and 13 or 12,TextColor3=sel and theme.Accent or theme.SubText,BackgroundColor3=sel and theme.AccentBg or theme.Elevated,AutomaticSize=AS_X,Size=UDim2.new(0,0,0,cH),ZIndex=z+2,Parent=crow},{New("UICorner",{CornerRadius=UDim.new(1,0)}),New("UIStroke",{Color=sel and theme.Accent or theme.StrokeStrong,Thickness=sel and 1.5 or 1})})
				ShineLayer(ch,z+2,.87); PressAnim(ch); chips[opt]=ch
				ch.MouseButton1Click:Connect(function()
					if multi then local n=0; for _ in next,selected do n+=1 end; if not selected[opt] and n>=maxSel then return end; if selected[opt] then selected[opt]=nil else selected[opt]=true end
					else selected={}; selected[opt]=true end
					for _,o in next,options do updChip(o) end
					local l={}; for v in next,selected do l[#l+1]=v end; NovaUI:SetFlag(opts.Flag,l); if opts.Callback then spawn(opts.Callback,l) end
				end)
			end
			if opts.Flag then local l={}; for v in next,selected do l[#l+1]=v end; NovaUI.Flags[opts.Flag]=l end
			local api={Get=function() local l={}; for v in next,selected do l[#l+1]=v end; return l end,Set=function(vals) selected={}; for _,v in next,vals do selected[v]=true end; for _,o in next,options do updChip(o) end end}
			if opts.Flag then comps[opts.Flag]=api end; return api
		end

		function Tab:CreateAccordion(opts)
			opts=opts or {}; local z=zi(); local isOpen=opts.DefaultOpen==true
			local holder=New("Frame",{BackgroundColor3=theme.Elevated,ClipsDescendants=true,Size=UDim2.new(1,0,0,42),ZIndex=z,Parent=Page},{New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.05)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90})})
			TopHL(holder,z)
			local head=New("TextButton",{Text="",AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.new(1,0,0,42),ZIndex=z+1,Parent=holder})
			head.MouseEnter:Connect(function() T(holder,{BackgroundColor3=theme.ElevatedHover},.10) end); head.MouseLeave:Connect(function() T(holder,{BackgroundColor3=theme.Elevated},.16) end)
			if opts.Icon then New("ImageLabel",{Image=opts.Icon,BackgroundTransparency=1,ImageColor3=theme.Accent,Position=UDim2.new(0,13,.5,-9),Size=UDim2.fromOffset(18,18),ZIndex=z+2,Parent=head}) end
			New("TextLabel",{Text=opts.Title or "Section",Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=theme.Text,TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,opts.Icon and 38 or 14,0,0),Size=UDim2.new(1,-52,1,0),ZIndex=z+2,Parent=head})
			local chev=New("TextLabel",{Text="▸",Font=Enum.Font.GothamBold,TextSize=13,TextColor3=theme.Accent,BackgroundTransparency=1,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-14,.5,0),Size=UDim2.new(0,14,0,14),ZIndex=z+2,Parent=head})
			New("Frame",{Position=UDim2.new(0,10,0,42),Size=UDim2.new(1,-20,0,1),BackgroundColor3=theme.Stroke,BorderSizePixel=0,ZIndex=z+1,Parent=holder},{New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,theme.Background),ColorSequenceKeypoint.new(.1,theme.Stroke),ColorSequenceKeypoint.new(.9,theme.Stroke),ColorSequenceKeypoint.new(1,theme.Background)})})})
			local content=New("Frame",{BackgroundTransparency=1,Position=UDim2.new(0,0,0,44),Size=UDim2.new(1,0,0,0),AutomaticSize=AS_Y,ZIndex=z+1,Parent=holder},{New("UIPadding",{PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14),PaddingBottom=UDim.new(0,11)}),New("UIListLayout",{Padding=UDim.new(0,6),SortOrder=SORT})})
			if type(opts.Content)=="string" then New("TextLabel",{Text=opts.Content,Font=Enum.Font.Gotham,TextSize=12,TextColor3=theme.SubText,TextWrapped=true,TextXAlignment=XL,BackgroundTransparency=1,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=z+2,Parent=content})
			elseif type(opts.Content)=="function" then defer(function() opts.Content(content) end) end
			local function getH(cb) spawn(function() for _=1,12 do if content.AbsoluteSize.Y>0 then break end; RS.Heartbeat:Wait() end; cb(content.AbsoluteSize.Y+54) end) end
			local function toggle() isOpen=not isOpen; T(chev,{Rotation=isOpen and 90 or 0},.18); if isOpen then getH(function(h) T(holder,{Size=UDim2.new(1,0,0,h)},.24,QUINT) end) else T(holder,{Size=UDim2.new(1,0,0,42)},.20,QUINT) end end
			if isOpen then chev.Rotation=90; getH(function(h) holder.Size=UDim2.new(1,0,0,h) end) end
			head.MouseButton1Click:Connect(toggle)
			return {Open=function() if not isOpen then toggle() end end,Close=function() if isOpen then toggle() end end,Toggle=toggle,Content=content}
		end

		function Tab:CreateStatusIndicator(opts)
			opts=opts or {}; local z=zi()
			local function rc(s) if s=="Online" then return theme.Success elseif s=="Offline" then return theme.MutedText elseif s=="Busy" then return theme.Danger elseif s=="Away" then return theme.Warning else return opts.Color or theme.Accent end end
			local holder=New("Frame",{BackgroundColor3=theme.Elevated,Size=UDim2.new(1,0,0,mob and 44 or 38),ZIndex=z,Parent=Page},{New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.05)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90})})
			TopHL(holder,z)
			if opts.Name then New("TextLabel",{Text=opts.Name,Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=theme.SubText,TextXAlignment=XL,BackgroundTransparency=1,Position=UDim2.new(0,14,0,0),Size=UDim2.new(.5,0,1,0),ZIndex=z+1,Parent=holder}) end
			local dC=rc(opts.Status)
			local dot=New("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-38,.5,0),Size=UDim2.fromOffset(12,12),BackgroundColor3=dC,ZIndex=z+2,Parent=holder},{New("UICorner",{CornerRadius=UDim.new(1,0)})}); ShineLayer(dot,z+2,.74)
			local sLbl=New("TextLabel",{Text=opts.Status or "Unknown",Font=Enum.Font.Gotham,TextSize=12,TextColor3=dC,TextXAlignment=XR,BackgroundTransparency=1,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-56,.5,0),Size=UDim2.new(0,84,0,22),ZIndex=z+1,Parent=holder})
			local pulseC=nil; local curS=opts.Status or "Unknown"
			local function pulse(on)
				if pulseC then pulseC:Disconnect(); pulseC=nil end
				if on then local t0=tick(); pulseC=RS.Heartbeat:Connect(function() dot.BackgroundTransparency=(sin((tick()-t0)*3.2)+1)*.22 end); track(pulseC)
				else dot.BackgroundTransparency=0 end
			end
			if curS=="Online" then pulse(true) end
			return {SetStatus=function(s,c) curS=s; local col=c or rc(s); T(dot,{BackgroundColor3=col},.20); T(sLbl,{TextColor3=col},.20); sLbl.Text=s; pulse(s=="Online"); NovaUI:SetFlag(opts.Flag,s) end,GetStatus=function() return curS end}
		end

		function Tab:CreateTabGroup(opts)
			opts=opts or {}; local z=zi()
			local tabs_=opts.Tabs or {}; local def=opts.DefaultTab or (tabs_[1] and tabs_[1].Name)
			local wrap=New("Frame",{BackgroundColor3=theme.Elevated,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=z,Parent=Page},{New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.05)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90}),New("UIListLayout",{Padding=UDim.new(0,0),SortOrder=SORT})})
			TopHL(wrap,z)
			local pr=New("Frame",{BackgroundColor3=Lighten(theme.Elevated,.04),Size=UDim2.new(1,0,0,38),ZIndex=z+1,Parent=wrap},{New("UICorner",{CornerRadius=UDim.new(0,12)}),New("UIListLayout",{FillDirection=HFILL,HorizontalAlignment=HALC,Padding=UDim.new(0,5),SortOrder=SORT}),New("UIPadding",{PaddingLeft=UDim.new(0,7),PaddingRight=UDim.new(0,7),PaddingTop=UDim.new(0,6)}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.08)),ColorSequenceKeypoint.new(1,Lighten(theme.Elevated,.03))}),Rotation=90})})
			New("Frame",{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,1,-16),BackgroundColor3=Lighten(theme.Elevated,.04),BorderSizePixel=0,ZIndex=z+1,Parent=pr})
			local ca=New("Frame",{BackgroundTransparency=1,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=z+1,Parent=wrap},{New("UIPadding",{PaddingLeft=UDim.new(0,13),PaddingRight=UDim.new(0,13),PaddingTop=UDim.new(0,11),PaddingBottom=UDim.new(0,11)})})
			local pages_,pills,cur_={},{},nil
			local function selI(name)
				for n,p in next,pages_ do p.Visible=n==name end; cur_=name
				for n,btn in next,pills do
					local s=n==name
					T(btn,{BackgroundColor3=s and theme.Accent or Lighten(theme.Elevated,.03),TextColor3=s and C3(12,12,12) or theme.SubText,BackgroundTransparency=s and 0 or 1},.16)
				end
			end
			for _,t in next,tabs_ do
				local pg=New("Frame",{Name=t.Name,BackgroundTransparency=1,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),Visible=false,ZIndex=z+2,Parent=ca},{New("UIListLayout",{Padding=UDim.new(0,7),SortOrder=SORT})})
				pages_[t.Name]=pg
				local pill=New("TextButton",{Text=t.Name,Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=theme.SubText,BackgroundColor3=theme.Accent,BackgroundTransparency=1,AutomaticSize=AS_X,Size=UDim2.new(0,0,0,27),ZIndex=z+2,Parent=pr},{New("UICorner",{CornerRadius=UDim.new(0,9)}),New("UIPadding",{PaddingLeft=UDim.new(0,13),PaddingRight=UDim.new(0,13)})})
				ShineLayer(pill,z+2,.84); pills[t.Name]=pill
				pill.MouseButton1Click:Connect(function() selI(t.Name) end)
				if t.Content and type(t.Content)=="function" then defer(function() t.Content(pg) end) end
			end
			selI(def)
			return {Select=selI,GetCurrent=function() return cur_ end,Pages=pages_}
		end

		function Tab:CreateSkeleton(opts)
			opts=opts or {}; local z=zi(); local nL=opts.Lines or 3; local lH=opts.Height or 18
			local holder=New("Frame",{BackgroundColor3=theme.Elevated,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=z,Parent=Page},{New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=theme.StrokeStrong,Thickness=1}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(theme.Elevated,.05)),ColorSequenceKeypoint.new(1,Darken(theme.Elevated,.01))}),Rotation=90}),New("UIPadding",{PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14),PaddingTop=UDim.new(0,14),PaddingBottom=UDim.new(0,14)}),New("UIListLayout",{Padding=UDim.new(0,11),SortOrder=SORT})})
			local widths={.88,.66,.78,.55,.82,.70}
			for i=1,nL do
				local w=widths[(i-1)%#widths+1]
				local line=New("Frame",{BackgroundColor3=theme.Stroke,Size=UDim2.new(w,0,0,lH),ClipsDescendants=true,ZIndex=z+1,Parent=holder},{New("UICorner",{CornerRadius=UDim.new(0,7)})})
				local grad=New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(.40,Color3.new(1,1,1)),ColorSequenceKeypoint.new(.5,Lighten(theme.Stroke,.28)),ColorSequenceKeypoint.new(.60,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))}),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.55),NumberSequenceKeypoint.new(.40,.55),NumberSequenceKeypoint.new(.5,.04),NumberSequenceKeypoint.new(.60,.55),NumberSequenceKeypoint.new(1,.55)}),Rotation=10,Parent=line})
				local period=2.0; local phase=i*0.26
				local shimC=RS.Heartbeat:Connect(function() grad.Offset=Vector2.new(((tick()+phase)%period)/period*2-.5,0) end)
				track(shimC)
			end
			return {Replace=function(fn) for _,c in next,holder:GetChildren() do if not (c:IsA("UICorner") or c:IsA("UIStroke") or c:IsA("UIPadding") or c:IsA("UIListLayout") or c:IsA("UIGradient")) then c:Destroy() end end; fn(holder) end,Destroy=function() holder:Destroy() end}
		end

		function Tab:CreateConfigManager()
			self:CreateSection("Configuration"); local z=zi()
			local function mkBtn(lbl,bg_,tc_)
				local b=New("TextButton",{Text=lbl,Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=tc_ or theme.Text,BackgroundColor3=bg_ or theme.Elevated,Size=UDim2.new(1,0,0,40),ZIndex=z,Parent=Page},{New("UICorner",{CornerRadius=UDim.new(0,14)}),New("UIStroke",{Color=tc_ and Darken(tc_,.2) or theme.StrokeStrong,Thickness=1}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(bg_ or theme.Elevated,.06)),ColorSequenceKeypoint.new(1,Darken(bg_ or theme.Elevated,.01))}),Rotation=90})})
				TopHL(b,z); ShineLayer(b,z,.84); PressAnim(b); HoverBg(b,bg_ or theme.Elevated,theme.ElevatedHover); return b
			end
			local saveBtn=mkBtn("Export Config")
			self:CreateSeparatorLabel("Import")
			local function mkBox(ph,vis)
				local box=New("TextBox",{Text="",PlaceholderText=ph,Font=Enum.Font.Code,TextSize=11,TextColor3=theme.Text,PlaceholderColor3=theme.MutedText,ClearTextOnFocus=false,MultiLine=true,TextWrapped=true,TextXAlignment=XL,TextYAlignment=YT,BackgroundColor3=Darken(theme.Background,.04),Size=UDim2.new(1,0,0,70),Visible=vis~=false,ZIndex=z,Parent=Page},{New("UICorner",{CornerRadius=UDim.new(0,12)}),New("UIStroke",{Name="S",Color=theme.Stroke,Thickness=1}),New("UIPadding",{PaddingLeft=UDim.new(0,11),PaddingRight=UDim.new(0,11),PaddingTop=UDim.new(0,9),PaddingBottom=UDim.new(0,9)})})
				local sk=box:FindFirstChild("S"); box.Focused:Connect(function() if sk then T(sk,{Color=theme.Accent,Thickness=1.8},.14) end end); box.FocusLost:Connect(function() if sk then T(sk,{Color=theme.Stroke,Thickness=1},.14) end end); return box
			end
			local impBox=mkBox("Paste config string here…"); local loadBtn=mkBtn("Load Config"); local expBox=mkBox("Exported config appears here…",false); local rstBtn=mkBtn("Reset All Flags",theme.DangerBg,theme.Danger); rstBtn.Size=UDim2.new(1,0,0,34)
			saveBtn.MouseButton1Click:Connect(function() local s=NovaUI:ExportConfig(); if s then expBox.Text=s; expBox.Visible=true; NovaUI:Notify({Title="Config",Type="Success",Content="Exported.",Duration=4}) else NovaUI:Notify({Title="Config",Type="Danger",Content="Nothing to export.",Duration=3}) end end)
			loadBtn.MouseButton1Click:Connect(function() if Trim(impBox.Text)=="" then NovaUI:Notify({Title="Config",Type="Warning",Content="Paste a config string first.",Duration=3}); return end; if NovaUI:ImportConfig(impBox.Text) then NovaUI:Notify({Title="Config",Type="Success",Content="Loaded.",Duration=4}) else NovaUI:Notify({Title="Config",Type="Danger",Content="Could not parse string.",Duration=4}) end end)
			rstBtn.MouseButton1Click:Connect(function() NovaUI:ResetFlags(); impBox.Text=""; expBox.Text=""; expBox.Visible=false; NovaUI:Notify({Title="Config",Type="Warning",Content="All flags reset.",Duration=3}) end)
		end

		return Tab
	end -- CreateTab

	table.insert(NovaUI.Windows,Window); return Window
end -- CreateWindow

-- ══ CONFIRM DIALOG ════════════════════════════════════════════════════════════
function NovaUI:CreateConfirmDialog(opts)
	opts=opts or {}
	local win=NovaUI.Windows[#NovaUI.Windows]; if not win then return end
	local t=win.Theme or Themes.Dark; local sg=win.ScreenGui
	local overlay=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=C3(0,0,0),BackgroundTransparency=1,ZIndex=60,Parent=sg})
	T(overlay,{BackgroundTransparency=0.52},.18)
	local dialog=New("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.48,0),Size=UDim2.fromOffset(330,0),AutomaticSize=AS_Y,BackgroundColor3=t.Secondary,BackgroundTransparency=1,ZIndex=61,Parent=sg},{New("UICorner",{CornerRadius=UDim.new(0,18)}),New("UIStroke",{Color=t.StrokeStrong,Thickness=1}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(t.Secondary,.08)),ColorSequenceKeypoint.new(1,t.Secondary)}),Rotation=90}),New("UIPadding",{PaddingLeft=UDim.new(0,22),PaddingRight=UDim.new(0,22),PaddingTop=UDim.new(0,22),PaddingBottom=UDim.new(0,20)}),New("UIListLayout",{Padding=UDim.new(0,12),SortOrder=SORT})})
	TopHL(dialog,62)
	dialog.Size=UDim2.fromOffset(310,0); T(dialog,{BackgroundTransparency=0,Size=UDim2.fromOffset(330,0)},.24,BACK,OUT)
	New("TextLabel",{Text=opts.Title or "Are you sure?",Font=Enum.Font.GothamBold,TextSize=16,TextColor3=t.Text,TextXAlignment=XL,TextWrapped=true,BackgroundTransparency=1,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=62,Parent=dialog})
	New("TextLabel",{Text=opts.Message or "This action cannot be undone.",Font=Enum.Font.Gotham,TextSize=13,TextColor3=t.SubText,TextXAlignment=XL,TextWrapped=true,BackgroundTransparency=1,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=62,Parent=dialog})
	local br=New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,38),ZIndex=62,Parent=dialog}); New("UIListLayout",{FillDirection=HFILL,HorizontalAlignment=HALR,Padding=UDim.new(0,9),SortOrder=SORT,Parent=br})
	local function closeDialog() T(overlay,{BackgroundTransparency=1},.14); T(dialog,{BackgroundTransparency=1,Size=UDim2.fromOffset(310,0)},.16); delay(.17,function() pcall(overlay.Destroy,overlay); pcall(dialog.Destroy,dialog) end) end
	local cancelBtn=New("TextButton",{Text=opts.CancelText or "Cancel",Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=t.SubText,BackgroundColor3=t.Elevated,Size=UDim2.new(0,92,0,38),ZIndex=63,Parent=br},{New("UICorner",{CornerRadius=UDim.new(0,12)}),New("UIStroke",{Color=t.StrokeStrong,Thickness=1}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(t.Elevated,.06)),ColorSequenceKeypoint.new(1,t.Elevated)}),Rotation=90})}); ShineLayer(cancelBtn,63,.84); PressAnim(cancelBtn); cancelBtn.MouseButton1Click:Connect(function() closeDialog(); if opts.OnCancel then spawn(opts.OnCancel) end end)
	local confirmBtn=New("TextButton",{Text=opts.ConfirmText or "Confirm",Font=Enum.Font.GothamBold,TextSize=13,TextColor3=opts.Danger and Color3.new(1,1,1) or C3(11,11,11),BackgroundColor3=opts.Danger and t.Danger or t.Accent,Size=UDim2.new(0,108,0,38),ZIndex=63,Parent=br},{New("UICorner",{CornerRadius=UDim.new(0,12)}),New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(opts.Danger and t.Danger or t.Accent,.14)),ColorSequenceKeypoint.new(1,opts.Danger and t.Danger or t.Accent)}),Rotation=90})}); ShineLayer(confirmBtn,63,.76); PressAnim(confirmBtn); confirmBtn.MouseButton1Click:Connect(function() closeDialog(); if opts.OnConfirm then spawn(opts.OnConfirm) end end)
	return {Close=closeDialog}
end

-- ══ NOTIFICATIONS ═════════════════════════════════════════════════════════════
function NovaUI:Notify(opts)
	opts=opts or {}
	local target=(self.ScreenGui and self) or NovaUI.Windows[#NovaUI.Windows]
	if not target then return end
	local t=target.Theme or Themes.Dark; local mob=target._mob or IsMobile()
	local NH=target.ScreenGui:FindFirstChild("NH"); if not NH then return end
	local existing={}; for _,c in next,NH:GetChildren() do if c:IsA("Frame") then existing[#existing+1]=c end end
	if #existing>=6 then local old=existing[1]; T(old,{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1},.14); delay(.15,function() pcall(old.Destroy,old) end) end
	local accent,acBg=t.Accent,t.AccentBg
	if opts.Type=="Success" then accent,acBg=t.Success,t.SuccessBg
	elseif opts.Type=="Danger" or opts.Type=="Error" then accent,acBg=t.Danger,t.DangerBg
	elseif opts.Type=="Warning" then accent,acBg=t.Warning,t.WarningBg
	elseif opts.Type=="Info" then accent,acBg=t.Info,t.InfoBg end
	local icons={Success="✓",Danger="✕",Warning="⚠",Info="ℹ"}; local dur=opts.Duration or 4
	local wrapper=New("Frame",{BackgroundTransparency=1,ClipsDescendants=true,Size=UDim2.new(1,0,0,0),AutomaticSize=AS_Y,ZIndex=50,Parent=NH})
	local startPos=mob and UDim2.new(0,0,0,0) or UDim2.new(1,55,0,0)
	local card=New("Frame",{BackgroundColor3=t.Secondary,BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=AS_Y,Position=startPos,ZIndex=51,Parent=wrapper},{
		New("UICorner",{CornerRadius=UDim.new(0,16)}),
		New("UIStroke",{Name="SK",Color=t.StrokeStrong,Thickness=1,Transparency=1}),
		-- Glass gradient: lighter top, slightly darker bottom
		New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Lighten(t.Secondary,.09)),ColorSequenceKeypoint.new(1,t.Secondary)}),Rotation=90}),
		New("UIPadding",{PaddingLeft=UDim.new(0,44),PaddingRight=UDim.new(0,15),PaddingTop=UDim.new(0,12),PaddingBottom=UDim.new(0,12)}),
		New("UIListLayout",{Padding=UDim.new(0,3),SortOrder=SORT}),
	})
	TopHL(card,52)
	-- Left accent strip with gradient
	New("Frame",{Size=UDim2.new(0,4,1,-24),Position=UDim2.new(0,0,0,12),BackgroundColor3=accent,BorderSizePixel=0,ZIndex=54,Parent=card},{New("UICorner",{CornerRadius=UDim.new(1,0)}),New("UIGradient",{Color=ColorSequence.new(Lighten(accent,.14),accent),Rotation=90})})
	-- Icon circle with shine
	local ic=New("TextLabel",{Text=icons[opts.Type] or "●",Font=Enum.Font.GothamBold,TextSize=13,TextColor3=accent,BackgroundColor3=acBg,AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,8,.5,0),Size=UDim2.new(0,26,0,26),ZIndex=54,Parent=card},{New("UICorner",{CornerRadius=UDim.new(1,0)})}); ShineLayer(ic,54,.78)
	New("TextLabel",{Text=opts.Title or "Notification",Font=Enum.Font.GothamBold,TextSize=13,TextColor3=t.Text,TextXAlignment=XL,TextWrapped=true,BackgroundTransparency=1,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=52,Parent=card})
	New("TextLabel",{Text=opts.Content or "",Font=Enum.Font.Gotham,TextSize=12,TextColor3=t.SubText,TextXAlignment=XL,TextWrapped=true,BackgroundTransparency=1,AutomaticSize=AS_Y,Size=UDim2.new(1,0,0,0),ZIndex=52,Parent=card})
	-- Drain bar with gradient
	local pT=New("Frame",{Size=UDim2.new(1,0,0,3),BackgroundColor3=Darken(t.Stroke,.04),BorderSizePixel=0,ZIndex=54,Parent=card},{New("UICorner",{CornerRadius=UDim.new(1,0)})})
	local pF=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=accent,BorderSizePixel=0,ZIndex=55,Parent=pT},{New("UICorner",{CornerRadius=UDim.new(1,0)}),New("UIGradient",{Color=ColorSequence.new(accent,Darken(accent,.06))})}); New("Frame",{Size=UDim2.new(1,0,.6,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.78,BorderSizePixel=0,ZIndex=56,Parent=pF},{New("UICorner",{CornerRadius=UDim.new(1,0)})})
	local xBtn=New("TextButton",{Text="✕",Font=Enum.Font.GothamBold,TextSize=10,TextColor3=t.SubText,BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.new(0,20,0,20),ZIndex=57,Parent=card})
	local catcher=New("TextButton",{Text="",AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=56,Parent=card})
	local sk=card:FindFirstChild("SK")
	if mob then T(card,{BackgroundTransparency=0},.22); if sk then T(sk,{Transparency=0},.20) end
	else T(card,{Position=UDim2.new(0,0,0,0),BackgroundTransparency=0},.34,BACK,OUT); if sk then T(sk,{Transparency=0},.30) end end
	T(pF,{Size=UDim2.new(0,0,1,0)},dur,LIN)
	local dismissed=false
	local function dismiss()
		if dismissed then return end; dismissed=true
		if mob then T(card,{BackgroundTransparency=1},.18) else T(card,{Position=UDim2.new(1,55,0,0),BackgroundTransparency=1},.22,QUINT,INE) end
		if sk then T(sk,{Transparency=1},.16) end
		yield(.24); local h=wrapper.AbsoluteSize.Y
		if h>0 then wrapper.AutomaticSize=Enum.AutomaticSize.None; wrapper.Size=UDim2.new(1,0,0,h); T(wrapper,{Size=UDim2.new(1,0,0,0)},.18); yield(.20) end
		pcall(wrapper.Destroy,wrapper)
	end
	catcher.MouseButton1Click:Connect(function() spawn(dismiss) end); xBtn.MouseButton1Click:Connect(function() spawn(dismiss) end); delay(dur,function() spawn(dismiss) end)
end

-- ══ SERIALIZATION ══════════════════════════════════════════════════════════════
local function sv(v) local ty=typeof(v); if ty=="Color3" then return{__t="C3",r=v.R,g=v.G,b=v.B} elseif ty=="EnumItem" then return{__t="EN",e=tostring(v.EnumType),n=v.Name} elseif ty=="Vector2" then return{__t="V2",x=v.X,y=v.Y} elseif ty=="Vector3" then return{__t="V3",x=v.X,y=v.Y,z=v.Z} else return v end end
local function dv(v) if typeof(v)~="table" then return v end; if v.__t=="C3" then return Color3.new(v.r,v.g,v.b) elseif v.__t=="V2" then return Vector2.new(v.x,v.y) elseif v.__t=="V3" then return Vector3.new(v.x,v.y,v.z) elseif v.__t=="EN" then local ok,i=pcall(function() return Enum[v.e][v.n] end); return ok and i or nil end; return v end
function NovaUI:ExportConfig() local s={}; for f,val in next,NovaUI.Flags do s[f]=sv(val) end; local ok,enc=pcall(function() return HTTP:JSONEncode(s) end); return ok and enc or nil end
function NovaUI:ImportConfig(json) local ok,dec=pcall(function() return HTTP:JSONDecode(json) end); if not ok or typeof(dec)~="table" then return false end; for f,val in next,dec do NovaUI:SetFlag(f,dv(val)) end; return true end

-- ══ EXTRA API ══════════════════════════════════════════════════════════════════
function NovaUI:NotifySuccess(t,c,d) self:Notify({Title=t,Content=c,Type="Success",Duration=d or 4}) end
function NovaUI:NotifyError(t,c,d)   self:Notify({Title=t,Content=c,Type="Danger", Duration=d or 5}) end
function NovaUI:NotifyWarn(t,c,d)    self:Notify({Title=t,Content=c,Type="Warning",Duration=d or 4}) end
function NovaUI:NotifyInfo(t,c,d)    self:Notify({Title=t,Content=c,Type="Info",   Duration=d or 3}) end
function NovaUI:GetThemeNames() local n={}; for k in next,Themes do n[#n+1]=k end; table.sort(n); return n end
function NovaUI:RegisterTheme(name,t) Themes[name]=FT(t) end
function NovaUI:ExtendTheme(base,ov) local t={}; local b=typeof(base)=="string" and Themes[base] or base; for k,v in next,b do t[k]=v end; if ov then for k,v in next,ov do t[k]=v end end; return FT(t) end

NovaUI.Version="6.0"; NovaUI.VersionName="Lumen"; NovaUI.Themes=Themes
return NovaUI
