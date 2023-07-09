#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# ngltf dependencies
import ./base


type MeshPrimitiveMode *{.pure.}= enum
  ## The topology type of primitives to render.
  Points        = 0  ## POINTS
  Lines         = 1  ## LINES
  LineLoop      = 2  ## LINE_LOOP
  LineStrip     = 3  ## LINE_STRIP
  Triangles     = 4  ## TRIANGLES  # <-- Default
  TriangleStrip = 5  ## TRIANGLE_STRIP
  TriangleFan   = 6  ## TRIANGLE_FAN

type MeshPrimitive * = object
  ## Geometry to be rendered with the given material.
  attributes  *:JsonString         ## A plain JSON object, where each key corresponds to a mesh attribute semantic and each value is the index of the accessor containing attribute's data.
  indices     *:GltfId             ## The index of the accessor that contains the vertex indices.
  material    *:GltfId             ## The index of the material to apply to this primitive when rendering.
  mode        *:MeshPrimitiveMode  ## The topology type of primitives to render.
  targets     *:JsonStringList     ## An array of morph targets.
  extensions  *:Extension          ## JSON object with extension-specific objects.
  extras      *:Extras             ## Application-specific data.
type MeshPrimitives * = seq[MeshPrimitive]

type Mesh * = object
  ## A set of primitives to be rendered.  Its global transform is defined by a node that references it.
  primitives  *:MeshPrimitives     ## An array of primitives, each defining geometry to be rendered.
  weights     *:seq[float64]       ## Array of weights to be applied to the morph targets. The number of array elements **MUST** match the number of morph targets.
  name        *:string             ## The user-defined name of this object.
  extensions  *:Extension          ## JSON object with extension-specific objects.
  extras      *:Extras             ## Application-specific data.
type Meshes * = seq[Mesh]

