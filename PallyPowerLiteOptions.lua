PallyPowerLite.options = {
	name = PALLYPOWERLIGHT_NAME,
	type = "group",
	args = {
-------------------------------
-- About Section
-------------------------------
		about_header = {
			name = "About",
			type = "header",
			order = 0
		},
		about_desc = {
			name = "Conceptually and visually, the addon is based on [Pally Power Classic], but developed from scratch and simplified to the realities of a casual Cataclysm expansion. The addon is created as a minimalistic version of the original. Allows you to assign and track an Aura, Seal and Buff for yourself and party/raid members. Can be used by raid leader to assign Auras and Buffs for pallys in raid (who has the addon of course).",
			type = "description",
			order = 1,
			fontSize = "medium"
		},
-------------------------------
-- Main Options Section
-------------------------------
		main_options_header = {
			name = "Main Options",
			type = "header",
			order = 2
		},
		main_options_minimap_button = {
			name = "Hide Minimap Icon",
			desc = "Check if you want to hide minimap icon",
			type = "toggle",
			order = 3,
			set = function(info, val)
				PallyPowerLite.prof.minimap.hide = not PallyPowerLite.prof.minimap.hide
				if PallyPowerLite.prof.minimap.hide then
					PallyPowerLite.MinimapIcon:Hide("PallyPowerLite")
				else
					PallyPowerLite.MinimapIcon:Show("PallyPowerLite")
				end
			end,
			get = function(info) return PallyPowerLite.prof.minimap.hide end
		},
		main_options_freeassign = {
			name = "Free Assignment",
			desc = "If Enables, all party/raid members can change Aura and Buff assignment for you",
			type = "toggle",
			order = 3,
			hidden = function(info) return select(2, UnitClass("player")) ~= "PALADIN" end,
			set = function(info, val)
				PallyPowerLite.prof.freeAssign = not PallyPowerLite.prof.freeAssign
				PallyPowerLite:UpdateSeflData()
				PallyPowerLite:UpdateAssignmentFrameLayout()
			end,
			get = function(info) return PallyPowerLite.prof.freeAssign end
		},
-------------------------------
-- Overlay Options Section
-------------------------------
		overlay_header = {
			name = "Overlay Options",
			type = "header",
			order = 4,
			hidden = function(info) return select(2, UnitClass("player")) ~= "PALADIN" end
		},
		overlay_rf_button = {
			name = "Enable RF Button",
			desc = "Enables/Disables showing Righteous Fury button in overlay (showing only in tank spec)",
			type = "toggle",
			order = 5,
			hidden = function(info) return select(2, UnitClass("player")) ~= "PALADIN" end,
			set = function(info, val)
				PallyPowerLite.prof.overlayShowRF = not PallyPowerLite.prof.overlayShowRF
				PallyPowerLite:UpdateOverlayLayout()
			end,
			get = function(info) return PallyPowerLite.prof.overlayShowRF end
		},
		overlay_reset_position = {
			name = "Reset Position",
			desc = "Resets overlay position (if you lost it)",
			type = "execute",
			order = 5,
			hidden = function(info) return select(2, UnitClass("player")) ~= "PALADIN" end,
			func  = function(info)
				PallyPowerLite.prof.overlayPos.x = 0;
				PallyPowerLite.prof.overlayPos.y = 0;
				local c = _G["PPLOverlayFrame"]
				c:ClearAllPoints()
				c:SetPoint("CENTER", "UIParent", "CENTER", PallyPowerLite.prof.overlayPos.x, PallyPowerLite.prof.overlayPos.y)
			end
		}
	}
}