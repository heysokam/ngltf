#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# ngltf dependencies
import ./base


type BufferViewTarget *{.pure.}= enum
  ## The hint representing the intended GPU buffer type to use with this buffer view.
  ArrayBuffer        = 34962  ## ARRAY_BUFFER
  ElementArrayBuffer = 34963  ## ELEMENT_ARRAY_BUFFER

type BufferView * = object
  ## A view into a buffer generally representing a subset of the buffer.
  buffer      *:seq[GltfId]      ## The index of the buffer.
  byteOffset  *:uint32           ## The offset into the buffer in bytes.
  byteLength  *:uint32           ## The length of the bufferView in bytes.
  byteStride  *:uint32           ## The stride, in bytes.
  target      *:BufferViewTarget ## The hint representing the intended GPU buffer type to use with this buffer view.
  name        *:string           ## The user-defined name of this object.
  extensions  *:Extension        ## JSON object with extension-specific objects.
  extras      *:Extras           ## Application-specific data.

type Buffer * = object
  ## A buffer points to binary geometry, animation, or skins.
  uri         *:string           ## The URI (or IRI) of the buffer.
  byteLength  *:uint32           ## The length of the buffer in bytes.
  name        *:string           ## The user-defined name of this object.
  extensions  *:Extension        ## JSON object with extension-specific objects.
  extras      *:Extras           ## Application-specific data.

