local config = require("config")

Heist = {
    crew = {},
    entered = false,
    vaultOpened = false,

    cellAOpened = false,
    cellBOpened = false,

    breached = false,

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

function Class:set(key, value)
    self[key] = value

    self:action(function(src)
        TriggerClientEvent("unheist:client:syncKey", src, key, value)
    end)
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

    if not config.debug then return end

    local players = GetPlayers()

    for i = 1, #players do
        local src = players[i]
        Heist:add(src)
    end

    for key, value in pairs(config.debugData) do
        Heist:set(key, value)
    end
end)
