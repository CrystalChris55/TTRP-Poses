require "TimedActions/ISBaseTimedAction"
require "TimedActions/RPSmokeTimedAction"

local originalRPSmokeTimedActionStart = RPSmokeTimedAction.start

-- Modify the Fuu's RP timed actions to use TTRPSmoke instead of RPSmoke to adjust the timed action length.
function RPSmokeTimedAction:start()
 originalRPSmokeTimedActionStart(self)
self:setActionAnim("TTRPSmoke")
end
