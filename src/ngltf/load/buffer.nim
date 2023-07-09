#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/json as stdjson
# ngltf dependencies
import ../types/base
import ../types/buffer
import ../validate
import ./base


#_______________________________________
func get *(json :JsonNode; _:typedesc[Buffers]) :Buffers=
  ## Gets the Buffers data from the given json node.
  ## Raises an exception if any of the elements is missing the byteLength field (required by spec)
  for buffer in json["buffers"].elems:
    # Validate the fields required to exist by spec
    if not buffer.hasByteLength: raise newException(ImportError, "Tried to get Buffer data from a node that doesn't have a byteLength field (required by spec).")
    # Get the data for the current Buffer
    var tmp :Buffer
    if buffer.hasURI: tmp.uri = buffer["uri"].getStr()
    tmp.byteLength = buffer["byteLength"].getInt.uint32
    if buffer.hasName:    tmp.name       = buffer["name"].getStr()
    if buffer.hasExtJson: tmp.extensions = buffer.get(Extension)
    if buffer.hasExtras:  tmp.extras     = buffer.get(Extras)
    result.add tmp
#_______________________________________
func get *(json :JsonNode; _:typedesc[BufferViews]) :BufferViews=
  ## Gets the BufferViews data from the given json node.
  ## Raises an exception if any of the elements is missing the buffer field (required by spec)
  for view in json["bufferViews"]:
    # Validate the fields required to exist by spec
    if not view.hasBuffer:     raise newException(ImportError, "Tried to get BufferView data from a node that doesn't have a buffer field (required by spec).")
    if not view.hasByteLength: raise newException(ImportError, "Tried to get BufferView data from a node that doesn't have a byteLength field (required by spec).")
    # Get the data for the current BufferView
    var tmp :BufferView
    tmp.buffer = view["buffer"].getInt.GltfId
    if view.hasByteOffset:  tmp.byteOffset = view["byteOffset"].getInt.uint32
    tmp.byteLength = view["byteLength"].getInt.uint32
    if view.hasByteStride:  tmp.byteStride = view["byteStride"].getInt.uint32
    if view.hasTarget:      tmp.target     = view["target"].getInt.BufferViewTarget
    if view.hasName:        tmp.name       = view["name"].getStr()
    if view.hasExtJson:     tmp.extensions = view.get(Extension)
    if view.hasExtras:      tmp.extras     = view.get(Extras)
    result.add tmp

