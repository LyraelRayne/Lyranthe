-- Author      : CyberWitch
-- Create Date : 9/28/2009 4:56:43 PM

-- Working functionality:
--
-- Pending Functionality:

CyberMacroButtons = LibStub("AceAddon-3.0"):NewAddon("CyberMacroButtons", "AceConsole-3.0", "AceEvent-3.0");
local LAB = LibStub("LibActionButton-1.0");

function CyberMacroButtons:OnInitialize()
	self:InitConfig();

	-- Register for events
	self:RegisterEvents();



	--RegisterStateDriver(State_Display, "mouseover", "[@mouseover, exists, dead, help]rez;[@mouseover, help, nodead]help;[@mouseover, harm, nodead]harm;[@mouseover,dead]dead;none");
	--RegisterStateDriver(State_Display, "focus", "[@focus, exists, dead, help]rez;[@focus, help,nodead]help;[@focus, harm, nodead]harm;[@focus,dead]dead;none");
	--RegisterStateDriver(State_Display, "target", "[@target, exists, dead, help]rez;[@target, help,nodead]help;[@target, harm, nodead]harm;[@target, dead]dead;none");
	--RegisterStateDriver(State_Display, "targettarget", "[@target, exists, dead, help]rez;[@target, help, nodead]help;[@target, harm, nodead]harm;[@target, dead]dead;none");

	for _, fTarget in ipairs({"mouseover", "focus", "target", "targettarget"}) do
		RegisterStateDriver(State_Display, fTarget, "[@" .. fTarget .. ", exists, dead, help]rez;[@" .. fTarget .. ", help, nodead]help;[@" .. fTarget .. ", harm, nodead]harm;[@" .. fTarget .. ",dead]dead;none");
		State_Display:SetAttribute("state-" .. fTarget, "none");
		local stateHandler = [[
			self:ChildUpdate(stateid, newstate);
		]]
		State_Display:SetAttribute("_onstate-" .. fTarget, stateHandler);
	end



	local testButton = LAB:CreateButton("a1b1", "CyberMacroButtons_Bar1_Button1", State_Display);
	testButton:SetState("help", "spell", 1064);
	testButton:SetState("harm", "spell", 8042);
	testButton:SetState("rez", "spell", 8042);
	testButton:SetState("dead", "spell", 8042);
	testButton:SetState("none", "spell", 8042);
	testButton:UpdateState("none");
	testButton:SetPoint("TOPLEFT", State_Display, "BOTTOMLEFT");
	testButton:SetHeight(100);
	testButton:SetWidth(100);
	testButton:Show();

	local targetHandler = [[
		self:RunAttribute("UpdateState", message);
		self:CallMethod("UpdateAction");
	]]

	testButton:SetAttribute("_childupdate-target", targetHandler);


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




function CyberMacroButtons:RegisterEvents()
-- self:RegisterEvent("AN_EVENT", "A_HANDLER");
end

function CyberMacroButtons:InitConfig()

end

function CyberMacroButtons:SlashTest(args)
	self:DebugPrint("Test command executed!");
end



