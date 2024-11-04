local activebuttons = BT_JUMP|BT_WEAPONNEXT|BT_WEAPONPREV|BT_ATTACK|BT_CUSTOM1|BT_CUSTOM2|BT_CUSTOM3
local AFK_TIMEOUT = 60*TICRATE

local function handleTimeout(p)
	if CV_MM.afkkickmode.value == 0 then return end
	if p == server
	or IsPlayerAdmin(p)
	or (CV_MM.afkkickmode.value == 2) -- "kill" mode
		P_KillMobj(p.mo,nil,nil,DMG_SPECTATOR)
		chatprintf(p,"\x82*You have been made a spectator for being AFK.")
		p.mm.afkhelpers.timedout = false
		--TODO: add corpse immediately
	else
		COM_BufAddText(server,"kick "..#p.." AFK")
	end
	
end

--TODO: this is just shitty lol
return function(p)
	local cmd = p.cmd
	local afk = p.mm.afkhelpers
	
	if (MM_N.waiting_for_players)
	or (MM_N.gameover)
	or (p.mm.spectator)
	or (p.mm.role == MMROLE_INNOCENT)
		return
	end

	if afk.timedout
	or not CV_MM.afkkickmode.value
		p.mm.afktimer = 0
		return
	end
	
	if not ((cmd.forwardmove or cmd.sidemove
	or cmd.buttons & activebuttons)
	or (afk.lastangle ~= cmd.angleturn << 16)
	or (afk.lastaiming ~= cmd.aiming))
		if afk.timeuntilreset < 10*TICRATE
			afk.timeuntilreset = $+1
		else
			p.mm.afktimer = $ + 1
			
			if p.mm.afktimer == AFK_TIMEOUT
				p.mm.afktimer = 0
				afk.timedout = true
				
				handleTimeout(p)
			end
		end
	else
		if afk.timeuntilreset
			afk.timeuntilreset = min(max($-6,0),2*TICRATE)
		else
			p.mm.afktimer = $*3/4
		end
	end
	
	afk.lastangle = cmd.angleturn << 16
	afk.lastaiming = cmd.aiming	
end