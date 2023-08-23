#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/os
import std/paths as stdPaths ; export stdPaths


#_____________________________________________________
# Paths: Default behavior missing
#_____________________________
proc len        *(p :Path) :int    {.borrow.}
proc readFile   *(p :Path) :string {.borrow.}
proc fileExists *(p :Path) :bool   {.borrow.}
proc `$` *(p :Path) :string {.borrow.}
proc isFile *(input :string|Path) :bool=  input.len < 32000 and input.fileExists()
  ## Returns true if the input is a file

