
-- https://pastebin.com/TFLLgAK5

History = {
  undo_log = {},
  redo_log = {},
  rewinding = false,
  redoing = false
}

History.__index = History

function History:new()
  local o = {}
  setmetatable(o, self)
  return o
end

function History:addToLog(action)
  if self.rewinding then
    return table.insert(self.redo_log, action)
  end
  if not self.redoing then
    self:clearRedoLog()
  end
  return table.insert(self.undo_log, action)
end

function History:clearRedoLog()
  self.redo_log = {}
end

function History:redo()
  local action
  action = table.remove(self.redo_log)
  if not action then
    error("Redo Log returned a nil action.")
  end
  return action
end

function History:undo()
  local action
  action = table.remove(self.undo_log)
  if not action then
    error("Undo Log returned a nil action.")
  end
  return action
end