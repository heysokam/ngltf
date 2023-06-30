#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# Types imported by all other types.  |
#_____________________________________|
# External dependencies
import pkg/jsony


type Extras    * = RawJson ## Application-specific data.
type Extension * = RawJson ## JSON object with extension-specific objects.
type GltfId    * = uint32  ## Generic GLTF handle id


type GltfProperty * = object
  extensions  *:Extension  ## JSON object with extension-specific objects.
  extras      *:Extras     ## Application-specific data.

type GltfChildOfRootProperty * = object
  name        *:string     ## The user-defined name of this object.

