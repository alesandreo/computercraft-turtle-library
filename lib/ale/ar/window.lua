
ARWindow = {
  pos_x = 0,
  pos_y = 0,
  size_x = 0,
  size_y = 0,
  pos_b_x = 0,
  pos_b_y = 0,
  ar = nil,
  bgColor = 0x000000,
  fgColor = 0xFFFFFF,
}
ARWindow.__index = ARWindow

function ARWindow:new(ar, pos_x, pos_y, size_x, size_y, bgColor, fgColor)
  bgColor = bgColor or 0x000000
  fgColor = fgColor or 0xFFFFFF
  local ar_window = {}
  setmetatable(ar_window, ARWindow)
  ar_window.ar = ar
  ar_window.pos_x = pos_x or 0
  ar_window.pos_y = pos_y or 0
  ar_window.size_x = size_x or 0
  ar_window.size_y = size_y or 0
  ar_window.pos_b_x = ar_window.pos_x + ar_window.size_x
  ar_window.pos_b_y = ar_window.pos_y + ar_window.size_y
  ar_window.bgColor = bgColor
  ar_window.fgColor = fgColor
  return ar_window
end

function ARWindow:draw()
  self.ar.fill(self.pos_x, self.pos_y, self.pos_b_x, self.pos_b_y, self.bgColor)
end
