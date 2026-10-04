--[[
  NovaUI Reporter  ·  Auto error reporter via Discord webhook
  ─────────────────────────────────────────────────────────────
  SETUP: fill in the three values below, then host this file
  and load it with:

      local NovaUI = loadstring(game:HttpGet("YOUR_REPORTER_URL"))()

  That's it. reporter auto-loads NovaUI, and if anything goes
  wrong it fires your Discord webhook with a full report.
]]

-- ── FILL THESE IN ─────────────────────────────────────────────
local NOVA_URL      = ""   -- raw URL to your NovaUI.lua
local ICONS_URL     = ""   -- raw URL to your Icons.luau  (optional)
local WEBHOOK_URL   = ""   -- your Discord webhook URL    (optional)
local GAME_NAME     = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or tostring(game.PlaceId)
-- ──────────────────────────────────────────────────────────────

local HttpService  = game:GetService("HttpService")
local Players      = game:GetService("Players")
local StarterGui   = game:GetService("StarterGui")

local RETRY_COUNT = 3
local RETRY_DELAY = 1.5

-- ── Logging ───────────────────────────────────────────────────

local function log(tag, msg)
    print(("[NovaUI Reporter] [%s] %s"):format(tag, tostring(msg)))
end
local function warn_(tag, msg)
    warn(("[NovaUI Reporter] [%s] %s"):format(tag, tostring(msg)))
end

-- ── Icons fallback (only runs when NovaUI fails) ─────────────
-- Loads Icons silently and returns the module, or nil.

local function loadIcons()
    if not ICONS_URL or ICONS_URL == "" then return nil end
    local ok, src = pcall(function() return game:HttpGet(ICONS_URL, true) end)
    if not ok or type(src) ~= "string" or #src < 50 then return nil end
    local chunk, _ = loadstring(src)
    if not chunk then return nil end
    local ok2, mod = pcall(chunk)
    if ok2 and type(mod) == "table" then
        log("ICONS","Fallback icons loaded.")
        return mod
    end
    return nil
end

-- ── User ID hashing (FNV-1a 32-bit, hex output) ───────────────
-- Never sends the real UserId to Discord.

local function hashId(id)
    local h = 2166136261
    local s = tostring(id)
    for i = 1, #s do
        h = bit32.bxor(h, string.byte(s, i))
        h = bit32.band(h * 16777619, 0xFFFFFFFF)
    end
    return ("%08x"):format(h)
end

local function safePlayer()
    local p = Players.LocalPlayer
    if not p then return "unknown#????????" end
    return ("%s#%s"):format(p.Name, hashId(p.UserId))
end

-- ── Discord webhook (errors only) ────────────────────────────

local function sendWebhook(title, description, color, fields)
    if not WEBHOOK_URL or WEBHOOK_URL == "" then return end

    local embedFields = {}
    for _, f in ipairs(fields or {}) do
        table.insert(embedFields, {
            name   = f.name,
            value  = ("```\n%s\n```"):format(tostring(f.value):sub(1, 1000)),
            inline = f.inline or false,
        })
    end

    local payload = HttpService:JSONEncode({
        username   = "NovaUI Reporter",
        avatar_url = "https://i.imgur.com/mBKPCaA.png",
        embeds = {{
            title       = title,
            description = description,
            color       = color,
            fields      = embedFields,
            footer      = { text = ("Game: %s  ·  PlaceId: %d"):format(GAME_NAME, game.PlaceId) },
            timestamp   = DateTime.now():ToIsoDate(),
        }},
    })

    pcall(function()
        HttpService:PostAsync(WEBHOOK_URL, payload, Enum.HttpContentType.ApplicationJson, false)
    end)
end

-- ── In-game error GUI (fallback, no NovaUI needed) ────────────

local function showErrorWindow(errors)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title    = "NovaUI Failed to Load",
            Text     = "Check console output for details.",
            Duration = 8,
        })
    end)

    local player    = Players.LocalPlayer
    local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return end

    local existing = playerGui:FindFirstChild("__NovaUIReporterError")
    if existing then existing:Destroy() end

    local function New(cls, props, children)
        local i = Instance.new(cls)
        for k,v in pairs(props or {}) do i[k]=v end
        for _,c in ipairs(children or {}) do c.Parent=i end
        return i
    end

    local gui = New("ScreenGui",{
        Name="__NovaUIReporterError", ResetOnSpawn=false,
        DisplayOrder=9999, IgnoreGuiInset=true, Parent=playerGui
    })

    local bg = New("Frame",{
        Size=UDim2.new(0,460,0,40), Position=UDim2.new(0.5,-230,0.5,-20),
        BackgroundColor3=Color3.fromRGB(16,16,22), BorderSizePixel=0, Parent=gui
    },{New("UICorner",{CornerRadius=UDim.new(0,10)})})

    local bar = New("Frame",{
        Size=UDim2.new(1,0,0,42), BackgroundColor3=Color3.fromRGB(190,40,40),
        BorderSizePixel=0, Parent=bg
    },{New("UICorner",{CornerRadius=UDim.new(0,10)})})
    New("Frame",{Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,1,-10),
        BackgroundColor3=Color3.fromRGB(190,40,40),BorderSizePixel=0,Parent=bar})

    New("TextLabel",{
        Size=UDim2.new(1,-50,1,0), Position=UDim2.new(0,12,0,0),
        BackgroundTransparency=1, Text="⚠  NovaUI Failed to Load",
        TextColor3=Color3.new(1,1,1), Font=Enum.Font.GothamBold,
        TextSize=15, TextXAlignment=Enum.TextXAlignment.Left, Parent=bar
    })

    local close = New("TextButton",{
        Size=UDim2.new(0,30,0,30), Position=UDim2.new(1,-36,0,6),
        BackgroundColor3=Color3.fromRGB(230,70,70), Text="✕",
        TextColor3=Color3.new(1,1,1), Font=Enum.Font.GothamBold,
        TextSize=14, BorderSizePixel=0, Parent=bar
    },{New("UICorner",{CornerRadius=UDim.new(0,6)})})
    close.MouseButton1Click:Connect(function() gui:Destroy() end)

    local body = New("Frame",{
        Position=UDim2.new(0,0,0,42), Size=UDim2.new(1,0,0,10),
        BackgroundTransparency=1, Parent=bg
    })
    local layout = New("UIListLayout",{
        Padding=UDim.new(0,5),
        HorizontalAlignment=Enum.HorizontalAlignment.Center, Parent=body
    })
    New("UIPadding",{
        PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14),
        PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,14),Parent=body
    })

    local function row(txt, col)
        New("TextLabel",{
            Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1, Text=txt,
            TextColor3=col or Color3.fromRGB(210,210,220),
            Font=Enum.Font.Gotham, TextSize=13,
            TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left,
            Parent=body
        })
    end

    row("All strategies failed. Errors:", Color3.fromRGB(255,180,80))
    for i,e in ipairs(errors) do
        row(("  [%d] %s"):format(i,e), Color3.fromRGB(255,110,110))
    end
    row("─────────────────────────────────────", Color3.fromRGB(50,50,70))
    row("• Check NOVA_URL points to raw NovaUI.lua", nil)
    row("• HTTP requests must be enabled in game settings", nil)
    if WEBHOOK_URL ~= "" then
        row("• A report has been sent to your Discord webhook", Color3.fromRGB(100,200,255))
    end

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local h = layout.AbsoluteContentSize.Y + 28
        body.Size = UDim2.new(1,0,0,h)
        bg.Size   = UDim2.new(0,460,0,42+h)
        bg.Position = UDim2.new(0.5,-230,0.5,-(42+h)/2)
    end)
end

-- ── Load NovaUI from URL ───────────────────────────────────────

local function loadNovaUI()
    if not NOVA_URL or NOVA_URL == "" then
        warn_("CFG","NOVA_URL is empty — nothing to load")
        return nil
    end

    local src, lastErr
    for attempt = 1, RETRY_COUNT do
        local ok, result = pcall(function()
            return game:HttpGet(NOVA_URL, true)
        end)
        if ok and type(result)=="string" and #result > 100 then
            src = result
            break
        else
            lastErr = tostring(result)
            warn_("HTTP",("Attempt %d/%d: %s"):format(attempt, RETRY_COUNT, lastErr))
            if attempt < RETRY_COUNT then task.wait(RETRY_DELAY) end
        end
    end

    if not src then
        local errors = {
            ("HTTP GET failed after %d attempts: %s"):format(RETRY_COUNT, lastErr or "unknown"),
        }
        warn_("FAIL","NovaUI could not be fetched.")

        sendWebhook(
            "❌ NovaUI Failed to Load",
            ("Could not fetch NovaUI source after **%d** attempts."):format(RETRY_COUNT),
            0xFF3333,
            {
                { name="URL",        value=NOVA_URL },
                { name="Last Error", value=lastErr or "unknown" },
                { name="Player",     value=safePlayer() },
                { name="Game",       value=GAME_NAME.." ("..game.PlaceId..")" },
            }
        )

        task.spawn(loadIcons)
        pcall(showErrorWindow, errors)
        return nil
    end

    -- Compile
    local chunk, compileErr = loadstring(src)
    if not chunk then
        local errors = { "Compile error: "..tostring(compileErr) }
        warn_("FAIL","NovaUI source failed to compile: "..tostring(compileErr))

        sendWebhook(
            "❌ NovaUI Compile Error",
            "NovaUI loaded but failed to compile.",
            0xFF6600,
            {
                { name="Compile Error", value=compileErr },
                { name="Player",        value=safePlayer() },
                { name="Game",          value=GAME_NAME.." ("..game.PlaceId..")" },
            }
        )

        task.spawn(loadIcons)
        pcall(showErrorWindow, errors)
        return nil
    end

    -- Execute
    local ok, result = pcall(chunk)
    if not ok then
        local errors = { "Runtime error: "..tostring(result) }
        warn_("FAIL","NovaUI execution error: "..tostring(result))

        sendWebhook(
            "❌ NovaUI Runtime Error",
            "NovaUI compiled but errored on execution.",
            0xFF9900,
            {
                { name="Runtime Error", value=result },
                { name="Player",        value=safePlayer() },
                { name="Game",          value=GAME_NAME.." ("..game.PlaceId..")" },
            }
        )

        task.spawn(loadIcons)
        pcall(showErrorWindow, errors)
        return nil
    end

    log("OK","NovaUI loaded successfully.")
    -- Icons skipped — NovaUI loaded fine.
    return result
end

return loadNovaUI()
