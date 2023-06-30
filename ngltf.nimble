#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
import std/os
import std/strformat

#_____________________________
# Package
packageName   = "ngltf"
version       = "0.0.0"
author        = "sOkam"
description   = "GLTF for Nim"
license       = "MIT"


#_____________________________
# Build Requirements
requires "nim >= 1.6.12"
requires "jsony"
requires "flatty"
requires "https://github.com/heysokam/nmath"


#_____________________________
# Folders
srcDir         = "src"
binDir         = "bin"
let cacheDir   = binDir/"nimcache"
let genDir     = "gen"
let refDir     = "ref"
let gltfDir    = refDir/"gltf"
let specDir    = gltfDir/"specification"
let schemaDir  = specDir/"2.0"/"schema"
let schemaTrg  = genDir/"schema"
let schemaFile = schemaDir/"glTF.schema.json"
let j2nim      = binDir/"j2nim"
let j2nimSrc   = srcDir/packageName/"j2nim"


#_______________________________________
# Tasks
#_____________________________
# Configuration
let verbose   = on

#_____________________________
# Helpers
proc compile (src :string; verb=verbose) :void=
  let cmd = &"nimble c --outDir:{binDir} --nimcache:{cacheDir} {j2nimSrc}"
  if verb: echo cmd
  exec cmd

#_____________________________
# File Generation
task gen, "Internal: Generates the gltf Json objects from the downloaded schema.":
  if not refDir.dirExists():
    refDir.mkDir()
    writeFile( refDir/".gitignore", "*\n" )
  if not gltfDir.dirExists: exec &"git clone https://github.com/KhronosGroup/glTF {gltfDir}"
  cpDir schemaDir, schemaTrg
  compile j2nimSrc
  exec &"{j2nim.absolutePath()} \"{schemaFile}\""

