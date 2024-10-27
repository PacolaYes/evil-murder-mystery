local TILEWIDTH = 64
local TILEHEIGHT = 16
local TILEMARGIN = 4
local ROWLENGTH = 300 / TILEWIDTH

--TODO: spectators and innocents during showdown always know the role
--		of other people

--if shouldialwaysknow is true, 
local function isDead(p,shouldialwaysknow)
	-- print("death", (not (p and p.mo and p.mo.valid)), p.spectator, p.mo.health <= 0)
	if p.mm and p.mm.joinedmidgame then
		return true
	end

	if MM_N.knownDeadPlayers[#p] then
		return true
	end

	if (p and p.mm and p.mm.role == MMROLE_SHERIFF and p.mm.spectator) then
		return true
	end

	return false
end

local SECRECY_NOTSECRET = 0
local SECRECY_MURDERERALLOWED = 1
local SECRECY_SECRET = 2

local roles = MM.require "Variables/Data/Roles"

local ROLESTYLES = {
	Unknown = {
		secrecy = SECRECY_NOTSECRET
	},
	Dead = {
		overlay = "MM_PLAYERLIST_OVERLAY_DEAD",
		overlayFlags = V_20TRANS,
		subtitle = "\x86" .. "Dead",
		secrecy = SECRECY_NOTSECRET
	},
	MidgameJoin = {
		subtitle = "\x82(joined midgame)",
		secrecy = SECRECY_NOTSECRET
	},
	Innocent = {
		subtitle = "Innocent",
		secrecy = SECRECY_SECRET,
		standardRole = true
	},
	Murderer = {
		bg = "MM_PLAYERLIST_BG_MURDERER",
		subtitle = "\x85Murderer",
		secrecy = SECRECY_MURDERERALLOWED,
		standardRole = true
	},
	Sheriff = {
		bg = "MM_PLAYERLIST_BG_SHERRIF",
		subtitle = "\x84Sheriff",
		secrecy = SECRECY_SECRET,
		standardRole = true
	}
}

local function getViewedPlayerRole(player, viewer)
	local role = "Unknown"

	if not player.mm then return "Unknown" end
	if player.mm.joinedmidgame then
		role = "MidgameJoin"
	elseif isDead(player) then
		role = "Dead"
	else
		role = roles[player.mm.role].name
	end

	if player == viewer then
		-- i should know what i am
		return role
	end

	local secrecyLevel = (ROLESTYLES[role] and ROLESTYLES[role].secrecy) or 0
	local privilegeLevel = SECRECY_NOTSECRET
	if isDead(viewer) or MM_N.gameover or MM_N.showdown /*DEBUG!* / or (viewer.cmd.buttons & BT_CUSTOM3)/**/  then
		privilegeLevel = SECRECY_SECRET
	elseif (viewer.mm and viewer.mm.role == MMROLE_MURDERER) then
		privilegeLevel = SECRECY_MURDERERALLOWED
	end
	-- print(player.name .. ": " .. role .. " with secrecy " .. secrecyLevel .. " and priv " .. privilegeLevel)
	if (privilegeLevel < secrecyLevel) then
		role = "Unknown"
	end
	return role
end

--[[@param v videolib]]
local function HUD_TabScoresDrawer(v)
	local playerlist = {}
	local deadplayerlist = {}
	-- while #playerlist < 32 do
	for p in players.iterate do
		if p and p.valid then
			if isDead(p) then
				table.insert(deadplayerlist, p)
			else
				table.insert(playerlist, p)
			end
		end
	end
	for _, p in ipairs(deadplayerlist) do
		table.insert(playerlist, p)
	end
	-- end
	-- while #playerlist > 32 do
	-- 	table.remove(playerlist, #playerlist)
	-- end
	
	local xroot = 160 - TILEWIDTH/2 - (min(ROWLENGTH, #playerlist)-1)*(TILEWIDTH+TILEMARGIN)/2
	local yroot = 100 - TILEHEIGHT/2 - ((#playerlist-1)/ROWLENGTH)*(TILEHEIGHT+TILEMARGIN)/2
	
	local bgPatch = v.cachePatch("MM_PLAYERLIST_BG")
	for ind, p in ipairs(playerlist) do
		local x = xroot + (TILEWIDTH+TILEMARGIN)*((ind-1)%ROWLENGTH)
		local y = yroot + (TILEHEIGHT+TILEMARGIN)*((ind-1)/ROWLENGTH)
		
		local role = getViewedPlayerRole(p, consoleplayer)
		local roleStyle = ROLESTYLES[role] or ROLESTYLES.Unknown

		local thisBgPatch = bgPatch
		if roleStyle.bg then
			thisBgPatch = v.cachePatch(roleStyle.bg)
		end
		v.draw(x, y, thisBgPatch, V_50TRANS)
		
		local p_skin = p.mm.permanentskin or p.skin
		local p_skincolor = p.mm.permanentcolor or p.skincolor

		--#region life icon
		local iconpatch = v.getSprite2Patch(p_skin, SPR2_XTRA, false, A)
		local stndpatch = v.getSprite2Patch(p_skin, SPR2_STND, false, A)
		if iconpatch == stndpatch then
			iconpatch = v.cachePatch("WHODISICON")
		end
		v.drawScaled(x*FU, y*FU, FU/2, iconpatch, 0, v.getColormap(p_skin, p_skincolor))
		--#endregion

		--#region name rendering
		local style = "small"
		local name = p.name
		-- name = string.sub(name, 1, sin(ANG2*leveltime)/(FU/12)+14)
		if v.stringWidth(name, 0, "small") >= (TILEWIDTH-18) then
			style = "small-thin"
			if v.stringWidth(name, 0, "thin")/2 >= (TILEWIDTH-16) then
				while v.stringWidth(name .. "...", 0, "thin")/2 >= (TILEWIDTH-16) do
					name = string.sub(name, 1, #name-1)
				end
				name = name .. "..."
			end
		end
		v.drawString(
			x + 17, y,
			name, V_ALLOWLOWERCASE,
			style
		)
		--#endregion

		if roleStyle.subtitle then
			local subtitle = roleStyle.subtitle
			if role == "Dead" then
				local preDeathRole = roles[p.mm.role].name
				subtitle = subtitle .. " " .. ROLESTYLES[preDeathRole].subtitle
			end
			style = "small"
			if v.stringWidth(subtitle, 0, "small") >= (TILEWIDTH-18) then
				style = "small-thin"
			end
			v.drawString(
				x + 17, y+5,
				subtitle, V_ALLOWLOWERCASE,
				style
			)
		end
		if roleStyle.overlay then
			v.draw(x, y, v.cachePatch(roleStyle.overlay), roleStyle.overlayFlags)
		end

		if p == consoleplayer then
			v.draw(x, y, v.cachePatch("MM_PLAYERLIST_OUTLINE_YOU"))
		elseif p == displayplayer then
			v.draw(x, y, v.cachePatch("MM_PLAYERLIST_OUTLINE_SPEC"))
		end
	end
end

return HUD_TabScoresDrawer