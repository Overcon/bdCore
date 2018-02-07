local bdCore, c, f = select(2, ...):unpack()

----------------------------------------------
-- Configuration Frames
----------------------------------------------
local function CreateText(parentframe, hjust, vjust)
	if not hjust then hjust = "LEFT" end
	if not vjust then vjust = "MIDDLE" end

	local text = parentframe:CreateFontString(nil)
	text:SetFont(bdCore.media.font, 14)
	text:SetJustifyH(hjust)
	text:SetJustifyV(vjust)
	text:SetTextColor(1, 1, 1, 1)
	text:SetAllPoints()

	return text
end

local function CreateButton(parentframe, color)
	local button = CreateFrame("button", nil, parentframe, "UIPanelButtonTemplate")
	local f = button

	local colors = bdCore.media.backdrop
	local hovercolors = {0,0.55,.85,1}
	if (color == "red") then
		colors = {.6,.1,.1,0.6}
		hovercolors = {.6,.1,.1,1}
	elseif (color == "blue") then
		colors = {0,0.55,.85,0.6}
		hovercolors = {0,0.55,.85,1}
	elseif (color == "dark") then
		colors = bdCore.media.backdrop
		hovercolors = {.1,.1,.1,1}
	elseif (color and bdCore.media[color]) then
		colors = bdCore.media[color]
		hovercolors = bdCore.media[color]
	end

	f:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 2, insets = {left=2,top=2,right=2,bottom=2}})
	f:SetBackdropColor(unpack(colors)) 
    f:SetBackdropBorderColor(unpack(bdCore.media.border))
    f:SetNormalFontObject("bdCore.font")
	f:SetHighlightFontObject("bdCore.font")
	f:SetPushedTextOffset(0,-1)
	-- f:SetJustifyH("CENTER")
	-- f:SetJustifyV("MIDDLE")
	f:SetSize(f:GetTextWidth()+16,24)
	
	f:HookScript("OnEnter", function(f) 
		f:SetBackdropColor(unpack(hovercolors)) 
	end)
	f:HookScript("OnLeave", function(f) 
		f:SetBackdropColor(unpack(colors)) 
	end)

	return button
end

local function CreateCheckbox()

end

local function CreateDropdown()

end

local function CreateDetailList()

end


----------------------------------------------
-- Configuration Window
----------------------------------------------
local sizes = {
	left = 200
	, right = 600
	, height = 500
	, header_height = 30
	, tab_height = 24
}

local cfg = CreateFrame("frame", "bdCore Config", UIParent)
cfg:SetSize(sizes.left + sizes.right, sizes.height)
cfg:SetPoint("CENTER")
cfg:SetMovable(true)
cfg:SetUserPlaced(true)
cfg:SetClampedToScreen(true)
cfg:SetBackdrop({bgFile = bdCore.media.flat})
cfg:SetBackdropColor(unpack(bdCore.media.backdrop))

-- Header
cfg.header = CreateFrame("frame", nil, cfg)
cfg.header:SetPoint("BOTTOMLEFT", cfg, "TOPLEFT")
cfg.header:SetPoint("BOTTOMRIGHT", cfg, "TOPRIGHT")
cfg.header:SetHeight(sizes.header_height)
cfg.header:SetBackdrop({bgFile = bdCore.media.flat})
cfg.header:SetBackdropColor(unpack(bdCore.media.backdrop))
cfg.header:RegisterForDrag("LeftButton","RightButton")
cfg.header:EnableMouse(true)
cfg.header:SetScript("OnDragStart", function(self) cfg:StartMoving() end)
cfg.header:SetScript("OnDragStop", function(self) cfg:StopMovingOrSizing() end)

cfg.header.title = CreateText(cfg.header)
cfg.header.title:SetText("BigDumb Config")
cfg.header.close = CreateButton(cfg.header, "red")
cfg.header.close:SetText("X")
cfg.header.close:SetPoint("TOPRIGHT", cfg.header, "TOPRIGHT")
cfg.header.reload = CreateButton(cfg.header, "blue")
cfg.header.reload:SetText("Reload UI")
cfg.header.reload:SetPoint("TOPRIGHT", cfg.header.close, "TOPLEFT")
cfg.header.lock = CreateButton(cfg.header, "blue")
cfg.header.lock:SetText("Lock")
cfg.header.lock:SetPoint("TOPRIGHT", cfg.header.reload, "TOPLEFT")

-- leftcol
cfg.left = CreateFrame("frame", nil, cfg)
cfg.left:SetPoint("TOPLEFT", cfg, "TOPLEFT")
cfg.left:SetPoint("BOTTOMRIGHT", cfg, "BOTTOMLEFT", sizes.left, 0)
cfg.left:SetBackdrop({bgFile = bdCore.media.flat})
cfg.left:SetBackdropColor(1,1,1,.1)

-- rightcol
cfg.right = CreateFrame("frame", nil, cfg)
cfg.right:SetPoint("TOPRIGHT", cfg, "TOPRIGHT")
cfg.right:SetPoint("BOTTOMLEFT", cfg, "BOTTOMRIGHT", -sizes.right, 0)
cfg.right:SetBackdrop({bgFile = bdCore.media.flat})
cfg.right:SetBackdropColor(0,0,0,.1)


----------------------------------------------
-- Configuration Functions
----------------------------------------------
local lastnav = nil
function cfg:addNavigation(name)
	local nav = CreateFrame("Button", nil, cfg.left)
	nav.name = name
	nav:SetWidth(sizes.left)
	nav:SetHeight(20)
	nav:SetBackdrop({bgFile = bdCore.media.flat})
	nav:SetBackdropColor(0,0,0,0)
	nav:SetScript("OnEnter", function(self)
		if self.active then return end
		self:SetBackdropColor(1,1,1,0.1)
	end)
	nav:SetScript("OnLeave", function(self)
		if self.active then return end
		self:SetBackdropColor(1,1,1,0)
	end)

	nav.text = CreateText(nav)
	nav.text:SetText(name)

	-- position correctly
	if (not lastnav) then
		nav:SetPoint("TOPLEFT", cfg.left, "TOPLEFT")
	else
		nav:SetPoint("TOPLEFT", lastnav, "BOTTOMLEFT")
	end

	-- become active when clicked
	nav:SetScript("OnClick", function(self)
		if (self.active) then return end

		-- clear navs
		for name, nav in pairs(cfg.nav) do
			nav.active = false
			nav:SetBackdropColor(0,0,0,0)
		end

		-- clear panels
		for name, panel in pairs(cfg.panels) do
			if (name == self.name) then
				panel:Show()

				-- then fix/click the tabs in the panel
				for name, tab in pairs(panel.tabs) do
					tab.active = nil
					tab:SetAlpha(0.6)
					tab.backdrop:SetVertexColor(1,1,1,.1)
				end
				local first_tab = c[0] or c[1]
				first_tab:Click()
			else
				panel:Hide()
			end
		end

		self.active = true
		self:SetBackdropColor(unpack(bdCore.media.red))
	end)

	cfg.nav[name] = nav
	lastnav = nav
	return nav
end

function cfg:addTab(panel, name)
	print("adding tab")
	local tab = CreateButton(panel.tab_container, 'dark')
	tab:SetAlpha(0.6)
	tab:SetText(name)
	tab:SetSize(tab:GetTextWidth()+30,26)
	tab:SetScript("OnEnter", function(self)
		if (self.active) then return end
		self:SetAlpha(1)
	end)
	tab:SetScript("OnLeave", function(self)
		if (self.active) then return end
		self:SetAlpha(0.6)
	end)

	-- position tab
	if (not panel.last_tab) then
		tab:SetPoint("LEFT", panel.tab_container, "LEFT", 4, 0)
	else
		tab:SetPoint("LEFT", panel.last_tab, "RIGHT", 2, 0)
	end

	local content = CreateFrame("frame", nil, panel)
	content:SetPoint("TOPLEFT", panel, "TOPLEFT")
	content:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT")
	content.scrollframe = CreateFrame("ScrollFrame", nil, content) 
	content.scrollframe:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0) 
	content.scrollframe:SetSize(content:GetWidth(), content:GetHeight()) 
	content.scrollbar = CreateFrame("Slider", nil, content.scrollframe, "UIPanelScrollBarTemplate") 
	content.scrollbar:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -18) 
	content.scrollbar:SetPoint("BOTTOMLEFT", content, "BOTTOMRIGHT", -18, 18) 
	content.scrollbar:SetMinMaxValues(1, math.ceil(content:GetHeight()+1)) 
	content.scrollbar:SetValueStep(1) 
	content.scrollbar.scrollStep = 1
	content.scrollbar:SetValue(0) 
	content.scrollbar:SetWidth(16) 
	content.scrollbar:SetScript("OnValueChanged", function (self, value) self:GetParent():SetVerticalScroll(value) self:SetValue(value) end) 
	content.scrollbar:SetBackdrop({bgFile = bdCore.media.flat})
	content.scrollbar:SetBackdropColor(0,0,0,.2)
	content.content = CreateFrame("Frame", nil, content.scrollframe) 
	content.content:SetSize(content:GetWidth(), content:GetHeight())

	--cfg.panel[name] = panel
	panel.last_tab = tab
	panel.tabs = panel.tabs or {}
	panel.tabs[name] = tab
	return tab, content.content
end

cfg.nav = {}
cfg.panels = {}
bdCore.modules = {}
function bdCore:addModule(name, configurations, persistent, callback)
	-- used to say whether or not config has been initiated for name
	bdCore.modules[name] = true
	-- add leftside navigation item
	local nav = cfg:addNavigation(name)

	-- add panels tabs for this UI element
	local panel = CreateFrame("frame", nil, cfg.right)
	panel:SetPoint("TOPRIGHT", cfg.right, "TOPRIGHT", 0, -sizes.tab_height)
	panel:SetPoint("BOTTOMLEFT", cfg.right, "BOTTOMLEFT")
	panel:Hide()
	panel.tab_container = CreateFrame("frame", nil, panel)
	panel.tab_container:SetPoint("BOTTOMRIGHT", cfg.right, "TOPLEFT", 0, -sizes.tab_height)
	panel.tab_container:SetPoint("TOPLEFT", cfg.right, "TOPLEFT")
	cfg.panels[name] = panel

	-- now lets start adding configuration
	if (not configurations) then print("bdConfig for"..name.."is missing configuration array"); return end
	for k, config in pairs(configurations) do
		print(k, config)
		local tab_started = false
		for option, info in pairs(config) do
			print(option, info, info.type)
			if (not tab_started and info.type ~= "tab") then
				-- we haven't started a tab yet, let's just make one for ease
				tab_started = true
				local tab, content = cfg:addTab(panel, "General")
			end

			-- check where to store this. either in the account-wide persistent data, or in the profile
			if (persistent or info.persistent) then
				c.persistent[name] = c.persistent[name] or {}
				if (c.persistent[name][option] == nil) then
					if (info.value == nil) then
						info.value = {}
					end
					c.persistent[name][option] = info.value
				end
			else
				c.profile[name] = c.profile[name] or {}
				if (c.profile[name][option] == nil) then
					if (info.value == nil) then
						info.value = {}
					end
					c.profile[name][option] = info.value
				end
			end

			-- create the configuration frame here
			if (info.type == "tab") then
				local tab, content = cfg:addTab(panel, info.name)
			elseif (info.type == "slider") then
			elseif (info.type == "checkbox") then
			elseif (info.type == "dropdown") then
			elseif (info.type == "list") then
			elseif (info.type == "createbox") then
			elseif (info.type == "actionbutton") then
			elseif (info.type == "color") then
			end

			-- hide tabs if we're not actually using anything other than General
			if (panel.last_tab:GetText() == "General") then
				panel.tab_container:Hide()
				panel:SetPoint("TOPRIGHT", cfg.right, "TOPRIGHT", 0, 0)
			end
		end

	end
end

