-- Author      : Lyrael
-- Create Date : 2012/12/15 08:31 AM

-- Working functionality:
--
-- Pending Functionality:

local addonName = "Lyranthe";

Lyranthe = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0");
Lyranthe.BAR_TEMPLATE = "LyrantheButtonBar";
Lyranthe.BUTTON_TEMPLATE = "LyrantheButton";

local addon = Lyranthe;
local LibKeyBound = LibStub("LibKeyBound-1.0");
local LibActionButton = LibStub("LibActionButton-1.0");
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

local function AssignBarStateHandler(bar)
	local stateHandler = [[
			self:ChildUpdate(stateid, newstate);
		]]
	bar:SetAttribute("_onstate-state", stateHandler);
	RegisterStateDriver(bar, "state", "[help]heal;default");
	bar:SetAttribute("state-state", "default");
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
		self:SetupMasque(bar);
		AssignBarStateHandler(bar);
		bar:Show();
	end

end

function addon:SetupMasque(bar)
	local config = bar.config;
	local msqGroup = nil;
	if(Masque) then
		msqGroup = Masque:Group(self:GetName(), config.name);
	end

	local buttons = {bar:GetChildren()};
	for _,button in ipairs(buttons) do
		if(msqGroup) then
			button:AddToMasque(msqGroup);
		end
	end
end

function addon:GenerateButtons(bar)
	local config = bar.config;

	local buttonConfigs = config.buttons;
	local lastbutton = nil;
	for index, buttonConfig in ipairs(buttonConfigs) do
		local buttonName = bar:GetName() .. "_Button" .. index;
		local button = LibActionButton:CreateButton(buttonName, buttonName, bar, buttonConfig.labConfig);
		button[addonName .. "config"]= buttonConfig;
		button:SetState("default", "action", index);

		if(lastButton) then
			button:SetPoint("TOPLEFT", lastButton, "TOPRIGHT", 2, 0);
		else
			button:SetPoint("TOPLEFT");
		end
		self:ConfigureButton(button);
		lastButton = button;
	end
end

function addon:ConfigureButton(button)
	local config = button.config;
	if(config.width and config.height) then
		button:SetSize(config.width, config.height);
	end
	if(config.attributes) then
		for key, value in pairs(config.attributes) do
			button:SetAttribute(key, value);
		end
	end
end

function addon:GetSpellBookId(spell)
	return FindSpellBookSlotBySpellID(spell);
	
	
end

-- Thanks to Nevcairiel, nicked this function from Bartender4.
function addon:Merge(target, source)
	if type(target) ~= "table" then target = {} end
	for k,v in pairs(source) do
		if type(v) == "table" then
			target[k] = self:Merge(target[k], v)
		elseif target[k] == nil then
			target[k] = v
		end
	end
	return target
end


