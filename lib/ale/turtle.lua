-- https://pastebin.com/mZYfaWLA

if not LibraryPath then
  error("LibraryPath not set.")
end

require(LibraryPath .. 'turtle.position')
require(LibraryPath .. "turtle.history")
require(LibraryPath .. "turtle.blocklist")
require(LibraryPath .. "turtle.inventory")
require(LibraryPath .. 'turtle.turtle')
require(LibraryPath .. 'turtle.miner')