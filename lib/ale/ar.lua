-- https://pastebin.com/vr5qBvMP
-- AR Functions to come.
ARGlasses = {}
ARGlasses.__index = ARGlasses

function ARGlasses:new(x, y)
  local o = {}
  setmetatable(o, Position)
  o.ar = peripheral.find("arController")
  if o.ar then
    o.ar.setRelativeMode(true, x, y)
    return o
  else
    return nil
  end
end

function ARGlasses:clear()
  self.ar.clear()
end

function ARGlasses:drawUI()

end
