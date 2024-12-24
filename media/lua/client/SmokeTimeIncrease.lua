require "TimedActions/ISEatFoodAction"
-- Increase the length of the timed action to smoke to accomodate the longer animation, only when smoking a cigarette.

local originalISEatFoodActionNew = ISEatFoodAction.new

ISEatFoodAction.new = function(self, character, item, percentage)
    local o = originalISEatFoodActionNew(self, character, item, percentage)

    if item and item:getFullType() == "Base.Cigarettes" then
        o.maxTime = o.maxTime * 1.6
    end

    return o
end
