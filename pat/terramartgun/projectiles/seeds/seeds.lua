require "/pat/terramartgun/projectiles/debris/debris.lua"

function destroy()
  local seed = config.getParameter("seedType")
  if seed then
    local pos = entity.position()
    local dir = math.random(0, 1) == 0 and -1 or 1
    local params = config.getParameter("seedParameters")

    world.placeObject(seed, pos, dir, params)
  end
end
