-- Author      : CyberWitch
-- Create Date : 9/28/2009 4:56:43 PM

-- Working functionality:
--
-- Pending Functionality:

CyberMacroButtons = LibStub("AceAddon-3.0"):NewAddon("CyberMacroButtons", "AceConsole-3.0", "AceEvent-3.0");

local CMB = CyberMacroButtons;
local LibKeyBound = LibStub("LibKeyBound-1.0")

function CyberMacroButtons:OnInitialize()
	self:InitConfig();

	-- Register for events
	self:RegisterEvents();

	for _, fTarget in ipairs({"mouseover", "focus", "target", "targettarget"}) do
		RegisterStateDriver(State_Display, fTarget, "[@" .. fTarget .. ", exists, dead, help]rez;[@" .. fTarget .. ", help, nodead]help;[@" .. fTarget .. ", harm, nodead]harm;[@" .. fTarget .. ",dead]dead;none");
		State_Display:SetAttribute("state-" .. fTarget, "none");
		local stateHandler = [[
			self:ChildUpdate(stateid, newstate);
		]]
		State_Display:SetAttribute("_onstate-" .. fTarget, stateHandler);
	end


	State_Display:HookScript("OnAttributeChanged",
	function(self,name,value)
		if(name == "state-mouseover") then
			State_Display.mStateText:SetText("m:" .. value);
		elseif(name == "state-focus") then
			State_Display.fStateText:SetText("f:" .. value);
		elseif(name == "state-target") then
			State_Display.tStateText:SetText("t:" .. value);
		elseif(name == "state-targettarget") then
			State_Display.ttStateText:SetText("tt:" .. value);
		end

	end);
	-- Always good to know that it worked ;)
	self:Print("CyberMacroButtons Initialized");
end


function CyberMacroButtons:OnEnable(first)
	LibKeyBound.RegisterCallback(self, "LIBKEYBOUND_ENABLED")
	LibKeyBound.RegisterCallback(self, "LIBKEYBOUND_DISABLED")
	LibKeyBound.RegisterCallback(self, "LIBKEYBOUND_MODE_COLOR_CHANGED")
end


function CyberMacroButtons:RegisterEvents()
-- self:RegisterEvent("AN_EVENT", "A_HANDLER");
end

function CyberMacroButtons:InitConfig()
end


function CyberMacroButtons:LIBKEYBOUND_ENABLED()
	self:Print("LIBKEYBOUND_ENABLED");
	--CyberMacroButtons:OtherModeOff()
	CyberMacroButtons.keyBoundMode = true
	--CyberMacroButtons:ColorMyMod()
end

function CyberMacroButtons:LIBKEYBOUND_DISABLED()
	self:Print("LIBKEYBOUND_DISABLED");
	CyberMacroButtons.keyBoundMode = nil
	--CyberMacroButtons:ColorMyMod()
end

function CyberMacroButtons:LIBKEYBOUND_MODE_COLOR_CHANGED()
	self:Print("LIBKEYBOUND_MODE_COLOR_CHANGED");
	--CyberMacroButtons:ColorMyMod()
end


