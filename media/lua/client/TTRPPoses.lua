-- Activates modules for global access. 
-- (At one point I was coding various client-server syncing and this lua file was required, it's mostly deprecated now but I'm leaving it here for future updates.)
-- Written by CrystalChris
local Client = {
	RadialPoses = require("TTRP-RoleplayPosesRadialMenu"),
}

local function Init()
	for name, module in pairs(Client) do
		module.Client = Client
	end
end

Init()

-- Helper function to determine if this is a solo or multiplayer game
function Client:IsMultiplayer()
	return getWorld():getGameMode() == "Multiplayer"
end

return Client