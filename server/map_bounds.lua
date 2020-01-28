local interval_ms = 1000

local admins_bounds = {}

--admins_bounds["76561197972837186"] = true
--admins_bounds["steamid"] = true

local curbounds = {}

local default = {
    maxx = 264286,
    maxy = 264744,
    minx = -250000,
    miny = -340190
}

function check_bounds_tim()
    for i, ply in pairs(GetAllPlayers()) do
       if GetPlayerVehicle(ply) == 0 then
           local x,y,z = GetPlayerLocation(ply)
           if (x>curbounds.maxx+500) then
            if (GetDistance3D(x, y, z, curbounds.maxx-100, y, z)>24000) then
            SetPlayerLocation(ply, curbounds.maxx-100, y, z)
            else
                CallRemoteEvent(ply,"TraceLineToGround",true,"maxx",curbounds.maxx-100)
            end
           elseif (y>curbounds.maxy+500) then
            if (GetDistance3D(x, y, z, x, curbounds.maxy-100, z)>24000) then
            SetPlayerLocation(ply, x, curbounds.maxy-100, z)
        else
            CallRemoteEvent(ply,"TraceLineToGround",true,"maxy",curbounds.maxy-100)
        end
        elseif (x<curbounds.minx-500) then
            if (GetDistance3D(x, y, z, curbounds.minx+100, y, z)>24000) then
            SetPlayerLocation(ply, curbounds.minx+100, y, z)
        else
            CallRemoteEvent(ply,"TraceLineToGround",true,"minx",curbounds.minx+100)
        end
        elseif (y<curbounds.miny-500) then
            if (GetDistance3D(x, y, z, x, curbounds.miny+100, z)>24000) then
            SetPlayerLocation(ply, x, curbounds.miny+100, z)
        else
            CallRemoteEvent(ply,"TraceLineToGround",true,"miny",curbounds.miny+100)
        end
         end
        else
            local veh = GetPlayerVehicle(ply)
            local x, y, z = GetVehicleLocation(veh)
            if (GetVehicleModelName(veh)=="Helicopter_01" or GetVehicleModelName(veh)=="Helicopter_02") then
                if (x>curbounds.maxx) then
                    SetVehicleLocation(veh, curbounds.maxx-100, y, z)
                   elseif (y>curbounds.maxy) then
                    SetVehicleLocation(veh, x, curbounds.maxy-100, z)
                elseif (x<curbounds.minx) then
                    SetVehicleLocation(veh, curbounds.minx+100, y, z)
                elseif (y<curbounds.miny) then
                    SetVehicleLocation(veh, x, curbounds.miny+100, z)
                 end
            else
                if (x>curbounds.maxx) then
                        CallRemoteEvent(ply,"TraceLineToGround",false,"maxx",curbounds.maxx-250)
                   elseif (y>curbounds.maxy) then
                    CallRemoteEvent(ply,"TraceLineToGround",false,"maxy",curbounds.maxy-250)
                elseif (x<curbounds.minx) then
                    CallRemoteEvent(ply,"TraceLineToGround",false,"minx",curbounds.minx+250)
                elseif (y<curbounds.miny) then
                    CallRemoteEvent(ply,"TraceLineToGround",false,"miny",curbounds.miny+250)
                end
            end
        end
    end
end

AddEvent("OnPackageStart", function()
    CreateTimer(check_bounds_tim, interval_ms)
    local file = io.open("saved_bounds.json", 'r') 
    if (file) then 
        local contents = file:read("*a")
        curbounds = json_decode(contents);
        io.close(file)
    else
        local file = io.open("saved_bounds.json", 'w') 
        if file then
            local contents = json_encode(default)
            file:write(contents)
            io.close(file)
            curbounds=default
        end
    end
end)

AddCommand("bounds", function(ply)
    if admins_bounds[tostring(GetPlayerSteamId(ply))] then
    CallRemoteEvent(ply,"BoundsSelection")
    local file = io.open("saved_bounds.json", 'w') 
        if file then
            local contents = json_encode(default)
            file:write(contents)
            io.close(file)
            curbounds=default
            for i, plyy in pairs(GetAllPlayers()) do
                CallRemoteEvent(plyy,"RepBounds",curbounds)
            end
        end
    else
        AddPlayerChat(ply,"You're not allowed to do this")
    end
end)

AddRemoteEvent("BoundsRep", function(ply,maxx,maxy,minx,miny)
    local file = io.open("saved_bounds.json", 'w') 
        if file then
            local tblencode = {
                maxx = maxx,
                maxy = maxy,
                minx = minx,
                miny = miny
            }
            local contents = json_encode(tblencode)
            file:write(contents)
            io.close(file)
            curbounds=tblencode
            for i, plyy in pairs(GetAllPlayers()) do
                CallRemoteEvent(plyy,"RepBounds",curbounds)
            end
        end
end)

AddRemoteEvent("RepTraceply", function(ply,impactZ,side)
    impactZ=impactZ+100
    local x,y,z = GetPlayerLocation(ply)
    if (side=="maxx") then
    SetPlayerLocation(ply, curbounds.maxx-100, y, impactZ)
    elseif (side=="maxy") then
        SetPlayerLocation(ply, x, curbounds.maxy-100, impactZ)
    elseif (side=="minx") then
        SetPlayerLocation(ply, curbounds.minx+100, y, impactZ)

    elseif (side=="miny") then
        SetPlayerLocation(ply, x, curbounds.miny+100, impactZ)

    end
end)

AddRemoteEvent("RepTraceveh", function(ply,impactZ,side)
    impactZ=impactZ+5
    local veh = GetPlayerVehicle(ply)
    local x,y,z = GetVehicleLocation(veh)
    if impactZ-z<-15 then
        local rx, ry, rz = GetVehicleRotation(veh)
        SetVehicleRotation(veh, 0, ry, 0)
    end
    if (side=="maxx") then
        SetVehicleLocation(veh, curbounds.maxx-250, y, impactZ)
    elseif (side=="maxy") then
        SetVehicleLocation(veh, x, curbounds.maxy-250, impactZ)
    elseif (side=="minx") then
        SetVehicleLocation(veh, curbounds.minx+250, y, impactZ)

    elseif (side=="miny") then
        SetVehicleLocation(veh, x, curbounds.miny+250, impactZ)

    end
end)

AddEvent("OnPlayerJoin",function(ply)
    CallRemoteEvent(ply,"RepBounds",curbounds)

end)