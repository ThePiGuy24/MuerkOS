local gpu = component.getPrimary("gpu")
local w, h = gpu.getResolution()

local pvars = {}

local rprint = function(...)
  local out = ""
  for i,seg in ipairs(pvars) do
    out = out .. tostring(seg) .. " "
  end
  for line in string.gmatch(out, "[^\n]+") do
    gpu.copy(1, 2, w, h-1, 0, -1)
    gpu.fill(1, h, w, 1, " ")
    local tstring = string.gsub(line,"\t","  ")
    gpu.set(1, h, tstring)
  end
end

print = function(...)
  pvars = {...}
  xpcall(rprint, function(err) error(debug.traceback()) end)
end