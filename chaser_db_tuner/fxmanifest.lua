fx_version 'bodacious'
game 'gta5'
lua54 'yes'

author 'Legacy_DMC'
description 'Discord: https://discord.gg/KsvJWyvpZU'
version '1.0'

server_script 'server.lua'
client_script 'menuapi.lua'
client_script 'client.lua'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/styles/style.css',
    'ui/scripts/script.js'
}
  
escrow_ignore {
  'config.lua'
  }