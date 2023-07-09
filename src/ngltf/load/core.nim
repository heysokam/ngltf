#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/os
import std/strformat
import std/json as stdjson
# ndk dependencies
import ../paths
# ngltf dependencies
import ../types
import ../validate
import ./binary as loadBinary
import ./json   as loadJson



#_____________________________________________________
proc loadFile *(
    path    : Path;
    verbose : bool = false;
  ) :Model=
  ## Smart load a gltf file.
  ## Reads it as a .glb or .gltf file depending on its extension.
  if not path.isGLTF: raise newException(ImportError, &"Tried to load glTF from file {path.string}, but it is not a valid format.")
  if verbose: echo &"Loading {path.string}"
  if   path.splitFile.ext == ".glb":  result = loadBinary.model(path)
  elif path.splitFile.ext == ".gltf": result = loadJson.model(path)


#_____________________________________________________
proc loadMem *(buffer :string; verbose :bool= false) :Model=
  if verbose: echo &"Loading glTF from Memory Buffer"


#_____________________________________________________
proc load *(file :Path; verbose :bool= false) :Model=  file.loadFile( verbose )
proc load *(input :string; verbose :bool= false) :Model=
  ## Smart load a gltf into a Model object.
  ## Reads it as a file if it exists, or as a bytebuffer if it doesn't
  if input.isFile(): Path(input).loadFile( verbose )
  else:              input.loadMem( verbose )

