#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# Types imported by all other types.  |
#_____________________________________|


type JsonString     * = string
type JsonStringList * = seq[JsonString]
type Extras         * = distinct JsonString ## JSON object with Application-specific data.
type Extension      * = distinct JsonString ## JSON object with extension-specific objects.
type GltfId         * = uint32              ## Generic GLTF handle id
type GltfIdList     * = seq[GltfId]
type Float64List    * = seq[float64]
type Matrix4        * = array[16,float64]
type Vector3        * = array[3,float64]
type Vector4        * = array[4,float64]

type GltfProperty * = object
  extensions  *:Extension  ## JSON object with extension-specific objects.
  extras      *:Extras     ## Application-specific data.

type GltfChildOfRootProperty * = object
  name        *:string     ## The user-defined name of this object.

