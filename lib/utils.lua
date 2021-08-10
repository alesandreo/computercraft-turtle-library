function deleteTable(tab)
    for k, v in pairs(tab) do
        tab[k] = nil
    end
    tab = nil
end

function shallowcopytable(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
      copy = {}
      for orig_key, orig_value in pairs(orig) do
          copy[orig_key] = orig_value
      end
  else -- number, string, boolean, etc
      copy = orig
  end
  return copy
end