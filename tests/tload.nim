#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/unittest
import std/os
import std/strformat
# n*gltf dependencies
import ngltf

#_______________________________________
# Config
const resDir = currentSourcePath().parentDir()/"res"
#_____________________________


#_______________________________________
const bottleFile = resDir/"bottle/bottle.gltf"
test &"loadFile {bottleFile}":
  let gltf = ngltf.load(bottleFile)
#_______________________________________
const spheresFile = resDir/"mrSpheres/MetalRoughSpheres.gltf"
test &"loadFile {spheresFile}":
  let gltf = ngltf.load(spheresFile)

