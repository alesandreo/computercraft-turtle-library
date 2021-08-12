-- https://pastebin.com/LJnVWtiw

Mock = {}
Mock.__index = Mock
  function Mock.Return_true()
    return true
  end
  function Mock.Return_false()
    return false
  end
  function Mock.Return_int()
    return math.random(0, 10)
  end
  function Mock.Return_false_inspect()
    local inspects = {
      {
        name = "minecraft:dirt",
        tags = {}
      },
      {
        name = "minecraft:oak_log",
        tags = {}
      }
    }
    return true, inspects[math.random(1, #inspects)]
  end
  function Mock.Return_false_item()
    return {
      name = "minecraft:dirt",
      count = math.random(1,64)
    }
  end
if turtle == nil then
  turtle = {
    forward = Mock.Return_true,
    back = Mock.Return_true,
    up = Mock.Return_true,
    down = Mock.Return_true,
    turnLeft = Mock.Return_true,
    turnRight = Mock.Return_true,
    dig = Mock.Return_true,
    detect = Mock.Return_false,
    digUp = Mock.Return_true,
    placeUp = Mock.Return_true,
    placeDown = Mock.Return_true,
    place = Mock.Return_true,
    digDown = Mock.Return_true,
    detectUp = Mock.Return_false,
    detectDown = Mock.Return_false,
    select = Mock.Return_true,
    getItemSpace = Mock.Return_int,
    inspect = Mock.Return_false_inspect,
    inspectUp = Mock.Return_false_inspect,
    inspectDown = Mock.Return_false_inspect,
    getItemDetail = Mock.Return_false_item,
  }
end
if not os.sleep then
  os.sleep = Mock.Return_true
end