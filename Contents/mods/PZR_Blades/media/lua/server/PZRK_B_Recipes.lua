require "recipecode"


-- Decreases the maximum durability based on hou much the blade has been repaired.
-- Also increases the repair counts when the blade has been sharpened.
function Recipe.OnCreate.SharpenBlade(items, result, player, selected_item)

    local maintenance_lvl = player:getPerkLevel(Perks.Maintenance);
    local condition_max = result:getConditionMax();
    local condition_recovery = 0;
    local repair_count = 0;

    -- How much can be repaired by shapening at current maintenance skill.
    if maintenance_lvl < 3 then
        condition_recovery = condition_max * ( (maintenance_lvl+1)/4 );
    end

    -- Gather info about the current blade being repaired.
    local blade_init_condit = 1;
    for i = 0, items:size()-1 do
        local item = items:get(i);
        local item_type = item:getType();
        if item_type ~= "Stone" and item_type ~= "SharpedStone" then
            local categories = item:getCategories();
            for j = 0, categories:size()-1 do
                local category = categories:get(j);
                if category == "SmallBlade" or category == "LongBlade" then
                    blade_init_condit = item:getCondition();
                    repair_count = item:getHaveBeenRepaired();
                    break;
                end
            end
        end
    end

    -- Blades slowly degrades after multiple repairs.
    local condition_limit = condition_max - 0.33 * (repair_count-1);

    -- Claps at condition maximun.
    if condition_limit > condition_max then
        condition_limit = condition_max;
    end

    -- Clamps minumum at 2. You can always re-sharpen an old blade.
    if condition_limit < 2 then
        condition_limit = 2;
    end


    -- Calculate the final condition after shapening and clamps it.
    local blade_final_condit = blade_init_condit + condition_recovery;
    if blade_final_condit > condition_limit then
        blade_final_condit = condition_limit;
    end

    -- Increments the repair count and sets the new condition.
    result:setHaveBeenRepaired(repair_count + 1);
    result:setCondition(blade_final_condit);

end


-- Gives a little bit of maintenance XP upon sharpening a knife.
function Recipe.OnGiveXP.SharpenBlade(recipe, ingredients, result, player)

    player:getXp():AddXP(Perks.Maintenance, 2);

end