-- Test file, might make timed actions with items in the future.
require "TimedActions/ISBaseTimedAction"

TTRPBrushMopAction = ISBaseTimedAction:derive("TTRPBrushMopAction");

function TTRPBrushMopAction:isValid()
    return true;
end

function TTRPBrushMopAction:update()
    --
end

function TTRPBrushMopAction:waitToStart()
    return false;
end

function TTRPBrushMopAction:start()
    self:setActionAnim("TTRP_CookingWithSpice")
    self:setOverrideHandModels(self.rightItem, self.leftItem);
	self.sound = self.character:playSound("CleanBloodScrub")
    self.character:reportEvent("EventCleanBlood");
end

function TTRPBrushMopAction:stop()
    ISBaseTimedAction.stop(self);
end

function TTRPBrushMopAction:perform()
    ISBaseTimedAction.perform(self);
end

function TTRPBrushMopAction:new(character, item1, item2)
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    o.character = character;

    o.maxTime = -1;
    o.useProgressBar = false;
    o.forceProgressBar = false;
    o.stopOnWalk = false;
    o.stopOnRun = true;

    o.rightItem = item1;
    o.leftItem = item2;

    if o.character:isTimedActionInstant() then o.maxTime = 1; end
    return o;
end