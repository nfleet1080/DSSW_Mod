local assets = {
    Asset("ANIM", "anim/pepperoniroll.zip"),
    Asset("ATLAS", "images/inventoryimages/pepperoniroll.xml")
}

local prefabs = {}

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    -- Check if Shipwrecked is enabled
    if IsDLCEnabled(CAPY_DLC) then
        -- Make floatable
        --MakeInventoryFloatable(inst, "idle_water", "idle")
    end
    
    anim:SetBank("pepperoniroll")-- Bank name, within the scml
    anim:SetBuild("pepperoniroll")-- Build name, as seen in anim folder
    anim:PlayAnimation("idle")-- Animation name
    
	inst:AddTag("preparedfood")

	inst:AddComponent("edible")
	inst.components.edible.healthvalue = TUNING.HEALING_HUGE
	inst.components.edible.hungervalue = TUNING.CALORIES_LARGE
	inst.components.edible.foodtype = "MEAT"
	inst.components.edible.sanityvalue = TUNING.SANITY_LARGE
    inst.components.edible.temperaturedelta = 35 -- heat!

    inst:AddComponent("inspectable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/pepperoniroll.xml"
    
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("bait")
	
	inst:AddComponent("tradable")

    return inst
end


-- Custom item name
STRINGS.NAMES.PEPPERONIROLL = "Pepperoni Roll"
-- Generic description of an item
STRINGS.CHARACTERS.GENERIC.DESCRIBE.PEPPERONIROLL = "A mountaineer's staple."

return Prefab("common/inventory/pepperoniroll", fn, assets, prefabs)
