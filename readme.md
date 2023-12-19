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

> See the [relevant section](#why-i-changed-pure-nim-to-be-my-auxiliary-programming-language-instead-of-being-my-primary-focus) for an explaination of why this is the case.

---

### Why I changed Pure Nim to be my auxiliary programming language, instead of being my primary focus
> _Important:_  
> _This reason is very personal, and it is exclusively about using Nim in a manual-memory-management context._  
> _Nim is great as it is, and the GC performance is so optimized that it's barely noticeable that it is there._  
> _That's why I still think Nim is the best language for projects where a GC'ed workflow makes more sense._  

Nim with `--mm:none` was always my ideal language.  
But its clear that the GC:none feature (albeit niche) is only provided as a sidekick, and not really maintained as a core feature.  

I tried to get Nim to behave correctly with `--mm:none` for months and months.  
It takes an absurd amount of unnecessary effort to get it to a basic default state.  

And I'm not talking about the lack of GC removing half of the nim/std library because of nim's extensive use of seq/string in its stdlib.  
I'm talking about features that shouldn't even be allowed to exist at all in a gc:none context, because they leak memory and create untrackable bugs.  
_(eg: exceptions, object variants, dynamically allocated types, etc etc)_  

After all of that effort, and seeing how futile it was, I gave up on `--mm:none` completely.  
It would take a big amount of effort patching nim itself so that these issues are no longer there.  
And, sadly, based on experience, I'm not confident in my ability to communicate with Nim's leadership to do such work myself.  

This setback led me to consider other alternatives, including Zig or Pure C.  
But, in the end, I decided that from now on I will be programming with my [MinC](https://github.com/heysokam/minc) source-to-source language/compiler instead.  

As such, I will be deprecating most of my `n*dk` libraries.  
I will be creating my engine's devkit with MinC instead.  

That means, as it is detailed in the [Low Maintainance](#low-maintainance-mode) section, that this library will receive a very low/minimal amount of support.

