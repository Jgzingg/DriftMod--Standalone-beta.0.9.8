fx_version 'cerulean'
game 'gta5'

author 'Seu Nome ou Equipe'
description 'Mod de drift robusto e configurável'
version '2.0.0'

-- Define o nome do recurso para a comunicação NUI
resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'
nui_main 'html/index.html'

client_script 'config.lua'
client_script 'client.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/fonts/*' -- Se você adicionar fontes customizadas
}

