require "defines"
require "scripts/trees"


--[[Debug Functions]]--
debug_master = false -- Master switch for debugging, shows most things!
debug_ontick = false -- Ontick switch for debugging, shows all ontick event debugs
debug_chunks = false -- shows the chunks generated with this on
function debug(str)
	if debug_master then
		PlayerPrint(str)
	end
end

function PlayerPrint(message)
	for _,player in pairs(game.players) do
		player.print(message)
	end
end

local RubberSeedTypeName = "RubberTree"
local RubberGrowingStates = {
	"rubber-seed",
	"small-rubber-tree",
	"medium-rubber-tree",
	"mature-rubber-tree"
}
local RubberOutput = {"resin", 3}
local RubberTileEfficiency = {
	["grass"] = 1.00,
	["grass-medium"] = 1.50,
	["grass-dry"] = 0.75,
	["dirt"] = 1.25,
	["dirt-dark"] = 1.25,
	["hills"] = 0.80,
	["sand"] = 0.25,
	["sand-dark"] = 0.25,
	["other"] = 0
}
local RubberBasicGrowingTime = 7500
local RubberRandomGrowingTime = 4500
local RubberFertilizerBoost = 1.45
local allInOne = {
	["name"] = RubberSeedTypeName,
	["states"] = RubberGrowingStates,
	["output"] = RubberOutput,
	["efficiency"] = RubberTileEfficiency,
	["basicGrowingTime"] = RubberBasicGrowingTime,
	["randomGrowingTime"] = RubberRandomGrowingTime,
	["fertilizerBoost"] = RubberFertilizerBoost
}

game.oninit(function()
	Trees.OnInit()
end)

game.onsave(function()

end)

game.onload(function()
	Trees.OnLoad()
	if game.itemprototypes.charcoal and remote.interfaces["treefarm"] then -- item "charcoal" is available, that means treefarm-mod is probably used
	debug("Treefarm installed")
        local errorMsg = remote.call("treefarm", "addSeed", allInOne) -- call the interface and store the return value
            -- the remote function will return nil on success, otherwise a string with the error-msg
			if errorMsg == nil then -- everything worked fine
				glob.compatibility.treefarm = true
			else
				if errorMsg ~= "seed type already present" then PlayerPrint(errorMsg) end
			end
	else -- charcoal isn't available, so treefarm-mod isn't installed
	debug("Treefarm not installed")
		glob.compatibility.treefarm = false
		for seedTypeName, seedTypeInfo in pairs (glob.trees.seedTypes) do
			if game.itemprototypes[seedTypeInfo.states[1]] == nil then
				glob.trees.isGrowing[seedTypeName] = nil
				glob.trees.seedTypes[seedTypeName] = nil
			end
		end
	end
end)

game.onevent(defines.events.ontick, function(event)
	if glob.compatibility.treefarm == false then
		for seedTypeName, seedType in pairs(glob.trees.isGrowing) do
			if (seedType[1] ~= nil) and (game.tick >= seedType[1].nextUpdate)then
				local removedEntity = table.remove(seedType, 1)
				fs.updateEntityState(removedEntity)
				debug("Trees update entity state")
			end
		end
	end
end)

game.onevent(defines.events.onbuiltentity, function(event)
	if event.createdentity.type == "tree" then
		if glob.compatibility.treefarm == false then
			local currentSeedTypeName = fs.getSeedTypeByEntityName(event.createdentity.name)
			if currentSeedTypeName ~= nil then
				fs.seedPlaced(event.createdentity, currentSeedTypeName)
				debug("Tree Seed Placed")
				return
			end
		end
	end
end)

game.onevent(defines.events.onrobotbuiltentity, function(event)
	if event.createdentity.type == "tree" then
		if glob.compatibility.treefarm == false then
			local currentSeedTypeName = fs.getSeedTypeByEntityName(event.createdentity.name)
			if currentSeedTypeName ~= nil then
				fs.seedPlaced(event.createdentity, currentSeedTypeName)
				debug("Tree Seed Placed")
				return
			end
		end
	end
end)

remote.addinterface("DyTech-Core",
{  
  ResetAll = function()
	game.force.resettechnologies()
	game.force.resetrecipes()
  end
})