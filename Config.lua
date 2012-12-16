local addon = Lyranthe;

local AceConfigOptions = {};
local AceConfig = LibStub("AceConfig-3.0");
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0");
local AceDB = LibStub("AceDB-3.0");


function addon:getActionButtonDefaults(actionSlot) return {
		attributes = {
			type = "action",
			action = actionSlot,
			unit = "target",
			["useparent-unit"] = true,
			showgrid = 1,
			checkselfcast = true,
			checkfocuscast = true,
		},
		width = nil,
		height = nil,
	};
end


function addon:getSpellButtonDefaults(spellID) return {
		attributes = {
			type = "spell",
			spell = spellID,
			unit = "target",
			["useparent-unit"] = true,
			showgrid = 1,
			checkselfcast = true,
			checkfocuscast = true,
		},
		width = nil,
		height = nil,
	};
end



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
					[1] = addon:getActionButtonDefaults(1),
					[2] = addon:getActionButtonDefaults(2),
					[3] = addon:getActionButtonDefaults(3),
					[4] = addon:getActionButtonDefaults(4),
					[5] = addon:getActionButtonDefaults(5),
					[6] = addon:getSpellButtonDefaults(8042),
					[7] = addon:getActionButtonDefaults(7),
					[8] = addon:getActionButtonDefaults(8),
					[9] = addon:getActionButtonDefaults(9),
					[10]= addon:getActionButtonDefaults(10),
					[11]= addon:getActionButtonDefaults(11),
					[12]= addon:getActionButtonDefaults(12),
				},
			},
		},
	},
};

function addon:InitConfig()
	addon.configDB = AceDB:New("LyrantheDB", DefaultSettings);
end