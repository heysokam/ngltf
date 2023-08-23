#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/os
import std/strformat
import std/strutils
import std/tables
import std/json as stdjson
# n*dk dependencies
import ./tool/paths as pths
# n*gltf dependencies
import ./types
import ./types/base
import ./types/buffer
import ./types/accessor
import ./types/texture
import ./types/mesh
from   ./types/binary as bin import nil


#_________________________________________________
# GLTF
#_____________________________
proc validate *(header :bin.Header; length :SomeInteger) :void {.inline.}=
  ## Validates that the given header meets all of the required conditions to be a valid glTF header.
  const Magic = bin.Magic
  if not header.magic      == bin.Magic:   raise newException(ImportError, &"Tried to load a glTF file, but its Magic value ({header.magic}) does not match the glTF specification (should be {Magic}).")
  if not header.version    == bin.Version: raise newException(ImportError, &"Tried to load a glTF file, but support for version {header.version} is not implemented in ngltf.")
  if not header.length     >  0:           raise newException(ImportError, &"Tried to load a glTF file, but the length declared in its header is {header.length} and it should be bigger than 0 instead.")
  if not header.length.int == length.int:  raise newException(ImportError, &"Tried to load a glTF file, but the length declared in its header ({header.length}) does not match the given length sent for validation ({length}).")
#_____________________________
proc validate *(gltf :JsonNode) :void {.inline.}=
  ## Validates that the given json node contains the fields required to be a valid glTF json object.
  ## Checks that the json has an "asset" and "asset/version" keys, and that the contained version is compatible with ngltf.
  if not gltf.hasKey("asset"):            raise newException(ImportError, "Tried to load a glTF json file, but the given json doesn't have an asset field (required by spec).")
  if not gltf["asset"].hasKey("version"): raise newException(ImportError, "Tried to load a glTF json file, but the given json doesn't have a version field (required by spec).")
  if not (gltf["asset"]["version"].getStr.parseFloat() == bin.Version.float):
    raise newException(ImportError, &"Tried to load a glTF json file, but the given node contains an invalid version.")
#_____________________________
proc validate *(chunk :Chunk) :void {.inline.}=
  ## Validates that the given input chunk is valid.
  if not chunk.length.int == chunk.data.len: raise newException(ImportError, &"Tried to load a Chunk from a GLB binary, but its resulting length ({chunk.data.len}) is different than the one declared in its chunkLength field ({chunk.length}).")
#_____________________________
proc chunkIDjson *(id :SomeInteger) :void {.inline.}=
  ## Checks that the given id correctly identifies a GltfJson chunk.
  if not id.uint32 == bin.ChunkIDjson: raise newException(ImportError, &"Tried to load a glTF binary file, but the json chunk id {id} is incorrect (should be {ChunkIDjson})")
proc chunkIDdata *(id :SomeInteger) :void {.inline.}=
  ## Checks that the given id correctly identifies a GltfData chunk.
  if not id.uint32 == bin.ChunkIDdata: raise newException(ImportError, &"Tried to load a glTF binary file, but the data chunk id {id} is incorrect (should be {ChunkIDdata})")
#_____________________________
func isData  *(uri :URI) :bool=  uri.string.startsWith("data:")
  ## Checks if the given uri string is pointing to a data container.
func isFile  *(uri :URI) :bool=  uri.string.splitFile.ext in ValidFileExtensions
  ## Checks if the given uri string is pointing to a file.
func isChunk *(uri :URI) :bool=  uri == UriBufferGLB
  ## Checks if the given uri string is signaling to our custom identifier for GLB.DataChunk.Buffer.
#_____________________________
proc isGLTF *(path :Path) :void=
  ## Checks that the given path contains a valid gltf file.
  if not (pths.splitFile(path).ext in ValidGltfFileExtensions): raise newException(ImportError, &"Tried to load glTF from file {path.string}, but it has an incorrect extension (valid options {ValidGltfFileExtensions}).")

#_________________________________________________
# Buffer
#_____________________________
func areSameLength *(buf :Buffer; bbuf :ByteBuffer) :bool=  buf.byteLength == bbuf.bytes.len.uint32
  ## Returns true if the `buf` Buffer has the same length as the `bbuf` ByteBuffer
func sameLength *(buf :Buffer; bbuf :ByteBuffer) :void=
  ## Checks that the `buf` Buffer has the same length as the `bbuf` ByteBuffer
  if not areSameLength(buf, bbuf): raise newException(ImportError, &"Tried to load Buffer data from {buf.uri.string}, but the resulting bytebuffer has a length ({buf.byteLength}) different than the one declared in the input Buffer object ({bbuf.bytes.len}).")
func sameLength *(bbuf :ByteBuffer; buf :Buffer) :void=  sameLength( buf, bbuf )
  ## Checks that the `buf` Buffer has the same length as the `bbuf` ByteBuffer
func sameLength *(acc :Accessor; view :BufferView) :void=
  ## Checks that the given `acc` Accessor defines data that has the same size than the data contained in the buffer portion pointed by the given `view` BufferView.
  if not (acc.size == view.byteLength):  raise newException(ImportError, &"Tried to access a BufferView from an Accessor that defines data of a size ({acc.size()}) which does not match the bufferView.byteLength ({view.byteLength}).")
func sameLength *(view :BufferView; acc :Accessor) :void=  sameLength( acc, view )
  ## Checks that the given `acc` Accessor defines data that has the same size than the data contained in the buffer portion pointed by the given `view` BufferView.

#_________________________________________________
# Texture
#_____________________________
func hasBufferView *(img :Image) :bool=  img.bufferView >= 0
  ## Checks if the given `img` has an active bufferView id
  ## A negative GltfId means the view is inactive.

#_________________________________________________
# Mesh
#_____________________________
func hasAttr *(mesh :Mesh; key :MeshAttribute) :bool=  mesh.attributes.hasKey( $key )
  ## Returns true if the given primitive contains the given attribute.
func hasAttr *(meshes :Meshes; key :MeshAttribute) :bool=
  ## Returns true if all of the given primitives contain the given attribute.
  for mesh in meshes:
    if not mesh.hasAttr(key): return false
  return true
#_____________________________
func hasPositions *(mesh :Mesh)  :bool=  mesh.hasAttr( MeshAttribute.pos )
func hasPositions *(mdl  :Model) :bool=
  for mesh in mdl.meshes:
    if not mesh.hasPositions: return false
  return true
#_____________________________
func hasUVs       *(mdl  :Model) :bool=  mdl.meshes.hasAttr( MeshAttribute.uv )
func hasUVs       *(mesh :Mesh)  :bool=  mesh.hasAttr( MeshAttribute.uv )
func hasNormals   *(mdl  :Model) :bool=  mdl.meshes.hasAttr( MeshAttribute.norm )
func hasNormals   *(mesh :Mesh)  :bool=  mesh.hasAttr( MeshAttribute.norm )
func hasColors    *(mdl  :Model) :bool=  mdl.meshes.hasAttr( MeshAttribute.color )
func hasColors    *(mesh :Mesh)  :bool=  mesh.hasAttr( MeshAttribute.color )
func hasIndices   *(mesh :Mesh)  :bool=  mesh.indices  >= 0
func hasMaterial  *(mesh :Mesh)  :bool=  mesh.material >= 0

#_________________________________________________
# Json Entries
#_____________________________
# Base
func hasBoth          *(json :JsonNode; k1,k2 :string) :bool=  json.hasKey(k1) and json.hasKey(k2)
func hasExtJson       *(json :JsonNode) :bool=  json.hasKey("extensions")
func hasExtras        *(json :JsonNode) :bool=  json.hasKey("extras")
# Multi
func hasBufferView    *(json :JsonNode) :bool=  json.hasKey("bufferView")
func hasByteOffset    *(json :JsonNode) :bool=  json.hasKey("byteOffset")
func hasName          *(json :JsonNode) :bool=  json.hasKey("name")
func hasIndices       *(json :JsonNode) :bool=  json.hasKey("indices")
func hasWeights       *(json :JsonNode) :bool=  json.hasKey("weights")
func hasScale         *(json :JsonNode) :bool=  json.hasKey("scale")
func hasSampler       *(json :JsonNode) :bool=  json.hasKey("sampler")
#_____________________________
# GLTF
func hasExtUsed       *(json :JsonNode) :bool=  json.hasKey("extensionsUsed")
func hasExtReq        *(json :JsonNode) :bool=  json.hasKey("extensionsRequired")
func hasAccessors     *(json :JsonNode) :bool=  json.hasKey("accessors")
func hasAnimations    *(json :JsonNode) :bool=  json.hasKey("animations")
func hasAsset         *(json :JsonNode) :bool=  json.hasKey("asset")
func hasBuffers       *(json :JsonNode) :bool=  json.hasKey("buffers")
func hasBufferViews   *(json :JsonNode) :bool=  json.hasKey("bufferViews")
func hasCameras       *(json :JsonNode) :bool=  json.hasKey("cameras")
func hasImages        *(json :JsonNode) :bool=  json.hasKey("images")
func hasMaterials     *(json :JsonNode) :bool=  json.hasKey("materials")
func hasModels        *(json :JsonNode) :bool=  json.hasKey("meshes")
func hasNodes         *(json :JsonNode) :bool=  json.hasKey("nodes")
func hasSamplers      *(json :JsonNode) :bool=  json.hasKey("samplers")
func hasSceneID       *(json :JsonNode) :bool=  json.hasKey("scene")
func hasScenes        *(json :JsonNode) :bool=  json.hasKey("scenes")
func hasSkins         *(json :JsonNode) :bool=  json.hasKey("skins")
func hasTextures      *(json :JsonNode) :bool=  json.hasKey("textures")
#_____________________________
# Accessor
func hasComponentType *(json :JsonNode) :bool=  json.hasKey("componentType")
func hasNormalized    *(json :JsonNode) :bool=  json.hasKey("normalized")
func hasCount         *(json :JsonNode) :bool=  json.hasKey("count")
func hasType          *(json :JsonNode) :bool=  json.hasKey("type")
func hasMaxv          *(json :JsonNode) :bool=  json.hasKey("max")
func hasMinv          *(json :JsonNode) :bool=  json.hasKey("min")
func hasSparse        *(json :JsonNode) :bool=  json.hasKey("sparse")
# Sparse
func hasValues        *(json :JsonNode) :bool=  json.hasKey("values")
#_____________________________
# Animation
func hasChannels      *(json :JsonNode) :bool=  json.hasKey("channels")
func hasChannel       *(json :JsonNode) :bool=  json.hasKey("channel")
func hasPath          *(json :JsonNode) :bool=  json.hasKey("path")
func hasNode          *(json :JsonNode) :bool=  json.hasKey("node")
func hasInput         *(json :JsonNode) :bool=  json.hasKey("input")
func hasOutput        *(json :JsonNode) :bool=  json.hasKey("output")
func hasInterpolation *(json :JsonNode) :bool=  json.hasKey("interpolation")
func hasJoints        *(json :JsonNode) :bool=  json.hasKey("joints")
func hasBindMatrices  *(json :JsonNode) :bool=  json.hasKey("inverseBindMatrices")
func hasSkeleton      *(json :JsonNode) :bool=  json.hasKey("skeleton")
#_____________________________
# Asset
func hasCopyright     *(json :JsonNode) :bool=  json.hasKey("copyright")
func hasGenerator     *(json :JsonNode) :bool=  json.hasKey("generator")
func hasVersion       *(json :JsonNode) :bool=  json.hasKey("version")
func hasMinVersion    *(json :JsonNode) :bool=  json.hasKey("minVersion")
#_____________________________
# Buffer
func hasByteLength    *(json :JsonNode) :bool=  json.hasKey("byteLength")
func hasByteStride    *(json :JsonNode) :bool=  json.hasKey("byteStride")
func hasTarget        *(json :JsonNode) :bool=  json.hasKey("target")
func hasBuffer        *(json :JsonNode) :bool=  json.hasKey("buffer")
func hasURI           *(json :JsonNode) :bool=  json.hasKey("uri")
#_____________________________
# Camera
func hasXmag          *(json :JsonNode) :bool=  json.hasKey("xmag")
func hasYmag          *(json :JsonNode) :bool=  json.hasKey("ymag")
func hasZfar          *(json :JsonNode) :bool=  json.hasKey("zfar")
func hasZnear         *(json :JsonNode) :bool=  json.hasKey("znear")
func hasYfov          *(json :JsonNode) :bool=  json.hasKey("yfov")
func hasAspectRatio   *(json :JsonNode) :bool=  json.hasKey("aspectRatio")
func hasOrthographic  *(json :JsonNode) :bool=  json.hasKey("orthographic")
func hasPerspective   *(json :JsonNode) :bool=  json.hasKey("perspective")
#_____________________________
# Material
func hasPBRMR         *(json :JsonNode) :bool=  json.hasKey("pbrMetallicRoughness")
func hasStrength      *(json :JsonNode) :bool=  json.hasKey("strength")
func hasBaseColorFac  *(json :JsonNode) :bool=  json.hasKey("baseColorFactor")
func hasBaseColorTex  *(json :JsonNode) :bool=  json.hasKey("baseColorTexture")
func hasMetallic      *(json :JsonNode) :bool=  json.hasKey("metallicFactor")
func hasRoughness     *(json :JsonNode) :bool=  json.hasKey("roughnessFactor")
func hasNormalTex     *(json :JsonNode) :bool=  json.hasKey("normalTexture")
func hasOcclusionTex  *(json :JsonNode) :bool=  json.hasKey("occlusionTexture")
func hasEmissiveTex   *(json :JsonNode) :bool=  json.hasKey("emissiveTexture")
func hasEmissiveFac   *(json :JsonNode) :bool=  json.hasKey("emissiveFactor")
func hasAlphaMode     *(json :JsonNode) :bool=  json.hasKey("alphaMode")
func hasAlphaCutoff   *(json :JsonNode) :bool=  json.hasKey("alphaCutoff")
func hasDoubleSided   *(json :JsonNode) :bool=  json.hasKey("doubleSided")
#_____________________________
# Mesh
func hasAttributes    *(json :JsonNode) :bool=  json.hasKey("attributes")
func hasMeshes        *(json :JsonNode) :bool=  json.hasKey("primitives")
func hasMaterial      *(json :JsonNode) :bool=  json.hasKey("material")
func hasMode          *(json :JsonNode) :bool=  json.hasKey("mode")
func hasTargets       *(json :JsonNode) :bool=  json.hasKey("targets")
#_____________________________
# Node
func hasCamera        *(json :JsonNode) :bool=  json.hasKey("camera")
func hasChildren      *(json :JsonNode) :bool=  json.hasKey("children")
func hasSkin          *(json :JsonNode) :bool=  json.hasKey("skin")
func hasMatrix        *(json :JsonNode) :bool=  json.hasKey("matrix")
func hasMesh          *(json :JsonNode) :bool=  json.hasKey("mesh")
func hasRotation      *(json :JsonNode) :bool=  json.hasKey("rotation")
func hasTranslation   *(json :JsonNode) :bool=  json.hasKey("translation")
#_____________________________
# Sampler
func hasMagFilter     *(json :JsonNode) :bool=  json.hasKey("magFilter")
func hasMinFilter     *(json :JsonNode) :bool=  json.hasKey("minFilter")
func hasWrapS         *(json :JsonNode) :bool=  json.hasKey("wrapS")
func hasWrapT         *(json :JsonNode) :bool=  json.hasKey("wrapT")
#_____________________________
# Texture
func hasIndex         *(json :JsonNode) :bool=  json.hasKey("index")
func hasMimetype      *(json :JsonNode) :bool=  json.hasKey("mimeType")
func hasTexCoord      *(json :JsonNode) :bool=  json.hasKey("texCoord")
func hasSource        *(json :JsonNode) :bool=  json.hasKey("source")

