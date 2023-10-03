#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# std dependencies
import std/json as stdjson
import std/sets
# ngltf dependencies
import ../types
import ../types/base
import ../validate


#_____________________________
func getUsed *(json :JsonNode; _:typedesc[Extension]) :HashSet[string]=
  ## Returns a list of all the unique extensions used by the GLTF root node.
  if not json.hasExtUsed: raise newException(ImportError, "Tried to get the extensionsUsed field of a json node that doesn't have any.")
  for ext in json["extensionsUsed"].elems: result.incl ext.getStr
#_____________________________
func getReq *(json :JsonNode; _:typedesc[Extension]) :HashSet[string]=
  ## Returns a list of all the unique extensions required to load the GLTF root node.
  if not json.hasExtReq: raise newException(ImportError, "Tried to get the extensionsRequired field of a json node that doesn't have any.")
  for ext in json["extensionsRequired"].elems: result.incl ext.getStr

