local gungameWeapons = {
	"ac130_105mm_mp",
	"ac130_40mm_mp",
	"ac130_25mm_mp",
	"striker_grip_silencer_mp",
	"coltanaconda_fmj_mp",
	"mp5k_thermal_mp",
	"model1887_akimbo_fmj_mp",
	"usp_akimbo_fmj_mp",
	"ranger_akimbo_fmj_mp",
	"aa12_silencer_xmags_mp",
	"ump45_thermal_mp",
	"fal_heartbeat_silencer_mp",
	"m16_acog_silencer_mp",
	"riotshield_mp",
	"m79_mp",	
	"rpg_mp",	
	"defaultweapon_mp",
	"aug_silencer_thermal_mp",	
	"m21_silencer_thermal_mp",
	"frag_grenade_mp",		
	"wa2000_acog_xmags_mp",	
	"claymore_mp",	
	"cheytac_acog_silencer_mp",
    "p90_akimbo_fmj_mp",
    "deserteaglegold_mp",
    "coltanaconda_fmj_mp",
	"throwingknife_mp",
	"javelin_mp"
}

-- DO NOT CHANGE BELOW THIS LINE.

version_string = "0.11"

function playerDeath(player, inflictor, attacker, damage, meansOfDeath, iWeapon)
    print(GetName(player) .. " died. meansofdeath: " .. meansOfDeath)
	if(attacker < 18 and meansOfDeath ~= 12) then
		if(meansOfDeath == IW4.MOD_MELEE or player == attacker) then
			demote(player)

			local attWep = CALLREF(getCurrentWeapon, attacker)
			if(attWep == "riotshield_mp") then
				promote(attacker)
			end
            if(meansOfDeath == IW4.MOD_MELEE) then
                playerInfo[attacker].knifes = playerInfo[attacker].knifes + 1
                if ((playerInfo[attacker].knifes ~= 0) and (playerInfo[attacker].knifes % 5) == 0) then
                    for p, _ in pairs(playerInfo) do                    
                        ref, n = createHUD(p, YELLOW .. GetName(attacker) .. " has " .. playerInfo[attacker].knifes .. " knife kills!", "hudsmall", 1, "center", "top", "center", "top", 0, 0);
                        CALLREF(IW4.HECmd.setPulseFx, ref, 50, 4000, 50)
                        destroyAfterTime(ref, 4) -- Destroyed after player leaves?
                    end
                end 
            end
		else
			promote(attacker)
		end
	elseif(meansOfDeath == 11) then
        demote(player)
    end 
end

function demote(player)
	if(playerInfo[player].level > 0) then
		playerInfo[player].level = playerInfo[player].level - 1
		playerInfo[player].levelChanged = true
	end
	demoted(player)
    updateLeaderboard(nil)
end

function promote(player)
	if(playerInfo[player].level < (#gungameWeapons - 1)) then
        playerInfo[player].level = playerInfo[player].level + 1        
		playerInfo[player].levelChanged = true
        CALLREF(playLocalSound, player, "mp_killstreak_emp")
        updateLeaderboard(nil)
        
        -- play suspensefull sound when a player reaches final weapon, else local levelup.
        if(playerInfo[player].level == (#gungameWeapons - 1)) then
            for p, _ in pairs(playerInfo) do        
                CALLREF(playLocalSound, p, "mp_defeat")
                
                ref, n = createHUD(p, RED .. GetName(player) .. " on final gun!", "hudsmall", 1, "center", "top", "center", "top", 0, 0);
                CALLREF(IW4.HECmd.setPulseFx, ref, 50, 4000, 50)
	            destroyAfterTime(ref, 4) -- Destroyed after player leaves?
            end
        end
	else
        updateLeaderboard(player)
		endGame(player) 
	end
end

gameIsEnding = false

function endGame(winningPlayer)
	if gameIsEnding then
		return
	end

	gameIsEnding = true
	gameEnded = true
    
    dickhead = 0
    knifes = -1
    for player, _ in pairs(playerInfo) do
        if (playerInfo[player].knifes > knifes) then
            knifes = playerInfo[player].knifes
            dickhead = player
        end
	end   
    
    
    -- display winner and dickhead
	for player, _ in pairs(playerInfo) do
		ref, n = createHUD(player, RED .. "Game Ended\n" .. WHITE .. "Winner is:\n" .. BLUE .. GetName(winningPlayer), "hudbig", 1, "center", "middle", "center", "middle", 0, -50)
        CALLREF(IW4.HECmd.setPulseFx, ref, 50, 30000, 50)
        destroyAfterTime(ref, 31) -- Destroyed after player leaves?
        
        ref, n = createHUD(player, YELLOW .. "Knife dickhead:\n" .. GetName(dickhead), "hud", 1, "center", "middle", "center", "middle", 0, 25)
        CALLREF(IW4.HECmd.setPulseFx, ref, 50, 30000, 50)
        destroyAfterTime(ref, 31) -- Destroyed after player leaves?
	end

	timers.add(tick + 10 * 100, function(null) 
		CALL(exitLevel, 0)
	end, 0)
end

function playerThink(player, tick)
	if(playerInfo[player].levelChanged) then
		playerInfo[player].levelChanged = not playerInfo[player].levelChanged

		CALLREF(setText, playerInfo[player].levelHUD, BLUE .. "YOUR LEVEL " .. playerInfo[player].level .. "/" .. #gungameWeapons - 1);
        CALLREF(setText, playerInfo[player].knifeHUD, BLUE .. "YOUR KNIFES " .. playerInfo[player].knifes);
	end

	if CALL(isAlive, toEntity(player)) == 1 then
		checkWeapon(player)

		if gameEnded then
			CALLREF(freezeControl, player, 1)
		end
	end
end

function checkWeapon(player)
	local wep = gungameWeapons[playerInfo[player].level + 1]

	local currWep = CALLREF(getCurrentWeapon, player)

	if currWep ~= wep and currWep ~= "none" then
		CALLREF(takeWeapon, player, currWep);
		CALLREF(giveWeapon, player, wep, 0, false);
		CALLREF(switchToWeapon, player, wep);
	end
	if currWep == "none" then
		CALLREF(switchToWeapon, player, wep);
	end
end

function demoted(player)
	ref, n = createHUD(player, "^1DEMOTED", "hudbig", 3, "center", "middle", "center", "middle", 0, 0)
	CALLREF(IW4.HECmd.setPulseFx, ref, 100, 2000, 100 )
	destroyAfterTime(ref, 2) -- Destroyed after player leaves?
end

function createHUDs(player)
    playerInfo[player].lbHUD = createHUD(player, RED .. "LEADERBOARD", "hudsmall", 1, "left", "middle", "left", "middle", -60, -48)
    playerInfo[player].lbfirstHUD = createHUD(player, " ", "hudsmall", 1, "left", "middle", "left", "middle", -60, -36)
    playerInfo[player].lbsecondHUD = createHUD(player, "Start killing :)", "hudsmall", 1, "left", "middle", "left", "middle", -60, -24)
    playerInfo[player].lbthirdHUD = createHUD(player, " ", "hudsmall", 1, "left", "middle", "left", "middle", -60, -12)
    playerInfo[player].levelHUD = createHUD(player, BLUE .. "YOUR LEVEL " .. playerInfo[player].level .. "/" .. #gungameWeapons - 1, "hudsmall", 1, "left", "middle", "left", "middle", -60, 0)
    
    
    playerInfo[player].lbkHUD = createHUD(player, RED .. "Knife Knobs", "hudsmall", 1, "left", "middle", "left", "middle", -60, 24)
    playerInfo[player].lbkfirstHUD = createHUD(player, " ", "hudsmall", 1, "left", "middle", "left", "middle", -60, 36)
    playerInfo[player].lbksecondHUD = createHUD(player, "Dickheads go here :)", "hudsmall", 1, "left", "middle", "left", "middle", -60, 48)
    playerInfo[player].lbkthirdHUD = createHUD(player, " ", "hudsmall", 1, "left", "middle", "left", "middle", -60, 60)
    playerInfo[player].knifeHUD = createHUD(player, BLUE .. "YOUR KNIFES " .. playerInfo[player].knifes, "hudsmall", 1, "left", "middle", "left", "middle", -60, 72)

    
    ref, n = createHUD(player, BLUE .. "Gun Game v" .. version_string, "hudsmall", 3, "center", "top", "center", "top", 0, 0)
    CALLREF(IW4.HECmd.setPulseFx, ref, 100, 15000, 100 )
	destroyAfterTime(ref, 18) -- Destroyed after player leaves?
end

function playerSpawned(player)
	setupPlayer(player)
end

function setupPlayer(player)
	CALLREF(takeAllWeapons, player);

	local wep = gungameWeapons[playerInfo[player].level + 1]

	CALLREF(giveWeapon, player, wep, 0, false); --simply setting akimbo true wont work.
	CALLREF(switchToWeapon, player, wep);
	CALLREF(clearPerks, player);

	bad_perks = {"specialty_pistoldeath", "specialty_combathigh", "specialty_grenadepulldeath", "specialty_finalstand", "specialty_copycat", "specialty_localjammer"}
	
	for _, perk in pairs(bad_perks) do
		CALLREF(unsetPerk, player, perk);
	end

	perks = {"specialty_lightweight", "specialty_fastreload", "specialty_fastsprintrecovery", "specialty_quickdraw", "specialty_bulletdamage", "specialty_marathon"}

	for _, perk in pairs(perks) do
		CALLREF(setPerk, player, perk, true);
	end
end

function playerConnected(player)
	CALLREF(setClientDvar, player, "cg_fov", 80);
	CALLREF(setClientDvar, player, "cg_fovScale", "1.125");

	playerInfo[player].firstSpawn = true
	playerInfo[player].level = 0
	playerInfo[player].levelChanged = false
    playerInfo[player].knifes = 0

	createHUDs(player)
end

function playerDisconnected(player)
	if playerInfo[player] then
        CALLREF(IW4.HECmd.destroy, playerInfo[player].lbHUD)
        CALLREF(IW4.HECmd.destroy, playerInfo[player].lbfirstHUD)
        CALLREF(IW4.HECmd.destroy, playerInfo[player].lbsecondHUD)
        CALLREF(IW4.HECmd.destroy, playerInfo[player].lbthirdHUD)
        CALLREF(IW4.HECmd.destroy, playerInfo[player].levelHUD)
        
        CALLREF(IW4.HECmd.destroy, playerInfo[player].lbkHUD)       
        CALLREF(IW4.HECmd.destroy, playerInfo[player].lbkfirstHUD)
        CALLREF(IW4.HECmd.destroy, playerInfo[player].lbksecondHUD)
        CALLREF(IW4.HECmd.destroy, playerInfo[player].lbkthirdHUD)
        CALLREF(IW4.HECmd.destroy, playerInfo[player].knifeHUD)
	end
end


function updateLeaderboard(winner)
	-- iterate over players to determine 1 2 and 3
    first = nil
    second = nil 
    third = nil
    
    kfirst = nil
    ksecond = nil 
    kthird = nil
    for player, _ in pairs(playerInfo) do
        --leaderboard
        if player == winner or first == nil or playerInfo[player].level > playerInfo[first].level then
            third = second
            second = first
            first = player
        elseif second == nil or playerInfo[player].level > playerInfo[second].level then
            third = second
            second = player
        elseif third == nil or playerInfo[player].level > playerInfo[second].level then
            third = player
        end
        --knifeboard
        if kfirst == nil or playerInfo[player].knifes > playerInfo[kfirst].knifes then
            kthird = ksecond
            ksecond = kfirst
            kfirst = player
        elseif ksecond == nil or playerInfo[player].knifes > playerInfo[ksecond].knifes then
            kthird = ksecond
            ksecond = player
        elseif kthird == nil or playerInfo[player].knifes > playerInfo[ksecond].knifes then
            kthird = player
        end
	end
    
    -- Update the UI
    for player, _ in pairs(playerInfo) do
        --leaderboard
        if first ~= nil then
            CALLREF(setText, playerInfo[player].lbfirstHUD, "1. " .. GetName(first) .. " [" .. playerInfo[first].level .. "]");
        end
        if second ~= nil then
            CALLREF(setText, playerInfo[player].lbsecondHUD, "2. " .. GetName(second) .. " [" .. playerInfo[second].level .. "]");
        end
        if third ~= nil then
            CALLREF(setText, playerInfo[player].lbthirdHUD, "3. " .. GetName(third) .. " [" .. playerInfo[third].level .. "]");
        end
        --knifeboard
        if kfirst ~= nil then
            CALLREF(setText, playerInfo[player].lbkfirstHUD, "1. " .. GetName(kfirst) .. " [" .. playerInfo[kfirst].knifes .. "]");
        end
        if ksecond ~= nil then
            CALLREF(setText, playerInfo[player].lbksecondHUD, "2. " .. GetName(ksecond) .. " [" .. playerInfo[ksecond].knifes .. "]");
        end
        if kthird ~= nil then
            CALLREF(setText, playerInfo[player].lbkthirdHUD, "3. " .. GetName(kthird) .. " [" .. playerInfo[kthird].knifes .. "]");
        end
	end
end
