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

addon.ButtonPrototype.action = {};
local Template = addon.ButtonPrototype.action;

function Template:SetTooltip (button)
	GameTooltip:SetAction(button.action);
end

function Template:IsTargetInRange(button)
	return IsActionInRange(button.action);
end

function Template:IsFlashableAction(button)
	return (IsAttackAction(button.action) and IsCurrentAction(button.action)) or IsAutoRepeatAction(button.action);
end


local function CalculateAction (button, pressedMouseButton)
	if ( not pressedMouseButton ) then
		-- "LeftButton" is the hardcoded value returned by SecureButton_GetEffectiveButton.
		-- Check to see if they eventually implement it and what it does
		--  but the feature probably isn't important/desired anyway.
		pressedMouseButton = "LeftButton";
	end

	return SecureButton_GetModifiedAttribute(button, "action", pressedMouseButton) or 1;
end

function Template:UpdateAction(button)
	local action = CalculateAction(button);

	if ( action ~= button.action ) then
		-- We use a local action variable instead of the attribute because the game systems seem to use it
		-- for flyouts regardless of whether we call it or not. Might as well use it everywhere.
		button.action = action;
		button:Update();
	end
end

function Template:GetActionTexture(button)
	return GetActionTexture(button.action);
end

function Template:HasAction(button)
	return HasAction(button.action);
end

function Template:IsEquippedAction(button)
	return IsEquippedAction(button.action);
end

function Template:IsActionBeingUsed(button)
	return IsCurrentAction(button.action) or IsAutoRepeatAction(button.action);
end

function Template:IsUsable(button)
	return IsUsableAction(button.action);
end

function Template:GetActionUseCount(button)
	return GetActionCount(button.action);
end

function Template:ActionHasUseCount(button)
	return IsConsumableAction(button.action) or IsStackableAction(button.action);
end

function Template:GetCooldown(button)
	return GetActionCooldown(button.action);
end

function Template:GetActionInfo(button)
	return GetActionInfo(button.action);
end