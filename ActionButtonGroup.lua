local addon = Lyranthe;
local addonName = addon:GetName();
local Masque = LibStub("Masque", true);
local groupPrototype = getmetatable(CreateFrame("Frame", addonName .. "group_dummy", nil, addon.GROUP_TEMPLATE)).__index;

local profile = nil;
local configKey = addonName .. "GroupConfig"

local LibActionButton = LibStub("LibActionButton-1.0");
local Masque = LibStub("Masque", true);

local sidePad = 5;
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
	group:AssignMasqueGroup();
	group:ClearAllPoints();
	group:EnableConfigMode();
	group.buttons = {};
	group:SetScript("OnSizeChanged", group.OnSizeChanged);
	group:LoadConfig();
	group:Show();

	return group;
end

function groupPrototype:AssignMasqueGroup()
	local groupName = self:GetName();
	self.masqueGroup = Masque:Group(addonName, groupName);
end

function groupPrototype:LoadConfig()
	-- load profile here because it's not available on load.
	if not profile then profile = addon.configDB.profile; end

	local groupName = self:GetName();
	local config = profile.groups[groupName];
	self[configKey] = config;

	self:SetWidth(config.width);
	self:SetHeight(config.height);
	self:SetPoint(config.anchorPoint, nil, config.relativePoint, config.centerX, config.centerY);
end

function groupPrototype:PositionButton(button)
	local column = button.column;
	local row = button.row;
	button:ClearAllPoints();
	button:SetPoint("TOPLEFT", self, "TOPLEFT", sidePad + (column-1)*offset, -sidePad -(row-1)*offset);
end

function groupPrototype:OnSizeChanged(width, height)
	self:FillWithButtons();
end

local function ClearSpareRows(group, startPoint)
	local buttonRows = group.buttons;
	-- Handles the case where there are 0 rows gracefully.
	if(startPoint <= 0) then
		startPoint = 1;
	end
	
	if(buttonRows and #(buttonRows) >= startPoint) then
		for rowIndex, row in next, buttonRows, startPoint do
			for columnIndex, button in next, row do
				group:RemoveButton(button);
			end
		end
	end
end

function ClearSpareColumns(group, rowIndex, startPoint)
   local row = group.buttons[rowIndex];
   -- Handles the case where there are 0 columns gracefully.
   if(startPoint <= 0) then
		startPoint = 1;
	end
   if row then
      if(#(row) >= startPoint) then
         for columnIndex, button in next, row, startPoint do
            group:RemoveButton(button);
         end
      end
   end
end

function groupPrototype:RemoveButton(button)
	local column = button.column;
	local row = button.row;
	self.buttons[row][column] = nil;
	button:SetParent(nil);
	button:Hide();
	self.masqueGroup:RemoveButton(button, true);
end

function groupPrototype:FillWithButtons()
	local width = self:GetWidth() - sidePad;
	local height = self:GetHeight() - sidePad;
	local rows = floor(height / offset);
	local columns = floor(width / offset);

	local lastButton = nil;
	for row = 1, rows, 1 do
		for column = 1, columns, 1 do
			local button = self:GetButton(row,column);
			self:AddButton(button);
		end
		ClearSpareColumns(self, row, columns);
	end
	ClearSpareRows(self, rows)
end

function groupPrototype:GetButton(row,column)
	local groupName = self:GetName();
	local buttonName = groupName .. "_Row" .. row .. "_Button" .. column;
	local button = _G[buttonName];
	if not(button) then
		button =  CreateFrame("CheckButton", buttonName, self, addon.BUTTON_TEMPLATE);
		button.action = column;
	end
	button.row = row;
	button.column = column;
	_G[button:GetName() .. "Count"]:SetText(button.row .. "," .. button.column)
	return button;
end

function groupPrototype:AddButton(button)
	local buttons = self.buttons;
	local column = button.column;
	local row = button.row;
	if(not buttons[row]) then buttons[row] = {} end
	buttons[row][column] = button;
	button:SetParent(self);
	self.masqueGroup:AddButton(button);
	self:PositionButton(button);
	button:Show();
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
	-- There should only ever be one point.
	config.anchorPoint, _, config.relativePoint, config.centerX, config.centerY = self:GetPoint();
end