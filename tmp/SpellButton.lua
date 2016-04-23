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

addon.ButtonPrototype.spell = {};
local Template = addon.ButtonPrototype.spell;

local function GetSpellId(button)
	return SecureButton_GetModifiedAttribute(button, "spell", "LeftButton");
end

function Template:SetTooltip (button)
	local spellID = GetSpellId(button);
	GameTooltip:SetSpellBookItem(addon:GetSpellBookId(spellID), BOOKTYPE_SPELL);
end

function Template:IsTargetInRange(button)
	local spellID = GetSpellId(button);
	local unit = SecureButton_GetModifiedAttribute(button, "unit", "LeftButton");
	local spellName = GetSpellInfo(spellID);
	return IsSpellInRange(spellName, unit);
end

function Template:IsFlashableAction(button)
	local spellID = GetSpellId(button);
	local spellName = GetSpellInfo(spellID);
	return (IsAttackSpell(spellName) and IsCurrentSpell(spellName)) or IsAutoRepeatSpell(spellName);
end

function Template:UpdateAction(button)
-- noop
end

function Template:GetActionTexture(button)
	local spellID = GetSpellId(button);
	local texture = GetSpellTexture(spellID);
	return texture;
end

function Template:HasAction(button)
	local spellID = GetSpellId(button);
	return (spellID ~= nil);
end

function Template:IsEquippedAction(button)
	-- spells are not items.
	return false;
end

function Template:IsActionBeingUsed(button)
	local spellID = GetSpellId(button);
	local spellName = GetSpellInfo(spellID);
	return IsCurrentSpell(spellName) or IsAutoRepeatSpell(spellName);
end

function Template:IsUsable(button)
	local spellID = GetSpellId(button);
	local spellName = GetSpellInfo(spellID);
	return IsUsableSpell(spellName);
end

function Template:GetActionUseCount(button)
	local spellID = GetSpellId(button);
	local spellName = GetSpellInfo(spellID);
	return GetSpellCount(spellName);
end

function Template:ActionHasUseCount(button)
	local spellID = GetSpellId(button);
	local spellName = GetSpellInfo(spellID);
	return IsConsumableSpell(spellName);
end

function Template:GetCooldown(button)
	local spellID = GetSpellId(button);
	return GetSpellCooldown(spellID);
end

function Template:GetActionInfo(button)
	local spellID = GetSpellId(button);
	local spellBookID = addon:GetSpellBookId(spellID);
	local type = "spell";
	local subType = "spell";
	return type, spellBookID, subType, spellID;
end