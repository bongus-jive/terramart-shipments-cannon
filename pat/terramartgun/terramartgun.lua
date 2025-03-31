require "/scripts/util.lua"
require "/scripts/interp.lua"

GunFire = WeaponAbility:new()

function GunFire:init()
  for _, stance in pairs(self.stances) do
    if stance ~= self.stances.__base then
      setmetatable(stance, {__index = self.stances.__base})
    end
  end

  if animator.animationState("gun") ~= "ready" then
    animator.setAnimationState("gun", "reload")
  end

  self.weapon:setStance(self.stances.idle)
  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
end

function GunFire:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  animator.setGlobalTag("direction", mcontroller.facingDirection() == 1 and "R" or "L")

  if self.fireMode == (self.activatingFireMode or self.abilitySlot)
  and not self.weapon.currentAbility
  and animator.animationState("gun") == "ready"
  and status.overConsumeResource("energy", self:energyPerShot()) then
    self:setState(self.auto)
  end
end

function GunFire:auto()
  self.weapon:setStance(self.stances.fire)

  self:fireProjectile()
  self:muzzleFlash()

  if self.stances.fire.duration then
    util.wait(self.stances.fire.duration)
  end

  self:setState(self.cooldown)
end

function GunFire:cooldown()
  local stance1, stance2 = self.stances.cooldown, self.stances.idle
  self.weapon:setStance(stance1)

  local progress = 0
  util.wait(stance1.duration, function()
    self.weapon.weaponOffset = vec2.lerp(progress, stance1.weaponOffset or {0, 0}, stance2.weaponOffset or {0, 0})
    self.weapon.relativeWeaponRotation = util.toRadians(util.lerp(progress, stance1.weaponRotation, stance2.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(util.lerp(progress, stance1.armRotation, stance2.armRotation))
    progress = math.min(1, progress + (self.dt / stance1.duration))
  end)
end

function GunFire:muzzleFlash()
  animator.setPartTag("muzzleFlash", "variant", math.random(1, 3))
  animator.burstParticleEmitter("muzzleFlash")
  animator.playSound("fire")
end

function GunFire:fireProjectile()	
  local params = sb.jsonMerge(self.projectileParameters)
  params.power = self:damagePerShot()
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  world.spawnProjectile(self.projectileType, self:firePosition(), activeItem.ownerEntityId(), self:aimVector(), false, params)
end

function GunFire:firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset))
end

function GunFire:aimVector()
  local angle = self.weapon.aimAngle
  local dir = mcontroller.facingDirection()
  return {math.cos(angle) * dir, math.sin(angle)}
end

function GunFire:energyPerShot()
  return self.energyUsage * self.fireTime * (self.energyUsageMultiplier or 1.0)
end

function GunFire:damagePerShot()
  return (self.baseDamage or (self.baseDps * self.fireTime)) * (self.baseDamageMultiplier or 1.0) * config.getParameter("damageLevelMultiplier")
end

function GunFire:uninit() end
