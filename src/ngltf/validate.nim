#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/os
import std/strformat
import std/strutils
import std/json as stdjson
# External dependencies
import nmath
# ndk dependencies
import ./paths
# ngltf dependencies
import ./types
import ./binary

#_________________________________________________
proc header *(input :string|Path) :bool=
  ## Validates that the input string or path contains a valid glTF file header.
  if input.len < HeaderSize: return false
  let header = binary.header(input)
  result =
    header.magic == Magic and
    header.version == Version and
    header.length > 0
#_________________________________________________
proc json *(input :string) :bool=
  let root = input.parseJson
  result =
    root.hasKey("asset") and
    root["asset"].hasKey("version") and
    root["asset"]["version"].getStr.parseFloat() == Version.float

#_________________________________________________
proc isGLTF *(input :string|Path) :bool=
  ## Returns true if the input passes all checks for being a valid glTF file
  if input.fileExists():
    let ext = input.splitFile.ext
    case ext
    of ".glb":  return validate.header(input.readFile)
    of ".gltf": return validate.json(input.readFile)
    else: raise newException(ImportError, &"Tried to read file {input.string}, but {ext} it is not a valid glTF extension.")
  return validate.header(input)

