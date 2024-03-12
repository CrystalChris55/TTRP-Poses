-----------------------------------------------------------------------------------------------------------------------------------
-- hi i'm Chris and I wrote this by heavily modified emote code by referencing RPactions pose mod made by Fuu, please ask them or me first if you use this code! --
--             To contact me, my Discord is ''crystalchris'' for any questions or comments or concerns!                             --            
-----------------------------------------------------------------------------------------------------------------------------------

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
    

    -- This bit sets the ghost mode for the player to 'false' if it is within a sandbox adjustable range of the player. Defaults to 30 tiles which is about the range of audible sprinting.
    function setGhostModeBasedOnDistance(playerObject, maxRange)
        local playerObject = getSpecificPlayer(0)
        local closestZombie, closestDistance = determineNearestZombie(playerObject)
        maxRange = SandboxVars.TTRPPoses.GhostToggleRange or 30
        local closestZombieInfo = tostring(closestZombie) -- Convert closestZombie to a string for debug purposes.
        --print("Closest zombie distance: " .. closestDistance) -- Print  distance
        --print("Closest zombie distance: " .. closestZombieInfo) -- Print zombie Iso
        --print("Max Range:" .. maxRange)

    -- Check if closestDistance and maxRange are valid and if not; exit the function early.(In cases where a Zombie is not in render distance or zombies are turned off for pre-apoc settings)
    if type(closestDistance) ~= "number" or type(closestZombieInfo) ~= "string" or type(maxRange) ~= "number" then
        print("Warning: closestDistance or maxRange is not a number.")
        return -- Exit the function early if either value is not valid
    end

        if closestDistance <= maxRange and not isAdmin() then -- Does not set ghost mode to false if the player is an Admin.
            playerObject:setGhostMode(false)  -- Set ghost mode to false if within range of a zombie.
        end
        -- if playerObject:isGhostMode() then
        -- print("Ghost Mode is enabled for player.")
        -- else
        -- print("Ghost Mode is disabled for player.")
        -- end
    end

Events.OnTick.Add(function(tick)
    if tick % 150 ~= 0 then return end
    setGhostModeBasedOnDistance(playerObject, maxRange)
    --print("This is firing.")
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


--add the main pose slice to the q menu
function poseTTRPMain(menu, player)
    menu:addSlice("TTRP Poses", getTexture("media/ui/menus/main-menu.png"), ISRadialMenu.createSubMenu, menu, TTRPSubmenu)
end

require 'ISUI/ISEmoteRadialMenu'
--create the submenu with categories
function TTRPSubmenu(menu, player)
    local playerObject = getSpecificPlayer(0)
    menu:addSlice("Cancel Animation", getTexture("media/ui/menus/stop.png"), cancelEmote, "BobRPS_Cancel")
    menu:addSlice("Standing", getTexture("media/ui/menus/Standing_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPPoses)
    menu:addSlice("Sitting Poses", getTexture("media/ui/menus/Sitting_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPSit)
    menu:addSlice("Lying", getTexture("media/ui/menus/lying.png"), ISRadialMenu.createSubMenu, menu, subTTRPLying)
    menu:addSlice("Props", getTexture("media/ui/menus/props.png"), ISRadialMenu.createSubMenu, menu, subTTRPprops)
    menu:addSlice("Dynamic", getTexture("media/ui/menus/emote_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPDynamic)
end

function subTTRPPoses(menu)
    --Standing/Leaning Poses Menu
    menu:addSlice("Lean - Sassy", getTexture("media/ui/poses/standing/lean-sassy.png"), doEmote, "TTRP_SassyLean")
    menu:addSlice("Lean - Hands Flat", getTexture("media/ui/poses/standing/hands-table.png"), doEmote, "TTRP_LeanHandsFlat")
    menu:addSlice("Lean - Chin on Fist", getTexture("media/ui/poses/standing/chin-on-fist.png"), doEmote, "TTRP_LeanOnChin")
    menu:addSlice("Lean - Foot on Object", getTexture("media/ui/poses/standing/foot-object.png"), doEmote, "TTRP_Standing-Foot-On-Object")
    menu:addSlice("Lean - Hands Resting Behind", getTexture("media/ui/poses/standing/leantback.png"), doEmote, "TTRP_LeantBackHandsResting")
    menu:addSlice("Lean - Glass Box of Emotion", getTexture("media/ui/poses/standing/hand-eyes.png"), doEmote, "TTRP_GlassBoxOfEmotion")
    menu:addSlice("Stand - JoJo Pose", getTexture("media/ui/poses/standing/jojo.png"), doEmote, "TTRP_JoJoPose")
    menu:addSlice("Stand - Holding Hands Shy", getTexture("media/ui/poses/standing/holding-hands-shy.png"), doEmote, "TTRP_HoldHandsShy")
    menu:addSlice("Stand - Ready to Draw", getTexture("media/ui/poses/standing/drawholster.png"), doEmote, "TTRP_GunslingerReady")
    menu:addSlice("Stand - Pointing Behind", getTexture("media/ui/poses/standing/pointbehind.png"), doEmote, "TTRP_Blackboard")
    menu:addSlice("Stand - Crying 1", getTexture("media/ui/poses/standing/crying1.png"), doEmote, "TTRP_Crying1")
    menu:addSlice("Stand - Hand on Hip Alt", getTexture("media/ui/poses/standing/hand-on-hip-alt.png"), doEmote, "TTRP_HandOnHipAlt")
    menu:addSlice("Stand - Hand On Chin, Hip", getTexture("media/ui/poses/standing/hand-hip-chin.png"), doEmote, "TTRP_HandOnHipHandOnChin")
    menu:addSlice("Stand - One Hand In Pocket", getTexture("media/ui/poses/standing/noicon.png"), doEmote, "TTRP_handinpocket")
    menu:addSlice("Stand - Shy Arm Rub", getTexture("media/ui/poses/standing/arm-rub.png"), doEmote, "TTRP_ShyArmRub")
    menu:addSlice("Stand - Folding Hands Demurely", getTexture("media/ui/poses/standing/demure.png"), doEmote, "TTRP_HandsFoldedDemure")
    menu:addSlice("Stand - Taunt", getTexture("media/ui/poses/standing/jeb.png"), doEmote, "TTRP_Taunt")
    menu:addSlice("Stand - Cooking With Spice", getTexture("media/ui/poses/standing/spicybrain.png"), doEmote, "TTRP_CookingWithSpice")
    menu:addSlice("Stand - Shocked Pose", getTexture("media/ui/poses/standing/shocked.png"), doEmote, "TTRP_HandsBehindHeadShocked")
    menu:addSlice("Stand - Hands Over Eyes", getTexture("media/ui/poses/standing/noicon.png"), doEmote, "TTRP_HandOverEyes")
    menu:addSlice("Stand - Facepalm", getTexture("media/ui/poses/standing/noicon.png"), doEmote, "TTRP_Facepalm")
    menu:addSlice("Stand - Wall Tinkle", getTexture("media/ui/poses/standing/noicon.png"), doEmote, "TTRP_Wall_Tinkle")
    menu:addSlice("Stand - Drunken Shamble", getTexture("media/ui/poses/standing/noicon.png"), doEmote, "TTRP_Drunk")
    menu:addSlice("Stand - Scared", getTexture("media/ui/poses/standing/noicon.png"), doEmote, "TTRP_Scared_Look")
    end
     
function subTTRPSit(menu)
    -- Sitting Main Menu
    menu:addSlice("Sit on Ground", getTexture("media/ui/icon1.png"), ISRadialMenu.createSubMenu, menu, SittingGround)
    menu:addSlice("Sit on Object", getTexture("media/ui/icon2.png"), ISRadialMenu.createSubMenu, menu, SittingObject)
end

function SittingGround(menu)
    -- Sitting On Ground Menu
    menu:addSlice("Sit - Hand Tap on Leg", getTexture("media/ui/poses/sitting/hand-tap.png"), doEmote, "TTRP_SitHandTap")
    menu:addSlice("Sit - Girly-Pop Sit on Ground", getTexture("media/ui/poses/sitting/noicon.png"), doEmote, "TTRP_GirlyPopSit")
    menu:addSlice("Sit - Hands bound kneeling", getTexture("media/ui/poses/sitting/hands-cuffed.png"), doEmote, "TTRP_HandsBoundKneel")
    menu:addSlice("Sit - Sway Side to Side", getTexture("media/ui/poses/sitting/sway-sit.png"), doEmote, "TTRP_SitSway")
    menu:addSlice("Sit - Elbow on Knee", getTexture("media/ui/poses/sitting/elbowonknee.png"), doEmote, "TTRP_ElbowOnKnee")
    menu:addSlice("Sit - Chin In Hands", getTexture("media/ui/poses/sitting/chin-in-hand.png"), doEmote, "TTRP_SitWithChinInHands")
    menu:addSlice("Sit - Arms on Knees", getTexture("media/ui/poses/sitting/arms-over-knee.png"), doEmote, "TTRP_SittingArmsOverKnee")
    menu:addSlice("Kneel - Hand on Wall", getTexture("media/ui/poses/sitting/hand-on-wall.png"), doEmote, "TTRP_KneelHandOnWall")
    menu:addSlice("Kneel - Prayer", getTexture("media/ui/poses/sitting/praying.png"), doEmote, "TTRP_SitPrayer")
    menu:addSlice("Kneel - Clutching Toilet", getTexture("media/ui/poses/sitting/toiletchuck.png"), doEmote, "TTRP_ClutchingToilet")
end

function SittingObject(menu)
    -- Sitting on an Object Menu
    menu:addSlice("Sit In Chair/Bed - Head in Hands", getTexture("media/ui/poses/sitting/head-in-hands.png"), doEmote, "TTRP_HeadInHandsSit")
    menu:addSlice("Sit In Chair - Sitting Beside", getTexture("media/ui/poses/sitting/lean-against.png"), doEmote, "TTRP_SittingNextTo")
    menu:addSlice("Sit In Chair - Hands on Thighs", getTexture("media/ui/poses/sitting/deep-squat.png"), doEmote, "TTRP_Hands_On_Thighs")
    menu:addSlice("Sit In Chair - Lazy Boy Chair", getTexture("media/ui/poses/sitting/lazy-boy.png"), doEmote, "TTRP_LazyBoy")
    menu:addSlice("Sit In Chair - Sassy", getTexture("media/ui/poses/sitting/sassy-sit.png"), doEmote, "TTRP_SassySit")
    menu:addSlice("Sit In Chair - Legs Crossed", getTexture("media/ui/poses/sitting/legs-crossed.png"), doEmote, "TTRP_SitInChairLegsCrossed")
    menu:addSlice("Sit In Chair - Chin In Hand", getTexture("media/ui/poses/sitting/chair-chin-in-hand.png"), doEmote, "TTRP_SitWithChinInHand-Chair")
    menu:addSlice("Sit In Chair - One Leg Up", getTexture("media/ui/poses/sitting/one-leg-up.png"), doEmote, "TTRP_SitInChairOneLegUp")
    menu:addSlice("Sit In Chair - Hands Folded Leant Forward", getTexture("media/ui/poses/sitting/satrmscross.png"), doEmote, "TTRP_SitHandsFolded")
end

function subTTRPLying(menu)
   -- Lying down menu
   menu:addSlice("Lie Down - Injured Lay", getTexture("media/ui/poses/laying/injured1.png"), doEmote, "TTRP_DownAndOut")
   menu:addSlice("Lie Down - Injured Lay 2", getTexture("media/ui/poses/laying/injured2.png"), doEmote, "TTRP_LyingInjured2")
   menu:addSlice("Lie Down - Cloudspotting", getTexture("media/ui/poses/laying/cloudwatching.png"), doEmote, "TTRP_Cloudspotting")
   menu:addSlice("Lie Down - Flutter Kick", getTexture("media/ui/poses/laying/flutter-kick.png"), doEmote, "TTRP_Lie_Flutter_Kick")
   menu:addSlice("Lie Down - Feet Resting on Object", getTexture("media/ui/poses/laying/legs-on-chair.png"), doEmote, "TTRP_FeetOnSofa")
   menu:addSlice("Lie Down - Fetal Position", getTexture("media/ui/poses/laying/fetal.png"), doEmote, "TTRP_FetalPosition")
   menu:addSlice("Lie Down - Faceplant", getTexture("media/ui/poses/laying/faceplant.png"), doEmote, "TTRP_Faceplant")
   menu:addSlice("Lie Down - On Stomach 1", getTexture("media/ui/poses/laying/layingstomach.png"), doEmote, "TTRP_LayStomach1")
   menu:addSlice("Lie Down - French Girl", getTexture("media/ui/poses/laying/french_boi.png"), doEmote, "TTRP_FrenchGirl")
end

function subTTRPprops(menu)
-- Prop emotes menu
  menu:addSlice("Stand - Holding Rifle Steady", getTexture("media/ui/poses/props/aimrifle.png"), doEmote, "TTRP_HoldRifleSteady")
  menu:addSlice("Stand - Holding at Gunpoint", getTexture("media/ui/poses/props/gunoint1.png"), doEmote, "TTRP_HeldAtGunpoint")
  menu:addSlice("Stand - Holding Rifle Idle", getTexture("media/ui/poses/props/rifleidle.png"), doEmote, "TTRP_HoldRifle")
  menu:addSlice("Stand - Holding Pistol Idle", getTexture("media/ui/poses/props/pistolsteady.png"), doEmote, "TTRP_HoldPistol")
  menu:addSlice("Kneel - Holding Rifle Steady", getTexture("media/ui/poses/props/kneelshoot.png"), doEmote, "TTRP_HoldRifleKneel")
  menu:addSlice("Stand - Bat Pat", getTexture("media/ui/poses/props/batpat.png"), doEmote, "TTRP_BatPat")
end

function subTTRPDynamic(menu)
   menu:addSlice("Stomach Wound / Upset Stomach", getTexture("media/ui/poses/dynamic/handstomach.png"), doEmote, "TTRP_HandsOverStomach")
   menu:addSlice("Limping", getTexture("media/ui/poses/dynamic/injuredlimp.png"), doEmote, "TTRP_LimpLeg")
   menu:addSlice("Stand - Shadowboxing", getTexture("media/ui/poses/standing/shadowboxing.png"), doEmote, "TTRP_ShadowBoxing")
   menu:addSlice("Kneel - Backpack Rummage", getTexture("media/ui/poses/dynamic/backpackrummage.png"), doEmote, "TTRP_BackpackRummage")
   menu:addSlice("Drugs - Snorting Pixie Sticks", getTexture("media/ui/poses/dynamic/icon1.png"), doEmote, "TTRP_PixieSticks")
   menu:addSlice("J'accuse", getTexture("media/ui/poses/dynamic/noicon.png"), doEmote, "TTRP_Accost")
   menu:addSlice("CPR", getTexture("media/ui/poses/dynamic/icon1.png"), doEmote, "TTRP_CPR")
   menu:addSlice("Up Yours", getTexture("media/ui/poses/dynamic/icon1.png"), doEmote, "TTRP_UpYours")
   menu:addSlice("Big Wave", getTexture("media/ui/poses/dynamic/icon1.png"), doEmote, "TTRP_BigWave")
   -- Can't get it to move. menu:addSlice("Crawling", getTexture("media/ui/poses/props/icon1.png"), doEmote, "TTRP_WoundedCrawl")
   -- Placeholder test pose menu:addSlice("T-pose test", getTexture("media/ui/poses/props/icon1.png"), doEmote, "TTRP_TPoseTest")
end

--registers the pose slice
EmoteMenuAPI.registerSlice("TTRP Poses", poseTTRPMain)