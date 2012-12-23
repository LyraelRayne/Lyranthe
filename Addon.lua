-- Author      : Lyrael
-- Create Date : 2012/12/15 08:31 AM

-- Working functionality:
--
-- Pending Functionality:

local addonName = "Lyranthe";
Lyranthe = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0");
local addon = Lyranthe;

addon.BAR_TEMPLATE = "LyrantheButtonBar";
addon.BUTTON_TEMPLATE = "LyrantheButton";
addon.BUTTON_SIDE_LENGTH = 38;

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
	self:SetupOSD(State_Display);

--	LibKeyBound.RegisterCallback(self, "LIBKEYBOUND_ENABLED")
--	LibKeyBound.RegisterCallback(self, "LIBKEYBOUND_DISABLED")
--	LibKeyBound.RegisterCallback(self, "LIBKEYBOUND_MODE_COLOR_CHANGED")
end


function addon:RegisterEvents()
-- self:RegisterEvent("PLAYER_LOGIN", "OnPlayerLogin");
end

local function BuildStateFromStates(states)
	local stateString = "";
	for index, value in ipairs(states) do
		stateString = stateString .. value
		if(index < getn(states)) then
			stateString = stateString .. ";"
		end
	end
	return stateString;
end

local function AssignBarStateHandler(bar)

	local stateConditions = BuildStateFromStates(bar.config.states);
	RegisterStateDriver(bar, "state", stateConditions);
	bar:SetAttribute("stateConditions", stateConditions);

	local stateHandler = [[
			local stateConditions = self:GetAttribute("stateConditions");
			local result, target = SecureCmdOptionParse(stateConditions);
			
			
			if(not target)  then
				target = "target";
			end
			newstate = gsub(newstate, "-.*", "");
			self:SetAttribute("unit", target);
			self:ChildUpdate("state", newstate);
		]]
	bar:SetAttribute("_onstate-state", stateHandler);
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
		bar.buttons = {};
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
	if(msqGroup) then
		msqGroup:ReSkin();
	end
end

-- If a labtype or labaction attribute then set the appropriate config.
local function OnButtonAttributeChanged(button, name, value)
	local _,_,target, state = string.find(name,"^lab([%a]+)-([%a%d]+)$");
	if(state and target) then
		local config = button[addonName .. "config"];

		if (not config.states[state]) then
			config.states[state] = {type = "empty", action = 0};
		end

		local state = config.states[state];
		state[target] = value;
	end
end

function addon:GenerateButtons(bar)
	local config = bar.config;

	local buttonConfigs = config.buttons;
	local previousButton = nil;
	local firstButton = nil;
	for index, buttonConfig in ipairs(buttonConfigs) do
		local buttonName = bar:GetName() .. "_Button" .. index;
		local button = LibActionButton:CreateButton(buttonName, buttonName, bar, buttonConfig.labConfig);
		button:HookScript("OnAttributeChanged", OnButtonAttributeChanged);

		button[addonName .. "config"]= buttonConfig;

		for state, values in pairs(buttonConfig.states) do
			button:SetState(state, values.type, values.action);
		end

		--		if(buttonConfig.states.default.type == "empty" and buttonConfig.states.default.action == 0) then
		--			button:SetState("default", "action", index);
		--		end

		if(previousButton) then
			button:SetPoint("TOPLEFT", previousButton, "TOPRIGHT", 2, 0);
		else
			button:SetPoint("TOPLEFT");
		end

		if(not firstButton) then
			firstButton = button
		end
		self:ConfigureButton(button);
		previousButton = button;
		bar.buttons[index] = button;
	end
	bar:SetWidth(previousButton:GetRight() - firstButton:GetLeft());
end

function addon:ConfigureButton(button)
	local config = button[addonName .. "config"];
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


