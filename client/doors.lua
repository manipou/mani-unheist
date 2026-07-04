local doors = require "data.doors"

RegisterNetEvent('unheist:client:doorTimeout', function()
    Jet.Door.Set("un_elevator_entrance", 1)
    Jet.Door.Set("un_elevator_exit", 1)

    SetTimeout(7500, function()
        Jet.Door.Set("un_elevator_entrance", 0)
        Jet.Door.Set("un_elevator_exit", 0)
    end)
end)

CreateThread(function()
    for i = 1, #doors do
        local door = doors[i]
        Jet.Door.Add(door)
    end
end)
