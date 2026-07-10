local cachedEvents = {}

local Class = {}
Class.__index = Class

function Class:set(key, value)
    self[key] = value

    local events = cachedEvents[key]
    if not events then return end

    for i = 1, #events do
        events[i](value)
    end
end

function Class:onUpdate(key, event)
    cachedEvents[key] = cachedEvents[key] or {}
    cachedEvents[key][#cachedEvents[key] + 1] = event
end

Heist = {}
setmetatable(Heist, Class)

RegisterNetEvent("unheist:client:syncHeist", function(heistData)
    Heist = heistData

    setmetatable(Heist, Class)
end)

RegisterNetEvent("unheist:client:syncKey", function(key, value)
    Heist:set(key, value)
end)
