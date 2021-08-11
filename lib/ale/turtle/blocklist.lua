-- https://pastebin.com/tnXQrtpQ

BlockList = {}
BlockList.__index = BlockList

function BlockList:new()
  local o = {}
  setmetatable(o, BlockList)
  o.blocks = {}
  o.tags = {}
  return o
end

function BlockList:addBlock(block_name)
  self.blocks[block_name] = true
end

function BlockList:removeBlock(block_name)
  self.blocks[block_name] = nil
end

function BlockList:addTag(tag)
  self.tags[tag] = true
end

function BlockList:removeTag(tag)
  self.tags[tag] = nil
end

function BlockList: checkBlockName(block_name)
  return self.blocks[block_name]
end

function BlockList:checkBlockTag(block_tag)
  return self.tags[block_tag]
end

function BlockList:checkBlockTags(block_data)
  if not block_data.tags then
    return false
  end
  for k, tag in ipairs(block_data.tags) do
    if  self:checkBlockTag(tag) then
      return true
    end
  end
  return false
end

function BlockList:checkBlock(block_data)
  local block_name
  block_name = block_data.name
  return (self:checkBlockName(block_name) or self:checkBlockTags(block_data))
end