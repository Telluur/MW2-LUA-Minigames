print("Using MW2_211")
-- PlayerCmd
giveWeapon = 0x0520000
getCurrentWeapon = 0x05202A0
takeAllWeapons = 0x0520210
takeWeapon = 0x05201B0
switchToWeapon = 0x05207D0
setClientDvar = 0x05221C0
clearPerks = 0x0523640
setPerk = 0x0523350
unsetPerk = 0x0523540
setSpreadOverride = 0x05215B0
setViewModel = 0x0521540
freezeControl = 0x05219E0

-- PlayerCmd #2
suicide = 0x0524740
sayAll = 0x0524CF0
iprintln = 0x0524810
iprintlnbold = 0x0524870
getGuid = 0x0524EA0
showHudSplash = 0x05255D0

-- GSCr
isAlive = 0x0544280
newClientHudElem = 0x052A1E0
exitLevel = 0x05455F0
kickPlayer = 0x0545770
setDvar = 0x0539D70
getDvar = 0x0539E90
getDvarInt = 0x0539EE0
getDvarFloat = 0x0539F30
mapRestart = 0x0545000
setText = 0x052A2E0

destroy = 0x052AFF0

println = 0x05441E0
printlnbold = 0x0544260

-- ScrCmd
playLocalSound = 0x05227F0

-- Hud offsets
IW4 = {
	HUD = {
		OFFSET = {
			x = 0,
			y = 1,
			fontScale = 3,
			font = 4,
			alignX = 5,
			alignY = 6,
			horzAlign = 7,
			vertAlign = 8
		} 
	},
	HECmd = {
		changeFontScaleOverTime = 0x052AD90,
		destroy = 0x052AFF0,
		setPulseFx = 0x052B0D0
	},
	MOD_MELEE = 8
}

ENTITYARRAYA = 0x194B9D0