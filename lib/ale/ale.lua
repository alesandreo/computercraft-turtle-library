-- https://pastebin.com/x1LfzQNz

-- This snippet taken from: https://stackoverflow.com/a/9146653/2161855
-- Uses regex to pull the package string apart for building out relative package requirements.
LibraryPath = (...):match("(.-)[^%.]+$")

require(LibraryPath .. 'mock.mock')
require(LibraryPath .. 'ar')
require(LibraryPath .. 'config')
require(LibraryPath .. 'logger')
require(LibraryPath .. 'turtle')
require(LibraryPath .. 'utils')