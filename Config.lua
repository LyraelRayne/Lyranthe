local addon = Lyranthe;

local AceConfigOptions = {};
local AceConfig = LibStub("AceConfig-3.0");
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0");
local AceDB = LibStub("AceDB-3.0");


local labDefaultConfig = {
	outOfRangeColoring = "button",
	tooltip = "enabled",
	showGrid = true,
	colors = {
		range = { 0.8, 0.1, 0.1 },
		mana = { 0.5, 0.5, 1.0 }
	},
	hideElements = {
		macro = false,
		hotkey = false,
		equipped = false,
	},
	keyBoundTarget = nil,
	clickOnDown = false,
	flyoutDirection = "UP",
}

local buttonDefaults = {
	labConfig = labDefaultConfig,
	width = nil,
	height = nil,
	states = {
		default = {type = "empty",
			action = 0,
		},
	},
	attributes = {
		["useparent-unit"] = true,
	},
	unit = nil,
};

local defaultStates =  {
					"[@mouseover, harm, mod:ctrl]cc-mo",
					"[@focus, harm, mod:ctrl]cc-fo",
					"[@target, harm, mod:ctrl]cc-ta",
					"[@mouseover,help,nodead]heal-mo",
					"[@target,help,nodead]heal-ta",
					"[@mouseover,help,dead]rez-mo",
					"[@target,help,dead]rez-ta",
					"[@target,exists]default-ta",
					"[@mouseover,exists]default-mo",
					"[]default-df",
				};

-- Default settings
local DefaultSettings = {
	profile = {
		bars = {
			[1] = {
				name = "Bar1",
				relativeTo = "ActionButton1",
				anchorPoint = "BOTTOMLEFT",
				relativePoint = "TOPLEFT",
				xOffset = 0,
				yOffset = 120,
				buttons = {
					[1] = buttonDefaults,
					[2] = buttonDefaults,
					[3] = buttonDefaults,
					[4] = buttonDefaults,
					[5] = buttonDefaults,
					[6] = buttonDefaults,
					[7] = buttonDefaults,
				},
				states = defaultStates,
			},
			[2] = {
				name = "Bar2",
				relativeTo = "ActionButton1",
				anchorPoint = "BOTTOMLEFT",
				relativePoint = "TOPLEFT",
				xOffset = 0,
				yOffset = 80,
				buttons = {
					[1] = buttonDefaults,
					[2] = buttonDefaults,
					[3] = buttonDefaults,
					[4] = buttonDefaults,
					[5] = buttonDefaults,
					[6] = buttonDefaults,
					[7] = buttonDefaults,
				},
				states = defaultStates,
			},
			[3] = {
				name = "Bar3",
				relativeTo = "ActionButton1",
				anchorPoint = "BOTTOMLEFT",
				relativePoint = "TOPLEFT",
				xOffset = 38,
				yOffset = 40,
				buttons = {
					[1] = buttonDefaults,
					[2] = buttonDefaults,
					[3] = buttonDefaults,
					[4] = buttonDefaults,
					[5] = buttonDefaults,
				},
				states = defaultStates,
			},
			[4] = {
				name = "Bar4",
				relativeTo = "ActionButton1",
				anchorPoint = "BOTTOMLEFT",
				relativePoint = "TOPLEFT",
				xOffset = 76,
				yOffset = 0,
				buttons = {
					[1] = buttonDefaults,
					[2] = buttonDefaults,
					[3] = buttonDefaults,
				},
				states = defaultStates,
			},
		},
	},
};

function addon:InitConfig()
	addon.configDB = AceDB:New("LyrantheDB", DefaultSettings);
end