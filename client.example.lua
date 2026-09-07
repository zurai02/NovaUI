--[[
	Example usage of NovaUI.
	Place NovaUI.lua as a ModuleScript somewhere accessible (e.g. ReplicatedStorage),
	and this file as a LocalScript in StarterPlayerScripts.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NovaUI = require(ReplicatedStorage:WaitForChild("NovaUI"))

local Window = NovaUI:CreateWindow({
	Title = "Aurora Client",
	Subtitle = "v1.3.0",
	Theme = "Ocean", -- try "Dark", "Light", "Ocean", "Amethyst", or "Emerald"
	Size = UDim2.fromOffset(560, 380),
	ToggleKey = Enum.KeyCode.RightControl,
})

-- // Main tab
local MainTab = Window:CreateTab("Main")

MainTab:CreateSection("Movement")

MainTab:CreateToggle({
	Name = "Infinite Sprint",
	CurrentValue = false,
	Flag = "InfiniteSprint",
	Callback = function(value)
		print("Infinite Sprint set to", value)
	end,
})

MainTab:CreateSlider({
	Name = "Walk Speed",
	Range = { 16, 100 },
	Increment = 1,
	CurrentValue = 16,
	Flag = "WalkSpeed",
	Callback = function(value)
		local character = game.Players.LocalPlayer.Character
		if character and character:FindFirstChild("Humanoid") then
			character.Humanoid.WalkSpeed = value
		end
	end,
})

MainTab:CreateSection("Visuals")

MainTab:CreateDropdown({
	Name = "Theme",
	Options = { "Dark", "Light" },
	CurrentOption = "Dark",
	Flag = "SelectedTheme",
	Callback = function(value)
		NovaUI:Notify({ Title = "Theme", Content = "Selected " .. value, Duration = 3 })
	end,
})

MainTab:CreateColorPicker({
	Name = "Highlight Color",
	CurrentColor = Color3.fromRGB(242, 169, 59),
	Flag = "HighlightColor",
	Callback = function(color)
		print("Highlight color:", color)
	end,
})

MainTab:CreateButton({
	Name = "Send Test Notification",
	Info = "Fires a sample notification with a Success accent.",
	Callback = function()
		NovaUI:Notify({
			Title = "Hello!",
			Content = "This is a NovaUI notification.",
			Duration = 4,
		})
	end,
})

-- // Settings tab
local SettingsTab = Window:CreateTab("Settings")

SettingsTab:CreateInput({
	Name = "Username",
	PlaceholderText = "Enter a nickname",
	Flag = "Nickname",
	Callback = function(text, enterPressed)
		print("Nickname:", text, enterPressed)
	end,
})

SettingsTab:CreateKeybind({
	Name = "Toggle Menu",
	CurrentKeybind = Enum.KeyCode.RightControl,
	Flag = "MenuKeybind",
	Callback = function(key)
		print("Menu keybind set to", key.Name)
	end,
})

SettingsTab:CreateSection("Config")

SettingsTab:CreateDropdown({
	Name = "Enabled Modules",
	MultiSelect = true,
	Options = { "ESP Hider", "Chat Filter", "Auto Reconnect" },
	CurrentOptions = { "Chat Filter" },
	Flag = "EnabledModules",
	Callback = function(list)
		print("Enabled modules:", table.concat(list, ", "))
	end,
})

SettingsTab:CreateButton({
	Name = "Copy Config to Clipboard",
	Callback = function()
		local exported = NovaUI:ExportConfig()
		if exported then
			print("Config JSON:", exported) -- swap for Clipboard-writing if your environment supports it
		end
	end,
})

SettingsTab:CreateLabel("NovaUI stores every flagged value in NovaUI.Flags for easy lookup elsewhere in your codebase.")

SettingsTab:CreateDivider()

SettingsTab:CreateParagraph({
	Title = "About this menu",
	Content = "Built with NovaUI — a single-file Luau component library. No external dependencies.",
})

NovaUI:Notify({
	Title = "Welcome",
	Type = "Success",
	Content = "Aurora Client loaded successfully.",
	Duration = 4,
})

-- Clean up everything (connections, ScreenGui) when you're done with the window:
-- Window:Destroy()
