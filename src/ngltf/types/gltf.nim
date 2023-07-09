#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/sets
# ngltf dependencies
import ./base
import ./other
import ./accessor
import ./animation
import ./buffer
import ./camera
import ./material
import ./mesh
import ./sampler
import ./texture


type Gltf * = ref object
  ## The root object for a glTF asset.
  extensionsUsed     *:HashSet[string] ## Names of glTF extensions used in this asset.
  extensionsRequired *:HashSet[string] ## Names of glTF extensions required to properly load this asset.
  accessors          *:seq[Accessor]   ## An array of accessors.
  animations         *:seq[Animation]  ## An array of keyframe animations.
  asset              *:Asset           ## Metadata about the glTF asset.
  buffers            *:seq[Buffer]     ## An array of buffers.
  bufferViews        *:seq[BufferView] ## An array of bufferViews.
  cameras            *:seq[Camera]     ## An array of cameras.
  images             *:seq[Image]      ## An array of images.
  materials          *:seq[Material]   ## An array of materials.
  meshes             *:seq[Mesh]       ## An array of meshes.
  nodes              *:seq[Node]       ## An array of nodes.
  samplers           *:seq[Sampler]    ## An array of samplers.
  sceneID            *:GltfId          ## The index of the default scene.
  scenes             *:seq[Scene]      ## An array of scenes.
  skins              *:seq[Skin]       ## An array of skins.
  textures           *:seq[Texture]    ## An array of textures.
  extensions         *:Extension       ## JSON object with extension-specific objects.
  extras             *:Extras          ## Application-specific data.

