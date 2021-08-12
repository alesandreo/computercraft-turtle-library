--
-- Created by IntelliJ IDEA.
-- User: amcco
-- Date: 4/2/2020
-- Time: 11:03 PM
-- To change this template use File | Settings | File Templates.
--
if not textutils then
  require('lib.ale.mock.textutils')
end
require('lib.ale.ale')
-- conf = Config:new('configs/turtle.position')
-- if conf:load() then
--   print(textutils.serialize(conf.data))
-- end


T = Miner:new()
T:back()
print(T.position:toString())
-- conf.data = T.position
-- conf:save()
-- if conf:load() then
--   print(textutils.serialize(conf.data))
-- end