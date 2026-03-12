local cloneref = cloneref or function(i: Instance) return i; end;

local Players: Players = cloneref(game:GetService("Players"));
local UIS: UserInputService = cloneref(game:GetService("UserInputService"));

local plr = Players.LocalPlayer;
local cam = workspace.CurrentCamera;

local isMobile = UIS:GetDeviceType() == Enum.DeviceType.Phone;

local rp = RaycastParams.new();
rp.FilterType = Enum.RaycastFilterType.Exclude;
rp.IgnoreWater = true;

local npc = workspace.NPCSFolder;
local bf = workspace.BloodFolder;

local setup = function(char: Model)
    if not char then return; end;
    rp.FilterDescendantsInstances = {char, bf:FindFirstChild("ALWAYSHERE", true), bf:FindFirstChild("CheckingWalking", true), bf:FindFirstChild("INVISBARRIERS", true), bf:FindFirstChild("Spawns", true), bf:FindFirstChild("TREES", true), bf:FindFirstChild("InvisibleWall", true), bf:FindFirstChild("Cleaning windows", true)};
    for _, v: Instance in next, bf:GetDescendants() do
        if v.Name:lower():match("window", 1) then
            rp.FilterDescendantsInstances[#rp.FilterDescendantsInstances+1] = v;
        end;
    end;
end

setup(plr.Character);

return function(a: boolean)
    if a then
        plr.CharacterAdded:Once(setup);
    else
        plr.CharacterAdded:Connect(setup);
    end;

    local isSameTeam = function(char: Model)
        if plr.Character then
            return (char:FindFirstChild("TEAM1") and plr.Character:FindFirstChild("TEAM1")) or (char:FindFirstChild("TEAM2") and plr.Character:FindFirstChild("TEAM2"))--[[ or ((plr.PlayerGui:FindFirstChild("RSOD") and plr.PlayerGui.RSOD:FindFirstChild("Role") and plr.PlayerGui.RSOD.Role.Text:lower() == "vigilante") and (char:FindFirstChild("weap_cl", true) or (player and player.Backpack:FindFirstChild("weap_cl", true)) or false) or false)]];
        end;
        return true;
    end;

    local isVisible = function(part: BasePart, origin: Vector3): (boolean, Instance?)
        if not part then return false, nil; end;

        local dir = part.Position - origin;
        local result: RaycastResult = workspace:Raycast(origin, dir, rp);
        if not result then return true, nil; end;

        if result.Instance:IsDescendantOf(part.Parent) then
            return true, result.Instance;
        end;

        return false, result.Instance;
    end;

    local getTarget = function(origin: Vector3): BasePart
        local cPart, cDistance = nil, 300;

        for _, char: Model in next, npc:GetChildren() do
            if char == plr.Character or isSameTeam(char) or char:FindFirstChildOfClass("ForceField") or (char:FindFirstChild("Humanoid") and char.Humanoid.Health <= 0) or (char:FindFirstChild("PlayerThings") and char.PlayerThings:FindFirstChild("Downed") and char.PlayerThings.Downed.Value) then continue; end;

            local tPart: BasePart = char:FindFirstChild("Head") or char.PrimaryPart or char:FindFirstChild("HumanoidRootPart");
            if not tPart then continue; end;

            local pos, onScreen = cam:WorldToViewportPoint(tPart.Position);
            if not onScreen then continue; end;

            local v, nTPart = isVisible(tPart, origin);
            if not v then 
                v, nTPart = isVisible(char.PrimaryPart or char:FindFirstChild("HumanoidRootPart"), origin);
                if not v then continue; end;
            end;

            if nTPart then tPart = nTPart; end;

            local distance = isMobile and Vector2.new(pos.X, pos.Y).Magnitude or (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude;
            if distance < cDistance then
                cPart = tPart;
                cDistance = distance;
            end;
        end;

        return cPart;
    end;

    return getTarget;
end;
