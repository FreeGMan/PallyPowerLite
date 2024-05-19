
PallyPowerLite.commPrefix = "PLPWRL"
PallyPowerLite.pallyDataTemplate = {
	["freeAssign"] = true,
	["role"] = "NONE",
	["talents"] = {
		["holy"] = 0,
		["prot"] = 0,
		["retri"] = 0
	},
	["assignment"] = {
		["buff"] = 0,
		["aura"] = 0,
		["seal"] = 0
	}
}

PALLYPOWERLIGHT_MAXCLASSES = 11
PALLYPOWERLIGHT_MAXPALLYS = 8

PALLYPOWERLIGHT_BACKDROP_LAYOUT_16_16 = {
	bgFile = "Interface\\Buttons\\WHITE8X8",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileEdge = true,
	tileSize = 16,
	edgeSize = 16,
	insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

PallyPowerLite.ClassID = {
	[1] = "WARRIOR",
	[2] = "PALADIN",
	[3] = "HUNTER",
	[4] = "ROGUE",
	[5] = "PRIEST",
	[6] = "DEATHKNIGHT",
	[7] = "SHAMAN",
	[8] = "MAGE",
	[9] = "WARLOCK",
	[11] = "DRUID",
}

PallyPowerLite.ClassToID = {
	["WARRIOR"] = 1,
	["PALADIN"] = 2,
	["HUNTER"] = 3,
	["ROGUE"] = 4,
	["PRIEST"] = 5,
	["DEATHKNIGHT"] = 6,
	["SHAMAN"] = 7,
	["MAGE"] = 8,
	["WARLOCK"] = 9,
	["DRUID"] = 11,
}

PallyPowerLite.ClassIcons = {
	[1] = "Interface\\Icons\\ClassIcon_Warrior",
	[2] = "Interface\\Icons\\ClassIcon_Paladin",
	[3] = "Interface\\Icons\\ClassIcon_Hunter",
	[4] = "Interface\\Icons\\ClassIcon_Rogue",
	[5] = "Interface\\Icons\\ClassIcon_Priest",
	[6] = "Interface\\Icons\\Spell_deathknight_classicon",
	[7] = "Interface\\Icons\\ClassIcon_Shaman",
	[8] = "Interface\\Icons\\ClassIcon_Mage",
	[9] = "Interface\\Icons\\ClassIcon_Warlock",
	[11] = "Interface\\Icons\\ClassIcon_Druid",
}

PallyPowerLite.RoleIconCoords = {
	["NONE"] = "",
	["TANK"] = {0, 0.2617188, 0.2617188, 0.5234375},
	["HEALER"] = {0.2617188, 0.5234375, 0, 0.2617188},
	["DAMAGER"] = {0.2617188, 0.5234375, 0.2617188, 0.5234375}
}

PallyPowerLite.BuffsIcons = {
	[0] = "",
	[1] = "Interface\\Icons\\Spell_holy_greaterblessingofkings",
	[2] = "Interface\\Icons\\Spell_magic_greaterblessingofkings",
}

PallyPowerLite.Buffs = {
	[0] = "",
	[1] = 79102,	-- Blessing of Might
	[2] = 79063,	-- Blessing of Kings
}

PallyPowerLite.AurasIcons = {
	[0] = "",
	[1] = "Interface\\Icons\\Spell_Holy_DevotionAura",
	[2] = "Interface\\Icons\\Spell_Holy_AuraOfLight",
	[3] = "Interface\\Icons\\Spell_Holy_MindSooth",
	[4] = "Interface\\Icons\\Spell_Fire_SealOfFire",
	[5] = "Interface\\Icons\\Spell_Holy_CrusaderAura"
}

PallyPowerLite.Auras = {
	[0] = "",
	[1] = 465,		-- Devotion Aura
	[2] = 7294,		-- Retribution Aura
	[3] = 19746,	-- Concentration Aura
	[4] = 19891,	-- Resistance Aura
	[5] = 32223,	-- Crusader Aura
}

PallyPowerLite.SealsIcons = {
	[0] = "",
	[1] = "Interface\\Icons\\Spell_Holy_SealOfWrath",
	[2] = "Interface\\Icons\\Spell_Holy_HealingAura",
	[3] = "Interface\\Icons\\Spell_Holy_RighteousnessAura",
	[4] = "Interface\\Icons\\Spell_Holy_SealOfVengeance",
}

PallyPowerLite.Seals = {
	[0] = "",
	[1] = 20164,	-- Seal of Justice
	[2] = 20165,	-- Seal of Insight
	[3] = 20154,	-- Seal of Righteousness
	[4] = 31801,	-- Seal of Truth
}

do
	PallyPowerLite.GetAddOnMetadata = _G.GetAddOnMetadata or C_AddOns.GetAddOnMetadata
	local version = string.trim(PallyPowerLite.GetAddOnMetadata("PallyPowerLite", "Version"))
	if version == ("@project-".."version@") then -- split string so it doesn't get replaced by packager
		version = "Development version"
	end
	PALLYPOWERLIGHT_NAME = L["PallyPower Lite"] .. " (" .. version .. ")"
end