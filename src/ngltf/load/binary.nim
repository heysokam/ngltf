#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# ngltf dependencies
import ../types
import ../paths


#_____________________________________________________
proc gltf *(buffer :string) :GLTF=
  ## Loads a GLTF object from a string bytebuffer.
  discard
#_____________________________________________________
proc gltf *(file :Path) :GLTF=
  ## Loads a GLTF object from the given file path.
  discard

#_____________________________________________________
proc model *(buffer :string) :Model=
  ## Loads a Model object from the given file path.
  discard
#_____________________________________________________
proc model *(file :Path) :Model=
  ## Loads a Model object from a string bytebuffer.
  discard

