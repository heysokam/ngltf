#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/json as stdjson
# ngltf dependencies
import ../types/base
import ../types/other
import ./base


#_______________________________________
# Asset
#_____________________________
func get *(json :JsonNode; _:typedesc[Asset]) :Asset=
  ## Gets the Asset metadata from the given json node.
  ## Raises an exception if the node has no version field (required by spec)
  let asset = json["asset"]
  # Validate the fields required to exist by spec
  if not asset.hasVersion: raise newException(ImportError, "Tried to get the Asset data of a json node, but it doesn't have a version field (required by spec).")
  # Get the data for the Asset metadata
  if asset.hasCopyright:  result.copyright  = asset["copyright"].getStr()
  if asset.hasGenerator:  result.generator  = asset["generator"].getStr()
  result.version = asset["version"].getStr()
  if asset.hasMinVersion: result.minVersion = asset["minVersion"].getStr()
  if asset.hasExtJson:    result.extensions = asset.get(Extension)
  if asset.hasExtras:     result.extras     = asset.get(Extras)
#_____________________________
func get *(json :JsonNode; _:typedesc[Nodes]) :Nodes=
  ## Gets the Node list from the given json node.
  ## Raises an exception if the node has no version field (required by spec)
  for node in json["nodes"].elems:
    var tmp :Node
    if node.hasCamera:   tmp.camera     = node["camera"].getInt.GltfId
    if node.hasChildren: tmp.children   = node["children"].get(GltfIdList)
    if node.hasSkin:     tmp.skin       = node["skin"].getInt.GltfId
    tmp.matrix = if node.hasMatrix: node["matrix"].getMatrix4 else: Matrix4.identity()
    if node.hasMesh:     tmp.mesh       = node["mesh"].getInt.GltfId
    tmp.rotation    = if node.hasRotation: node["rotation"].getVector4 else: [0'f64, 0, 0, 1]
    tmp.scale       = if node.hasScale:    node["scale"].getVector3    else: [1'f64, 1, 1]
    tmp.translation = if node.hasTranslation: node["translation"].getVector3 else: [0'f64, 0, 0]
    if node.hasWeights:  tmp.weights    = node["weights"].get(Float64List)
    if node.hasName:     tmp.name       = node["name"].getStr()
    if node.hasExtJson:  tmp.extensions = node.get(Extension)
    if node.hasExtras:   tmp.extras     = node.get(Extras)
    result.add tmp
#_____________________________
func get *(json :JsonNode; _:typedesc[Scenes]) :Scenes=
  for scn in json["scenes"].elems:
    var tmp :Scene
    if scn.hasNodes:   tmp.nodes      = scn["nodes"].get(GltfIdList)
    if scn.hasName:    tmp.name       = scn["name"].getStr()
    if scn.hasExtJson: tmp.extensions = scn.get(Extension)
    if scn.hasExtras:  tmp.extras     = scn.get(Extras)
    result.add tmp
#_____________________________
func get *(json: JsonNode; _:typedesc[SceneID]) :SceneID=  json["scene"].getInt.SceneID

