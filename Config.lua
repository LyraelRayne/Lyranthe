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
		default = {kind = "empty",
			action = 0,
		},
	},
	unit = nil;
	startup_state = "default",
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
				yOffset = 100,
				buttons = {
					[1] = buttonDefaults,
					[2] = buttonDefaults,
					[3] = buttonDefaults,
					[4] = buttonDefaults,
					[5] = buttonDefaults,
					[6] = buttonDefaults,
					[7] = buttonDefaults,
					[8] = buttonDefaults,
					[9] = buttonDefaults,
					[10]= buttonDefaults,
					[11]= buttonDefaults,
					[12]= buttonDefaults,
				},
			},
		},
	},
};

function addon:InitConfig()
	addon.configDB = AceDB:New("LyrantheDB", DefaultSettings);
end