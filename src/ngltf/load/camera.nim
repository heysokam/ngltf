#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/strutils
import std/json as stdjson
# ngltf dependencies
import ../types/base
import ../types/camera
import ../validate
import ./base


#_______________________________________
func get *(json :JsonNode; _:typedesc[CameraOrthographic]) :CameraOrthographic=
  ## Gets the CameraOrthographic data from the given json node.
  ## Raises an exception if any of the fields required by spec is missing.
  # Validate the fields required to exist by spec
  if not json.hasXmag:  raise newException(ImportError, "Tried to get CameraOrthographic data from a node that has no xmag field (required by spec).")
  if not json.hasYmag:  raise newException(ImportError, "Tried to get CameraOrthographic data from a node that has no ymag field (required by spec).")
  if not json.hasZfar:  raise newException(ImportError, "Tried to get CameraOrthographic data from a node that has no zfar field (required by spec).")
  if not json.hasZnear: raise newException(ImportError, "Tried to get CameraOrthographic data from a node that has no znear field (required by spec).")
  # Get the CameraOrthographic data
  result.xmag  = json["xmag"].getFloat()
  result.ymag  = json["ymag"].getFloat()
  result.zfar  = json["zfar"].getFloat()
  result.znear = json["znear"].getFloat()
  if json.hasExtJson: result.extensions = json.get(Extension)
  if json.hasExtras:  result.extras     = json.get(Extras)
#_______________________________________
func get *(json :JsonNode; _:typedesc[CameraPerspective]) :CameraPerspective=
  ## Gets the CameraPerspective data from the given json node.
  ## Raises an exception if any of the fields required by spec is missing.
  # Validate the fields required to exist by spec
  if not json.hasYfov:  raise newException(ImportError, "Tried to get CameraPerspective data from a node that has no yfov field (required by spec).")
  if not json.hasZnear: raise newException(ImportError, "Tried to get CameraPerspective data from a node that has no znear field (required by spec).")
  # Get the CameraPerspective data
  if json.hasAspectRatio: result.aspectRatio = json["aspectRatio"].getFloat()
  result.yfov  = json["yfov"].getFloat()
  if json.hasZfar:    result.zfar = json["zfar"].getFloat()
  result.znear = json["znear"].getFloat()
  if json.hasExtJson: result.extensions = json.get(Extension)
  if json.hasExtras:  result.extras     = json.get(Extras)
#_______________________________________
func get *(json :JsonNode; _:typedesc[Cameras]) :Cameras=
  ## Gets the Cameras data from the given json node.
  ## Raises an exception if any of the elements is missing a field required by spec
  for cam in json["cameras"].elems:
    # Validate the fields required to exist by spec
    if cam.hasBoth("orthographic", "perspective"): raise newException(ImportError, "Tried to get Camera data from a node that has both orthographic and perspective camera information in the same camera (not allowed by spec).")
    if not cam.hasType: raise newException(ImportError, "Tried to get Camera data from a node that has no type field (required by spec).")
    # Get the data for this Camera
    var tmp :Camera
    if   cam.hasOrthographic: tmp.orthographic = cam.get(CameraOrthographic)
    elif cam.hasPerspective:  tmp.perspective  = cam.get(CameraPerspective)
    tmp.typ = parseEnum[CameraType]( cam["type"].getStr() )
    if cam.hasName:    tmp.name       = cam["name"].getStr()
    if cam.hasExtJson: tmp.extensions = cam.get(Extension)
    if cam.hasExtras:  tmp.extras     = cam.get(Extras)
    result.add tmp

