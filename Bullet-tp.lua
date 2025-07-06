getgenv().TeleportConfig = {
    Targets = {},
    Enabled = true
}
getgenv().OriginalTransparency = {}

local Client = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

StarterGui:SetCore("SendNotification", {
    Title = "THIS SCRIPT WAS MADE BY RYAN BITCH",
    Text = "THIS SCRIPT WAS MADE BY RYAN BITCH",
    Duration = 5
})

StarterGui:SetCore("SendNotification", {
    Title = "LOOK AT THIS",
    Text = "WHEN PEOPLE TARGETTED THEY BECOME INVISIBLE",
    Duration = 5
})

task.delay(300, function()
    StarterGui:SetCore("SendNotification", {
        Title = "5 MINUTES LATER",
        Text = "THIS SCRIPT WAS MADE BY RYAN BITCH",
        Duration = 5
    })
end)

local function CreateTeleportGUI()
    local gui = Client.PlayerGui:FindFirstChild("TeleportGUI")
    if gui then gui:Destroy() end

    gui = Instance.new("ScreenGui", Client.PlayerGui)
    gui.Name = "TeleportGUI"
    gui.ResetOnSpawn = false

    local SideFrame = Instance.new("Frame", gui)
    SideFrame.Size = UDim2.new(0, 200, 0, 360)
    SideFrame.Position = UDim2.new(0, 10, 0, 10)
    SideFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    SideFrame.BackgroundTransparency = 0.4

    local Scroll = Instance.new("ScrollingFrame", SideFrame)
    Scroll.Size = UDim2.new(1,0,1,0)
    Scroll.CanvasSize = UDim2.new(0,0,5,0)
    Scroll.ScrollBarThickness = 1
    Scroll.BackgroundTransparency = 1

    local Layout = Instance.new("UIListLayout", Scroll)
    Layout.Padding = UDim.new(0, 5)

    local function RefreshPlayerList()
        for _, child in pairs(Scroll:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for _,v in pairs(game.Players:GetPlayers()) do
            if v ~= Client then
                local Toggle = Instance.new("TextButton", Scroll)
                Toggle.Size = UDim2.new(0,180,0,30)
                Toggle.TextColor3 = Color3.fromRGB(255,255,255)
                Toggle.BackgroundColor3 = Color3.fromRGB(50,50,50)
                Toggle.Text = v.DisplayName.." - [OFF]"

                if getgenv().TeleportConfig.Targets[v.UserId] then
                    Toggle.Text = v.DisplayName.." - [ON]"
                end

                Toggle.MouseButton1Click:Connect(function()
                    local id = v.UserId
                    if getgenv().TeleportConfig.Targets[id] then
                        getgenv().TeleportConfig.Targets[id] = nil
                        Toggle.Text = v.DisplayName.." - [OFF]"
                    else
                        getgenv().TeleportConfig.Targets[id] = true
                        Toggle.Text = v.DisplayName.." - [ON]"
                    end
                end)
            end
        end
    end

    RefreshPlayerList()

    game.Players.PlayerAdded:Connect(RefreshPlayerList)
    game.Players.PlayerRemoving:Connect(RefreshPlayerList)

    local ToggleGUI = Instance.new("TextButton", gui)
    ToggleGUI.Size = UDim2.new(0, 180, 0, 30)
    ToggleGUI.Position = UDim2.new(0.5, -90, 0, 5)
    ToggleGUI.Text = "Hide Teleport GUI"
    ToggleGUI.TextColor3 = Color3.fromRGB(255,255,255)
    ToggleGUI.BackgroundColor3 = Color3.fromRGB(40,40,40)

    ToggleGUI.MouseButton1Click:Connect(function()
        SideFrame.Visible = not SideFrame.Visible
        ToggleGUI.Text = SideFrame.Visible and "Hide Teleport GUI" or "Show Teleport GUI"
    end)
end

CreateTeleportGUI()

RunService.RenderStepped:Connect(function()
    if not getgenv().TeleportConfig.Enabled then return end
    if not Client.Character or not Client.Character:FindFirstChild("HumanoidRootPart") then return end

    local tool = Client.Character:FindFirstChildOfClass("Tool")
    if not tool then return end

    local pos, dir
    if tool:FindFirstChild("Handle") then
        pos = tool.Handle.Position
        dir = tool.Handle.CFrame.LookVector
    else
        pos = Client.Character.HumanoidRootPart.Position
        dir = Client.Character.HumanoidRootPart.CFrame.LookVector
    end

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= Client and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local id = player.UserId
            if getgenv().TeleportConfig.Targets[id] then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + dir * 3)

                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if not getgenv().OriginalTransparency[part] then
                            getgenv().OriginalTransparency[part] = { Transparency = part.Transparency, CanCollide = part.CanCollide }
                        end
                        part.Transparency = 1
                        part.CanCollide = false
                    elseif part:IsA("Decal") then
                        if not getgenv().OriginalTransparency[part] then
                            getgenv().OriginalTransparency[part] = { Transparency = part.Transparency }
                        end
                        part.Transparency = 1
                    end
                end
            else
                for _, part in pairs(player.Character:GetDescendants()) do
                    local saved = getgenv().OriginalTransparency[part]
                    if saved then
                        part.Transparency = saved.Transparency
                        if part:IsA("BasePart") then
                            part.CanCollide = saved.CanCollide
                        end
                        getgenv().OriginalTransparency[part] = nil
                    end
                end
            end
        end
    end
end)
