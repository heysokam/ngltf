#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/json as stdjson
# ngltf dependencies
import ../types/base
import ../types/sampler
import ./base


#_____________________________
func get *(json :JsonNode; _:typedesc[Samplers]) :Samplers=
  ## Gets the Sampler list from the given json node.
  for smpl in json["samplers"].elems:
    var tmp :Sampler
    if smpl.hasMagFilter: tmp.magFilter  = smpl["magFilter"].getInt.MagFilter
    if smpl.hasMinFilter: tmp.minFilter  = smpl["minFilter"].getInt.MinFilter
    if smpl.hasWrapS:     tmp.wrapS      = smpl["wrapS"].getInt.WrapS
    if smpl.hasWrapT:     tmp.wrapT      = smpl["wrapT"].getInt.WrapT
    if smpl.hasName:      tmp.name       = smpl["name"].getStr()
    if smpl.hasExtJson:   tmp.extensions = smpl.get(Extension)
    if smpl.hasExtras:    tmp.extras     = smpl.get(Extras)
    result.add tmp

