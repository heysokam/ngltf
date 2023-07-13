![ngltf](./doc/res/gh_banner.png)
# Pure Nim glTF™ Reader
`ngltf` is a pure Nim reader implementation for the glTF™ file specification.  
glTF™ is an efficient, extensible and publishing format for transmission and loading of 3D scenes and models for engines and applications.  

This library is a raw reader with no dependencies.  
Consider using @[heysokam/nimp](https://github.com/heysokam/nimp) for a more ergonomic and simple to use API.  

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

An example of how the data contained in the gltf object could be accessed can be seen @[nimp/mdl.nim](https://github.com/heysokam/nimp/src/nimp/mdl.nim).  

A complete implementation needs to depend on an image loader and a math library.  
Dependencies are purposedly kept away from this raw reader,  
and are implemented in the @[heysokam/nimp](https://github.com/heysokam/nimp) abstraction instead.  

## Internal
```md
# Spec Renames
- Model    : spec.Mesh
- Mesh     : spec.MeshPrimitive
- MeshType : spec.MeshPrimitiveMode
- SceneID  : spec.scene (singular). Renamed to clarify what it really is (root scene id).
# Spec Extensions
- Buffer   : Contains a bytebuffer with its corresponding `.bin` or `.glb` data buffers already loaded into memory.
- Image    : Contains a bytebuffer with its corresponding `.png` or `.jpg` data buffers already loaded into memory.
```

**License:**  MIT  |  Copyright (C) Ivan Mar (sOkam!)

