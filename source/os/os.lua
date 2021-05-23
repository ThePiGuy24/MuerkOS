local fs = component.proxy(__OSDISK)
computer.pushSignal("boot_start", computer.uptime())
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

isin = function(ite, tab)
  --info("isin")
  if type(tab) ~= "table" then
    --print("isnill")
    return nil
  end
  for _,itte in ipairs(tab) do
    --print(itte, ite)
    if itte == ite then
      return true
    end
  end
  --info("isnie")
  return false
end

local gpu = component.getPrimary("gpu")
w, h = gpu.getResolution()

local eventlimit = 256
local eventstack = {}
local eventid = 0

epull = function(etype, clearevent)
  --info("epull")
  local re = nil
  if clearevent == nil then
    clearevent = true
  end
  if #eventstack > 0 then
    if etype == nil then
      re = eventstack[1]
      if clearevent then
        for te = 1, #eventstack - 1 do
          eventstack[te] = eventstack[te + 1]
        end
        eventstack[#eventstack] = nil
      end
    else
      if type(etype) ~= "table" then
        etype = {etype}
      end
      for te = 1, #eventstack do
        if isin(eventstack[te][3], etype) then
          re = eventstack[te]
          if clearevent then
            for te2 = te, #eventstack - 1 do
              eventstack[te2] = eventstack[te2 + 1]
            end
            eventstack[#eventstack] = nil
          end
          break
        end
      end
    end
  end
  return re
end

epush = function(ev)
  --info("epush")
  eventstack[#eventstack+1] = {eventid, computer.uptime(), table.unpack(ev)}
  if #eventstack > eventlimit then
    for te = 0, eventlimit - 1 do
      eventstack[eventlimit-te] = eventstack[#eventstack-te]
    end
  end
  eventid = eventid + 1
end

--gpu.fill(1, 1, w, h, " ")
require("printlib")
fslib = require("fslib")

procs = {}
cpid = 0
sproc = function(func, procname)
  cpid = cpid + 1
  procs[cpid] = {coroutine.create(func), computer.uptime(), 0, procname}
  return cpid
end

info("Loading Shell")

local shell = load(fslib.readfile(fs, "/os/shell.lua"),"/os/shell.lua")
--error("creating coro")

sproc(shell, "shell")
--procs[1] = {coroutine.create(shell), computer.uptime(), 1, "shell"} -- {proc coro, time last yielded, requested delay, name}
--coros, coror = coroutine.resume(procs[1][1])
--if coros then
--  procs[1][3] = tonumber(coror or 0)
--  procs[1][2] = computer.uptime()
--end

local fut = 0
local cut = 0

info("Finished booting in "..computer.uptime().." seconds")
info(math.floor(computer.freeMemory()) .. "Bytes free of " .. math.floor(computer.totalMemory()) .. "Bytes")

--print("This look like it does nothing, but it actually is doing something,\njust not enough to call it a proper OS yet.")

system("/os/motd.lua")
--print("")

computer.pushSignal("boot_finish", computer.uptime())
while true do
  --w, h = gpu.getResolution()
  local e = {computer.pullSignal(0)}
  if #e > 0 then
    epush(e)
  end
  for procpid, proc in pairs(procs) do
    if (proc[2] or computer.uptime()) + (proc[3] or 0) <= computer.uptime() then
      local succ, coros, coror = false, false, nil
      procs[procpid][2] = computer.uptime()
      succ, coros, coror = pcall(coroutine.resume, proc[1])
      if not succ then
        error(coros)
      end
      if coros then
        procs[procpid][3] = tonumber(coror or 0)
        --procs[procpid][2] = computer.uptime()
      end
    end
    --print(procs[procpid][1],procs[procpid][2],procs[procpid][3])
    --print(type(procs[procpid][1]),type(procs[procpid][2]),type(procs[procpid][3]))
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