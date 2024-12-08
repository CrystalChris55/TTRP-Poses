require "TimedActions/ISEatFoodAction"

local originalISEatFoodActionNew = ISEatFoodAction.new

-- Increase the length of the timed action to smoke to accomodate the longer animation, only when smoking a cigarette.

function ISEatFoodAction:new(character, item, percentage)
    local o = originalISEatFoodActionNew(self, character, item, percentage)
    if item and item:getFullType() == "Base.Cigarettes" then
    o.maxTime = o.maxTime * 1.6
    end

    return o
end