if( not ShadowUF.ComboPoints ) then return end

local Souls = setmetatable({}, {__index = ShadowUF.ComboPoints})
ShadowUF:RegisterModule(Souls, "soulShards", ShadowUF.L["Soul Shards"], nil, "WARLOCK", SPEC_WARLOCK_AFFLICTION)
local soulsConfig = {max = 3, key = "soulShards", colorKey = "SOULSHARDS", powerType = Enum.PowerType.SoulShards, eventType = "SOUL_SHARDS", icon = "Interface\\AddOns\\ShadowedUnitFrames\\media\\textures\\shard"}

local GetSpecialization = C_SpecializationInfo.GetSpecialization or _G.GetSpecialization

function Souls:OnEnable(frame)
	frame.soulShards = frame.soulShards or CreateFrame("Frame", nil, frame)
	frame.soulShards.cpConfig = soulsConfig
	frame.soulShards.cpConfig.max = (GetSpecialization() == SPEC_WARLOCK_AFFLICTION) and 50 or 5
	frame.soulShards.cpConfig.grouping = (GetSpecialization() == SPEC_WARLOCK_AFFLICTION) and UnitPowerDisplayMod(soulsConfig.powerType) or 1							   
	frame.comboPointType = soulsConfig.key

	frame:RegisterUnitEvent("UNIT_POWER_FREQUENT", self, "Update")
	frame:RegisterUnitEvent("UNIT_MAXPOWER", self, "UpdateBarBlocks")
	frame:RegisterUnitEvent("UNIT_DISPLAYPOWER", self, "Update")
	frame:RegisterNormalEvent("PLAYER_SPECIALIZATION_CHANGED", self, "SpecChanged")

	frame:RegisterUpdateFunc(self, "Update")
	frame:RegisterUpdateFunc(self, "UpdateBarBlocks")
						  
end

function Souls:OnLayoutApplied(frame, config)
	ShadowUF.ComboPoints.OnLayoutApplied(self, frame, config)
	self:UpdateBarBlocks(frame)
end

function Souls:SpecChanged(frame)
	-- update shard count on spec swap
	if frame and frame.soulShards then
		frame.soulShards.cpConfig.max = (GetSpecialization() == SPEC_WARLOCK_AFFLICTION) and 50 or 5
		frame.soulShards.cpConfig.grouping = (GetSpecialization() == SPEC_WARLOCK_AFFLICTION) and UnitPowerDisplayMod(soulsConfig.powerType) or 1
	end
	self:UpdateBarBlocks(frame)
end

function Souls:GetComboPointType()
	return "soulShards"
end

function Souls:GetPoints(unit)
	return UnitPower("player", soulsConfig.powerType, (GetSpecialization() == SPEC_WARLOCK_AFFLICTION))
end

function Souls:GetMaxPoints(unit)
	return UnitPowerMax("player", soulsConfig.powerType, (GetSpecialization() == SPEC_WARLOCK_AFFLICTION))
end


function Souls:Update(frame, event, unit, powerType)
    if event and powerType ~= "SOUL_SHARDS" then return end
    if not frame.soulShards then return end

    local max = self:GetMaxPoints()
    local power = self:GetPoints("player")

    local shardSize = UnitPowerDisplayMod(soulsConfig.powerType) or 10
    local numShards = max / shardSize

    for id = 1, numShards do
        local shard = frame.soulShards.points and frame.soulShards.points[id]
        if not shard then break end

        local value = math.min(power, shardSize)
        shard:SetMinMaxValues(0, shardSize)
        shard:SetValue(value)

        local color
        if value >= shardSize then
            color = "FULLSOULSHARD"
        elseif value > 0 then
            color = "SOULSHARDS"
        else
            color = "SOULSHARDS"
        end

        if shard.setColor ~= color then
            shard.setColor = color
            frame:SetBlockColor(
                shard,
                "soulShards",
                ShadowUF.db.profile.powerColors[color].r,
                ShadowUF.db.profile.powerColors[color].g,
                ShadowUF.db.profile.powerColors[color].b
            )
        end

        power = power - shardSize
    end
end
