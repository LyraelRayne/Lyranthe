-- Author      : Lyrael
-- Create Date : 2012/12/08 4:56:43 PM
-- Working functionality:
-- Can use like blizz action bars.
-- Buttons which have been hacked to have a spell type instead of action will be decorated correctly AFAIK.
--
-- Pending Functionality:
-- Masque support.
-- Allow drag and drop of spells to change to a spell button rather than using action slots.
-- Multiple state and target support
-- Same features as for spell but for macro?
-- Flyouts?


local addon = Lyranthe;

local MSQ = LibStub("Masque");

addon.ButtonPrototype = {};
local Button = addon.ButtonPrototype;

local ATTACK_BUTTON_FLASH_TIME = 0.4;
local RANGE_INDICATOR = "●";

local LibKeyBound = LibStub("LibKeyBound-1.0")

local function LyrOnAttributeChanged(widget, attributeName, attributeValue)
	if(widget.UpdateAction) then
		widget:UpdateAction();
	else
		addon:Print(tostring(widget:GetName()));
	end
end

function Button:OnLoad()
	self.flashing = 0;
	self.flashtime = 0;
	self:RegisterForDrag("LeftButton", "RightButton");
	self:RegisterForClicks("AnyUp");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:UpdateHotkeys();
	self:UpdateAction();

	if ( not self:GetAttribute("statehidden") ) then
		self:Show();
	end
	if ( self:GetAttribute("showgrid") == 0 ) then
		self:Hide();
	end

	self:SetScript("OnAttributeChanged", LyrOnAttributeChanged);
end

function Button:UpdateHotkeys ()
	local hotkey = _G[self:GetName() .. "HotKey"];
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

-- TODO Needs to pick up the correct type of action.
-- May use template code instead of putting body here.
function Button:OnDragStart(button)
	if ( LOCK_ACTIONBAR ~= "1" or IsModifiedClick("PICKUPACTION") ) then
		SpellFlyout:Hide();
		PickupAction(self:GetAttribute("action"));
		self:UpdateState();
		self:UpdateFlash();
	end
end

-- TODO This needs to check the type of drag and set/use the appropriate button template
function Button:OnReceiveDrag()
	PlaceAction(self:GetAttribute("action"));
	self:UpdateState();
	self:UpdateFlash();
end

function Button:Update ()
	local name = self:GetName();

	local action = self.action;
	local icon = _G[name.."Icon"];
	local buttonCooldown = _G[name.."Cooldown"];

	local texture = self:GetActionTexture();

	if ( self:HasAction() ) then
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
		--if ( self:GetAttribute("showgrid") == 0 ) then
		--	self:Hide();
		--else
		--	buttonCooldown:Hide();
		--end

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
	end

	-- Add a green border if button is an equipped item
	local border = _G[name.."Border"];
	if ( self:IsEquippedAction() ) then
		border:SetVertexColor(0, 1.0, 0, 0.35);
		border:Show();
	else
		border:Hide();
	end

	-- Update Action Text if item doesn't have a use count.
	local actionName = _G[name.."Name"];
	if (not self:ActionHasUseCount() ) then
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


-- TODO make this simpler and not reliant on action button checks.
function Button:ShowGrid ()
	if ( issecure() ) then
		self:SetAttribute("showgrid", self:GetAttribute("showgrid") + 1);
	end

	_G[self:GetName().."NormalTexture"]:SetVertexColor(1.0, 1.0, 1.0, 0.5);

	if ( self:GetAttribute("showgrid") >= 1 and not self:GetAttribute("statehidden") ) then
		self:Show();
	end
end

-- TODO make this simpler and not reliant on action button checks.
function Button:HideGrid ()
	local showgrid = self:GetAttribute("showgrid");

	if ( issecure() ) then
		if ( showgrid > 0 ) then
			self:SetAttribute("showgrid", showgrid - 1);
		end
	end

	if ( self:GetAttribute("showgrid") == 0 and not self:HasAction() ) then
		self:Hide();
	end
end

function Button:UpdateState ()
	if ( self:IsActionBeingUsed() ) then
		self:SetChecked(1);
	else
		self:SetChecked(0);
	end
end

function Button:UpdateUsable ()
	local name = self:GetName();
	local icon = _G[name.."Icon"];
	local normalTexture = _G[name.."NormalTexture"];

	local isUsable, notEnoughMana = self:IsUsable();
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
	if ( self:ActionHasUseCount() ) then
		local count = self:GetActionUseCount();
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
	local cooldownLayer = _G[self:GetName().."Cooldown"];

	local start, duration, enable = self:GetCooldown();

	CooldownFrame_SetTimer(cooldownLayer, start, duration, enable);
end


function Button:UpdateOverlayGlow()
	local spellType, id, subType  = self:GetActionInfo();
	if ( spellType == "spell" and IsSpellOverlayed(id) ) then
		ActionButton_ShowOverlayGlow(self);
	else
		ActionButton_HideOverlayGlow(self);
	end
end

function Button:OnEvent ( event, ...)
	local arg1 = ...;
	-- Update tooltips and item counts when inventory/spellbook changes.
	if ((event == "UNIT_INVENTORY_CHANGED" and arg1 == "player") or event == "LEARNED_SPELL_IN_TAB") then
		if ( GameTooltip:GetOwner() == self ) then
			self:SetTooltip();
		end
	end

	-- TODO Make this not happen on non action buttons.
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

	elseif ( event == "PLAYER_ENTER_COMBAT" or  event == "PLAYER_LEAVE_COMBAT" or event == "START_AUTOREPEAT_SPELL" or event == "STOP_AUTOREPEAT_SPELL" ) then
		self:UpdateFlash();
	elseif ( event == "PET_STABLE_UPDATE" or event == "PET_STABLE_SHOW") then
		-- Has to update everything for now, but this event should happen infrequently
		self:Update();
	elseif ( event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" or event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" ) then
		self:UpdateOverlayGlow();
	end
end


local function UpdateFlashingAnimation(button)
	local flashtime = button.flashtime;
	flashtime = flashtime - elapsed;

	if ( flashtime <= 0 ) then
		local overtime = -flashtime;
		if ( overtime >= ATTACK_BUTTON_FLASH_TIME ) then
			overtime = 0;
		end
		flashtime = ATTACK_BUTTON_FLASH_TIME - overtime;

		local flashTexture = _G[button:GetName().."Flash"];
		if ( flashTexture:IsShown() ) then
			flashTexture:Hide();
		else
			flashTexture:Show();
		end
	end

	button.flashtime = flashtime;
end

local function UpdateRange(button, elapsed)
	-- Handle range indicator
	local rangeTimer = button.rangeTimer;
	if ( rangeTimer ) then
		rangeTimer = rangeTimer - elapsed;

		if ( rangeTimer <= 0 ) then
			local hotKey = _G[button:GetName().."HotKey"];
			local valid = button:IsTargetInRange();
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

		button.rangeTimer = rangeTimer;
	end
end

function Button:OnUpdate (elapsed)
	if ( ActionButton_IsFlashing(self) ) then
		UpdateFlashingAnimation(self);
	end
	UpdateRange(self, elapsed);
end



function Button:UpdateFlash ()
	local action = self.action;
	if (self:IsFlashableAction()) then
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
	if(ActionButton_IsFlashing(self)) then
		self.flashing = 0;
		_G[self:GetName().."Flash"]:Hide();
		self:UpdateState();
	end
end

function Button:UpdateFlyout()
	local actionType = self:GetActionInfo();
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
-- Things which will just hand off to the specific prototype table.
---------------------------------------------------------------------------------------------------------------------------------------------------

function Button:SetTooltip ()
	if ( GetCVar("UberTooltips") == "1" ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
	else
		local parent = self:GetParent();
		GameTooltip:SetOwner( "ANCHOR_RIGHT");
	end

	return self.currentActionPrototype:SetTooltip(self);
end

function Button:IsTargetInRange()
	return self.currentActionPrototype:IsTargetInRange(self);
end

function Button:IsFlashableAction()
	return self.currentActionPrototype:IsFlashableAction(self);
end

function Button:UpdateAction()
	return self.currentActionPrototype:UpdateAction(self);
end

function Button:GetActionTexture()
	return self.currentActionPrototype:GetActionTexture(self);
end

function Button:HasAction()
	return self.currentActionPrototype:HasAction(self);
end

function Button:IsEquippedAction()
	return self.currentActionPrototype:IsEquippedAction(self);
end

function Button:IsActionBeingUsed()
	return self.currentActionPrototype:IsActionBeingUsed(self);
end

function Button:IsUsable()
	return self.currentActionPrototype:IsUsable(self);
end

function Button:GetActionUseCount()
	return self.currentActionPrototype:GetActionUseCount(self);
end

function Button:ActionHasUseCount()
	return self.currentActionPrototype:ActionHasUseCount(self);
end

function Button:GetCooldown()
	return self.currentActionPrototype:GetCooldown(self);
end

function Button:GetActionInfo()
	return self.currentActionPrototype:GetActionInfo(self);
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