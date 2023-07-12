#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/tables
# ngltf dependencies
import ./base


type MeshAttribute *{.pure.}= enum
  pos   = "POSITION"
  norm  = "NORMAL"
  uv    = "TEXCOORD_0"  #todo: Map other uv coordinate slots "TEXCOORD_n"
  color = "COLOR_0"     #todo: Map other vertex colors slots "COLOR_n"
  tan   = "TANGENT"
  #todo "JOINTS_n", "WEIGHTS_n", [semantic]_[set_index], _APPSPECIFIC attributes

type MeshType * = enum
  ## spec.MeshPrimtiveMode. The topology type of primitives to render.
  Points        = 0  ## POINTS
  Lines         = 1  ## LINES
  LineLoop      = 2  ## LINE_LOOP
  LineStrip     = 3  ## LINE_STRIP
  Triangles     = 4  ## TRIANGLES  # <-- Default
  TriangleStrip = 5  ## TRIANGLE_STRIP
  TriangleFan   = 6  ## TRIANGLE_FAN

type MeshAttributes * = Table[string, GltfId]

type Mesh * = object
  ## spec.MeshPrimitives Geometry to be rendered with the given material.
  attributes  *:MeshAttributes     ## Table where each key corresponds to a mesh attribute semantic and each value is the index of the accessor containing attribute's data.
  indices     *:GltfId             ## The index of the accessor that contains the vertex indices.
  material    *:GltfId             ## The index of the material to apply to this primitive when rendering.
  mode        *:MeshType           ## spec.MeshPrimtiveMode. The topology type of primitives to render.
  targets     *:JsonStringList     ## An array of morph targets.
  extensions  *:Extension          ## JSON object with extension-specific objects.
  extras      *:Extras             ## Application-specific data.
type Meshes * = seq[Mesh]

type Model * = object
  ## spec.Mesh. A set of primitives to be rendered.  Its global transform is defined by a node that references it.
  meshes      *:Meshes             ## An array of spec.MeshPrimitives, each defining geometry to be rendered.
  weights     *:seq[float64]       ## Array of weights to be applied to the morph targets. The number of array elements **MUST** match the number of morph targets.
  name        *:string             ## The user-defined name of this object.
  extensions  *:Extension          ## JSON object with extension-specific objects.
  extras      *:Extras             ## Application-specific data.
type Models * = seq[Model]

