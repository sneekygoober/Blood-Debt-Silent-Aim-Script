local cloneref = cloneref or function(i: Instance) return i; end;

local Players: Players = cloneref(game:GetService("Players"));
local UIS: UserInputService = cloneref(game:GetService("UserInputService"));

local plr = Players.LocalPlayer;
local cam = workspace.CurrentCamera;

local rp = RaycastParams.new();
rp.FilterType = Enum.RaycastFilterType.Exclude;
rp.IgnoreWater = true;

local npc = workspace.NPCSFolder;
local bf = workspace.BloodFolder;

rp.FilterDescendantsInstances = {plr.Character, bf:FindFirstChild("Folder#ALWAYSHERE", true), bf:FindFirstChild("Folder#CheckingWalking", true), bf:FindFirstChild("Folder#INVISBARRIERS", true), bf:FindFirstChild("Folder#Spawns", true), bf:FindFirstChild("Folder#TREES", true)};

plr.CharacterAdded:Connect(function(char)
    rp.FilterDescendantsInstances = {char, bf:FindFirstChild("Folder#ALWAYSHERE", true), bf:FindFirstChild("Folder#CheckingWalking", true), bf:FindFirstChild("Folder#INVISBARRIERS", true), bf:FindFirstChild("Folder#Spawns", true), bf:FindFirstChild("Folder#TREES", true)};
end);

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
        if char == plr.Character or char:FindFirstChildOfClass("ForceField") or (char:FindFirstChild("Humanoid") and char.Humanoid.Health <= 0) then continue; end;

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

        local distance = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude;
        if distance < cDistance then
            cPart = tPart;
            cDistance = distance;
        end;
    end;

    return cPart;
end;

return getTarget;
