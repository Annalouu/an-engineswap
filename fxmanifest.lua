--[[ Metadata ]]--
fx_version 'cerulean'
games { 'gta5' }

-- [[ Author ]] --
author 'AnnaLou. <https://discordapp.com/users/585839151564193812>'
description 'Annalouu | Engine Swap!'
github 'https://github.com/Annalouu/an-engineswap'

-- [[ Version ]] --
version '353'

-- [[ Dependencies ]] --
dependencies { 
  'ox_lib',
}

-- [[ Files ]] --
shared_scripts {
  '@ox_lib/init.lua',
  'bridge/*.lua',
  'shared/*.lua',
}

server_scripts {
  -- Server Events
  'server/*.lua',
}

client_scripts { 
  -- Client Events
  'client/*.lua',
}

files {
  'data/*.lua',
}

-- [[ Tebex ]] --
lua54 'yes'

