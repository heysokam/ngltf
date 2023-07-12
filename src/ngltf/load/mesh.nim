#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/tables
import std/json as stdjson
# ngltf dependencies
import ../types/base
import ../types/mesh
import ../validate
import ./base
import ./buffer


#_______________________________________
func get *(json :JsonNode; _:typedesc[Meshes]) :Meshes=
  ## Gets the Meshes data contained in the given json node.
  ## Raises an ImportError exception if the fields required by spec are not there.
  for mesh in json["primitives"].elems:
    # Validate the fields required to exist by spec
    if not mesh.hasAttributes: raise newException(ImportError, "Tried to get Meshes (spec.MeshPrimitives) data from a node that has no attributes field (required by spec).")
    # Get the data for the MeshPrimitive
    var tmp :Mesh
    tmp.attributes = mesh["attributes"].toTable()
    tmp.indices    = if mesh.hasIndices:  mesh["indices"].getInt.GltfId  else: GltfId(-1)
    tmp.material   = if mesh.hasMaterial: mesh["material"].getInt.GltfId else: GltfId(-1)
    tmp.mode       = if mesh.hasMode:     mesh["mode"].getInt().MeshType else: MeshType.Triangles
    if mesh.hasTargets: tmp.targets    = mesh["targets"].get(JsonStringList)
    if mesh.hasExtJson: tmp.extensions = mesh.get(Extension)
    if mesh.hasExtras:  tmp.extras     = mesh.get(Extras)
    result.add tmp
#_______________________________________
func get *(json :JsonNode; _:typedesc[Models]) :Models=
  ## Gets the Meshes list data contained in the given json node.
  ## Raises an ImportError exception if the fields required by spec are not there.
  for mdl in json["meshes"].elems:
    # Validate the fields required to exist by spec
    if not mdl.hasMeshes: raise newException(ImportError, "Tried to get Model (spec.Mesh) data from a node that has no primitives (aka meshes) field (required by spec).")
    # Get the data for the Mesh
    var tmp :Model
    tmp.meshes = mdl.get(Meshes)
    if mdl.hasWeights: tmp.weights    = mdl["weights"].get(Float64List)
    if mdl.hasName:    tmp.name       = mdl["name"].getStr()
    if mdl.hasExtJson: tmp.extensions = mdl.get(Extension)
    if mdl.hasExtras:  tmp.extras     = mdl.get(Extras)
    result.add tmp

