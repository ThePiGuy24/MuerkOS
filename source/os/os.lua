local fs = component.proxy(__OSDISK)

require = function(module)
  if not fs.exists("/os/lib/" .. module .. ".lua") then -- improve this later maybe
    return nil
  end
  modfile = fs.open("/os/lib/" .. module .. ".lua")
  module = load(fs.read(modfile, math.huge))
  fs.close(modfile)
  return module()
end

local gpu = component.getPrimary("gpu")
local w, h = gpu.getResolution()

--local print = function(text)
--  gpu.copy(1, 2, w, h-1, 0, -1)
--  gpu.fill(1, h, w, 1, " ")
--  gpu.set(1, h, tostring(text))
--end

require("printlib")

print("Successfully booted in " .. computer.uptime() .. " seconds")
print("From " .. __OSDISK)

while true do
  computer.pullSignal(1)
end