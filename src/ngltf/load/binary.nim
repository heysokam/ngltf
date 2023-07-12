#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/strformat
import std/json as stdjson
# External dependencies
import pkg/flatty/binny
# ngltf dependencies
import ../types
import ../types/base
import ../types/binary
import ../tool/paths
import ../validate
import ./buffer
import ./texture


#_____________________________________________________
proc readData (gltf :var GLTF; dir :Path; chunk :ByteBuffer) :void=
  ## Reads the data stored in the given bytebuffer data chunk.
  ## Stores the data into their corresponding slots, taking it from the chunk, uri.readFile and/or base64 embedded data
  for buf in gltf.buffers.mitems: buf.data = buf.get(ByteBuffer, dir, chunk)
  for img in gltf.images.mitems:  img.data = img.get(ByteBuffer, dir, gltf)
#_____________________________________________________
proc get *(buffer :string; _:typedesc[Chunk]; pos :SomeInteger= 0) :Chunk=
  new result
  result.length = buffer.readUint32( pos )
  result.typ    = buffer.readUint32( pos + sizeof(uint32) )
  result.data   = buffer.readStr( pos + 2*sizeof(uint32), result.length.int )
  validate( result )
#_______________________________________
proc get (buffer :string; _:typedesc[Header]) :Header=
  ## Returns the header of the given glb bytebuffer.
  ## Raises an exception if the input has an insufficient length, or if the resulting header is not valid.
  if buffer.len < HeaderSize: raise newException(ImportError, &"Tried to read a glTF header from a bytebuffer, but it has an insufficient length of {buffer.len} bytes.")
  result.magic   = buffer.readUint32(0)
  result.version = buffer.readUint32(4)
  result.length  = buffer.readUint32(8)
  validate( result, buffer.len )
#_______________________________________
proc get (buffer :string; _:typedesc[JsonString]) :string=
  ## Returns the Json chunk of the given glb bytebuffer.
  ## Raises an exception if the resulting json is not valid.
  let chunk = buffer.get(Chunk, pos=HeaderSize)
  result    = chunk.data
  validate.chunkIDjson( chunk.typ )
  validate( result.parseJson )
#_______________________________________
proc get (buffer :string; _:typedesc[ByteBuffer]; pos :SomeInteger) :ByteBuffer=
  ## Returns the data chunk of the given glb bytebuffer.
  new result
  let chunk       = buffer.get(Chunk, pos)
  result.bytes    = chunk.data
  result.mimetype = MimetypeGLB
  validate.chunkIDdata( chunk.typ )
#_____________________________________________________
proc gltf *(buffer :string; dir :Path) :GLTF=
  ## Loads a GLTF object from the given string bytebuffer.
  let header = buffer.get(Header)
  let json   = buffer.get(JsonString)
  result     = json.gltf(dir)
  result.readData( dir, buffer.get(ByteBuffer, json.len + HeaderSize) )
#_____________________________________________________
proc gltf *(file :Path) :GLTF=  file.readFile.gltf( file.splitFile.dir.Path )
  ## Loads a GLTF object from the given file path.
  ## Doesn't do any checks, assumes that the input is a `.glb` binary gltf.

