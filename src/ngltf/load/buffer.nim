#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# std dependencies
import std/os
import std/strutils
import std/strformat
import std/json as stdjson
import std/base64
import std/mimetypes
# ngltf dependencies
import ../types/base
import ../types/buffer
import ../tool/paths
import ../validate
import ./base


#_______________________________________
# Binary Data
#_____________________________
proc get *(buf :Buffer; _:typedesc[ByteBuffer]; dir :Path; chunk = ByteBuffer()) :ByteBuffer=
  ## Returns the ByteBuffer of the given `buf` buffer.
  ## Searches for its binary data file relative to `dir` when relevant.
  new result
  # Get the data from the base64 URI
  if buf.uri.isData():
    let split       = buf.uri.string.split(";base64,")
    result.mimetype = split[0].replace("data:", "")
    result.bytes    = base64.decode( split[1] )
  # Get the data from the file pointed by the URI
  elif buf.uri.isFile():
    if not fileExists( dir/buf.uri.Path ): raise newException(ImportError, &"Tried to load Buffer data from {string(dir/buf.uri.Path)}, but the file does not exist.")
    result.mimetype = newMimetypes().getMimetype( paths.splitFile(buf.uri.Path).ext )
    result.bytes    = readFile( dir/buf.uri.Path )
  # Get the buffer data from the given binary chunks data.
  elif buf.uri.isChunk():
    if chunk.bytes.len < buf.byteLength.int: raise newException(ImportError, &"Tried to load Buffer data from:  {buf.uri.string}  but the length of the given chunk ({chunk.bytes.len}) is less than the length declared in the buffer ({buf.byteLength}).")
    result.mimetype = MimetypeGLB
    result.bytes    = chunk.bytes[ 0..<buf.byteLength ]
  else: raise newException(ImportError, &"Tried to load Buffer data from:  {buf.uri.string}  but the input has an unknown or invalid URI format.")
  validate.sameLength(buf, result)
#_______________________________________
func getData *(buffers :Buffers; view :BufferView) :string=  buffers[ view.buffer ].data.bytes[ view.byteOffset..<view.byteOffset + view.byteLength ]
  ## Returns the byte data defined by the given BufferView from the input buffers list.


#_______________________________________
# Json Data
#_____________________________
func get *(json :JsonNode; _:typedesc[Buffers]) :Buffers=
  ## Gets the Buffers data from the given json node.
  ## Raises an exception if any of the elements is missing the byteLength field (required by spec)
  for buffer in json["buffers"].elems:
    # Validate the fields required to exist by spec
    if not buffer.hasByteLength: raise newException(ImportError, "Tried to get Buffer data from a node that doesn't have a byteLength field (required by spec).")
    # Get the data for the current Buffer
    var tmp :Buffer
    tmp.uri = if buffer.hasURI: buffer["uri"].getStr().URI else: UriBufferGLB  # GLTF.spec requires this to be undefined when the data of the buffer comes from the GLB Data Chunk
    tmp.byteLength = buffer["byteLength"].getInt.uint32
    if buffer.hasName:    tmp.name       = buffer["name"].getStr()
    if buffer.hasExtJson: tmp.extensions = buffer.get(Extension)
    if buffer.hasExtras:  tmp.extras     = buffer.get(Extras)
    result.add tmp
#_____________________________
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

