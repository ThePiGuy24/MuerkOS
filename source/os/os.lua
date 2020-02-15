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

system = function(executable)
  if not fs.exists(executable) then
    return false
  end
  execfile = fs.open(executable)
  load(fs.read(execfile, math.huge))()
  fs.close(execfile)
  return true
end

local gpu = component.getPrimary("gpu")
local w, h = gpu.getResolution()

--local print = function(text)
--  gpu.copy(1, 2, w, h-1, 0, -1)
--  gpu.fill(1, h, w, 1, " ")
--  gpu.set(1, h, tostring(text))
--end

gpu.fill(1, 1, w, h, " ")
require("printlib")
system("/os/motd.lua")

print("")

while true do
  computer.pullSignal(0.001)
  gpu.fill(1, h, w, 1, " ")
  gpu.set(1, h, "Uptime: " .. math.floor(computer.uptime()))
end