-- https://pastebin.com/w0T3h4a8

-- This library built based on comments here: http://www.computercraft.info/forums2/index.php?/topic/5128-lua-solved-saving-data/
-- By: http://www.computercraft.info/forums2/index.php?/user/88-noodle/

if textutils then
  Config = {}
  Config.__index = Config
  function Config:new(filename)
    local config = {}
    setmetatable(config, Config)
    config.filename = filename
    config.configuration = {}
    return data
  end

  function Config:load()
    local file_handle = io.open(self.filename, 'r')
    if not file_handle then
      error("Config "..self.filename.." did not exist.")
    end
    local str = file_handle.readAll()
    Config.data = textutils.unserialize(str)
    return true
  end

  function Config:save()
    local h = fs.open(self.filename, 'w')
    local str = textutils.serialize(self.data)
    h.write(str)
    h.close()
  end

end

