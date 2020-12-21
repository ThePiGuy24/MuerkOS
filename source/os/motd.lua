local logo = {
  {0xFF, 0xE6, 0xF4, 0xFF, 0x80, 0xF4, 0x1F},
  {0xFF, 0x08, 0x01, 0xFF, 0xFF, 0x41, 0x00},
  {0xFF, 0x00, 0x00, 0xFF, 0x08, 0x3B, 0xE6},
}

local lines = {}
local textLines = {
  __OSNAME .. " " .. __OSVER,
  "Booted in " .. computer.uptime() .. " seconds",
  "" .. math.floor(computer.freeMemory()/1024) .. "k free of " .. math.floor(computer.totalMemory()/1024) .. "k",
}

local gpu = component.getPrimary("gpu")
local w, h = gpu.getResolution()

print("")
for i=1, 3 do
  lines[i] = "  "
  for j=1, 7 do
    lines[i] = lines[i] .. unicode.char(0x2800 + logo[i][j])
  end
  print(lines[i] .. "  " .. textLines[i])
end
print(string.rep("_", w))