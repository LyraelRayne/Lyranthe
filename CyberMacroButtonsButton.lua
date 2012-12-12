-- Author      : CyberWitch
-- Create Date : 2012/12/08 4:56:43 PM
-- Working functionality:
--
-- Pending Functionality:

local addon = CyberMacroButtons;

addon.ButtonPrototype = {};
local Button = addon.ButtonPrototype;

local NUM_ACTIONBAR_BUTTONS = 12;
local ATTACK_BUTTON_FLASH_TIME = 0.4;
local RANGE_INDICATOR = "●";

local LibKeyBound = LibStub("LibKeyBound-1.0")


function CyberMacrosAssignStateHandler(self)
	for _, fTarget in ipairs({"mouseover", "focus", "target", "targettarget"}) do
		RegisterStateDriver(self, fTarget, "[@" .. fTarget .. ", exists, dead, help]rez;[@" .. fTarget .. ", help, nodead]help;[@" .. fTarget .. ", harm, nodead]harm;[@" .. fTarget .. ",dead]dead;none");
		self:SetAttribute("state-" .. fTarget, "none");
		local stateHandler = [[
			self:ChildUpdate(stateid, newstate);
		]]
		self:SetAttribute("_onstate-" .. fTarget, stateHandler);
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
	-- Button = the prototype. As opposed to button, the actual button.
	local theIndex = meta.__index;
	for key,value in pairs(Button) do
		if(key ~= nil) then
			theIndex[key] = value;
		end
	end
	setmetatable(button, meta);
end

function Button:OnLoad()

	--	local targetHandler = [[
	--		print(scriptid);
	--		print(message);
	--	]]
	--
	--	self:SetAttribute("_childupdate-target", targetHandler);

	self.flashing = 0;
	self.flashtime = 0;
	self:SetAttribute("showgrid", 1);
	self:SetAttribute("type", "action");
	self:SetAttribute("checkselfcast", true);
	self:SetAttribute("checkfocuscast", true);
	self:SetAttribute("useparent-unit", true);
	self:RegisterForDrag("LeftButton", "RightButton");
	self:RegisterForClicks("AnyUp");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("ACTIONBAR_SHOWGRID");
	self:RegisterEvent("ACTIONBAR_HIDEGRID");
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:UpdateHotkeys();
end

function Button:UpdateHotkeys ()
	local hotkey = _G[self:GetName().."HotKey"];
	local key = self:GetHotkey();

	local text = GetBindingText(key, "KEY_", 1);
	if ( text == "" ) then
		hotkey:SetText(RANGE_INDICATOR);
		hotkey:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -2);
		hotkey:Hide();
	else
		hotkey:SetText(text);
		hotkey:SetPoint("TOPLEFT", self, "TOPLEFT", -2, -2);
		hotkey:Show();
	end
end




-- TODO This needs to be sorted out to work with spell/macro/whatever instead of action buttons.
function Button:CalculateAction (pressedButton)
	if ( not pressedButton ) then
		-- This is the default returned by SecureButton_GetEffectiveButton anyways.
		-- Check to see if they eventually implement it and what it does
		--  but the feature isn't important at this time anyway.
		button = "LeftButton";
	end

	return SecureButton_GetModifiedAttribute(self, "action", pressedButton) or 1;
end


-- TODO This needs to be sorted out to work with spell/macro/whatever instead of action buttons.
-- Currently does nothing.
function Button:UpdateAction()
	local action = self:CalculateAction();

	if ( action ~= self.action ) then
		-- We don't use this variable but for some reason on clicking a flyout
		-- the secure action button template checks self.action.
		self.action = action;
		self:Update();
	end
end


function Button:HasValidAction()
	local type = SecureButton_GetModifiedAttribute(self, "type", "LeftButton");
	if(type == "action") then
		return HasAction(self.action);
	elseif(type == "spell") then
		local spell = SecureButton_GetModifiedAttribute(self, "spell", "LeftButton");
		return (spell);
	else
		return nil;
	end
end



-- TODO Make it use the texture of the proper (advanced) action;
function Button:GetActionTexture()
	local type = SecureButton_GetModifiedAttribute(self, "type", "LeftButton");
	if(type == "spell") then
		local spell = SecureButton_GetModifiedAttribute(self, "spell", "LeftButton");
		local texture = GetSpellTexture(spell);
		return texture;
	elseif(type == "action") then
		return GetActionTexture(self.action)
	else
		return nil;
	end
end

function Button:Update ()
	local name = self:GetName();

	local action = self.action;
	local icon = _G[name.."Icon"];
	local buttonCooldown = _G[name.."Cooldown"];

	local texture = self:GetActionTexture();

	if ( self:HasValidAction() ) then
		if ( not self.eventsRegistered ) then
			self:RegisterEvent("ACTIONBAR_UPDATE_STATE");
			self:RegisterEvent("ACTIONBAR_UPDATE_USABLE");
			self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
			self:RegisterEvent("UPDATE_INVENTORY_ALERTS");
			self:RegisterEvent("PLAYER_TARGET_CHANGED");
			self:RegisterEvent("TRADE_SKILL_SHOW");
			self:RegisterEvent("TRADE_SKILL_CLOSE");
			self:RegisterEvent("ARCHAEOLOGY_CLOSED");
			self:RegisterEvent("PLAYER_ENTER_COMBAT");
			self:RegisterEvent("PLAYER_LEAVE_COMBAT");
			self:RegisterEvent("START_AUTOREPEAT_SPELL");
			self:RegisterEvent("STOP_AUTOREPEAT_SPELL");
			self:RegisterEvent("UNIT_ENTERED_VEHICLE");
			self:RegisterEvent("UNIT_EXITED_VEHICLE");
			self:RegisterEvent("COMPANION_UPDATE");
			self:RegisterEvent("UNIT_INVENTORY_CHANGED");
			self:RegisterEvent("LEARNED_SPELL_IN_TAB");
			self:RegisterEvent("PET_STABLE_UPDATE");
			self:RegisterEvent("PET_STABLE_SHOW");
			self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW");
			self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE");
			self.eventsRegistered = true;
		end

		-- This appears to be running in combat causing taint
		-- TODO replace this with a secure showhide handler.
		--if ( not self:GetAttribute("statehidden") ) then
		--	self:Show();
		-- end
		self:UpdateState();
		self:UpdateUsable();
		self:UpdateCooldown();
		self:UpdateFlash();
	else
		if ( self.eventsRegistered ) then
			self:UnregisterEvent("ACTIONBAR_UPDATE_STATE");
			self:UnregisterEvent("ACTIONBAR_UPDATE_USABLE");
			self:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
			self:UnregisterEvent("UPDATE_INVENTORY_ALERTS");
			self:UnregisterEvent("PLAYER_TARGET_CHANGED");
			self:UnregisterEvent("TRADE_SKILL_SHOW");
			self:UnregisterEvent("ARCHAEOLOGY_CLOSED");
			self:UnregisterEvent("TRADE_SKILL_CLOSE");
			self:UnregisterEvent("PLAYER_ENTER_COMBAT");
			self:UnregisterEvent("PLAYER_LEAVE_COMBAT");
			self:UnregisterEvent("START_AUTOREPEAT_SPELL");
			self:UnregisterEvent("STOP_AUTOREPEAT_SPELL");
			self:UnregisterEvent("UNIT_ENTERED_VEHICLE");
			self:UnregisterEvent("UNIT_EXITED_VEHICLE");
			self:UnregisterEvent("COMPANION_UPDATE");
			self:UnregisterEvent("UNIT_INVENTORY_CHANGED");
			self:UnregisterEvent("LEARNED_SPELL_IN_TAB");
			self:UnregisterEvent("PET_STABLE_UPDATE");
			self:UnregisterEvent("PET_STABLE_SHOW");
			self:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW");
			self:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE");
			self.eventsRegistered = nil;
		end

		if ( self:GetAttribute("showgrid") == 0 ) then
			self:Hide();
		else
			buttonCooldown:Hide();
		end
	end

	-- Add a green border if button is an equipped item
	local border = _G[name.."Border"];
	if ( IsEquippedAction(action) ) then
		border:SetVertexColor(0, 1.0, 0, 0.35);
		border:Show();
	else
		border:Hide();
	end

	-- Update Action Text
	local actionName = _G[name.."Name"];
	if ( not IsConsumableAction(action) and not IsStackableAction(action) ) then
		actionName:SetText(GetActionText(action));
	else
		actionName:SetText("");
	end

	-- Update icon and hotkey text
	if ( texture ) then
		icon:SetTexture(texture);
		icon:Show();
		self.rangeTimer = -1;
		self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2");
	else
		icon:Hide();
		buttonCooldown:Hide();
		self.rangeTimer = nil;
		self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot");
		local hotkey = _G[name.."HotKey"];
		if ( hotkey:GetText() == RANGE_INDICATOR ) then
			hotkey:Hide();
		else
			hotkey:SetVertexColor(0.6, 0.6, 0.6);
		end
	end
	self:UpdateCount();

	-- Update flyout appearance
	self:UpdateFlyout();

	self:UpdateOverlayGlow();

	-- Update tooltip
	if ( GameTooltip:GetOwner() == self ) then
		self:SetTooltip();
	end

	self.feedback_action = action;
end

function Button:ShowGrid ()
	assert(self);

	if ( issecure() ) then
		self:SetAttribute("showgrid", self:GetAttribute("showgrid") + 1);
	end

	_G[self:GetName().."NormalTexture"]:SetVertexColor(1.0, 1.0, 1.0, 0.5);

	if ( self:GetAttribute("showgrid") >= 1 and not self:GetAttribute("statehidden") ) then
		self:Show();
	end
end

function Button:HideGrid ()

	local showgrid = self:GetAttribute("showgrid");

	if ( issecure() ) then
		if ( showgrid > 0 ) then
			self:SetAttribute("showgrid", showgrid - 1);
		end
	end

	if ( self:GetAttribute("showgrid") == 0 and not HasAction(self.action) ) then
		self:Hide();
	end
end

function Button:UpdateState ()
	local type = SecureButton_GetModifiedAttribute(self, "type", "LeftButton");
	if(type == "action") then
		local action = self.action;
		if ( IsCurrentAction(action) or IsAutoRepeatAction(action) ) then
			self:SetChecked(1);
		else
			self:SetChecked(0);
		end
	elseif(type == "spell") then
		local spell =  SecureButton_GetModifiedAttribute(self, "spell", "LeftButton");
		if ( IsCurrentSpell(spell) or IsAutoRepeatSpell(spell) ) then
			self:SetChecked(1);
		else
			self:SetChecked(0);
		end
	end
end

function Button:UpdateUsable ()
	local name = self:GetName();
	local icon = _G[name.."Icon"];
	local normalTexture = _G[name.."NormalTexture"];
	local type = SecureButton_GetModifiedAttribute(self, "type", "LeftButton");
	local isUsable, notEnoughMana;
	if(type == "action") then
		isUsable, notEnoughMana = IsUsableAction(self.action);
	elseif(type == "spell") then
		local spell = SecureButton_GetModifiedAttribute(self, "spell", "LeftButton");
		isUsable, notEnoughMana = IsUsableSpell(spell);
	end
	if ( isUsable ) then
		icon:SetVertexColor(1.0, 1.0, 1.0);
		normalTexture:SetVertexColor(1.0, 1.0, 1.0);
	elseif ( notEnoughMana ) then
		icon:SetVertexColor(0.5, 0.5, 1.0);
		normalTexture:SetVertexColor(0.5, 0.5, 1.0);
	else
		icon:SetVertexColor(0.4, 0.4, 0.4);
		normalTexture:SetVertexColor(1.0, 1.0, 1.0);
	end

end

function Button:UpdateCount ()
	local text = _G[self:GetName().."Count"];
	local action = self.action;
	if ( IsConsumableAction(action) or IsStackableAction(action) ) then
		local count = GetActionCount(action);
		if ( count > (self.maxDisplayCount or 9999 ) ) then
			text:SetText("*");
		else
			text:SetText(count);
		end
	else
		text:SetText("");
	end
end

function Button:UpdateCooldown ()
	local cooldown = _G[self:GetName().."Cooldown"];
	local type = SecureButton_GetModifiedAttribute(self, "type", "LeftButton");
	local start, duration, enable;
	if(type == "action") then
		start, duration, enable = GetActionCooldown(self.action);
	elseif(type == "spell") then
		local spell = SecureButton_GetModifiedAttribute(self, "spell", "LeftButton");
		start, duration, enable = GetSpellCooldown(spell);
	end

	CooldownFrame_SetTimer(cooldown, start, duration, enable);
end

--Overlay stuff
local unusedOverlayGlows = {};
local numOverlays = 0;
function Button:GetOverlayGlow()
	local overlay = tremove(unusedOverlayGlows);
	if ( not overlay ) then
		numOverlays = numOverlays + 1;
		overlay = CreateFrame("Frame", "ActionButtonOverlay"..numOverlays, UIParent, "ActionBarButtonSpellActivationAlert");
	end
	return overlay;
end

function Button:UpdateOverlayGlow()
	local type = SecureButton_GetModifiedAttribute(self, "type", "LeftButton");
	if(type == "action") then
		local spellType, id, subType  = GetActionInfo(self.action);
		if ( spellType == "spell" and IsSpellOverlayed(id) ) then
			self:ShowOverlayGlow();
		else
			self:HideOverlayGlow();
		end
	elseif (type == "spell") then
		local spell = SecureButton_GetModifiedAttribute(self, "spell", "LeftButton");
		if(IsSpellOverlayed(spell)) then
			self:ShowOverlayGlow();
		else
			self:HideOverlayGlow();
		end
	end
end

function Button:ShowOverlayGlow()
	if ( self.overlay ) then
		if ( self.overlay.animOut:IsPlaying() ) then
			self.overlay.animOut:Stop();
			self.overlay.animIn:Play();
		end
	else
		self.overlay = self:GetOverlayGlow();
		local frameWidth, frameHeight = self:GetSize();
		self.overlay:SetParent(self);
		self.overlay:ClearAllPoints();
		self.overlay:SetPoint("TOPLEFT", self, "TOPLEFT", -frameWidth * 0.2, frameHeight * 0.2);
		self.overlay:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", frameWidth * 0.2, -frameHeight * 0.2);
		self.overlay.animIn:Play();
	end
end

function Button:HideOverlayGlow()
	if ( self.overlay ) then
		if ( self.overlay.animIn:IsPlaying() ) then
			self.overlay.animIn:Stop();
		end
		if ( self:IsVisible() ) then
			self.overlay.animOut:Play();
		else
			self:OverlayGlowAnimOutFinished(self.overlay.animOut);	--We aren't shown anyway, so we'll instantly hide it.
		end
	end
end

function Button:OverlayGlowAnimOutFinished(animGroup)
	local overlay = animGroup:GetParent();
	local actionButton = overlay:GetParent();
	overlay:Hide();
	tinsert(unusedOverlayGlows, overlay);
	actionButton.overlay = nil;
end

function Button:OnEvent ( event, ...)
	local arg1 = ...;
	-- Update tooltips and item counts when inventory/spellbook changes.
	if ((event == "UNIT_INVENTORY_CHANGED" and arg1 == "player") or event == "LEARNED_SPELL_IN_TAB") then
		if ( GameTooltip:GetOwner() == self ) then
			self:SetTooltip();
		end
	end
	if ( event == "ACTIONBAR_SLOT_CHANGED" ) then
		if ( arg1 == 0 or arg1 == tonumber(self.action) ) then
			self:Update();
		end
		return;
	end

	-- need to listen for UPDATE_SHAPESHIFT_FORM because attack icons change when the shapeshift form changes
	if ( event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_SHAPESHIFT_FORM" ) then
		self:Update();
		return;
	end
	-- Do we actually want paging support? Suspect not but here it is.
	if ( event == "ACTIONBAR_PAGE_CHANGED" or event == "UPDATE_BONUS_ACTIONBAR" ) then
		self:UpdateAction();
		local actionType, id, subType = GetActionInfo(self.action);
		if ( actionType == "spell" and id == 0 ) then
			self:HideOverlayGlow();
		end
		return;
	end
	if ( event == "ACTIONBAR_SHOWGRID" ) then
		self:ShowGrid();
		return;
	end
	if ( event == "ACTIONBAR_HIDEGRID" ) then
		self:HideGrid();
		return;
	end
	if ( event == "UPDATE_BINDINGS" ) then
		self:UpdateHotkeys( self.buttonType);
		return;
	end

	-- All event handlers below this line are only set when the button has an action

	if ( event == "PLAYER_TARGET_CHANGED" ) then
		self.rangeTimer = -1;
	elseif ( (event == "ACTIONBAR_UPDATE_STATE") or
	((event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE") and (arg1 == "player")) or
	((event == "COMPANION_UPDATE") and (arg1 == "MOUNT")) ) then
		self:UpdateState();
	elseif ( event == "ACTIONBAR_UPDATE_USABLE" ) then
		self:UpdateUsable();
	elseif ( event == "ACTIONBAR_UPDATE_COOLDOWN" ) then
		self:UpdateCooldown();
	elseif ( event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE"  or event == "ARCHAEOLOGY_CLOSED" ) then
		self:UpdateState();
	elseif ( event == "PLAYER_ENTER_COMBAT" ) then
		if ( IsAttackAction(self.action) ) then
			self:StartFlash();
		end
	elseif ( event == "PLAYER_LEAVE_COMBAT" ) then
		if ( IsAttackAction(self.action) ) then
			self:StopFlash();
		end
	elseif ( event == "START_AUTOREPEAT_SPELL" ) then
		if ( IsAutoRepeatAction(self.action) ) then
			self:StartFlash();
		end
	elseif ( event == "STOP_AUTOREPEAT_SPELL" ) then
		if ( self:IsFlashing() and not IsAttackAction(self.action) ) then
			self:StopFlash();
		end
	elseif ( event == "PET_STABLE_UPDATE" or event == "PET_STABLE_SHOW") then
		-- Has to update everything for now, but this event should happen infrequently
		self:Update();
	elseif ( event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" ) then
		self:UpdateOverlayGlow();
	elseif ( event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" ) then
		self:UpdateOverlayGlow();
	end
end

function Button:SetTooltip ()
	if ( GetCVar("UberTooltips") == "1" ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
	else
		local parent = self:GetParent();
		if ( parent == MultiBarBottomRight or parent == MultiBarRight or parent == MultiBarLeft ) then
			GameTooltip:SetOwner( "ANCHOR_LEFT");
		else
			GameTooltip:SetOwner( "ANCHOR_RIGHT");
		end
	end
	local type = SecureButton_GetModifiedAttribute(self, "type", "LeftButton");

	if (type == "action" ) then
		GameTooltip:SetAction(self.action)
	elseif type == "spell" then
		local spell = SecureButton_GetModifiedAttribute(self, "spell", "LeftButton");
		GameTooltip:SetSpellBookItem(addon:GetSpellBookId(spell), BOOKTYPE_SPELL)
	end
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

function Button:OnUpdate (elapsed)
	if ( self:IsFlashing() ) then
		local flashtime = self.flashtime;
		flashtime = flashtime - elapsed;

		if ( flashtime <= 0 ) then
			local overtime = -flashtime;
			if ( overtime >= ATTACK_BUTTON_FLASH_TIME ) then
				overtime = 0;
			end
			flashtime = ATTACK_BUTTON_FLASH_TIME - overtime;

			local flashTexture = _G[self:GetName().."Flash"];
			if ( flashTexture:IsShown() ) then
				flashTexture:Hide();
			else
				flashTexture:Show();
			end
		end

		self.flashtime = flashtime;
	end

	-- Handle range indicator
	local rangeTimer = self.rangeTimer;
	if ( rangeTimer ) then
		rangeTimer = rangeTimer - elapsed;

		if ( rangeTimer <= 0 ) then
			local hotKey = _G[self:GetName().."HotKey"];
			local valid = self:IsTargetInRange();
			if ( hotKey:GetText() == RANGE_INDICATOR ) then
				if ( valid == 0 ) then
					hotKey:Show();
					hotKey:SetVertexColor(1.0, 0.1, 0.1);
				elseif ( valid == 1 ) then
					hotKey:Show();
					hotKey:SetVertexColor(0.6, 0.6, 0.6);
				else
					hotKey:Hide();
				end
			else
				if ( valid == 0 ) then
					hotKey:SetVertexColor(1.0, 0.1, 0.1);
				else
					hotKey:SetVertexColor(0.6, 0.6, 0.6);
				end
			end
			rangeTimer = TOOLTIP_UPDATE_TIME;
		end

		self.rangeTimer = rangeTimer;
	end
end

function Button:IsTargetInRange()
	local type = SecureButton_GetModifiedAttribute(self, "type", "LeftButton");
	if(type == "action") then
		return IsActionInRange(self.action);
	elseif(type == "spell") then
		local spell = SecureButton_GetModifiedAttribute(self, "spell", "LeftButton");
		local unit = SecureButton_GetModifiedAttribute(self, "unit", "LeftButton");
		return IsSpellInRange(GetSpellInfo(spell), unit);
	end
end

function Button:GetPagedID ()
	return self.action;
end

function Button:UpdateFlash ()
	local action = self.action;
	if ( (IsAttackAction(action) and IsCurrentAction(action)) or IsAutoRepeatAction(action) ) then
		self:StartFlash();
	else
		self:StopFlash();
	end
end

function Button:StartFlash ()
	self.flashing = 1;
	self.flashtime = 0;
	self:UpdateState();
end

function Button:StopFlash ()
	self.flashing = 0;
	_G[self:GetName().."Flash"]:Hide();
	self:UpdateState();
end

function Button:IsFlashing ()
	if ( self.flashing == 1 ) then
		return 1;
	end

	return nil;
end

function Button:UpdateFlyout()
	local actionType = GetActionInfo(self.action);
	if (actionType == "flyout") then
		-- Update border and determine arrow position
		local arrowDistance;
		if ((SpellFlyout and SpellFlyout:IsShown() and SpellFlyout:GetParent() == self) or GetMouseFocus() == self) then
			self.FlyoutBorder:Show();
			self.FlyoutBorderShadow:Show();
			arrowDistance = 5;
		else
			self.FlyoutBorder:Hide();
			self.FlyoutBorderShadow:Hide();
			arrowDistance = 2;
		end

		-- Update arrow
		self.FlyoutArrow:Show();
		self.FlyoutArrow:ClearAllPoints();
		self.FlyoutArrow:SetPoint("TOP", self, "TOP", 0, arrowDistance);
		SetClampedTextureRotation(self.FlyoutArrow, 0);
	else
		self.FlyoutBorder:Hide();
		self.FlyoutBorderShadow:Hide();
		self.FlyoutArrow:Hide();
	end
end

---------------------------------------------------------------------------------------------------------------------------------------------------
-- LibKeyBound Handlers.
---------------------------------------------------------------------------------------------------------------------------------------------------

--  returns the current hotkey assigned to me
function Button:GetHotkey()
	return GetBindingKey("CLICK " .. self:GetName() .. ":LeftButton");
end

-- Tells LibKeyBound which key is under the mouse.
function Button:LKBOnEnter()
	if(self.GetHotkey) then
		LibKeyBound:Set(self)
	end
end