game 'gta5'
fx_version 'cerulean'

author 'Pitrs'


lua54 'yes'
version '1.0.0'

client_scripts {
    'cl.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'sv.lua'
}

shared_scripts {
    'config.lua',
}