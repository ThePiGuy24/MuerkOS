component.getPrimary = function(c) return component.proxy(component.list(c)()) end

__OSNAME = "MuerkOS" 
__OSVER  = "alph0002"
__OSDISK = computer.getBootAddress()

local gpu = component.getPrimary("gpu")
local fs = component.proxy(__OSDISK)

gpu.set(1, 1, "Booting " .. __OSNAME .. " " .. __OSVER .. "...")

if not fs.exists("/os/os.lua") then
  error("You broke it. (/os/os.lua does not exist)")
end

local osfile = fs.open("/os/os.lua")
local oscode = fs.read(osfile, math.huge)
fs.close(osfile)

load(oscode)()

error("Le os has Le stopped.")