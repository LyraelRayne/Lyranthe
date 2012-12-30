local addon = Lyranthe;
local addonName = addon:GetName();

local AceConfigOptions = {};
local AceConfig = LibStub("AceConfig-3.0");
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0");
local AceDB = LibStub("AceDB-3.0");

-- Default settings
local DefaultSettings = {
	profile = {
		groups = {
			['*'] = {
				centerX = 0,
				centerY = 0,
				relativePoint = "CENTER",
				width = 40,
				height = 40,
			},
		},
	},
};

function addon:InitConfig()
	addon.configDB = AceDB:New(addonName .. "DBTemp", DefaultSettings);
end