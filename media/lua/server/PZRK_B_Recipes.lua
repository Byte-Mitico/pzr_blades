require "recipecode"


-- Decreases the maximum durability based on hou much the blade has been repaired.
-- Also increases the repair counts when the blade has been sharpened.
function Recipe.OnCreate.SharpenBlade(items, result, player, selected_item)

    local maintenance_lvl = player:getPerkLevel(Perks.Maintenance);
    local condition_max = result:getConditionMax();
    local condition_recovery = condition_max;

    if maintenance_lvl < 3 then
        condition_recovery = condition_recovery * ( (maintenance_lvl+1)/4 );
    end

    local blade_init_condit = 1;
    for i = 0, items:size()-1 do
        local item_type = items:get(i):getType();
        if item_type ~= "Stone" then
            print(item_type);
            local categories = items:get(i):getCategories();
            for j = 0, categories:size()-1 do
                local category = categories:get(j);
                print(category);
                if category == "SmallBlade" or category == "LongBlade" then
                    blade_init_condit = items:get(i):getCondition();
                    break;
                end
            end
        end
    end

    local blade_final_condit = blade_init_condit + condition_recovery;
    if blade_final_condit > condition_max then
        blade_final_condit = condition_max;
    end

    -- print("Blade Init Condit  " .. blade_init_condit);
    -- print("Maintenace Lvl     " .. maintenance_lvl);
    -- print("Condit Recov       " .. condition_recovery);
    -- print("Condit Max         " .. condition_max);
    -- print("Final Condit       " .. blade_final_condit);

    result:setCondition(blade_final_condit);

end


-- Gives a little bit of maintenance XP upon sharpening a knife.
function Recipe.OnGiveXP.SharpenBlade(recipe, ingredients, result, player)

    player:getXp():AddXP(Perks.Maintenance, 2);

end