local MakePlayerCharacter = require "prefabs/player_common"

-- {prefab, text}
local cuteThings = {
    {'rabbit', 'wabbit'}
    , {'catcoon', 'wacoon'}
    , {'babybeefalo', 'baby beefalo'}
    , {'ballphin', 'ballphin'}
    , {'twister_seal', 'seal'}
    , {'moleworm', 'mole'}
}
-- triggers to prevent talk spam
local canTalkSanity = true
local canTalkKill = true
local canTalkHat = true

local assets = {
        
        Asset("ANIM", "anim/player_basic.zip"),
        Asset("ANIM", "anim/player_idles_shiver.zip"),
        Asset("ANIM", "anim/player_actions.zip"),
        Asset("ANIM", "anim/player_actions_axe.zip"),
        Asset("ANIM", "anim/player_actions_pickaxe.zip"),
        Asset("ANIM", "anim/player_actions_shovel.zip"),
        Asset("ANIM", "anim/player_actions_blowdart.zip"),
        Asset("ANIM", "anim/player_actions_eat.zip"),
        Asset("ANIM", "anim/player_actions_item.zip"),
        Asset("ANIM", "anim/player_actions_uniqueitem.zip"),
        Asset("ANIM", "anim/player_actions_bugnet.zip"),
        Asset("ANIM", "anim/player_actions_fishing.zip"),
        Asset("ANIM", "anim/player_actions_boomerang.zip"),
        Asset("ANIM", "anim/player_bush_hat.zip"),
        Asset("ANIM", "anim/player_attacks.zip"),
        Asset("ANIM", "anim/player_idles.zip"),
        Asset("ANIM", "anim/player_rebirth.zip"),
        Asset("ANIM", "anim/player_jump.zip"),
        Asset("ANIM", "anim/player_amulet_resurrect.zip"),
        Asset("ANIM", "anim/player_teleport.zip"),
        Asset("ANIM", "anim/wilson_fx.zip"),
        Asset("ANIM", "anim/player_one_man_band.zip"),
        Asset("ANIM", "anim/shadow_hands.zip"),
        Asset("SOUND", "sound/sfx.fsb"),
        Asset("SOUND", "sound/wilson.fsb"),
        Asset("ANIM", "anim/beard.zip"),
        
        Asset("ANIM", "anim/ehrieana.zip"),
}
local prefabs = {
    "cellphone",
    "pepperoniroll",
}

-- Custom starting items
local start_inv = {
    "cellphone",
    "pepperoniroll",
    "pepperoniroll",
}

local function possibleCuteThing(entity)
    -- can return at the first matching occurance
    for i, v in ipairs(cuteThings) do
        
        if entity.prefab == v[1] then
            -- named matched, BUT, is it in a hole?
            -- INLIMBO tag seems to satisfy this
            if not entity:HasTag("INLIMBO") then
                return true
            end
        end
    end
    -- return falsy on default
    return false
end

-- returns the word used to describe the cute thing
local function getCuteThing(entity)
    local ct
    
    -- get the "cute talk" for the entity
    for i, v in ipairs(cuteThings) do
        if entity.prefab == v[1] then
            ct = v[2]
        end
    end
    
    return ct
end


-- cute animals restore some sanity
local function sanityfn(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local delta = 0
    local max_rad = 10
    
    -- find all nearby entities
    local ents = TheSim:FindEntities(x, y, z, max_rad, {})
    -- iterate through the entities and target just the cute ones
    for k, v in pairs(ents) do
        if possibleCuteThing(v) then
            -- ok it's cute, but don't fill sanity if it's dead
            if not v.components.health:IsDead() then
                -- KISS: keep it simple stupid!
                -- while we _could_ adjust sanity based on distance to entities
                -- for now just keep it simple
                delta = TUNING.SANITYAURA_TINY
                
                -- use the condition to prevent talk spam
                if canTalkSanity then
                    -- occasionally broadcast the animal curing sanity
                    -- just for funs
                    -- pick a line to say
                    local tx = GetString("ehrieana", "ANNOUNCE_CUTE_" .. math.random(2))
                    
                    inst.components.talker:Say(string.format(tx, getCuteThing(v)))
                    canTalkSanity = false
                    inst:DoTaskInTime(30, function()canTalkSanity = true end)
                end
            end
        end
    end

    -- also restore some sanity when raining!
    if GetSeasonManager():IsRaining() then
        delta = TUNING.SANITYAURA_TINY * GetSeasonManager():GetPrecipitationRate()
    end
    
    return delta
end

-- lose sanity when something cute nearby gets killed
function cuteDeath(inst, victim)
    local max_rad = 11
    local dist = math.max(0, math.min(max_rad, math.sqrt(inst:GetDistanceSqToInst(victim))))
    
    -- if a valid victim
    if victim and victim.prefab then
        -- check distance of target from you
        -- we don't want things from far away making you insane
        if dist < max_rad then
            if possibleCuteThing(victim) then
                local delta = -TUNING.SANITYAURA_HUGE * 2 -- the amount of sanity lost here
                inst.components.sanity:DoDelta(delta)
                -- use the condition to prevent talk spam
                if canTalkKill then
                    inst.components.talker:Say(string.format(GetString("ehrieana", "ANNOUNCE_CUTE_SAD"), getCuteThing(victim)))
                    canTalkKill = false
                    inst:DoTaskInTime(10, function()canTalkKill = true end)
                end
            end
        end
    end
end

-- do not apply ice to the skin!
function icehatcheck(inst, item, equipped)
    
    -- check if icehat was equipped
    if equipped and item.prefab == "icehat" then
        -- equippped case
        inst.lose_health_task = inst:DoPeriodicTask(5, function(inst)
                -- first announce it
                --if canTalkHat then
                --    inst.components.talker:Say("OUCH!  Too cold, please take it off!")
                --    canTalkHat = false
                --    inst:DoTaskInTime(5, function()canTalkHat = true end)
                --end
                inst.components.talker:Say("OUCH!  Too cold, please take it off!")

                --if inst.components.health > 10 then
                inst.components.health:DoDelta(-10, true, "cold")
                local sound_name = inst.soundsname or inst.prefab
                local path = inst.talker_path_override or "dontstarve/characters/"
                local sound_event = path .. sound_name .. "/hurt"
                inst.SoundEmitter:PlaySound(inst.hurtsoundoverride or sound_event)
        --inst.SoundEmitter:PlaySound(inst.hurtsound)
        --end
        end)
    elseif equipped == false and item.prefab == "icehat" then
        canTalkHat = true
        inst.lose_health_task:Cancel()
        inst.components.talker:Say("Please don't do that again.")
    end
end

local fn = function(inst)
        
        -- choose which sounds this character will play
        inst.soundsname = "willow"
        
        -- Minimap icon
        inst.MiniMapEntity:SetIcon("ehrieana.tex")
        
        -- Stats
        inst.components.health:SetMaxHealth(150)
        inst.components.hunger:SetMax(170)
        inst.components.sanity:SetMax(200)
        -- forgiving to heat, unforgiving to cold
        inst.components.temperature.overheattemp = TUNING.OVERHEAT_TEMP + 20 -- a little extra tolerance
        inst.components.temperature.maxtemp = TUNING.MAX_ENTITY_TEMP + 20
        inst.components.temperature.hurtrate = (TUNING.WILSON_HEALTH / TUNING.FREEZING_KILL_TIME) + 5 -- cold REALLY hurts!
        
        -- Damage multiplier (optional)
        inst.components.combat.damagemultiplier = 1
        
        -- Hunger rate (optional)
        inst.components.hunger.hungerrate = TUNING.WILSON_HUNGER_RATE / 1.5
        
        -- Movement speed (optional)
        inst.components.locomotor.walkspeed = 4
        inst.components.locomotor.runspeed = 6
        
        -- cute animal logic
        inst.components.sanity.custom_rate_fn = sanityfn
        inst:ListenForEvent("killed", function(insta, data)cuteDeath(inst, data.victim) end)
        
        -- ice cube hats are painful
        inst:ListenForEvent("equip", function(insta, data)icehatcheck(inst, data.item, true) end, GetPlayer())
        inst:ListenForEvent("unequip", function(insta, data)icehatcheck(inst, data.item, false) end, GetPlayer())

end

return MakePlayerCharacter("ehrieana", prefabs, assets, fn, start_inv)
