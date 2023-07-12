#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/os
import std/strformat
# ndk dependencies
import ./tool/paths
# ngltf dependencies
import ./types
import ./validate
import ./load/binary as loadBinary
import ./load/json   as loadJson


#_____________________________________________________
proc loadFile *(path :Path; verbose :bool= false) :GLTF=
  ## Smart load a gltf file into a GLTF object
  ## Reads it as a .glb or .gltf file depending on its extension.
  validate.isGLTF( path )
  if   verbose: echo &"Loading glTF file from:  {path.string}"
  if   path.splitFile.ext == ".gltf": result = loadJson.gltf(path)
  elif path.splitFile.ext == ".glb":  result = loadBinary.gltf(path)
  else:
    echo "WRN: Loading a gltf from {path.string} but its extension {path.string.splitFile.ext} is not known by loadFile(). Treating it as a .glb binary."
    result = loadBinary.gltf(path)
#_____________________________________________________
proc loadMem *(buffer :string; verbose :bool= false; dir :Path= getAppDir().Path) :GLTF=
  ## Loads a glb file from the given string bytebuffer into a GLTF object
  ## The input must be self-contained, and not reference any external resources in its buffers.
  ##   eg: Having an URI to load an image not stored in the given glb buffer is not allowed with this function.
  ##       If this limitation is ignored, external files will be searched relative to the main application binary location, unless specified otherwise.
  ##       This path will most likely be incorrect, and lead to an application crash if the glb file does reference external files.
  if verbose: echo "Loading a glTF from Memory into a GLTF object"
  result = loadBinary.gltf(buffer, dir)

#_____________________________________________________
proc load *(file :Path; verbose :bool= false) :GLTF=  file.loadFile( verbose )
  ## Loads a gltf file and returns the specified type of Data object.
proc load *(input :string; verbose :bool= false; dir = getAppDir().Path) :GLTF=
  ## Smart load a gltf file and returns the specified type of Data object.
  ## Reads it as a file if it exists, or as a bytebuffer if it doesn't.
  ## When the input is a bytebuffer, the data must be self-contained, and not reference any external resources in its buffers.
  ##   eg: Having an URI to load an image not stored in the given glb buffer is not allowed with this function.
  ##       If this limitation is ignored, external files will be searched relative to the main application binary location, unless specified otherwise.
  ##       This default path will most likely be incorrect, and lead to an application crash if the glb file does actually reference external files.
  if input.isFile(): Path(input).loadFile( verbose )
  else:              input.loadMem( verbose, dir )

