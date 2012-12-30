local addon = Lyranthe;
local addonName = addon:GetName();
local Masque = LibStub("Masque", true);
local groupPrototype = getmetatable(CreateFrame("Frame", addonName .. "group_dummy", nil, addon.GROUP_TEMPLATE)).__index;

local profile = nil;
local configKey = addonName .. "GroupConfig"

local LibActionButton = LibStub("LibActionButton-1.0");

local spacing = 4;
local offset = addon.BUTTON_SIDE_LENGTH + spacing;

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
	group.buttons = {};
	group:SetScript("OnSizeChanged", group.OnSizeChanged);
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
	self:SetPoint("CENTER", nil, config.relativePoint, config.centerX, config.centerY);
end

function groupPrototype:PositionButton(button, row, col)
	button:ClearAllPoints();
	button:SetPoint("TOPLEFT", self, "TOPLEFT", (col-1)*offset, -(row-1)*offset);
end

function groupPrototype:OnSizeChanged(width, height)
	self:FillWithButtons();
end

local function ClearSpareButtons(group, maxButtons)
	local buttons = group.buttons;
	local buttonIndex = maxButtons + 1;
	while(buttons[buttonIndex]) do
		local button = buttons[buttonIndex];
		button:SetParent(nil);
		button:Hide();
		buttonIndex = buttonIndex + 1;
	end
end

function groupPrototype:FillWithButtons()
	local scale = self:GetEffectiveScale();
	local width = self:GetWidth() * scale;
	local height = self:GetHeight() * scale;
	local rows = floor(height / offset);
	local cols = floor(width / offset);

	local lastButton = nil;
	for row = 1, rows, 1 do
		for col = 1, cols, 1 do
			local buttonIndex = col + cols*(row - 1);
			local button = self.buttons[buttonIndex];
			if(not button) then
				button = self:AddButton();
			end
			button:SetParent(this);
			self:PositionButton(button, row, col);
			button:Show();
		end
	end
	ClearSpareButtons(self, (rows * cols))
end



function groupPrototype:AddButton()
	local groupName = self:GetName();
	local buttonIndex = getn(self.buttons) + 1;
	local buttonName = groupName .. "_Button" .. buttonIndex;
	local buttons = self.buttons;
	local button = _G[buttonName];
	if not(button) then
		button =  CreateFrame("CheckButton", buttonName, self, addon.BUTTON_TEMPLATE);
	end
	buttons[buttonIndex] = button;
	button.positionInGroup = buttonIndex;
	return button;
end

function groupPrototype:EnableConfigMode()
	local groupName = self:GetName();
	self:SetBackdrop(self.configBackdrop);
	self:SetBackdropColor(0, 1, 0, 0.5);
	self.sizer:Show();
	self:EnableMouse(true);
	self.configMode = true;
end

function groupPrototype:DisableConfigMode()
	local groupName = self:GetName();
	self:SetBackdrop(nil);
	self.sizer:Hide();
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