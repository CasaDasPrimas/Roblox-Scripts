Main:AddButton({
    Title = 'Shiftlock',
    Description = '',
    Callback = function()
        local ScreenGui = Instance.new('ScreenGui')
        local Button = Instance.new('ImageButton')
        local Cursor = Instance.new('ImageLabel')
        local States = {
            Off = 'rbxasset://textures/ui/mouseLock_off@2x.png',
            On = 'rbxasset://textures/ui/mouseLock_on@2x.png',
            Lock = 'rbxasset://textures/MouseLockedCursor.png'
        }

        local MaxLength = 900000
        local DisabledOffset = CFrame.new(-1.7, 0, 0)
        local EnabledOffset = CFrame.new(1.7, 0, 0)

        ScreenGui.ResetOnSpawn = false
        ScreenGui.Name = 'Shiftlock'
        ScreenGui.Parent = Folder

        Button.Visible = false

        Cursor.SizeConstraint = Enum.SizeConstraint.RelativeXX
        Cursor.Position = UDim2.new(0.5, 0, 0.5, 0)
        Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
        Cursor.Size = UDim2.new(0.03, 0, 0.03, 0)
        Cursor.BackgroundTransparency = 1
        Cursor.Image = States.Lock
        Cursor.Parent = ScreenGui
        Cursor.Visible = false
        Cursor.Name = 'Cursor'

        local shiftlockEnabled = false

        local function toggleShiftlock()
            shiftlockEnabled = not shiftlockEnabled

            task.spawn(function()
                while shiftlockEnabled do
                    Rs.RenderStepped:Wait()
                    pcall(function()
                        if Character and Character:FindFirstChild('Humanoid') and workspace.CurrentCamera and not TempStats.Ragdoll.Value and not TempStats.Captured.Value then
                            if IsMobile then
                                Button.Image = States.On
                            end
                            Character.Humanoid.AutoRotate = false
                            Cursor.Visible = true

                            GetRoot(Character).CFrame = CFrame.new(
                                GetRoot(Character).Position,
                                Vector3.new(
                                    workspace.CurrentCamera.CFrame.LookVector.X * MaxLength,
                                    GetRoot(Character).Position.Y,
                                    workspace.CurrentCamera.CFrame.LookVector.Z * MaxLength
                                )
                            )

                            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * EnabledOffset
                            workspace.CurrentCamera.Focus = CFrame.fromMatrix(
                                workspace.CurrentCamera.Focus.Position,
                                workspace.CurrentCamera.CFrame.RightVector,
                                workspace.CurrentCamera.CFrame.UpVector
                            ) * EnabledOffset
                        else
                            Cursor.Visible = false
                            if Character and Character:FindFirstChild('Humanoid') then
                                Character.Humanoid.AutoRotate = true
                            end
                            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * DisabledOffset
                        end
                    end)
                    if not shiftlockEnabled or not _G.FTF then break end
                end

                if IsMobile then
                    Button.Image = States.Off
                end
                Cursor.Visible = false
                if Character and Character:FindFirstChild('Humanoid') then
                    Character.Humanoid.AutoRotate = true
                end
                workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * DisabledOffset
            end)
        end

        if IsMobile then
            Button.Size = UDim2.new(0.0636147112, 0, 0.0661305636, 0)
            Button.SizeConstraint = Enum.SizeConstraint.RelativeXX
            Button.Position = UDim2.new(0.8, 0, 0.35, 0)
            Button.BackgroundTransparency = 1
            Button.Visible = true
            Button.Parent = ScreenGui
            Button.Image = States.Off

            Button.MouseButton1Click:Connect(toggleShiftlock)
        else
            Uis.InputBegan:Connect(function(input, gameProcessed)
                if input.KeyCode == Enum.KeyCode.LeftControl and not gameProcessed then
                    toggleShiftlock()
                end
            end)
        end
    end
})
