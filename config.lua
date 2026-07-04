local config = {}

config.debug = false

config.policeJob = "police"

config.elevator = { -- Disabling all these options basically creates an semi-seamless elevator transition (Nearby players might flicker as they teleport)
    randomAnimation = false,
    fadeOut = true,
    shake = false,
    sound = true,
    camera = false,
}

return config
