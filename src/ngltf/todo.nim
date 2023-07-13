#_________________________________________________
# Lights:
#_______________________________________
# https://github.com/KhronosGroup/glTF/tree/main/extensions/2.0/Khronos/KHR_lights_punctual

#_________________________________________________
# Accessor : Data Validation
#_______________________________________
# AccessorSparseIndices : Number of AccessorSparseIndices is equal to AccessorSparse.count
# AccessorSparseIndices : MUST increase.
# AccessorSparseIndices.bufferView : The referenced buffer view MUST NOT have its target or byteStride properties defined.
# AccessorSparseIndices.bufferView : The buffer view and the optional byteOffset MUST be aligned to the componentType byte length.
#_______________________________________
# AccessorSparseValues : Number of AccessorSparseValues is equal to Accessor.count times number of components
# AccessorSparseValues : The elements have the same component type as the base accessor.
# AccessorSparseValues : The elements are tightly packed.
# AccessorSparseValues : Data MUST be aligned following the same rules as the base accessor.
# AccessorSparseValues.bufferView : The referenced buffer view MUST NOT have its target or byteStride properties defined.

#_________________________________________________
# Animation : Data Validation
#_______________________________________
# Animation.channels : Different channels of the same animation MUST NOT have the same targets.
# animation.channel.target.node : When undefined, the animated object MAY be defined by an extension.
# animation.sampler.input : The accessor MUST be of scalar type with floating-point components.
# animation.sampler.input : The values represent time in seconds with time[0] >= 0.0, and strictly increasing values, i.e., time[n + 1] > time[n].
# animation.sampler.interpolation."LINEAR"      : When targeting a rotation, spherical linear interpolation (slerp) SHOULD be used to interpolate quaternions.
# animation.sampler.interpolation."LINEAR"      : The number of output elements MUST equal the number of input elements.
# animation.sampler.interpolation."STEP"        : The number of output elements MUST equal the number of input elements.
# animation.sampler.interpolation."CUBICSPLINE" : The number of output elements MUST equal three times the number of input elements.
# animation.sampler.interpolation."CUBICSPLINE" : There MUST be at least two keyframes when using this interpolation.

#_________________________________________________
# Asset
#_______________________________________
# parseVersion()   : Pattern: ^[0-9]+\.[0-9]+$
# asset.minVersion : This property MUST NOT be greater than the asset version.

#_________________________________________________
# Buffer
#_______________________________________
# buffer.uri            : Instead of referencing an external file, this field MAY contain a data:-URI.
# bufferView.byteStride : When two or more accessors use the same buffer view, this field MUST be defined.

#_________________________________________________
# Camera
#_______________________________________
# Camera                   : A node MAY reference a camera to apply a transform to place the camera in the scene.
# camera.orthographic      : This property MUST NOT be defined when perspective is defined.
# camera.perspective       : This property MUST NOT be defined when orthographic is defined.
# camera.orthographic.xmag : This value MUST NOT be equal to zero.
# camera.orthographic.xmag : This value SHOULD NOT be negative.
# camera.orthographic.ymag : This value MUST NOT be equal to zero.
# camera.orthographic.ymag : This value SHOULD NOT be negative.
# camera.orthographic.zfar : This value MUST NOT be equal to zero.
# camera.orthographic.zfar : zfar MUST be greater than znear.

#_________________________________________________
# Texture
#_______________________________________
# image.uri        : Instead of referencing an external file, this field MAY contain a data:-URI.
# image.uri        : This field MUST NOT be defined when bufferView is defined.
# image.mimeType   : This field MUST be defined when bufferView is defined.
# image.bufferView : This field MUST NOT be defined when uri is defined.

#_________________________________________________
# Material
#_______________________________________
# material.normalTexture    : If a fourth component (A) is present, it MUST be ignored.
# material.normalTexture    : When undefined, the material does not have a tangent space normal texture.
# material.occlusionTexture : If other channels are present (GBA), they MUST be ignored for occlusion calculations.
# material.occlusionTexture : When undefined, the material does not have an occlusion texture.
# material.emissiveTexture  : If a fourth component (A) is present, it MUST be ignored.
# material.emissiveTexture  : When undefined, the texture MUST be sampled as having 1.0 in RGB components.

#_________________________________________________
# Mesh
#_______________________________________
# mesh.primitive.indices : When this is undefined, the primitive defines non-indexed geometry.
# mesh.primitive.indices : When defined, the accessor MUST have SCALAR type and an unsigned integer component type.

#_________________________________________________
# Node
#_______________________________________
# Node          : When the node contains skin, all mesh.primitives MUST contain JOINTS_0 and WEIGHTS_0 attributes.
# Node          : A node MAY have either a matrix or any combination of translation/rotation/scale (TRS) properties.
# Node          : TRS properties are converted to matrices and postmultiplied in the T * R * S order to compose the transformation matrix; first the scale is applied to the vertices, then the rotation, and then the translation.
# Node          : If none are provided, the transform is the identity.
# Node          : When a node is targeted for animation (referenced by an animation.channel.target), matrix MUST NOT be present.
# node.children : Each element in the array MUST be unique.
# node.children : Each element in the array MUST be greater than or equal to 0.
# node.skin     : When a skin is referenced by a node within a scene, all joints used by the skin MUST belong to the same scene.
# node.skin     : When defined, mesh MUST also be defined.
# node.rotation : Each element in the array MUST be greater than or equal to -1 and less than or equal to 1.
# node.weights  : The number of array elements MUST match the number of morph targets of the referenced mesh.
# node.weights  : When defined, mesh MUST also be defined.

#_________________________________________________
# Scene
#_______________________________________
# sceneID     : This property MUST NOT be defined, when scenes is undefined.
# scene.nodes : Each element in the array MUST be greater than or equal to 0.
# scene.nodes : Each element in the array MUST be unique.

#_________________________________________________
# Sampler
#_______________________________________
# texture.sampler : When undefined, a sampler with repeat wrapping and auto filtering SHOULD be used.
# texture.source  : When undefined, an extension or other mechanism SHOULD supply an alternate texture source, otherwise behavior is undefined.

