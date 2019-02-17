local rtdNames = {
	"James Bond",
	"AC130 Gunner",
	"Riot Control",
	"Golden Deagle",
	"Pirate",
	"Tube Noob",
	"Sniper",
	"Handguns"
}

function playerDeath(player, inflictor, attacker, damage, meansOfDeath, iWeapon)
end

function playerThink(player, tick)
	if CALL(isAlive, toEntity(player)) == 1 then
		checkWeapon(player)

	end
end

function checkWeapon(player)
	local wep = playerInfo[player].weapon

	local currWep = CALLREF(getCurrentWeapon, player)

	if currWep ~= wep and currWep ~= "none" then
		CALLREF(takeWeapon, player, currWep);
		CALLREF(giveWeapon, player, wep, 0, playerInfo[player].akimbo);
		CALLREF(switchToWeapon, player, wep);
	end
	if currWep == "none" then
		CALLREF(switchToWeapon, player, wep);
	end
end

function createLevelHUD(player)
	ref = createHUD(player, "Roll: ", "hudbig", 1, "left", "bottom", "left", "bottom", 20, -20)
	playerInfo[player].levelHUD = ref
end

function setWeapon(player, weapon, akimbo)
	playerInfo[player].weapon = weapon
	
	if akimbo ~= nil and akimbo then
		playerInfo[player].akimbo = true
	end
end

function rollTheDice(player)
	playerInfo[player].roll = math.random(#rtdNames)
	local roll = playerInfo[player].roll

	if roll == 1 then
		setWeapon(player, "usp_silencer_tactical_mp")
		playerInfo[player].perks = {"specialty_extendedmelee"}
	elseif roll == 2 then
		setWeapon(player, "ac130_25mm_mp")
	elseif roll == 3 then
		setWeapon(player, "riotshield_mp")
		playerInfo[player].perks = {"specialty_fastsprintrecovery", "specialty_quickdraw", "specialty_marathon", "specialty_extendedmelee"}
	elseif roll == 4 then
		setWeapon(player, "deserteaglegold_mp")
	elseif roll == 5 then
		setWeapon(player, "model1887_akimbo_fmj_mp", true)
	elseif roll == 6 then
		setWeapon(player, "m79_mp", true)
		playerInfo[player].perks = {"specialty_explosivedamage"}	
	elseif roll == 7 then
		setWeapon(player, "cheytac_fmj_xmags_mp")
		playerInfo[player].perks = {
			"specialty_fastsnipe",
			"specialty_fastreload",
			"specialty_fastsprintrecovery",
			"specialty_quickdraw",
			"specialty_bulletdamage",
			"specialty_marathon",
			"specialty_improvedholdbreath"
		}
	elseif roll == 8 then
		setWeapon(player, "defaultweapon_mp")
		playerInfo[player].perks = {"specialty_bulletdamage"}
	else
		print("fuck")
	end
end

function playerSpawned(player)
	playerInfo[player].roll = 0
	playerInfo[player].weapon = ""
	playerInfo[player].perks = {}
	playerInfo[player].akimbo = false

	rollTheDice(player)
	setupPlayer(player)
	CALLREF(setText, playerInfo[player].levelHUD, "Roll: " .. rtdNames[playerInfo[player].roll])
end

function setupPlayer(player)
	local wep = playerInfo[player].weapon

	CALLREF(takeAllWeapons, player);
	CALLREF(clearPerks, player);

	CALLREF(giveWeapon, player, wep, 0, playerInfo[player].akimbo);
	CALLREF(switchToWeapon, player, wep);

	bad_perks = {"specialty_pistoldeath", "specialty_combathigh", "specialty_grenadepulldeath", "specialty_finalstand", "specialty_copycat", "specialty_localjammer"}
	
	for _, perk in pairs(bad_perks) do
		CALLREF(unsetPerk, player, perk);
	end

	for _, perk in pairs(playerInfo[player].perks) do
		CALLREF(setPerk, player, perk, true);
	end
end

function playerConnected(player)
	CALLREF(setClientDvar, player, "cg_fov", 80);
	CALLREF(setClientDvar, player, "cg_fovScale", "1.125");

	playerInfo[player].roll = 0
	playerInfo[player].weapon = ""
	playerInfo[player].perks = {}
	playerInfo[player].akimbo = false

	createLevelHUD(player)
end

function playerDisconnected(player)
	if playerInfo[player] then
		CALLREF(IW4.HECmd.destroy, playerInfo[player].levelHUD)
	end
end
