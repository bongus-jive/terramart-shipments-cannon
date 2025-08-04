function init()
  self.rotationSpeed = config.getParameter("rotationSpeed", 20)
  mcontroller.setRotation(math.random() * math.pi * 2)

  local variance = config.getParameter("rotationVariance")
  if variance then
    self.rotationSpeed = sb.nrand(variance, self.rotationSpeed)
  end

  if math.random(2) == 2 then self.rotationSpeed = -self.rotationSpeed end

  local ttlRange = config.getParameter("timeToLiveRange")
  if ttlRange then
    local ttl = ttlRange[1] + (math.random() * (ttlRange[2] - ttlRange[1]))
    projectile.setTimeToLive(ttl)
  end
end

function update(dt)
  local vel = mcontroller.velocity()
  local dir = vel[1] > 0 and 1 or -1
  
  local mag = math.sqrt(vel[1] * vel[1] + vel[2] * vel[2])
  local rot = (mag / 180 * math.pi) * -dir * dt * self.rotationSpeed
  mcontroller.setRotation(mcontroller.rotation() + rot)
end
