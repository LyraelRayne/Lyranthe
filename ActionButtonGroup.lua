local addon = Lyranthe;
local addonName = addon:GetName();
local Masque = LibStub("Masque", true);
local groupPrototype = getmetatable(CreateFrame("Frame", addonName .. "group_dummy", nil, addon.GROUP_TEMPLATE)).__index;

local profile = nil;
local configKey = addonName .. "GroupConfig"

groupPrototype.configBackdrop = {
	-- path to the background texture
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background" ,
	-- path to the border texture
	edgeFile = nil,
	-- true to repeat the background texture to fill the frame, false to scale it
	tile = true,
	-- size (width or height) of the square repeating background tiles (in pixels)
	tileSize = 32,
	-- thickness of edge segments and square size of edge corners (in pixels)
	edgeSize = 32,
	-- distance from the edges of the frame to those of the background texture (in pixels)
	insets = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	}
};

function addon:CreateGroup(name)
	local group = CreateFrame("Frame", name, UIParent, addon.GROUP_TEMPLATE);
	group:ClearAllPoints();
	group:EnableConfigMode();
	group:LoadConfig();
	group:Show();
	return group;
end



function groupPrototype:LoadConfig()
	-- load profile here because it's not available on load.
	if not profile then profile = addon.configDB.profile; end

	local groupName = self:GetName();
	local config = profile.groups[groupName];
	self[configKey] = config;

	self:SetWidth(config.width);
	self:SetHeight(config.height);
	addon:Print(config.centerX .. " " .. config.centerY);
	self:SetPoint("CENTER", nil, config.relativePoint, config.centerX, config.centerY);
end

function groupPrototype:AddButton()

end

function groupPrototype:EnableConfigMode()
	local groupName = self:GetName();
	self:SetBackdrop(self.configBackdrop);
	self:SetBackdropColor(0, 1, 0, 0.5);
	_G[groupName .. "_Sizer"]:Show();
	self:EnableMouse(true);
	self.configMode = true;
end

function groupPrototype:DisableConfigMode()
	local groupName = self:GetName();
	self:SetBackdrop(nil);
	_G[groupName .. "_Sizer"]:Hide();
	self:EnableMouse(false);
	self.configMode = false;
	self:CommitPositionChanges();
end

function groupPrototype:CommitPositionChanges()
	local config = self[configKey];
	config.width = self:GetWidth();
	config.height = self:GetHeight();
	_, _, config.relativePoint, config.centerX, config.centerY = self:GetPoint("CENTER");
end