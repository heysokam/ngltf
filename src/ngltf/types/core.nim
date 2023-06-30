#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# Types imported only by the core GLTF file.  |
#_____________________________________________|
# ngltf dependencies
import ./base


type Asset * = object
  ## Metadata about the glTF asset.
  copyright    *:string       ## A copyright message suitable for display to credit the content creator.
  generator    *:string       ## Tool that generated this glTF model.  Useful for debugging.
  version      *:string       ## The glTF version in the form of `<major>.<minor>` that this asset targets.
  minVersion   *:string       ## The minimum glTF version in the form of `<major>.<minor>` that this asset targets. This property **MUST NOT** be greater than the asset version.
  extensions   *:Extension    ## JSON object with extension-specific objects.
  extras       *:Extras       ## Application-specific data.

type Node * = object
  ## A node in the node hierarchy.  When the node contains `skin`, all `mesh.primitives` **MUST** contain `JOINTS_0` and `WEIGHTS_0` attributes.  A node **MAY** have either a `matrix` or any combination of `translation`/`rotation`/`scale` (TRS) properties. TRS properties are converted to matrices and postmultiplied in the `T * R * S` order to compose the transformation matrix; first the scale is applied to the vertices, then the rotation, and then the translation. If none are provided, the transform is the identity. When a node is targeted for animation (referenced by an animation.channel.target), `matrix` **MUST NOT** be present.
  camera       *:seq[GltfId]  ## The index of the camera referenced by this node.
  children     *:seq[GltfId]  ## The indices of this node's children.
  skin         *:seq[GltfId]  ## The index of the skin referenced by this node.
  matrix       *:seq[float64] ## A floating-point 4x4 transformation matrix stored in column-major order.
  mesh         *:seq[GltfId]  ## The index of the mesh in this node.
  rotation     *:seq[float64] ## The node's unit quaternion rotation in the order (x, y, z, w), where w is the scalar.
  scale        *:seq[float64] ## The node's non-uniform scale, given as the scaling factors along the x, y, and z axes.
  translation  *:seq[float64] ## The node's translation along the x, y, and z axes.
  weights      *:seq[float64] ## The weights of the instantiated morph target. The number of array elements **MUST** match the number of morph targets of the referenced mesh. When defined, `mesh` **MUST** also be defined.
  name         *:string       ## The user-defined name of this object.
  extensions   *:Extension    ## JSON object with extension-specific objects.
  extras       *:Extras       ## Application-specific data.

type Scene * = object
  ## The root nodes of a scene.
  nodes        *:seq[GltfId]  ## The indices of each root node.
  name         *:string       ## The user-defined name of this object.
  extensions   *:Extension    ## JSON object with extension-specific objects.
  extras       *:Extras       ## Application-specific data.

