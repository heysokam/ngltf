#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/strutils
import std/json as stdjson
# ngltf dependencies
import ../types/base
import ../types/texture
import ./base


#_______________________________________
func get *(json :JsonNode; _:typedesc[Images]) :Images=
  ## Gets the Images list data contained in the given json node.
  ## Raises an ImportError exception if the fields required by spec are not there.
  for img in json["images"].elems:
    # Validate the fields required to exist by spec
    if img.hasBoth("bufferView", "uri"): raise newException(ImportError, "Tried to get Image data from a node that contains both a bufferView field and an uri field (not allowed by spec).")
    if img.hasBufferView and not img.hasMimetype: raise newException(ImportError, "Tried to get Image data from a node that contains a bufferView field, but is missing its mimeType field (required by spec).")
    # Get the data for this Image
    var tmp :Image
    if img.hasURI:        tmp.uri        = img["uri"].getStr()
    if img.hasMimetype:   tmp.mimeType   = parseEnum[ImageMimeType]( img["mimeType"].getStr() )
    if img.hasBufferView: tmp.bufferView = img["bufferView"].getInt.GltfId
    if img.hasName:       tmp.name       = img["name"].getStr()
    if img.hasExtJson:    tmp.extensions = img.get(Extension)
    if img.hasExtras:     tmp.extras     = img.get(Extras)
    result.add tmp
#_______________________________________
func get *(json :JsonNode; _:typedesc[TextureInfo]) :TextureInfo=
  ## Gets the TextureInfo data contained in the given json node.
  ## Raises an ImportError exception if the fields required by spec are not there.
  if not json.hasIndex: raise newException(ImportError, "Tried to get TextureInfo data from a node that doesn't have an index field (required by spec).")
  result.index = json["index"].getInt().uint32
  if json.hasTexCoord: result.texCoord   = json["texCoord"].getInt.uint32
  if json.hasExtJson:  result.extensions = json.get(Extension)
  if json.hasExtras:   result.extras     = json.get(Extras)
#_______________________________________
func get *(json :JsonNode; _:typedesc[Textures]) :Textures=
  ## Gets the Textures list data contained in the given json node.
  ## Raises an ImportError exception if the fields required by spec are not there.
  for tex in json["textures"].elems:
    var tmp :Texture
    if tex.hasSampler: tmp.sampler    = tex["sampler"].getInt.GltfId
    if tex.hasSource:  tmp.source     = tex["source"].getInt.GltfId
    if tex.hasName:    tmp.name       = tex["name"].getStr()
    if tex.hasExtJson: tmp.extensions = tex.get(Extension)
    if tex.hasExtras:  tmp.extras     = tex.get(Extras)
    result.add tmp

