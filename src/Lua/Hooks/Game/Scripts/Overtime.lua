return function()
	--starting countdown
	if (leveltime >= (6*TICRATE - 1) and leveltime <= 9*TICRATE)
	and (leveltime % TICRATE == 0)
		S_StartSound(nil,leveltime == 9*TICRATE and sfx_s3kad or sfx_s3ka7)
	end
	
	--people might've joined or left, so recalc minimum kills
	if leveltime == 10*TICRATE
		local innocents = 0
		for p in players.iterate do
			if (p.mm and p.mm.role ~= MMROLE_MURDERER)
				innocents = $+1
			end
		end
		MM_N.minimum_killed = max(1,innocents/5)
	end
	
	if CV_MM.debug.value
		MM:handleStorm()
	end
	
	-- time management
	MM_N.time = max(0, $-1)
	if not (MM_N.time)
	and not MM_N.overtime then
		if MM_N.peoplekilled >= MM_N.minimum_killed
			MM:startOvertime()
		else
			MM:endGame(1)
			MM_N.disconnect_end = true
			MM_N.end_ticker = 3*TICRATE - 1
			S_StartSound(nil,sfx_s253)
		end
	end

	if MM_N.overtime
	and not MM_N.showdown then 
		if not MM_N.ping_time then
			MM_N.pings_done = $+1

			if MM_N.pings_done >= 2 then
				MM_N.pings_done = 0
				MM_N.max_ping_time = max(6, $/2)
			end

			MM_N.ping_time = MM_N.max_ping_time
			MM_N.ping_approx = FixedDiv(MM_N.ping_time, 30*TICRATE)

			MM:pingMurderers(min(MM_N.max_ping_time, 5*TICRATE), MM_N.ping_approx)
		end
		MM_N.ping_time = max(0, $-1)

		for k,pos in pairs(MM_N.ping_positions) do
			pos.time = max($-1, 0)
			if not (pos.time) then
				table.remove(MM_N.ping_positions, k)
			end
		end
	end

	if MM_N.overtime then
		if not MM_N.showdown
		and mapmusname ~= "MMOVRT" then
			mapmusname = "MMOVRT"
			S_ChangeMusic(mapmusname, true)
		end

		MM_N.overtime_ticker = $+1
	end

	--Overtime storm
	if MM_N.showdown 
	or MM_N.overtime then
		MM:handleStorm()
	end
end