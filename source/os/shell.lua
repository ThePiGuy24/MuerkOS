-- if we're lucky, this will be a working shell some day

local gpu = component.getPrimary("gpu")
local inputbuffer = ""
local cursorchar = "_"

coroutine.yield(0) -- used as delay, and to do event shit
gpu.set(1,h,"> "..inputbuffer.."_"..string.rep(" ",w))
while true do
  if computer.uptime() % 1 < 0.5 then
    cursorchar = "_"
  else
    cursorchar = " "
  end
  local lk = epull({"key_down","clipboard"})
  if lk ~= nil then
    local inkey = nil
    --print(table.unpack(lk))
    if lk[3] == "key_down" then
      inkey = string.char(lk[5])
    elseif lk[3] == "clipboard" then
      inkey = lk[5]
    end
    if inkey == "\b" then
      inputbuffer = unicode.sub(inputbuffer,1,-2)
    elseif inkey == "\r" then
      print("> "..inputbuffer..string.rep(" ",w))
      if #inputbuffer > 0 then
        --sproc(load(inputbuffer), inputbuffer)
        local r, e = system(inputbuffer) -- fucking bodgy as shit and will die is probably many cases, fix later
        if not r then
          print(e)
        end
      end
      inputbuffer = ""
    elseif inkey == "\n" then
    else
      inputbuffer = inputbuffer .. inkey
    end
  end
  gpu.set(1,h,"> "..inputbuffer..cursorchar..string.rep(" ",w))
  coroutine.yield(0) -- used as delay, and to do event shit
end

