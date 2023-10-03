#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# Base properties loaded by all modules.  |
#_________________________________________|
# std dependencies
import std/tables
import std/json as stdjson
# ngltf dependencies
import ../types/base


#_______________________________________
func get *(json :JsonNode; _:typedesc[Extension]) :Extension=  Extension $json["extensions"]
  ## Returns the Extension data contained in the given json node.
func get *(json :JsonNode; _:typedesc[Extras]) :Extras=  Extras $json["extras"]
  ## Returns the Extras data contained in the given json node.
#_______________________________________
func get *(json :JsonNode; _:typedesc[JsonStringList]) :JsonStringList=
  ## Returns the list of JsonString objects contained in the given json node.
  for obj in json.elems: result.add $obj
#_______________________________________
func get *(json :JsonNode; _:typedesc[GltfIdList]) :GltfIdList=
  ## Returns the list of GltfIds contained in the given json node.
  for id in json.elems: result.add id.getInt.GltfId
#_______________________________________
func get *(json :JsonNode; _:typedesc[Float64List]) :Float64List=
  ## Returns a list of float64 values from the given json node.
  for val in json.elems: result.add val.getFloat()
func getVector3 *(json :JsonNode) :Vector3=
  ## Returns an array of 3x float64 values from the given json node.
  for id,val in json.elems.pairs: result[id] = val.getFloat()
func getVector4 *(json :JsonNode) :Vector4=
  ## Returns an array of 4x float64 values from the given json node.
  for id,val in json.elems.pairs: result[id] = val.getFloat()
func getMatrix4 *(json :JsonNode) :Matrix4=
  ## Returns an array of 16x float64 values from the given json node.
  for id,val in json.elems.pairs: result[id] = val.getFloat()
func identity *(_:typedesc[Matrix4]) :Matrix4=  [1,0,0,0,  0,1,0,0,  0,0,1,0,  0,0,0,1]
  ## Returns an array of 16x float64 values filled with an identity matrix.
#_______________________________________
func toTable *(json :JsonNode) :Table[string,GltfId]=
  ## Converts the given json node to a Table[string,GltfId]
  for key,val in json.pairs: result[key] = val.getInt.GltfId

