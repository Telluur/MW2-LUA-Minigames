print("-----------------------------------")
print("              GAME.LUA             ")
print("-----------------------------------")

require("MW2_211");
require("util")
require("timers")
require("gungame")

players = {}
playerInfo = {}
baseTick = 0
tick = 0
hasRun = false
myHost = -999
frozen = true

function addPlayer(playerEntnum)
	table.insert(players, playerEntnum);

	playerInfo[playerEntnum] = {}
end

function removePlayer(playerEntnum)
	for key, value in pairs(players) do
		if value == player then
			table.remove(players, key)
			break
		end
	end
end

function runOnce(hostEntnum)
    print("[SERVER] SETTING HOST, ID: " .. hostEntnum)
    myHost = hostEntnum
	CALLREF(setViewModel, hostEntnum, "com_cellphone_on");
	onPlayerConnected(hostEntnum)
end

function onPlayerNotification(playerEntnum, notification)
	--print(playerEntnum, notification)
end

function onPlayerSay(fromEntnum, text)
    if access(fromEntnum) then
        cmd = string.match(text, "/(%w+)")
        if cmd then
            print("[" .. GetName(fromEntnum) .. "] CMD: " .. cmd)
        end
        if cmd == "fov" then
            CALLREF(setClientDvar, fromEntnum, "cg_fov", 80);
            CALLREF(setClientDvar, fromEntnum, "cg_fovScale", "1.125");
        elseif cmd == "r" then
            CALL(mapRestart, 0)
        elseif cmd == "x" then
            CALL(exitLevel, false)
        elseif cmd == "freeze" then
            frozen = true
        elseif cmd == "unfreeze" then
            frozen = false
            for _, player in pairs(players) do
                CALLREF(freezeControl, player, 0)
                if playerInfo[player].frozenHUD ~= nil then
                    destroyAfterTime(playerInfo[player].frozenHUD, 0)
                    playerInfo[player].frozenHUD = nil
                end
            end
        elseif cmd == "ui" then
            destroyAfterTime(createHUD(fromEntnum, "^2 0 0" , "hudbig", 1, "center", "middle", "center", "middle", 0, 0), 30)
            destroyAfterTime(createHUD(fromEntnum, "^2 +100 +100" , "hudbig", 1, "center", "middle", "center", "middle", 100, 100), 30)
            destroyAfterTime(createHUD(fromEntnum, "^2 -100 +100" , "hudsmall", 1, "center", "middle", "center", "middle", -100, 100), 30)
            destroyAfterTime(createHUD(fromEntnum, "^2 -100 -100" , "hud", 1, "center", "middle", "center", "middle", -100, -100), 30)
            destroyAfterTime(createHUD(fromEntnum, "^2 +100 -100" , "hudammo", 1, "center", "middle", "center", "middle", 100, -100), 30)
        end
        
        saying = string.match(text, "/say (.+)")
        if saying then
            print("[" .. GetName(fromEntnum) .. "] CMD: say " .. cmd)
            for _, player in pairs(players) do
                hudref, _ = createHUD(player, saying, "hudbig", 1, "center", "middle", "center", "middle", 0, -50)
                destroyAfterTime(hudref, 10)
            end
        end    
        
        kickName, reason = string.match(text, "/kick (%w+) (.+)")
        if kickName and reason then
            print("[" .. GetName(fromEntnum) .. "] CMD: kick " .. kickName .. " " .. reason)
            for _, player in pairs(players) do
                local name = GetName(player)
                if name == kickName then
                    DropClient(player, "Kicked: " .. reason)
                end
            end
        end
    end
end

function onTick(hostEntnum) -- called every 100ms
	if(not hasRun) then
		runOnce(hostEntnum); -- 4 on highrise.. 1 on rundown.. 2 on afghan
		hasRun = true
	end
    

	for _, player in pairs(players) do
		onPlayerThink(player, tick);
	end

	timers.timerThink(tick)

	tick = tick + 1
end

function onPlayerConnected(playerEntnum)
    print("[" .. GetName(playerEntnum) .. "] CONNECT")
	addPlayer(playerEntnum);
	playerConnected(playerEntnum)
end

function onPlayerDisconnected(playerEntnum)
	print("[" .. GetName(playerEntnum) .. "] DISCONNECT");
	playerDisconnected(playerEntnum)
	removePlayer(playerEntnum);
end

function onPlayerSpawned(playerEntnum)
	if CALL(isAlive, toEntity(playerEntnum)) == 1 then
        print("[" .. GetName(playerEntnum) .. "] SPAWN, ID: " .. playerEntnum);
		playerSpawned(playerEntnum)
	end
end

function onPlayerThink(playerEntnum, tick)
    if frozen then
        CALLREF(freezeControl, playerEntnum, 1)
        
        if playerInfo[playerEntnum].frozenHUD == nil then
            playerInfo[playerEntnum].frozenHUD = createHUD(playerEntnum, PURPLE .. "FROZEN", "hudbig", 2, "center", "middle", "center", "bottom", 0, 0)
        end
        
    end
	playerThink(playerEntnum, tick)
end

function onPlayerDeath(playerEntnum, inflictorEntnum, attackerEntnum, damage, meansOfDeath, iWeapon)
	playerDeath(playerEntnum, inflictorEntnum, attackerEntnum, damage, meansOfDeath, iWeapon)
end

function access(entnum)
   return entnum == myHost or string.match(GetName(entnum):lower(), "toxic") or string.match(GetName(entnum):lower(), "telluur")
end