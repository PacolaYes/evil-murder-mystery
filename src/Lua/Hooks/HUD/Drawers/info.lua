local function HUD_InfoDrawer(v)
	local p = displayplayer
	local slidein = MMHUD.xoffset
	
	MMHUD.interpolate(v,true)
	
	--Timer
	do
		local flash = false
		local timetic = MM_N.time
		timetic = min(max($,0), MM_N.maxtime)
		
		local minutes = G_TicsToMinutes(timetic, true)
		local seconds = G_TicsToSeconds(timetic)
		
		if minutes < 10 then minutes = "0"..$ end
		if seconds < 10 then seconds = "0"..$ end
		
		flash = timetic <= 30*TICRATE or MM_N.showdown
		flash = (flash and ((leveltime%(2*TICRATE)) < 30*TICRATE) and (leveltime/5 & 1))
		
		local finalstring = minutes..":"..seconds
		if (MM_N.showdown)
			finalstring = "SHOWDOWN !!" -- ("..$..")"
		end
		
		v.drawScaled(5*FU - slidein,
			10*FU,
			FU,
			v.cachePatch("NGRTIMER"),
			V_SNAPTOLEFT|V_SNAPTOTOP
		)
		v.drawString(20*FU - slidein,
			10*FU,
			finalstring, --.."."..tictrn,
			V_SNAPTOLEFT|V_SNAPTOTOP|(flash and V_REDMAP or 0),
			"fixed"
		)
	end
	
	--rings
	do
		v.drawScaled(6*FU - slidein,
			21*FU,
			FU*3/4,
			v.cachePatch("NRNG1"),
			V_SNAPTOLEFT|V_SNAPTOTOP
		)
		v.drawString(20*FU - slidein,
			21*FU,
			p.rings,
			V_SNAPTOLEFT|V_SNAPTOTOP,
			"fixed"
		)	
	end

	-- murderers count
	/*
	do
		local color = leveltime/6 % 2 and V_REDMAP or V_BLUEMAP
		v.drawString(6*FU - slidein,
			33*FU,
			"SPECIAL COUNT: ".. MM_N.special_count,
			V_SNAPTOTOP|V_SNAPTOLEFT|color,
			"thin-fixed"
		)
	end
	*/
end

return HUD_InfoDrawer,"gameandscores"