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

local isVisible = function(part: BasePart, origin: Vector3): (boolean, Instance?)
    local char = plr.Character;
    if not (char and part) then return false, nil; end;

    rp.FilterDescendantsInstances = {char};
    for _, v in next, bf do
        if v.Name == "_glass" or v.Name == "deadbodylul" then
            rp.FilterDescendantsInstances[#rp.FilterDescendantsInstances+1] = v;
        end;
    end;
    rp.FilterDescendantsInstances[#rp.FilterDescendantsInstances+1] = bf:QueryDescendants("Folder#ALWAYSHERE")[1];
    rp.FilterDescendantsInstances[#rp.FilterDescendantsInstances+1] = bf:QueryDescendants("Folder#CheckingWalking")[1];
    rp.FilterDescendantsInstances[#rp.FilterDescendantsInstances+1] = bf:QueryDescendants("Folder#INVISBARRIERS")[1];
    rp.FilterDescendantsInstances[#rp.FilterDescendantsInstances+1] = bf:QueryDescendants("Folder#Spawns")[1];
    rp.FilterDescendantsInstances[#rp.FilterDescendantsInstances+1] = bf:QueryDescendants("Folder#TREES")[1];

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
