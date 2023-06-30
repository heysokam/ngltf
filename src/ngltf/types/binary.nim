#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________


#_________________________________________________
# File Header
#_____________________________
const Magic   *:uint32= 0x46546C67
const Version *:uint32= 2
type Header * = object
  magic    *:uint32
  version  *:uint32
  length   *:uint32
const HeaderSize *:int= Header.sizeof
static: assert HeaderSize == 12

