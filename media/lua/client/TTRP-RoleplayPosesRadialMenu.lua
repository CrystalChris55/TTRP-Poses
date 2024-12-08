-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- hi, i'm Chris, and I wrote this exstensively modified emote code by referencing RPactions pose mod made by Fuu, please ask them or me first if you use this code! --
-- To contact me, my Discord is ''crystalchris'' for any questions or comments or concerns!                                                                          --            
-- The first half of this file deals with the ghost mode application when posing to remove player collision hitboxes to allow for paired emotes.                     --
-- The second half deals with the actual meat and potatoes of the UI and posing adjacent code.                                                                       --
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

require 'ISUI/ISEmoteRadialMenu'

    -- We do math here. 
    function calculateDistance(x1, y1, x2, y2)
        return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
    end
    -- This function does a bunch of mystical math I wrote in a fugue state that grabs the nearest zombie, then gives us its distance to the player.
    function determineNearestZombie(playerObject)
        local playerObject = getSpecificPlayer(0)
        local closestZombie = nil
        local closestDistance = math.huge -- Set initial distance to a large value
        
        local zombieList = getWorld():getCell():getZombieList() -- Feeds us an array of zombies in the loaded nearby cells.
        
        if zombieList then
            for i = 0, zombieList:size() - 1 do 
                local zombie = zombieList:get(i) -- Grabs zombies out of the array, then calculates their distances to the player to find the closest one.
                local distance = calculateDistance(playerObject:getX(), playerObject:getY(), zombie:getX(), zombie:getY())
                if distance < closestDistance then
                    closestZombie = zombie
                    closestDistance = distance
                end
            end
        end
        
        return closestZombie, closestDistance
    end
    

    -- This bit of gobblygoo sets the ghost mode for the player to 'false' if it is within a sandbox adjustable range of the player. Defaults to 30 tiles which is about the range of audible sprinting.
    function setGhostModeBasedOnDistance(playerObject, maxRange)
        local playerObject = getSpecificPlayer(0)
        local closestZombie, closestDistance = determineNearestZombie(playerObject)
        maxRange = SandboxVars.TTRPPoses.GhostToggleRange or 30
        local closestZombieInfo = tostring(closestZombie) -- Convert closestZombie to a string for debug purposes.
         -- print("Closest zombie distance: " .. closestDistance) 
         -- print("Closest zombie distance: " .. closestZombieInfo) 
         -- print("Max Range:" .. maxRange)

    -- Check if closestDistance and maxRange are valid and if not; exit the function early.(In cases where a Zombie is not in render distance or zombies are turned off for pre-apoc settings)
    if type(closestDistance) ~= "number" or type(closestZombieInfo) ~= "string" or type(maxRange) ~= "number" then
         -- print("Warning: closestDistance or maxRange is not a number.")
        return -- Exit the function early if either value is not valid
    end

        if closestDistance <= maxRange and not isAdmin() then -- Does not set ghost mode to false if the player is an Admin.
            playerObject:setGhostMode(false)  -- Set ghost mode to false if within range of a zombie.
        end
         if playerObject:isGhostMode() then
           -- print("Ghost Mode is enabled for player.")
         else
           -- print("Ghost Mode is disabled for player.")
         end
    end

    Events.OnTick.Add(function(tick)
        if tick % 150 ~= 0 then return end -- This ensures the function runs every 150 ticks.
        
        -- Retrieve the player object inside this function to ensure it's valid
        local playerObject = getSpecificPlayer(0)
        
        -- Check if playerObject is nil before proceeding, this usually only happens when you die in multiplayer. Prevents errors.
        if not playerObject then
            --print("Warning: No player object found. Skipping ghost mode update.")
            return
        end
        
        -- If sandbox setting is set to false, will not fire the zombie-detection function.
        if SandboxVars.TTRPPoses.ToggleGhosting then
            setGhostModeBasedOnDistance(playerObject, maxRange)
            -- print("This is firing.")
        end
    end)


-- Function to perform emote; conditionally apply ghost mode.
function doEmote(emote)
    local playerObject = getSpecificPlayer(0)
    playerObject:playEmote(emote)
    if SandboxVars.TTRPPoses.ToggleGhosting then
    playerObject:setGhostMode(true)
    end
end
-- Function to cancel emotes, and if the user is not an admin, set ghost mode to false.
function cancelEmote(emote)
    local playerObject = getSpecificPlayer(0)
    playerObject:playEmote(emote)
    if not isAdmin() then
        playerObject:setGhostMode(false)
    end
end

-----------------------------------------------
           -- Main Menu --
-----------------------------------------------


--add the main pose slice to the q menu
function poseTTRPMain(menu, player)
    menu:addSlice("TTRP Poses", getTexture("media/ui/menus/main-menu.png"), ISRadialMenu.createSubMenu, menu, TTRPSubmenu)
end

-----------------------------------------------
       -- Submenus Creation --
-----------------------------------------------


--create the submenu with categories
function TTRPSubmenu(menu, player)
    menu:addSlice("Cancel Animation", getTexture("media/ui/menus/stop.png"), cancelEmote, "BobRPS_Cancel")
    menu:addSlice("Standing", getTexture("media/ui/menus/Standing_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPStanding)
    menu:addSlice("Sitting Poses", getTexture("media/ui/menus/Sitting_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPSit)
    menu:addSlice("Lying", getTexture("media/ui/menus/lying_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPLying)
    menu:addSlice("Props", getTexture("media/ui/menus/props_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPprops)
    menu:addSlice("Emotes", getTexture("media/ui/menus/emotes_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPemotes)
    menu:addSlice("Dances", getTexture("media/ui/menus/dance_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPDances)
    menu:addSlice("Dynamic", getTexture("media/ui/menus/dynamic_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPDynamic) -- TODO: Create submenu for interacting with other players / interacting with world
    local RPAspc = false;
    local playerItems = getPlayer():getInventory():getItems()
        --adds a submenu if you have forbidden cards in your inventory
        for i=1,playerItems:size() do
            local item = playerItems:get(i-1)
            if ForbiddenPoses[item:getFullType()] then
                if not RPAspc then
                    RPAspc = true;
                    menu:addSlice("Forbidden", getTexture("media/ui/menus/Forbidden.png"), ISRadialMenu.createSubMenu, menu, subForbidden)
                end
            end
        end
end

-------------------
-- STANDING MENU --
-------------------

function subTTRPStanding(menu)
    -- Standing Main Menu
    menu:addSlice("Standing Lean", getTexture("media/ui/menus/leaning_icon.png"), ISRadialMenu.createSubMenu, menu, StandingLean)
    menu:addSlice("Standing Lean 2", getTexture("media/ui/menus/lean2.png"), ISRadialMenu.createSubMenu, menu, StandingLean2)
    menu:addSlice("Idle Poses", getTexture("media/ui/menus/upright_icon.png"), ISRadialMenu.createSubMenu, menu, IdlePoses)
    menu:addSlice("Active Poses", getTexture("media/ui/menus/active_icon.png"), ISRadialMenu.createSubMenu, menu, ActivePoses)
    menu:addSlice("Standing Paired", getTexture("media/ui/menus/paired_icon.png"), ISRadialMenu.createSubMenu, menu, StandingPaired)
end

function StandingLean(menu)
    --Leaning Poses Menu
    menu:addSlice("Lean - Sassy", getTexture("media/ui/poses/standing/lean-sassy.png"), doEmote, "TTRP_SassyLean")
    menu:addSlice("Lean - Sassy Reverse", getTexture("media/ui/poses/standing/sassy-reverse.png"), doEmote, "TTRP_SassyLeanReverse")
    menu:addSlice("Lean - Hands Flat", getTexture("media/ui/poses/standing/hands-table.png"), doEmote, "TTRP_LeanHandsFlat")
    menu:addSlice("Lean - Chin on Fist", getTexture("media/ui/poses/standing/chin-on-fist.png"), doEmote, "TTRP_LeanOnChin")
    menu:addSlice("Lean - Foot on Object", getTexture("media/ui/poses/standing/foot-object.png"), doEmote, "TTRP_Standing-Foot-On-Object")
    menu:addSlice("Lean - Glass Box of Emotion", getTexture("media/ui/poses/standing/glass-case-emotion.png"), doEmote, "TTRP_GlassBoxOfEmotion")
    menu:addSlice("Lean - Lean Back Hands Folded", getTexture("media/ui/poses/standing/lean-back-folded-hands.png"), doEmote, "TTRP_Lean-Back-Hands-Folded")
    menu:addSlice("Lean - Lean On Table Left", getTexture("media/ui/poses/standing/lean-table-right.png"), doEmote, "TTRP_LeanLeftTable")
    menu:addSlice("Lean - Lean On Table Right", getTexture("media/ui/poses/standing/lean-table-left.png"), doEmote, "TTRP_LeanRightTable")
    menu:addSlice("Lean - Lean Crossed Arm Left", getTexture("media/ui/poses/standing/lean-right-crossed-arms.png"), doEmote, "TTRP_Crossed-Arm-Lean-Left")
    menu:addSlice("Lean - Lean Crossed Arm Right", getTexture("media/ui/poses/standing/lean-left-crossed-arms.png"), doEmote, "TTRP_Crossed-Arm-Lean-Right")
    menu:addSlice("Lean - Lean Back Hand In Pocket", getTexture("media/ui/poses/standing/lean-pocket.png"), doEmote, "TTRP_LeanBackHandinPocket")
    menu:addSlice("Lean - Lean Back Hands Behind", getTexture("media/ui/poses/standing/leantback.png"), doEmote, "TTRP_LeantBackHandsResting")
    menu:addSlice("Lean - Girlypop Door/Wall Lean Right", getTexture("media/ui/poses/standing/lean-left-girly-pop.png"), doEmote, "TTRP_GirlypopDoorLeanRight")
    menu:addSlice("Lean - Girlypop Door/Wall Lean Left", getTexture("media/ui/poses/standing/lean-right-girly-pop.png"), doEmote, "TTRP_GirlypopDoorLeanLeft")
end

function StandingLean2(menu)
    menu:addSlice("Lean - Arm Lean Up Left", getTexture("media/ui/poses/standing/LeanArmUpLeft.png"), doEmote, "TTRP_LeanArmUpLeft")
    menu:addSlice("Lean - Arm Lean Up Right", getTexture("media/ui/poses/standing/LeanArmUpRight.png"), doEmote, "TTRP_LeanArmUpRight")
    menu:addSlice("Lean - Arm Lean Left", getTexture("media/ui/poses/standing/arm-lean-left.png"), doEmote, "TTRP_ManLeanLeft")
    menu:addSlice("Lean - Arm Lean Right", getTexture("media/ui/poses/standing/arm-lean-right.png"), doEmote, "TTRP_ManLeanRight")
end

function IdlePoses(menu)
    -- Standing menu
    menu:addSlice("Stand - JoJo Pose", getTexture("media/ui/poses/standing/jojo.png"), doEmote, "TTRP_JoJoPose")
    menu:addSlice("Stand - Holding Hands Shy", getTexture("media/ui/poses/standing/holding-hands-shy.png"), doEmote, "TTRP_HoldHandsShy")
    menu:addSlice("Stand - Hand on Hip Alt", getTexture("media/ui/poses/standing/hand-on-hip-alt.png"), doEmote, "TTRP_HandOnHipAlt")
    menu:addSlice("Stand - Hand On Chin, Hip", getTexture("media/ui/poses/standing/hand-hip-chin.png"), doEmote, "TTRP_HandOnHipHandOnChin")
    menu:addSlice("Stand - One Hand in Pocket Casual", getTexture("media/ui/poses/standing/hand-in-pocket-casual.png"), doEmote, "TTRP_handinpocketcasual")
    menu:addSlice("Stand - Shy Arm Rub", getTexture("media/ui/poses/standing/arm-rub.png"), doEmote, "TTRP_ShyArmRub")
    menu:addSlice("Stand - Folding Hands Demurely", getTexture("media/ui/poses/standing/demure.png"), doEmote, "TTRP_HandsFoldedDemure")
    menu:addSlice("Stand - Hold Vest Straps", getTexture("media/ui/poses/standing/hold-vest.png"), doEmote, "TTRP_HoldVest")
    menu:addSlice("Stand - Rubbing Hand Behind Head", getTexture("media/ui/poses/standing/hand-behind-head.png"), doEmote, "TTRP_Hand-Behind-Head-Rub")
    menu:addSlice("Stand - Holding Neck", getTexture("media/ui/poses/standing/holdneck.png"), doEmote, "TTRP_HoldNeck")
end

function ActivePoses(menu)
    menu:addSlice("Stand - Taunt", getTexture("media/ui/poses/standing/jeb.png"), doEmote, "TTRP_Taunt")
    menu:addSlice("Stand - Flourishing Bow", getTexture("media/ui/poses/standing/curtsy.png"), doEmote, "TTRP_FlourishingBow")
    menu:addSlice("Stand - Shocked Pose", getTexture("media/ui/poses/standing/shocked.png"), doEmote, "TTRP_HandsBehindHeadShocked")
    menu:addSlice("Stand - Military Salute", getTexture("media/ui/poses/standing/military-salute.png"), doEmote, "TTRP_MilitarySalute")
    menu:addSlice("Stand - Hand Over Eyes", getTexture("media/ui/poses/standing/hand-over-eyes.png"), doEmote, "TTRP_HandOverEyes")
    menu:addSlice("Stand - Pondering", getTexture("media/ui/poses/standing/pondering.png"), doEmote, "TTRP_Pondering")
    menu:addSlice("Stand - Holding Self", getTexture("media/ui/poses/standing/holding-self.png"), doEmote, "TTRP_HUGGING_SELF")
    menu:addSlice("Stand - Soccer Flex", getTexture("media/ui/poses/standing/SoccerPose.png"), doEmote, "TTRP_SoccerFlex")
    menu:addSlice("Lean - Pose 28", getTexture("media/ui/poses/standing/pose28.png"), doEmote, "TTRP_Pose28")
end

function StandingPaired(menu)
    menu:addSlice("Stand - Hug", getTexture("media/ui/poses/standing/hugA.png"), doEmote, "TTRP_Hug1")
    menu:addSlice("Stand - Makeout A", getTexture("media/ui/poses/standing/kiss1.png"), doEmote, "TTRP_Makeout1")
    menu:addSlice("Stand - Makeout B", getTexture("media/ui/poses/standing/kiss1.png"), doEmote, "TTRP_Makeout2")
    menu:addSlice("Stand - Arm Around Another Left", getTexture("media/ui/poses/standing/standing-arm-left.png"), doEmote, "TTRP_Arm-Around-Other1")
    menu:addSlice("Stand - Arm Around Another Right", getTexture("media/ui/poses/standing/standing-arm-right.png"), doEmote, "TTRP_Arm-Around-Other2")
    menu:addSlice("Stand - Arm Around Two", getTexture("media/ui/poses/standing/arm-two.png"), doEmote, "TTRP_Arm-Around-Two")
    menu:addSlice("Stand - Arm Around Girly-ish Left", getTexture("media/ui/poses/standing/girly-left.png"), doEmote, "TTRP_GirlyArm")
    menu:addSlice("Stand - Arm Around Girly-ish Right", getTexture("media/ui/poses/standing/girly-right.png"), doEmote, "TTRP_GirlyArm2")
    menu:addSlice("Stand - Holding", getTexture("media/ui/poses/standing/holding.png"), doEmote, "TTRP_Holding")
    menu:addSlice("Kabedon", getTexture("media/ui/poses/standing/kabedon.png"), doEmote, "TTRP_Kabedon")
    menu:addSlice("Stand - Hands on Chest", getTexture("media/ui/poses/standing/hand-chest.png"), doEmote, "TTRP_Hands-on-Others-Chest")
    menu:addSlice("Stand - Hands on Hips", getTexture("media/ui/poses/standing/hand-hips.png"), doEmote, "TTRP_HoldHips")
end


------------------
-- SITTING MENU --
------------------

function subTTRPSit(menu)
    -- Sitting Main Menu
    menu:addSlice("Sit on Ground", getTexture("media/ui/menus/ground_icon.png"), ISRadialMenu.createSubMenu, menu, SittingGround)
    menu:addSlice("Sit on Furniture 1", getTexture("media/ui/menus/furniture_icon.png"), ISRadialMenu.createSubMenu, menu, SittingObject)
    menu:addSlice("Sit on Furniture 2", getTexture("media/ui/menus/furniture_icon-2.png"), ISRadialMenu.createSubMenu, menu, SittingObject2)
    menu:addSlice("Paired Sit on Ground", getTexture("media/ui/menus/sit-paired-ground.png"), ISRadialMenu.createSubMenu, menu, SittingGroundPaired)
    menu:addSlice("Paired Sit on Furniture", getTexture("media/ui/menus/sit-paired-furn.png"), ISRadialMenu.createSubMenu, menu, SittingObjectPaired)
end

function SittingGround(menu)
    -- Sitting On Ground Menu
    menu:addSlice("Sit - Hand Tap on Leg", getTexture("media/ui/poses/sitting/hand-tap.png"), doEmote, "TTRP_SitHandTap")
    menu:addSlice("Sit - Arms around Knee", getTexture("media/ui/poses/sitting/arms-knee.png"), doEmote, "TTRP_HandsOnKnee")
    menu:addSlice("Sit - Girly-Pop Sit on Ground", getTexture("media/ui/poses/sitting/girlypop-sit.png"), doEmote, "TTRP_GirlyPopSit")
    menu:addSlice("Sit - Hands bound kneeling", getTexture("media/ui/poses/sitting/hands-cuffed.png"), doEmote, "TTRP_HandsBoundKneel")
    menu:addSlice("Sit - Surrender", getTexture("media/ui/poses/sitting/surrender.png"), doEmote, "TTRP_KneelSurrender")
    menu:addSlice("Sit - Sway Side to Side", getTexture("media/ui/poses/sitting/sway-sit.png"), doEmote, "TTRP_SitSway")
    menu:addSlice("Sit - Elbow on Knee", getTexture("media/ui/poses/sitting/elbowonknee.png"), doEmote, "TTRP_ElbowOnKnee")
    menu:addSlice("Sit - Chin In Hands", getTexture("media/ui/poses/sitting/chin-in-hand.png"), doEmote, "TTRP_SitWithChinInHands")
    menu:addSlice("Sit - Arms on Knees", getTexture("media/ui/poses/sitting/arms-over-knee.png"), doEmote, "TTRP_SittingArmsOverKnee")
    menu:addSlice("Sit - Forearms on Thighs", getTexture("media/ui/poses/sitting/fore-arms-thighs.png"), doEmote, "TTRP_Forearms-Thighs")
    menu:addSlice("Kneel - Hand on Wall", getTexture("media/ui/poses/sitting/hand-on-wall.png"), doEmote, "TTRP_KneelHandOnWall")
    menu:addSlice("Kneel - Prayer", getTexture("media/ui/poses/sitting/praying.png"), doEmote, "TTRP_SitPrayer")
    menu:addSlice("Kneel - Hand over Hand", getTexture("media/ui/poses/sitting/kneel-crossed-hands.png"), doEmote, "TTRP_KneelingCrossedHand")
    menu:addSlice("Kneel - Crossed Arms", getTexture("media/ui/poses/sitting/kneel-crossed-arms.png"), doEmote, "TTRP_KneelingCrossedArms")
end

function SittingObject(menu)
    -- Sitting on an Object Menu
    menu:addSlice("Sit In Chair/Bed - Head in Hands", getTexture("media/ui/poses/sitting/head-in-hands.png"), doEmote, "TTRP_HeadInHandsSit")
    menu:addSlice("Sit In Chair - Hands on Thighs", getTexture("media/ui/poses/sitting/deep-squat.png"), doEmote, "TTRP_Hands_On_Thighs")
    menu:addSlice("Sit In Chair - Forearms on Thighs", getTexture("media/ui/poses/sitting/arms-thighs.png"), doEmote, "TTRP_Sitting_ForearmsThighs")
    menu:addSlice("Sit In Chair - Hands in Head", getTexture("media/ui/poses/sitting/cantdothisnomore.png"), doEmote, "TTRP_Sitting_Hands-Head")
    menu:addSlice("Sit In Chair - Lazy Boy Chair", getTexture("media/ui/poses/sitting/lazy-boy.png"), doEmote, "TTRP_LazyBoy")
    menu:addSlice("Sit In Chair - Manspread", getTexture("media/ui/poses/sitting/manspread.png"), doEmote, "TTRP_MANSPREAD")
    menu:addSlice("Sit In Chair - Manspread Arms Folded", getTexture("media/ui/poses/sitting/armsfoldedmanspread.png"), doEmote, "TTRP_ManspreadCrossedArms")
    menu:addSlice("Sit In Chair - Sassy", getTexture("media/ui/poses/sitting/sassy-sit.png"), doEmote, "TTRP_SassySit")
    menu:addSlice("Sit In Chair - Legs Crossed", getTexture("media/ui/poses/sitting/legs-crossed.png"), doEmote, "TTRP_SitInChairLegsCrossed")
    menu:addSlice("Sit In Chair - Chin In Hand", getTexture("media/ui/poses/sitting/chair-chin-in-hand.png"), doEmote, "TTRP_SitWithChinInHand-Chair")
    menu:addSlice("Sit In Chair - One Leg Up", getTexture("media/ui/poses/sitting/one-leg-up.png"), doEmote, "TTRP_SitInChairOneLegUp")
    menu:addSlice("Sit In Chair - Hands Folded Leant Forward", getTexture("media/ui/poses/sitting/satrmscross.png"), doEmote, "TTRP_SitHandsFolded")
    menu:addSlice("Sit In Chair - Legs Kicked Up", getTexture("media/ui/poses/sitting/legskickedup.png"), doEmote, "TTRP_Sit-Legs-Kicked-Up")
    menu:addSlice("Sit In Chair - Sitting Across Chair", getTexture("media/ui/poses/sitting/sit-cross-chair.png"), doEmote, "TTRP_Sit-Cross-Chair")
    menu:addSlice("Sit In Chair - Sunbathing in Beach Chair", getTexture("media/ui/poses/sitting/suntanning2.png"), doEmote, "TTRP_Suntanning2")
    menu:addSlice("Sit In Chair - Girlypop Arms-Around-Legs", getTexture("media/ui/poses/sitting/girlypop-kneesup.png"), doEmote, "TTRP_Girlypop-Chair-Sit")
end

function SittingObject2(menu)
    -- Sitting on an Object Menu pt 2
    menu:addSlice("Sit in Chair - Hand and Arm Thigh", getTexture("media/ui/poses/sitting/laxarmsit.png"), doEmote, "TTRP_HandThighArmThigh")
    menu:addSlice("Thane Sit", getTexture("media/ui/poses/sitting/Thane.png"), doEmote, "TTRP_ThaneSit")
    menu:addSlice("JARL Ballin", getTexture("media/ui/poses/sitting/JARLIN.png"), doEmote, "TTRP_JARL")
    menu:addSlice("JARL Ballin Two Arms", getTexture("media/ui/poses/sitting/JARLIN.png"), doEmote, "TTRP_JARL_ARMS_DOWN")
    menu:addSlice("Sit in Chair - Hands on Chair Girly", getTexture("media/ui/poses/sitting/Handchair.png"), doEmote, "TTRP_Sit-Hands-On-Chair")
    menu:addSlice("Sit In Chair - Chaise Lounge", getTexture("media/ui/poses/sitting/chaise-lounge.png"), doEmote, "TTRP_ChaiseLounge")
    menu:addSlice("Sit In Chair - Chaise Lounge Reversed", getTexture("media/ui/poses/sitting/chaise-reversed.png"), doEmote, "TTRP_ChaiseLoungeReversed")
    menu:addSlice("Sit In Chair - One up, one down", getTexture("media/ui/poses/sitting/1up1down.png"), doEmote, "TTRP_One-leg-up-one-down")
    menu:addSlice("Sit in Chair - One up, one down, reversed", getTexture("media/ui/poses/sitting/1up1downreversed.png"), doEmote, "TTRP_One-Leg-Up-One-Down-Reversed")
    menu:addSlice("Sit in Chair - Legs Crossed", getTexture("media/ui/poses/sitting/CrossedLegs.png"), doEmote, "TTRP_LegsCrossedChair")
    menu:addSlice("Sit in Chair - Goblin Sit", getTexture("media/ui/poses/sitting/goblin.png"), doEmote, "TTRP_GoblinSit")
end



function SittingObjectPaired(menu)
    menu:addSlice("Sitting Beside", getTexture("media/ui/poses/sitting/lean-against.png"), doEmote, "TTRP_SittingNextTo")
    menu:addSlice("Sit Beside, Hand on Thigh Right", getTexture("media/ui/poses/sitting/sit-hand-right.png"), doEmote, "TTRP_SitBesideHandThighRight")
    menu:addSlice("Sit Beside, Hand on Thigh Left", getTexture("media/ui/poses/sitting/sit-hand-left.png"), doEmote, "TTRP_SitBesideHandThighLeft")
    menu:addSlice("Sit Arm Around Right", getTexture("media/ui/poses/sitting/sit-around-right.png"), doEmote, "TTRP_Sit-Arm-Around-Right")
    menu:addSlice("Sit Arm Around Left", getTexture("media/ui/poses/sitting/sit-around-left.png"), doEmote, "TTRP_Sit-Arm-Around-Left")
end

function SittingGroundPaired(menu)
    menu:addSlice("Sit - Sitting Beside", getTexture("media/ui/poses/sitting/sittingbeside.png"), doEmote, "TTRP_SittingNextToGround")
    menu:addSlice("Sit - Legs Spread", getTexture("media/ui/poses/sitting/legsspread.png"), doEmote, "TTRP_Sit-on-Ground-Legs-Spread")
    menu:addSlice("Sit - Sit Between Legs", getTexture("media/ui/poses/sitting/sitbetween.png"), doEmote, "TTRP_Sit-Between-legs")
    menu:addSlice("Sit - Arm Around Left", getTexture("media/ui/poses/sitting/arm-around-left.png"), doEmote, "TTRP_Sitting-Arm-Around")
    menu:addSlice("Sit - Arm Around Right", getTexture("media/ui/poses/sitting/arm-around-right.png"), doEmote, "TTRP_Sitting-Arm-Around2")
    menu:addSlice("Sit - Stroking head in Lap", getTexture("media/ui/poses/sitting/stroke-head.png"), doEmote, "TTRP_Head-In-Lap")
end
---------------------
-- LYING DOWN MENU --
---------------------
function subTTRPLying(menu)
    menu:addSlice("Laying on Ground", getTexture("media/ui/menus/lying-ground.png"), ISRadialMenu.createSubMenu, menu, subTTRPLyingFloor)
    menu:addSlice("Laying on Furniture", getTexture("media/ui/menus/lying-furn.png"), ISRadialMenu.createSubMenu, menu, subTTRPLyingFurniture)
    menu:addSlice("Paired Lying", getTexture("media/ui/menus/lying-paired-ground.png"), ISRadialMenu.createSubMenu, menu, subLyingPairedGround)
    menu:addSlice("Paired Lying Furniture", getTexture("media/ui/menus/lying-paired-furn.png"), ISRadialMenu.createSubMenu, menu, subLyingPairedFurniture)

end

function subTTRPLyingFloor(menu)
   menu:addSlice("Lie Down - Injured Lay", getTexture("media/ui/poses/laying/injured1.png"), doEmote, "TTRP_DownAndOut")
   menu:addSlice("Lie Down - Injured Lay 2", getTexture("media/ui/poses/laying/injured2.png"), doEmote, "TTRP_LyingInjured2")
   menu:addSlice("Lie Down - Cloudspotting", getTexture("media/ui/poses/laying/cloudwatching.png"), doEmote, "TTRP_Cloudspotting")
   menu:addSlice("Lie Down - Flutter Kick", getTexture("media/ui/poses/laying/flutter-kick.png"), doEmote, "TTRP_Lie_Flutter_Kick")
   menu:addSlice("Lie Down - Feet Resting on Object", getTexture("media/ui/poses/laying/legs-on-chair.png"), doEmote, "TTRP_FeetOnSofa")
   menu:addSlice("Lie Down - Fetal Position", getTexture("media/ui/poses/laying/fetal.png"), doEmote, "TTRP_FetalPosition")
   menu:addSlice("Lie Down - Faceplant", getTexture("media/ui/poses/laying/faceplant.png"), doEmote, "TTRP_Faceplant")
   menu:addSlice("Lie Down - On Stomach 1", getTexture("media/ui/poses/laying/layingstomach.png"), doEmote, "TTRP_LayStomach1")
   menu:addSlice("Lie Down - French Girl", getTexture("media/ui/poses/laying/french_boi.png"), doEmote, "TTRP_FrenchGirl")
   menu:addSlice("Lie Down - French Girl Reversed", getTexture("media/ui/poses/laying/french_boi.png"), doEmote, "TTRP_French-Girl-Reversed")
   menu:addSlice("Lie Down - Sleeping 1", getTexture("media/ui/poses/laying/sleeping1.png"), doEmote, "TTRP_Lying-Asleep")
   menu:addSlice("Lie Down - Sleeping 1 Reversed", getTexture("media/ui/poses/laying/sleeping1.png"), doEmote, "TTRP_Lying-Asleep-Reversed")
   menu:addSlice("Lie Down - Sleeping 2", getTexture("media/ui/poses/laying/sleeping2.png"), doEmote, "TTRP_Lying-Sleeping2")
   menu:addSlice("Lie Down - Suntanning On Ground", getTexture("media/ui/poses/laying/suntanning.png"), doEmote, "TTRP_Suntanning")
   menu:addSlice("Lie Down - Elbows", getTexture("media/ui/poses/laying/elbows.png"), doEmote, "TTRP_LYING_ELBOWS")
end

function subTTRPLyingFurniture(menu)
    menu:addSlice("Lie Down - Fetal Position Furniture", getTexture("media/ui/poses/laying/fetal.png"), doEmote, "TTRP_FetalFurniture")
    menu:addSlice("Lie Down - On Stomach Bed", getTexture("media/ui/poses/laying/layingstomach.png"), doEmote, "TTRP_StomachLayBed")
    menu:addSlice("Lie Down - Flutter kick Furniture", getTexture("media/ui/poses/laying/flutter-kick.png"), doEmote, "TTRP_LegFlutterFurniture")
    menu:addSlice("Lie Down - French Girl Reversed Furniture", getTexture("media/ui/poses/laying/french_boi.png"), doEmote, "TTRP_French-Girl-ReversedFurniture")
    menu:addSlice("Lie Down - Lying Asleep 1 Furniture", getTexture("media/ui/poses/laying/sleeping1.png"), doEmote, "TTRP_Lying-AsleepFurniture")
    menu:addSlice("Lie Down - Lying Asleep 1 Furniture Reversed", getTexture("media/ui/poses/laying/sleeping1.png"), doEmote, "TTRP_Lying-Asleep-ReversedFurniture")
    menu:addSlice("Lie Down - Lying Asleep 2 Furniture", getTexture("media/ui/poses/laying/sleeping2.png"), doEmote, "TTRP_Lying-Sleeping2Furniture")
    menu:addSlice("Lie Down - Elbows Bed", getTexture("media/ui/poses/laying/elbows.png"), doEmote, "TTRP_LYING_ELBOWS_BED")
end

function subLyingPairedGround(menu)
    menu:addSlice("Lie Down - Cuddle", getTexture("media/ui/poses/laying/cuddle-reverse.png"), doEmote, "TTRP_Cuddle1")
    menu:addSlice("Lie Down - Cuddle Reversed", getTexture("media/ui/poses/laying/cuddle-reverse.png"), doEmote, "TTRP_Cuddle-Reversed")
    menu:addSlice("Lie Down - Laying head in a lap", getTexture("media/ui/poses/laying/head-lap.png"), doEmote, "TTRP_Laying-Head-In-Lap")
end

function subLyingPairedFurniture(menu)
    menu:addSlice("Lie Down - Cuddle Furniture", getTexture("media/ui/poses/laying/cuddle-reverse.png"), doEmote, "TTRP_Cuddle1-Offset")
    menu:addSlice("Lie Down - Cuddle Furniture Reversed", getTexture("media/ui/poses/laying/cuddle-reverse.png"), doEmote, "TTRP_Cuddle-Reversed-Offset")
end
----------------
-- PROPS MENU --
----------------
function subTTRPprops(menu)
    menu:addSlice("Long Rifles", getTexture("media/ui/menus/rifle-icon.png"), ISRadialMenu.createSubMenu, menu, subLongRifles)
    menu:addSlice("Pistols", getTexture("media/ui/menus/pistols-icon.png"), ISRadialMenu.createSubMenu, menu, subPistols)
    menu:addSlice("Melee Weapons", getTexture("media/ui/menus/melee-icon.png"), ISRadialMenu.createSubMenu, menu, subMeleeWeapons)
end

function subLongRifles(menu)
  menu:addSlice("Stand - Holding Rifle Steady", getTexture("media/ui/poses/props/aimrifle.png"), doEmote, "TTRP_HoldRifleSteady")
  menu:addSlice("Stand - Holding Rifle Idle", getTexture("media/ui/poses/props/rifleidle.png"), doEmote, "TTRP_HoldRifle")
  menu:addSlice("Stand - Holding Rifle Gunpoint", getTexture("media/ui/poses/props/rifle-gunpoint.png"), doEmote, "TTRP_HoldAtGunpointRifle")
  menu:addSlice("Stand - Holding Rifle Idle 2", getTexture("media/ui/poses/props/rifle-idle.png"), doEmote, "TTRP_Holding_Rifle_Idle_2")
  menu:addSlice("Stand - Holding Rifle Up Idle", getTexture("media/ui/poses/props/rifle-idle-3.png"), doEmote, "TTRP_Rifle-One-Hand-Up")
  menu:addSlice("Kneel - Holding Rifle Steady", getTexture("media/ui/poses/props/kneelshoot.png"), doEmote, "TTRP_HoldRifleKneel")
  menu:addSlice("Kneel - Holding Rifle Idle", getTexture("media/ui/poses/props/kneelidle.png"), doEmote, "TTRP_HoldRifleIdleKneel")
end

function subMeleeWeapons(menu)
    menu:addSlice("Stand - Weapon Pat", getTexture("media/ui/poses/props/batpat.png"), doEmote, "TTRP_BatPat")
    menu:addSlice("Stand - Weapon Held Behind Head", getTexture("media/ui/poses/props/weaponbehindhead.png"), doEmote, "TTRP_HoldBehindHead")
    menu:addSlice("Stand - Weapon on Shoulder", getTexture("media/ui/poses/props/weaponshoulder.png"), doEmote, "TTRP_Weapon-Shoulder")
    menu:addSlice("Stand - Sword at Ready", getTexture("media/ui/poses/props/swordready.png"), doEmote, "TTRP_SwordStance1")
    menu:addSlice("Crouch - Sword at Ready", getTexture("media/ui/poses/props/swordready2.png"), doEmote, "TTRP_SwordStance2")
end

function subPistols(menu)
    menu:addSlice("Stand - Holding Pistol Idle", getTexture("media/ui/poses/props/pistolsteady.png"), doEmote, "TTRP_HoldPistol")
    menu:addSlice("Stand - Ready to Draw", getTexture("media/ui/poses/props/drawholster.png"), doEmote, "TTRP_GunslingerReady")
    menu:addSlice("Stand - Hold Pistol Upright", getTexture("media/ui/poses/props/hold-pistol-up.png"), doEmote, "TTRP_Pistol-Held-Upwards")
    menu:addSlice("Stand - Holding Pistol at Gunpoint", getTexture("media/ui/poses/props/gunoint1.png"), doEmote, "TTRP_HeldAtGunpoint")
    menu:addSlice("Stand - Olympic Pistol Pose", getTexture("media/ui/poses/props/olympic.png"), doEmote, "TTRP_HeldAtGunpointOlympic")
    menu:addSlice("Lean - Cleaning Pistol/Racking Pistol", getTexture("media/ui/poses/props/cleangun.png"), doEmote, "TTRP_Clean_Pistol")
end

-----------------
-- EMOTES MENU --
-----------------

function subTTRPemotes(menu)
  menu:addSlice("Drugs - Snorting Pixie Sticks", getTexture("media/ui/poses/emotes/cocainum.png"), doEmote, "TTRP_PixieSticks")
  menu:addSlice("J'accuse", getTexture("media/ui/poses/emotes/accuser.png"), doEmote, "TTRP_Accost")
  menu:addSlice("Up Yours", getTexture("media/ui/poses/emotes/up-yours.png"), doEmote, "TTRP_UpYours")
  menu:addSlice("Up Yours - Casual", getTexture("media/ui/poses/emotes/up-yours-casual.png"), doEmote, "TTRP_UpYoursCasual")
  menu:addSlice("Big Wave", getTexture("media/ui/poses/emotes/big-wave.png"), doEmote, "TTRP_BigWave")
  menu:addSlice("Thinking", getTexture("media/ui/poses/emotes/thinking.png"), doEmote, "TTRP_Think")
  menu:addSlice("Rude Jerking Gesture", getTexture("media/ui/poses/emotes/rude-jerk.png"), doEmote, "TTRP_JackRude")
  menu:addSlice("Panicking", getTexture("media/ui/poses/emotes/freaking-out.png"), doEmote, "TTRP_Panic")
  menu:addSlice("Sighing", getTexture("media/ui/poses/emotes/big-sigh.png"), doEmote, "TTRP_Sighing")
  menu:addSlice("Crying", getTexture("media/ui/poses/emotes/crying1.png"), doEmote, "TTRP_Crying1")
  menu:addSlice("Facepalm", getTexture("media/ui/poses/emotes/facepalm.png"), doEmote, "TTRP_Facepalm")
  menu:addSlice("Scared", getTexture("media/ui/poses/emotes/scared.png"), doEmote, "TTRP_Scared_Look")
end

----------------
-- DANCE MENU --
----------------

function subTTRPDances(menu)
    menu:addSlice("Awkward Dance 1 - Awkward Shimmy", getTexture("media/ui/poses/dancing/Awkward-Dance-1.png"), doEmote, "TTRP_AwkwardDance1")
    menu:addSlice("Awkward Dance 2 - Raise the Roof", getTexture("media/ui/poses/dancing/Awkward-Dance-2.png"), doEmote, "TTRP_AwkwardDance2")
    menu:addSlice("Awkward Dance 3 - Wallflower", getTexture("media/ui/poses/dancing/Awkward-Dance-3.png"), doEmote, "TTRP_AwkwardDance3")
    menu:addSlice("Awkward Dance 4 - Dad Shimmy", getTexture("media/ui/poses/dancing/BBQDance.png"), doEmote, "TTRP_BBQShimmy")
end

-----------------
-- DYNAMIC MENU--
-----------------

function subTTRPDynamic(menu) 
    menu:addSlice("Stomach Wound / Upset Stomach", getTexture("media/ui/poses/dynamic/handstomach.png"), doEmote, "TTRP_HandsOverStomach")
    menu:addSlice("Arm in Sling", getTexture("media/ui/poses/dynamic/sling.png"), doEmote, "TTRP_ArmSling")
    menu:addSlice("Limping", getTexture("media/ui/poses/dynamic/injuredlimp.png"), doEmote, "TTRP_LimpLeg")
    -- menu:addSlice("Brushing/Mopping", getTexture("media/ui/poses/dynamic/brushmop.png"), doTTRPActions, "Base.PropaneTank", "mop")
    menu:addSlice("Stand - Shadowboxing", getTexture("media/ui/poses/dynamic/shadowboxing.png"), doEmote, "TTRP_ShadowBoxing")
    menu:addSlice("Kneel - Backpack Rummage", getTexture("media/ui/poses/dynamic/backpackrummage.png"), doEmote, "TTRP_BackpackRummage")
    menu:addSlice("Stand - Drunken Stumble", getTexture("media/ui/poses/dynamic/drunkenshamble.png"), doEmote, "TTRP_Drunk")
    menu:addSlice("CPR", getTexture("media/ui/poses/dynamic/CPR.png"), doEmote, "TTRP_CPR")
    menu:addSlice("Stand - Cooking With Spice", getTexture("media/ui/poses/dynamic/spicybrain.png"), doEmote, "TTRP_CookingWithSpice")
    menu:addSlice("Stand - Sanitary Handwash", getTexture("media/ui/poses/dynamic/handwash.png"), doEmote, "TTRP_Handwash")
    menu:addSlice("Stand - Cooling Off", getTexture("media/ui/poses/dynamic/coolingoff.png"), doEmote, "TTRP_CoolingOff")
    menu:addSlice("Stand - Pointing Behind", getTexture("media/ui/poses/dynamic/pointbehind.png"), doEmote, "TTRP_Blackboard")
    menu:addSlice("Stand - Examine Object", getTexture("media/ui/poses/dynamic/examine.png"), doEmote, "TTRP_ExamineHand")
    menu:addSlice("Lean - Wall Tinkle", getTexture("media/ui/poses/dynamic/P-I-S-S.png"), doEmote, "TTRP_Wall_Tinkle")
    menu:addSlice("Kneel - Clutching Toilet", getTexture("media/ui/poses/dynamic/toiletchuck.png"), doEmote, "TTRP_ClutchingToilet")
    menu:addSlice("Making Snowangels", getTexture("media/ui/poses/dynamic/starfish.png"), doEmote, "TTRP_Snowangel")
    menu:addSlice("ASL", getTexture("media/ui/poses/dynamic/ASL.png"), doEmote, "TTRP_ASL")
    -- menu:addSlice("Crawling", getTexture("media/ui/poses/props/icon1.png"), doEmote, "TTRP_WoundedCrawl")
    -- Placeholder test pose menu:addSlice("T-pose test", getTexture("media/ui/poses/props/icon1.png"), doEmote, "TTRP_TPoseTest")end
end

-----------------------------------------------
-- Modified Fuu's action code - Timed Action triggers. --
-----------------------------------------------

 function doTTRPActions(item, action)
     local player = getSpecificPlayer(0)
     if action == "mop" then
        ISTimedActionQueue.add(TTRPBrushMopAction:new(player, item))
     end
 end

 function doTTRPActionsBothHands(item1, item2, action)
    local player = getSpecificPlayer(0)
    if action == "mop" then
        ISTimedActionQueue.add(TTRPBrushMopAction:new(player, item1, item2))
    end
 end

-----------------------------------------------
-- Forbidden Card Poses - Admin only spawns. --
-----------------------------------------------

--define forbidden poses
ForbiddenPoses = {
    ["TTRP.TTRP_Forbidden_Splits_Card"] = "TTRP_TwerkSplits",
    ["TTRP.TTRP_Forbidden_Twerk_Card"] = "TTRP_Twerk",
    ["TTRP.TTRP_Forbidden_T-Pose"] = "TTRP_T-Pose",
    ["TTRP.TTRP_Forbidden_Frey"] = "TTRP_CaseyFrey",
    ["TTRP.TTRP_Forbidden_Restart"] = "TTRP_Restart",
    ["TTRP.TTRP_PinkGuy"] = "TTRP_PinkGuy",
}

function subForbidden(menu)
    --if playerItems has a pose card in the ForbiddenPoses table, add slice of that card + push that animation to doEmote
    local playerItems = getPlayer():getInventory():getItems()
    for i=1,playerItems:size() do
        local item = playerItems:get(i-1)
        if ForbiddenPoses[item:getFullType()] then
            menu:addSlice(ForbiddenPoses[item:getFullType()], getTexture('media/ui/poses/Forbidden/' .. ForbiddenPoses[item:getFullType()] .. '.png'), doEmote, ForbiddenPoses[item:getFullType()])
        end
    end
end

--registers the pose slice
EmoteMenuAPI.registerSlice("TTRP Poses", poseTTRPMain)