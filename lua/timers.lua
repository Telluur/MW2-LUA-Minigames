timers = {
	timerTable = {},

	timerThink = function(tick)
		for k, v in pairs(timers.timerTable) do
			if v.onTick == tick then
				v.func(v.params)	
				timers.timerTable[k] = nil
			end
		end
	end,

	add = function(onTick, func, params)
		table.insert(timers.timerTable, {onTick = onTick, func = func, params = params})
	end
}