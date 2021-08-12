-- https://pastebin.com/w0T3h4a8

-- This library built based on comments here: http://www.computercraft.info/forums2/index.php?/topic/5128-lua-solved-saving-data/
-- By: http://www.computercraft.info/forums2/index.php?/user/88-noodle/

Config = {}
Config.__index = Config
function Config:new(filename)
  local config = {}
  setmetatable(config, Config)
  config.filename = filename
  config.data = {}
  return config
end

function Config:load()
  local file_handle = io.open(self.filename, 'r')
  if not file_handle then
    return false
  end
  local str = file_handle:read("*all")
  self.data = textutils.unserialize(str)
  return true
end

function Config:save()
  local file_handle = io.open(self.filename, 'w')
  local str = textutils.serialize(self.data)
  file_handle:write(str)
  file_handle:close()
end


