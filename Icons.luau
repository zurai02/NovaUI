local Icons = {}

-- ── Asset ID fallback table ───────────────────────────────────
-- Only used if Get() doesn't have a drawn version.
-- Safe system icons from Roblox's own library.
Icons.Id = {
    star         = "rbxassetid://45428444",
    heart        = "rbxassetid://1076723389",
    home         = "rbxassetid://3926305904",
    bell         = "rbxassetid://3926305904",
    lock         = "rbxassetid://3926307352",
    unlock       = "rbxassetid://3926307396",
    camera       = "rbxassetid://3926305532",
    chat         = "rbxassetid://3926305584",
    flag         = "rbxassetid://3926305688",
    image        = "rbxassetid://3926307010",
    video        = "rbxassetid://3926307432",
    music        = "rbxassetid://3926307196",
    folder       = "rbxassetid://3926305716",
    file         = "rbxassetid://3926305664",
    trash        = "rbxassetid://3926307380",
    download     = "rbxassetid://3926305628",
    upload       = "rbxassetid://3926307404",
    link         = "rbxassetid://3926307108",
    globe        = "rbxassetid://3926305748",
    map          = "rbxassetid://3926307132",
    user         = "rbxassetid://3926307420",
    users        = "rbxassetid://3926307416",
    tag          = "rbxassetid://3926307348",
    gift         = "rbxassetid://3926305732",
    shield       = "rbxassetid://3926307308",
    trophy       = "rbxassetid://3926307388",
    crown        = "rbxassetid://3926305600",
    diamond      = "rbxassetid://3926305624",
    bolt         = "rbxassetid://3926305476",
    fire         = "rbxassetid://3926305692",
    leaf         = "rbxassetid://3926307096",
    moon         = "rbxassetid://3926307160",
    sun          = "rbxassetid://3926307336",
    cloud         = "rbxassetid://3926305588",
    snow         = "rbxassetid://3926307320",
    eye          = "rbxassetid://3926305650",
    eyeoff       = "rbxassetid://3926305654",
    mic          = "rbxassetid://3926307140",
    volume       = "rbxassetid://3926307448",
    mute         = "rbxassetid://3926307196",
    wifi         = "rbxassetid://3926307452",
    bluetooth    = "rbxassetid://3926305488",
    battery      = "rbxassetid://3926305464",
    cpu          = "rbxassetid://3926305604",
    code         = "rbxassetid://3926305592",
    terminal     = "rbxassetid://3926307356",
    package      = "rbxassetid://3926307228",
    box          = "rbxassetid://3926305500",
    grid_        = "rbxassetid://3926305760",
    list_        = "rbxassetid://3926307116",
    layout       = "rbxassetid://3926307092",
    sidebar      = "rbxassetid://3926307312",
    menu         = "rbxassetid://3926307148",
    more         = "rbxassetid://3926307168",
    filter       = "rbxassetid://3926305680",
    sort         = "rbxassetid://3926307328",
    refresh      = "rbxassetid://3926307280",
    loader       = "rbxassetid://3926307120",
    time         = "rbxassetid://3926307368",
    calendar     = "rbxassetid://3926305516",
    clock        = "rbxassetid://3926305584",
    alarm        = "rbxassetid://3926305444",
    timer        = "rbxassetid://3926307372",
    clipboard    = "rbxassetid://3926305576",
    edit_        = "rbxassetid://3926305640",
    pen          = "rbxassetid://3926307240",
    scissors     = "rbxassetid://3926307296",
    copy_        = "rbxassetid://3926305596",
    paste        = "rbxassetid://3926307232",
    print        = "rbxassetid://3926307268",
    mail         = "rbxassetid://3926307128",
    send         = "rbxassetid://3926307300",
    inbox        = "rbxassetid://3926307002",
    archive      = "rbxassetid://3926305452",
    bookmark     = "rbxassetid://3926305492",
    pin          = "rbxassetid://3926307252",
    share        = "rbxassetid://3926307304",
    external     = "rbxassetid://3926305648",
    maximize     = "rbxassetid://3926307136",
    minimize     = "rbxassetid://3926307152",
    expand       = "rbxassetid://3926305656",
    compress     = "rbxassetid://3926305596",
    zoomin       = "rbxassetid://3926307460",
    zoomout      = "rbxassetid://3926307464",
    crop_        = "rbxassetid://3926305608",
    rotate       = "rbxassetid://3926307288",
    flip         = "rbxassetid://3926305700",
    move         = "rbxassetid://3926307172",
    drag         = "rbxassetid://3926305632",
    resize       = "rbxassetid://3926307284",
    percent      = "rbxassetid://3926307244",
    hash_        = "rbxassetid://3926305776",
    at           = "rbxassetid://3926305456",
    dollar       = "rbxassetid://3926305628",
    cart         = "rbxassetid://3926305524",
    bag          = "rbxassetid://3926305460",
    credit       = "rbxassetid://3926305608",
    chart        = "rbxassetid://3926305540",
    bar_chart    = "rbxassetid://3926305468",
    pie_chart    = "rbxassetid://3926305536",
    trending_up  = "rbxassetid://3926307376",
    trending_dn  = "rbxassetid://3926307380",
    activity     = "rbxassetid://3926305440",
    pulse        = "rbxassetid://3926307272",
    target       = "rbxassetid://3926307352",
    award        = "rbxassetid://3926305460",
    zap          = "rbxassetid://3926307456",
    power        = "rbxassetid://3926307260",
    key_         = "rbxassetid://3926307060",
    fingerprint  = "rbxassetid://3926305676",
    id_          = "rbxassetid://3926307006",
    info         = "rbxassetid://3926307022",
    help         = "rbxassetid://3926305788",
    alert_       = "rbxassetid://3926305448",
    error_       = "rbxassetid://3926305644",
    warning      = "rbxassetid://3926307444",
    success      = "rbxassetid://3926305748",
    question     = "rbxassetid://3926307276",
    minus        = "rbxassetid://3926307156",
    plus         = "rbxassetid://3926307256",
    close        = "rbxassetid://3926305584",
    check        = "rbxassetid://3926305548",
    x            = "rbxassetid://3926307456",
    search       = "rbxassetid://3926305904",
    settings     = "rbxassetid://3926307308",
    sliders      = "rbxassetid://3926307316",
    tool         = "rbxassetid://3926307376",
    wrench       = "rbxassetid://3926307452",
    hammer       = "rbxassetid://3926305768",
    arrow_up     = "rbxassetid://3926305452",
    arrow_down   = "rbxassetid://3926305456",
    arrow_left   = "rbxassetid://3926305460",
    arrow_right  = "rbxassetid://3926305464",
    chevron_up   = "rbxassetid://3926305556",
    chevron_down = "rbxassetid://3926305560",
    chevron_left = "rbxassetid://3926305564",
    chevron_right= "rbxassetid://3926305568",
}

-- ── Internal helpers ──────────────────────────────────────────

local function N(cls, props, children)
    local i = Instance.new(cls)
    for k,v in pairs(props or {}) do i[k]=v end
    for _,c in ipairs(children or {}) do c.Parent=i end
    return i
end

local function container(size)
    return N("Frame",{
        Size = UDim2.fromOffset(size,size),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
    })
end

local function rect(parent, x,y,w,h, col, r)
    local f = N("Frame",{
        Position = UDim2.fromOffset(x,y),
        Size = UDim2.fromOffset(w,h),
        BackgroundColor3 = col,
        BorderSizePixel = 0,
        Parent = parent,
    })
    if r and r > 0 then N("UICorner",{CornerRadius=UDim.new(0,r),Parent=f}) end
    return f
end

local function circle(parent, x,y,d, col)
    return rect(parent, x,y,d,d, col, d//2)
end

local function line(parent, x1,y1,x2,y2, thick, col)
    local dx,dy = x2-x1, y2-y1
    local len = math.sqrt(dx*dx+dy*dy)
    local ang = math.deg(math.atan2(dy,dx))
    local cx,cy = (x1+x2)/2, (y1+y2)/2
    local f = N("Frame",{
        Position = UDim2.fromOffset(cx - len/2, cy - thick/2),
        Size = UDim2.fromOffset(len, thick),
        BackgroundColor3 = col,
        BorderSizePixel = 0,
        Rotation = ang,
        AnchorPoint = Vector2.new(0,0.5),
        Parent = parent,
    })
    N("UICorner",{CornerRadius=UDim.new(0,thick//2),Parent=f})
    return f
end

-- ── Drawn icon constructors ───────────────────────────────────
-- Each returns a Frame of size (s×s) with colour (c).
-- s = size in pixels, c = Color3

local Draw = {}

function Draw.close(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.12))
    local p = math.round(s*0.18)
    line(f, p,p, s-p,s-p, t, c)
    line(f, s-p,p, p,s-p, t, c)
    return f
end

function Draw.check(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.13))
    local p = math.round(s*0.1)
    line(f, p, s*0.52, s*0.38, s-p, t, c)
    line(f, s*0.38, s-p, s-p, p, t, c)
    return f
end

function Draw.plus(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.13))
    local p = math.round(s*0.15)
    rect(f, p, (s-t)//2, s-p*2, t, c, t//2)
    rect(f, (s-t)//2, p, t, s-p*2, c, t//2)
    return f
end

function Draw.minus(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.13))
    local p = math.round(s*0.15)
    rect(f, p, (s-t)//2, s-p*2, t, c, t//2)
    return f
end

function Draw.search(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.11))
    local r = math.round(s*0.28)
    local cx,cy = math.round(s*0.38), math.round(s*0.38)
    -- ring
    local ring = N("Frame",{
        Position=UDim2.fromOffset(cx-r,cy-r),
        Size=UDim2.fromOffset(r*2,r*2),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0.5,0),Parent=ring})
    N("UIStroke",{Color=c,Thickness=t,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=ring})
    -- handle
    local hx = cx + math.round(r*0.68)
    local hy = cy + math.round(r*0.68)
    line(f, hx,hy, s-math.round(s*0.08), s-math.round(s*0.08), t, c)
    return f
end

function Draw.settings(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.11))
    local cr = math.round(s*0.15)
    -- center circle
    local cx,cy = s//2, s//2
    circle(f, cx-cr, cy-cr, cr*2, c)
    -- ring cutout trick: inner white circle
    -- (transparent bg means we just draw the stroke ring)
    local ring = N("Frame",{
        Position=UDim2.fromOffset(cx-cr,cy-cr),
        Size=UDim2.fromOffset(cr*2,cr*2),
        BackgroundTransparency=1,
        Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0.5,0),Parent=ring})
    -- 6 gear teeth as small rects rotated around center
    for i=0,5 do
        local ang = math.rad(i*60)
        local tx = cx + math.cos(ang)*math.round(s*0.34) - math.round(s*0.07)
        local ty = cy + math.sin(ang)*math.round(s*0.34) - math.round(s*0.18)
        local tooth = rect(f, tx, ty, math.round(s*0.14), math.round(s*0.28), c, math.round(s*0.04))
        tooth.Rotation = math.deg(ang)
        tooth.AnchorPoint = Vector2.new(0.5,0.5)
        tooth.Position = UDim2.fromOffset(
            cx + math.cos(ang)*math.round(s*0.34),
            cy + math.sin(ang)*math.round(s*0.34)
        )
    end
    return f
end

function Draw.arrow_right(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.13))
    local p = math.round(s*0.2)
    line(f, p, s//2, s-p, s//2, t, c)
    line(f, s-p, s//2, s-p-math.round(s*0.28), p, t, c)
    line(f, s-p, s//2, s-p-math.round(s*0.28), s-p, t, c)
    return f
end

function Draw.arrow_left(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.13))
    local p = math.round(s*0.2)
    line(f, s-p, s//2, p, s//2, t, c)
    line(f, p, s//2, p+math.round(s*0.28), p, t, c)
    line(f, p, s//2, p+math.round(s*0.28), s-p, t, c)
    return f
end

function Draw.arrow_up(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.13))
    local p = math.round(s*0.2)
    line(f, s//2, s-p, s//2, p, t, c)
    line(f, s//2, p, p, p+math.round(s*0.28), t, c)
    line(f, s//2, p, s-p, p+math.round(s*0.28), t, c)
    return f
end

function Draw.arrow_down(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.13))
    local p = math.round(s*0.2)
    line(f, s//2, p, s//2, s-p, t, c)
    line(f, s//2, s-p, p, s-p-math.round(s*0.28), t, c)
    line(f, s//2, s-p, s-p, s-p-math.round(s*0.28), t, c)
    return f
end

function Draw.chevron_right(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.13))
    local p = math.round(s*0.22)
    local mx = math.round(s*0.62)
    line(f, p, p, mx, s//2, t, c)
    line(f, mx, s//2, p, s-p, t, c)
    return f
end

function Draw.chevron_left(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.13))
    local p = math.round(s*0.22)
    local mx = math.round(s*0.38)
    line(f, s-p, p, mx, s//2, t, c)
    line(f, mx, s//2, s-p, s-p, t, c)
    return f
end

function Draw.chevron_up(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.13))
    local p = math.round(s*0.22)
    local my = math.round(s*0.38)
    line(f, p, s-p, s//2, my, t, c)
    line(f, s//2, my, s-p, s-p, t, c)
    return f
end

function Draw.chevron_down(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.13))
    local p = math.round(s*0.22)
    local my = math.round(s*0.62)
    line(f, p, p, s//2, my, t, c)
    line(f, s//2, my, s-p, p, t, c)
    return f
end

function Draw.menu(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.11))
    local p = math.round(s*0.15)
    rect(f, p, math.round(s*0.25), s-p*2, t, c, t//2)
    rect(f, p, s//2-t//2,          s-p*2, t, c, t//2)
    rect(f, p, math.round(s*0.75)-t, s-p*2, t, c, t//2)
    return f
end

function Draw.more(s,c)  -- horizontal three dots
    local f = container(s)
    local d = math.max(3, math.round(s*0.16))
    local y = s//2 - d//2
    local gap = math.round((s - d*3) / 4)
    circle(f, gap,           y, d, c)
    circle(f, gap*2+d,       y, d, c)
    circle(f, gap*3+d*2,     y, d, c)
    return f
end

function Draw.more_v(s,c)  -- vertical three dots
    local f = container(s)
    local d = math.max(3, math.round(s*0.16))
    local x = s//2 - d//2
    local gap = math.round((s - d*3) / 4)
    circle(f, x, gap,           d, c)
    circle(f, x, gap*2+d,       d, c)
    circle(f, x, gap*3+d*2,     d, c)
    return f
end

function Draw.info(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.12))
    local p = math.round(s*0.12)
    -- circle
    local ring = N("Frame",{
        Position=UDim2.fromOffset(p,p),
        Size=UDim2.fromOffset(s-p*2,s-p*2),
        BackgroundTransparency=1,
        Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0.5,0),Parent=ring})
    N("UIStroke",{Color=c,Thickness=t,Parent=ring})
    -- dot
    local dr = math.max(2, math.round(s*0.08))
    circle(f, s//2-dr, math.round(s*0.28)-dr, dr*2, c)
    -- stem
    rect(f, s//2-t//2, math.round(s*0.42), t, math.round(s*0.32), c, t//2)
    return f
end

function Draw.warning(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.11))
    local p = math.round(s*0.06)
    -- triangle via rotated frame trick: draw 3 lines
    local bx,by = s//2, p
    local lx,ly = p, s-p
    local rx,ry = s-p, s-p
    line(f, bx,by, lx,ly, t, c)
    line(f, lx,ly, rx,ry, t, c)
    line(f, rx,ry, bx,by, t, c)
    -- exclamation
    local ex = s//2
    rect(f, ex-t//2, math.round(s*0.38), t, math.round(s*0.28), c, t//2)
    local dr = math.max(2, math.round(s*0.08))
    circle(f, ex-dr, math.round(s*0.75), dr*2, c)
    return f
end

function Draw.error_(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.11))
    local p = math.round(s*0.1)
    local ring = N("Frame",{
        Position=UDim2.fromOffset(p,p),
        Size=UDim2.fromOffset(s-p*2,s-p*2),
        BackgroundTransparency=1,
        Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0.5,0),Parent=ring})
    N("UIStroke",{Color=c,Thickness=t,Parent=ring})
    local ip = math.round(s*0.28)
    line(f, ip,ip, s-ip,s-ip, t, c)
    line(f, s-ip,ip, ip,s-ip, t, c)
    return f
end

function Draw.success(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.11))
    local p = math.round(s*0.1)
    local ring = N("Frame",{
        Position=UDim2.fromOffset(p,p),
        Size=UDim2.fromOffset(s-p*2,s-p*2),
        BackgroundTransparency=1,
        Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0.5,0),Parent=ring})
    N("UIStroke",{Color=c,Thickness=t,Parent=ring})
    local cp = math.round(s*0.22)
    line(f, cp, s*0.52, s*0.42, s-cp, t, c)
    line(f, s*0.42, s-cp, s-cp, cp, t, c)
    return f
end

function Draw.refresh(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.11))
    local p = math.round(s*0.14)
    -- arc (3/4 circle using UIStroke on a frame with ClipsDescendants)
    local ring = N("Frame",{
        Position=UDim2.fromOffset(p,p),
        Size=UDim2.fromOffset(s-p*2,s-p*2),
        BackgroundTransparency=1,
        Rotation=45,
        Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0.5,0),Parent=ring})
    N("UIStroke",{Color=c,Thickness=t,Parent=ring})
    -- arrowhead at end of arc
    local ap = math.round(s*0.18)
    line(f, s-ap-math.round(s*0.14), ap, s-ap, ap+math.round(s*0.18), t, c)
    line(f, s-ap, ap, s-ap+math.round(s*0.14), ap+math.round(s*0.18), t, c)
    return f
end

function Draw.copy_(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.11))
    local p = math.round(s*0.14)
    local off = math.round(s*0.18)
    -- back rect
    local br = N("Frame",{
        Position=UDim2.fromOffset(off,off),
        Size=UDim2.fromOffset(s-p-off, s-p-off),
        BackgroundTransparency=1,
        Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0,math.round(s*0.1)),Parent=br})
    N("UIStroke",{Color=c,Thickness=t,Parent=br})
    -- front rect
    local fr2 = N("Frame",{
        Position=UDim2.fromOffset(p,p),
        Size=UDim2.fromOffset(s-p-off, s-p-off),
        BackgroundTransparency=1,
        Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0,math.round(s*0.1)),Parent=fr2})
    N("UIStroke",{Color=c,Thickness=t,Parent=fr2})
    return f
end

function Draw.trash(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.11))
    local p = math.round(s*0.15)
    local lw = math.round(s*0.12)
    -- lid
    rect(f, p, math.round(s*0.2), s-p*2, t, c, t//2)
    -- handle on lid
    local hw = math.round(s*0.26)
    rect(f, s//2-hw//2, p, hw, math.round(s*0.12)+t, c, math.round(s*0.05))
    -- body
    local by2 = math.round(s*0.3)
    local br2 = N("Frame",{
        Position=UDim2.fromOffset(p+math.round(s*0.04), by2),
        Size=UDim2.fromOffset(s-p*2-math.round(s*0.08), s-by2-p),
        BackgroundTransparency=1,
        Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0,math.round(s*0.08)),Parent=br2})
    N("UIStroke",{Color=c,Thickness=t,Parent=br2})
    -- lines inside
    rect(f, s//2-t//2, by2+math.round(s*0.1), t, s-by2-p-math.round(s*0.2), c, t//2)
    return f
end

function Draw.user(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.11))
    -- head
    local hr = math.round(s*0.18)
    local hx,hy = s//2, math.round(s*0.3)
    local head = N("Frame",{
        Position=UDim2.fromOffset(hx-hr,hy-hr),
        Size=UDim2.fromOffset(hr*2,hr*2),
        BackgroundTransparency=1,
        Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0.5,0),Parent=head})
    N("UIStroke",{Color=c,Thickness=t,Parent=head})
    -- body arc
    local bp = math.round(s*0.12)
    local body = N("Frame",{
        Position=UDim2.fromOffset(bp, math.round(s*0.55)),
        Size=UDim2.fromOffset(s-bp*2, math.round(s*0.34)),
        BackgroundTransparency=1,
        Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0.5,0),Parent=body})
    N("UIStroke",{Color=c,Thickness=t,Parent=body})
    return f
end

function Draw.bell(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.11))
    local p = math.round(s*0.15)
    -- bell body
    local bw = s-p*2
    local body = N("Frame",{
        Position=UDim2.fromOffset(p, math.round(s*0.2)),
        Size=UDim2.fromOffset(bw, math.round(s*0.55)),
        BackgroundTransparency=1,
        Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0,math.round(s*0.3)),Parent=body})
    N("UIStroke",{Color=c,Thickness=t,Parent=body})
    -- clapper
    local cr = math.round(s*0.09)
    circle(f, s//2-cr, math.round(s*0.78), cr*2, c)
    -- stem
    rect(f, s//2-t, p, t*2, math.round(s*0.14), c, t)
    return f
end

function Draw.lock(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.11))
    local p = math.round(s*0.2)
    local bh = math.round(s*0.44)
    local by2 = math.round(s*0.44)
    -- body
    local body = N("Frame",{
        Position=UDim2.fromOffset(p, by2),
        Size=UDim2.fromOffset(s-p*2, bh),
        BackgroundTransparency=1,
        Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0,math.round(s*0.1)),Parent=body})
    N("UIStroke",{Color=c,Thickness=t,Parent=body})
    -- shackle
    local sw = math.round(s*0.36)
    local shackle = N("Frame",{
        Position=UDim2.fromOffset(s//2-sw//2, math.round(s*0.12)),
        Size=UDim2.fromOffset(sw, math.round(s*0.42)),
        BackgroundTransparency=1,
        Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0.5,0),Parent=shackle})
    N("UIStroke",{Color=c,Thickness=t,Parent=shackle})
    -- keyhole dot
    local kr = math.round(s*0.07)
    circle(f, s//2-kr, math.round(s*0.57), kr*2, c)
    return f
end

function Draw.eye(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.11))
    local p = math.round(s*0.1)
    -- outer eye shape: ellipse via scaled frame
    local ew = s-p*2
    local eh = math.round(s*0.44)
    local ey = s//2 - eh//2
    local outer = N("Frame",{
        Position=UDim2.fromOffset(p,ey),
        Size=UDim2.fromOffset(ew,eh),
        BackgroundTransparency=1,
        Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0.5,0),Parent=outer})
    N("UIStroke",{Color=c,Thickness=t,Parent=outer})
    -- pupil
    local pr = math.round(s*0.13)
    circle(f, s//2-pr, s//2-pr, pr*2, c)
    return f
end

function Draw.heart(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.13))
    local p = math.round(s*0.1)
    -- two circles top
    local cr = math.round(s*0.22)
    local lc = N("Frame",{
        Position=UDim2.fromOffset(p, math.round(s*0.18)),
        Size=UDim2.fromOffset(cr*2,cr*2),
        BackgroundTransparency=1,Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0.5,0),Parent=lc})
    N("UIStroke",{Color=c,Thickness=t,Parent=lc})
    local rc = N("Frame",{
        Position=UDim2.fromOffset(s-p-cr*2, math.round(s*0.18)),
        Size=UDim2.fromOffset(cr*2,cr*2),
        BackgroundTransparency=1,Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0.5,0),Parent=rc})
    N("UIStroke",{Color=c,Thickness=t,Parent=rc})
    -- bottom V
    line(f, p, math.round(s*0.44), s//2, s-p, t, c)
    line(f, s//2, s-p, s-p, math.round(s*0.44), t, c)
    return f
end

function Draw.star(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.12))
    local cx,cy = s//2, s//2
    local R = math.round(s*0.44)
    local r = math.round(s*0.2)
    local pts = {}
    for i=0,9 do
        local ang = math.rad(i*36 - 90)
        local rad = (i%2==0) and R or r
        pts[i+1] = {cx+math.cos(ang)*rad, cy+math.sin(ang)*rad}
    end
    for i=1,10 do
        local a,b = pts[i], pts[(i%10)+1]
        line(f, a[1],a[2], b[1],b[2], t, c)
    end
    return f
end

function Draw.key_(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.11))
    local r = math.round(s*0.22)
    local p = math.round(s*0.12)
    -- ring
    local ring = N("Frame",{
        Position=UDim2.fromOffset(p,p),
        Size=UDim2.fromOffset(r*2,r*2),
        BackgroundTransparency=1,
        Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0.5,0),Parent=ring})
    N("UIStroke",{Color=c,Thickness=t,Parent=ring})
    -- shaft
    local sx = p+r*2
    rect(f, sx, s//2-t//2, s-p-sx-math.round(s*0.12), t, c, t//2)
    -- teeth
    local tx = s - p - math.round(s*0.12)
    rect(f, tx, s//2, math.round(s*0.08), math.round(s*0.12), c)
    rect(f, tx-math.round(s*0.16), s//2, math.round(s*0.08), math.round(s*0.1), c)
    return f
end

function Draw.download(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.13))
    local p = math.round(s*0.2)
    -- shaft
    rect(f, s//2-t//2, p, t, math.round(s*0.44), c, t//2)
    -- arrow head
    line(f, s//2, math.round(s*0.62), p, math.round(s*0.38), t, c)
    line(f, s//2, math.round(s*0.62), s-p, math.round(s*0.38), t, c)
    -- base line
    rect(f, p, s-p-t, s-p*2, t, c, t//2)
    return f
end

function Draw.upload(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.13))
    local p = math.round(s*0.2)
    -- shaft
    rect(f, s//2-t//2, math.round(s*0.26), t, math.round(s*0.44), c, t//2)
    -- arrow head (pointing up)
    line(f, s//2, math.round(s*0.26), p, math.round(s*0.5), t, c)
    line(f, s//2, math.round(s*0.26), s-p, math.round(s*0.5), t, c)
    -- base line
    rect(f, p, s-p-t, s-p*2, t, c, t//2)
    return f
end

function Draw.external(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.12))
    local p = math.round(s*0.16)
    local box_s = math.round(s*0.54)
    -- box (bottom-left)
    local bx = N("Frame",{
        Position=UDim2.fromOffset(p, s-p-box_s),
        Size=UDim2.fromOffset(box_s,box_s),
        BackgroundTransparency=1, Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0,math.round(s*0.08)),Parent=bx})
    N("UIStroke",{Color=c,Thickness=t,Parent=bx})
    -- arrow pointing top-right
    local as = math.round(s*0.38)
    line(f, s//2, s//2-as//2+math.round(s*0.04), s-p, p, t, c)
    line(f, s-p-as, p, s-p, p, t, c)
    line(f, s-p, p, s-p, p+as, t, c)
    return f
end

function Draw.grid_(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.1))
    local p = math.round(s*0.14)
    local cs = math.round((s-p*2-t) / 2)
    for row=0,1 do
        for col=0,1 do
            local bx = N("Frame",{
                Position=UDim2.fromOffset(p+col*(cs+t), p+row*(cs+t)),
                Size=UDim2.fromOffset(cs,cs),
                BackgroundTransparency=1, Parent=f,
            })
            N("UICorner",{CornerRadius=UDim.new(0,math.round(s*0.08)),Parent=bx})
            N("UIStroke",{Color=c,Thickness=t,Parent=bx})
        end
    end
    return f
end

function Draw.list_(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.1))
    local p = math.round(s*0.14)
    local d = math.max(3, math.round(s*0.12))
    local rows = 3
    local gap = math.round((s-p*2 - rows*d) / (rows-1))
    for i=0,rows-1 do
        local y = p + i*(d+gap)
        circle(f, p, y+d//2-d//2, d, c)
        rect(f, p+d+math.round(s*0.1), y, s-p*2-d-math.round(s*0.1), math.max(t,2), c, t//2)
    end
    return f
end

function Draw.bookmark(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.11))
    local p = math.round(s*0.2)
    -- outer shape
    local bk = N("Frame",{
        Position=UDim2.fromOffset(p, math.round(s*0.1)),
        Size=UDim2.fromOffset(s-p*2, math.round(s*0.8)),
        BackgroundTransparency=1, Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0,math.round(s*0.08)),Parent=bk})
    N("UIStroke",{Color=c,Thickness=t,Parent=bk})
    -- V notch at bottom via two lines
    line(f, p, s-math.round(s*0.14), s//2, s-math.round(s*0.3), t, c)
    line(f, s//2, s-math.round(s*0.3), s-p, s-math.round(s*0.14), t, c)
    return f
end

function Draw.share(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.12))
    local cr = math.max(3, math.round(s*0.1))
    local p = math.round(s*0.14)
    local lx,ly = p+cr, s//2
    local rx,ry = s-p-cr, p+cr
    local bx,by_ = s-p-cr, s-p-cr
    circle(f, lx-cr, ly-cr, cr*2, c)
    circle(f, rx-cr, ry-cr, cr*2, c)
    circle(f, bx-cr, by_-cr, cr*2, c)
    line(f, lx,ly, rx,ry, t, c)
    line(f, lx,ly, bx,by_, t, c)
    return f
end

function Draw.mail(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.11))
    local p = math.round(s*0.1)
    local top = math.round(s*0.24)
    local bot = math.round(s*0.76)
    -- envelope box
    local env = N("Frame",{
        Position=UDim2.fromOffset(p,top),
        Size=UDim2.fromOffset(s-p*2,bot-top),
        BackgroundTransparency=1, Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0,math.round(s*0.08)),Parent=env})
    N("UIStroke",{Color=c,Thickness=t,Parent=env})
    -- V flap
    line(f, p, top, s//2, s//2+math.round(s*0.04), t, c)
    line(f, s//2, s//2+math.round(s*0.04), s-p, top, t, c)
    return f
end

function Draw.chart(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.1))
    local p = math.round(s*0.12)
    -- axes
    rect(f, p, p, t, s-p*2, c, t//2)
    rect(f, p, s-p-t, s-p*2, t, c, t//2)
    -- bars
    local bw = math.round((s-p*2-t*2) / 5)
    local heights = {0.4, 0.7, 0.55, 0.85, 0.5}
    for i,h in ipairs(heights) do
        local bh = math.round((s-p*2)*h)
        rect(f, p+t+(i-1)*bw+math.round(bw*0.1), s-p-t-bh,
             math.round(bw*0.7), bh, c, math.round(s*0.04))
    end
    return f
end

function Draw.sliders(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.1))
    local p = math.round(s*0.12)
    local cr = math.max(3, math.round(s*0.1))
    local rows = {{0.25,0.55},{0.5,0.3},{0.75,0.7}}
    for _,r in ipairs(rows) do
        local y = math.round(s*r[1])
        local x = math.round(s*r[2])
        rect(f, p, y-t//2, s-p*2, t, c, t//2)
        circle(f, x-cr, y-cr, cr*2, c)
    end
    return f
end

function Draw.calendar(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.11))
    local p = math.round(s*0.1)
    -- box
    local bx = N("Frame",{
        Position=UDim2.fromOffset(p, math.round(s*0.2)),
        Size=UDim2.fromOffset(s-p*2, math.round(s*0.7)),
        BackgroundTransparency=1, Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0,math.round(s*0.1)),Parent=bx})
    N("UIStroke",{Color=c,Thickness=t,Parent=bx})
    -- header line
    rect(f, p, math.round(s*0.42)-t//2, s-p*2, t, c)
    -- pins
    local pt = math.round(s*0.12)
    local pw = math.max(2, math.round(s*0.08))
    rect(f, math.round(s*0.3)-pw//2, math.round(s*0.12), pw, pt, c, pw//2)
    rect(f, math.round(s*0.7)-pw//2, math.round(s*0.12), pw, pt, c, pw//2)
    -- dots grid (2×2)
    local dr = math.max(2, math.round(s*0.07))
    for row=0,1 do
        for col=0,1 do
            circle(f,
                math.round(s*(0.32+col*0.28))-dr,
                math.round(s*(0.56+row*0.18))-dr,
                dr*2, c)
        end
    end
    return f
end

function Draw.send(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.12))
    local p = math.round(s*0.1)
    -- paper plane: triangle
    line(f, p, s-p, s-p, p, t, c)
    line(f, p, s-p, s//2, s//2, t, c)
    line(f, s-p, p, s//2, s//2, t, c)
    -- tail
    line(f, p, s-p, math.round(s*0.42), math.round(s*0.58), t, c)
    return f
end

function Draw.power(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.12))
    local p = math.round(s*0.14)
    -- arc (top open)
    local ar = math.round(s*0.32)
    local ax,ay = s//2, math.round(s*0.44)
    local arc = N("Frame",{
        Position=UDim2.fromOffset(ax-ar, ay-ar),
        Size=UDim2.fromOffset(ar*2,ar*2),
        BackgroundTransparency=1, Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0.5,0),Parent=arc})
    N("UIStroke",{Color=c,Thickness=t,Parent=arc})
    -- stem
    rect(f, s//2-t//2, p, t, math.round(s*0.38), c, t//2)
    return f
end

function Draw.pin(s,c)
    local f = container(s)
    local t = math.max(2, math.round(s*0.12))
    local p = math.round(s*0.18)
    local r = math.round(s*0.26)
    local cx = s//2
    local cy = math.round(s*0.36)
    -- circle
    local ring = N("Frame",{
        Position=UDim2.fromOffset(cx-r,cy-r),
        Size=UDim2.fromOffset(r*2,r*2),
        BackgroundTransparency=1, Parent=f,
    })
    N("UICorner",{CornerRadius=UDim.new(0.5,0),Parent=ring})
    N("UIStroke",{Color=c,Thickness=t,Parent=ring})
    -- teardrop tail
    line(f, cx, cy+r, cx, s-p, t, c)
    return f
end

-- ── Name aliases ──────────────────────────────────────────────

Draw["x"]            = Draw.close
Draw["error"]        = Draw.error_
Draw["alert"]        = Draw.warning
Draw["trash_"]       = Draw.trash
Draw["delete"]       = Draw.close
Draw["done"]         = Draw.check
Draw["tick"]         = Draw.check
Draw["add"]          = Draw.plus
Draw["remove"]       = Draw.minus
Draw["nav_right"]    = Draw.chevron_right
Draw["nav_left"]     = Draw.chevron_left
Draw["nav_up"]       = Draw.chevron_up
Draw["nav_down"]     = Draw.chevron_down
Draw["hamburger"]    = Draw.menu
Draw["dots"]         = Draw.more
Draw["kebab"]        = Draw.more_v
Draw["reload"]       = Draw.refresh
Draw["duplicate"]    = Draw.copy_
Draw["save"]         = Draw.download
Draw["export"]       = Draw.upload
Draw["filter_"]      = Draw.sliders
Draw["tune"]         = Draw.sliders
Draw["notification"] = Draw.bell
Draw["favourite"]    = Draw.star
Draw["like"]         = Draw.heart
Draw["location"]     = Draw.pin
Draw["map_pin"]      = Draw.pin
Draw["open"]         = Draw.external
Draw["navigate"]     = Draw.arrow_right
Draw["back"]         = Draw.arrow_left
Draw["up"]           = Draw.arrow_up
Draw["down"]         = Draw.arrow_down
Draw["message"]      = Draw.mail
Draw["email"]        = Draw.mail
Draw["statistics"]   = Draw.chart
Draw["graph"]        = Draw.chart
Draw["equalizer"]    = Draw.sliders

-- ── Public API ────────────────────────────────────────────────

--[[
    Icons.Get(name, size, color)
    ────────────────────────────
    Returns a cloned Frame with the icon drawn inside.
    Falls back to an ImageLabel using Icons.Id if no
    drawn version exists.

    name  : string  — icon name (see Draw table + aliases)
    size  : number  — pixel size (default 20)
    color : Color3  — icon colour (default white)
]]
function Icons.Get(name, size, color)
    size  = size  or 20
    color = color or Color3.new(1,1,1)

    local fn = Draw[name] or Draw[name:lower()]
    if fn then
        local ico = fn(size, color)
        ico.Name = "Icon_"..name
        return ico
    end

    -- Fallback: ImageLabel with asset ID
    local id = Icons.Id[name] or Icons.Id[name:lower()]
    local lbl = Instance.new("ImageLabel")
    lbl.Name             = "Icon_"..name
    lbl.Size             = UDim2.fromOffset(size,size)
    lbl.BackgroundTransparency = 1
    lbl.ImageColor3      = color
    lbl.ScaleType        = Enum.ScaleType.Fit
    lbl.Image            = id or ""
    if not id then
        -- placeholder: small dot
        lbl.Image = ""
        Instance.new("UICorner",lbl).CornerRadius = UDim.new(0.5,0)
        lbl.BackgroundTransparency = 0
        lbl.BackgroundColor3 = color
        lbl.Size = UDim2.fromOffset(math.max(4,size//5), math.max(4,size//5))
    end
    return lbl
end

--[[
    Icons.List()
    ────────────
    Returns a sorted list of all available drawn icon names.
]]
function Icons.List()
    local names = {}
    for k in pairs(Draw) do
        table.insert(names, k)
    end
    table.sort(names)
    return names
end

--[[
    Icons.Has(name)
    ───────────────
    Returns true if a drawn or asset-ID icon exists for name.
]]
function Icons.Has(name)
    return Draw[name] ~= nil
        or Draw[name:lower()] ~= nil
        or Icons.Id[name] ~= nil
        or Icons.Id[name:lower()] ~= nil
end

return Icons
