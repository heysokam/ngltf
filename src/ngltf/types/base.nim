#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# Types imported by all other types and modules.  |
#_________________________________________________|


#_____________________________________________________
# GLTF
#_____________________________
type GltfId         * = int32               ## Generic GLTF handle id. A negative value means the id is inactive.
type JsonString     * = string              ## Alias to a string for clarity of its intended contents
type Extension      * = distinct JsonString ## JSON object with extension-specific objects.
type Extras         * = distinct JsonString ## JSON object with Application-specific data.
func `$` *(ext :Extension) :string=  ext.string
func `$` *(ext :Extras)    :string=  ext.string

type GltfProperty * = object
  extensions  *:Extension  ## JSON object with extension-specific objects.
  extras      *:Extras     ## Application-specific data.

type GltfChildOfRootProperty * = object
  name        *:string     ## The user-defined name of this object.


#_____________________________________________________
# Extend
#_____________________________
# Error management
type ImportError * = object of IOError
#_____________________________
# Base types
type JsonStringList * = seq[JsonString]
type GltfIdList     * = seq[GltfId]
type Float64List    * = seq[float64]
type Matrix4        * = array[16,float64]
type Vector3        * = array[3,float64]
type Vector4        * = array[4,float64]
#_____________________________
# Binary Data
type Chunk * = ref object
  length    *:uint32  ## uint32  chunkLength is the length of chunkData, in bytes.
  typ       *:uint32  ## uint32  chunkType indicates the type of chunk. See Table 1 for details. https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#chunks
  data      *:string  ## ubyte[] chunkData is the binary payload of the chunk.
#___________________
type ByteBuffer * = ref object
  bytes     *:string  ## String containing a buffer of bytes
  mimetype  *:string  ## Mimetype of the ByteBuffer, to aid in loading its data
#_____________________________
# Extensions and Mimetypes
const ValidGltfFileExtensions * = @[".gltf", ".glb"]
const ValidFileExtensions     * = ValidGltfFileExtensions & @[".png", ".jpeg", ".jpg", ".bin", ".glbin", ".glbuf"]
const MimetypeGLB             * = "model/gltf-binary"
#_____________________________
# URIs
type URI * = distinct string
func `==` *(u1,u2 :URI) :bool {.borrow.}
const UriBufferGLB * = "GLB.DataChunk.Buffer".URI  # Arbitrary name when undefined, so that exceptions print easily indentifiable information.

