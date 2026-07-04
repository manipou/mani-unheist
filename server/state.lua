local cachedEvents = {}

Heist = {
    crew = {},
    inProgress = false,
    breached = false,
    vaultOpened = false,

    overwritten = false,
}

local Class = {}
Class.__index = Class

---@param source integer
function Class:add(source)
    local src = tonumber(source)
    if not src then return end

    self.crew[src] = true

    TriggerClientEvent("unheist:client:syncHeist", src, Heist)
end

---@param source integer
function Class:remove(source)
    local src = tonumber(source)
    if not src then return end

    self.crew[src] = nil

    TriggerClientEvent("unHeist:client:syncHeist", src, {})
end

---@param action function
function Class:action(action)
    for src, _ in pairs(self.crew) do
        action(src)
    end
end

function Class:sync()
    self:action(function(src)
        TriggerClientEvent("unheist:client:syncHeist", src, Heist)
    end)
end

function Class:onUpdate(key, event)
    cachedEvents[key] = cachedEvents[key] or {}
    cachedEvents[key][#cachedEvents[key] + 1] = event
end

function Class:set(key, value)
    self[key] = value

    local events = cachedEvents[key]
    if not events then return end

    for i = 1, #events do
        events[i](value)
    end
end

AddEventHandler('playerDropped', function()
    local src = source
    if Heist.crew[src] then
        Heist:remove(src)
    end
end)

CreateThread(function()
    setmetatable(Heist, Class)

    Wait(250)

    local players = GetPlayers()

    for i = 1, #players do
        local src = players[i]
        Heist:add(src)
    end
end)
