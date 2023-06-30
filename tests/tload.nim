#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/unittest
import std/os
import std/paths
import std/strformat
# Library dependencies
import ngltf as gltf

#_______________________________________
# Config
const resDir = currentSourcePath().parentDir()/"res"
#_____________________________


#_______________________________________
const bottleFile = resDir/"bottle/bottle.gltf"
test &"loadFile {bottleFile}":
  check 5+5 == 10
  let mdl = gltf.load(bottleFile, verbose=true)

