require "/pat/terramartgun/projectiles/debris.lua"

local offsets = { {0, 0}, {-1, 0}, {1, 0} }

function destroy()
  local seed = config.getParameter("seedType")
  if not seed then return end
  
  local pos = entity.position()
  local dir = math.random(0, 1) == 0 and -1 or 1
  local params = config.getParameter("seedParameters")

  for _, offset in pairs(offsets) do
    local p = {pos[1] + offset[1], pos[2] + offset[2]}
    if world.placeObject(seed, p, dir, params) then
      break
    end
  end
end
