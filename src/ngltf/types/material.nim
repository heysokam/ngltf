#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# ngltf dependencies
import ./base
import ./texture


#_______________________________________
const DefaultBaseColorFactor *:array[4,float64]=  [1'f64, 1, 1, 1]

#_______________________________________
type MaterialPBRMetallicRoughness * = object
  ## A set of parameter values that are used to define the metallic-roughness material model from Physically-Based Rendering (PBR) methodology.
  baseColorFactor           *:array[4, float64]            ## The factors for the base color of the material.
  baseColorTexture          *:TextureInfo                  ## The base color texture.
  metallicFactor            *:float64                      ## The factor for the metalness of the material.
  roughnessFactor           *:float64                      ## The factor for the roughness of the material.
  metallicRoughnessTexture  *:TextureInfo                  ## The metallic-roughness texture.
  extensions                *:Extension                    ## JSON object with extension-specific objects.
  extras                    *:Extras                       ## Application-specific data.

type MaterialNormalTextureInfo * = object
  index                     *:uint32                       ## The index of the texture.
  texCoord                  *:uint32                       ## The set index of texture's TEXCOORD attribute used for texture coordinate mapping.
  scale                     *:float64                      ## The scalar parameter applied to each normal vector of the normal texture.
  extensions                *:Extension                    ## JSON object with extension-specific objects.
  extras                    *:Extras                       ## Application-specific data.

type MaterialOcclusionTextureInfo * = object
  index                     *:uint32                       ## The index of the texture.
  texCoord                  *:uint32                       ## The set index of texture's TEXCOORD attribute used for texture coordinate mapping.
  strength                  *:float64                      ## A scalar multiplier controlling the amount of occlusion applied.
  extensions                *:Extension                    ## JSON object with extension-specific objects.
  extras                    *:Extras                       ## Application-specific data.

type MaterialAlphaMode *{.pure.}= enum
  ## The alpha rendering mode of the material.
  Opaque = "OPAQUE"                                        ## The alpha value is ignored, and the rendered output is fully opaque.
  Mask   = "MASK"                                          ## The rendered output is either fully opaque or fully transparent depending on the alpha value and the specified `alphaCutoff` value; the exact appearance of the edges **MAY** be subject to implementation-specific techniques such as \"`Alpha-to-Coverage`\".
  Blend  = "BLEND"                                         ## The alpha value is used to composite the source and destination areas. The rendered output is combined with the background using the normal painting operation (i.e. the Porter and Duff over operator).

type Material * = object
  ## The material appearance of a primitive.
  name                      *:string                       ## The user-defined name of this object.
  extensions                *:Extension                    ## JSON object with extension-specific objects.
  extras                    *:Extras                       ## Application-specific data.
  pbrMetallicRoughness      *:MaterialPBRMetallicRoughness ## A set of parameter values that are used to define the metallic-roughness material model from Physically Based Rendering (PBR) methodology. When undefined, all the default values of `pbrMetallicRoughness` **MUST** apply.
  normalTexture             *:MaterialNormalTextureInfo    ## The tangent space normal texture.
  occlusionTexture          *:MaterialOcclusionTextureInfo ## The occlusion texture.
  emissiveTexture           *:TextureInfo                  ## The emissive texture.
  emissiveFactor            *:array[3,float64]             ## The factors for the emissive color of the material.
  alphaMode                 *:MaterialAlphaMode            ## The alpha rendering mode of the material.
  alphaCutoff               *:float64                      ## The alpha cutoff value of the material.
  doubleSided               *:bool                         ## Specifies whether the material is double sided.
type Materials * = seq[Material]

