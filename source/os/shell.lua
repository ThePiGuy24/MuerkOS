-- if we're lucky, this will be a working shell some day

local gpu = component.getPrimary("gpu")
local x = 0

while true do
  --gpu.set(1, 1, tostring(x))
  --print(tostring(x))
  --status("Coro: "..tostring(x))
  coroutine.yield(0.05) -- used as delay
  x = x + 1
end