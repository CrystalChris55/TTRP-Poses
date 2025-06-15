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
function doEmote(emote, player)
    player:playEmote(emote)
    if SandboxVars.TTRPPoses.ToggleGhosting then
        player:setGhostMode(true)
    end
end
-- Function to cancel emotes, and if the user is not an admin, sets ghost mode back to false.
function cancelEmote(emote, player)
    player:playEmote(emote)
    if not isAdmin() then
        player:setGhostMode(false)
    end
end

-----------------------------------------------
           -- Main Menu --
-----------------------------------------------

function poseTTRPMain(menu, player)
    menu:addSlice(getText("IGUI_TTRP_Poses"), getTexture("media/ui/menus/main-menu.png"), ISRadialMenu.createSubMenu, menu, TTRPSubmenu, player)
end

-----------------------------------------------
       -- Submenus Creation --
-----------------------------------------------

-- Create the submenus with categories
function TTRPSubmenu(menu, player)
    menu:addSlice(getText("IGUI_TTRP_Cancel"), getTexture("media/ui/menus/stop.png"), cancelEmote, "BobRPS_Cancel", player)
    menu:addSlice(getText("IGUI_TTRP_Standing"), getTexture("media/ui/menus/Standing_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPStanding, player)
    menu:addSlice(getText("IGUI_TTRP_Sitting"), getTexture("media/ui/menus/Sitting_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPSit, player)
    menu:addSlice(getText("IGUI_TTRP_Lying"), getTexture("media/ui/menus/lying_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPLying, player)
    menu:addSlice(getText("IGUI_TTRP_Props"), getTexture("media/ui/menus/props_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPprops, player)
    menu:addSlice(getText("IGUI_TTRP_Emotes"), getTexture("media/ui/menus/emotes_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPemotes, player)
    menu:addSlice(getText("IGUI_TTRP_Dances"), getTexture("media/ui/menus/dance_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPDances, player)
    menu:addSlice(getText("IGUI_TTRP_Dynamic"), getTexture("media/ui/menus/dynamic_icon.png"), ISRadialMenu.createSubMenu, menu, subTTRPDynamic, player)

    local function hasFavorites()
        -- Adds a submenu if you have favorites saved to a table.
        for _ in pairs(Favorites) do
            return true 
        end
        return false
    end

    if hasFavorites() then
        menu:addSlice(getText("IGUI_TTRP_Favorites"), getTexture("media/ui/menus/favorites.png"), ISRadialMenu.createSubMenu, menu, subTTRPFavorites, player)
    end

    local RPAspc = false
    local playerItems = getPlayer():getInventory():getItems()
    -- Adds a submenu if you have forbidden cards in your inventory
    for i=1, playerItems:size() do
        local item = playerItems:get(i-1)
        if ForbiddenPoses[item:getFullType()] then
            if not RPAspc then
                RPAspc = true
                menu:addSlice(getText("IGUI_TTRP_Forbidden"), getTexture("media/ui/menus/Forbidden.png"), ISRadialMenu.createSubMenu, menu, subForbidden, player)
            end
        end
    end
end

-------------------
-- STANDING MENU --
-------------------

function subTTRPStanding(menu, player)
    -- Standing Main Menu
    menu:addSlice(getText("IGUI_TTRP_StandingLean"), getTexture("media/ui/menus/leaning_icon.png"), ISRadialMenu.createSubMenu, menu, StandingLean, player)
    menu:addSlice(getText("IGUI_TTRP_StandingLean2"), getTexture("media/ui/menus/lean2.png"), ISRadialMenu.createSubMenu, menu, StandingLean2, player)
    menu:addSlice(getText("IGUI_TTRP_IdlePoses"), getTexture("media/ui/menus/upright_icon.png"), ISRadialMenu.createSubMenu, menu, IdlePoses, player)
    menu:addSlice(getText("IGUI_TTRP_IdlePoses2"), getTexture("media/ui/menus/upright_icon2.png"), ISRadialMenu.createSubMenu, menu, IdlePoses2, player)
    menu:addSlice(getText("IGUI_TTRP_ActivePoses"), getTexture("media/ui/menus/active_icon.png"), ISRadialMenu.createSubMenu, menu, ActivePoses, player)
    menu:addSlice(getText("IGUI_TTRP_StandingPaired"), getTexture("media/ui/menus/paired_icon.png"), ISRadialMenu.createSubMenu, menu, StandingPaired, player)
    menu:addSlice(getText("IGUI_TTRP_Injured"), getTexture("media/ui/menus/standing-injured.png"), ISRadialMenu.createSubMenu, menu, subStandingInjured, player)
end

function StandingLean(menu, player)
    -- Leaning Poses Menu
    menu:addSlice(getText("IGUI_TTRP_LeanSassy"), getTexture("media/ui/poses/standing/lean-sassy.png"), doEmote, "TTRP_SassyLean", player)
    menu:addSlice(getText("IGUI_TTRP_LeanSassyReverse"), getTexture("media/ui/poses/standing/sassy-reverse.png"), doEmote, "TTRP_SassyLeanReverse", player)
    menu:addSlice(getText("IGUI_TTRP_LeanHandsFlat"), getTexture("media/ui/poses/standing/hands-table.png"), doEmote, "TTRP_LeanHandsFlat", player)
    menu:addSlice(getText("IGUI_TTRP_LeanOnChin"), getTexture("media/ui/poses/standing/chin-on-fist.png"), doEmote, "TTRP_LeanOnChin", player)
    menu:addSlice(getText("IGUI_TTRP_LeanFootObject"), getTexture("media/ui/poses/standing/foot-object.png"), doEmote, "TTRP_Standing-Foot-On-Object", player)
    menu:addSlice(getText("IGUI_TTRP_GlassBoxEmotion"), getTexture("media/ui/poses/standing/glass-case-emotion.png"), doEmote, "TTRP_GlassBoxOfEmotion", player)
    menu:addSlice(getText("IGUI_TTRP_LeanBackHandsFolded"), getTexture("media/ui/poses/standing/lean-back-folded-hands.png"), doEmote, "TTRP_Lean-Back-Hands-Folded", player)
    menu:addSlice(getText("IGUI_TTRP_LeanTableLeft"), getTexture("media/ui/poses/standing/lean-table-right.png"), doEmote, "TTRP_LeanLeftTable", player)
    menu:addSlice(getText("IGUI_TTRP_LeanTableRight"), getTexture("media/ui/poses/standing/lean-table-left.png"), doEmote, "TTRP_LeanRightTable", player)
    menu:addSlice(getText("IGUI_TTRP_LeanCrossedArmLeft"), getTexture("media/ui/poses/standing/lean-right-crossed-arms.png"), doEmote, "TTRP_Crossed-Arm-Lean-Left", player)
    menu:addSlice(getText("IGUI_TTRP_LeanCrossedArmRight"), getTexture("media/ui/poses/standing/lean-left-crossed-arms.png"), doEmote, "TTRP_Crossed-Arm-Lean-Right", player)
    menu:addSlice(getText("IGUI_TTRP_LeanBackPocket"), getTexture("media/ui/poses/standing/lean-pocket.png"), doEmote, "TTRP_LeanBackHandinPocket", player)
    menu:addSlice(getText("IGUI_TTRP_LeanBackHandsBehind"), getTexture("media/ui/poses/standing/leantback.png"), doEmote, "TTRP_LeantBackHandsResting", player)
    menu:addSlice(getText("IGUI_TTRP_GirlypopDoorLeanLeft"), getTexture("media/ui/poses/standing/lean-right-girly-pop.png"), doEmote, "TTRP_GirlypopDoorLeanLeft", player)
    menu:addSlice(getText("IGUI_TTRP_GirlypopDoorLeanRight"), getTexture("media/ui/poses/standing/lean-left-girly-pop.png"), doEmote, "TTRP_GirlypopDoorLeanRight", player)
end

function StandingLean2(menu, player)
    -- Standing Lean 2
    menu:addSlice(getText("IGUI_TTRP_LeanArmUpLeft"), getTexture("media/ui/poses/standing/LeanArmUpLeft.png"), doEmote, "TTRP_LeanArmUpLeft", player)
    menu:addSlice(getText("IGUI_TTRP_LeanArmUpRight"), getTexture("media/ui/poses/standing/LeanArmUpRight.png"), doEmote, "TTRP_LeanArmUpRight", player)
    menu:addSlice(getText("IGUI_TTRP_ArmLeanLeft"), getTexture("media/ui/poses/standing/arm-lean-left.png"), doEmote, "TTRP_ManLeanLeft", player)
    menu:addSlice(getText("IGUI_TTRP_ArmLeanRight"), getTexture("media/ui/poses/standing/arm-lean-right.png"), doEmote, "TTRP_ManLeanRight", player)
    menu:addSlice(getText("IGUI_TTRP_Bent_Forward"), getTexture("media/ui/poses/standing/bent-forward.png"), doEmote, "TTRP_Bent_Forward", player)
    menu:addSlice(getText("IGUI_TTRP_LookingDownAt"), getTexture("media/ui/poses/standing/leanover.png"), doEmote, "TTRP_LookingDownAt", player)
    menu:addSlice(getText("IGUI_TTRP_Lean-Back-Arms-Crossed-Shy"), getTexture("media/ui/poses/standing/lean-back-shy.png"), doEmote, "TTRP_Lean-Back-Arms-Crossed", player)
    menu:addSlice(getText("IGUI_TTRP_LeanBackHoldVest"), getTexture("media/ui/poses/standing/leanbackvest.png"), doEmote, "TTRP_LeanBackHoldVest", player)
    menu:addSlice(getText("IGUI_TTRP_LeanBackHandsPockets"), getTexture("media/ui/poses/standing/leanbackhandspockets.png"), doEmote, "TTRP_LeanBackHandsPockets", player)

end

function IdlePoses(menu, player)
    -- Standing menu
    menu:addSlice(getText("IGUI_TTRP_JoJoPose"), getTexture("media/ui/poses/standing/jojo.png"), doEmote, "TTRP_JoJoPose", player)
    menu:addSlice(getText("IGUI_TTRP_HoldingHandsShy"), getTexture("media/ui/poses/standing/holding-hands-shy.png"), doEmote, "TTRP_HoldHandsShy", player)
    menu:addSlice(getText("IGUI_TTRP_SassyStance"), getTexture("media/ui/poses/standing/sassystand.png"), doEmote, "TTRP_SassyStance", player)
    menu:addSlice(getText("IGUI_TTRP_HandOnHipAlt"), getTexture("media/ui/poses/standing/hand-on-hip-alt.png"), doEmote, "TTRP_HandOnHipAlt", player)
    menu:addSlice(getText("IGUI_TTRP_HandsOnHipsIdle"), getTexture("media/ui/poses/standing/hands-on-hip-idle.png"), doEmote, "TTRP_HandsOnHipsIdle", player)
    menu:addSlice(getText("IGUI_TTRP_HandOnChinHip"), getTexture("media/ui/poses/standing/hand-hip-chin.png"), doEmote, "TTRP_HandOnHipHandOnChin", player)
    menu:addSlice(getText("IGUI_TTRP_HandInPocketCasual"), getTexture("media/ui/poses/standing/hand-in-pocket-casual.png"), doEmote, "TTRP_handinpocketcasual", player)
    menu:addSlice(getText("IGUI_TTRP_FoldingHandsDemurely"), getTexture("media/ui/poses/standing/demure.png"), doEmote, "TTRP_HandsFoldedDemure", player)
    menu:addSlice(getText("IGUI_TTRP_HoldVestStraps"), getTexture("media/ui/poses/standing/hold-vest.png"), doEmote, "TTRP_HoldVest", player)
    menu:addSlice(getText("IGUI_TTRP_RubbingHandBehindHead"), getTexture("media/ui/poses/standing/hand-behind-head.png"), doEmote, "TTRP_Hand-Behind-Head-Rub", player)
    menu:addSlice(getText("IGUI_TTRP_HoldingNeck"), getTexture("media/ui/poses/standing/holdneck.png"), doEmote, "TTRP_HoldNeck", player)
    menu:addSlice(getText("IGUI_TTRP_ThinkHoldSelfblend"), getTexture("media/ui/poses/standing/thinkholdself.png"), doEmote, "TTRP_ThinkHoldSelfblend", player)
    menu:addSlice(getText("IGUI_TTRP_ShyHoldSelf"), getTexture("media/ui/poses/standing/shyholdself.png"), doEmote, "TTRP_ShyHoldSelf", player)
    menu:addSlice(getText("IGUI_TTRP_Shy-Hands-Around-Self-2"), getTexture("media/ui/poses/standing/shyholdself2.png"), doEmote, "TTRP_Shy-Hands-Around-Self-2", player)
end

function IdlePoses2(menu, player)
    menu:addSlice(getText("IGUI_TTRP_HandHipForearmForehead"), getTexture("media/ui/poses/standing/handhipforearm.png"), doEmote, "TTRP_HandHipForearmForehead", player)
    menu:addSlice(getText("IGUI_TTRP_LowCrossedArms"), getTexture("media/ui/poses/standing/lowcrossedarms.png"), doEmote, "TTRP_LowCrossedArms", player)
end


function ActivePoses(menu, player)
    menu:addSlice(getText("IGUI_TTRP_Taunt"), getTexture("media/ui/poses/standing/jeb.png"), doEmote, "TTRP_Taunt", player)
    menu:addSlice(getText("IGUI_TTRP_WhoDoYouThinkIAm"), getTexture("media/ui/poses/standing/gurrenlagenn.png"), doEmote, "TTRP_WhoDoYouThinkIAmblend", player)
    menu:addSlice(getText("IGUI_TTRP_PierceHeaven"), getTexture("media/ui/poses/standing/pierceheaven.png"), doEmote, "TTRP_PierceHeaven", player)
    menu:addSlice(getText("IGUI_TTRP_FlourishingBow"), getTexture("media/ui/poses/standing/curtsy.png"), doEmote, "TTRP_FlourishingBow", player)
    menu:addSlice(getText("IGUI_TTRP_ShockedPose"), getTexture("media/ui/poses/standing/shocked.png"), doEmote, "TTRP_HandsBehindHeadShocked", player)
    menu:addSlice(getText("IGUI_TTRP_MilitarySalute"), getTexture("media/ui/poses/standing/military-salute.png"), doEmote, "TTRP_MilitarySalute", player)
    menu:addSlice(getText("IGUI_TTRP_HandOverEyes"), getTexture("media/ui/poses/standing/hand-over-eyes.png"), doEmote, "TTRP_HandOverEyes", player)
    menu:addSlice(getText("IGUI_TTRP_Pondering"), getTexture("media/ui/poses/standing/pondering.png"), doEmote, "TTRP_Pondering", player)
    menu:addSlice(getText("IGUI_TTRP_HuggingSelf"), getTexture("media/ui/poses/standing/holding-self.png"), doEmote, "TTRP_HUGGING_SELF", player)
    menu:addSlice(getText("IGUI_TTRP_SoccerFlex"), getTexture("media/ui/poses/standing/SoccerPose.png"), doEmote, "TTRP_SoccerFlex", player)
    menu:addSlice(getText("IGUI_TTRP_Pose28"), getTexture("media/ui/poses/standing/pose28.png"), doEmote, "TTRP_Pose28", player)
    menu:addSlice(getText("IGUI_TTRP_Standing_OofOwMyBalls"), getTexture("media/ui/poses/standing/owmyballs.png"), doEmote, "TTRP_Standing_OofOwMyBalls", player)
end

function StandingPaired(menu, player)
    menu:addSlice(getText("IGUI_TTRP_Hug"), getTexture("media/ui/poses/standing/hugA.png"), doEmote, "TTRP_Hug1", player)
    menu:addSlice(getText("IGUI_TTRP_MakeoutA"), getTexture("media/ui/poses/standing/kiss1.png"), doEmote, "TTRP_Makeout1", player)
    menu:addSlice(getText("IGUI_TTRP_MakeoutB"), getTexture("media/ui/poses/standing/kiss1.png"), doEmote, "TTRP_Makeout2", player)
    menu:addSlice(getText("IGUI_TTRP_ArmAroundOtherLeft"), getTexture("media/ui/poses/standing/standing-arm-left.png"), doEmote, "TTRP_Arm-Around-Other1", player)
    menu:addSlice(getText("IGUI_TTRP_ArmAroundOtherRight"), getTexture("media/ui/poses/standing/standing-arm-right.png"), doEmote, "TTRP_Arm-Around-Other2", player)
    menu:addSlice(getText("IGUI_TTRP_ArmAroundTwo"), getTexture("media/ui/poses/standing/arm-two.png"), doEmote, "TTRP_Arm-Around-Two", player)
    menu:addSlice(getText("IGUI_TTRP_GirlyArmLeft"), getTexture("media/ui/poses/standing/girly-left.png"), doEmote, "TTRP_GirlyArm", player)
    menu:addSlice(getText("IGUI_TTRP_GirlyArmRight"), getTexture("media/ui/poses/standing/girly-right.png"), doEmote, "TTRP_GirlyArm2", player)
    menu:addSlice(getText("IGUI_TTRP_Holding"), getTexture("media/ui/poses/standing/holding.png"), doEmote, "TTRP_Holding", player)
    menu:addSlice(getText("IGUI_TTRP_Kabedon"), getTexture("media/ui/poses/standing/kabedon.png"), doEmote, "TTRP_Kabedon", player)
    menu:addSlice(getText("IGUI_TTRP_HandsOnChest"), getTexture("media/ui/poses/standing/hand-chest.png"), doEmote, "TTRP_Hands-on-Others-Chest", player)
    menu:addSlice(getText("IGUI_TTRP_HoldHips"), getTexture("media/ui/poses/standing/hand-hips.png"), doEmote, "TTRP_HoldHips", player)
end

function subStandingInjured(menu, player)
    menu:addSlice(getText("IGUI_TTRP_LimpLeg"), getTexture("media/ui/poses/standing/injuredlimp.png"), doEmote, "TTRP_LimpLeg", player)
    menu:addSlice(getText("IGUI_TTRP_InjuredWalk1"), getTexture("media/ui/poses/standing/injuredwalk1.png"), doEmote, "TTRP_InjuredWalk1", player)
    menu:addSlice(getText("IGUI_TTRP_InjuredWalk2"), getTexture("media/ui/poses/standing/injuredwalk2.png"), doEmote, "TTRP_InjuredWalk2", player)
end

------------------
-- SITTING MENU --
------------------

function subTTRPSit(menu, player)
    -- Sitting Main Menu
    menu:addSlice(getText("IGUI_TTRP_SitGround"), getTexture("media/ui/menus/ground_icon.png"), ISRadialMenu.createSubMenu, menu, subSittingGround, player)
    menu:addSlice(getText("IGUI_TTRP_SitGround2"), getTexture("media/ui/menus/GROUND_ICON_2.png"), ISRadialMenu.createSubMenu, menu, subSittingGround2, player)
    menu:addSlice(getText("IGUI_TTRP_SitFurniture1"), getTexture("media/ui/menus/furniture_icon.png"), ISRadialMenu.createSubMenu, menu, subSittingObject, player)
    menu:addSlice(getText("IGUI_TTRP_SitFurniture2"), getTexture("media/ui/menus/furniture_icon-2.png"), ISRadialMenu.createSubMenu, menu, subSittingObject2, player)
    menu:addSlice(getText("IGUI_TTRP_SitFurniture3"), getTexture("media/ui/menus/furniture_icon-3.png"), ISRadialMenu.createSubMenu, menu, subSittingObject3, player)
    menu:addSlice(getText("IGUI_TTRP_PairedSitGround"), getTexture("media/ui/menus/sit-paired-ground.png"), ISRadialMenu.createSubMenu, menu, subSittingGroundPaired, player)
    menu:addSlice(getText("IGUI_TTRP_PairedSitFurniture"), getTexture("media/ui/menus/sit-paired-furn.png"), ISRadialMenu.createSubMenu, menu, subSittingObjectPaired, player)
    menu:addSlice(getText("IGUI_TTRP_SittingInjured"), getTexture("media/ui/menus/sit-injured.png"), ISRadialMenu.createSubMenu, menu, subSittingInjured, player)
end

function subSittingGround(menu, player)
    -- Sitting On Ground Menu
    menu:addSlice(getText("IGUI_TTRP_SitHandTap"), getTexture("media/ui/poses/sitting/hand-tap.png"), doEmote, "TTRP_SitHandTap", player)
    menu:addSlice(getText("IGUI_TTRP_SitArmsKnee"), getTexture("media/ui/poses/sitting/arms-knee.png"), doEmote, "TTRP_HandsOnKnee", player)
    menu:addSlice(getText("IGUI_TTRP_GirlyPopSitGround"), getTexture("media/ui/poses/sitting/girlypop-sit.png"), doEmote, "TTRP_GirlyPopSit", player)
    menu:addSlice(getText("IGUI_TTRP_SitHandsBound"), getTexture("media/ui/poses/sitting/hands-cuffed.png"), doEmote, "TTRP_HandsBoundKneel", player)
    menu:addSlice(getText("IGUI_TTRP_SitSurrender"), getTexture("media/ui/poses/sitting/surrender.png"), doEmote, "TTRP_KneelSurrender", player)
    menu:addSlice(getText("IGUI_TTRP_SitSway"), getTexture("media/ui/poses/sitting/sway-sit.png"), doEmote, "TTRP_SitSway", player)
    menu:addSlice(getText("IGUI_TTRP_SitElbowKnee"), getTexture("media/ui/poses/sitting/elbowonknee.png"), doEmote, "TTRP_ElbowOnKnee", player)
    menu:addSlice(getText("IGUI_TTRP_SitChinHands"), getTexture("media/ui/poses/sitting/chin-in-hand.png"), doEmote, "TTRP_SitWithChinInHands", player)
    menu:addSlice(getText("IGUI_TTRP_SitArmsKnees"), getTexture("media/ui/poses/sitting/arms-over-knee.png"), doEmote, "TTRP_SittingArmsOverKnee", player)
    menu:addSlice(getText("IGUI_TTRP_SitForearmsThighs"), getTexture("media/ui/poses/sitting/fore-arms-thighs.png"), doEmote, "TTRP_Forearms-Thighs", player)
    menu:addSlice(getText("IGUI_TTRP_KneelHandWall"), getTexture("media/ui/poses/sitting/hand-on-wall.png"), doEmote, "TTRP_KneelHandOnWall", player)
    menu:addSlice(getText("IGUI_TTRP_KneelPrayer"), getTexture("media/ui/poses/sitting/praying.png"), doEmote, "TTRP_SitPrayer", player)
    menu:addSlice(getText("IGUI_TTRP_KneelHandOverHand"), getTexture("media/ui/poses/sitting/kneel-crossed-hands.png"), doEmote, "TTRP_KneelingCrossedHand", player)
    menu:addSlice(getText("IGUI_TTRP_KneelCrossedArms"), getTexture("media/ui/poses/sitting/kneel-crossed-arms.png"), doEmote, "TTRP_KneelingCrossedArms", player)
end

function subSittingGround2(menu, player)
    -- Sitting On Ground Menu 2
    menu:addSlice(getText("IGUI_TTRP_WrappedKneesGround"), getTexture("media/ui/poses/sitting/wrapped-knees-ground.png"), doEmote, "TTRP_WrappedKneesGround", player)
    menu:addSlice(getText("IGUI_TTRP_DeepSquat"), getTexture("media/ui/poses/sitting/deepsquat.png"), doEmote, "TTRP_DeepSquat", player)
    menu:addSlice(getText("IGUI_TTRP_GoblinSitGround"), getTexture("media/ui/poses/sitting/goblin.png"), doEmote, "TTRP_GoblinSitGround", player)
end

function subSittingObject(menu, player)
    -- Sitting on an Object Menu
    menu:addSlice(getText("IGUI_TTRP_ChairHeadInHands"), getTexture("media/ui/poses/sitting/head-in-hands.png"), doEmote, "TTRP_HeadInHandsSit", player)
    menu:addSlice(getText("IGUI_TTRP_ChairHandsThighs"), getTexture("media/ui/poses/sitting/deep-squat.png"), doEmote, "TTRP_Hands_On_Thighs", player)
    menu:addSlice(getText("IGUI_TTRP_ChairForearmsThighs"), getTexture("media/ui/poses/sitting/arms-thighs.png"), doEmote, "TTRP_Sitting_ForearmsThighs", player)
    menu:addSlice(getText("IGUI_TTRP_ChairHandsHead"), getTexture("media/ui/poses/sitting/cantdothisnomore.png"), doEmote, "TTRP_Sitting_Hands-Head", player)
    menu:addSlice(getText("IGUI_TTRP_LazyBoy"), getTexture("media/ui/poses/sitting/lazy-boy.png"), doEmote, "TTRP_LazyBoy", player)
    menu:addSlice(getText("IGUI_TTRP_Manspread"), getTexture("media/ui/poses/sitting/manspread.png"), doEmote, "TTRP_MANSPREAD", player)
    menu:addSlice(getText("IGUI_TTRP_ManspreadArmsFolded"), getTexture("media/ui/poses/sitting/armsfoldedmanspread.png"), doEmote, "TTRP_ManspreadCrossedArms", player)
    menu:addSlice(getText("IGUI_TTRP_SassySit"), getTexture("media/ui/poses/sitting/sassy-sit.png"), doEmote, "TTRP_SassySit", player)
    menu:addSlice(getText("IGUI_TTRP_LegsCrossedChair"), getTexture("media/ui/poses/sitting/legs-crossed.png"), doEmote, "TTRP_SitInChairLegsCrossed", player)
    menu:addSlice(getText("IGUI_TTRP_ChairChinInHand"), getTexture("media/ui/poses/sitting/chair-chin-in-hand.png"), doEmote, "TTRP_SitWithChinInHand-Chair", player)
    menu:addSlice(getText("IGUI_TTRP_ChairOneLegUp"), getTexture("media/ui/poses/sitting/one-leg-up.png"), doEmote, "TTRP_SitInChairOneLegUp", player)
    menu:addSlice(getText("IGUI_TTRP_ChairHandsFolded"), getTexture("media/ui/poses/sitting/satrmscross.png"), doEmote, "TTRP_SitHandsFolded", player)
    menu:addSlice(getText("IGUI_TTRP_LegsKickedUp"), getTexture("media/ui/poses/sitting/legskickedup.png"), doEmote, "TTRP_Sit-Legs-Kicked-Up", player)
    menu:addSlice(getText("IGUI_TTRP_CrossChair"), getTexture("media/ui/poses/sitting/sit-cross-chair.png"), doEmote, "TTRP_Sit-Cross-Chair", player)
    menu:addSlice(getText("IGUI_TTRP_SunbathingBeachChair"), getTexture("media/ui/poses/sitting/suntanning2.png"), doEmote, "TTRP_Suntanning2", player)
    menu:addSlice(getText("IGUI_TTRP_GirlypopArmsLegs"), getTexture("media/ui/poses/sitting/girlypop-kneesup.png"), doEmote, "TTRP_Girlypop-Chair-Sit", player)
end

function subSittingObject2(menu, player)
    -- Sitting on an Object Menu pt 2
    menu:addSlice(getText("IGUI_TTRP_ChairHandArmThigh"), getTexture("media/ui/poses/sitting/laxarmsit.png"), doEmote, "TTRP_HandThighArmThigh", player)
    menu:addSlice(getText("IGUI_TTRP_ThaneSit"), getTexture("media/ui/poses/sitting/Thane.png"), doEmote, "TTRP_ThaneSit", player)
    menu:addSlice(getText("IGUI_TTRP_JarlBallin"), getTexture("media/ui/poses/sitting/JARLIN.png"), doEmote, "TTRP_JARL", player)
    menu:addSlice(getText("IGUI_TTRP_JarlBallinTwoArms"), getTexture("media/ui/poses/sitting/JARLIN.png"), doEmote, "TTRP_JARL_ARMS_DOWN", player)
    menu:addSlice(getText("IGUI_TTRP_ChairHandsOnChair"), getTexture("media/ui/poses/sitting/Handchair.png"), doEmote, "TTRP_Sit-Hands-On-Chair", player)
    menu:addSlice(getText("IGUI_TTRP_ChaiseLounge"), getTexture("media/ui/poses/sitting/chaise-lounge.png"), doEmote, "TTRP_ChaiseLounge", player)
    menu:addSlice(getText("IGUI_TTRP_ChaiseLoungeReversed"), getTexture("media/ui/poses/sitting/chaise-reversed.png"), doEmote, "TTRP_ChaiseLoungeReversed", player)
    menu:addSlice(getText("IGUI_TTRP_OneLegUpOneDown"), getTexture("media/ui/poses/sitting/1up1down.png"), doEmote, "TTRP_One-leg-up-one-down", player)
    menu:addSlice(getText("IGUI_TTRP_OneLegUpOneDownReversed"), getTexture("media/ui/poses/sitting/1up1downreversed.png"), doEmote, "TTRP_One-Leg-Up-One-Down-Reversed", player)
    menu:addSlice(getText("IGUI_TTRP_LegsCrossed"), getTexture("media/ui/poses/sitting/CrossedLegs.png"), doEmote, "TTRP_LegsCrossedChair", player)
    menu:addSlice(getText("IGUI_TTRP_GoblinSit"), getTexture("media/ui/poses/sitting/goblin.png"), doEmote, "TTRP_GoblinSit", player)
    menu:addSlice(getText("IGUI_TTRP_SitChairArmsAroundSelf"), getTexture("media/ui/poses/sitting/sitarmschair.png"), doEmote, "TTRP_SitChairArmsAroundSelf", player)
    menu:addSlice(getText("IGUI_TTRP_HandsBehindHeadChair"), getTexture("media/ui/poses/sitting/handsbehindhead.png"), doEmote, "TTRP_HandsBehindHeadChair", player)
end

function subSittingObject3(menu, player)
    menu:addSlice(getText("IGUI_TTRP_CrossedLegs_Sassy"), getTexture("media/ui/poses/sitting/crosslegssassy.png"), doEmote, "TTRP_CrossedLegs_Sassy", player)
    menu:addSlice(getText("IGUI_TTRP_CrossedLegs_Leaned"), getTexture("media/ui/poses/sitting/crosslegsleaned.png"), doEmote, "TTRP_CrossedLegs_Leaned", player)
    menu:addSlice(getText("IGUI_TTRP_CrossedLegs_InLap"), getTexture("media/ui/poses/sitting/crosslegsinlap.png"), doEmote, "TTRP_CrossedLegs_InLap", player)
end

function subSittingObjectPaired(menu, player)
    menu:addSlice(getText("IGUI_TTRP_SittingBeside"), getTexture("media/ui/poses/sitting/lean-against.png"), doEmote, "TTRP_SittingNextTo", player)
    menu:addSlice(getText("IGUI_TTRP_SitHandThighRight"), getTexture("media/ui/poses/sitting/sit-hand-right.png"), doEmote, "TTRP_SitBesideHandThighRight", player)
    menu:addSlice(getText("IGUI_TTRP_SitHandThighLeft"), getTexture("media/ui/poses/sitting/sit-hand-left.png"), doEmote, "TTRP_SitBesideHandThighLeft", player)
    menu:addSlice(getText("IGUI_TTRP_SitArmAroundRight"), getTexture("media/ui/poses/sitting/sit-around-right.png"), doEmote, "TTRP_Sit-Arm-Around-Right", player)
    menu:addSlice(getText("IGUI_TTRP_SitArmAroundLeft"), getTexture("media/ui/poses/sitting/sit-around-left.png"), doEmote, "TTRP_Sit-Arm-Around-Left", player)
end

function subSittingGroundPaired(menu, player)
    menu:addSlice(getText("IGUI_TTRP_SitBesideGround"), getTexture("media/ui/poses/sitting/sittingbeside.png"), doEmote, "TTRP_SittingNextToGround", player)
    menu:addSlice(getText("IGUI_TTRP_SitLegsSpread"), getTexture("media/ui/poses/sitting/legsspread.png"), doEmote, "TTRP_Sit-on-Ground-Legs-Spread", player)
    menu:addSlice(getText("IGUI_TTRP_SitBetweenLegs"), getTexture("media/ui/poses/sitting/sitbetween.png"), doEmote, "TTRP_Sit-Between-legs", player)
    menu:addSlice(getText("IGUI_TTRP_SitArmAroundLeft"), getTexture("media/ui/poses/sitting/arm-around-left.png"), doEmote, "TTRP_Sitting-Arm-Around", player)
    menu:addSlice(getText("IGUI_TTRP_SitArmAroundRight"), getTexture("media/ui/poses/sitting/arm-around-right.png"), doEmote, "TTRP_Sitting-Arm-Around2", player)
    menu:addSlice(getText("IGUI_TTRP_HeadInLap"), getTexture("media/ui/poses/sitting/stroke-head.png"), doEmote, "TTRP_Head-In-Lap", player)
end

function subSittingInjured(menu, player)
    menu:addSlice(getText("IGUI_TTRP_Sitting_InjuredArmTucked"), getTexture("media/ui/poses/sitting/SittingInjuredArmTucked.png"), doEmote, "TTRP_Sitting_InjuredArmTucked", player)
    menu:addSlice(getText("IGUI_TTRP_Sitting_InjuredArm"), getTexture("media/ui/poses/sitting/SittingInjuredArm.png"), doEmote, "TTRP_Sitting_InjuredArm", player)
end



---------------------
-- LYING DOWN MENU --
---------------------
function subTTRPLying(menu, player)
    menu:addSlice(getText("IGUI_TTRP_LyingGround"), getTexture("media/ui/menus/lying-ground.png"), ISRadialMenu.createSubMenu, menu, subTTRPLyingFloor, player)
    menu:addSlice(getText("IGUI_TTRP_LyingFurniture"), getTexture("media/ui/menus/lying-furn.png"), ISRadialMenu.createSubMenu, menu, subTTRPLyingFurniture, player)
    menu:addSlice(getText("IGUI_TTRP_PairedLying"), getTexture("media/ui/menus/lying-paired-ground.png"), ISRadialMenu.createSubMenu, menu, subLyingPairedGround, player)
    menu:addSlice(getText("IGUI_TTRP_PairedLyingFurniture"), getTexture("media/ui/menus/lying-paired-furn.png"), ISRadialMenu.createSubMenu, menu, subLyingPairedFurniture, player)
    menu:addSlice(getText("IGUI_TTRP_LyingInjured"), getTexture("media/ui/menus/lying-injured.png"), ISRadialMenu.createSubMenu, menu, subLyingInjured, player)
end


function subTTRPLyingFloor(menu, player)
    menu:addSlice(getText("IGUI_TTRP_DownAndOut"), getTexture("media/ui/poses/laying/injured1.png"), doEmote, "TTRP_DownAndOut", player)
    menu:addSlice(getText("IGUI_TTRP_LyingInjured2"), getTexture("media/ui/poses/laying/injured2.png"), doEmote, "TTRP_LyingInjured2", player)
    menu:addSlice(getText("IGUI_TTRP_Cloudspotting"), getTexture("media/ui/poses/laying/cloudwatching.png"), doEmote, "TTRP_Cloudspotting", player)
    menu:addSlice(getText("IGUI_TTRP_Lie_Flutter_Kick"), getTexture("media/ui/poses/laying/flutter-kick.png"), doEmote, "TTRP_Lie_Flutter_Kick", player)
    menu:addSlice(getText("IGUI_TTRP_FeetOnSofa"), getTexture("media/ui/poses/laying/legs-on-chair.png"), doEmote, "TTRP_FeetOnSofa", player)
    menu:addSlice(getText("IGUI_TTRP_FetalPosition"), getTexture("media/ui/poses/laying/fetal.png"), doEmote, "TTRP_FetalPosition", player)
    menu:addSlice(getText("IGUI_TTRP_Faceplant"), getTexture("media/ui/poses/laying/faceplant.png"), doEmote, "TTRP_Faceplant", player)
    menu:addSlice(getText("IGUI_TTRP_LayStomach1"), getTexture("media/ui/poses/laying/layingstomach.png"), doEmote, "TTRP_LayStomach1", player)
    menu:addSlice(getText("IGUI_TTRP_FrenchBoy"), getTexture("media/ui/poses/laying/french_boi.png"), doEmote, "TTRP_FrenchBoy", player)
    menu:addSlice(getText("IGUI_TTRP_FrenchBoyReversed"), getTexture("media/ui/poses/laying/french_boi.png"), doEmote, "TTRP_FrenchBoyReversed", player)
    menu:addSlice(getText("IGUI_TTRP_FrenchGirl"), getTexture("media/ui/poses/laying/french_goil.png"), doEmote, "TTRP_FrenchGirl", player)
    menu:addSlice(getText("IGUI_TTRP_FrenchGirlReversed"), getTexture("media/ui/poses/laying/french_goil.png"), doEmote, "TTRP_FrenchGirlReversed", player)
    menu:addSlice(getText("IGUI_TTRP_Lying_Asleep"), getTexture("media/ui/poses/laying/sleeping1.png"), doEmote, "TTRP_Lying-Asleep", player)
    menu:addSlice(getText("IGUI_TTRP_Lying_Asleep_Reversed"), getTexture("media/ui/poses/laying/sleeping1.png"), doEmote, "TTRP_Lying-Asleep-Reversed", player)
    menu:addSlice(getText("IGUI_TTRP_Lying_Sleeping2"), getTexture("media/ui/poses/laying/sleeping2.png"), doEmote, "TTRP_Lying-Sleeping2", player)
    menu:addSlice(getText("IGUI_TTRP_Suntanning"), getTexture("media/ui/poses/laying/suntanning.png"), doEmote, "TTRP_Suntanning", player)
    menu:addSlice(getText("IGUI_TTRP_LYING_ELBOWS"), getTexture("media/ui/poses/laying/elbows.png"), doEmote, "TTRP_LYING_ELBOWS", player)
 end
 
 function subTTRPLyingFurniture(menu, player)
     menu:addSlice(getText("IGUI_TTRP_FetalFurniture"), getTexture("media/ui/poses/laying/fetal.png"), doEmote, "TTRP_FetalFurniture", player)
     menu:addSlice(getText("IGUI_TTRP_StomachLayBed"), getTexture("media/ui/poses/laying/layingstomach.png"), doEmote, "TTRP_StomachLayBed", player)
     menu:addSlice(getText("IGUI_TTRP_LegFlutterFurniture"), getTexture("media/ui/poses/laying/flutter-kick.png"), doEmote, "TTRP_LegFlutterFurniture", player)
     menu:addSlice(getText("IGUI_TTRP_FrenchBoy_Bed"), getTexture("media/ui/poses/laying/french_boi.png"), doEmote, "TTRP_FrenchBoy_Bed", player)
     menu:addSlice(getText("IGUI_TTRP_FrenchBoy_BedReversed"), getTexture("media/ui/poses/laying/french_boi.png"), doEmote, "TTRP_FrenchBoy_BedReversed", player)
     menu:addSlice(getText("IGUI_TTRP_FrenchGirl_Bed"), getTexture("media/ui/poses/laying/french_goil.png"), doEmote, "TTRP_FrenchGirl_Bed", player)
     menu:addSlice(getText("IGUI_TTRP_FrenchGirl_BedReversed"), getTexture("media/ui/poses/laying/french_goil.png"), doEmote, "TTRP_FrenchGirl_BedReversed", player)
     menu:addSlice(getText("IGUI_TTRP_Lying_AsleepFurniture"), getTexture("media/ui/poses/laying/sleeping1.png"), doEmote, "TTRP_Lying-AsleepFurniture", player)
     menu:addSlice(getText("IGUI_TTRP_Lying_Asleep_ReversedFurniture"), getTexture("media/ui/poses/laying/sleeping1.png"), doEmote, "TTRP_Lying-Asleep-ReversedFurniture", player)
     menu:addSlice(getText("IGUI_TTRP_Lying_Sleeping2Furniture"), getTexture("media/ui/poses/laying/sleeping2.png"), doEmote, "TTRP_Lying-Sleeping2Furniture", player)
     menu:addSlice(getText("IGUI_TTRP_LYING_ELBOWS_BED"), getTexture("media/ui/poses/laying/elbows.png"), doEmote, "TTRP_LYING_ELBOWS_BED", player)
 end
 
 function subLyingPairedGround(menu, player)
     menu:addSlice(getText("IGUI_TTRP_Cuddle1"), getTexture("media/ui/poses/laying/cuddle-reverse.png"), doEmote, "TTRP_Cuddle1", player)
     menu:addSlice(getText("IGUI_TTRP_Cuddle_Reversed"), getTexture("media/ui/poses/laying/cuddle-reverse.png"), doEmote, "TTRP_Cuddle-Reversed", player)
     menu:addSlice(getText("IGUI_TTRP_Laying_Head_In_Lap"), getTexture("media/ui/poses/laying/head-lap.png"), doEmote, "TTRP_Laying-Head-In-Lap", player)
 end
 
 function subLyingPairedFurniture(menu, player)
     menu:addSlice(getText("IGUI_TTRP_Cuddle1_Offset"), getTexture("media/ui/poses/laying/cuddle-reverse.png"), doEmote, "TTRP_Cuddle1-Offset", player)
     menu:addSlice(getText("IGUI_TTRP_Cuddle_Reversed_Offset"), getTexture("media/ui/poses/laying/cuddle-reverse.png"), doEmote, "TTRP_Cuddle-Reversed-Offset", player)
 end

  function subLyingInjured(menu, player)
     menu:addSlice(getText("IGUI_TTRP_LieAgainstWallInjured"), getTexture("media/ui/poses/laying/LieAgainstWall.png"), doEmote, "TTRP_LieAgainstWallInjured", player)
     menu:addSlice(getText("IGUI_TTRP_LieAgainstWallInjured2"), getTexture("media/ui/poses/laying/LieAgainstWall2.png"), doEmote, "TTRP_LieAgainstWallInjured2", player)
     menu:addSlice(getText("IGUI_TTRP_Injured_LyingClutchStomach"), getTexture("media/ui/poses/laying/LyingClutchStomach.png"), doEmote, "TTRP_Injured_LyingClutchStomach", player)
     menu:addSlice(getText("IGUI_TTRP_Lying_Raptured"), getTexture("media/ui/poses/laying/Lyingraptured.png"), doEmote, "TTRP_Lying_Raptured", player)
     menu:addSlice(getText("IGUI_TTRP_Lying_LimpClutchTummy"), getTexture("media/ui/poses/laying/LyingLimpClutchStomach.png"), doEmote, "TTRP_Lying_LimpClutchTummy", player)
     menu:addSlice(getText("IGUI_TTRP_BladeRunner"), getTexture("media/ui/poses/laying/BladeRunner.png"), doEmote, "TTRP_BladeRunner", player)
     menu:addSlice(getText("IGUI_TTRP_MentalBreak"), getTexture("media/ui/poses/laying/mentalbreak.png"), doEmote, "TTRP_MentalBreak", player)
     menu:addSlice(getText("IGUI_TTRP_Crawling"), getTexture("media/ui/poses/laying/Crawling.png"), doEmote, "TTRP_Crawling", player)
     menu:addSlice(getText("IGUI_TTRP_InjuredCrawl"), getTexture("media/ui/poses/laying/InjuredCrawling.png"), doEmote, "TTRP_InjuredCrawl", player)
     menu:addSlice(getText("IGUI_TTRP_PanickedScramble"), getTexture("media/ui/poses/laying/PanickedCrawl.png"), doEmote, "TTRP_PanickedScramble", player)
 end
----------------
-- PROPS MENU --
----------------
function subTTRPprops(menu, player)
    menu:addSlice(getText("IGUI_TTRP_LongRifles"), getTexture("media/ui/menus/rifle-icon.png"), ISRadialMenu.createSubMenu, menu, subLongRifles, player)
    menu:addSlice(getText("IGUI_TTRP_SittingLongRifles"), getTexture("media/ui/menus/rifle-icon2.png"), ISRadialMenu.createSubMenu, menu, subSittingLongRifle, player)
    menu:addSlice(getText("IGUI_TTRP_Pistols"), getTexture("media/ui/menus/pistols-icon.png"), ISRadialMenu.createSubMenu, menu, subPistols, player)
    menu:addSlice(getText("IGUI_TTRP_LongWeapons"), getTexture("media/ui/menus/melee-icon.png"), ISRadialMenu.createSubMenu, menu, subLongWeapons, player)
    menu:addSlice(getText("IGUI_TTRP_InjuredProps"), getTexture("media/ui/menus/InjuredProps.png"), ISRadialMenu.createSubMenu, menu, subInjuredProps, player)
    menu:addSlice(getText("IGUI_TTRP_Instruments"), getTexture("media/ui/menus/instruments.png"), ISRadialMenu.createSubMenu, menu, subInstruments, player)
end

function subLongRifles(menu, player)
    menu:addSlice(getText("IGUI_TTRP_HoldRifleSteady"), getTexture("media/ui/poses/props/aimrifle.png"), doEmote, "TTRP_HoldRifleSteady", player)
    menu:addSlice(getText("IGUI_TTRP_HoldRifle"), getTexture("media/ui/poses/props/rifleidle.png"), doEmote, "TTRP_HoldRifle", player)
    menu:addSlice(getText("IGUI_TTRP_HoldRifleArmpit"), getTexture("media/ui/poses/props/riflearmpit.png"), doEmote, "TTRP_HoldRifleUnderArmpit", player)
    menu:addSlice(getText("IGUI_TTRP_HoldAtGunpointRifle"), getTexture("media/ui/poses/props/rifle-gunpoint.png"), doEmote, "TTRP_HoldAtGunpointRifle", player)
    menu:addSlice(getText("IGUI_TTRP_HoldRifleAtHip"), getTexture("media/ui/poses/props/riflehip.png"), doEmote, "TTRP_HoldRifleAtHip", player)
    menu:addSlice(getText("IGUI_TTRP_Holding_Rifle_Idle_2"), getTexture("media/ui/poses/props/rifle-idle.png"), doEmote, "TTRP_Holding_Rifle_Idle_2", player)
    menu:addSlice(getText("IGUI_TTRP_Rifle_One_Hand_Up"), getTexture("media/ui/poses/props/rifle-idle-3.png"), doEmote, "TTRP_Rifle-One-Hand-Up", player)
    menu:addSlice(getText("IGUI_TTRP_HoldRifleHip"), getTexture("media/ui/poses/props/riflehip.png"), doEmote, "TTRP_HoldRifleToHip", player)
    menu:addSlice(getText("IGUI_TTRP_HoldRifleKneel"), getTexture("media/ui/poses/props/kneelshoot.png"), doEmote, "TTRP_HoldRifleKneel", player)
    menu:addSlice(getText("IGUI_TTRP_HoldRifleIdleKneel"), getTexture("media/ui/poses/props/kneelidle.png"), doEmote, "TTRP_HoldRifleIdleKneel", player)
    menu:addSlice(getText("IGUI_TTRP_HoldRifleUp"), getTexture("media/ui/poses/props/holdrifleup.png"), doEmote, "TTRP_HoldRifleUp", player)
    menu:addSlice(getText("IGUI_TTRP_HoldWeaponOnShoulder"), getTexture("media/ui/poses/props/holdriflshoulder.png"), doEmote, "TTRP_HoldWeaponOnShoulder", player)
end

function subSittingLongRifle(menu, player)
    menu:addSlice(getText("IGUI_TTRP_RifleOverLap"), getTexture("media/ui/poses/props/rifle-lap.png"), doEmote, "TTRP_RifleOverLap", player)
    menu:addSlice(getText("IGUI_TTRP_SittingHipRifle"), getTexture("media/ui/poses/props/sit-rifle-hip.png"), doEmote, "TTRP_SittingHipRifle", player)
    menu:addSlice(getText("IGUI_TTRP_SittingRifleBetweenLegs"), getTexture("media/ui/poses/props/rifle-legs.png"), doEmote, "TTRP_SittingRifleBetweenLegs", player)
end

function subLongWeapons(menu, player)
    menu:addSlice(getText("IGUI_TTRP_BatPat"), getTexture("media/ui/poses/props/batpat.png"), doEmote, "TTRP_BatPat", player)
    menu:addSlice(getText("IGUI_TTRP_HoldBehindHead"), getTexture("media/ui/poses/props/weaponbehindhead.png"), doEmote, "TTRP_HoldBehindHead", player)
    menu:addSlice(getText("IGUI_TTRP_Weapon_Shoulder"), getTexture("media/ui/poses/props/weaponshoulder.png"), doEmote, "TTRP_Weapon-Shoulder", player)
    menu:addSlice(getText("IGUI_TTRP_SwordStance1"), getTexture("media/ui/poses/props/swordready.png"), doEmote, "TTRP_SwordStance1", player)
    menu:addSlice(getText("IGUI_TTRP_SwordStance2"), getTexture("media/ui/poses/props/swordready2.png"), doEmote, "TTRP_SwordStance2", player)
    menu:addSlice(getText("IGUI_TTRP_Katana-Stance-1"), getTexture("media/ui/poses/props/katanastance1.png"), doEmote, "TTRP_Katana-Stance-1", player)
    menu:addSlice(getText("IGUI_TTRP_Katana-Stance-2"), getTexture("media/ui/poses/props/katanastance2.png"), doEmote, "TTRP_Katana-Stance-2", player)
    menu:addSlice(getText("IGUI_TTRP_HoldAtSpearpoint"), getTexture("media/ui/poses/props/whyareyoureadingthis.png"), doEmote, "TTRP_HoldAtSpearpoint", player)
    menu:addSlice(getText("IGUI_TTRP_HoldSpear"), getTexture("media/ui/poses/props/holdspear.png"), doEmote, "TTRP_HoldingSpear", player)
    menu:addSlice(getText("IGUI_TTRP_HoldSpearAnime"), getTexture("media/ui/poses/props/holdspearanime.png"), doEmote, "TTRP_HoldSpearAnime", player)
    menu:addSlice(getText("IGUI_TTRP_LeanOnSpear"), getTexture("media/ui/poses/props/holdspearlean.png"), doEmote, "TTRP_LeanOnSpear", player)
    menu:addSlice(getText("IGUI_TTRP_LeanOnSpearStanding"), getTexture("media/ui/poses/props/holdspearleanstanding.png"), doEmote, "TTRP_LeanOnSpearStanding", player)
end

function subPistols(menu, player)
    menu:addSlice(getText("IGUI_TTRP_HoldPistol"), getTexture("media/ui/poses/props/pistolsteady.png"), doEmote, "TTRP_HoldPistol", player)
    menu:addSlice(getText("IGUI_TTRP_HoldPistolLowReady"), getTexture("media/ui/poses/props/pistollow.png"), doEmote, "TTRP_HoldPistolLowReady", player)
    menu:addSlice(getText("IGUI_TTRP_HighReady"), getTexture("media/ui/poses/props/pistolhigh.png"), doEmote, "TTRP_HighReady", player)
    menu:addSlice(getText("IGUI_TTRP_FanRevolver"), getTexture("media/ui/poses/props/revolverfanning.png"), doEmote, "TTRP_FanRevolver", player)
    menu:addSlice(getText("IGUI_TTRP_PistolHipDrawn"), getTexture("media/ui/poses/props/pistolhip.png"), doEmote, "TTRP_PistolHipDrawn", player)
    menu:addSlice(getText("IGUI_TTRP_GunslingerReady"), getTexture("media/ui/poses/props/drawholster.png"), doEmote, "TTRP_GunslingerReady", player)
    menu:addSlice(getText("IGUI_TTRP_Pistol_Held_Upwards"), getTexture("media/ui/poses/props/hold-pistol-up.png"), doEmote, "TTRP_Pistol-Held-Upwards", player)
    menu:addSlice(getText("IGUI_TTRP_HeldAtGunpoint"), getTexture("media/ui/poses/props/gunoint1.png"), doEmote, "TTRP_HeldAtGunpoint", player)
    menu:addSlice(getText("IGUI_TTRP_HeldAtGunpointOlympic"), getTexture("media/ui/poses/props/olympic.png"), doEmote, "TTRP_HeldAtGunpointOlympic", player)
    menu:addSlice(getText("IGUI_TTRP_Clean_Pistol"), getTexture("media/ui/poses/props/cleangun.png"), doEmote, "TTRP_Clean_Pistol", player)
end

function subInjuredProps(menu, player)
    menu:addSlice(getText("IGUI_TTRP_LongWeaponInjured"), getTexture("media/ui/poses/props/injuredgun1.png"), doEmote, "TTRP_LongWeaponInjured", player)
end

function subInstruments(menu, player)
    menu:addSlice(getText("IGUI_TTRP_Strumming"), getTexture("media/ui/poses/props/strumming.png"), doEmote, "BttB_strumming", player)
    menu:addSlice(getText("IGUI_TTRP_SaxPlaying"), getTexture("media/ui/poses/props/saxplaying.png"), doEmote, "BttB_SaxPlaying1", player)
    menu:addSlice(getText("IGUI_TTRP_Keytar"), getTexture("media/ui/poses/props/keytar.png"), doEmote, "BttB_Keytar", player)
    menu:addSlice(getText("IGUI_TTRP_Flute"), getTexture("media/ui/poses/props/flute.png"), doEmote, "BttB_Flute", player)
    menu:addSlice(getText("IGUI_TTRP_Violin"), getTexture("media/ui/poses/props/violin.png"), doEmote, "BttB_Violin", player)
    --menu:addSlice(getText("IGUI_TTRP_AirDrumming"), getTexture("media/ui/poses/props/drumming.png"), doEmote, "TTRP_AirDrummingWalk", player)
end
-----------------
-- EMOTES MENU --
-----------------

function subTTRPemotes(menu, player)
    menu:addSlice(getText("IGUI_TTRP_EmoteSnortPixie"), getTexture("media/ui/poses/emotes/cocainum.png"), doEmote, "TTRP_PixieSticks", player)
    menu:addSlice(getText("IGUI_TTRP_EmoteAccuse"), getTexture("media/ui/poses/emotes/accuser.png"), doEmote, "TTRP_Accost", player)
    menu:addSlice(getText("IGUI_TTRP_EmoteUpYours"), getTexture("media/ui/poses/emotes/up-yours.png"), doEmote, "TTRP_UpYours", player)
    menu:addSlice(getText("IGUI_TTRP_EmoteUpYoursCasual"), getTexture("media/ui/poses/emotes/up-yours-casual.png"), doEmote, "TTRP_UpYoursCasual", player)
    menu:addSlice(getText("IGUI_TTRP_EmoteBigWave"), getTexture("media/ui/poses/emotes/big-wave.png"), doEmote, "TTRP_BigWave", player)
    menu:addSlice(getText("IGUI_TTRP_EmoteThink"), getTexture("media/ui/poses/emotes/thinking.png"), doEmote, "TTRP_Think", player)
    menu:addSlice(getText("IGUI_TTRP_EmoteRudeGesture"), getTexture("media/ui/poses/emotes/rude-jerk.png"), doEmote, "TTRP_JackRude", player)
    menu:addSlice(getText("IGUI_TTRP_EmotePanic"), getTexture("media/ui/poses/emotes/freaking-out.png"), doEmote, "TTRP_Panic", player)
    menu:addSlice(getText("IGUI_TTRP_EmoteSigh"), getTexture("media/ui/poses/emotes/big-sigh.png"), doEmote, "TTRP_Sighing", player)
    menu:addSlice(getText("IGUI_TTRP_EmoteCry"), getTexture("media/ui/poses/emotes/crying1.png"), doEmote, "TTRP_Crying1", player)
    menu:addSlice(getText("IGUI_TTRP_EmoteFacepalm"), getTexture("media/ui/poses/emotes/facepalm.png"), doEmote, "TTRP_Facepalm", player)
    menu:addSlice(getText("IGUI_TTRP_EmoteScared"), getTexture("media/ui/poses/emotes/scared.png"), doEmote, "TTRP_Scared_Look", player)
end

function subTTRPDances(menu, player)
    menu:addSlice(getText("IGUI_TTRP_AwkwardDance1"), getTexture("media/ui/poses/dancing/Awkward-Dance-1.png"), doEmote, "TTRP_AwkwardDance1", player)
    menu:addSlice(getText("IGUI_TTRP_AwkwardDance2"), getTexture("media/ui/poses/dancing/Awkward-Dance-2.png"), doEmote, "TTRP_AwkwardDance2", player)
    menu:addSlice(getText("IGUI_TTRP_AwkwardDance3"), getTexture("media/ui/poses/dancing/Awkward-Dance-3.png"), doEmote, "TTRP_AwkwardDance3", player)
    menu:addSlice(getText("IGUI_TTRP_AwkwardDance4"), getTexture("media/ui/poses/dancing/BBQDance.png"), doEmote, "TTRP_BBQShimmy", player)
    menu:addSlice(getText("IGUI_TTRP_SpookyMonthDance"), getTexture("media/ui/poses/dancing/spookymonthdance.png"), doEmote, "TTRP_SpookyMonthDance", player)
    menu:addSlice(getText("IGUI_TTRP_GangnamStyle"), getTexture("media/ui/poses/dancing/gangnam.png"), doEmote, "TTRP_GangnamStyle", player)
end

---------------------------------
-- Dynamic Menu                --
---------------------------------

function subTTRPDynamic(menu, player)
    menu:addSlice(getText("IGUI_TTRP_DynamicMisc"), getTexture("media/ui/menus/dynamic-misc.png"), ISRadialMenu.createSubMenu, menu, subDynamicMisc, player)
    menu:addSlice(getText("IGUI_TTRP_DynamicCombat"), getTexture("media/ui/menus/dynamic-combat.png"), ISRadialMenu.createSubMenu, menu, subDynamicCombat, player)
    menu:addSlice(getText("IGUI_TTRP_Workouts"), getTexture("media/ui/menus/dynamic-workouts.png"), ISRadialMenu.createSubMenu, menu, subDynamicWorkouts, player)
end

function subDynamicWorkouts(menu, player)
        menu:addSlice(getText("IGUI_TTRP_Bicyclekick"), getTexture("media/ui/poses/dynamic/bicyclekick.png"), doEmote, "TTRP_BicycleKick", player)
        menu:addSlice(getText("IGUI_TTRP_JumpingJacks"), getTexture("media/ui/poses/dynamic/jumpingjacks.png"), doEmote, "TTRP_JumpingJacks", player)
        menu:addSlice(getText("IGUI_TTRP_Meditate"), getTexture("media/ui/poses/sitting/meditate.png"), doEmote, "TTRP_Meditate", player)
        menu:addSlice(getText("IGUI_TTRP_Meditate2"), getTexture("media/ui/poses/dynamic/meditate2.png"), doEmote, "TTRP_Meditate2", player)
        menu:addSlice(getText("IGUI_TTRP_Meditate2Furniture"), getTexture("media/ui/poses/dynamic/meditate2.png"), doEmote, "TTRP_Meditate2_Furniture", player)
end


function subDynamicMisc(menu, player)
    menu:addSlice(getText("IGUI_TTRP_HandsOverStomach"), getTexture("media/ui/poses/dynamic/handstomach.png"), doEmote, "TTRP_HandsOverStomach", player)
    menu:addSlice(getText("IGUI_TTRP_ArmSling"), getTexture("media/ui/poses/dynamic/sling.png"), doEmote, "TTRP_ArmSling", player)
    menu:addSlice(getText("IGUI_TTRP_BackpackRummage"), getTexture("media/ui/poses/dynamic/backpackrummage.png"), doEmote, "TTRP_BackpackRummage", player)
    menu:addSlice(getText("IGUI_TTRP_Drunk"), getTexture("media/ui/poses/dynamic/drunkenshamble.png"), doEmote, "TTRP_Drunk", player)
    menu:addSlice(getText("IGUI_TTRP_CPR"), getTexture("media/ui/poses/dynamic/CPR.png"), doEmote, "TTRP_CPR", player)
    menu:addSlice(getText("IGUI_TTRP_CookingWithSpice"), getTexture("media/ui/poses/dynamic/spicybrain.png"), doEmote, "TTRP_CookingWithSpice", player)
    menu:addSlice(getText("IGUI_TTRP_Handwash"), getTexture("media/ui/poses/dynamic/handwash.png"), doEmote, "TTRP_Handwash", player)
    menu:addSlice(getText("IGUI_TTRP_CoolingOff"), getTexture("media/ui/poses/dynamic/coolingoff.png"), doEmote, "TTRP_CoolingOff", player)
    menu:addSlice(getText("IGUI_TTRP_PointBehind"), getTexture("media/ui/poses/dynamic/pointbehind.png"), doEmote, "TTRP_Blackboard", player)
    menu:addSlice(getText("IGUI_TTRP_ExamineHand"), getTexture("media/ui/poses/dynamic/examine.png"), doEmote, "TTRP_ExamineHand", player)
    menu:addSlice(getText("IGUI_TTRP_WallTinkle"), getTexture("media/ui/poses/dynamic/P-I-S-S.png"), doEmote, "TTRP_Wall_Tinkle", player)
    menu:addSlice(getText("IGUI_TTRP_ClutchingToilet"), getTexture("media/ui/poses/dynamic/toiletchuck.png"), doEmote, "TTRP_ClutchingToilet", player)
    menu:addSlice(getText("IGUI_TTRP_Snowangel"), getTexture("media/ui/poses/dynamic/starfish.png"), doEmote, "TTRP_Snowangel", player)
    menu:addSlice(getText("IGUI_TTRP_ASL"), getTexture("media/ui/poses/dynamic/ASL.png"), doEmote, "TTRP_ASL", player)
    menu:addSlice(getText("IGUI_TTRP_CampfireSit"), getTexture("media/ui/poses/dynamic/Campfire-Squat.png"), doEmote, "TTRP_CampfireSit", player)
    menu:addSlice(getText("IGUI_TTRP_Prostrating"), getTexture("media/ui/poses/dynamic/prostrate.png"), doEmote, "TTRP_Prostrating", player)
    -- menu:addSlice(getText("IGUI_TTRP_Test"), getTexture("media/ui/poses/dynamic/prostrate.png"), doEmote, "TTRP_Test", player)
    -- menu:addSlice("Brushing/Mopping", getTexture("media/ui/poses/dynamic/brushmop.png"), doTTRPActions, "Base.PropaneTank", "mop")
end

function subDynamicCombat(menu, player)
    menu:addSlice(getText("IGUI_TTRP_ShadowBoxing"), getTexture("media/ui/poses/dynamic/shadowboxing.png"), doEmote, "TTRP_ShadowBoxing", player)
    menu:addSlice(getText("IGUI_TTRP_FightingStance1"), getTexture("media/ui/poses/dynamic/FightingStance1.png"), doEmote, "TTRP_FightingStance1", player)
    menu:addSlice(getText("IGUI_TTRP_FightingStance2"), getTexture("media/ui/poses/dynamic/FightingStance2.png"), doEmote, "TTRP_FightingStance2", player)
    menu:addSlice(getText("IGUI_TTRP_FightingStance3"), getTexture("media/ui/poses/dynamic/FightingStance3.png"), doEmote, "TTRP_FightingStance3", player)
    menu:addSlice(getText("IGUI_TTRP_Fisticuffs"), getTexture("media/ui/poses/dynamic/Fisticuffs.png"), doEmote, "TTRP_Fisticuffs", player)
    menu:addSlice(getText("IGUI_TTRP_PostedUp"), getTexture("media/ui/poses/dynamic/postedup.png"), doEmote, "TTRP_PostedUp", player)
    menu:addSlice(getText("IGUI_TTRP_BeastMode"), getTexture("media/ui/poses/dynamic/beastmode.png"), doEmote, "TTRP_BeastMode", player)
    menu:addSlice(getText("IGUI_TTRP_MajimaThugging"), getTexture("media/ui/poses/dynamic/majimathugging.png"), doEmote, "TTRP_MajimaThugging", player)
    menu:addSlice(getText("IGUI_TTRP_ShadowBoxing"), getTexture("media/ui/poses/dynamic/shadowboxing.png"), doEmote, "TTRP_ShadowBoxing", player)
    menu:addSlice(getText("IGUI_TTRP_Capoeira"), getTexture("media/ui/poses/dynamic/capoeira.png"), doEmote, "TTRP_Capoeira", player)
    menu:addSlice(getText("IGUI_TTRP_FlipKick"), getTexture("media/ui/poses/dynamic/flipkick.png"), doEmote, "TTRP_FlipKick", player)
end

--------------------
-- FAVORITES MENU --
--------------------

function subTTRPFavorites(menu, player)
    if type(Favorites) ~= "table" then
        return
    end

    for text, data in pairs(Favorites) do
        if data and data.texture and data.command then
            -- --print("Processing favorite:", text, "Texture raw:", tostring(data.texture), "Type:", type(data.texture))
            -- Clean up the texture path for favorites added while the game is running. The game saves width and height data of the textures in-memory for the currently running game instance as a userdata JSON string rather than a readable string path.
            -- We need to remove that data from the table when reading it from the JSON file or it errors out unless you restart your game.
            local texturePath
            if type(data.texture) == "userdata" and data.texture.getName then
                texturePath = data.texture:getName() -- Convert userdata to string path
                -- --print("Converted texture userdata to path:", texturePath)
            elseif type(data.texture) == "string" then
                texturePath = data.texture 
            else
                -- --print("Error: Invalid texture type for favorite:", text)
             end
            local cleanTexturePath = texturePath:gsub("\\\\", "/"):gsub("\\", "/")
            -- --print("Cleaned texture path for:", text, "is:", cleanTexturePath)

            local texture = getTexture(cleanTexturePath)
            if not texture then
                --print("TTRP Poses Error: Could not load texture for " .. text .. " (" .. tostring(cleanTexturePath) .. ")")
            end

            -- We need to hardcode the function, couldn't figure out how to correctly extract function data from JSON strings. Might revisit this to let it dynamically store function information in JSON, but I couldn't figure out how.
            local commandFunc = doEmote
            local commandArg = data.command[2]
            menu:addSlice(text, texture, commandFunc, commandArg, player)

        else
            -- --print("Error: Invalid data for favorite:", text)
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
    ["TTRP.TTRP_SexySax"] = "BttB_SaxPlaying2",
    ["TTRP.TTRP_GirlypopTwerk"] = "TTRP_GirlypopTwerk",
    ["TTRP.TTRP_HurricaneKick"] = "TTRP_HurricaneKick",
    ["TTRP.TTRP_SpookyMonthDance"] = "TTRP_SpookyMonthDanceForbidden",
    ["TTRP.TTRP_Ascension"] = "TTRP_Lying_RapturedForbidden",

}

function subForbidden(menu, player)
    local playerItems = getPlayer():getInventory():getItems()
    for i=1,playerItems:size() do
        local item = playerItems:get(i-1)
        if ForbiddenPoses[item:getFullType()] then
            menu:addSlice(ForbiddenPoses[item:getFullType()], getTexture('ui/poses/Forbidden/' .. ForbiddenPoses[item:getFullType()] .. '.png'), doEmote, ForbiddenPoses[item:getFullType()], player)
        end
    end
end

EmoteMenuAPI.registerSlice("TTRP Poses", poseTTRPMain)
---------------------------------------------------------------
-- Radial Slice Detection and JSON saving For Favorites      --
---------------------------------------------------------------

local function saveFavorites()
    if type(Favorites) ~= "table" then
       -- --print("Favorites is not a valid table.")
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

    local savePath = getModFileWriter("\\TTRPPosesB42", "favorites.json", true, false)
    if not savePath then
        --print("Failed to open or create favorites.json.")
        return
    end

    local jsonString
    local success, err = pcall(function()
        jsonString = json.stringify(serializableFavorites)
    end)

    if not success then
        --print("Error encoding Favorites to JSON: " .. tostring(err))
        return
    end

    savePath:write(jsonString)
    savePath:close()
    --print("Favorites saved successfully.")
end

local function loadFavorites()
    local filePath = getModFileReader("\\TTRPPosesB42", "favorites.json", false)
    if not filePath then
     --print("Favorites file not found.")
        Favorites = {}
        return
    end

    local jsonString = filePath:readLine()
    filePath:close()

    if not jsonString or jsonString == "" then
     --print("No data to load from favorites.json.")
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
        --print("Favorites loaded successfully.")
    else
        --print("Error decoding JSON: " .. tostring(result))
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
                        -- --print("Refreshed Favorites menu.")
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



