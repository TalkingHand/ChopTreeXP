-- Chop Tree XP
-- Grants XP for each 'ChopTree' anim event (= one axe hit on the tree) of the
-- automatic "Chop Tree" action (ISChopTreeAction).
--
-- Strength / Fitness = one burpee rep (Java Fitness.incStats):
--   burpees stiffness = legs, arms, chest (shared/Definitions/FitnessExercises.lua)
--   Strength = (arms 4 + chest 2) * xpMod 0.8 = 4.8
--   Fitness  = (legs 4)           * xpMod 0.8 = 3.2
-- Axe = tree health actually removed by this hit * AXE_XP_PER_TREE_DAMAGE,
-- so every axe gives the same Axe XP per tree. Java IsoTree.WeaponHit removes
-- weapon TreeDamage (x1.5 with a trait) from the tree health; measuring the
-- health before/after includes that bonus and the clamp on the final hit.
-- The coefficient is calibrated on the Fire Axe (Base.Axe): one zombie hit's
-- Axe:Strength ratio (XpUpdate.lua onWeaponHitXp: avg damage 1.4 * 0.9 = 1.26)
-- applied to the burpee Strength XP, per its TreeDamage 35, then halved.
--
-- Where this runs (see shared/TimedActions/ISChopTreeAction.lua):
--   animEvent's `if not isClient()` branch is the authoritative one:
--     - singleplayer: the local game (isClient()=false, isServer()=false)
--     - multiplayer:  the server, which emulates 'ChopTree' every 1500ms from
--                     ISChopTreeAction:serverStart() via emulateAnimEvent
--   The `else` branch (isClient()=true) only plays WeaponHitEffects.
-- We mirror that guard, so XP is granted exactly once per hit; addXp on the
-- server syncs to the owning client (same pattern as vanilla
-- ISHutchGrabEgg / ISGiveWaterToAnimal animEvent).

require "TimedActions/ISChopTreeAction"

ChopTreeXP = ChopTreeXP or {}

local function getOptions()
	local opts = SandboxVars and SandboxVars.ChopTreeXP or {}
	return {
		enableStrength = opts.EnableStrength ~= false,
		strengthMul = tonumber(opts.StrengthMultiplier) or 1,
		enableAxe = opts.EnableAxe ~= false,
		axeMul = tonumber(opts.AxeMultiplier) or 1,
		enableFitness = opts.EnableFitness ~= false,
	}
end

local function isAxeWeapon(item)
	local script = item and item.getScriptItem and item:getScriptItem()
	return script ~= nil and script:containsWeaponCategory(WeaponCategory.AXE)
end

local BURPEE_STRENGTH_XP = (4 + 2) * 0.8
local BURPEE_FITNESS_XP = 4 * 0.8
local AXE_XP_PER_TREE_DAMAGE = BURPEE_STRENGTH_XP * (1.4 * 0.9) / 35 * 0.5

function ChopTreeXP.grantHitXp(character, axe, treeDamage)
	if not character or not axe then return end
	local o = getOptions()

	if o.enableFitness then
		addXp(character, Perks.Fitness, BURPEE_FITNESS_XP)
	end

	if o.enableStrength and o.strengthMul > 0 then
		addXp(character, Perks.Strength, BURPEE_STRENGTH_XP * o.strengthMul)
	end

	if o.enableAxe and o.axeMul > 0 and treeDamage > 0 and isAxeWeapon(axe) then
		addXp(character, Perks.Axe, treeDamage * AXE_XP_PER_TREE_DAMAGE * o.axeMul)
	end
end

function ChopTreeXP.animEvent(self, event, parameter)
	-- Same condition as the vanilla authoritative branch (lines 66/68).
	local isHit = not isClient() and event == 'ChopTree' and self.axe ~= nil and self.tree ~= nil
	local healthBefore = isHit and self.tree:getHealth() or 0

	ChopTreeXP.originalAnimEvent(self, event, parameter)

	if isHit then
		local healthAfter = math.max(self.tree:getHealth(), 0)
		local treeDamage = math.max(healthBefore - healthAfter, 0)
		ChopTreeXP.grantHitXp(self.character, self.axe, treeDamage)
	end
end

-- Keep the vanilla function as the original even if this file is reloaded
-- (debug Lua reload): never capture one of our own wrappers as "original".
ChopTreeXP.wrappers = ChopTreeXP.wrappers or {}
if not ChopTreeXP.wrappers[ISChopTreeAction.animEvent] then
	ChopTreeXP.originalAnimEvent = ISChopTreeAction.animEvent
end
ChopTreeXP.wrappers[ChopTreeXP.animEvent] = true
ISChopTreeAction.animEvent = ChopTreeXP.animEvent
