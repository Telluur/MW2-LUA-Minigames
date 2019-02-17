-- Util functions
RED = "^1";
GREEN = "^2";
YELLOW = "^3";
BLUE = "^4";
LIGHTBLUE = "^5";
PURPLE = "^6";
WHITE = "^7";
GREY = "^9";
BLACK = "^0";

function toEntity(player)
	return {entity = ((player * 0x274) + ENTITYARRAYA)};
end

function float(int)
	return int + 0.0;
end

function createHUD(player, text, font, fontscale, alignX, alignY, horzAlign, vertAlign, x, y)
	if player == nil then
		print("createHUD: Missing player")
		return
	end

	local entnum = CALL(newClientHudElem, toEntity(player))
	local ref = hudRef(entnum)
    
	SetHudElemField(entnum, IW4.HUD.OFFSET.font, font);
	SetHudElemField(entnum, IW4.HUD.OFFSET.alignX, alignX);
	SetHudElemField(entnum, IW4.HUD.OFFSET.alignY, alignY);
	SetHudElemField(entnum, IW4.HUD.OFFSET.horzAlign, horzAlign);
	SetHudElemField(entnum, IW4.HUD.OFFSET.vertAlign, vertAlign);
	SetHudElemField(entnum, IW4.HUD.OFFSET.x, float(x));
	SetHudElemField(entnum, IW4.HUD.OFFSET.y, float(y));
	SetHudElemField(entnum, IW4.HUD.OFFSET.fontScale, float(fontscale));

	CALLREF(setText, ref, tostring(text));

	return ref, entnum
end

function destroyAfterTime(hudref, seconds)
	if seconds < 0 then
		print("destroyAfterTime: seconds must be > 0")
		return
	end
	timers.add(tick + seconds * 100, function(hudref) 
		CALLREF(IW4.HECmd.destroy, hudref)
	end, hudref)
end

function hudRef(entnum)
	return entnum + 0x10000; -- 1 because it's the classnum for hud.
end