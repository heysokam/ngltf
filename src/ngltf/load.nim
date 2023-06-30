#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/os
import std/strformat
import std/json
# ndk dependencies
import ./paths
# ngltf dependencies
import ./types
import ./validate


#_____________________________________________________
proc loadBinary (file :Path) :Model=
  ##
#_____________________________________________________
proc loadJson (file :Path) :Model=
  ##
  new result
  let jsonRoot = file.string.readFile.parseJson
  let modelDir = file.splitFile.dir

  # result = parse(jsonRoot, modelDir=modelDir)

#_____________________________________________________
proc loadFile *(
    file    : Path;
    verbose : bool = false;
  ) :Model=
  ## Smart load a gltf file.
  ## Reads it as a .glb or .gltf file depending on its extension.
  if not file.isGLTF: raise newException(ImportError, &"Tried to load glTF from file {file.string}, but it is not a valid format.")
  if verbose: echo &"Loading {file.string}"
  if   file.splitFile.ext == ".glb":  result = file.loadBinary()
  elif file.splitFile.ext == ".gltf": result = file.loadJson()

#_____________________________________________________
proc loadMem *(buffer :string; verbose :bool= false) :Model=
  if verbose: echo &"Loading glTF from Memory Buffer"
  discard

#_____________________________________________________
proc load *(file :Path; verbose :bool= false) :Model=  file.loadFile( verbose )
proc load *(input :string; verbose :bool= false) :Model=
  ## Smart load a gltf.
  ## Reads it as a file if it exists, or as a bytebuffer if it doesn't
  if input.isFile(): Path(input).loadFile( verbose )
  else:              input.loadMem( verbose )

