fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'rdr3'

version '1.2.9'
vorp_checker 'yes'
vorp_name '^5MMS-Beekeeper ^4version Check^3'
vorp_github 'https://github.com/RetryR1v2/mms-beekeeper'

description 'mms-beekeeper'
author 'Markus Mueller'

client_scripts {
	'client/client.lua'
}

server_scripts {
	'server/server.lua',
	'@oxmysql/lib/MySQL.lua',
}

shared_scripts {
    'config.lua',
	'shared/locale.lua',
	'languages/*.lua',
}

files {
    'stream/bee_house_gk_ytyp.ytyp'
}

data_file 'DLC_ITYP_REQUEST' 'stream/bee_house_gk_ytyp.ytyp'

dependency {
	'vorp_core',
}

