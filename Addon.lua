-- Author      : Lyrael
-- Create Date : 2012/12/15 08:31 AM

-- Working functionality:
--
-- Pending Functionality:

local addonName = "Lyranthe";
Lyranthe = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0");
local addon = Lyranthe;

addon.GROUP_TEMPLATE = "LyrantheActionButtonGroup";
addon.BUTTON_TEMPLATE = "LyrantheActionButton";
addon.BUTTON_SIDE_LENGTH = 36;

local LibKeyBound = LibStub("LibKeyBound-1.0");
local LibActionButton = LibStub("LibActionButton-1.0");
local Masque = LibStub("Masque", true);

addon.bars = {};

function addon:OnInitialize()
	self:InitConfig();

	-- Register for events
	self:RegisterEvents();

	-- Always good to know that it worked ;)
	self:Print("Lyranthe Initialized");
end


function addon:OnEnable(first)
	self:GenerateBars();

--	LibKeyBound.RegisterCallback(self, "LIBKEYBOUND_ENABLED")
--	LibKeyBound.RegisterCallback(self, "LIBKEYBOUND_DISABLED")
--	LibKeyBound.RegisterCallback(self, "LIBKEYBOUND_MODE_COLOR_CHANGED")
end

function addon:GenerateBars()

end

function addon:RegisterEvents()
-- self:RegisterEvent("PLAYER_LOGIN", "OnPlayerLogin");
end



