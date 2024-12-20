-- SAXAS MURDER MYSTERY

rawset(_G, "MM_N", {})
rawset(_G, "MM", {})
freeslot("TOL_SAXAMM")

G_AddGametype({
    name = "Murder Mystery",
    identifier = "SAXAMM",
    typeoflevel = TOL_MATCH|TOL_TAG|TOL_SAXAMM,
    rules = GTR_FRIENDLYFIRE|GTR_SPAWNINVUL,
    intermissiontype = int_match,
    headerleftcolor = 222,
    headerrightcolor = 84,
	description = "Who murdered this guy? It's a mystery!"
})

MM.require = dofile "Libs/require"
dofile "Libs/CustomHud.lua"

dofile "events"

dofile "Variables/main"
dofile "Functions/main"
dofile "Console/main"
dofile "Interactions/main"
dofile "Hooks/main"
dofile "Clues/main"
dofile "Items/main"

-- fool-proofing
-- basically if you reference a variable thats not in the local table
-- it corrects itself to get the variable in the network table
-- ofc, its faster to reference the correct tables
-- so dont use this too much
setmetatable(MM, {
	__index = function(self, key)
		if rawget(self, key) ~= nil then
			return rawget(self, key)
		end

		if MM_N[key] ~= nil then
			return MM_N[key]
		end
	end,
	__newindex = function(self, key, value)
		if MM_N[key] ~= nil then
			MM_N[key] = value
			return
		end

		rawset(self, key, value)
	end
})