#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/strformat
# External dependencies
import pkg/flatty/binny
# ndk dependencies
import ./paths
# ngltf dependencies
import ./binary


#_______________________________________
proc header *(input :string|Path) :Header=
  ## Returns the header of the given input
  ## Raises an exception if the path doesn't exist or it has an insufficient length
  if input.len < HeaderSize: raise newException(ImportError, &"Tried to read a glTF header from {input.string}, but it has an insufficient length of {input.len}.")
  elif not input.isFile():   raise newException(ImportError, &"Tried to read a glTF header from {input.string}, but the file does not exist.")
  let data       = input.readFile()
  result.magic   = data.readUint32(0)
  result.version = data.readUint32(4)
  result.length  = data.readUint32(8)

