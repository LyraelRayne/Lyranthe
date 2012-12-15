-- Author      : Lyrael
-- Create Date : 2012/12/15 08:31 AM

-- Working functionality:
--
-- Pending Functionality:

Lyranthe = LibStub("AceAddon-3.0"):NewAddon("Lyranthe", "AceConsole-3.0", "AceEvent-3.0");
Lyranthe.BAR_TEMPLATE = "LyrantheButtonBar";
Lyranthe.BUTTON_TEMPLATE = "LyrantheButton";

local addon = Lyranthe;
local LibKeyBound = LibStub("LibKeyBound-1.0");
local Masque = LibStub("Masque", true);

addon.bars = {};

function addon:OnInitialize()
	self:InitConfig();

	self:GenerateBars();

	-- Register for events
	self:RegisterEvents();

	self:SetupOSD(State_Display);

	-- Always good to know that it worked ;)
	self:Print("Lyranthe Initialized");

end


function addon:OnEnable(first)
--	LibKeyBound.RegisterCallback(self, "LIBKEYBOUND_ENABLED")
--	LibKeyBound.RegisterCallback(self, "LIBKEYBOUND_DISABLED")
--	LibKeyBound.RegisterCallback(self, "LIBKEYBOUND_MODE_COLOR_CHANGED")
end


function addon:RegisterEvents()
-- self:RegisterEvent("AN_EVENT", "A_HANDLER");
end




--function Lyranthe:LIBKEYBOUND_ENABLED()
--end
--
--function Lyranthe:LIBKEYBOUND_DISABLED()
--
--end
--
--function Lyranthe:LIBKEYBOUND_MODE_COLOR_CHANGED()
--
--end

-- Adds button prototype functions to the metatable index, essentially "mixing in" the prototype methods.
local function SetButtonMeta(button)
	local meta = getmetatable(button);
	if(meta == nil) then
		meta = {};
		meta.__index = {};
	elseif(meta.__index == nil) then
		meta.__index = {};
	end

	local theIndex = meta.__index;
	-- We only need to update the metatable if it doesn't have our stuff in it already.
	-- It would seem that secure action button types all share the same metatable so only need to update once per load!
	if(not theIndex.lyrantheMetaLoaded) then
		for key,value in pairs(addon.ButtonPrototype) do
			if(key ~= nil) then
				theIndex[key] = value;
			end
		end
		meta.__index = theIndex;
		theIndex.lyrantheMetaLoaded = true;
		setmetatable(button, meta);
	end
end

function addon:GenerateBars()
	local profile = addon.configDB.profile;

	for index, barConfig in ipairs(profile.bars) do
		local barName = barConfig.name;
		local barFrameName = self:GetName() .. "_" .. barName;
		local bar = CreateFrame("Frame", barFrameName, UIParent, self.BAR_TEMPLATE);
		bar:SetPoint(barConfig.anchorPoint, barConfig.relativeTo, barConfig.relativePoint, barConfig.xOffset, barConfig.yOffset);
		bar.config = barConfig;
		self.bars[barName] = bar;
		self:GenerateButtons(bar);
		self:ConfigureBar(bar);
		bar:Show();
	end
end

function addon:ConfigureBar(bar)
	local config = bar.config;
	local msqGroup = nil;
	if(Masque) then
		msqGroup = Masque:Group(self:GetName(), config.name);
	end

	local buttons = {bar:GetChildren()};
	for _,button in ipairs(buttons) do
		if(msqGroup) then
			msqGroup:AddButton(button);
		end
		self:ConfigureButton(button);
	end
end

function addon:GenerateButtons(bar)
	local config = bar.config;


	local buttonConfigs = config.buttons;
	local lastbutton = nil;
	for index, buttonConfig in ipairs(buttonConfigs) do
		local buttonName = bar:GetName() .. "_Button" .. index;
		local button = CreateFrame("CheckButton", buttonName, bar, self.BUTTON_TEMPLATE);
		SetButtonMeta(button);
		button.currentActionPrototype = addon.ButtonPrototype[buttonConfig.attributes.type];
		button:SetScript("OnAttributeChanged", button.OnAttributeChanged);
		button.config = buttonConfig;
		if(lastButton) then
			button:SetPoint("TOPLEFT", lastButton, "TOPRIGHT", 3, 0);
		else
			button:SetPoint("TOPLEFT");
		end
		lastButton = button;
	end
end

function addon:ConfigureButton(button)
	local config = button.config;
	if(config.width and config.height) then
		button:SetSize(config.width, config.height);
	end
	for key, value in pairs(config.attributes) do
		button:SetAttribute(key, value);
	end
	button:OnLoad();
end




function addon:GetSpellBookId(spell)
	local targetSpellName = GetSpellInfo(spell);
	local i = 1
	while true do
		local currentSpellName = GetSpellBookItemName(i, BOOKTYPE_SPELL);
		if (not currentSpellName) then
			break
		end
		if(currentSpellName == targetSpellName) then
			return i;
		end

		i = i + 1
	end
end

