#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# ngltf dependencies
import ./types/gltf as gltfType ; export gltfType


#_________________________________________________
# Error management
#_____________________________
type ImportError * = object of IOError

#_________________________________________________
# Output Data
#_____________________________
type Model * = ref object
  # # All of the data that is indexed into
  # buffers        *:seq[string]
  # bufferViews    *:seq[BufferView]
  # textures       *:seq[Texture]
  # samplers       *:seq[Sampler]
  # images         *:seq[Image]
  # animations     *:seq[Animation]
  # materials      *:seq[Material]
  # accessors      *:seq[Accessor]
  # primitives     *:seq[Primitive]
  # meshes         *:seq[Mesh]
  # nodes          *:seq[Node]
  # scenes         *:seq[Scene]
  # # State
  # bufferIds      *:seq[GLuint]
  # textureIds     *:seq[GLuint]
  # vertexArrayIds *:seq[GLuint]
  # animationState *:seq[AnimationState]
  # # Model properties
  # scene          *:Natural

