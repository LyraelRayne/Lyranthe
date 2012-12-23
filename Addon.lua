-- Author      : Lyrael
-- Create Date : 2012/12/15 08:31 AM

-- Working functionality:
--
-- Pending Functionality:

local addonName = "Lyranthe";
Lyranthe = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0");
local addon = Lyranthe;

addon.GROUP_TEMPLATE = "LyrantheButtonGroup";
addon.ROW_TEMPLATE = "LyrantheButtonGroupRow";
addon.BUTTON_TEMPLATE = "LyrantheButton";
addon.ROW_HEIGHT = 38;


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

local function AssignGroupStateHandler(group)

	local state = BuildStateFromStates(group.config.states);
	RegisterStateDriver(group, "state", state);

	local stateHandler = [[
			-- local message = format("%s-%s", stateid, newstate);
			self:ChildUpdate("state", newstate);
		]]
	group:SetAttribute("_onstate-state", stateHandler);
	group:SetAttribute("state-state", "default");
end

function addon:GenerateGroups()
	local profile = addon.configDB.profile;

	for index, groupConfig in ipairs(profile.groups) do
		local groupName = groupConfig.name;
		local groupFrameName = self:GetName() .. "_" .. groupName;
		local group = _G[groupFrameName];
		if(not group) then
			group = CreateFrame("Frame", groupFrameName, UIParent, self.GROUP_TEMPLATE);
		end
		group:SetPoint(groupConfig.anchorPoint, groupConfig.relativeTo, groupConfig.relativePoint, groupConfig.xOffset, groupConfig.yOffset);
		group.config = groupConfig;
		self.groups[groupName] = group;
		self:GenerateRows(group);
		self:SetupMasque(group);
		AssignGroupStateHandler(group);
		group:Show();
	end

end

function addon:SetupMasque(group)
	local config = group.config;
	local msqGroup = nil;
	if(Masque) then
		msqGroup = Masque:Group(self:GetName(), config.name);
	end

	local buttons = {group:GetChildren()};
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

function addon:GenerateRows(group)
	local groupConfig = group.config;
	local groupName = group:GetName();

	local rowConfigs = groupConfig.rows;

	for rowNum, config in ipairs(rowConfigs) do
		local rowName = groupName .. "_Row" .. rowNum;
		local row = CreateFrame("Frame", rowName, group, self.ROW_TEMPLATE);
		row:SetPoint("LEFT");
		row:SetPoint("RIGHT");
		row:SetPoint("TOP", group, "TOP", 0, -addon.ROW_HEIGHT * (rowNum - 1));
		row:SetHeight(addon.ROW_HEIGHT);
		row.config = config;
		self:GenerateButtons(group, row);
	end
end

function addon:GenerateButtons(group, row)
	local rowConfig = row.config;
	local groupConfig = group.config;

	local buttonConfigs = config.buttons;
	local lastbutton = nil;
	for index, buttonConfig in ipairs(buttonConfigs) do
		local buttonName = group:GetName() .. "_Button" .. index;
		local button = LibActionButton:CreateButton(buttonName, buttonName, group, buttonConfig.labConfig);
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
		button[addonName .. "config"]= buttonConfig;
		button:SetState("default", "action", index);
		for state, values in pairs(buttonConfig.states) do
			button:SetState(state, values.type, values.action);
		end

		if(lastButton) then
			button:SetPoint("TOPLEFT", lastButton, "TOPRIGHT", 2, 0);
		else
			button:SetPoint("TOPLEFT", row);
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


