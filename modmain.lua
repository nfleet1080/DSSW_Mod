PrefabFiles = {
	"ehrieana",
	"cellphone",
    "pepperoniroll"
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/ehrieana.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/ehrieana.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/ehrieana.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/ehrieana.xml" ),
	
    Asset( "IMAGE", "images/selectscreen_portraits/ehrieana_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/ehrieana_silho.xml" ),

    Asset( "IMAGE", "bigportraits/ehrieana.tex" ),
    Asset( "ATLAS", "bigportraits/ehrieana.xml" ),
	
	Asset( "IMAGE", "images/map_icons/ehrieana.tex" ),
	Asset( "ATLAS", "images/map_icons/ehrieana.xml" ),

}

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

-- The character select screen lines
GLOBAL.STRINGS.CHARACTER_TITLES.ehrieana = "The Mountaineer Beauty"
GLOBAL.STRINGS.CHARACTER_NAMES.ehrieana = "Ehrieana"
GLOBAL.STRINGS.CHARACTER_DESCRIPTIONS.ehrieana = "*Hates cold\n*Can survive on less food\n*Loves cute animals, rain, and pepperoni rolls"
GLOBAL.STRINGS.CHARACTER_QUOTES.ehrieana = "\"Just LOOK at its tute wittle nose!!\""

-- Custom speech strings
STRINGS.CHARACTERS.EHRIEANA = require "speech_ehrieana"

-- Let the game know character is male, female, or robot
table.insert(GLOBAL.CHARACTER_GENDERS.FEMALE, "ehrieana")

AddMinimapAtlas("images/map_icons/ehrieana.xml")
AddModCharacter("ehrieana")

-- custom cookpot recipe
local pepperoniroll =
	{
        name = "pepperoniroll",
		test = function(cooker, names, tags) return names.butter and tags.meat and tags.egg end,
		priority = 10,
        weight = 1,
		foodtype = "MEAT",
		health = TUNING.HEALING_HUGE,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_PRESERVED,
		sanity = TUNING.SANITY_LARGE,
		cooktime = .5,
	}
    AddCookerRecipe("cookpot", pepperoniroll)

--GLOBAL.CHEATS_ENABLED = true

--GLOBAL.require( 'debugkeys' )