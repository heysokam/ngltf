# GLTF reader for Nim
`ngltf` is a pure Nim reader implementation for the glTF file specification.  
glTF™ is an efficient, extensible and publishing format for transmission and loading of 3D scenes and models for engines and applications.  

This library is a raw reader, and has no dependencies other than the standard library.  
Consider using @[heysokam/nimp](https://github.com/heysokam/nimp) if you prefer a more ergonomic and simple to use API for loading 3D models.  

## How to use
```nim
import ngltf
let gltf = ngltf.load( "path/to/yourFile.gltf" )  # Smart load from the given path

... do something with the data ...
```
```nim
# Other smart load options
let glb  = ngltf.load("path/to/yourFile.glb")       # Smart load a binary gltf
let mem1 = ngltf.load(myStringBytebuffer)           # Smart load a binary from memory

# Explicit load
let file = ngltf.loadFile("path/to/yourFile.gltf")  # Explicit load a .gltf from a file
let mem2 = ngltf.loadMem(myStringBytebuffer)        # Explicit load a glb binary from memory
```
Supports:
- `.gltf`+`.bin`
- `.gltf` embedded (base64)
- `.glb`

An example of how the data contained in the gltf object could be accessed can be seen @[load/data.nim](src/ngltf/load/data).  
Said file is not maintained, and is kept only as a reference.  

A complete implementation needs to depend on an image loader and a math library.  
Said dependencies are purposedly kept away from this raw reader,  
and are implemented in the @[heysokam/nimp](https://github.com/heysokam/nimp) abstraction instead.  

## Spec Concepts Renames and Extensions
- Model    : spec.Mesh
- Mesh     : spec.MeshPrimitive
- MeshType : spec.MeshPrimitiveMode
- Buffer   : Contains a bytebuffer with its corresponding `.bin` or `.glb` data buffers already loaded into memory.
- SceneID  : spec.scene (singular). Renamed to clarify what it really does (root scene id).

## License
| MIT | Copyright (C) Ivan Mar (sOkam!)  
