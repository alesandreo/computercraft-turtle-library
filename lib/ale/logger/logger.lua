Logger = {
    levels = {
    fatal = 0,
    error = 10,
    warn  = 20,
    info  = 30,
    debug = 40,
    trace = 50
  },
  categories = {
    log = "info"
  },
  default_category = "log",
  logfile = nil
}

function Logger:getIntLevel(level)
  level = string.lower(level)
  return self.levels[level]
end

function Logger:getCategoryLevel(category)
  return self.categories[category] or self.categories[self.default_category]
end

function Logger:log(message, level, category)
  level = level or "info"
  category = category or self.default_category
  if self:getIntLevel(level) <= self:getIntLevel(self:getCategoryLevel(category)) then
    if not self.logfile then
      print(string.upper(level)..": "..message)
    end
  end
  return true
end

function Logger:trace(message, category)
  category = category or self.default_category
  return self:log(message, "TRACE", category)
end

function Logger:info(message, category)
  category = category or self.default_category
  return self:log(message, "INFO", category)
end