#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/json as stdjson
import std/strutils
# ngltf dependencies
import ../types/base
import ../types/animation
import ./base as loadBase


#_____________________________________________________
func get *(json :JsonNode; _:typedesc[AnimationChannelTarget]) :AnimationChannelTarget=
  ## Returns the AnimationChannelTarget data contained in the given json node.
  ## Raises an exception if the given node doesn't have the fields required by spec.
  # Validate the fields required to exist by spec
  if not json.hasPath: raise newException(ImportError, "Tried to load AnimationChannelTarget data from a json node that doesn't have a path field (required by spec).")
  # Get the data for this AnimationChannelTarget
  if json.hasNode: result.node = json["node"].getInt().GltfId
  result.path = parseEnum[AnimationChannelTargetPath]( json["path"].getStr() )
  if json.hasExtJson: result.extensions = json.get(Extension)
  if json.hasExtras:  result.extras     = json.get(Extras)
#_____________________________________________________
func get *(json :JsonNode; _:typedesc[AnimationChannels]) :AnimationChannels=
  ## Returns the AnimationChannels data contained in the given json node.
  ## Raises an exception if the given node doesn't have the fields required by spec.
  for chan in json["channels"]:
    # Validate the fields required to exist by spec
    if not chan.hasSampler: raise newException(ImportError, "Tried to load AnimationChannel data from a json node that doesn't have a sampler field (required by spec).")
    if not chan.hasChannel: raise newException(ImportError, "Tried to load AnimationChannel data from a json node that doesn't have a channel field (required by spec).")
    # Get the data for this AnimationChannel
    var tmp :AnimationChannel
    tmp.sampler = chan["sampler"].getInt.GltfId
    tmp.target  = chan["target"].get(AnimationChannelTarget)
    if chan.hasExtJson: tmp.extensions = chan.get(Extension)
    if chan.hasExtras:  tmp.extras     = chan.get(Extras)
    result.add tmp

#_____________________________________________________
func get *(json :JsonNode; _:typedesc[AnimationSamplers]) :AnimationSamplers=
  ## Returns the AnimationSamplers data contained in the given json node.
  ## Raises an exception if the given node doesn't have the fields required by spec.
  for smpl in json["samplers"]:
    # Validate the fields required to exist by spec
    if not smpl.hasInput():  raise newException(ImportError, "Tried to load AnimationSamplers data from a json node that doesn't have an input field (required by spec).")
    if not smpl.hasOutput(): raise newException(ImportError, "Tried to load AnimationSamplers data from a json node that doesn't have an output field (required by spec).")
    # Get the data for this AnimationSampler
    var tmp :AnimationSampler
    tmp.input  = smpl["input"].getInt.GltfId
    if smpl.hasInterpolation: tmp.interpolation = parseEnum[AnimationSamplerInterpolation]( smpl["interpolation"].getStr )
    tmp.output = smpl["output"].getInt.GltfId
    if smpl.hasExtJson: tmp.extensions = smpl.get(Extension)
    if smpl.hasExtras:  tmp.extras     = smpl.get(Extras)
    result.add tmp
#_____________________________________________________
func get *(json :JsonNode; _:typedesc[Animations]) :Animations=
  ## Returns the Animations data contained in the given json node.
  ## Raises an exception if the given node doesn't have the fields required by spec.
  for anim in json["animations"].elems:
    # Validate the fields required to exist by spec
    if not anim.hasChannels: raise newException(ImportError, "Tried to load Animations data from a json node that doesn't have a channels field (required by spec).")
    if not anim.hasSamplers: raise newException(ImportError, "Tried to load Animations data from a json node that doesn't have a samplers field (required by spec).")
    # Get the data for this Animation
    var tmp :Animation
    tmp.channels = anim.get(AnimationChannels)
    tmp.samplers = anim.get(AnimationSamplers)
    if anim.hasName:    tmp.name       = anim["name"].getStr()
    if anim.hasExtJson: tmp.extensions = anim.get(Extension)
    if anim.hasExtras:  tmp.extras     = anim.get(Extras)
    # Add the accessor to the result
    result.add tmp
#_____________________________________________________
func get *(json :JsonNode; _:typedesc[Skins]) :Skins=
  ## Returns the Skins data contained in the given json node.
  ## Raises an exception if the given node doesn't have the fields required by spec.
  for skin in json["skins"].elems:
    # Validate the fields required to exist by spec
    if not skin.hasJoints: raise newException(ImportError, "Tried to load Skins data from a json node that doesn't have a joints field (required by spec).")
    # Get the data for this Skin
    var tmp :Skin
    if skin.hasBindMatrices: tmp.inverseBindMatrices = skin["inverseBindMatrices"].getInt.GltfId
    if skin.hasSkeleton:     tmp.skeleton            = skin["skeleton"].getInt.GltfId
    tmp.joints = skin["joints"].get(GltfIdList)
    if skin.hasName:    tmp.name       = skin["name"].getStr()
    if skin.hasExtJson: tmp.extensions = skin.get(Extension)
    if skin.hasExtras:  tmp.extras     = skin.get(Extras)
    result.add tmp

