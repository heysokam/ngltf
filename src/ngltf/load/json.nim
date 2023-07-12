#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/json as stdjson
# ngltf dependencies
import ../tool/paths
import ../validate
import ../types
import ../types/base
import ../types/accessor
import ../types/animation
import ../types/other
import ../types/buffer
import ../types/camera
import ../types/texture
import ../types/material
import ../types/mesh
import ../types/sampler
import ./base
import ./extension
import ./accessor
import ./animation
import ./other
import ./buffer
import ./camera
import ./texture
import ./material
import ./mesh
import ./sampler


#_____________________________________________________
proc readData (gltf :var GLTF) :void=
  ## Reads the bytebuffer data pointed by the gltf file.
  ## Stores the data into their corresponding slots, taking it from uri.readFile and/or base64 embedded data
  for buf in gltf.buffers.mitems: buf.data = buf.get(ByteBuffer, gltf.rootDir)
  for img in gltf.images.mitems:  img.data = img.get(ByteBuffer, gltf.rootDir, gltf)
#_____________________________________________________
proc gltf *(buffer :string; dir :Path) :GLTF=
  ## Loads a GLTF object from a string bytebuffer.
  ## Doesn't do any checks, assumes that the input buffer contains a `.gltf` json.
  let json = buffer.parseJson
  validate(json)
  new result
  result.rootDir = dir
  if json.hasExtUsed     : result.extensionsUsed     = json.getUsed(Extension)
  if json.hasExtReq      : result.extensionsRequired = json.getReq(Extension)
  if json.hasAccessors   : result.accessors          = json.get(Accessors)
  if json.hasAnimations  : result.animations         = json.get(Animations)
  result.asset = json.get(Asset)
  if json.hasBuffers     : result.buffers            = json.get(Buffers)
  if json.hasBufferViews : result.bufferViews        = json.get(BufferViews)
  if json.hasCameras     : result.cameras            = json.get(Cameras)
  if json.hasImages      : result.images             = json.get(Images)
  if json.hasMaterials   : result.materials          = json.get(Materials)
  if json.hasModels      : result.models             = json.get(Models)
  if json.hasNodes       : result.nodes              = json.get(Nodes)
  if json.hasSamplers    : result.samplers           = json.get(Samplers)
  if json.hasSceneID     : result.sceneID            = json.get(SceneID)
  if json.hasScenes      : result.scenes             = json.get(Scenes)
  if json.hasSkins       : result.skins              = json.get(Skins)
  if json.hasTextures    : result.textures           = json.get(Textures)
  if json.hasExtJson     : result.extensions         = json.get(Extension)
  if json.hasExtras      : result.extras             = json.get(Extras)
  # Get the bytebuffer data into their corresponding slots
  result.readData()
#_____________________________________________________
proc gltf *(file :Path) :GLTF=  file.readFile.gltf( file.splitFile.dir.Path )
  ## Loads a gltf object from the given file path.
  ## Doesn't do any checks, assumes that the input is a `.gltf` json.

