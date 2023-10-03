#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# std dependencies
import std/strutils
import std/strformat
import std/json as stdjson
# ngltf dependencies
import ../types/base
import ../types/texture
import ../types/material
import ./base
import ./texture


#_______________________________________
func get *(json :JsonNode; _:typedesc[MaterialPBRMetallicRoughness]) :MaterialPBRMetallicRoughness=
  ## Gets the MaterialPBRMetallicRoughness data contained in the given json node.
  ## Raises an ImportError exception if the fields required by spec are not there.
  result.baseColorFactor = if json.hasBaseColorFac: json["baseColorFactor"].getVector4() else: DefaultBaseColorFactor
  if json.hasBaseColorTex: result.baseColorTexture = json["baseColorTexture"].get(TextureInfo)
  result.metallicFactor  = if json.hasMetallic:  json["metallicFactor"].getFloat() else: 1.0
  result.roughnessFactor = if json.hasRoughness: json["roughnessFactor"].getFloat() else: 1.0
  result.metallicRoughnessTexture = json["metallicRoughnessTexture"].get(TextureInfo)
  if json.hasExtJson: result.extensions = json.get(Extension)
  if json.hasExtras:  result.extras     = json.get(Extras)
#_______________________________________
func get *(json :JsonNode; _:typedesc[MaterialNormalTextureInfo]) :MaterialNormalTextureInfo=
  ## Gets the Normal or Occlusion MaterialNormalTextureInfo data contained in the given json node.
  ## Raises an ImportError exception if the fields required by spec are not there.
  # Validate the fields required to exist by spec
  if not json.hasIndex: raise newException(ImportError, &"Tried to get MaterialNormalTextureInfo data from a node that has no index field (required by spec).")
  # Get the data for the MaterialNormalTextureInfo
  result.index = json["index"].getInt.uint32
  if json.hasTexCoord: result.texCoord = json["texCoord"].getInt.uint32
  result.scale = if json.hasScale: json["scale"].getFloat() else: 1.0
  if json.hasExtJson:  result.extensions = json.get(Extension)
  if json.hasExtras:   result.extras     = json.get(Extras)
#_______________________________________
func get *(json :JsonNode; _:typedesc[MaterialOcclusionTextureInfo]) :MaterialOcclusionTextureInfo=
  # Validate the fields required to exist by spec
  if not json.hasIndex: raise newException(ImportError, &"Tried to get MaterialOcclusionTextureInfo data from a node that has no index field (required by spec).")
  # Get the data for the MaterialNormalTextureInfo
  result.index = json["index"].getInt.uint32
  if json.hasTexCoord: result.texCoord = json["texCoord"].getInt.uint32
  result.strength = if json.hasStrength: json["strength"].getFloat() else: 1.0
  if json.hasExtJson:  result.extensions = json.get(Extension)
  if json.hasExtras:   result.extras     = json.get(Extras)
#_______________________________________
func get *(json :JsonNode; _:typedesc[Materials]) :Materials=
  ## Gets the Materials list data contained in the given json node.
  ## Raises an ImportError exception if the fields required by spec are not there.
  for mat in json["materials"].elems:
    # Validate the fields required to exist by spec
    # Get the data for the Material
    var tmp :Material
    if mat.hasName:         tmp.name                 = mat["name"].getStr()
    if mat.hasExtJson:      tmp.extensions           = mat.get(Extension)
    if mat.hasExtras:       tmp.extras               = mat.get(Extras)
    if mat.hasPBRMR:        tmp.pbrMetallicRoughness = mat["pbrMetallicRoughness"].get(MaterialPBRMetallicRoughness)
    if mat.hasNormalTex:    tmp.normalTexture        = mat["normalTexture"].get(MaterialNormalTextureInfo)
    if mat.hasOcclusionTex: tmp.occlusionTexture     = mat["occlusionTexture"].get(MaterialOcclusionTextureInfo)
    if mat.hasEmissiveTex:  tmp.emissiveTexture      = mat["emissiveTexture"].get(TextureInfo)
    if mat.hasEmissiveFac:  tmp.emissiveFactor       = mat["emissiveFactor"].getVector3()
    if mat.hasAlphaMode:    tmp.alphaMode            = parseEnum[MaterialAlphaMode]( mat["alphaMode"].getStr() )
    tmp.alphaCutoff = if mat.hasAlphaCutoff: mat["alphaCutoff"].getFloat() else: 0.5
    if mat.hasDoubleSided:  tmp.doubleSided          = mat["doubleSided"].getBool()
    result.add tmp

