#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# ngltf dependencies
import ./base


type AnimationChannelTargetPath *{.pure.}= enum
  ## The name of the node's TRS property to animate, or the `\"weights\"` of the Morph Targets it instantiates. For the `\"translation\"` property, the values that are provided by the sampler are the translation along the X, Y, and Z axes. For the `\"rotation\"` property, the values are a quaternion in the order (x, y, z, w), where w is the scalar. For the `\"scale\"` property, the values are the scaling factors along the X, Y, and Z axes.
  translation = "translation"
  rotation    = "rotation"
  scale       = "scale"
  weights     = "weights"

type AnimationChannelTarget * = object
  ## The descriptor of the animated property.
  node        *:GltfId                                ## The index of the node to animate. When undefined, the animated object **MAY** be defined by an extension.
  path        *:AnimationChannelTargetPath            ## The name of the node's TRS property to animate, or the `"weights"` of the Morph Targets it instantiates. For the `"translation"` property, the values that are provided by the sampler are the translation along the X, Y, and Z axes. For the `"rotation"` property, the values are a quaternion in the order (x, y, z, w), where w is the scalar. For the `"scale"` property, the values are the scaling factors along the X, Y, and Z axes.
  extensions  *:Extension                             ## JSON object with extension-specific objects.
  extras      *:Extras                                ## Application-specific data.

type AnimationChannel * = object
  ## An animation channel combines an animation sampler with a target property being animated.
  sampler     *:GltfId                                ## The index of a sampler in this animation used to compute the value for the target.
  target      *:AnimationChannelTarget                ## The descriptor of the animated property.
  extensions  *:Extension                             ## JSON object with extension-specific objects.
  extras      *:Extras                                ## Application-specific data.
type AnimationChannels * = seq[AnimationChannel]

type AnimationSamplerInterpolation *{.pure.}= enum
  ## Interpolation algorithm.
  Linear      = "LINEAR"                              ## The animated values are linearly interpolated between keyframes. When targeting a rotation, spherical linear interpolation (slerp) **SHOULD** be used to interpolate quaternions. The number of output elements **MUST** equal the number of input elements.
  Step        = "STEP"                                ## The animated values remain constant to the output of the first keyframe, until the next keyframe. The number of output elements **MUST** equal the number of input elements.
  CubicSpline = "CUBICSPLINE"                         ## The animation's interpolation is computed using a cubic spline with specified tangents. The number of output elements **MUST** equal three times the number of input elements. For each input element, the output stores three elements, an in-tangent, a spline vertex, and an out-tangent. There **MUST** be at least two keyframes when using this interpolation.

type AnimationSampler * = object
  ## An animation sampler combines timestamps with a sequence of output values and defines an interpolation algorithm.
  input               *:GltfId                        ## The index of an accessor containing keyframe timestamps.
  interpolation       *:AnimationSamplerInterpolation ## Interpolation algorithm.
  output              *:GltfId                        ## The index of an accessor, containing keyframe output values.
  extensions          *:Extension                     ## JSON object with extension-specific objects.
  extras              *:Extras                        ## Application-specific data.
type AnimationSamplers * = seq[AnimationSampler]

type Animation * = object
  ## A keyframe animation.
  channels            *:seq[AnimationChannel]         ## An array of animation channels. An animation channel combines an animation sampler with a target property being animated. Different channels of the same animation **MUST NOT** have the same targets.
  samplers            *:seq[AnimationSampler]         ## An array of animation samplers. An animation sampler combines timestamps with a sequence of output values and defines an interpolation algorithm.
  name                *:string                        ## The user-defined name of this object.
  extensions          *:Extension                     ## JSON object with extension-specific objects.
  extras              *:Extras                        ## Application-specific data.
type Animations * = seq[Animation]

type Skin * = object
  ## Joints and matrices defining a skin.
  inverseBindMatrices *:GltfId                        ## The index of the accessor containing the floating-point 4x4 inverse-bind matrices.
  skeleton            *:GltfId                        ## The index of the node used as a skeleton root.
  joints              *:seq[GltfId]                   ## Indices of skeleton nodes, used as joints in this skin.
  name                *:string                        ## The user-defined name of this object.
  extensions          *:Extension                     ## JSON object with extension-specific objects.
  extras              *:Extras                        ## Application-specific data.
type Skins * = seq[Skin]

