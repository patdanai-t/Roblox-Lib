-- raise_animals_ui.lua
-- Minimal UI library to create a left-sidebar (icon + text) and right panel with sections/toggles.
-- Drop into a LocalScript or host raw on GitHub and load via HttpGet.
-- Author: generated for user
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Library = {}
Library.__index = Library

-- helper
local function round(n) return math.floor(n+0.5) end
local function create(class, props)
    local obj = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            if k == "Parent" then obj.Parent = v else obj[k]=v end
        end
    end
    return obj
end

-- Basic theme (you can tweak)
local Theme = {
    Background = Color3.fromRGB(25,25,25),
    Panel = Color3.fromRGB(37,37,38),
    Accent = Color3.fromRGB(43,105,159),
    Text = Color3.fromRGB(230,230,230),
    SecondaryText = Color3.fromRGB(170,170,170),
    ToggleOn = Color3.fromRGB(0,146,214),
    ToggleOff = Color3.fromRGB(100,100,100)
}

-- Build main ScreenGui
local function new_gui()
    local screen = create("ScreenGui", {Name="RA_UI", ResetOnSpawn=false, Parent=PlayerGui})
    screen.IgnoreGuiInset = true

    local main = create("Frame", {
        Name = "Main",
        Parent = screen,
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0.5,0.5,0.5,0),
        Size = UDim2.new(0, 780, 0, 420),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0
    })
    create("UICorner", {Parent = main, CornerRadius = UDim.new(0,10)})
    create("UIStroke", {Parent = main, Color = Color3.fromRGB(45,45,45), Thickness=1})

    -- Left sidebar
    local sidebar = create("Frame", {
        Name = "Sidebar",
        Parent = main,
        Position = UDim2.new(0, 12, 0, 12),
        Size = UDim2.new(0, 160, 1, -24),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0
    })
    create("UICorner", {Parent = sidebar, CornerRadius = UDim.new(0,8)})

    local sidebarLayout = create("UIListLayout", {Parent=sidebar, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)})
    sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sidebarLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    -- Header in sidebar
    local header = create("Frame", {Parent = sidebar, Name = "Header", Size = UDim2.new(1, -16, 0, 56), BackgroundTransparency = 1})
    header.Position = UDim2.new(0,8,0,8)
    local title = create("TextLabel", {
        Parent = header, Name = "Title",
        Text = "Main", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold,
        TextSize = 18, BackgroundTransparency=1, Size = UDim2.new(1,0,1,0), TextXAlignment=Enum.TextXAlignment.Left
    })
    title.Position = UDim2.new(0,42,0,8)

    local icon = create("ImageLabel", {
        Parent = header, Name = "Icon",
        Size = UDim2.new(0,32,0,32), Position = UDim2.new(0,6,0,12),
        BackgroundTransparency = 1, Image = "rbxassetid://3926307971" -- placeholder
    })
    create("UICorner", {Parent=icon, CornerRadius=UDim.new(0,6)})

    -- container for sidebar items
    local itemsFrame = create("ScrollingFrame", {
        Parent = sidebar, Name = "Items", Position = UDim2.new(0,8,0,72), Size = UDim2.new(1,-16,1,-80),
        BackgroundTransparency = 1, ScrollBarThickness = 6
    })
    local itemsLayout = create("UIListLayout", {Parent=itemsFrame, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,6)})
    itemsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    itemsFrame.CanvasSize = UDim2.new(0,0,0,0)

    -- Right panel
    local panel = create("Frame", {
        Name = "Panel", Parent = main,
        Position = UDim2.new(0,188,0,12), Size = UDim2.new(1,-200,1,-24),
        BackgroundColor3 = Theme.Panel, BorderSizePixel = 0
    })
    create("UICorner", {Parent = panel, CornerRadius = UDim.new(0,8)})

    -- top bar inside panel for title & search
    local panelTop = create("Frame",{Parent = panel, Name="Top", Size=UDim2.new(1, -24, 0, 48), Position=UDim2.new(0,12,0,12), BackgroundTransparency=1})
    local panelTitle = create("TextLabel", {Parent=panelTop, Name="Title", Text="Play Mode", Font=Enum.Font.GothamBold, TextSize=18, TextColor3=Theme.Text, BackgroundTransparency=1, Position=UDim2.new(0,0,0,6), Size=UDim2.new(0.6,0,0,22), TextXAlignment=Enum.TextXAlignment.Left})
    local panelSubtitle = create("TextLabel", {Parent=panelTop, Name="Subtitle", Text="by YOU", Font=Enum.Font.Gotham, TextSize=12, TextColor3=Theme.SecondaryText, BackgroundTransparency=1, Position=UDim2.new(0,0,0,26), Size=UDim2.new(0.6,0,0,18), TextXAlignment=Enum.TextXAlignment.Left})

    -- content scrolling area
    local content = create("ScrollingFrame", {Parent = panel, Name = "Content", Position = UDim2.new(0,12,0,72), Size = UDim2.new(1,-24,1,-84), BackgroundTransparency=1, ScrollBarThickness=6})
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local contentLayout = create("UIListLayout", {Parent=content, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,10)})
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

    -- helpers for measuring/auto canvas
    spawn(function()
        while screen.Parent do
            pcall(function()
                itemsFrame.CanvasSize = UDim2.new(0,0,0, itemsLayout.AbsoluteContentSize.Y + 8)
                content.CanvasSize = UDim2.new(0,0,0, contentLayout.AbsoluteContentSize.Y + 12)
            end)
            RunService.RenderStepped:Wait()
        end
    end)

    return {
        Screen = screen,
        Main = main,
        Sidebar = sidebar,
        ItemsFrame = itemsFrame,
        Panel = panel,
        Content = content,
        Title = panelTitle,
        Subtitle = panelSubtitle
    }
end

-- UI element constructors (Section, Toggle, Dropdown, Button)
local function makeSection(titleText)
    local sec = create("Frame", {Name="Section", Size=UDim2.new(1,-24,0,60), BackgroundTransparency=1})
    local secTitle = create("TextLabel", {Parent=sec, Name="Title", Text=titleText, Font=Enum.Font.GothamBold, TextSize=14, TextColor3=Theme.Text, BackgroundTransparency=1, Position=UDim2.new(0,0,0,4), Size=UDim2.new(1,0,0,18), TextXAlignment=Enum.TextXAlignment.Left})
    local holder = create("Frame", {Parent=sec, Name="Holder", Position=UDim2.new(0,0,0,28), Size=UDim2.new(1,0,0,28), BackgroundTransparency=1})
    return sec, holder
end

local function makeToggle(name, default, callback)
    local container = create("Frame", {Name="ToggleRow", Size=UDim2.new(1,0,0,28), BackgroundTransparency=1})
    local label = create("TextLabel", {Parent=container, Text=name, Font=Enum.Font.Gotham, TextSize=14, TextColor3=Theme.Text, BackgroundTransparency=1, Position=UDim2.new(0,0,0,0), Size=UDim2.new(0.8,0,1,0), TextXAlignment=Enum.TextXAlignment.Left})
    -- toggle background
    local toggBg = create("Frame", {Parent=container, Name="ToggleBG", Size=UDim2.new(0,44,0,24), Position=UDim2.new(1,-44,0,2), BackgroundColor3=Theme.ToggleOff, BorderSizePixel=0})
    create("UICorner", {Parent=toggBg, CornerRadius=UDim.new(0,12)})
    local toggKnob = create("Frame", {Parent=toggBg, Name="Knob", Size=UDim2.new(0,20,1,0), Position=UDim2.new(0,2,0,0), BackgroundColor3=Theme.Panel, BorderSizePixel=0})
    create("UICorner", {Parent=toggKnob, CornerRadius=UDim.new(0,10)})
    local state = default == true

    local function updateVisual()
        if state then
            TweenService:Create(toggBg, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ToggleOn}):Play()
            TweenService:Create(toggKnob, TweenInfo.new(0.22), {Position = UDim2.new(1, -22, 0, 0)}):Play()
        else
            TweenService:Create(toggBg, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ToggleOff}):Play()
            TweenService:Create(toggKnob, TweenInfo.new(0.22), {Position = UDim2.new(0, 2, 0, 0)}):Play()
        end
    end
    updateVisual()

    -- click
    toggBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            updateVisual()
            if callback then pcall(callback, state) end
        end
    end)

    return container, function() return state end, function(val) state = val updateVisual() if callback then pcall(callback, state) end end
end

local function makeDropdown(name, options, default, callback)
    local container = create("Frame", {Name="DropdownRow", Size=UDim2.new(1,0,0,36), BackgroundTransparency=1})
    local label = create("TextLabel", {Parent=container, Text=name, Font=Enum.Font.Gotham, TextSize=14, TextColor3=Theme.Text, BackgroundTransparency=1, Position=UDim2.new(0,0,0,0), Size=UDim2.new(0.5,0,0,0), TextXAlignment=Enum.TextXAlignment.Left})
    local current = default or options[1]
    local display = create("TextLabel", {Parent=container, Text=tostring(current), Font=Enum.Font.Gotham, TextSize=14, TextColor3=Theme.SecondaryText, BackgroundColor3=Theme.Panel, BackgroundTransparency=0, Size=UDim2.new(0.45,0,0,26), Position=UDim2.new(1,-(0.45*container.AbsoluteSize.X)-12,0,6)})
    create("UICorner", {Parent=display, CornerRadius=UDim.new(0,6)})
    display.TextXAlignment = Enum.TextXAlignment.Center

    -- menu
    local menu = create("Frame", {Parent=container, Name="Menu", BackgroundColor3=Theme.Panel, Size=UDim2.new(0.45,0,0,(#options*28)+6), Position=UDim2.new(1,-(0.45*container.AbsoluteSize.X)-12,0,38), Visible=false, ZIndex=10})
    create("UICorner", {Parent=menu, CornerRadius=UDim.new(0,6)})
    local list = create("UIListLayout", {Parent=menu, Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder})

    for i,opt in ipairs(options) do
        local row = create("TextButton", {Parent = menu, Text = tostring(opt), BackgroundTransparency=0, BackgroundColor3=Theme.Panel, TextColor3=Theme.Text, AutoButtonColor=false, Size=UDim2.new(1,-12,0,28)})
        row.Position = UDim2.new(0,6,0, (i-1)*28 + 6)
        row.MouseButton1Click:Connect(function()
            current = opt
            display.Text = tostring(current)
            menu.Visible = false
            if callback then pcall(callback, current) end
        end)
    end

    display.MouseButton1Click:Connect(function()
        menu.Visible = not menu.Visible
    end)

    return container, function() return current end, function(val) current = val display.Text = tostring(current) if callback then pcall(callback,current) end end
end

local function makeButton(name, callback)
    local btn = create("TextButton", {Name="Btn", Size=UDim2.new(1,0,0,34), BackgroundColor3=Theme.Accent, BorderSizePixel=0, Text=name, Font=Enum.Font.GothamBold, TextSize=14, TextColor3=Color3.fromRGB(255,255,255)})
    create("UICorner", {Parent=btn, CornerRadius=UDim.new(0,6)})
    btn.MouseButton1Click:Connect(function()
        if callback then pcall(callback) end
    end)
    return btn
end

-- Public API: CreateWindow
function Library.CreateWindow(opts)
    opts = opts or {}
    local gui = new_gui()
    gui.Title.Text = opts.Title or "Window"
    gui.Subtitle.Text = opts.Subtitle or ""
    local self = setmetatable({
        gui = gui,
        tabs = {},
        current = nil
    }, Library)

    -- add sidebar item
    function self:AddSidebarItem(name, id, iconAsset)
        local item = create("Frame", {Parent = self.gui.ItemsFrame, Name = tostring(id), Size = UDim2.new(1,-12,0,36), BackgroundTransparency=1})
        create("UICorner",{Parent=item, CornerRadius=UDim.new(0,6)})
        local btn = create("TextButton", {Parent=item, Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), AutoButtonColor=false})
        local icon = create("ImageLabel", {Parent=item, Name="Icon", Image = iconAsset or "rbxassetid://3926307971", Size=UDim2.new(0,28,0,28), Position=UDim2.new(0,4,0,4), BackgroundTransparency=1})
        local lbl = create("TextLabel", {Parent=item, Name="Label", Text=name, Font=Enum.Font.Gotham, TextSize=14, TextColor3=Theme.Text, BackgroundTransparency=1, Position=UDim2.new(0,40,0,6), Size=UDim2.new(1,-40,1,0), TextXAlignment=Enum.TextXAlignment.Left})
        item.LayoutOrder = #self.gui.ItemsFrame:GetChildren()
        -- select behavior
        local function select()
            -- highlight selection visually
            for _,child in ipairs(self.gui.ItemsFrame:GetChildren()) do
                if child:IsA("Frame") and child:FindFirstChild("Label") then
                    child.Label.TextColor3 = Theme.Text
                    child.BackgroundTransparency = 1
                end
            end
            lbl.TextColor3 = Theme.Accent
            -- set panel title
            self.gui.Title.Text = name
            -- clear content
            for _,v in ipairs(self.gui.Content:GetChildren()) do
                if v:IsA("Frame") or v:IsA("TextLabel") or v:IsA("TextButton") then v:Destroy() end
            end
            -- create container for this tab
            local container = create("Frame", {Parent=self.gui.Content, Size=UDim2.new(1,0,0,20), BackgroundTransparency=1})
            container.LayoutOrder = 0
            self.current = {id=id, name=name, container = container, sections = {}}
        end

        btn.MouseButton1Click:Connect(select)

        -- auto select first appended tab
        if not self.current then
            select()
        end

        local tabRef = {id=id, name=name, frame=item, addSection = function(_, title)
            local sec, holder = makeSection(title)
            sec.Parent = self.gui.Content
            sec.LayoutOrder = #self.gui.Content:GetChildren()
            table.insert(self.current.sections, sec)
            -- return an object to add elements
            local sectionObj = {}
            function sectionObj:AddToggle(n, default, cb) 
                local trow, getter, setter = makeToggle(n, default, cb)
                trow.Parent = sec
                return {Get = getter, Set = setter}
            end
            function sectionObj:AddDropdown(n, opts, default, cb)
                local drow, getter, setter = makeDropdown(n, opts, default, cb)
                drow.Parent = sec
                return {Get = getter, Set = setter}
            end
            function sectionObj:AddButton(n, cb)
                local b = makeButton(n, cb)
                b.Parent = sec
                return b
            end
            return sectionObj
        end}
        table.insert(self.tabs, tabRef)
        return tabRef
    end

    return self
end

-- return library
return Library
