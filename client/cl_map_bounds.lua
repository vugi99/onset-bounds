local selecting = false
local selectphase = 1

local firstx = 0
local firsty = 0
local secx = 0
local secy = 0

local curbounds = {}


AddRemoteEvent("BoundsSelection", function()
    selecting=true
    selectphase=1
    AddPlayerChat("Select first bound (Left click)")
end)

AddRemoteEvent("RepBounds", function(bounds)
    curbounds=bounds
end)

AddRemoteEvent("TraceLineToGround", function(arg,side,val)
    local x,y,z = GetPlayerLocation()
    if (side=="maxx" or side=="minx") then
    local hittype, hitid, impactX, impactY, impactZ = LineTrace(val, y, 25000, val, y, -100)
    if arg then
        CallRemoteEvent("RepTraceply",impactZ,side)
    else
    CallRemoteEvent("RepTraceveh",impactZ,side)
    end
else
    local hittype, hitid, impactX, impactY, impactZ = LineTrace(x, val, 25000, x, val, -100)
    if arg then
        CallRemoteEvent("RepTraceply",impactZ,side)
    else
    CallRemoteEvent("RepTraceveh",impactZ,side)
    end
end
end)

function OnKeyPress(key)
    if selecting then
    if key == "Left Mouse Button" then
        local ScreenX, ScreenY = GetScreenSize()
        SetMouseLocation(ScreenX/2, ScreenY/2)
        local x,y,z = GetMouseHitLocation()
        if (x ~= 0 and y ~= 0) then
            if selectphase==1 then
            firstx=x
            firsty=y
            AddPlayerChat("x1 : " .. x .. " y1 : " .. y)
            AddPlayerChat("Select second bound (Left click)")
            selectphase=2
            elseif selectphase==2 then
                secx=x
                secy=y
                AddPlayerChat("x2 : " .. x .. " y2 : " .. y)
                selecting=false
                local maxx = 0
                local maxy = 0
                local minx = 0
                local miny = 0
                if (firstx==secx or firsty==secy) then
                   AddPlayerChat("Cannot be the same x or the same y")
                else
                    if firstx>secx then
                        maxx=firstx
                        minx=secx
                    else
                        maxx=secx
                        minx=firstx
                    end
                    if firsty>secy then
                        maxy=firsty
                        miny=secy
                    else
                        maxy=secy
                        miny=firsty
                    end
                    CallRemoteEvent("BoundsRep",maxx,maxy,minx,miny)
                end
            end
        else
            AddPlayerChat("Invalid Hit location")
        end
    end
end
end

AddEvent("OnKeyPress",OnKeyPress)

function RestrictPlayerBoundary() -- Pindrought#5849
    if GetPlayerVehicle() == 0 then
    actor = GetPlayerActor(GetPlayerId())
    local x, y, z = GetPlayerLocation()
    if (x>curbounds.maxx) then
        actor:SetActorLocation(FVector(curbounds.maxx-5, y, z+5))
       elseif (y>curbounds.maxy) then
        actor:SetActorLocation(FVector(x, curbounds.maxy-5, z+5))
    elseif (x<curbounds.minx) then
        actor:SetActorLocation(FVector(curbounds.minx+5, y, z+5))
    elseif (y<curbounds.miny) then
        actor:SetActorLocation(FVector(x, curbounds.miny+5, z+5))
    end
end
end
AddEvent("OnGameTick", RestrictPlayerBoundary)