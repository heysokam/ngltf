#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/strutils
import std/json as stdjson
import std/base64
import std/mimetypes
# ngltf dependencies
import ../types/base
import ../types/texture
import ../types/gltf
import ../tool/paths
import ../validate
import ./base
import ./buffer



#_______________________________________
# Binary Data
#_____________________________
proc get *(img :Image; _:typedesc[ByteBuffer]; dir :Path; gltf :GLTF) :ByteBuffer=
  ## Returns the ByteBuffer of the given `img` Image.
  ## Searches for its binary data file relative to `dir` when relevant.
  new result
  # Get the data from the gltf.buffer pointed by the bufferView
  if img.hasBufferView:
    let view        = gltf.bufferViews[ img.bufferView ]
    result.bytes    = gltf.buffers.getData(view)
    result.mimetype = img.uri.string
    if not validate.areSameLength(gltf.buffers[view.buffer], result): raise newException(ImportError, &"Tried to load Image data from {img.uri.string}, but the resulting bytebuffer has a length different than the one declared in the input Image object.")
  # Get the data from the base64 uri
  elif img.uri.isData():
    let split       = img.uri.string.split(";base64,")
    result.mimetype = split[0].replace("data:", "")
    result.bytes    = base64.decode( split[1] )
  # Get the data from the file
  elif img.uri.isFile():
    if not fileExists( dir/img.uri.Path ): raise newException(ImportError, &"Tried to load Image data from {string(dir/img.uri.Path)}, but the file does not exist.")
    result.mimetype = newMimetypes().getMimetype( img.uri.Path.splitFile.ext )
    result.bytes    = readFile( dir/img.uri.Path )
  # Data couldn't be found
  else: raise newException(ImportError, &"Tried to load Image data from:  {img.uri.string}  but the input has an unknown or invalid URI format.")


#_______________________________________
# Json Data
#_____________________________
func get *(json :JsonNode; _:typedesc[Images]) :Images=
  ## Gets the Images list data contained in the given json node.
  ## Raises an ImportError exception if the fields required by spec are not there.
  for img in json["images"].elems:
    # Validate the fields required to exist by spec
    if img.hasBoth("bufferView", "uri"): raise newException(ImportError, "Tried to get Image data from a node that contains both a bufferView field and an uri field (not allowed by spec).")
    if img.hasBufferView and not img.hasMimetype: raise newException(ImportError, "Tried to get Image data from a node that contains a bufferView field, but is missing its mimeType field (required by spec).")
    # Get the data for this Image
    var tmp :Image
    tmp.bufferView = if img.hasBufferView: img["bufferView"].getInt.GltfId else: GltfId(-1)
    if img.hasURI:      tmp.uri        = img["uri"].getStr().URI
    if img.hasMimetype: tmp.mimeType   = parseEnum[ImageMimeType]( img["mimeType"].getStr() )
    if img.hasName:     tmp.name       = img["name"].getStr()
    if img.hasExtJson:  tmp.extensions = img.get(Extension)
    if img.hasExtras:   tmp.extras     = img.get(Extras)
    result.add tmp
#_____________________________
func get *(json :JsonNode; _:typedesc[TextureInfo]) :TextureInfo=
  ## Gets the TextureInfo data contained in the given json node.
  ## Raises an ImportError exception if the fields required by spec are not there.
  if not json.hasIndex: raise newException(ImportError, "Tried to get TextureInfo data from a node that doesn't have an index field (required by spec).")
  result.index = json["index"].getInt().uint32
  if json.hasTexCoord: result.texCoord   = json["texCoord"].getInt.uint32
  if json.hasExtJson:  result.extensions = json.get(Extension)
  if json.hasExtras:   result.extras     = json.get(Extras)
#_____________________________
func get *(json :JsonNode; _:typedesc[Textures]) :Textures=
  ## Gets the Textures list data contained in the given json node.
  ## Raises an ImportError exception if the fields required by spec are not there.
  for tex in json["textures"].elems:
    var tmp :Texture
    tmp.sampler = if tex.hasSampler: tex["sampler"].getInt.GltfId else: GltfId(-1)
    tmp.source  = if tex.hasSource:  tex["source"].getInt.GltfId  else: GltfId(-1)
    if tex.hasName:    tmp.name       = tex["name"].getStr()
    if tex.hasExtJson: tmp.extensions = tex.get(Extension)
    if tex.hasExtras:  tmp.extras     = tex.get(Extras)
    result.add tmp

