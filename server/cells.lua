RegisterNetEvent("unheist:server:plantCellBomb", function(key)
    if not Heist.crew[source] then return end

    -- if not remove item then return end

    Heist:set(("cell%sOpened"):format(string.upper(key)), true)

    TriggerClientEvent("unheist:client:openCellDoor", -1, key)
end)
