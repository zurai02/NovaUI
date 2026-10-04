--[[
╔══════════════════════════════════════════════════════════════════╗
║  N O V A U I   L I T E   ·   v 6 . 0   ·   " L u m e n "       ║
║  Slim fallback — same API as NovaUI, no depth effects/tweens     ║
║  ~450 lines · zero external assets · loads in <5 ms              ║
╚══════════════════════════════════════════════════════════════════╝
  Usage (auto-fallback in reporter.luau):
      local NovaUI = loadstring(game:HttpGet(NOVA_URL))()
               or loadstring(game:HttpGet(LITE_URL))()
  Or directly:
      local NovaUI = loadstring(game:HttpGet(LITE_URL))()
]]

-- ══ SERVICES ══════════════════════════════════════════════════════
local PLR  = game:GetService("Players")
local UIS  = game:GetService("UserInputService")
local LP   = PLR.LocalPlayer
local PG   = LP:WaitForChild("PlayerGui")

-- ══ MATH / TASK ════════════════════════════════════════════════════
local clamp = math.clamp
local floor = math.floor
local spawn = task.spawn

-- ══ FACTORY ════════════════════════════════════════════════════════
local function New(cls, props, children)
    local i = Instance.new(cls)
    if props    then for k,v in next,props    do i[k]=v end end
    if children then for _,c in next,children do c.Parent=i end end
    return i
end

-- ══ THEMES (3 built-in) ════════════════════════════════════════════
local C3 = Color3.fromRGB
local THEMES = {
    Dark = {
        Background  = C3(15,15,20),
        TopBar      = C3(20,20,28),
        Accent      = C3(99,102,241),
        Text        = C3(230,230,240),
        SubText     = C3(140,140,160),
        Card        = C3(24,24,33),
        Stroke      = C3(40,40,55),
        Toggle      = C3(40,40,55),
        ToggleOn    = C3(99,102,241),
        InputBg     = C3(18,18,26),
        Error       = C3(239,68,68),
        Warning     = C3(245,158,11),
        Success     = C3(34,197,94),
    },
    Light = {
        Background  = C3(240,240,248),
        TopBar      = C3(255,255,255),
        Accent      = C3(99,102,241),
        Text        = C3(20,20,30),
        SubText     = C3(100,100,120),
        Card        = C3(255,255,255),
        Stroke      = C3(210,210,225),
        Toggle      = C3(210,210,225),
        ToggleOn    = C3(99,102,241),
        InputBg     = C3(245,245,252),
        Error       = C3(220,38,38),
        Warning     = C3(217,119,6),
        Success     = C3(22,163,74),
    },
    Midnight = {
        Background  = C3(8,8,14),
        TopBar      = C3(12,12,20),
        Accent      = C3(139,92,246),
        Text        = C3(225,225,235),
        SubText     = C3(120,120,145),
        Card        = C3(14,14,22),
        Stroke      = C3(30,30,45),
        Toggle      = C3(30,30,45),
        ToggleOn    = C3(139,92,246),
        InputBg     = C3(10,10,18),
        Error       = C3(239,68,68),
        Warning     = C3(245,158,11),
        Success     = C3(34,197,94),
    },
}
-- Alias all 22 NovaUI theme names to one of the 3 above
local _ALIAS = {
    Amethyst="Dark",Aurora="Dark",Blaze="Dark",Blueberry="Dark",
    Carbon="Dark",Cherry="Dark",Cobalt="Dark",Crimson="Dark",
    Emerald="Dark",Forest="Dark",Graphite="Dark",Jade="Dark",
    Lemon="Light",Lumen="Dark",["Mocha Dark"]="Dark",
    ["Mocha Light"]="Light",["Nord Dark"]="Dark",["Nord Light"]="Light",
    Ocean="Dark",Rosewater="Light",Sakura="Light",Slate="Dark",
}
for k,v in next,_ALIAS do if not THEMES[k] then THEMES[k]=THEMES[v] end end

-- ══ ICONS (optional, set by reporter fallback) ══════════════════════
-- NovaUI_Lite will use NovaUI_Lite.Icons if assigned externally.
-- e.g.  NovaUI_Lite.Icons = Icons  before calling CreateWindow.

-- ══ NOTIFY QUEUE ══════════════════════════════════════════════════
local _notifGui, _notifStack, _notifY = nil, {}, 8

-- ══ LITE TABLE ════════════════════════════════════════════════════
local NL = {}
NL.Icons   = nil   -- caller may assign Icons module here
NL.Version = "6.0-Lite"
NL.VersionName = "Lumen-Lite"
NL.Themes  = THEMES

-- ══ NOTIFY ════════════════════════════════════════════════════════
function NL:Notify(cfg)
    cfg = cfg or {}
    local theme = THEMES[cfg.Theme or "Dark"] or THEMES.Dark
    local dur   = cfg.Duration or 4
    local title = tostring(cfg.Title or "Notification")
    local body  = tostring(cfg.Content or cfg.Text or "")

    if not _notifGui or not _notifGui.Parent then
        _notifGui = New("ScreenGui",{
            Name="__NovaLiteNotify", ResetOnSpawn=false,
            DisplayOrder=9998, IgnoreGuiInset=true, Parent=PG
        })
        _notifY = 8
        _notifStack = {}
    end

    local H = 60 + (body ~= "" and 20 or 0)
    local card = New("Frame",{
        Size=UDim2.new(0,280,0,H),
        Position=UDim2.new(1,-288,0,_notifY),
        BackgroundColor3=theme.Card,
        BorderSizePixel=0, Parent=_notifGui
    },{New("UICorner",{CornerRadius=UDim.new(0,8)}),
       New("UIStroke",{Color=theme.Stroke,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}),
       New("Frame",{Size=UDim2.new(0,3,1,0),BackgroundColor3=theme.Accent,BorderSizePixel=0},{
           New("UICorner",{CornerRadius=UDim.new(0,4)})}),
       New("TextLabel",{
           Size=UDim2.new(1,-16,0,22), Position=UDim2.new(0,12,0,8),
           BackgroundTransparency=1, Text=title,
           TextColor3=theme.Text, Font=Enum.Font.GothamBold,
           TextSize=13, TextXAlignment=Enum.TextXAlignment.Left
       }),
       New("TextLabel",{
           Size=UDim2.new(1,-16,0,20), Position=UDim2.new(0,12,0,30),
           BackgroundTransparency=1, Text=body,
           TextColor3=theme.SubText, Font=Enum.Font.Gotham,
           TextSize=12, TextXAlignment=Enum.TextXAlignment.Left,
           TextWrapped=true, Visible=body~=""
       }),
    })

    _notifY = _notifY + H + 6
    table.insert(_notifStack, card)

    spawn(function()
        task.wait(dur)
        pcall(function()
            card:Destroy()
            -- reflow remaining
            local ny = 8
            for i,c in ipairs(_notifStack) do
                if c == card then table.remove(_notifStack,i) break end
            end
            for _,c in ipairs(_notifStack) do
                if c.Parent then
                    c.Position = UDim2.new(1,-288,0,ny)
                    ny = ny + c.AbsoluteSize.Y + 6
                end
            end
            _notifY = ny
        end)
    end)
end

-- ══ CONFIRM DIALOG ════════════════════════════════════════════════
function NL:Dialog(cfg)
    cfg = cfg or {}
    local theme = THEMES[cfg.Theme or "Dark"] or THEMES.Dark
    local gui = New("ScreenGui",{
        Name="__NovaLiteDialog",ResetOnSpawn=false,
        DisplayOrder=9999,IgnoreGuiInset=true,Parent=PG
    })
    New("Frame",{
        Size=UDim2.new(1,0,1,0),BackgroundColor3=C3(0,0,0),
        BackgroundTransparency=0.5,BorderSizePixel=0,Parent=gui
    })
    local box = New("Frame",{
        Size=UDim2.new(0,340,0,140),
        Position=UDim2.new(0.5,-170,0.5,-70),
        BackgroundColor3=theme.Card,BorderSizePixel=0,Parent=gui
    },{New("UICorner",{CornerRadius=UDim.new(0,10)}),
       New("UIStroke",{Color=theme.Stroke,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}),
    })
    New("TextLabel",{
        Size=UDim2.new(1,-24,0,28),Position=UDim2.new(0,12,0,10),
        BackgroundTransparency=1,Text=tostring(cfg.Title or "Confirm"),
        TextColor3=theme.Text,Font=Enum.Font.GothamBold,TextSize=15,
        TextXAlignment=Enum.TextXAlignment.Left,Parent=box
    })
    New("TextLabel",{
        Size=UDim2.new(1,-24,0,40),Position=UDim2.new(0,12,0,40),
        BackgroundTransparency=1,Text=tostring(cfg.Content or ""),
        TextColor3=theme.SubText,Font=Enum.Font.Gotham,TextSize=13,
        TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,Parent=box
    })
    local function btn(label,x,cb,accent)
        local b = New("TextButton",{
            Size=UDim2.new(0,130,0,32),Position=UDim2.new(0,x,0,96),
            BackgroundColor3=accent and theme.Accent or theme.Toggle,
            Text=label,TextColor3=theme.Text,Font=Enum.Font.GothamBold,
            TextSize=13,BorderSizePixel=0,Parent=box
        },{New("UICorner",{CornerRadius=UDim.new(0,6)})})
        b.MouseButton1Click:Connect(function() gui:Destroy(); pcall(cb) end)
    end
    btn(cfg.ConfirmText or "Confirm", 12, cfg.Callback or function() end, true)
    btn(cfg.DenyText    or "Cancel", 156, cfg.DenyCallback or function() end, false)
end

-- ══ CREATE WINDOW ══════════════════════════════════════════════════
function NL:CreateWindow(cfg)
    cfg = cfg or {}
    local themeName = cfg.Theme or "Dark"
    local theme = THEMES[themeName] or THEMES.Dark
    local title = cfg.Name or "NovaUI Lite"

    -- Root
    local gui = New("ScreenGui",{
        Name="NovaUILite",ResetOnSpawn=false,
        DisplayOrder=100,IgnoreGuiInset=true,Parent=PG
    })

    -- Main window
    local win = New("Frame",{
        Name="Main",
        Size=UDim2.new(0,520,0,360),
        Position=UDim2.new(0.5,-260,0.5,-180),
        BackgroundColor3=theme.Background,
        BorderSizePixel=0,Parent=gui
    },{New("UICorner",{CornerRadius=UDim.new(0,10)}),
       New("UIStroke",{Color=theme.Stroke,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}),
    })

    -- Top bar
    local topbar = New("Frame",{
        Name="TopBar",Size=UDim2.new(1,0,0,38),
        BackgroundColor3=theme.TopBar,BorderSizePixel=0,Parent=win
    },{New("UICorner",{CornerRadius=UDim.new(0,10)}),
       New("Frame",{Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,1,-12),
           BackgroundColor3=theme.TopBar,BorderSizePixel=0}),
    })

    -- Accent strip
    New("Frame",{
        Size=UDim2.new(1,0,0,3),Position=UDim2.new(0,0,0,38),
        BackgroundColor3=theme.Accent,BorderSizePixel=0,Parent=win
    })

    -- Title
    New("TextLabel",{
        Size=UDim2.new(1,-80,1,0),Position=UDim2.new(0,14,0,0),
        BackgroundTransparency=1,Text=title,
        TextColor3=theme.Text,Font=Enum.Font.GothamBold,
        TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,Parent=topbar
    })

    -- Close button
    local closeBtn = New("TextButton",{
        Size=UDim2.new(0,26,0,26),Position=UDim2.new(1,-32,0.5,-13),
        BackgroundColor3=C3(200,50,50),Text="✕",
        TextColor3=C3(255,255,255),Font=Enum.Font.GothamBold,
        TextSize=12,BorderSizePixel=0,Parent=topbar
    },{New("UICorner",{CornerRadius=UDim.new(0,6)})})
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- Dragging
    do
        local drag, ox, oy = false
        topbar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                drag=true; local ap=win.AbsolutePosition
                ox=inp.Position.X-ap.X; oy=inp.Position.Y-ap.Y
            end
        end)
        UIS.InputChanged:Connect(function(inp)
            if drag and (inp.UserInputType==Enum.UserInputType.MouseMovement
            or inp.UserInputType==Enum.UserInputType.Touch) then
                local sp=inp.Position
                win.Position=UDim2.new(0,sp.X-ox,0,sp.Y-oy)
            end
        end)
        UIS.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1
            or inp.UserInputType==Enum.UserInputType.Touch then drag=false end
        end)
    end

    -- Tab rail (left)
    local rail = New("Frame",{
        Name="Rail",Size=UDim2.new(0,110,1,-41),Position=UDim2.new(0,0,0,41),
        BackgroundColor3=theme.TopBar,BorderSizePixel=0,Parent=win
    },{New("UICorner",{CornerRadius=UDim.new(0,10)}),
       New("Frame",{Size=UDim2.new(0,12,1,0),Position=UDim2.new(1,-12,0,0),
           BackgroundColor3=theme.TopBar,BorderSizePixel=0}),
       New("UIListLayout",{
           Padding=UDim.new(0,2),
           HorizontalAlignment=Enum.HorizontalAlignment.Center,
           SortOrder=Enum.SortOrder.LayoutOrder
       }),
       New("UIPadding",{
           PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,8),
           PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6)
       }),
    })

    -- Content area
    local content = New("Frame",{
        Name="Content",Size=UDim2.new(1,-118,1,-48),
        Position=UDim2.new(0,114,0,44),
        BackgroundTransparency=1,Parent=win
    })

    -- Window object
    local W = {_theme=theme,_gui=gui,_tabs={},_active=nil,_cfg=cfg}

    function W:Destroy() gui:Destroy() end
    function W:Toggle() gui.Enabled = not gui.Enabled end

    -- Theme change
    function W:SetTheme(name)
        local t = THEMES[name] or THEMES.Dark
        self._theme = t
        win.BackgroundColor3 = t.Background
        topbar.BackgroundColor3 = t.TopBar
        rail.BackgroundColor3 = t.TopBar
        -- tabs recolor themselves; components keep their last bake
    end

    -- ══ CREATE TAB ════════════════════════════════════════════════
    function W:CreateTab(tabcfg)
        tabcfg = tabcfg or {}
        local name  = tabcfg.Name or ("Tab "..#self._tabs+1)
        local t     = self._theme

        -- Tab button in rail
        local btn = New("TextButton",{
            Size=UDim2.new(1,0,0,30),
            BackgroundColor3=t.Toggle,
            Text=name,TextColor3=t.SubText,
            Font=Enum.Font.Gotham,TextSize=12,
            BorderSizePixel=0,LayoutOrder=#self._tabs+1,Parent=rail
        },{New("UICorner",{CornerRadius=UDim.new(0,6)})})

        -- Tab scroll frame
        local pane = New("ScrollingFrame",{
            Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1,
            ScrollBarThickness=3,
            ScrollBarImageColor3=t.Accent,
            BorderSizePixel=0,
            Visible=false,
            ScrollingDirection=Enum.ScrollingDirection.Y,
            Parent=content
        },{New("UIListLayout",{
               Padding=UDim.new(0,6),
               SortOrder=Enum.SortOrder.LayoutOrder
           }),
           New("UIPadding",{
               PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,6),
               PaddingLeft=UDim.new(0,4),PaddingRight=UDim.new(0,8)
           }),
        })

        -- Auto-resize canvas
        local layout = pane:FindFirstChildOfClass("UIListLayout")
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            pane.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y+14)
        end)

        local Tab = {_pane=pane,_btn=btn,_theme=t,_lo=0}

        -- Activate tab
        local function activate()
            for _,tb in ipairs(W._tabs) do
                tb._pane.Visible = false
                tb._btn.BackgroundColor3 = t.Toggle
                tb._btn.TextColor3 = t.SubText
            end
            pane.Visible = true
            btn.BackgroundColor3 = t.Accent
            btn.TextColor3 = C3(255,255,255)
            W._active = Tab
        end
        btn.MouseButton1Click:Connect(activate)
        table.insert(W._tabs, Tab)
        if #W._tabs == 1 then activate() end

        -- ── Helper: make a card ────────────────────────────────────
        local function Card(h)
            Tab._lo = Tab._lo + 1
            local c = New("Frame",{
                Size=UDim2.new(1,0,0,h or 40),
                BackgroundColor3=t.Card,BorderSizePixel=0,
                LayoutOrder=Tab._lo,Parent=pane
            },{New("UICorner",{CornerRadius=UDim.new(0,7)}),
               New("UIStroke",{Color=t.Stroke,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}),
            })
            return c
        end
        local function Label(parent,txt,x,y,w,h,big,col)
            return New("TextLabel",{
                Size=UDim2.new(w or 1,-8,0,h or 18),
                Position=UDim2.new(0,x or 8,0,y or 4),
                BackgroundTransparency=1,Text=txt,
                TextColor3=col or (big and t.Text or t.SubText),
                Font=big and Enum.Font.GothamBold or Enum.Font.Gotham,
                TextSize=big and 13 or 11,
                TextXAlignment=Enum.TextXAlignment.Left,
                Parent=parent
            })
        end

        -- ── COMPONENTS ─────────────────────────────────────────────

        function Tab:CreateButton(cfg)
            cfg=cfg or {}
            local c = Card(40)
            local b = New("TextButton",{
                Size=UDim2.new(1,-16,0,26),Position=UDim2.new(0,8,0,7),
                BackgroundColor3=t.Accent,Text=cfg.Name or "Button",
                TextColor3=C3(255,255,255),Font=Enum.Font.GothamBold,
                TextSize=13,BorderSizePixel=0,Parent=c
            },{New("UICorner",{CornerRadius=UDim.new(0,6)})})
            b.MouseButton1Click:Connect(function() pcall(cfg.Callback or function()end) end)
            return {SetText=function(_,s) b.Text=s end}
        end

        function Tab:CreateToggle(cfg)
            cfg=cfg or {}
            local val = cfg.Default or false
            local c = Card(40)
            Label(c, cfg.Name or "Toggle", 8, 4, 0.7, 18, true)
            local track = New("Frame",{
                Size=UDim2.new(0,36,0,20),Position=UDim2.new(1,-46,0.5,-10),
                BackgroundColor3=val and t.ToggleOn or t.Toggle,
                BorderSizePixel=0,Parent=c
            },{New("UICorner",{CornerRadius=UDim.new(0,10)})})
            local dot = New("Frame",{
                Size=UDim2.new(0,14,0,14),
                Position=UDim2.new(val and 1 or 0, val and -16 or 2,0.5,-7),
                BackgroundColor3=C3(255,255,255),BorderSizePixel=0,Parent=track
            },{New("UICorner",{CornerRadius=UDim.new(0,7)})})
            local cb=cfg.Callback or function()end
            track.InputBegan:Connect(function(inp)
                if inp.UserInputType~=Enum.UserInputType.MouseButton1
                and inp.UserInputType~=Enum.UserInputType.Touch then return end
                val=not val
                track.BackgroundColor3=val and t.ToggleOn or t.Toggle
                dot.Position=UDim2.new(val and 1 or 0, val and -16 or 2,0.5,-7)
                pcall(cb,val)
            end)
            return {
                SetValue=function(_,v) val=v
                    track.BackgroundColor3=v and t.ToggleOn or t.Toggle
                    dot.Position=UDim2.new(v and 1 or 0, v and -16 or 2,0.5,-7)
                end,
                GetValue=function() return val end,
            }
        end

        function Tab:CreateSlider(cfg)
            cfg=cfg or {}
            local mn,mx = cfg.Min or 0, cfg.Max or 100
            local val   = clamp(cfg.Default or mn, mn, mx)
            local c = Card(52)
            Label(c, cfg.Name or "Slider", 8, 4, 0.7, 16, true)
            local valLbl = New("TextLabel",{
                Size=UDim2.new(0,40,0,16),Position=UDim2.new(1,-48,0,4),
                BackgroundTransparency=1,Text=tostring(val),
                TextColor3=t.Accent,Font=Enum.Font.GothamBold,TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Right,Parent=c
            })
            local track = New("Frame",{
                Size=UDim2.new(1,-16,0,6),Position=UDim2.new(0,8,0,30),
                BackgroundColor3=t.Toggle,BorderSizePixel=0,Parent=c
            },{New("UICorner",{CornerRadius=UDim.new(0,3)})})
            local pct = (val-mn)/(mx-mn)
            local fill = New("Frame",{
                Size=UDim2.new(pct,0,1,0),BackgroundColor3=t.Accent,
                BorderSizePixel=0,Parent=track
            },{New("UICorner",{CornerRadius=UDim.new(0,3)})})
            local thumb = New("Frame",{
                Size=UDim2.new(0,14,0,14),
                Position=UDim2.new(pct,-7,0.5,-7),
                BackgroundColor3=C3(255,255,255),BorderSizePixel=0,Parent=track
            },{New("UICorner",{CornerRadius=UDim.new(0,7)})})

            local cb=cfg.Callback or function()end
            local dragging=false
            local function update(x)
                local a=track.AbsolutePosition.X; local w=track.AbsoluteSize.X
                local p=clamp((x-a)/w,0,1)
                val=floor(mn+(mx-mn)*p+0.5)
                local dp=(val-mn)/(mx-mn)
                fill.Size=UDim2.new(dp,0,1,0)
                thumb.Position=UDim2.new(dp,-7,0.5,-7)
                valLbl.Text=tostring(val); pcall(cb,val)
            end
            track.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1
                or i.UserInputType==Enum.UserInputType.Touch then
                    dragging=true; update(i.Position.X)
                end
            end)
            game:GetService("UserInputService").InputChanged:Connect(function(i)
                if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement
                or i.UserInputType==Enum.UserInputType.Touch) then update(i.Position.X) end
            end)
            game:GetService("UserInputService").InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1
                or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
            end)
            return {
                SetValue=function(_,v) val=clamp(v,mn,mx)
                    local dp=(val-mn)/(mx-mn)
                    fill.Size=UDim2.new(dp,0,1,0)
                    thumb.Position=UDim2.new(dp,-7,0.5,-7)
                    valLbl.Text=tostring(val)
                end,
                GetValue=function() return val end,
            }
        end

        function Tab:CreateDropdown(cfg)
            cfg=cfg or {}
            local opts = cfg.Options or {}
            local val  = cfg.Default or (opts[1] or "")
            local open = false
            local c = Card(40)
            Label(c, cfg.Name or "Dropdown", 8, 4, 0.7, 16, true)
            local disp = New("TextButton",{
                Size=UDim2.new(1,-16,0,22),Position=UDim2.new(0,8,0,22),
                BackgroundColor3=t.InputBg,Text=tostring(val).." ▾",
                TextColor3=t.Text,Font=Enum.Font.Gotham,TextSize=12,
                BorderSizePixel=0,Parent=c
            },{New("UICorner",{CornerRadius=UDim.new(0,5)}),
               New("UIStroke",{Color=t.Stroke,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}),
            })
            local menu = New("Frame",{
                Size=UDim2.new(1,-16,0,0),Position=UDim2.new(0,8,1,2),
                BackgroundColor3=t.Card,BorderSizePixel=0,ZIndex=5,
                ClipsDescendants=true,Visible=false,Parent=c
            },{New("UICorner",{CornerRadius=UDim.new(0,5)}),
               New("UIStroke",{Color=t.Stroke,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}),
               New("UIListLayout",{Padding=UDim.new(0,1),SortOrder=Enum.SortOrder.LayoutOrder}),
            })
            local cb=cfg.Callback or function()end
            local function addOpt(o)
                local ob=New("TextButton",{
                    Size=UDim2.new(1,0,0,24),BackgroundColor3=t.Card,
                    Text="  "..tostring(o),TextColor3=t.SubText,
                    Font=Enum.Font.Gotham,TextSize=12,ZIndex=6,
                    BorderSizePixel=0,Parent=menu
                })
                ob.MouseButton1Click:Connect(function()
                    val=o; disp.Text=tostring(o).." ▾"
                    menu.Visible=false; open=false
                    c.Size=UDim2.new(1,0,0,40)
                    pcall(cb,val)
                end)
            end
            for _,o in ipairs(opts) do addOpt(o) end
            disp.MouseButton1Click:Connect(function()
                open=not open; menu.Visible=open
                local mh=#opts*24+2
                menu.Size=UDim2.new(1,-16,0, open and mh or 0)
                c.Size=UDim2.new(1,0,0, open and 40+mh+4 or 40)
            end)
            return {
                SetValue=function(_,v) val=v; disp.Text=tostring(v).." ▾" end,
                GetValue=function() return val end,
                Refresh=function(_,list)
                    opts=list; for _,ch in ipairs(menu:GetChildren()) do
                        if ch:IsA("TextButton") then ch:Destroy() end
                    end
                    for _,o in ipairs(list) do addOpt(o) end
                end,
            }
        end

        function Tab:CreateInput(cfg)
            cfg=cfg or {}
            local c = Card(52)
            Label(c, cfg.Name or "Input", 8, 4, 0.7, 16, true)
            local box = New("TextBox",{
                Size=UDim2.new(1,-16,0,24),Position=UDim2.new(0,8,0,24),
                BackgroundColor3=t.InputBg,Text=cfg.Default or "",
                PlaceholderText=cfg.PlaceholderText or "Enter value...",
                TextColor3=t.Text,PlaceholderColor3=t.SubText,
                Font=Enum.Font.Gotham,TextSize=13,
                ClearTextOnFocus=cfg.ClearTextOnFocus~=false,
                BorderSizePixel=0,Parent=c
            },{New("UICorner",{CornerRadius=UDim.new(0,5)}),
               New("UIStroke",{Color=t.Stroke,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}),
               New("UIPadding",{PaddingLeft=UDim.new(0,8)}),
            })
            local cb=cfg.Callback or function()end
            box.FocusLost:Connect(function(enter) if enter then pcall(cb,box.Text) end end)
            return {
                SetValue=function(_,v) box.Text=tostring(v) end,
                GetValue=function() return box.Text end,
            }
        end

        function Tab:CreateColorPicker(cfg)
            cfg=cfg or {}
            local c = Card(40)
            Label(c, cfg.Name or "Color Picker", 8, 4, 0.7, 16, true)
            local col=cfg.Default or C3(99,102,241)
            local preview=New("Frame",{
                Size=UDim2.new(0,24,0,24),Position=UDim2.new(1,-32,0.5,-12),
                BackgroundColor3=col,BorderSizePixel=0,Parent=c
            },{New("UICorner",{CornerRadius=UDim.new(0,5)}),
               New("UIStroke",{Color=t.Stroke,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}),
            })
            -- Lite: no full picker UI, just preview + callback stub
            return {
                SetValue=function(_,v) col=v; preview.BackgroundColor3=v end,
                GetValue=function() return col end,
            }
        end

        function Tab:CreateKeybind(cfg)
            cfg=cfg or {}
            local key=cfg.Default or Enum.KeyCode.Unknown
            local listening=false
            local c=Card(40)
            Label(c,cfg.Name or "Keybind",8,4,0.7,16,true)
            local kb=New("TextButton",{
                Size=UDim2.new(0,80,0,24),Position=UDim2.new(1,-88,0.5,-12),
                BackgroundColor3=t.InputBg,Text=key.Name or "None",
                TextColor3=t.Accent,Font=Enum.Font.GothamBold,TextSize=12,
                BorderSizePixel=0,Parent=c
            },{New("UICorner",{CornerRadius=UDim.new(0,5)}),
               New("UIStroke",{Color=t.Stroke,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}),
            })
            local cb=cfg.Callback or function()end
            kb.MouseButton1Click:Connect(function()
                listening=true; kb.Text="..."
            end)
            game:GetService("UserInputService").InputBegan:Connect(function(inp,gp)
                if not listening or gp then return end
                if inp.UserInputType==Enum.UserInputType.Keyboard then
                    key=inp.KeyCode; kb.Text=key.Name
                    listening=false; pcall(cb,key)
                end
            end)
            return {SetValue=function(_,k) key=k; kb.Text=k.Name end, GetValue=function() return key end}
        end

        function Tab:CreateLabel(cfg)
            cfg=cfg or{}
            local c=Card(36)
            Label(c,cfg.Name or cfg.Text or "Label",8,4,0.9,22,true,t.Text)
            return {SetText=function(_,s)
                local lbl=c:FindFirstChildOfClass("TextLabel")
                if lbl then lbl.Text=s end
            end}
        end

        function Tab:CreateParagraph(cfg)
            cfg=cfg or{}
            local lines=math.max(1,math.ceil((#(cfg.Content or ""))/60))
            local c=Card(36+lines*16)
            Label(c,cfg.Title or cfg.Name or "Paragraph",8,4,0.9,18,true)
            New("TextLabel",{
                Size=UDim2.new(1,-16,0,lines*16),Position=UDim2.new(0,8,0,22),
                BackgroundTransparency=1,Text=cfg.Content or "",
                TextColor3=t.SubText,Font=Enum.Font.Gotham,TextSize=12,
                TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,Parent=c
            })
            return {}
        end

        function Tab:CreateSection(cfg)
            cfg=cfg or{}; Tab._lo=Tab._lo+1
            New("TextLabel",{
                Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,
                Text=("── %s ──"):format(cfg.Name or "Section"),
                TextColor3=t.Accent,Font=Enum.Font.GothamBold,TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Left,
                LayoutOrder=Tab._lo,Parent=pane
            })
            return {}
        end

        -- Stubs that share the same structure as full NovaUI so callers don't error
        function Tab:CreateSpinner(cfg)    return Tab:CreateLabel(cfg) end
        function Tab:CreateSkeleton(cfg)   return {} end
        function Tab:CreateProgressBar(cfg)
            cfg=cfg or{}
            local val=cfg.Default or 0
            local c=Card(44)
            Label(c,cfg.Name or "Progress",8,4,0.7,16,true)
            local track=New("Frame",{Size=UDim2.new(1,-16,0,6),Position=UDim2.new(0,8,0,30),
                BackgroundColor3=t.Toggle,BorderSizePixel=0,Parent=c
            },{New("UICorner",{CornerRadius=UDim.new(0,3)})})
            local fill=New("Frame",{Size=UDim2.new(clamp(val/100,0,1),0,1,0),
                BackgroundColor3=t.Accent,BorderSizePixel=0,Parent=track
            },{New("UICorner",{CornerRadius=UDim.new(0,3)})})
            return {
                SetValue=function(_,v)
                    val=clamp(v,0,100)
                    fill.Size=UDim2.new(val/100,0,1,0)
                end,
                GetValue=function() return val end,
            }
        end
        function Tab:CreateTable(cfg)     return Tab:CreateParagraph(cfg) end
        function Tab:CreateTextBox(cfg)   return Tab:CreateInput(cfg) end
        function Tab:CreateImage(cfg)
            cfg=cfg or{}; local c=Card(cfg.Height or 80)
            if cfg.Image then
                New("ImageLabel",{Size=UDim2.new(1,-16,1,-8),Position=UDim2.new(0,8,0,4),
                    BackgroundTransparency=1,Image=cfg.Image,
                    ScaleType=Enum.ScaleType.Fit,Parent=c})
            end; return {}
        end

        return Tab
    end -- CreateTab

    -- ══ KEY SYSTEM stub ══════════════════════════════════════════
    function W:KeySystem(cfg)
        cfg=cfg or{}
        spawn(function()
            -- minimal: show a plain input prompt
            local gui2=New("ScreenGui",{
                Name="__NovaLiteKey",ResetOnSpawn=false,
                DisplayOrder=9997,IgnoreGuiInset=true,Parent=PG
            })
            New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=C3(0,0,0),
                BackgroundTransparency=0.6,BorderSizePixel=0,Parent=gui2})
            local box2=New("Frame",{Size=UDim2.new(0,320,0,120),
                Position=UDim2.new(0.5,-160,0.5,-60),
                BackgroundColor3=self._theme.Card,BorderSizePixel=0,Parent=gui2
            },{New("UICorner",{CornerRadius=UDim.new(0,10)}),
               New("UIStroke",{Color=self._theme.Stroke,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}),
            })
            New("TextLabel",{Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,8),
                BackgroundTransparency=1,Text=cfg.Title or "Key Required",
                TextColor3=self._theme.Text,Font=Enum.Font.GothamBold,TextSize=14,Parent=box2})
            local inp=New("TextBox",{Size=UDim2.new(1,-24,0,28),Position=UDim2.new(0,12,0,44),
                BackgroundColor3=self._theme.InputBg,Text="",
                PlaceholderText="Enter key...",
                TextColor3=self._theme.Text,PlaceholderColor3=self._theme.SubText,
                Font=Enum.Font.Gotham,TextSize=13,BorderSizePixel=0,Parent=box2
            },{New("UICorner",{CornerRadius=UDim.new(0,6)}),
               New("UIStroke",{Color=self._theme.Stroke,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}),
               New("UIPadding",{PaddingLeft=UDim.new(0,8)}),
            })
            local sb=New("TextButton",{Size=UDim2.new(1,-24,0,28),Position=UDim2.new(0,12,0,80),
                BackgroundColor3=self._theme.Accent,Text="Submit",
                TextColor3=C3(255,255,255),Font=Enum.Font.GothamBold,TextSize=13,
                BorderSizePixel=0,Parent=box2
            },{New("UICorner",{CornerRadius=UDim.new(0,6)})})
            sb.MouseButton1Click:Connect(function()
                local k=inp.Text
                local valid=false
                for _,key in ipairs(cfg.Key or {}) do
                    if k==key then valid=true break end
                end
                if valid then
                    gui2:Destroy()
                    pcall(cfg.CorrectCallback or function()end)
                else
                    inp.Text=""; inp.PlaceholderText="Invalid key, try again"
                    pcall(cfg.WrongCallback or function()end)
                end
            end)
        end)
    end

    -- ══ Config stubs (no-op, keeps API compat) ════════════════════
    function W:SaveConfig(_name)  end
    function W:LoadConfig(_name)  return {} end
    function W:GetConfig()        return {} end

    return W
end -- CreateWindow

-- ══ MODULE RETURN ══════════════════════════════════════════════════
return NL
