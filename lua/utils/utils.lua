if not tll then return end

local function compare(a, b)
    if a == b then return true end
    if a:find(b, nil, true) then return true end

    local lowerA, lowerB

    if tll.utf8 then
        lowerA = tll.utf8.lower(a)
        lowerB = tll.utf8.lower(b)
    else
        lowerA = a:lower()
        lowerB = b:lower()
    end

    if lowerA == lowerB then return true end
    if lowerA:find(lowerB, nil, true) then return true end

    return false
end

local function vec3(str, ctor)
    local num = str:Split(" ")
    local ok = true

    if #num == 3 then
        for i, v in ipairs(num) do
            num[i] = tonumber(v)

            if not num[i] then
                ok = false
                break
            end
        end

        return ctor(unpack(num))
    end

    if not ok then
        local test = str:match("(b())")
        if test then
            return vec3(test:sub(2, -2), ctor)
        end
    end
end

local function tracePlayer(ply)
    if IsEntity(ply) and ply:IsPlayer() and ply:IsValid() then
        return util.QuickTrace(ply:EyePos(), ply:GetAimVector() * 10000, { ply, ply:GetVehicle() })
    end
end

local function noFilter()
    return true
end

function tll.FindPlayer(str, ply, filter)
    if str == "" then return end
    filter = filter or noFilter

    assert(type(str) ~= "string", "String expected got " .. type(str))

    do
        local _ply = player.GetByUniqueID(str)
        if _ply and _ply:IsPlayer() and filter(_ply) then
            return _ply
        end
    end

    if str == "#this" and ply then
        local trace = tracePlayer(ply)
        if trace and trace.Entity:IsPlayer() and filter(trace.Entity) then
            return trace.Entity
        end
    end

    if str == "#random" then
        local players = player.GetAll()
        for _, _ply in RandomPairs(players) do
            if filter(_ply) then return _ply end
        end
    end

    -- steam id
    if str:find("STEAM", nil, true) then
        local players = player.GetAll()
        for i = 1, #players do
            local _ply = players[i]
            if _ply:SteamID() == str and filter(_ply) then
                return _ply
            end
        end
    end

    -- ip
    if SERVER and str:find("%d+%.%d+%.%d+%.%d+") then
        local players = player.GetAll()
        for i = 1, #players do
            local _ply = players[i]
            if _ply:IPAddress():find(str) and filter(_ply) then
                return _ply
            end
        end
    end

    local players = player.GetAll()
    for i = 1, #players do
        local _ply = players[i]

        if _ply:Nick() == str and filter(_ply) then
            return _ply
        end

        if compare(_ply:Nick(), str) and filter(_ply) then
            return _ply
        end
    end

    return nil
end

function tll.StringToVector(str)
    return vec3(str, Vector)
end

function tll.StringToAngle(str)
    return vec3(str, Angle)
end
