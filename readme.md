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
- Standard: `.gltf`+`.bin`
- Embedded: `.gltf` embedded json (base64) data
- Binary:   `.glb`
- Extensions: See the extensions section

An example of how the data contained in the gltf object could be accessed can be seen @[nimp/mdl.nim](https://github.com/heysokam/nimp/blob/master/src/nimp/mdl.nim).  

A complete implementation needs to depend on an image loader and a math library.  
Dependencies are purposedly kept away from this library,  
and are implemented in the @[heysokam/nimp](https://github.com/heysokam/nimp) abstraction instead.  

## How do I draw it?
This library is a raw reader.  
It is _(and will always be)_ API agnostic.  

This means that all that `ngltf` does is load everything contained in the gltf/bin/image files into memory,  
and give you a bunch of bytebuffer data that you can then use to draw in your application as you see fit.  

The glTF™ specification is created such that the buffers contained in the files are already setup for efficient GPU access.  
`ngltf` stores all this information (including its URI pointed data) inside the `GLTF` object that is returned to you when loading.  

The URI-pointed `Image`s pixel data is loaded into the `GLTF.images[N].data` extension field of each image entry _(the spec supports png and jpeg)_.  
And the `.bin` and `.glb` buffer data is loaded into the `GLTF.buffers[N].data` extension field of each buffer entry.  

For an example of how this data is used in practice, see the implementation @[nimp/mdl.nim](https://github.com/heysokam/nimp/blob/master/src/nimp/mdl.nim) and @[nimp/scn.nim](https://github.com/heysokam/nimp/blob/master/src/nimp/scn.nim).

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
```md
# TODO
- [ ] Punctual Lights               : `KHR_lights_punctual`

# Undecided
- [ ] Material: Anisotropy          : `KHR_materials_anisotropy`
- [ ] Material: Clearcoat           : `KHR_materials_clearcoat`
- [ ] Material: Emissive Strength   : `KHR_materials_emissive_strength`
- [ ] Material: Index of Refraction : `KHR_materials_ior`
- [ ] Material: Iridescence         : `KHR_materials_iridescence`
- [ ] Material: Sheen               : `KHR_materials_sheen`
- [ ] Material: Specular            : `KHR_materials_specular`
- [ ] Material: Transmission        : `KHR_materials_transmission`
- [ ] Material: Unlit               : `KHR_materials_unlit`
- [ ] Material: Variants            : `KHR_materials_variants`
- [ ] Material: Volume              : `KHR_materials_volume`

# Not Planned
The following extensions are not planned, but their data is not lost reading when reading the file.  
You should be able to use the information contained in the GLTF.extensions fields to implement them without issues.  
- [ ] Mesh: Quantization            : `KHR_mesh_quantization`
- [ ] Texture: KTX Basisu           : `KHR_texture_basisu`
- [ ] Texture: Transform            : `KHR_texture_transform`
- [ ] XMP Metadata                  : `KHR_xmp_json_ld`
```

#### Draco Compression
`KHR_draco_mesh_compression`
[Draco compression](https://google.github.io/draco/spec/) is currently not supported.  
The existing decoding implementation is written for usage from C++ code,  
so will need to figure out a way around it to make it usable from Nim.  

## License
```md
MIT  |  Copyright (C) Ivan Mar (sOkam!)
```

