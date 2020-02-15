local gpu = component.getPrimary("gpu")
local w, h = gpu.getResolution()

print = function(text)
  gpu.copy(1, 2, w, h-1, 0, -1)
  gpu.fill(1, h, w, 1, " ")
  gpu.set(1, h, tostring(text))
end