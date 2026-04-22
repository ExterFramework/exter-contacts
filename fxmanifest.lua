fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Sobing4413'
description 'NPC Dialog System 4.0'
version '3.1.6'

files {
    'web/**',
    'web/dist/**',
	'web/dist/fonts/**',
	'web/dist/avatars/**.webp',
}

ui_page 'web/index.html'

shared_scripts {
	'shared/config.lua',
	'shared/bridge.lua',
	'shared/fuel.lua'
}

client_scripts {
	'client/client.lua',
	'client/events.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/server.lua',
}

escrow_ignore {
	'shared/**',
	'locales/**',
	'client/**',
	'server/**',
}