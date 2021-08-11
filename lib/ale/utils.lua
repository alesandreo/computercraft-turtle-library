-- https://pastebin.com/PEVfiaAa

function GetFilePath(path)
  local directory, filename, extension = string.match(path, "(.-)([^\\/]-%.?([^%.\\/]*))$")
  return {
      path = directory,
      file = filename,
      ext = extension,
      full_path = directory..filename
  }
end

function DeleteTable(table)
for k, v in pairs(table) do
  if type(v) == 'table' then
    DeleteTable(v)
  end
  table[k] = nil
end
table = nil
return true
end