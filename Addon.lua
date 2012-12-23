-- Author      : Lyrael
-- Create Date : 2012/12/15 08:31 AM

-- Working functionality:
--
-- Pending Functionality:

local addonName = "Lyranthe";
Lyranthe = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0");
local addon = Lyranthe;

addon.BAR_GROUP_TEMPLATE = "LyrantheButtonBarGroup";
addon.BAR_TEMPLATE = "LyrantheButtonBar";
addon.BUTTON_TEMPLATE = "LyrantheButton";
addon.BUTTON_SIDE_LENGTH = 38;



local LibKeyBound = LibStub("LibKeyBound-1.0");
local LibActionButton = LibStub("LibActionButton-1.0");
local Masque = LibStub("Masque", true);

addon.groups = {};

function addon:OnInitialize()
	self:InitConfig();

	-- Register for events
	self:RegisterEvents();

	-- Always good to know that it worked ;)
	self:Print("Lyranthe Initialized");

end


function addon:OnEnable(first)

	self:GenerateGroups();
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
	print(stateString);
	return stateString;
end

local function AssignBarStateHandler(bar)

	local state = BuildStateFromStates(bar.config.states);
	RegisterStateDriver(bar, "state", state);

	local stateHandler = [[
			-- local message = format("%s-%s", stateid, newstate);
			self:ChildUpdate("state", newstate);
		]]
	bar:SetAttribute("_onstate-state", stateHandler);
	bar:SetAttribute("state-state", "default");
end

function addon:GenerateGroups()
	local profile = addon.configDB.profile;
	for index, groupConfig in ipairs(profile.groups) do
		local groupName = groupConfig.name;
		local groupFrameName = self:GetName() .. "_" .. groupName;
		local group = _G[groupFrameName];
		if(not group) then
			self:Print("Creating frame " .. groupFrameName);
			group = CreateFrame("Frame", groupFrameName, UIParent, self.BAR_GROUP_TEMPLATE);
		end
		group:SetWidth(500);
		group:SetHeight(self.BUTTON_SIDE_LENGTH * getn(groupConfig.bars));
		group.config = groupConfig;
		group:SetPoint(groupConfig.anchorPoint, groupConfig.relativeTo, groupConfig.relativePoint, groupConfig.xOffset, groupConfig.yOffset);
		self.groups[groupName] = group;
		group.bars = {};
		self:GenerateBars(group);
		group:Show();
	end
end

function addon:GenerateBars(group)
	local barConfigs = group.config.bars;
	local previousBar = nil;
	for index, barConfig in ipairs(barConfigs) do
		local barName = barConfig.name;
		local barFrameName = group:GetName() .. "_Bar" .. index;
		local bar = _G[barFrameName];
		if(not bar) then
			bar = CreateFrame("Frame", barFrameName, group, self.BAR_TEMPLATE);
		end
		bar:SetParent(group);
		if(previousBar) then
			bar:SetPoint("TOPLEFT", previousBar, "BOTTOMLEFT", 0, 2);
		else
			bar:SetPoint("TOPLEFT");
		end
		previousBar = bar;
		group:SetHeight(self.BUTTON_SIDE_LENGTH);

		bar.config = barConfig;
		group.bars[index] = bar;
		bar.buttons = {};
		self:GenerateButtons(bar);
		self:SetupMasque(bar);
		AssignBarStateHandler(bar);
		bar:SetWidth(getn(barConfig.buttons) * (self.BUTTON_SIDE_LENGTH + 2));
	end

end

function addon:SetupMasque(bar)
	local msqGroup = nil;
	if(Masque) then
		msqGroup = Masque:Group(self:GetName(), bar:GetName());
	end

	local buttons = bar.buttons;
	for _,button in ipairs(buttons) do
		if(msqGroup) then
			button:AddToMasque(msqGroup);
		end
	end
end

-- If a labtype or labaction attribute then set the appropriate config.
local function OnButtonAttributeChanged(button, name, value)

	local _,_,target, state = string.find(name,"^lab([%a]+)-([%a%d]+)$");
	if(state and target) then
		addon:Print(state);
		addon:Print(target);
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
	for index, buttonConfig in ipairs(buttonConfigs) do
		local buttonName = bar:GetName() .. "_Button" .. index;
		local button = LibActionButton:CreateButton(buttonName, buttonName, bar, buttonConfig.labConfig);
		button:HookScript("OnAttributeChanged", OnButtonAttributeChanged);

		--		button:SetAttribute("_childupdate-state", [[
		--			local unit, state = strsplit("-", message, 2);
		--			print(message);
		--			local confMode = ((not PlayerInCombat()) and self:GetAttribute("confmode")) or false;
		--
		--			if((confMode or UnitExists(unit)) and self:GetAttribute("labtype-%s", state)) then
		--				print("Conf: " .. tostring(confMode));
		--				--state = "default";
		--				--unit = nil;
		--				print(format("Unit: " .. tostring(unit) .. "\n State:" .. tostring(state)));
		--				self:SetAttribute("unit", unit);
		--				self:RunAttribute("UpdateState", state);
		--				self:CallMethod("UpdateAction");
		--			end
		--
		--		]])
		button:SetParent(bar);
		button[addonName .. "config"]= buttonConfig;
		button:SetState("default", "action", index);
		for state, values in pairs(buttonConfig.states) do
			button:SetState(state, values.type, values.action);
		end

		if(previousButton) then
			button:SetPoint("TOPLEFT", previousButton, "TOPRIGHT", 2, 0);
		else
			button:SetPoint("TOPLEFT");
		end
		self:ConfigureButton(button);
		previousButton = button;
		bar.buttons[index] = button;
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


