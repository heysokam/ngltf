#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# ngltf dependencies
import ./base


type MagFilter *{.pure.}= enum
  ## Magnification filter.
  Nearest                = 9728  ## NEAREST
  Linear                 = 9729  ## LINEAR

type MinFilter *{.pure.}= enum
  ## Minification filter.
  Nearest                = 9728  ## NEAREST
  Linear                 = 9729  ## LINEAR
  NearestMipmapNearest   = 9984  ## NEAREST_MIPMAP_NEAREST
  LinearMipmapNearest    = 9985  ## LINEAR_MIPMAP_NEAREST
  NearestMipmapLinear    = 9986  ## NEAREST_MIPMAP_LINEAR
  LinearMipmapLinear     = 9987  ## LINEAR_MIPMAP_LINEAR

type WrapS *{.pure.}= enum
  ## S (U) wrapping mode.
  Repeat                 = 10497 ## REPEAT
  ClampToEdge            = 33071 ## CLAMP_TO_EDGE
  MirroredRepeat         = 33648 ## MIRRORED_REPEAT

type WrapT *{.pure.}= enum
  ## T (V) wrapping mode.
  Repeat                 = 10497 ## REPEAT
  ClampToEdge            = 33071 ## CLAMP_TO_EDGE
  MirroredRepeat         = 33648 ## MIRRORED_REPEAT

type Sampler * = object
  ## Texture sampler properties for filtering and wrapping modes.
  magFilter   *:MagFilter     ## Magnification filter.
  minFilter   *:MinFilter     ## Minification filter.
  wrapS       *:WrapS         ## S (U) wrapping mode.
  wrapT       *:WrapT         ## T (V) wrapping mode.
  name        *:string        ## The user-defined name of this object.
  extensions  *:Extension     ## JSON object with extension-specific objects.
  extras      *:Extras        ## Application-specific data.
type Samplers * = seq[Sampler]

