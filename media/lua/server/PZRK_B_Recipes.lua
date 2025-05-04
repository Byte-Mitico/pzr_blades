require "recipecode"


-- Decreases the maximum durability based on hou much the blade has been repaired.
-- Also increases the repair counts when the blade has been sharpened.
function Recipe.OnCreate.SharpenBlade(items, result, player, selected_item)

    local maintenance_lvl = player:getPerkLevel(Perks.Maintenance);
    local condition_max = result:getConditionMax();
    local condition_recovery = condition_max;
    local repair_count = 0;
    local item_full_type = "";
    local item_type = "";

    -- How much can be repaired by shapening at current maintenance skill.
    if maintenance_lvl < 3 then
        condition_recovery = condition_recovery * ( (maintenance_lvl+1)/4 );
    end

    -- Gather info about the current blade being repaired.
    local blade_init_condit = 1;
    for i = 0, items:size()-1 do
        item = items:get(i);
        item_type = item:getType();
        item_full_type = item:getFullType();
        if item_type ~= "Stone" then
            local categories = item:getCategories();
            for j = 0, categories:size()-1 do
                local category = categories:get(j);
                print(category);
                if category == "SmallBlade" or category == "LongBlade" then
                    blade_init_condit = item:getCondition();
                    repair_count = item:getHaveBeenRepaired();
                    break;
                end
            end
        end
    end

    -- Calculate the final condition after shapening and clamps it.
    local blade_final_condit = blade_init_condit + condition_recovery;
    if blade_final_condit > condition_max then
        blade_final_condit = condition_max;
    end

    -- Blades slowly degrades after multiple repairs.
    local condition_limit = condition_max * (1 - 0.05 * repair_count);
    if condition_limit < 2 then
        condition_limit = 2;
    end

    -- Clamps the final condition to the limit of multiple repairs.
    if blade_final_condit > condition_limit then
        blade_final_condit = condition_limit;
    end

    print("Blade Init Condit  " .. blade_init_condit);
    print("Maintenace Lvl     " .. maintenance_lvl);
    print("Condit Recov       " .. condition_recovery);
    print("Condit Max         " .. condition_max);
    print("Final Condit       " .. blade_final_condit);
    print("Repairs            " .. repair_count);
    print(result:getClass());

    -- Increments the repair count and sets the new condition.
    result:setHaveBeenRepaired(repair_count + 1);
    result:setCondition(blade_final_condit);

end


-- Gives a little bit of maintenance XP upon sharpening a knife.
function Recipe.OnGiveXP.SharpenBlade(recipe, ingredients, result, player)

    player:getXp():AddXP(Perks.Maintenance, 2);

end