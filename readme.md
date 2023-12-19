> **Warning**:  
> _This library is in **Low Maintainance** mode._  
> _See the [relevant section](#low-maintainance-mode) for an explanation of what that means._  

![ngltf](./doc/res/gh_banner.png)
# Pure Nim glTF™ Reader
`ngltf` is a pure Nim reader implementation for the glTF™ file specification.  
glTF™ is an efficient, extensible and publishing format for transmission and loading of 3D scenes and models for engines and applications.  

This library is a raw reader with no dependencies.  

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
- Standard: `.gltf`+`.bin`
- Embedded: `.gltf` embedded json (base64) data
- Binary:   `.glb`
- Extensions: See the extensions section

A complete implementation needs to depend on an image loader and a math library.  
Dependencies are kept away from this library by design.  

## How do I draw it?
This library is a raw reader.  
It is _(and will always be)_ API agnostic.  

This means that all that `ngltf` does is load everything contained in the gltf/bin/image files into memory,  
and give you a bunch of bytebuffer data that you can then use to draw in your application as you see fit.  

The glTF™ specification is created such that the buffers contained in the files are already setup for efficient GPU access.  
`ngltf` stores all this information (including its URI pointed data) inside the `GLTF` object that is returned to you when loading.  

The URI-pointed `Image`s pixel data is loaded into the `GLTF.images[N].data` extension field of each image entry _(the spec supports png and jpeg)_.  
And the `.bin` and `.glb` buffer data is loaded into the `GLTF.buffers[N].data` extension field of each buffer entry.  

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

### Extensions
Extensions are currently not supported.  
Please open an issue/PR to discuss about them if you require any.  
> _See the [Low Maintainance](#low-maintainance-mode) section for a more detailed explanation about unsupported features._  

#### Draco Compression
`KHR_draco_mesh_compression`  
[Draco compression](https://google.github.io/draco/spec/) is currently not supported.  
The existing decoding implementation is written for usage from C++ code,  
so will need to figure out a way around it to make it usable from Nim.  
> _See the [Low Maintainance](#low-maintainance-mode) section for a more detailed explanation about unsupported features._  

## License
```md
MIT  |  Copyright (C) Ivan Mar (sOkam!)
```

## Low Maintainance mode
This library is in low maintainance mode.  

New features and extensions are unlikely to be implemented, unless:
- They are randomnly needed for some casual side project _(eg: a gamejam or similar)_  
- They are submitted through a PR  

Proposals and PRs are very welcomed, and will likely be accepted.  

