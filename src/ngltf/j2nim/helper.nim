#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/strformat
import std/strutils
import std/sets
import std/json
# j2nim dependencies
import ./types as j2n


#_____________________________________________________
# Json Extension
#_____________________________
func hasKeys *(json :JsonNode) :bool=
  ## Returns true if the node has at least one key
  for key,val in json: return true
  return false


#_____________________________________________________
# Error management
#_____________________________
proc err *(msg :varargs[string, `$`]) :void=  quit "ERR:: " & msg.join("")


#_____________________________________________________
# Development helpers
#_____________________________
proc report *(list :HashSet[string]; name :string) :void=
  ## Reports all entries of the list to console. For debugging/developing what the parser does
  echo "\n",name,"  _____________________________"
  for entry in list: echo entry
  echo "_____________________________________________________"


#_____________________________________________________
# String Conversion
#_____________________________
func toUppercase *(str :string) :string=
  ## Returns a string with the first character converted to Uppercase, not UpperCamelCase.
  $(str[0].toUpperAscii() & str[1..^1])
#_____________________________
func toTypeName *(typ :string) :string=
  ## Returns the equivalent Nim.typename of the given Schema.typename
  case typ
  of "string","object": typ
  of "integer" : "uint32"
  of "number"  : "float64"
  of "boolean" : "bool"
  of "null"    : "NilType"
  else: raise newException(SchemaError, &"{typ} is not supported type. type must be object, string, integer, number, boolean, or null.")
#_____________________________
func toNimSpelling *(typ :string) :string=
  ## Converts a Spec-spelled typename into a Nim-spelled typename.
  result = typ.split(" ").join("").toUppercase.multiReplace(
    ("GlTF","Gltf"),
    ("Childof","ChildOf"),
    ) # << multiReplace( ... )
#_____________________________
func toFieldName *(key :string) :string=
  ## Returns a fieldname, changed to not clash with nim keywords
  case key
  of "type" : "`type`"
  of "min"  : "`min`"
  of "max"  : "`max`"
  else: key
#_____________________________
func refToGLTF *(refId :string) :string=
  if refId notin j2n.BaseTypeIDs: raise newException(SchemaError, &"Tried to get the ref type of {refId}, but it is not registered as a BaseType.")
  case refId
  of "glTFChildOfRootProperty.schema.json"       : "GltfChildOfRootProperty"
  of "animation.sampler.schema.json"             : "AnimationSampler"
  of "node.schema.json"                          : "Node"
  of "material.occlusionTextureInfo.schema.json" : "MaterialOcclusionTextureInfo"
  of "camera.perspective.schema.json"            : "CameraPerspective"
  of "buffer.schema.json"                        : "Buffer"
  of "sampler.schema.json"                       : "Sampler"
  of "scene.schema.json"                         : "Scene"
  of "textureInfo.schema.json"                   : "TextureInfo"
  of "accessor.sparse.indices.schema.json"       : "AccessorSparseIndices"
  of "material.schema.json"                      : "Material"
  of "glTFid.schema.json"                        : "GltfId"
  of "animation.schema.json"                     : "Animation"
  of "material.normalTextureInfo.schema.json"    : "MaterialNormalTextureInfo"
  of "mesh.schema.json"                          : "Mesh"
  of "animation.channel.schema.json"             : "AnimationChannel"
  of "extras.schema.json"                        : "Extras"
  of "glTF.schema.json"                          : "Gltf"
  of "accessor.sparse.schema.json"               : "AccessorSparse"
  of "texture.schema.json"                       : "Texture"
  of "extension.schema.json"                     : "Extension"
  of "accessor.schema.json"                      : "Accessor"
  of "asset.schema.json"                         : "Asset"
  of "accessor.sparse.values.schema.json"        : "AccessorSparseValues"
  of "bufferView.schema.json"                    : "BufferView"
  of "image.schema.json"                         : "Image"
  of "skin.schema.json"                          : "Skin"
  of "camera.orthographic.schema.json"           : "CameraOrthographic"
  of "mesh.primitive.schema.json"                : "MeshPrimitive"
  of "glTFProperty.schema.json"                  : "GltfProperty"
  of "camera.schema.json"                        : "Camera"
  of "material.pbrMetallicRoughness.schema.json" : "MaterialPBRMetallicRoughness"
  of "animation.channel.target.schema.json"      : "AnimationChannelTarget"
  else: raise newException(SchemaError, &"Reached the bottom of the refToGLTF string converter. The given id {refId} is in the BaseTypeIDs list, but its conversion is not added as a case.")

