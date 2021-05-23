component.getPrimary = function(c) return component.proxy(component.list(c)()) end

__OSNAME = "MuerkOS" 
__OSVER  = "alph0004"
if computer.getBootAddress then
  __OSDISK = computer.getBootAddress()
else
  __OSDISK = component.getPrimary("filesystem")
end

local gpu = component.getPrimary("gpu")
local fs = component.proxy(__OSDISK)
local w, h = gpu.getResolution()
gpu.fill(1, 1, w, h, " ")

__ERRFILE = fs.open("err.log", "w")
fs.write(__ERRFILE, "Start of error/info/status log.\n")
fs.close(__ERRFILE)
__ERRFILE = fs.open("err.log", "a")

local logmode = 3 -- 0 = none, 1 = errors only, 2 = errors and info, 3 = errors, info and status

--gpu.set(1, 1, "Booting " .. __OSNAME .. " " .. __OSVER .. "...")

local print = function(text) -- basic print
  gpu.fill(1, h, w, 1, " ")
  gpu.set(1, h, tostring(text))
  gpu.copy(1, 2, w, h-1, 0, -1)
  gpu.fill(1, h, w, 1, " ")
end

oc_error = error

newerror = function(err, nohold)
  local errstr = "[ERROR]: "..tostring(err).."\n"..tostring(debug.traceback())
  print(errstr)
  if logmode > 0 then
    fs.write(__ERRFILE, errstr.."\n")
    fs.close(__ERRFILE)
    __ERRFILE = fs.open("err.log", "a")
  end
  if not nohold then
    print("Press any key to continue...")
    while computer.pullSignal() ~= "key_down" do end
  end
end

info = function(info)
  local infostr = "[INFO]: "..tostring(info)
  print(infostr)
  if logmode > 1 then
    fs.write(__ERRFILE, infostr.."\n")
    fs.close(__ERRFILE)
    __ERRFILE = fs.open("err.log", "a")
  end
end

status = function(stat)
  local statstr = "[STATUS]: "..tostring(stat)
  print(statstr)
  if logmode > 2 then
    fs.write(__ERRFILE, statstr.."\n")
    fs.close(__ERRFILE)
    __ERRFILE = fs.open("err.log", "a")
  end
end

error = function(err, nohold)
  if not pcall(newerror, nohold) then
    oc_error(err)
  end
end

info("Booting " .. __OSNAME .. " " .. __OSVER .. "...")

if not fs.exists("/os/os.lua") then
  error("You broke it. (/os/os.lua does not exist)")
end

local osfile = fs.open("/os/os.lua")
local oscode = ""
local chunk
repeat -- thanks ocawesome :p
  chunk = fs.read(osfile, math.huge)
  oscode = oscode .. (chunk or "")
until not chunk
fs.close(osfile)

info("Loaded OS data")
--while computer.pullSignal() ~= "key_down" do end

xpcall(load(oscode, "/os/os.lua"), function(err)
  error("/os/os.lua failed\n"..err)
end)

--while computer.pullSignal() ~= "key_down" do end

error("End of init.lua (this shouldn't happen)")