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
from   ./types/binary as bin import nil
import ./binary as b

#_________________________________________________
proc header *(input :string|Path) :bool=
  ## Validates that the input string or path contains a valid glTF file header.
  if input.len < bin.HeaderSize: return false
  let header = b.header(input)
  result =
    header.magic   == bin.Magic and
    header.version == bin.Version and
    header.length > 0
#_________________________________________________
proc json *(input :string) :bool=
  ## Validates the given input bytebuffer containing a json object.
  ## Checks that the json has an "asset" and "asset/version" keys, and that the contained version is compatible with the loader.
  let root = input.parseJson
  result =
    root.hasKey("asset") and
    root["asset"].hasKey("version") and
    root["asset"]["version"].getStr.parseFloat() == bin.Version.float

#_________________________________________________
proc isGLTF *(input :string|Path) :bool=
  ## Returns true if the input passes all checks for being a valid glTF file
  ## Interprets the input as a bytebuffer if it doesn't pass the `isFile` check. Otherwise it reads the file and validates its contents.
  if input.isFile():
    let ext = input.splitFile.ext
    case ext
    of ".glb":  return validate.header(input.readFile)
    of ".gltf": return validate.json(input.readFile)
    else: raise newException(ImportError, &"Tried to read file {input.string}, but {ext} it is not a valid glTF extension.")
  return validate.header(input)

#_________________________________________________
# Data/Content
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
func hasMeshes        *(json :JsonNode) :bool=  json.hasKey("meshes")
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
func hasPrimitives    *(json :JsonNode) :bool=  json.hasKey("primitives")
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

