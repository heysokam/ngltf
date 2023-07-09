#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/json as stdjson
# External dependencies
import pkg/jsony
# ngltf dependencies
import ../types/base
import ../types/mesh
import ./base

#_______________________________________
func get *(json :JsonNode; _:typedesc[MeshPrimitives]) :MeshPrimitives=
  ## Gets the MeshPrimitive data contained in the given json node.
  ## Raises an ImportError exception if the fields required by spec are not there.
  for prm in json["primitives"].elems:
    # Validate the fields required to exist by spec
    if not prm.hasAttributes: raise newException(ImportError, "Tried to get MeshPrimitive data from a node that has no attributes field (required by spec).")
    # Get the data for the MeshPrimitive
    var tmp :MeshPrimitive
    tmp.attributes = prm["attributes"].toJson.JsonString
    if prm.hasIndices:  tmp.indices    = prm["indices"].getInt.GltfId
    if prm.hasMaterial: tmp.material   = prm["material"].getInt.GltfId
    tmp.mode = if prm.hasMode: prm["mode"].getInt().MeshPrimitiveMode else: MeshPrimitiveMode.Triangles
    if prm.hasTargets:  tmp.targets    = prm["targets"].get(JsonStringList)
    if prm.hasExtJson:  tmp.extensions = prm.get(Extension)
    if prm.hasExtras:   tmp.extras     = prm.get(Extras)
    result.add tmp
#_______________________________________
func get *(json :JsonNode; _:typedesc[Meshes]) :Meshes=
  ## Gets the Meshes list data contained in the given json node.
  ## Raises an ImportError exception if the fields required by spec are not there.
  for mesh in json["meshes"].elems:
    # Validate the fields required to exist by spec
    if not mesh.hasPrimitives: raise newException(ImportError, "Tried to get Mesh data from a node that has no primitives field (required by spec).")
    # Get the data for the Mesh
    var tmp :Mesh
    tmp.primitives = mesh.get(MeshPrimitives)
    if mesh.hasWeights: tmp.weights    = mesh["weights"].get(Float64List)
    if mesh.hasName:    tmp.name       = mesh["name"].getStr()
    if mesh.hasExtJson: tmp.extensions = mesh.get(Extension)
    if mesh.hasExtras:  tmp.extras     = mesh.get(Extras)
    result.add tmp

