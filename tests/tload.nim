#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/unittest
import std/os
import std/strformat
# Library dependencies
import ngltf as gltf
import ngltf/load/data

#_______________________________________
# Config
const resDir = currentSourcePath().parentDir()/"res"
#_____________________________


#_______________________________________
const bottleFile = resDir/"bottle/bottle.gltf"
test &"loadFile {bottleFile}":
  let mdl = data.load(bottleFile, ModelData, verbose=true)
#_______________________________________
const spheresFile = resDir/"mrSpheres/MetalRoughSpheres.gltf"
# test &"loadFile {spheresFile}":
#   let mdl = gltf.load(spheresFile, verbose=true)

