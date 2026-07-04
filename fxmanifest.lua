fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'ManiMods'
description 'Union Depository Heist'
version '1.0.0'

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

shared_scripts {
    '@jet-lib/init.lua',
}

files {
    'config.lua',
    'data/*.lua'
}
