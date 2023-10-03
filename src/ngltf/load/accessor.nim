#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# std dependencies
import std/strutils
import std/json as stdjson
# ngltf dependencies
import ../types/base
import ../types/accessor
import ../validate
import ./base as loadBase


#_______________________________________
func get *(json :JsonNode; _:typedesc[AccessorSparseIndices]) :AccessorSparseIndices=
  ## Gets the AccessorSparseIndices data contained in the given json node.
  ## Raises an ImportError exception if the fields required by spec are not there.
  # Validate the fields required to exist by spec
  if not json.hasBufferView:    raise newException(ImportError, "Tried to get AccessorSparseIndices data from a JsonNode that doesn't contain a bufferView field (required by spec).")
  if not json.hasComponentType: raise newException(ImportError, "Tried to get AccessorSparseIndices data from a JsonNode that doesn't contain a componentType field (required by spec).")
  # Get the data for the AccessorSparseIndices
  result.bufferView = json["bufferView"].getInt.GltfId
  if json.hasByteOffset: result.byteOffset = json["byteOffset"].getInt.uint32
  result.componentType = json["componentType"].getInt().AccessorSparseIndicesComponentType
  if json.hasExtJson: result.extensions = json.get(Extension)
  if json.hasExtras:  result.extras     = json.get(Extras)
#_______________________________________
func get *(json :JsonNode; _:typedesc[AccessorSparseValues]) :AccessorSparseValues=
  ## Gets the AccessorSparseValues data contained in the given json node.
  ## Raises an ImportError exception if the fields required by spec are not there.
  # Validate the fields required to exist by spec
  if not json.hasBufferView: raise newException(ImportError, "Tried to get AccessorSparseValues data from a JsonNode that doesn't contain a bufferView field (required by spec).")
  # Get the data for the AccessorSparseValues
  result.bufferView = json["bufferView"].getInt.GltfId
  if json.hasByteOffset: result.byteOffset = json["byteOffset"].getInt.uint32
  if json.hasExtJson:    result.extensions = json.get(Extension)
  if json.hasExtras:     result.extras     = json.get(Extras)
#_______________________________________
func get *(json :JsonNode; _:typedesc[AccessorSparse]) :AccessorSparse=
  ## Gets the AccessorSparse data contained in the given json node.
  ## Raises an ImportError exception if the fields required by spec are not there.
  # Validate the fields required to exist by spec
  if not json.hasCount:   raise newException(ImportError, "Tried to get AccessorSparse data from a JsonNode that doesn't contain a count field (required by spec).")
  if not json.hasIndices: raise newException(ImportError, "Tried to get AccessorSparse data from a JsonNode that doesn't contain an indices field (required by spec).")
  if not json.hasValues:  raise newException(ImportError, "Tried to get AccessorSparse data from a JsonNode that doesn't contain a values field (required by spec).")
  # Get the data for the AccessorSparse
  result.count   = json["count"].getInt().uint32
  result.indices = json["indices"].get(AccessorSparseIndices)
  result.values  = json["values"].get(AccessorSparseValues)
  if json.hasExtJson: result.extensions = json.get(Extension)
  if json.hasExtras:  result.extras     = json.get(Extras)
#_______________________________________
func get *(json :JsonNode; _:typedesc[AccessorType]) :AccessorType=  parseEnum[AccessorType](json["type"].getStr())
  ## Gets the AccessorType of the given json node
  ## Assumes the given node has the field and its content is a valid AccessorType.
#_______________________________________
func get *(json :JsonNode; _:typedesc[Accessors]) :Accessors=
  ## Gets the Accessor list data contained in the given json node.
  ## Raises an ImportError exception if the fields required by spec are not there.
  for accs in json["accessors"].elems:
    # Validate the fields required to exist by spec
    if not accs.hasComponentType: raise newException(ImportError, "Tried to get accessor data from a JsonNode that doesn't contain a componentType field (required by spec).")
    if not accs.hasCount:         raise newException(ImportError, "Tried to get accessor data from a JsonNode that doesn't contain a count field (required by spec).")
    if not accs.hasType:          raise newException(ImportError, "Tried to get accessor data from a JsonNode that doesn't contain a type field (required by spec).")
    # Get the data for this accessor
    var tmp :Accessor
    tmp.bufferView = if accs.hasBufferView: accs["bufferView"].getInt().GltfId else: GltfId(-1)
    if accs.hasByteOffset: tmp.byteOffset = accs["byteOffset"].getInt().uint32
    tmp.componentType = accs["componentType"].getInt().AccessorComponentType
    if accs.hasNormalized: tmp.normalized = accs["normalized"].getBool()
    tmp.count = accs["count"].getInt().uint32
    tmp.typ   = accs.get(AccessorType)
    if accs.hasMaxv:
      for val in accs["max"].elems: tmp.maxv.add val.getFloat()
    if accs.hasMinv:
      for val in accs["min"].elems: tmp.minv.add val.getFloat()
    if accs.hasSparse:  tmp.sparse     = accs["sparse"].get(AccessorSparse)
    if accs.hasName:    tmp.name       = accs["name"].getStr()
    if accs.hasExtJson: tmp.extensions = accs.get(Extension)
    if accs.hasExtras:  tmp.extras     = accs.get(Extras)
    # Add the accessor to the result
    result.add tmp

