Heist = {}
RegisterNetEvent("unheist:client:syncHeist", function(heistData)
    Heist = heistData
    print(json.encode(Heist))
end)
