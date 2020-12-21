local fslib = {}

function fslib.readall(disk, fileno, yield)
  local ddata = ""
  local ldisk
  if type(disk) == "string" then
    ldisk = component.proxy(disk)
  else
    ldisk = disk
  end
  repeat
    local chunk = ldisk.read(fileno, math.huge)
    ddata = ddata .. (chunk or "")
    if yield then
      computer.pushSignal(computer.pullSignal())
    end
  until not chunk
  return ddata
end

function fslib.readfile(disk, filename)
  local ldisk
  if type(disk) == "string" then
    ldisk = component.proxy(disk)
  else
    ldisk = disk
  end
  local lfile = ldisk.open(filename, "r")
  local ldata = fslib.readall(ldisk, lfile, true)
  ldisk.close(lfile)
  return ldata
end

return fslib