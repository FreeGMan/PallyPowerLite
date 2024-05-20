PallyPowerLite = LibStub("AceAddon-3.0"):NewAddon("PallyPowerLite", "AceConsole-3.0", "AceEvent-3.0", "AceBucket-3.0", "AceComm-3.0")

--Lib variable
local LS = LibStub("LibSerialize")
--local LD = LibStub("LibDeflate")

-- Saved variable
PallyPowerLiteSelfAssignment = {}
PPL_DebugEnabled = false

-- Main variable
player = UnitName("player")
isPally = false
isBattleground = false
roster = {}
classList = {}
pallysData = {}

-- Support variable
local partyUnits = {}
local raidUnits = {}
do
	table.insert(partyUnits, "player")
	for i = 1, MAX_PARTY_MEMBERS do
		table.insert(partyUnits, ("party%d"):format(i))
	end
	for i = 1, MAX_RAID_MEMBERS do
		table.insert(raidUnits, ("raid%d"):format(i))
	end
end
local lastMessage = ""


-------------------------------
-- Self Functions
-------------------------------

function PallyPowerLite:Debug(s)
	if (PPL_DebugEnabled) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffd100[PPL]|r |cff3fc7eb"..tostring(s).."|r", 1, 0, 0)
		if type(s) ~= "string" then
			DevTools_Dump(s)
		end
	end
end

function PallyPowerLite:OnInitialize()
	self:RegisterComm(PallyPowerLite.commPrefix)

	-- For first init state
	if not PallyPowerLiteSelfAssignment.assignment then
		PallyPowerLiteSelfAssignment = table.copy(self.pallyDataTemplate.assignment)	
	end

	-- Initialize options
	self.db = LibStub("AceDB-3.0"):New("PallyPowerLiteDB", {
		profile = {
			minimap = {
				hide = false
			},
			overlayLock = false,
			overlayPos = {
				x = 0,
				y = 0
			}
		},
	})
	self.prof = self.db.profile

	-- Initialize minimap icon
	self.MinimapIcon = LibStub("LibDBIcon-1.0")
	self.LDB =
		LibStub("LibDataBroker-1.1"):NewDataObject(
		"PallyPowerLite",
		{
			["type"] = "data source",
			["text"] = "PallyPowerLite",
			["icon"] = "Interface\\Icons\\spell_holy_championsbond",
			["OnTooltipShow"] = function(tooltip)
				tooltip:SetText(PALLYPOWERLIGHT_NAME)
				tooltip:AddLine(L["|cffffffff[Left-Click]|r Open Assignments Menu"])
				tooltip:Show()
			end,
			["OnClick"] = function(_, button)
				if (button == "LeftButton") then
					PallyPowerLiteAssignmentFrame_Toggle()
				end
			end
		}
	)
	self.MinimapIcon:Register("PallyPowerLite", self.LDB, self.prof.minimap)
	C_Timer.After(
		2.0,
		function()
			PallyPowerLite.MinimapIcon:Show("PallyPowerLite")
		end
	)

	self:RegisterChatCommand("ppl", PallyPowerLiteAssignmentFrame_Toggle)
	self:RegisterChatCommand("pallypowerlite", PallyPowerLiteAssignmentFrame_Toggle)

	local c = _G["PPLOverlayFrame"]
	c:ClearAllPoints()
	c:SetPoint("CENTER", "UIParent", "CENTER", self.prof.overlayPos.x, self.prof.overlayPos.y)

	if not PPL_DebugEnabled then
		PPL_DebugEnabled = true
		self:Debug(PALLYPOWERLIGHT_NAME.." loaded")
		PPL_DebugEnabled = false
	else		
		self:Debug(PALLYPOWERLIGHT_NAME.." loaded")
	end
end

function PallyPowerLite:OnEnable()
	--self:Debug("Start Enable")
	isPally = select(2, UnitClass("player")) == "PALADIN"
	isBattleground = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and IsInInstance()
	
	--self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("GROUP_JOINED")
	self:RegisterEvent("GROUP_LEFT")
	self:RegisterBucketEvent("ACTIVE_TALENT_GROUP_CHANGED", 1, "ACTIVE_TALENT_GROUP_CHANGED")
	self:RegisterBucketEvent("PLAYER_ENTERING_WORLD", 2, "PLAYER_ENTERING_WORLD")
	self:RegisterBucketEvent({"GROUP_ROSTER_UPDATE", "PLAYER_REGEN_ENABLED"}, 2, "GROUP_ROSTER_UPDATE")

	if isPally then	
		local c = _G["PPLOverlayFrame"]:Show()
	end

	self:UpdateSeflData()
	self:UpdateRoster()
	self:UpdateOverlayAnchorLayout()
	self:UpdateOverlayLayout()
end

function PallyPowerLite:OnDisable()
	--self:Debug("Start Disable")
	
	self:UnregisterAllEvents()
	self:UnregisterAllBuckets()
end

function PallyPowerLite:IsTrackedSpell(spellID)
	local res = false
	for _, currentSpellID in pairs(self.Buffs) do
		if spellID == currentSpellID then
			res = true
			break
		end	
	end
	for _, currentSpellID in pairs(self.Auras) do
		if spellID == currentSpellID then
			res = true
			break
		end	
	end
	for _, currentSpellID in pairs(self.Seals) do
		if spellID == currentSpellID then
			res = true
			break
		end	
	end
	return res
end

function PallyPowerLite:UpdateSeflData()
	if not isPally then return end
	
	local selfData = table.copy(self.pallyDataTemplate)
	selfData.role = UnitGroupRolesAssigned("player")
	selfData.talents.holy = select(5, GetTalentTabInfo(1))
	selfData.talents.prot = select(5, GetTalentTabInfo(2))
	selfData.talents.retri = select(5, GetTalentTabInfo(3))
	selfData.assignment = table.copy(PallyPowerLiteSelfAssignment)

	pallysData[player] = selfData

	self:SendPallyData(player)
end

function PallyPowerLite:UpdateRoster()
	isBattleground = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and IsInInstance()
	table.wipe(roster)
	for i = 1, PALLYPOWERLIGHT_MAXCLASSES do
		if self.ClassID[i] then
			classList[i] = 0
		end
	end

	for _, unitID in pairs(IsInRaid() and raidUnits or partyUnits) do
		if unitID and UnitExists(unitID) then
			local unitInfo = {}
			unitInfo.unitID = unitID
			unitInfo.class = UnitClassBase(unitID)
			if unitInfo.class then 
				unitName = GetUnitName(unitID, true)
				unitInfo.classID = self.ClassToID[unitInfo.class]
				unitInfo.role = UnitGroupRolesAssigned(unitID)
				unitInfo.isLeader = UnitIsGroupLeader(unitID)
				unitInfo.isPally = unitInfo.class == "PALADIN"
				unitInfo.hasBuff = false
				unitInfo.dead = false
				
				if PallyPowerLiteSelfAssignment and self.Buffs[PallyPowerLiteSelfAssignment.buff] ~= "" then
					local j=1
					local currentBuffID = select(10, UnitBuff(unitID, j))
					while currentBuffID do
						if currentBuffID == self.Buffs[PallyPowerLiteSelfAssignment.buff] then
							unitInfo.hasBuff = true
						end
		
						j=j+1
						currentBuffSource, _, _, currentBuffID = select(7, UnitBuff(unitID, j))
					end
				end

				roster[unitName] = unitInfo
				classList[unitInfo.classID] = classList[unitInfo.classID] + 1
			end
		end
	end

	-- Clean pallys data who not in roster anymore
	for pallyName in pairs(pallysData) do
		if pallyName ~= player and roster[pallyName] then
			table.remove(pallysData, pallyName)
		end
	end
end

function PallyPowerLite:UpdateAssignmentFrameLayout()
	local mainFrame = _G["PPLAssignmentFrame"]
	if not mainFrame or not mainFrame:IsVisible() then return end
	
	local frameHeight = 100 -- Start Height with only header
	local rowHeight = _G[mainFrame:GetName().."Row1"]:GetHeight()

	for i=1, PALLYPOWERLIGHT_MAXCLASSES do
		local frameName = mainFrame:GetName().."HeaderClassFrameInfo"..tostring(i)
		if _G[frameName] then
			local icon = PallyPowerLite.ClassIcons[i]
			if icon then
				_G[frameName.."Icon"]:SetTexture(icon)
			end
			local classCount = classList[i]
			if classCount then
				_G[frameName.."Counter"]:SetText(tostring(classCount))
			end
		end
	end
	
	-- Hide all pallys rows
	for i=1, PALLYPOWERLIGHT_MAXPALLYS do
		local rowFrame = _G[mainFrame:GetName().."Row"..tostring(i)]
		if rowFrame then
			rowFrame:Hide()
		end
	end

	-- Fill rows with pallys data and show
	-- Our pally always show first
	i=1
	for pallyName, pallyData in fpairs(pallysData, player) do
		if i > PALLYPOWERLIGHT_MAXPALLYS then break end
		
		local rowFrameName = mainFrame:GetName().."Row"..tostring(i)
		local rowFrame = _G[rowFrameName]
		if rowFrame then
			-- Pally info
			local infoFrameName = rowFrameName.."PallyInfo"
			_G[infoFrameName.."NameText"]:SetText(pallyName)
			_G[infoFrameName.."HolyTalentCount"]:SetText(pallyData.talents.holy)
			_G[infoFrameName.."ProtTalentCount"]:SetText(pallyData.talents.prot)
			_G[infoFrameName.."RetriTalentCount"]:SetText(pallyData.talents.retri)

			local roleIconCoord = PallyPowerLite.RoleIconCoords[
				pallyData.role ~= "NONE" and pallyData.role
				or pallyData.talents.holy > 30 and "HEALER"
				or pallyData.talents.prot > 30 and "TANK"
				or pallyData.talents.retri > 30 and "DAMAGER"
				]
			if roleIconCoord then
				_G[infoFrameName.."RoleIcon"]:SetTexCoord(roleIconCoord[1], roleIconCoord[2], roleIconCoord[3], roleIconCoord[4])
			else
				_G[infoFrameName.."RoleIcon"]:SetTexCoord(0, 0, 0, 0)
			end

			-- Pally assignment
			_G[rowFrameName.."PallyAuraButtonIcon"]:SetTexture(PallyPowerLite.AurasIcons[pallyData.assignment.aura])
			_G[rowFrameName.."PallyBuffButtonIcon"]:SetTexture(PallyPowerLite.BuffsIcons[pallyData.assignment.buff])

			i = i + 1
			frameHeight = frameHeight + rowHeight
			rowFrame:Show()
		end
	end

	mainFrame:SetHeight(frameHeight)
end

function PallyPowerLite:UpdateOverlayLayout()
	if not PallyPowerLiteSelfAssignment then return end
	
	local auraID = self.Auras[PallyPowerLiteSelfAssignment.aura]
	local auraColor = auraID == "" and {r=0, g=0, b=0, a=0.5} or {r=1, g=0, b=0, a=0.4}
	local sealID = self.Seals[PallyPowerLiteSelfAssignment.seal]
	local sealColor = sealID == "" and {r=0, g=0, b=0, a=0.5} or {r=1, g=0, b=0, a=0.4}

	local i=1
	local currentBuffSource, _, _, currentBuffID = select(7, UnitBuff("player", i))
	while currentBuffID do
		if currentBuffSource == "player" and currentBuffID == auraID then
			auraColor = {r=0, g=1, b=0, a=0.4}
		end
		if currentBuffSource == "player" and currentBuffID == sealID then
			sealColor = {r=0, g=1, b=0, a=0.4}
		end
		
		i=i+1
		currentBuffSource, _, _, currentBuffID = select(7, UnitBuff("player", i))
	end
	
	local buttonName = "PPLOverlayFrameButtonAura";
	_G[buttonName]:SetAttribute("spell", (not auraID or auraID == "") and "" or GetSpellInfo(auraID))
	_G[buttonName]:SetBackdropColor(auraColor["r"], auraColor["g"], auraColor["b"], auraColor["a"])
	_G[buttonName.."Icon"]:SetTexture(self.AurasIcons[PallyPowerLiteSelfAssignment.aura])

	local buttonName = "PPLOverlayFrameButtonSeal";
	_G[buttonName]:SetAttribute("spell", (not sealID or sealID == "") and "" or GetSpellInfo(sealID))
	_G[buttonName]:SetBackdropColor(sealColor["r"], sealColor["g"], sealColor["b"], sealColor["a"])
	_G[buttonName.."Icon"]:SetTexture(self.SealsIcons[PallyPowerLiteSelfAssignment.seal])
	
	local coutHasBuff = 0
	for unitName, unitInfo in pairs(roster) do
		if unitInfo.hasBuff then
			coutHasBuff = coutHasBuff + 1
		end
	end
	local buffID = self.Buffs[PallyPowerLiteSelfAssignment.buff]
	local buffColor = buffID == "" and {r=0, g=0, b=0, a=0.5} 
		or coutHasBuff == 0 and {r=1, g=0, b=0, a=0.4}
		or coutHasBuff < table.length(roster) and {r=1, g=1, b=0, a=0.4}
		or {r=0, g=1, b=0, a=0.4}
	
 
	local buttonName = "PPLOverlayFrameButtonBuff";
	_G[buttonName]:SetAttribute("spell", (not buffID or buffID == "") and "" or GetSpellInfo(buffID))
	_G[buttonName]:SetBackdropColor(buffColor["r"], buffColor["g"], buffColor["b"], buffColor["a"])
	_G[buttonName.."Icon"]:SetTexture(self.BuffsIcons[PallyPowerLiteSelfAssignment.buff])
	_G[buttonName.."Counter"]:SetText((coutHasBuff == table.length(roster) or buffID == "") and "" or table.length(roster) - coutHasBuff)
end

function PallyPowerLite:UpdateOverlayAnchorLayout()
	if not isPally then return end
	local c = _G["PPLOverlayFrameButtonAnchorBackground"]
	if not c then return end

	if self.prof.overlayLock then
		c:SetColorTexture(1, 0, 0, 1)
	else
		c:SetColorTexture(0, 1, 0, 1)
	end
end

function PallyPowerLite:CycleThroughSpell(pallyName, spellType, forward)
	local pallyData = pallysData[pallyName]
	if not pallyData or not spellType
		or (not pallyData.freeAssign and pallyName ~= player) then return end
	
	local spellData = nil
	local currentSpell = 0
	if spellType == "Buff" then
		spellsData = PallyPowerLite.Buffs
		currentSpell = pallyData.assignment.buff or 0
	elseif spellType == "Aura" then
		spellsData = PallyPowerLite.Auras
		currentSpell = pallyData.assignment.aura or 0
	else
		spellsData = PallyPowerLite.Seals
		currentSpell = pallyData.assignment.seal or 0
	end
	
	if forward then
		currentSpell = table.length(spellsData) == currentSpell+1 and 0 or currentSpell+1
	else
		currentSpell = currentSpell == 0 and table.length(spellsData)-1 or currentSpell-1
	end

	if spellType == "Buff" then
		pallyData.assignment.buff = currentSpell
	elseif spellType == "Aura" then
		pallyData.assignment.aura = currentSpell
	else
		pallyData.assignment.seal = currentSpell
	end

	if pallyName == player then
		PallyPowerLiteSelfAssignment = table.copy(pallyData.assignment)
		self:UpdateRoster()
	end

	self:UpdateAssignmentFrameLayout()
	self:UpdateOverlayLayout()
	self:SendPallyData(pallyName)
end

function PallyPowerLite:SendPallyData(pallyName, target)
	currentData = pallyName and {[pallyName] = pallysData[pallyName]} or pallysData
	self:SendMessage("PALLYDATA", currentData, target)
end

function PallyPowerLite:SendMessage(messageType, messageData, target)
	if GetNumGroupMembers() <= 0 or not messageType or isBattleground then return end
	local message = {
		["messageType"] = messageType,
		["messageData"] = messageData
	}
	local chanel = "WHISPER"
	if not target then
		if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and IsInInstance() then
			chanel = "INSTANCE_CHAT"
		elseif IsInRaid() then
			chanel = "RAID"
		else
			chanel = "PARTY"
		end
	end

	local outcomeData = LS:Serialize(message)
	if lastMessage ~= outcomeData then
		self:SendCommMessage(self.commPrefix, outcomeData, chanel, target)
	end
end

function PallyPowerLite:OnCommReceived(prefix, payload, distribution, sender)
	if prefix ~= self.commPrefix or isBattleground then return end
	if sender == player then return end
	--self:Debug("["..prefix.."] "..sender.." : "..payload);
	
	local success, incomeData = LS:Deserialize(payload)
	if success then
		self:ProcessIncomeData(incomeData)
	else
		self:Debug("Can't deserialize message")
	end
end

function PallyPowerLite:ProcessIncomeData(incomeData, sender)
	if not incomeData.messageType then return end
	
	if incomeData.messageType == "PALLYDATA" then
		if incomeData.messageData then
			for pallyName, pallyData in pairs(incomeData.messageData) do
				if pallyName and pallyData and roster[pallyName] then
					pallysData[pallyName] = pallyData
					if pallyName == player then
						slef:UpdateRoster()
						self:UpdateOverlayLayout()
					end
				end
			end
			self:UpdateAssignmentFrameLayout()
		end
	elseif incomeData.messageType == "REQDATA" then
		if isPally and pallysData[player] then
			self:SendPallyData(player, sender)
		end
	end
end


-------------------------------
-- Event Handlers
-------------------------------

function PallyPowerLite:UNIT_AURA(event, unitTarget, updateInfo)
	local unitName = GetUnitName(unitTarget, true)
	if isPally and PallyPowerLiteSelfAssignment and roster[unitName] then	
		local needUpdate = false
		if updateInfo.addedAuras then
			for _, currentAura in pairs(updateInfo.addedAuras) do
				if self:IsTrackedSpell(currentAura.spellId) then
					if currentAura.spellId == self.Buffs[PallyPowerLiteSelfAssignment.buff] then
						roster[unitName].hasBuff = true
					end
					needUpdate = true
					break
				end
			end
		end
		-- Because I don't want to cache aura instances data and GetAuraDataByAuraInstanceID doesn't work on removed aura
		-- Just update if something was removed but only outside of combat (for optimization)
		if updateInfo.removedAuraInstanceIDs and not InCombatLockdown() then
			self:UpdateRoster()
			needUpdate = true
		end
		if needUpdate then
			self:UpdateOverlayLayout()
		end	
	end
end

function PallyPowerLite:GROUP_JOINED()
	self:UpdateSeflData()
	self:UpdateRoster()
	self:SendMessage("REQDATA")
	self:UpdateOverlayLayout()
	self:UpdateAssignmentFrameLayout()
end

function PallyPowerLite:GROUP_LEFT()
	self:UpdateRoster()
	self:UpdateOverlayLayout()
	self:UpdateAssignmentFrameLayout()	
end

function PallyPowerLite:GROUP_ROSTER_UPDATE()
	self:UpdateRoster()
	self:UpdateOverlayLayout()
	self:UpdateAssignmentFrameLayout()	
end

function PallyPowerLite:PLAYER_ENTERING_WORLD()
	self:UpdateSeflData()
	self:UpdateRoster()
	self:SendMessage("REQDATA")
	self:UpdateOverlayLayout()
	self:UpdateAssignmentFrameLayout()	
end

function PallyPowerLite:ACTIVE_TALENT_GROUP_CHANGED()
	self:UpdateSeflData()
	self:UpdateAssignmentFrameLayout()
end


-------------------------------
-- Frame Event Functions
-------------------------------

function PallyPowerLite:RowButton_OnClick(button, mouseButton)
	local rowNumber = tonumber(string.match(button:GetName(), "%d+"))
	if not rowNumber then return end
	local isBuff = string.match(button:GetName(), "Buff") ~= nil
	
	local pallyName = _G["PPLAssignmentFrameRow"..rowNumber.."PallyInfoNameText"]:GetText()
	if not pallyName then return end
	
	PallyPowerLite:CycleThroughSpell(pallyName, isBuff and "Buff" or "Aura", mouseButton == "LeftButton")
end

function PallyPowerLite:RowButton_OnMouseWheel(button, deltaScroll)
	-- -1 = mouse wheel down = lift click
	self:RowButton_OnClick(button, deltaScroll == -1 and "LeftButton" or "RightButton")
end

function PallyPowerLite:OverlayButton_OnLoad(button)
	if BackdropTemplateMixin then
		Mixin(button, BackdropTemplateMixin)
	end
	button:SetBackdrop(PALLYPOWERLIGHT_BACKDROP_LAYOUT_16_16)
	if BackdropTemplateMixin then
		Mixin(button, BackdropTemplateMixin)
	end
	button:SetBackdropColor(0, 0, 0, 0.5)
end

function PallyPowerLite:OverlayButton_OnMouseWheel(button, deltaScroll)
	local spellType = nil
	if string.match(button:GetName(), "Buff") ~= nil then
		spellType = "Buff"
	elseif string.match(button:GetName(), "Aura") ~= nil then
		spellType = "Aura"
	elseif string.match(button:GetName(), "Seal") ~= nil then
		spellType = "Seal"
	end

	-- -1 = mouse wheel down = lift click
	PallyPowerLite:CycleThroughSpell(player, spellType, deltaScroll == -1)
end

function PallyPowerLite:OverlayAnchorButton_OnClick(button, mouseButton)
	if mouseButton == "LeftButton" then
		self.prof.overlayLock = not self.prof.overlayLock
		self:UpdateOverlayAnchorLayout()
	end
end

function PallyPowerLite:OverlayAnchorButton_OnDragStart(button, mouseButton)
	if not self.prof.overlayLock then
		local c = _G["PPLOverlayFrame"]
		c:StartMoving()
		c:SetClampedToScreen(true)
	end	
end

function PallyPowerLite:OverlayAnchorButton_OnDragStop(button)
	_G["PPLOverlayFrame"]:StopMovingOrSizing()
end


-------------------------------
-- Global Functions
-------------------------------

function PallyPowerLiteAssignmentFrame_Toggle()
	if PPLAssignmentFrame:IsVisible() then
		PPLAssignmentFrame:Hide()
	else
		local c = _G["PPLAssignmentFrame"]
		c:ClearAllPoints()
		c:SetPoint("CENTER", "UIParent", "CENTER", 0, 0)
		PPLAssignmentFrame:Show()
		PallyPowerLite:UpdateAssignmentFrameLayout()
	end
end


-------------------------------
-- Support Functions
-------------------------------

function table.copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[table.copy(k, s)] = table.copy(v, s) end
  return res
end

function table.length(obj)
  local res = 0
  for _ in pairs(obj) do res = res + 1 end
  return res
end

function fpairs(obj, first)
	if table.length(obj) == 0 or not obj[first] then return pairs(obj) end
   -- set first and collect other the keys
   local keys = first and {first} or {}
   for k in pairs(obj) do if k ~= first then keys[#keys+1] = k end end
   
   -- return the iterator function
   local i = 0
   return function()
      i = i + 1
      if keys[i] then
         return keys[i], obj[keys[i]]
      end
   end
end