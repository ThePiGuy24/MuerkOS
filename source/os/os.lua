local fs = component.proxy(__OSDISK)
--oc_error = error

--while computer.pullSignal() ~= "key_down" do end

--[[newerror = function(err)
  local errstr = "[ERROR]: "..tostring(err).."\n"..tostring(debug.traceback())
  print(errstr)
  print("Press any key to continue...")
  fs.write(__ERRFILE, errstr.."\n")
  while computer.pullSignal() ~= "key_down" do end
end

status = function(stat)
  local statstr = "[STATUS]: "..tostring(stat))
  print(statstr)
  fs.write(__ERRFILE, statstr.."\n")
end]]--

require = function(module)
  if not fs.exists("/os/lib/" .. module .. ".lua") then -- improve this later maybe
    return nil
  end
  modfile = fs.open("/os/lib/" .. module .. ".lua")
  module = load(fs.read(modfile, math.huge), "/os/lib/" .. module .. ".lua")
  fs.close(modfile)
  return module()
end

system = function(executable)
  if not fs.exists(executable) then
    return false, "file not found"
  end
  execfile = fs.open(executable)
  local succ, err = xpcall(load(fs.read(execfile, math.huge), executable), function(err) return err end)
  fs.close(execfile)
  return succ, err
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
fslib = require("fslib")

--status("Start of error/status log")

system("/os/motd.lua")

print("")

info("Loading Shell")

--local shellfile = fs.open("/os/shell.lua")
--local shell = load(fslib.readall(shellfile, math.huge))
--fs.close(shellfile)
local shell = load(fslib.readfile(fs, "/os/shell.lua"),"/os/shell.lua")
ttys = {}
--error("creating coro")

local coros, coror = false, nil

ttys[1] = {coroutine.create(shell), computer.uptime(), 1} -- {thread object, time last yielded, requested delay}
coros, coror = coroutine.resume(ttys[1][1])
if coros then
  ttys[1][3] = tonumber(coror or 0)
  ttys[1][2] = computer.uptime()
end

local fut = 0
local cut = 0

info("Finished booting in "..computer.uptime().." seconds")
info(math.floor(computer.freeMemory()) .. "Bytes free of " .. math.floor(computer.totalMemory()) .. "Bytes")

print("This look like it does nothing, but it actually is doing something,\njust not enough to call it a proper OS yet.")

while true do
  computer.pullSignal(0)
  for ttyi, tty in ipairs(ttys) do
    if (tty[2] or computer.uptime()) + (tty[3] or 0) <= computer.uptime() then
      coros, coror = false, nil
      ttys[ttyi][2] = computer.uptime()
      coros, coror = coroutine.resume(tty[1])
      if coros then
        ttys[ttyi][3] = tonumber(coror or 0)
        --ttys[ttyi][2] = computer.uptime()
      end
    end
    --print(ttys[ttyi][1],ttys[ttyi][2],ttys[ttyi][3])
    --print(type(ttys[ttyi][1]),type(ttys[ttyi][2]),type(ttys[ttyi][3]))
  end
  --gpu.fill(1, h, w, 1, " ")
  --gpu.set(1, h, "Uptime: " .. math.floor(computer.uptime()))
  cut = math.floor(computer.uptime())
  if cut > fut then
    --status("Uptime: " .. cut)
    fut = cut
  end
  --print("Uptime: " .. math.floor(computer.uptime()))
end