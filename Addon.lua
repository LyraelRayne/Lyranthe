-- Author      : CyberWitch
-- Create Date : 9/28/2009 4:56:43 PM

-- Working functionality:
--
-- Pending Functionality:

CyberMacroButtons = LibStub("AceAddon-3.0"):NewAddon("CyberMacroButtons", "AceConsole-3.0", "AceEvent-3.0");

local addon = CyberMacroButtons;
local LibKeyBound = LibStub("LibKeyBound-1.0");
local MSQ = LibStub("Masque");
local msqGroup = MSQ:Group("CyberMacroButtons", "CyberMacroButtons-Bar1");

function addon:OnInitialize()
	self:InitConfig();

	-- Register for events
	self:RegisterEvents();

	



	-- Always good to know that it worked ;)
	self:Print("CyberMacroButtons Initialized");
end


function addon:OnEnable(first)
--	LibKeyBound.RegisterCallback(self, "LIBKEYBOUND_ENABLED")
--	LibKeyBound.RegisterCallback(self, "LIBKEYBOUND_DISABLED")
--	LibKeyBound.RegisterCallback(self, "LIBKEYBOUND_MODE_COLOR_CHANGED")
end


function addon:RegisterEvents()
-- self:RegisterEvent("AN_EVENT", "A_HANDLER");
	self:RegisterEvent("ADDON_LOADED");
end

function addon:ADDON_LOADED()
	self:SetupOSD(State_Display);
end

function addon:InitConfig()
end


--function CyberMacroButtons:LIBKEYBOUND_ENABLED()
--end
--
--function CyberMacroButtons:LIBKEYBOUND_DISABLED()
--
--end
--
--function CyberMacroButtons:LIBKEYBOUND_MODE_COLOR_CHANGED()
--
--end

function addon:SetupOSD(osd)

	self:AssignStateHandler(osd);

	osd:HookScript("OnAttributeChanged",
	function(self,name,value)
		if(name == "state-mouseover") then
			osd.mStateText:SetText("m:" .. value);
		elseif(name == "state-focus") then
			osd.fStateText:SetText("f:" .. value);
		elseif(name == "state-target") then
			osd.tStateText:SetText("t:" .. value);
		elseif(name == "state-targettarget") then
			osd.ttStateText:SetText("tt:" .. value);
		end
	end);
end

function addon:AssignStateHandler(osd)
	for _, fTarget in ipairs({"mouseover", "focus", "target", "targettarget"}) do
		RegisterStateDriver(osd, fTarget, "[@" .. fTarget .. ", exists, dead, help]rez;[@" .. fTarget .. ", help, nodead]help;[@" .. fTarget .. ", harm, nodead]harm;[@" .. fTarget .. ",dead]dead;none");
		osd:SetAttribute("state-" .. fTarget, "none");
		local stateHandler = [[
			self:ChildUpdate(stateid, newstate);
		]]
		osd:SetAttribute("_onstate-" .. fTarget, stateHandler);
	end
end


-- Adds button prototype functions to the metatable index, essentially "mixing in" the prototype methods.
function CyberMacroButtonsSetButtonMeta(button)
	local meta = getmetatable(button);
	if(meta == nil) then
		meta = {};
		meta.__index = {};
	elseif(meta.__index == nil) then
		meta.__index = {};
	end
	
	local theIndex = meta.__index;
	for key,value in pairs(addon.ActionButtonPrototype) do
		if(key ~= nil) then
			theIndex[key] = value;
		end
	end
	setmetatable(button, meta);
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
