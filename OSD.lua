-- Author      : Lyrael
-- Create Date : 2012/12/15 08:31 AM

-- Working functionality:
--
-- Pending Functionality:

local addon = Lyranthe;


-- ========================================================================================================================================================================
-- OSD Related stuff here.
-- ========================================================================================================================================================================

local function AssignOSDStateHandler(osd)
	for _, fTarget in ipairs({"mouseover", "focus", "target", "targettarget"}) do
		RegisterStateDriver(osd, fTarget, "[@" .. fTarget .. ", exists, dead, help]rez;[@" .. fTarget .. ", help, nodead]help;[@" .. fTarget .. ", harm, nodead]harm;[@" .. fTarget .. ",dead]dead;none");
		osd:SetAttribute("state-" .. fTarget, "none");
		local stateHandler = [[
			self:ChildUpdate(stateid, newstate);
		]]
		osd:SetAttribute("_onstate-" .. fTarget, stateHandler);
	end
end

function addon:SetupOSD(osd)

	AssignOSDStateHandler(osd);

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




