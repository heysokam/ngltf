#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# ngltf dependencies
import ./base


type AccessorSparseIndicesComponentType *{.pure.}= enum
  ## The indices data type.
  UnsignedByte  = 5121  ## UNSIGNED_BYTE
  UnsignedShort = 5123  ## UNSIGNED_SHORT
  UnsignedInt   = 5125  ## UNSIGNED_INT

type AccessorSparseIndices * = object
  ## An object pointing to a buffer view containing the indices of deviating accessor values. The number of indices is equal to `accessor.sparse.count`. Indices **MUST** strictly increase.
  bufferView     *:GltfId                             ## The index of the buffer view with sparse indices. The referenced buffer view **MUST NOT** have its `target` or `byteStride` properties defined. The buffer view and the optional `byteOffset` **MUST** be aligned to the `componentType` byte length.
  byteOffset     *:uint32                             ## The offset relative to the start of the buffer view in bytes.
  componentType  *:AccessorSparseIndicesComponentType ## The indices data type.
  extensions     *:Extension                          ## JSON object with extension-specific objects.
  extras         *:Extras                             ## Application-specific data.

type AccessorSparseValues * = object
  ## An object pointing to a buffer view containing the deviating accessor values. The number of elements is equal to `accessor.sparse.count` times number of components. The elements have the same component type as the base accessor. The elements are tightly packed. Data **MUST** be aligned following the same rules as the base accessor.
  bufferView     *:GltfId                             ## The index of the bufferView with sparse values. The referenced buffer view **MUST NOT** have its `target` or `byteStride` properties defined.
  byteOffset     *:uint32                             ## The offset relative to the start of the bufferView in bytes.
  extensions     *:Extension                          ## JSON object with extension-specific objects.
  extras         *:Extras                             ## Application-specific data.

type AccessorSparse * = object
  ## Sparse storage of accessor values that deviate from their initialization value.
  count          *:uint32                             ## Number of deviating accessor values stored in the sparse array.
  indices        *:AccessorSparseIndices              ## An object pointing to a buffer view containing the indices of deviating accessor values. The number of indices is equal to `count`. Indices **MUST** strictly increase.
  values         *:AccessorSparseValues               ## An object pointing to a buffer view containing the deviating accessor values.
  extensions     *:Extension                          ## JSON object with extension-specific objects.
  extras         *:Extras                             ## Application-specific data.

type AccessorComponentType *{.pure.}= enum
  ## The datatype of the accessor's components.
  `Byte`        = 5120  ## BYTE
  UnsignedByte  = 5121  ## UNSIGNED_BYTE
  Short         = 5122  ## SHORT
  UnsignedShort = 5123  ## UNSIGNED_SHORT
  UnsignedInt   = 5125  ## UNSIGNED_INT
  Float         = 5126  ## FLOAT

type AccessorType *{.pure.}= enum
  ## Specifies if the accessor's elements are scalars, vectors, or matrices.
  Scalar = "SCALAR"
  Vec2   = "VEC2"
  Vec3   = "VEC3"
  Vec4   = "VEC4"
  Mat2   = "MAT2"
  Mat3   = "MAT3"
  Mat4   = "MAT4"

type Accessor * = object
  ## A typed view into a buffer view that contains raw binary data.
  bufferView    *:GltfId                ## The index of the bufferView.
  byteOffset    *:uint32                ## The offset relative to the start of the buffer view in bytes.
  componentType *:AccessorComponentType ## The datatype of the accessor's components.
  normalized    *:bool                  ## Specifies whether integer data values are normalized before usage.
  count         *:uint32                ## The number of elements referenced by this accessor.
  typ           *:AccessorType          ## Specifies if the accessor's elements are scalars, vectors, or matrices.
  maxv          *:seq[float64]          ## Maximum value of each component in this accessor.
  minv          *:seq[float64]          ## Minimum value of each component in this accessor.
  sparse        *:AccessorSparse        ## Sparse storage of elements that deviate from their initialization value.
  name          *:string                ## The user-defined name of this object.
  extensions    *:Extension             ## JSON object with extension-specific objects.
  extras        *:Extras                ## Application-specific data.
type Accessors * = seq[Accessor]

