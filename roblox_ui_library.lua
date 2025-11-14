--[[
Roblox UI Library — Single-file lightweight Rayfield-like library
Author: Generated for user
License: MIT (based on public UI ideas; include credit to Rayfield-style inspiration)

Features:
 - Window with Title/SubTitle
 - Left Sidebar with Tabs
 - Tabs -> Sections
 - Elements: Button, Toggle, Dropdown (single/multi), Label, Slider (basic)
 - Theme: Dark by default; configurable Accent
 - Lightweight Tween animations
 - Simple API similar to Rayfield but clean and small

Usage (example, included at bottom of file):
local Lib = loadstring(game:HttpGet("YOUR_RAW_URL_HERE"))()
local Win = Lib:CreateWindow({Title = "Raise Animals", Subtitle = "by YOU"})
local Tab = Win:CreateTab("Play Mode")
local Sec = Tab:CreateSection("Auto Swap")
Sec:CreateDropdown({Name = "Animals", Options = {"Lion","Tiger","Dog"}, Multi = true, Default = {"Lion"}, Callback = function(sel) print(sel) end})
Sec:CreateToggle({Name = "Enabled", Default = true, Callback = function(v) print(v) end})

-- End header
]]

local Library = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

-- Utils
local function twn(inst, props, info)
    info = info or TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    TweenService:Create(inst, info, props):Play()
end

local function new(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k == "Parent" then inst.Parent = v else pcall(function() inst[k] = v end) end
    end
    return inst
end

-- Default theme
local Theme = {
    Background = Color3.fromRGB(23, 23, 23),
    Panel = Color3.fromRGB(28, 28, 28),
    Accent = Color3.fromRGB(46, 134, 222), -- blue accent
    Text = Color3.fromRGB(235, 235, 235),
    Muted = Color3.fromRGB(160, 160, 160)
}

-- Basic styles
local UI = Instance.new("ScreenGui")
UI.Name = "SimpleUiLib"
UI.ResetOnSpawn = false

-- Root window factory
function Library:CreateWindow(opts)
    opts = opts or {}
    local title = opts.Title or "Window"
    local subtitle = opts.Subtitle or "by you"

    -- Main frame
    local Frame = new("Frame", {
        Name = "Window",
        Parent = UI,
        BackgroundColor3 = Theme.Background,
        Size = UDim2.new(0, 720, 0, 420),
        Position = UDim2.new(0.5, -360, 0.5, -210),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BorderSizePixel = 0
    })

    local UICorner = new("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 10)})
    local Main = new("Frame", {Parent = Frame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1})

    -- Left Sidebar
    local Side = new("Frame", {Parent = Main, BackgroundColor3 = Theme.Panel, Size = UDim2.new(0, 180, 1, 0), Position = UDim2.new(0,0,0,0), BorderSizePixel = 0})
    new("UICorner", {Parent = Side, CornerRadius = UDim.new(0, 8)})

    local SideList = new("UIListLayout", {Parent = Side, Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder})
    SideList.Padding = UDim.new(0,8)

    -- Title area
    local TitleFrame = new("Frame", {Parent = Side, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,70)})
    local TName = new("TextLabel", {Parent = TitleFrame, Text = title, Size = UDim2.new(1,-16,0,26), Position = UDim2.new(0,8,0,8), BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left})
    local TSub = new("TextLabel", {Parent = TitleFrame, Text = subtitle, Size = UDim2.new(1,-16,0,20), Position = UDim2.new(0,8,0,34), BackgroundTransparency = 1, TextColor3 = Theme.Muted, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})

    -- Tabs container (on the right)
    local Content = new("Frame", {Parent = Main, BackgroundColor3 = Theme.Background, Size = UDim2.new(1, -180, 1, 0), Position = UDim2.new(0, 180, 0, 0), BorderSizePixel = 0})
    new("UICorner", {Parent = Content, CornerRadius = UDim.new(0, 8)})

    -- Right content holder where tabs pages go
    local Pages = new("Folder", {Parent = Content})

    -- API container
    local WindowAPI = {}
    WindowAPI._tabs = {}
    WindowAPI._frame = Frame

    -- function to set active tab
    local function setActive(name)
        for k, tab in pairs(WindowAPI._tabs) do
            if tab.Name == name then
                tab.Button.TextColor3 = Theme.Text
                tab.Page.Visible = true
                twn(tab.Page, {BackgroundTransparency = 0})
            else
                tab.Button.TextColor3 = Theme.Muted
                tab.Page.Visible = false
            end
        end
    end

    function WindowAPI:CreateTab(name)
        local TabBtn = new("TextButton", {Parent = Side, Text = name, Size = UDim2.new(1, -16, 0, 28), BackgroundTransparency = 1, TextColor3 = Theme.Muted, Font = Enum.Font.Gotham, TextSize = 14, AutoButtonColor = false})
        TabBtn.MouseEnter:Connect(function() twn(TabBtn, {TextColor3 = Theme.Text}, TweenInfo.new(0.12)) end)
        TabBtn.MouseLeave:Connect(function() if TabBtn.TextColor3 ~= Theme.Text then twn(TabBtn, {TextColor3 = Theme.Muted}, TweenInfo.new(0.12)) end end)

        local Page = new("Frame", {Parent = Pages, Name = name .. "_Page", BackgroundColor3 = Theme.Background, Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), Visible = false, BorderSizePixel = 0})
        local PageScroll = new("ScrollingFrame", {Parent = Page, Size = UDim2.new(1, -24, 1, -24), Position = UDim2.new(0, 12, 0, 12), BackgroundTransparency = 1, ScrollBarThickness = 6})
        new("UIListLayout", {Parent = PageScroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)})

        local tabObj = {Name = name, Button = TabBtn, Page = Page, Sections = {}}
        table.insert(WindowAPI._tabs, tabObj)

        -- if first tab -> activate
        if #WindowAPI._tabs == 1 then
            setActive(name)
        end

        function tabObj:CreateSection(title)
            local SecFrame = new("Frame", {Parent = PageScroll, BackgroundColor3 = Theme.Panel, Size = UDim2.new(1,0,0,120), BorderSizePixel = 0})
            new("UICorner", {Parent = SecFrame, CornerRadius = UDim.new(0,6)})
            local SecTitle = new("TextLabel", {Parent = SecFrame, Text = title, Size = UDim2.new(1, -16, 0, 24), Position = UDim2.new(0,8,0,8), BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})

            local ContentHolder = new("Frame", {Parent = SecFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -16, 1, -40), Position = UDim2.new(0,8,0,36)})
            new("UIListLayout", {Parent = ContentHolder, Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder})

            local secAPI = {}
            function secAPI:CreateLabel(name)
                local lbl = new("TextLabel", {Parent = ContentHolder, Text = name, Size = UDim2.new(1,0,0,18), BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
                return lbl
            end

            function secAPI:CreateButton(opt)
                opt = opt or {}
                local btn = new("TextButton", {Parent = ContentHolder, Text = opt.Name or "Button", Size = UDim2.new(1,0,0,28), BackgroundColor3 = Theme.Panel, AutoButtonColor = false, Font = Enum.Font.GothamSemibold, TextSize = 13, TextColor3 = Theme.Text})
                new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})
                btn.MouseButton1Click:Connect(function()
                    if opt.Callback then pcall(opt.Callback) end
                    twn(btn, {BackgroundColor3 = Theme.Background}, TweenInfo.new(0.08))
                    delay(0.08, function() twn(btn, {BackgroundColor3 = Theme.Panel}, TweenInfo.new(0.12)) end)
                end)
                return btn
            end

            function secAPI:CreateToggle(opt)
                opt = opt or {}
                local container = new("Frame", {Parent = ContentHolder, Size = UDim2.new(1,0,0,28), BackgroundTransparency = 1})
                local txt = new("TextLabel", {Parent = container, Text = opt.Name or "Toggle", Size = UDim2.new(1, -44, 1, 0), Position = UDim2.new(0,8,0,0), BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
                local box = new("TextButton", {Parent = container, Size = UDim2.new(0,36,0,20), Position = UDim2.new(1, -44, 0.5, -10), BackgroundColor3 = Theme.Panel, AutoButtonColor = false, Text = "", BorderSizePixel = 0})
                new("UICorner", {Parent = box, CornerRadius = UDim.new(0,6)})
                local dot = new("Frame", {Parent = box, Size = UDim2.new(0,16,0,16), Position = UDim2.new(0,2,0.5,-8), BackgroundColor3 = Theme.Muted})
                new("UICorner", {Parent = dot, CornerRadius = UDim.new(0,8)})

                local state = opt.Default == true
                local function updateVisual()
                    if state then
                        twn(dot, {Position = UDim2.new(1, -18, 0.5, -8)})
                        twn(box, {BackgroundColor3 = Theme.Accent})
                    else
                        twn(dot, {Position = UDim2.new(0,2,0.5,-8)})
                        twn(box, {BackgroundColor3 = Theme.Panel})
                    end
                end
                updateVisual()

                box.MouseButton1Click:Connect(function()
                    state = not state
                    updateVisual()
                    if opt.Callback then pcall(opt.Callback, state) end
                end)

                return {Toggle = box, Get = function() return state end, Set = function(v) state = v; updateVisual() end}
            end

            function secAPI:CreateDropdown(opt)
                opt = opt or {}
                local name = opt.Name or "Dropdown"
                local options = opt.Options or {}
                local multi = opt.Multi or false
                local default = opt.Default or (multi and {} or nil)

                local container = new("Frame", {Parent = ContentHolder, Size = UDim2.new(1,0,0,26), BackgroundTransparency = 1})
                local txt = new("TextLabel", {Parent = container, Text = name, Size = UDim2.new(1,-150,1,0), Position = UDim2.new(0,8,0,0), BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
                local selBox = new("TextButton", {Parent = container, Size = UDim2.new(0,130,0,22), Position = UDim2.new(1, -138, 0.5, -11), BackgroundColor3 = Theme.Panel, Text = "Select", AutoButtonColor = false, BorderSizePixel = 0})
                new("UICorner", {Parent = selBox, CornerRadius = UDim.new(0,6)})
                local arrow = new("TextLabel", {Parent = selBox, Text = "▾", Size = UDim2.new(0,24,1,0), Position = UDim2.new(1, -24, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Muted, Font = Enum.Font.Gotham, TextSize = 14})
                local selected = {}
                if multi and type(default) == "table" then
                    for _,v in ipairs(default) do selected[v]=true end
                elseif default then selected[default]=true end

                local DropdownFrame = new("Frame", {Parent = Page, BackgroundColor3 = Theme.Panel, Size = UDim2.new(0, 300, 0, math.min(200, #options * 28 + 12)), Position = UDim2.new(0.5, -150, 0.5, -80), Visible = false, ZIndex = 10})
                new("UICorner", {Parent = DropdownFrame, CornerRadius = UDim.new(0,6)})
                local DFscroll = new("ScrollingFrame", {Parent = DropdownFrame, Size = UDim2.new(1, -12, 1, -12), Position = UDim2.new(0,6,0,6), BackgroundTransparency = 1, ScrollBarThickness = 6})
                DFscroll.CanvasSize = UDim2.new(0,0,0,#options * 28 + 6)
                local DFlayout = new("UIListLayout", {Parent = DFscroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,4)})

                local function refreshLabel()
                    local keys = {}
                    for k,v in pairs(selected) do if v then table.insert(keys,k) end end
                    if #keys == 0 then selBox.Text = "Select" else selBox.Text = (#keys>1 and (#keys .. " selected") or keys[1]) end
                end
                refreshLabel()

                for i,optv in ipairs(options) do
                    local item = new("TextButton", {Parent = DFscroll, Text = optv, Size = UDim2.new(1,0,0,24), BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 13})
                    item.MouseButton1Click:Connect(function()
                        if multi then
                            selected[optv] = not selected[optv]
                        else
                            for k,_ in pairs(selected) do selected[k] = false end
                            selected[optv] = true
                        end
                        refreshLabel()
                        if opt.Callback then
                            if multi then
                                local out = {}
                                for k,v in pairs(selected) do if v then table.insert(out,k) end end
                                pcall(opt.Callback, out)
                            else
                                pcall(opt.Callback, optv)
                            end
                        end
                    end)
                end

                -- toggle dropdown visibility
                selBox.MouseButton1Click:Connect(function()
                    DropdownFrame.Visible = not DropdownFrame.Visible
                    DropdownFrame.Position = UDim2.new(0.5, -150, 0.5, -80)
                end)

                -- close on outside click
                UserInputService.InputBegan:Connect(function(input, gpe)
                    if gpe then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mouse = UserInputService:GetMouseLocation()
                        -- naive close: hide if visible and click not on DF (skip pixel-perfect)
                        if DropdownFrame.Visible then
                            -- compute bounds
                            local absPos = DropdownFrame.AbsolutePosition
                            local absSize = DropdownFrame.AbsoluteSize
                            if not (mouse.X >= absPos.X and mouse.X <= absPos.X + absSize.X and mouse.Y >= absPos.Y and mouse.Y <= absPos.Y + absSize.Y) then
                                DropdownFrame.Visible = false
                            end
                        end
                    end
                end)

                return {Get = function()
                    if multi then
                        local out = {}
                        for k,v in pairs(selected) do if v then table.insert(out,k) end end
                        return out
                    else
                        for k,v in pairs(selected) do if v then return k end end
                        return nil
                    end
                end}
            end

            function secAPI:CreateSlider(opt)
                opt = opt or {}
                local container = new("Frame", {Parent = ContentHolder, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,36)})
                local title = new("TextLabel", {Parent = container, Text = opt.Name or "Slider", Size = UDim2.new(1,-16,0,18), Position = UDim2.new(0,8,0,0), BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
                local bar = new("Frame", {Parent = container, BackgroundColor3 = Theme.Panel, Size = UDim2.new(1,-16,0,12), Position = UDim2.new(0,8,0,18), BorderSizePixel = 0})
                new("UICorner", {Parent = bar, CornerRadius = UDim.new(0,6)})
                local fill = new("Frame", {Parent = bar, BackgroundColor3 = Theme.Accent, Size = UDim2.new(0,0,1,0)})
                local dragging = false
                local min = opt.Min or 0
                local max = opt.Max or 100
                local value = opt.Default or min

                local function updateVal(x)
                    local abs = bar.AbsolutePosition.X
                    local width = bar.AbsoluteSize.X
                    local pct = math.clamp((x - abs) / width, 0, 1)
                    value = math.floor((min + (max - min) * pct)*100)/100
                    fill.Size = UDim2.new(pct,0,1,0)
                    if opt.Callback then pcall(opt.Callback, value) end
                end

                bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true; updateVal(input.Position.X)
                    end
                end)
                bar.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateVal(input.Position.X)
                    end
                end)

                -- initial
                fill.Size = UDim2.new( (value - min) / (max - min), 0, 1, 0)
                return {Get = function() return value end, Set = function(v) value = math.clamp(v,min,max); fill.Size = UDim2.new((value-min)/(max-min),0,1,0) end}
            end

            return secAPI
        end

        -- hook tab button
        TabBtn.MouseButton1Click:Connect(function()
            setActive(name)
        end)

        return tabObj
    end

    -- attach UI to player's PlayerGui (if available)
    local function attachToPlayerGui()
        local player = game.Players.LocalPlayer
        if player and player:FindFirstChild("PlayerGui") then
            UI.Parent = player:FindFirstChild("PlayerGui")
        else
            -- fallback
            UI.Parent = StarterGui
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
        end
    end

    attachToPlayerGui()

    return WindowAPI
end

-- expose theme config
function Library:SetTheme(tbl)
    for k,v in pairs(tbl) do if Theme[k] ~= nil then Theme[k] = v end end
end

-- auto-run: return library
return function()
    return Library
end

