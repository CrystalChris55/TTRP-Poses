-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- hi, i'm Chris, and I wrote this exstensively modified emote code by referencing RPactions pose mod made by Fuu, please ask them or me first if you use this code! --
-- To contact me, my Discord is ''crystalchris'' for any questions or comments or concerns!                                                                          --            
-- The first half of this file deals with the ghost mode application when posing to remove player collision hitboxes to allow for paired emotes.                     --
-- The second half deals with the actual meat and potatoes of the UI and posing adjacent code.                                                                       --
--  ________      ________       ___    ___  ________       _________    ________      ___           ________      ___  ___      ________      ___      ________     -- 
--|\   ____\    |\   __  \     |\  \  /  /||\   ____\     |\___   ___\ |\   __  \    |\  \         |\   ____\    |\  \|\  \    |\   __  \    |\  \    |\   ____\     --
--\ \  \___|    \ \  \|\  \    \ \  \/  / /\ \  \___|_    \|___ \  \_| \ \  \|\  \   \ \  \        \ \  \___|    \ \  \\\  \   \ \  \|\  \   \ \  \   \ \  \___|_    --
-- \ \  \        \ \   _  _\    \ \    / /  \ \_____  \        \ \  \   \ \   __  \   \ \  \        \ \  \        \ \   __  \   \ \   _  _\   \ \  \   \ \_____  \   --
--  \ \  \____    \ \  \\  \|    \/  /  /    \|____|\  \        \ \  \   \ \  \ \  \   \ \  \____    \ \  \____    \ \  \ \  \   \ \  \\  \|   \ \  \   \|____|\  \  --
--   \ \_______\   \ \__\\ _\  __/  / /        ____\_\  \        \ \__\   \ \__\ \__\   \ \_______\   \ \_______\   \ \__\ \__\   \ \__\\ _\    \ \__\    ____\_\  \ --
--    \|_______|    \|__|\|__||\___/ /        |\_________\        \|__|    \|__|\|__|    \|_______|    \|_______|    \|__|\|__|    \|__|\|__|    \|__|   |\_________\--
--                            \|___|/         \|_________|                                                                                               \|_________|--
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

require 'ISUI/ISEmoteRadialMenu'
json = require 'json'
Favorites = Favorites or {}


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
-- Function to cancel emotes, and if the user is not an admin, sets ghost mode back to false.
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

function poseTTRPMain(menu, player)
    menu:addSlice(getText("IGUI_TTRP_Poses"), getTexture("media/ui/menus/main-menu.png"), ISRadialMenu.createSubMenu, menu, TTRPSubmenu)
end

-----------------------------------------------
       -- Submenus Creation --
-----------------------------------------------

-- Create the submenus with categories
function TTRPSubmenu(menu, player)
    menu:addSlice(getText("IGUI_TTRP_Cancel"), getTexture("media/ui/menus/stop.png"), cancelEmote, "BobRPS_Cancel")
    menu:addSlice(getText("IGUI_TTRP_Standing"), getTexture("media/ui/menus/Standing_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPStanding)
    menu:addSlice(getText("IGUI_TTRP_Sitting"), getTexture("media/ui/menus/Sitting_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPSit)
    menu:addSlice(getText("IGUI_TTRP_Lying"), getTexture("media/ui/menus/lying_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPLying)
    menu:addSlice(getText("IGUI_TTRP_Props"), getTexture("media/ui/menus/props_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPprops)
    menu:addSlice(getText("IGUI_TTRP_Emotes"), getTexture("media/ui/menus/emotes_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPemotes)
    menu:addSlice(getText("IGUI_TTRP_Dances"), getTexture("media/ui/menus/dance_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPDances)
    menu:addSlice(getText("IGUI_TTRP_Dynamic"), getTexture("media/ui/menus/dynamic_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPDynamic)

    local function hasFavorites()
        -- Adds a submenu if you have favorites saved to a table.
        for _ in pairs(Favorites) do
            return true 
        end
        return false
    end

    if hasFavorites() then
        menu:addSlice(getText("IGUI_TTRP_Favorites"), getTexture("media/ui/menus/favorites.png"), ISRadialMenu.createSubMenu, menu, subTTRPFavorites)
    end

    local RPAspc = false
    local playerItems = getPlayer():getInventory():getItems()
    -- Adds a submenu if you have forbidden cards in your inventory
    for i=1, playerItems:size() do
        local item = playerItems:get(i-1)
        if ForbiddenPoses[item:getFullType()] then
            if not RPAspc then
                RPAspc = true
                menu:addSlice(getText("IGUI_TTRP_Forbidden"), getTexture("media/ui/menus/Forbidden.png"), ISRadialMenu.createSubMenu, menu, subForbidden)
            end
        end
    end
end

-------------------
-- STANDING MENU --
-------------------

function subTTRPStanding(menu)
    -- Standing Main Menu
    menu:addSlice(getText("IGUI_TTRP_StandingLean"), getTexture("media/ui/menus/leaning_icon.png"), ISRadialMenu.createSubMenu, menu, StandingLean)
    menu:addSlice(getText("IGUI_TTRP_StandingLean2"), getTexture("media/ui/menus/lean2.png"), ISRadialMenu.createSubMenu, menu, StandingLean2)
    menu:addSlice(getText("IGUI_TTRP_IdlePoses"), getTexture("media/ui/menus/upright_icon.png"), ISRadialMenu.createSubMenu, menu, IdlePoses)
    menu:addSlice(getText("IGUI_TTRP_ActivePoses"), getTexture("media/ui/menus/active_icon.png"), ISRadialMenu.createSubMenu, menu, ActivePoses)
    menu:addSlice(getText("IGUI_TTRP_StandingPaired"), getTexture("media/ui/menus/paired_icon.png"), ISRadialMenu.createSubMenu, menu, StandingPaired)
end

function StandingLean(menu)
    -- Leaning Poses Menu
    menu:addSlice(getText("IGUI_TTRP_LeanSassy"), getTexture("media/ui/poses/standing/lean-sassy.png"), doEmote, "TTRP_SassyLean")
    menu:addSlice(getText("IGUI_TTRP_LeanSassyReverse"), getTexture("media/ui/poses/standing/sassy-reverse.png"), doEmote, "TTRP_SassyLeanReverse")
    menu:addSlice(getText("IGUI_TTRP_LeanHandsFlat"), getTexture("media/ui/poses/standing/hands-table.png"), doEmote, "TTRP_LeanHandsFlat")
    menu:addSlice(getText("IGUI_TTRP_LeanOnChin"), getTexture("media/ui/poses/standing/chin-on-fist.png"), doEmote, "TTRP_LeanOnChin")
    menu:addSlice(getText("IGUI_TTRP_LeanFootObject"), getTexture("media/ui/poses/standing/foot-object.png"), doEmote, "TTRP_Standing-Foot-On-Object")
    menu:addSlice(getText("IGUI_TTRP_GlassBoxEmotion"), getTexture("media/ui/poses/standing/glass-case-emotion.png"), doEmote, "TTRP_GlassBoxOfEmotion")
    menu:addSlice(getText("IGUI_TTRP_LeanBackHandsFolded"), getTexture("media/ui/poses/standing/lean-back-folded-hands.png"), doEmote, "TTRP_Lean-Back-Hands-Folded")
    menu:addSlice(getText("IGUI_TTRP_LeanTableLeft"), getTexture("media/ui/poses/standing/lean-table-right.png"), doEmote, "TTRP_LeanLeftTable")
    menu:addSlice(getText("IGUI_TTRP_LeanTableRight"), getTexture("media/ui/poses/standing/lean-table-left.png"), doEmote, "TTRP_LeanRightTable")
    menu:addSlice(getText("IGUI_TTRP_LeanCrossedArmLeft"), getTexture("media/ui/poses/standing/lean-right-crossed-arms.png"), doEmote, "TTRP_Crossed-Arm-Lean-Left")
    menu:addSlice(getText("IGUI_TTRP_LeanCrossedArmRight"), getTexture("media/ui/poses/standing/lean-left-crossed-arms.png"), doEmote, "TTRP_Crossed-Arm-Lean-Right")
    menu:addSlice(getText("IGUI_TTRP_LeanBackPocket"), getTexture("media/ui/poses/standing/lean-pocket.png"), doEmote, "TTRP_LeanBackHandinPocket")
    menu:addSlice(getText("IGUI_TTRP_LeanBackHandsBehind"), getTexture("media/ui/poses/standing/leantback.png"), doEmote, "TTRP_LeantBackHandsResting")
    menu:addSlice(getText("IGUI_TTRP_GirlypopDoorLeanLeft"), getTexture("media/ui/poses/standing/lean-right-girly-pop.png"), doEmote, "TTRP_GirlypopDoorLeanLeft")
    menu:addSlice(getText("IGUI_TTRP_GirlypopDoorLeanRight"), getTexture("media/ui/poses/standing/lean-left-girly-pop.png"), doEmote, "TTRP_GirlypopDoorLeanRight")
end

function StandingLean2(menu)
    -- Standing Lean 2
    menu:addSlice(getText("IGUI_TTRP_LeanArmUpLeft"), getTexture("media/ui/poses/standing/LeanArmUpLeft.png"), doEmote, "TTRP_LeanArmUpLeft")
    menu:addSlice(getText("IGUI_TTRP_LeanArmUpRight"), getTexture("media/ui/poses/standing/LeanArmUpRight.png"), doEmote, "TTRP_LeanArmUpRight")
    menu:addSlice(getText("IGUI_TTRP_ArmLeanLeft"), getTexture("media/ui/poses/standing/arm-lean-left.png"), doEmote, "TTRP_ManLeanLeft")
    menu:addSlice(getText("IGUI_TTRP_ArmLeanRight"), getTexture("media/ui/poses/standing/arm-lean-right.png"), doEmote, "TTRP_ManLeanRight")
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
    menu:addSlice(getText("IGUI_TTRP_Taunt"), getTexture("media/ui/poses/standing/jeb.png"), doEmote, "TTRP_Taunt")
    menu:addSlice(getText("IGUI_TTRP_FlourishingBow"), getTexture("media/ui/poses/standing/curtsy.png"), doEmote, "TTRP_FlourishingBow")
    menu:addSlice(getText("IGUI_TTRP_ShockedPose"), getTexture("media/ui/poses/standing/shocked.png"), doEmote, "TTRP_HandsBehindHeadShocked")
    menu:addSlice(getText("IGUI_TTRP_MilitarySalute"), getTexture("media/ui/poses/standing/military-salute.png"), doEmote, "TTRP_MilitarySalute")
    menu:addSlice(getText("IGUI_TTRP_HandOverEyes"), getTexture("media/ui/poses/standing/hand-over-eyes.png"), doEmote, "TTRP_HandOverEyes")
    menu:addSlice(getText("IGUI_TTRP_Pondering"), getTexture("media/ui/poses/standing/pondering.png"), doEmote, "TTRP_Pondering")
    menu:addSlice(getText("IGUI_TTRP_HuggingSelf"), getTexture("media/ui/poses/standing/holding-self.png"), doEmote, "TTRP_HUGGING_SELF")
    menu:addSlice(getText("IGUI_TTRP_SoccerFlex"), getTexture("media/ui/poses/standing/SoccerPose.png"), doEmote, "TTRP_SoccerFlex")
    menu:addSlice(getText("IGUI_TTRP_Pose28"), getTexture("media/ui/poses/standing/pose28.png"), doEmote, "TTRP_Pose28")
end

function StandingPaired(menu)
    menu:addSlice(getText("IGUI_TTRP_Hug"), getTexture("media/ui/poses/standing/hugA.png"), doEmote, "TTRP_Hug1")
    menu:addSlice(getText("IGUI_TTRP_MakeoutA"), getTexture("media/ui/poses/standing/kiss1.png"), doEmote, "TTRP_Makeout1")
    menu:addSlice(getText("IGUI_TTRP_MakeoutB"), getTexture("media/ui/poses/standing/kiss1.png"), doEmote, "TTRP_Makeout2")
    menu:addSlice(getText("IGUI_TTRP_ArmAroundOtherLeft"), getTexture("media/ui/poses/standing/standing-arm-left.png"), doEmote, "TTRP_Arm-Around-Other1")
    menu:addSlice(getText("IGUI_TTRP_ArmAroundOtherRight"), getTexture("media/ui/poses/standing/standing-arm-right.png"), doEmote, "TTRP_Arm-Around-Other2")
    menu:addSlice(getText("IGUI_TTRP_ArmAroundTwo"), getTexture("media/ui/poses/standing/arm-two.png"), doEmote, "TTRP_Arm-Around-Two")
    menu:addSlice(getText("IGUI_TTRP_GirlyArmLeft"), getTexture("media/ui/poses/standing/girly-left.png"), doEmote, "TTRP_GirlyArm")
    menu:addSlice(getText("IGUI_TTRP_GirlyArmRight"), getTexture("media/ui/poses/standing/girly-right.png"), doEmote, "TTRP_GirlyArm2")
    menu:addSlice(getText("IGUI_TTRP_Holding"), getTexture("media/ui/poses/standing/holding.png"), doEmote, "TTRP_Holding")
    menu:addSlice(getText("IGUI_TTRP_Kabedon"), getTexture("media/ui/poses/standing/kabedon.png"), doEmote, "TTRP_Kabedon")
    menu:addSlice(getText("IGUI_TTRP_HandsOnChest"), getTexture("media/ui/poses/standing/hand-chest.png"), doEmote, "TTRP_Hands-on-Others-Chest")
    menu:addSlice(getText("IGUI_TTRP_HoldHips"), getTexture("media/ui/poses/standing/hand-hips.png"), doEmote, "TTRP_HoldHips")
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
    menu:addSlice(getText("IGUI_TTRP_ChairHeadInHands"), getTexture("media/ui/poses/sitting/head-in-hands.png"), doEmote, "TTRP_HeadInHandsSit")
    menu:addSlice(getText("IGUI_TTRP_ChairHandsThighs"), getTexture("media/ui/poses/sitting/deep-squat.png"), doEmote, "TTRP_Hands_On_Thighs")
    menu:addSlice(getText("IGUI_TTRP_ChairForearmsThighs"), getTexture("media/ui/poses/sitting/arms-thighs.png"), doEmote, "TTRP_Sitting_ForearmsThighs")
    menu:addSlice(getText("IGUI_TTRP_ChairHandsHead"), getTexture("media/ui/poses/sitting/cantdothisnomore.png"), doEmote, "TTRP_Sitting_Hands-Head")
    menu:addSlice(getText("IGUI_TTRP_LazyBoy"), getTexture("media/ui/poses/sitting/lazy-boy.png"), doEmote, "TTRP_LazyBoy")
    menu:addSlice(getText("IGUI_TTRP_Manspread"), getTexture("media/ui/poses/sitting/manspread.png"), doEmote, "TTRP_MANSPREAD")
    menu:addSlice(getText("IGUI_TTRP_ManspreadArmsFolded"), getTexture("media/ui/poses/sitting/armsfoldedmanspread.png"), doEmote, "TTRP_ManspreadCrossedArms")
    menu:addSlice(getText("IGUI_TTRP_SassySit"), getTexture("media/ui/poses/sitting/sassy-sit.png"), doEmote, "TTRP_SassySit")
    menu:addSlice(getText("IGUI_TTRP_LegsCrossedChair"), getTexture("media/ui/poses/sitting/legs-crossed.png"), doEmote, "TTRP_SitInChairLegsCrossed")
    menu:addSlice(getText("IGUI_TTRP_ChairChinInHand"), getTexture("media/ui/poses/sitting/chair-chin-in-hand.png"), doEmote, "TTRP_SitWithChinInHand-Chair")
    menu:addSlice(getText("IGUI_TTRP_ChairOneLegUp"), getTexture("media/ui/poses/sitting/one-leg-up.png"), doEmote, "TTRP_SitInChairOneLegUp")
    menu:addSlice(getText("IGUI_TTRP_ChairHandsFolded"), getTexture("media/ui/poses/sitting/satrmscross.png"), doEmote, "TTRP_SitHandsFolded")
    menu:addSlice(getText("IGUI_TTRP_LegsKickedUp"), getTexture("media/ui/poses/sitting/legskickedup.png"), doEmote, "TTRP_Sit-Legs-Kicked-Up")
    menu:addSlice(getText("IGUI_TTRP_CrossChair"), getTexture("media/ui/poses/sitting/sit-cross-chair.png"), doEmote, "TTRP_Sit-Cross-Chair")
    menu:addSlice(getText("IGUI_TTRP_SunbathingBeachChair"), getTexture("media/ui/poses/sitting/suntanning2.png"), doEmote, "TTRP_Suntanning2")
    menu:addSlice(getText("IGUI_TTRP_GirlypopArmsLegs"), getTexture("media/ui/poses/sitting/girlypop-kneesup.png"), doEmote, "TTRP_Girlypop-Chair-Sit")
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
    menu:addSlice(getText("IGUI_TTRP_SittingBeside"), getTexture("media/ui/poses/sitting/lean-against.png"), doEmote, "TTRP_SittingNextTo")
    menu:addSlice(getText("IGUI_TTRP_SitHandThighRight"), getTexture("media/ui/poses/sitting/sit-hand-right.png"), doEmote, "TTRP_SitBesideHandThighRight")
    menu:addSlice(getText("IGUI_TTRP_SitHandThighLeft"), getTexture("media/ui/poses/sitting/sit-hand-left.png"), doEmote, "TTRP_SitBesideHandThighLeft")
    menu:addSlice(getText("IGUI_TTRP_SitArmAroundRight"), getTexture("media/ui/poses/sitting/sit-around-right.png"), doEmote, "TTRP_Sit-Arm-Around-Right")
    menu:addSlice(getText("IGUI_TTRP_SitArmAroundLeft"), getTexture("media/ui/poses/sitting/sit-around-left.png"), doEmote, "TTRP_Sit-Arm-Around-Left")
end

function SittingGroundPaired(menu)
    menu:addSlice(getText("IGUI_TTRP_SitBesideGround"), getTexture("media/ui/poses/sitting/sittingbeside.png"), doEmote, "TTRP_SittingNextToGround")
    menu:addSlice(getText("IGUI_TTRP_SitLegsSpread"), getTexture("media/ui/poses/sitting/legsspread.png"), doEmote, "TTRP_Sit-on-Ground-Legs-Spread")
    menu:addSlice(getText("IGUI_TTRP_SitBetweenLegs"), getTexture("media/ui/poses/sitting/sitbetween.png"), doEmote, "TTRP_Sit-Between-legs")
    menu:addSlice(getText("IGUI_TTRP_SitArmAroundLeft"), getTexture("media/ui/poses/sitting/arm-around-left.png"), doEmote, "TTRP_Sitting-Arm-Around")
    menu:addSlice(getText("IGUI_TTRP_SitArmAroundRight"), getTexture("media/ui/poses/sitting/arm-around-right.png"), doEmote, "TTRP_Sitting-Arm-Around2")
    menu:addSlice(getText("IGUI_TTRP_HeadInLap"), getTexture("media/ui/poses/sitting/stroke-head.png"), doEmote, "TTRP_Head-In-Lap")
end

---------------------
-- LYING DOWN MENU --
---------------------
function subTTRPLying(menu)
    menu:addSlice(getText("IGUI_TTRP_LyingGround"), getTexture("media/ui/menus/lying-ground.png"), ISRadialMenu.createSubMenu, menu, subTTRPLyingFloor)
    menu:addSlice(getText("IGUI_TTRP_LyingFurniture"), getTexture("media/ui/menus/lying-furn.png"), ISRadialMenu.createSubMenu, menu, subTTRPLyingFurniture)
    menu:addSlice(getText("IGUI_TTRP_PairedLying"), getTexture("media/ui/menus/lying-paired-ground.png"), ISRadialMenu.createSubMenu, menu, subLyingPairedGround)
    menu:addSlice(getText("IGUI_TTRP_PairedLyingFurniture"), getTexture("media/ui/menus/lying-paired-furn.png"), ISRadialMenu.createSubMenu, menu, subLyingPairedFurniture)

end


function subTTRPLyingFloor(menu)
    menu:addSlice(getText("IGUI_TTRP_DownAndOut"), getTexture("media/ui/poses/laying/injured1.png"), doEmote, "TTRP_DownAndOut")
    menu:addSlice(getText("IGUI_TTRP_LyingInjured2"), getTexture("media/ui/poses/laying/injured2.png"), doEmote, "TTRP_LyingInjured2")
    menu:addSlice(getText("IGUI_TTRP_Cloudspotting"), getTexture("media/ui/poses/laying/cloudwatching.png"), doEmote, "TTRP_Cloudspotting")
    menu:addSlice(getText("IGUI_TTRP_Lie_Flutter_Kick"), getTexture("media/ui/poses/laying/flutter-kick.png"), doEmote, "TTRP_Lie_Flutter_Kick")
    menu:addSlice(getText("IGUI_TTRP_FeetOnSofa"), getTexture("media/ui/poses/laying/legs-on-chair.png"), doEmote, "TTRP_FeetOnSofa")
    menu:addSlice(getText("IGUI_TTRP_FetalPosition"), getTexture("media/ui/poses/laying/fetal.png"), doEmote, "TTRP_FetalPosition")
    menu:addSlice(getText("IGUI_TTRP_Faceplant"), getTexture("media/ui/poses/laying/faceplant.png"), doEmote, "TTRP_Faceplant")
    menu:addSlice(getText("IGUI_TTRP_LayStomach1"), getTexture("media/ui/poses/laying/layingstomach.png"), doEmote, "TTRP_LayStomach1")
    menu:addSlice(getText("IGUI_TTRP_FrenchGirl"), getTexture("media/ui/poses/laying/french_boi.png"), doEmote, "TTRP_FrenchGirl")
    menu:addSlice(getText("IGUI_TTRP_French_Girl_Reversed"), getTexture("media/ui/poses/laying/french_boi.png"), doEmote, "TTRP_French-Girl-Reversed")
    menu:addSlice(getText("IGUI_TTRP_Lying_Asleep"), getTexture("media/ui/poses/laying/sleeping1.png"), doEmote, "TTRP_Lying-Asleep")
    menu:addSlice(getText("IGUI_TTRP_Lying_Asleep_Reversed"), getTexture("media/ui/poses/laying/sleeping1.png"), doEmote, "TTRP_Lying-Asleep-Reversed")
    menu:addSlice(getText("IGUI_TTRP_Lying_Sleeping2"), getTexture("media/ui/poses/laying/sleeping2.png"), doEmote, "TTRP_Lying-Sleeping2")
    menu:addSlice(getText("IGUI_TTRP_Suntanning"), getTexture("media/ui/poses/laying/suntanning.png"), doEmote, "TTRP_Suntanning")
    menu:addSlice(getText("IGUI_TTRP_LYING_ELBOWS"), getTexture("media/ui/poses/laying/elbows.png"), doEmote, "TTRP_LYING_ELBOWS")
 end
 
 function subTTRPLyingFurniture(menu)
     menu:addSlice(getText("IGUI_TTRP_FetalFurniture"), getTexture("media/ui/poses/laying/fetal.png"), doEmote, "TTRP_FetalFurniture")
     menu:addSlice(getText("IGUI_TTRP_StomachLayBed"), getTexture("media/ui/poses/laying/layingstomach.png"), doEmote, "TTRP_StomachLayBed")
     menu:addSlice(getText("IGUI_TTRP_LegFlutterFurniture"), getTexture("media/ui/poses/laying/flutter-kick.png"), doEmote, "TTRP_LegFlutterFurniture")
     menu:addSlice(getText("IGUI_TTRP_French_Girl_ReversedFurniture"), getTexture("media/ui/poses/laying/french_boi.png"), doEmote, "TTRP_French-Girl-ReversedFurniture")
     menu:addSlice(getText("IGUI_TTRP_Lying_AsleepFurniture"), getTexture("media/ui/poses/laying/sleeping1.png"), doEmote, "TTRP_Lying-AsleepFurniture")
     menu:addSlice(getText("IGUI_TTRP_Lying_Asleep_ReversedFurniture"), getTexture("media/ui/poses/laying/sleeping1.png"), doEmote, "TTRP_Lying-Asleep-ReversedFurniture")
     menu:addSlice(getText("IGUI_TTRP_Lying_Sleeping2Furniture"), getTexture("media/ui/poses/laying/sleeping2.png"), doEmote, "TTRP_Lying-Sleeping2Furniture")
     menu:addSlice(getText("IGUI_TTRP_LYING_ELBOWS_BED"), getTexture("media/ui/poses/laying/elbows.png"), doEmote, "TTRP_LYING_ELBOWS_BED")
 end
 
 function subLyingPairedGround(menu)
     menu:addSlice(getText("IGUI_TTRP_Cuddle1"), getTexture("media/ui/poses/laying/cuddle-reverse.png"), doEmote, "TTRP_Cuddle1")
     menu:addSlice(getText("IGUI_TTRP_Cuddle_Reversed"), getTexture("media/ui/poses/laying/cuddle-reverse.png"), doEmote, "TTRP_Cuddle-Reversed")
     menu:addSlice(getText("IGUI_TTRP_Laying_Head_In_Lap"), getTexture("media/ui/poses/laying/head-lap.png"), doEmote, "TTRP_Laying-Head-In-Lap")
 end
 
 function subLyingPairedFurniture(menu)
     menu:addSlice(getText("IGUI_TTRP_Cuddle1_Offset"), getTexture("media/ui/poses/laying/cuddle-reverse.png"), doEmote, "TTRP_Cuddle1-Offset")
     menu:addSlice(getText("IGUI_TTRP_Cuddle_Reversed_Offset"), getTexture("media/ui/poses/laying/cuddle-reverse.png"), doEmote, "TTRP_Cuddle-Reversed-Offset")
 end
----------------
-- PROPS MENU --
----------------
function subTTRPprops(menu)
    menu:addSlice(getText("IGUI_TTRP_LongRifles"), getTexture("media/ui/menus/rifle-icon.png"), ISRadialMenu.createSubMenu, menu, subLongRifles)
    menu:addSlice(getText("IGUI_TTRP_Pistols"), getTexture("media/ui/menus/pistols-icon.png"), ISRadialMenu.createSubMenu, menu, subPistols)
    menu:addSlice(getText("IGUI_TTRP_LongWeapons"), getTexture("media/ui/menus/melee-icon.png"), ISRadialMenu.createSubMenu, menu, subLongWeapons)
end

function subLongRifles(menu)
  menu:addSlice("Stand - Holding Rifle Steady", getTexture("media/ui/poses/props/aimrifle.png"), doEmote, "TTRP_HoldRifleSteady")
  menu:addSlice("Stand - Holding Rifle Idle", getTexture("media/ui/poses/props/rifleidle.png"), doEmote, "TTRP_HoldRifle")
  menu:addSlice("Stand - Holding Rifle Gunpoint", getTexture("media/ui/poses/props/rifle-gunpoint.png"), doEmote, "TTRP_HoldAtGunpointRifle")
  menu:addSlice("Stand - Holding Rifle Idle 2", getTexture("media/ui/poses/props/rifle-idle.png"), doEmote, "TTRP_Holding_Rifle_Idle_2")
  menu:addSlice("Stand - Holding Rifle Up Idle", getTexture("media/ui/poses/props/rifle-idle-3.png"), doEmote, "TTRP_Rifle-One-Hand-Up")
  menu:addSlice("Kneel - Holding Rifle Steady", getTexture("media/ui/poses/props/kneelshoot.png"), doEmote, "TTRP_HoldRifleKneel")
  menu:addSlice("Kneel - Holding Rifle Idle", getTexture("media/ui/poses/props/kneelidle.png"), doEmote, "TTRP_HoldRifleIdleKneel")
  menu:addSlice("Kneel - Holding Rifle Upwards", getTexture("media/ui/poses/props/holdrifleup.png"), doEmote, "TTRP_HoldRifleUp")
end

function subLongWeapons(menu)
    menu:addSlice(getText("IGUI_TTRP_BatPat"), getTexture("media/ui/poses/props/batpat.png"), doEmote, "TTRP_BatPat")
    menu:addSlice(getText("IGUI_TTRP_HoldBehindHead"), getTexture("media/ui/poses/props/weaponbehindhead.png"), doEmote, "TTRP_HoldBehindHead")
    menu:addSlice(getText("IGUI_TTRP_Weapon_Shoulder"), getTexture("media/ui/poses/props/weaponshoulder.png"), doEmote, "TTRP_Weapon-Shoulder")
    menu:addSlice(getText("IGUI_TTRP_SwordStance1"), getTexture("media/ui/poses/props/swordready.png"), doEmote, "TTRP_SwordStance1")
    menu:addSlice(getText("IGUI_TTRP_SwordStance2"), getTexture("media/ui/poses/props/swordready2.png"), doEmote, "TTRP_SwordStance2")
    menu:addSlice(getText("IGUI_TTRP_HoldSpear"), getTexture("media/ui/poses/props/holdspear.png"), doEmote, "TTRP_HoldingSpear")
    menu:addSlice(getText("IGUI_TTRP_HoldSpearAnime"), getTexture("media/ui/poses/props/holdspearanime.png"), doEmote, "TTRP_HoldSpearAnime")
    menu:addSlice(getText("IGUI_TTRP_HoldAtSpearpoint"), getTexture("media/ui/poses/props/whyareyoureadingthis.png"), doEmote, "TTRP_HoldAtSpearpoint")
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
    menu:addSlice(getText("IGUI_TTRP_EmoteSnortPixie"), getTexture("media/ui/poses/emotes/cocainum.png"), doEmote, "TTRP_PixieSticks")
    menu:addSlice(getText("IGUI_TTRP_EmoteAccuse"), getTexture("media/ui/poses/emotes/accuser.png"), doEmote, "TTRP_Accost")
    menu:addSlice(getText("IGUI_TTRP_EmoteUpYours"), getTexture("media/ui/poses/emotes/up-yours.png"), doEmote, "TTRP_UpYours")
    menu:addSlice(getText("IGUI_TTRP_EmoteUpYoursCasual"), getTexture("media/ui/poses/emotes/up-yours-casual.png"), doEmote, "TTRP_UpYoursCasual")
    menu:addSlice(getText("IGUI_TTRP_EmoteBigWave"), getTexture("media/ui/poses/emotes/big-wave.png"), doEmote, "TTRP_BigWave")
    menu:addSlice(getText("IGUI_TTRP_EmoteThink"), getTexture("media/ui/poses/emotes/thinking.png"), doEmote, "TTRP_Think")
    menu:addSlice(getText("IGUI_TTRP_EmoteRudeGesture"), getTexture("media/ui/poses/emotes/rude-jerk.png"), doEmote, "TTRP_JackRude")
    menu:addSlice(getText("IGUI_TTRP_EmotePanic"), getTexture("media/ui/poses/emotes/freaking-out.png"), doEmote, "TTRP_Panic")
    menu:addSlice(getText("IGUI_TTRP_EmoteSigh"), getTexture("media/ui/poses/emotes/big-sigh.png"), doEmote, "TTRP_Sighing")
    menu:addSlice(getText("IGUI_TTRP_EmoteCry"), getTexture("media/ui/poses/emotes/crying1.png"), doEmote, "TTRP_Crying1")
    menu:addSlice(getText("IGUI_TTRP_EmoteFacepalm"), getTexture("media/ui/poses/emotes/facepalm.png"), doEmote, "TTRP_Facepalm")
    menu:addSlice(getText("IGUI_TTRP_EmoteScared"), getTexture("media/ui/poses/emotes/scared.png"), doEmote, "TTRP_Scared_Look")
end

function subTTRPDances(menu)
    menu:addSlice(getText("IGUI_TTRP_AwkwardDance1"), getTexture("media/ui/poses/dancing/Awkward-Dance-1.png"), doEmote, "TTRP_AwkwardDance1")
    menu:addSlice(getText("IGUI_TTRP_AwkwardDance2"), getTexture("media/ui/poses/dancing/Awkward-Dance-2.png"), doEmote, "TTRP_AwkwardDance2")
    menu:addSlice(getText("IGUI_TTRP_AwkwardDance3"), getTexture("media/ui/poses/dancing/Awkward-Dance-3.png"), doEmote, "TTRP_AwkwardDance3")
    menu:addSlice(getText("IGUI_TTRP_AwkwardDance4"), getTexture("media/ui/poses/dancing/BBQDance.png"), doEmote, "TTRP_BBQShimmy")
end

function subTTRPDynamic(menu) 
    menu:addSlice("Stomach Wound / Upset Stomach", getTexture("media/ui/poses/dynamic/handstomach.png"), doEmote, "TTRP_HandsOverStomach")
    menu:addSlice("Arm in Sling", getTexture("media/ui/poses/dynamic/sling.png"), doEmote, "TTRP_ArmSling")
    menu:addSlice("Limping", getTexture("media/ui/poses/dynamic/injuredlimp.png"), doEmote, "TTRP_LimpLeg")
    -- menu:addSlice("Brushing/Mopping", getTexture("media/ui/poses/dynamic/brushmop.png"), doTTRPActions, "Base.PropaneTank", "mop")

end


--------------------
-- FAVORITES MENU --
--------------------

function subTTRPFavorites(menu)
    if type(Favorites) ~= "table" then
        return
    end

    for text, data in pairs(Favorites) do
        if data and data.texture and data.command then
            -- print("Processing favorite:", text, "Texture raw:", tostring(data.texture), "Type:", type(data.texture))
            -- Clean up the texture path for favorites added while the game is running. The game saves width and height data of the textures in-memory for the currently running game instance as a userdata JSON string rather than a readable string path.
            -- We need to remove that data from the table when reading it from the JSON file or it errors out unless you restart your game.
            local texturePath
            if type(data.texture) == "userdata" and data.texture.getName then
                texturePath = data.texture:getName() -- Convert userdata to string path
                -- print("Converted texture userdata to path:", texturePath)
            elseif type(data.texture) == "string" then
                texturePath = data.texture 
            else
                -- print("Error: Invalid texture type for favorite:", text)
             end
            local cleanTexturePath = texturePath:gsub("\\\\", "/"):gsub("\\", "/")
            -- print("Cleaned texture path for:", text, "is:", cleanTexturePath)

            local texture = getTexture(cleanTexturePath)
            if not texture then
                print("TTRP Poses Error: Could not load texture for " .. text .. " (" .. tostring(cleanTexturePath) .. ")")
            end

            -- We need to hardcode the function, couldn't figure out how to correctly extract function data from JSON strings. Might revisit this to let it dynamically store function information in JSON, but I couldn't figure out how.
            local commandFunc = doEmote
            local commandArg = data.command[2]
            menu:addSlice(text, texture, commandFunc, commandArg)

        else
            -- print("Error: Invalid data for favorite:", text)
        end
    end
end

-------------------------------------------------------------------------------------
-- Modified Fuu's action code - Timed Action triggers. Currently these do nothing. --
-- These will be utilized in a future update.                                      --
-------------------------------------------------------------------------------------

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

ForbiddenPoses = {
    ["TTRP.TTRP_Forbidden_Splits_Card"] = "TTRP_TwerkSplits",
    ["TTRP.TTRP_Forbidden_Twerk_Card"] = "TTRP_Twerk",
    ["TTRP.TTRP_Forbidden_T-Pose"] = "TTRP_T-Pose",
    ["TTRP.TTRP_Forbidden_Frey"] = "TTRP_CaseyFrey",
    ["TTRP.TTRP_Forbidden_Restart"] = "TTRP_Restart",
    ["TTRP.TTRP_PinkGuy"] = "TTRP_PinkGuy",
}

function subForbidden(menu)
    local playerItems = getPlayer():getInventory():getItems()
    for i=1,playerItems:size() do
        local item = playerItems:get(i-1)
        if ForbiddenPoses[item:getFullType()] then
            menu:addSlice(ForbiddenPoses[item:getFullType()], getTexture('media/ui/poses/Forbidden/' .. ForbiddenPoses[item:getFullType()] .. '.png'), doEmote, ForbiddenPoses[item:getFullType()])
        end
    end
end

EmoteMenuAPI.registerSlice("TTRP Poses", poseTTRPMain)

---------------------------------------------------------------
-- Radial Slice Detection and JSON saving For Favorites      --
---------------------------------------------------------------

local function saveFavorites()
    if type(Favorites) ~= "table" then
       -- print("Favorites is not a valid table.")
        return
    end

    local serializableFavorites = {}

    for key, value in pairs(Favorites) do
        local textureName = value.texture and value.texture.getName and value.texture:getName() or tostring(value.texture)
        serializableFavorites[key] = {
            texture = textureName, 
            command = {"doEmote", value.command[2]} 
        }
    end

    local savePath = getModFileWriter("TTRPPoses", "favorites.json", true, false)
    if not savePath then
       -- print("Failed to open or create favorites.json.")
        return
    end

    local jsonString
    local success, err = pcall(function()
        jsonString = json.stringify(serializableFavorites)
    end)

    if not success then
       -- print("Error encoding Favorites to JSON: " .. tostring(err))
        return
    end

    savePath:write(jsonString)
    savePath:close()
   -- print("Favorites saved successfully.")
end

local function loadFavorites()
    local filePath = getModFileReader("TTRPPoses", "favorites.json", false)
    if not filePath then
       -- print("Favorites file not found.")
        Favorites = {}
        return
    end

    local jsonString = filePath:readLine()
    filePath:close()

    if not jsonString or jsonString == "" then
       -- print("No data to load from favorites.json.")
        Favorites = {}
        return
    end

    local success, result = pcall(function()
        return json.parse(jsonString)
    end)

    if success and type(result) == "table" then
        Favorites = {}
        for key, value in pairs(result) do
            local commandFunc = doEmote

            Favorites[key] = {
                texture = value.texture, 
                command = {commandFunc, value.command[2]} 
            }
        end
       -- print("Favorites loaded successfully.")
    else
       -- print("Error decoding JSON: " .. tostring(result))
        Favorites = {}
    end
end

function SaveRadialSlice(key)
    if key == getCore():getKey("TTRP_Favorite") then 
        local player = getSpecificPlayer(0) 

        local radialMenu = getPlayerRadialMenu(0) 
        if radialMenu and radialMenu:isReallyVisible() then
            local mx, my = getMouseX(), getMouseY()
            local lx = mx - radialMenu:getX()
            local ly = my - radialMenu:getY()
            
            local sliceIndex = radialMenu.javaObject:getSliceIndexFromMouse(lx, ly)
            
            if sliceIndex and sliceIndex >= 0 then
                local sliceText = radialMenu:getSliceText(sliceIndex + 1)
                if sliceText then
                    local sliceTexture = radialMenu:getSliceTexture(sliceIndex + 1)
                    local sliceCommand = radialMenu:getSliceCommand(sliceIndex + 1)

                    if sliceCommand[1] ~= doEmote then
                        return
                    end

                    if Favorites[sliceText] then
                        Favorites[sliceText] = nil
                    else
                        Favorites[sliceText] = {
                            texture = sliceTexture,
                            command = sliceCommand,
                        }
                    end

                    saveFavorites()

                    if radialMenu then
                        radialMenu:refreshFavoritesMenu(player)
                        -- print("Refreshed Favorites menu.")
                    end
                    

                    local filePath = getFileReader("favorites.json", false)
                    if filePath then
                        filePath:close()
                    end
                end
            end
        end
    end
end

----------------------------------------
-- Menu refresh on Favorites Addition --
----------------------------------------
function ISRadialMenu:clearSlices()
    self.slices = {}
    if self.javaObject then
        self.javaObject:clear() 
    end
end

function ISRadialMenu:refreshFavoritesMenu(player)
    self:clearSlices()
    TTRPSubmenu(self, player)
    self:display()
end

---------------------------------------
-- Add Keybindings to the main menu. --
---------------------------------------
Events.OnGameBoot.Add(function()
    local index = nil
    for i, b in ipairs(keyBinding) do
        if b.value == "Equip/Turn On/Off Light Source" then
            index = i
            break
        end
    end

    if index then
        table.insert(keyBinding, index + 1, {value = "TTRP_Favorite", key = 53})
    end
end)

Events.OnGameStart.Add(loadFavorites)
Events.OnKeyPressed.Add(SaveRadialSlice)



