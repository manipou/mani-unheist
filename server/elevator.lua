local config = require "config"
local elevators = require "data.elevators"

GlobalState.Mani_Un_ElevatorBusy = false

local cooldown = false

RegisterNetEvent('unheist:server:takeElevator', function(id, players)
    local src = source
    local elevator = elevators[id]
    if cooldown or not elevator then return end

    local playerData = Jet.Framework.GetPlayerData(src)
    if not playerData then return end

    if not Heist.overwritten then
        if playerData.job.name ~= config.policeJob and not Heist.entered then
            Heist:set("entered", true)
        elseif playerData.job.name == config.policeJob and Heist.entered then
            Heist:set("overwritten", true)
        end
    end

    for i = 1, #players do
        local player = players[i]

        TriggerClientEvent('unheist:client:takeElevator', player.source, id)
    end

    TriggerClientEvent('unheist:client:doorTimeout', -1)

    cooldown = true
    SetTimeout(10000, function()
        cooldown = false
    end)
end)
