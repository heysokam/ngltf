#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# Types only used by the j2nim standalone tool  |
#_______________________________________________|


#_____________________________
type SchemaError    * = object of IOerror
const SchemaVersion * = "https://json-schema.org/draft/2020-12/schema"
#_____________________________
type Key *{.pure.}= enum
  ## Key names for accessing the different json properties
  id       = "$id"                     ## ID of the schema file. Always its filename, because its referenced by it from nested refs.
  schema   = "$schema"                 ## Schema version used by the file
  typename = "title"                   ## TypeName of the schema node
  kind     = "type"                    ## TypeKind of the schema node
  filds    = "properties"              ## TypeFields. The object has member fields when this property exists.  (fields conflicts with a nim.system.iterator)
  item     = "items"                   ## Elements of an array type
  refer    = "$ref"                    ## Reference keyword. Links to another subschema to load.
  allOf    = "allOf"                   ## Types might contain references inside the `items` or `allOf` fields
  generics = "anyOf"                   ## A type is a generic when this field exists.
  extras   = "additionalProperties"    ## Extensions that are not registered by the schema, but could be present
  hashset  = "uniqueItems"             ## An array is a HashSet when unique items is active.
  someEnum = "anyOf"                   ## Type field is an enum when it has an `anyOf` entry.
  minimum  = "minimum"                 ## Entry has a minimum value (for number/integer)
  maximum  = "maximum"                 ## Entry has a maximum value (for number/integer)
  cmtShort = "description"             ## Stores the short comment that concisely describes the component
  cmtLong  = "gltf_sectionDescription" ## Stores the long comment that describes the component and its detailed usage
converter toStr * (key :Key) :string=  $key
  ## Autoconvert to string for passing the enum to the json libraries
const BaseTypeIDs * = [
  ## Base type ids, based on the schema file list. Only contains types that have a "title" and "type" members
  "accessor.sparse.indices.schema.json",
  "accessor.sparse.schema.json",
  "accessor.schema.json",
  "accessor.sparse.values.schema.json",
  "animation.sampler.schema.json",
  "animation.schema.json",
  "animation.channel.schema.json",
  "animation.channel.target.schema.json",
  "asset.schema.json",
  "buffer.schema.json",
  "bufferView.schema.json",
  "camera.orthographic.schema.json",
  "camera.perspective.schema.json",
  "camera.schema.json",
  "extension.schema.json",
  "extras.schema.json",
  "glTF.schema.json",
  "glTFid.schema.json",
  "glTFProperty.schema.json",
  "glTFChildOfRootProperty.schema.json",
  "image.schema.json",
  "material.normalTextureInfo.schema.json",
  "material.pbrMetallicRoughness.schema.json",
  "material.occlusionTextureInfo.schema.json",
  "material.schema.json",
  "mesh.primitive.schema.json",
  "mesh.schema.json",
  "node.schema.json",
  "sampler.schema.json",
  "scene.schema.json",
  "skin.schema.json",
  "texture.schema.json",
  "textureInfo.schema.json",
  ] # << BaseTypes
#_____________________________
# CLI options
type ArgList * = seq[string]
type OptList * = object
  short *:seq[string]
  long  *:seq[string]
#_____________________________
type CLI * = object
  args  *:ArgList
  opts  *:OptList

