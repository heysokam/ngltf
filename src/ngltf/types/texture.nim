#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# ngltf dependencies
import ./base


type ImageMimeType *{.pure.}= enum
  jpeg = "image/jpeg"
  png  = "image/png"

type Image * = object
  ## Image data used to create a texture. Image **MAY** be referenced by an URI (or IRI) or a buffer view index.
  uri         *:URI           ## The URI (or IRI) of the image.
  mimeType    *:ImageMimeType ## The image's media type. This field **MUST** be defined when `bufferView` is defined.
  bufferView  *:GltfId        ## The index of the bufferView that contains the image. This field **MUST NOT** be defined when `uri` is defined.
  name        *:string        ## The user-defined name of this object.
  extensions  *:Extension     ## JSON object with extension-specific objects.
  extras      *:Extras        ## Application-specific data.
  data        *:ByteBuffer    ## ngltf.Extend -> Object containing the image's byte data
type Images * = seq[Image]

type TextureInfo * = object
  ## Reference to a texture.
  index       *:uint32        ## The index of the texture.
  texCoord    *:uint32        ## The set index of texture's TEXCOORD attribute used for texture coordinate mapping.
  extensions  *:Extension     ## JSON object with extension-specific objects.
  extras      *:Extras        ## Application-specific data.

type Texture * = object
  ## A texture and its sampler.
  sampler     *:GltfId        ## The index of the sampler used by this texture. When undefined, a sampler with repeat wrapping and auto filtering **SHOULD** be used.
  source      *:GltfId        ## The index of the image used by this texture. When undefined, an extension or other mechanism **SHOULD** supply an alternate texture source, otherwise behavior is undefined.
  name        *:string        ## The user-defined name of this object.
  extensions  *:Extension     ## JSON object with extension-specific objects.
  extras      *:Extras        ## Application-specific data.
type Textures * = seq[Texture]

