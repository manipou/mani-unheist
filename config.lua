local config = {}

config.debug = true

config.debugData = {
    entered = true,
    vaultOpened = true,

    cellAOpened = true,
    cellBOpened = true,

    -- breached = false,

    -- overwritten = false,
}

config.policeJob = "police"

config.elevator = { -- Disabling all these options basically creates an semi-seamless elevator transition (Nearby players might flicker as they teleport)
    randomAnimation = false,
    fadeOut = true,
    shake = false,
    sound = true,
    camera = false,
}

config.cellTimeout = 5000

config.cutter = {
    coords = vec4(25.18, -638.87, 16.0, 94.28),
    type = "server" -- "server" or "client" (server = cutter is spawned on server start serverside - client = cutter is spawned when the heist is started)
}

return config
