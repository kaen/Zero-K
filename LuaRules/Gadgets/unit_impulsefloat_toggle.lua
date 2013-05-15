local isImpulseFloat = (Spring.GetModOptions().impulsefloat  == "1") --ImpulseFloat
function gadget:GetInfo()
  return {
    name      = "Impulse Float Toggle",
    desc      = "Adds a float/sink toggle to units, can be pushed by other unit while floating",
    author    = "Google Frog", --Msafwan (impulse based float)
    date      = "9 March 2012, 12 April 2013",
    license   = "GNU GPL, v2 or later",
    layer     = -1, --start before unit_fall_damage.lua (for UnitPreDamage())
    enabled   = isImpulseFloat,  --  loaded by default?
  }
end
--[[
Changelog:
4 April 2013	Msafwan		Replace MoveCtrl with Impulse. This allow Spring to handle unit-to-unit collision.
							Which make floating unit non-static (can be pushed by ships and stack on top each
							other without issues).
							
--]]
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

if (not gadgetHandler:IsSyncedCode()) then 
    return
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- Commands

local DEFAULT_FLOAT = 1

include("LuaRules/Configs/customcmds.h.lua")

local unitFloatIdleBehaviour = {
	id      = CMD_UNIT_FLOAT_STATE,
	type    = CMDTYPE.ICON_MODE,
	name    = 'Float State',
	action  = 'floatstate',
	tooltip	= 'Impulse Float / Sink', --colorful tooltip is written in integral_menu_commands.lua
	params 	= {DEFAULT_FLOAT, 'Sink','Attack','Float'}
}

local FLOAT_NEVER = 0
local FLOAT_ATTACK = 1
local FLOAT_ALWAYS = 2

-------------------------------------------------------------------------------------
-- Config

local sinkCommand = {
	[CMD.MOVE] = true,
	[CMD.GUARD] = true,
	[CMD.FIGHT] = true,
	[CMD.PATROL] = true,
	[CMD_WAIT_AT_BEACON] = true,
}

local floatDefs = include("LuaRules/Configs/float_defs.lua")

--------------------------------------------------------------------------------
-- Local Vars

local float = {}
local floatByID = {data = {}, count = 0}

local floatState = {}
local aimWeapon = {}
local gRAVITY = Game.gravity/30/30
local rAD_PER_ROT = (math.pi/(2^15))
local fLY_THRESHOLD = gRAVITY*8

--------------------------------------------------------------------------------
-- Communication to script

local function callScript(unitID, funcName, args)
	local func = Spring.UnitScript.GetScriptEnv(unitID)[funcName]
	if func then
		Spring.UnitScript.CallAsUnit(unitID,func, args)
	end
end
--------------------------------------------------------------------------------
-- Float Table Manipulation

local function addFloat(unitID, unitDefID, isFlying)
	if not float[unitID] then
		local def = floatDefs[unitDefID]
		local x,y,z = Spring.GetUnitPosition(unitID)
		if y < def.depthRequirement or isFlying then
			local place, feature = Spring.TestBuildOrder(unitDefID, x, y ,z, 1)
			if place == 2 or place == 1 then
				Spring.SetUnitRulesParam(unitID, "disable_tac_ai", 1)
				floatByID.count = floatByID.count + 1
				floatByID.data[floatByID.count] = unitID
				float[unitID] = {
					index = floatByID.count,
					surfacing = true,
					prevSurfacing = true,
					onSurface = false,
					justStarted = true,
					sinkTank = 0,
					nextSpecialDrag = 1,
					speed = def.initialRiseSpeed, --desired speed
					x = x, y = y, z = z,
					unitDefID = unitDefID,
					isFlying = isFlying,
					paraData = {want = false, para = false},
				}
				local headingInRadian = Spring.GetUnitHeading(unitID)*rAD_PER_ROT
				Spring.SetUnitRotation(unitID, 0, -headingInRadian, 0) --this force unit to stay upright/prevent tumbling.TODO: remove negative sign if Spring no longer mirror input anymore 
			end
		end
	end
end

local function removeFloat(unitID)
	float[floatByID.data[floatByID.count] ].index = float[unitID].index
	floatByID.data[float[unitID].index] = floatByID.data[floatByID.count]
	floatByID.data[floatByID.count] = nil
	float[unitID] = nil
	floatByID.count = floatByID.count - 1
end

local function setSurfaceState(unitID, unitDefID, surfacing)
	local stun = float[unitID].paraData.para or Spring.GetUnitIsStunned(unitID)
	local data = float[unitID]
	if not stun then
		data.surfacing = surfacing
	else
		data.paraData.want = surfacing 
		if not data.paraData.para then
			local def = floatDefs[data.unitDefID]
			if def.sinkOnPara then
				data.surfacing = false
			end
		end
		data.paraData.para = true
	end
end

function gadget:UnitLoaded(unitID, unitDefID, unitTeam, transportID, transportTeam)
	if float[unitID] then
		Spring.SetUnitRulesParam(unitID, "disable_tac_ai", 0)
		Spring.GiveOrderToUnit(unitID,CMD.WAIT, {}, {})
		Spring.GiveOrderToUnit(unitID,CMD.WAIT, {}, {})
		callScript(unitID, "script.StopMoving")
		removeFloat(unitID)
	end
end

--------------------------------------------------------------------------------
-- Script calls

GG.Floating_StopMoving = GG.Floating_StopMoving or function() end --empty function. Defined in gadget:Initialize()

GG.Floating_AimWeapon = GG.Floating_AimWeapon or function() end

GG.Floating_UnitTeleported = GG.Floating_UnitTeleported or function() end

local function checkAlwaysFloat(unitID)
	if not select(1, Spring.GetUnitIsStunned(unitID)) then
		local unitDefID = Spring.GetUnitDefID(unitID)
		local cQueue = Spring.GetCommandQueue(unitID, 1)
		local moving = cQueue and #cQueue > 0 and sinkCommand[cQueue[1].id]
		if not moving then
			addFloat(unitID, unitDefID)
		end
	end
end

--------------------------------------------------------------------------------
-- Realism/Physic

--Reference: http://en.wikipedia.org/wiki/Drag_equation
local function CalculateDrag (velocity, dragCoefficient, unitsMass, waterDensity, unitsArea)
	local acceleration = 0.5*(waterDensity*velocity*velocity*dragCoefficient*unitsArea)/unitsMass
	local accWithDirection = acceleration*(math.abs(velocity)/velocity)
	return -accWithDirection
end

--------------------------------------------------------------------------------
-- Update that moves things around

function gadget:GameFrame(f)

	local checkStun = f%16 == 4
	local checkOrder = f%16 == 12

	local i = 1
	while i <= floatByID.count do
		local unitID = floatByID.data[i]
		local isValidUnitID = Spring.ValidUnitID(unitID)
		local isFlying = isValidUnitID and float[unitID]["isFlying"]
		
		if isFlying then --check if unit has landed or not
			local data = float[unitID] --(get reference to data table)
			data.x,data.y,data.z = Spring.GetUnitPosition(unitID)
			local height = Spring.GetGroundHeight(data.x, data.z)
			if data.y == height then --touch down on land
				removeFloat(unitID)
				i = i - 1
			elseif data.y <= 0 then --touch down on water level
				local dx,dy,dz = Spring.GetUnitVelocity(unitID)
				dx,dz =dx/2,dz/2 --arbitrary tweak (reduce speed to make less bounce)
				data.speed = math.sqrt(dy*dy + dx*dx + dz*dz) --Note: data.speed is designed for speed on y axis only but we include x,y,z just for fun! (higher speed mean better bounce when hitting water).
				data.isFlying = false
				local cmdQueue = Spring.GetUnitCommands(unitID);
				if (#cmdQueue>0) then 
					local cmdOpt = cmdQueue[1].options
					if cmdQueue[1].id == CMD.MOVE and cmdOpt.coded == 16 and cmdOpt.right then --Note: not sure what is "coded == 16" and "right" is but we want to remove any MOVE command as soon as amphfloater touch down so that it doesn't try to return to old position
						--Spring.GiveOrderToUnit(unitID,CMD.REMOVE, {cmdQueue[1].tag}, {}) --clear Spring's command that desire unit to return to old position	
						Spring.GiveOrderArrayToUnitArray( {unitID},{
							{CMD.REMOVE, {cmdQueue[1].tag}, {}},--clear Spring's command that desire unit to return to old position	
							{CMD.INSERT, {0, CMD.STOP, CMD.SHIFT,}, {"alt"}},
						})
					end
				end
			end
			i = i + 1
			
		elseif isValidUnitID and not isFlying then --perform float/sink behaviour
			local data = float[unitID]
			local def = floatDefs[data.unitDefID]
			
			-- This cannot be done when the float is added because that will often be
			-- the result of a unit script. Strange trigger inheritence bleh!
			if data.justStarted then
				callScript(unitID, "Float_startFromFloor")
				data.justStarted = nil
			end
			
			-- Check various paralysis conditions
			if checkStun then
				local stun
				-- Units that are paralysed cannot change state so change
				-- state when they become unstunned
				if data.paraData.para then
					stun = select(1, Spring.GetUnitIsStunned(unitID))
					if not stun then
						data.surfacing = data.paraData.want
						data.paraData.para = false
					end
				end
				-- Some units may sink when paralised, ie they require power to stay afloat.
				if def.sinkOnPara and not data.paraData.para then
					stun = stun or select(1, Spring.GetUnitIsStunned(unitID))
					if stun then
						data.paraData.want = data.surfacing 
						data.surfacing = false
						data.paraData.para = true
					end
				end
			end
			
			-- Check if the unit should sink
			if checkOrder then
				if floatState[unitID] == FLOAT_ALWAYS then
					local cQueue = Spring.GetCommandQueue(unitID, 1)
					local moving = cQueue and #cQueue > 0 and sinkCommand[cQueue[1].id]
					setSurfaceState(unitID, data.unitDefID, not moving)
				elseif floatState[unitID] == FLOAT_ATTACK then
					local cQueue = Spring.GetCommandQueue(unitID, 1)
					local moving = cQueue and #cQueue > 0 and cQueue[1].id == CMD.MOVE and not cQueue[1].options.internal
					setSurfaceState(unitID, data.unitDefID, (not moving and aimWeapon[unitID]) or false)
				elseif floatState[unitID] == FLOAT_NEVER then
					setSurfaceState(unitID, data.unitDefID, false)
				end
			end
			
			-- Rising/Sinking Animation
			if data.prevSurfacing ~= data.surfacing then
				if data.surfacing then
					callScript(unitID, "Float_rising")
				else
					callScript(unitID, "Float_sinking")
				end
				data.prevSurfacing = data.surfacing
			end
			
			-- Update unit current position
			data.x,data.y,data.z = Spring.GetUnitPosition(unitID)
			
			-- Fill tank
			if def.sinkTankRequirement then
				if not data.surfacing then
					if data.y <= def.floatPoint and data.sinkTank <= def.sinkTankRequirement then
						data.sinkTank = data.sinkTank + 1
					end
				else
					data.sinkTank = 0
				end
			end
			
			-- Increase & decrease floating/sinking speed
			if data.y <= def.floatPoint then
				if not data.surfacing then --sinking
					if (not def.sinkTankRequirement or data.sinkTank > def.sinkTankRequirement) then
						local dragFactors = (data.speed > 0 and def.sinkUpDrag or def.sinkDownDrag)*data.nextSpecialDrag*def.waterHitDrag
						local drag = CalculateDrag(data.speed,dragFactors, 1,0.2,1)
						data.speed = (data.speed + def.sinkAccel +drag) --sink as fast as possible
						data.onSurface = false
					else
						local dragFactors = (data.speed > 0 and def.sinkUpDrag or def.sinkDownDrag)*data.nextSpecialDrag*def.waterHitDrag
						local drag = CalculateDrag(data.speed,dragFactors, 1,0.2,1)
						data.speed = (data.speed + def.sinkAccel*(data.sinkTank/def.sinkTankRequirement) +drag) --sink as fast as sinktank fill
					end
				else --rising
					local dragFactors = (data.speed > 0 and def.riseUpDrag or def.riseDownDrag)*data.nextSpecialDrag*def.waterHitDrag
					local drag = CalculateDrag(data.speed,dragFactors, 1,0.2,1)				
					data.speed = (data.speed + def.riseAccel+drag) --float as fast as possible
				end
			else
				local dragFactors = (def.airDrag)*data.nextSpecialDrag
				local drag = CalculateDrag(data.speed,dragFactors, 1,0.02,1)	
				data.speed = (data.speed + def.airAccel + drag) --fall down from sky
			end
			
			-- Test for special case
			local height = Spring.GetGroundHeight(data.x, data.z)
			if data.speed ~= 0 or data.y <= height or not data.onSurface then
				
				-- Splash animation when enter/exit water
				if not data.onSurface then
					local waterline = data.y - def.floatPoint
					-- enter water: do splash
					if data.speed < 0 and waterline > 0 and waterline < -data.speed then
						callScript(unitID, "Float_crossWaterline", {data.speed})
					end
					
					--leave water: do splash
					if data.speed > 0 and waterline < 0 and -waterline < data.speed then
						callScript(unitID, "Float_crossWaterline", {data.speed})
					end
				end
				
				data.y = data.y + data.speed --look ahead to next position
				if data.y > height then --next position is above ground?
					--detect when reached surface
					if data.surfacing and def.stopSpeedLeeway > math.abs(data.speed) and def.stopPositionLeeway > math.abs(data.y - def.floatPoint) then
						if not data.onSurface then
							callScript(unitID, "Float_stationaryOnSurface")
							data.onSurface = true
						end
					end
				else --next position is below ground/on the ground?
					Spring.SetUnitRulesParam(unitID, "disable_tac_ai", 0)
					Spring.GiveOrderToUnit(unitID,CMD.WAIT, {}, {})
					Spring.GiveOrderToUnit(unitID,CMD.WAIT, {}, {})
					callScript(unitID, "Float_stopOnFloor")
					removeFloat(unitID)
					
					i = i - 1 
				end
			end
			
			--Apply desired speed
			local dx,dy,dz = Spring.GetUnitVelocity(unitID)
			local dyCorrection = data.speed+gRAVITY-dy
			local headingInRadian = Spring.GetUnitHeading(unitID)*rAD_PER_ROT --get current heading
			Spring.SetUnitRotation(unitID, 0, -headingInRadian, 0) --restore current heading. This force unit to stay upright/prevent tumbling.TODO: remove negative sign if Spring no longer mirror input anymore 
			Spring.AddUnitImpulse(unitID, 0,-4,0) --Note: -4/+4 hax is for impulse capacitor  (Spring 91 only need -1/+1, Spring 94 require at least -4/+4). TODO: remove -4/+4 hax if no longer needed
			Spring.AddUnitImpulse(unitID, 0,4+dyCorrection,0)
			
			i = i + 1
		else
			removeFloat(unitID)
		end
	end
	
	if f%16 == 12 then
		aimWeapon = {}
	end
end

--------------------------------------------------------------------------------
-- Command Handling

local function FloatToggleCommand(unitID, cmdParams, cmdOptions)
	if floatState[unitID] then
		local state = cmdParams[1]
		local cmdDescID = Spring.FindUnitCmdDesc(unitID, CMD_UNIT_FLOAT_STATE)
		if cmdOptions.right then
			state = (state + 1)%3
		end
		if (cmdDescID) then
			Spring.EditUnitCmdDesc(unitID, cmdDescID, { params = {state, 'Sink','Attack','Float'}})
		end
		floatState[unitID] = state
		if state == FLOAT_ALWAYS then
			checkAlwaysFloat(unitID)
		end
	end
end

function gadget:AllowCommand_GetWantedCommand()	
	return {[CMD_UNIT_FLOAT_STATE] = true}
end

function gadget:AllowCommand_GetWantedUnitDefID()	
	return true
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if (cmdID ~= CMD_UNIT_FLOAT_STATE) then
		return true  -- command was not used
	end
	FloatToggleCommand(unitID, cmdParams, cmdOptions)  
	return false  -- command was used
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	if floatDefs[unitDefID] then
		floatState[unitID] = DEFAULT_FLOAT
		Spring.InsertUnitCmdDesc(unitID, unitFloatIdleBehaviour)
	end
end

function gadget:Initialize()
	-- register command
	gadgetHandler:RegisterCMDID(CMD_UNIT_FLOAT_STATE)
	-- load active units
	for _, unitID in ipairs(Spring.GetAllUnits()) do
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID)
	end
	
	GG.Floating_StopMoving = function(unitID) --real function. Note: we do this in gadget:Initialize() so that only gadget that actually run will initialize GG. with a correct function
		if floatState[unitID] == FLOAT_ALWAYS  then
			checkAlwaysFloat(unitID)
		end
	end
	
	GG.Floating_AimWeapon= function(unitID)
		if floatState[unitID] == FLOAT_ATTACK and not select(1, Spring.GetUnitIsStunned(unitID)) then
			local unitDefID = Spring.GetUnitDefID(unitID)
			local cQueue = Spring.GetCommandQueue(unitID, 1)
			local moving = cQueue and #cQueue > 0 and cQueue[1].id == CMD.MOVE and not cQueue[1].options.internal
			if not moving then
				addFloat(unitID, unitDefID)
			end
		end
		aimWeapon[unitID] = true
	end
	
	GG.Floating_UnitTeleported = function(unitID, position)
		if float[unitID] then
			local data = float[unitID]
			local def = floatDefs[data.unitDefID]
			data.x, data.y, data.z = position[1], position[2], position[3]
			--data.speed = 0.1
			local height = Spring.GetGroundHeight(data.x, data.z)
			if height <= def.depthRequirement then
				data.onSurface = false
				Spring.SetUnitPosition(unitID, data.x, data.y, data.z)
				return true
			else
				Spring.SetUnitRulesParam(unitID, "disable_tac_ai", 0)
				callScript(unitID, "script.StopMoving")
				removeFloat(unitID)
				return false
			end
		end
		return false
	end
end

---------------------------------------------------------------------
--Updates that prevent collision damage when surfacing

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, attackerID, attackerDefID, attackerTeam) --Note: argument list is based on Spring91 (compatibility with Spring 94 is maintained by gadget.lua). Copied from unit_fall_damage.lua by googlefrog
	-- unit or wreck collision. Prevent collision damage when surfacing (usefull when unit rise too fast and bump on another unit's bottom)
	if float[unitID] and (not float[unitID].onSurface) and (weaponDefID == -3 or weaponDefID == -1) and attackerID == nil then
		return math.random()  -- no collision damage. use random return so that unit_fall_damage.lua do not use pairs of zero to calculate collision damage.
	end
	return damage
end

---------------------------------------------------------------------
--Updates that check whether unit is flying

function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, attackerID, attackerDefID, attackerTeam)
	if floatDefs[unitDefID] and not float[unitID] then
		local _,dy = Spring.GetUnitVelocity(unitID)
		if dy>= fLY_THRESHOLD then
			addFloat(unitID, unitDefID, true)
		end
	end
	return damage
end