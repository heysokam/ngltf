#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# ngltf dependencies
import ./base


type CameraOrthographic * = object
  ## An orthographic camera containing properties to create an orthographic projection matrix.
  xmag          *:float64                 ## The floating-point horizontal magnification of the view. This value **MUST NOT** be equal to zero. This value **SHOULD NOT** be negative.
  ymag          *:float64                 ## The floating-point vertical magnification of the view. This value **MUST NOT** be equal to zero. This value **SHOULD NOT** be negative.
  zfar          *:float64                 ## The floating-point distance to the far clipping plane. This value **MUST NOT** be equal to zero. `zfar` **MUST** be greater than `znear`.
  znear         *:float64                 ## The floating-point distance to the near clipping plane.
  extensions    *:Extension               ## JSON object with extension-specific objects.
  extras        *:Extras                  ## Application-specific data.

type CameraPerspective * = object
  ## A perspective camera containing properties to create a perspective projection matrix.
  aspectRatio   *:float64                 ## The floating-point aspect ratio of the field of view.
  yfov          *:float64                 ## The floating-point vertical field of view in radians. This value **SHOULD** be less than π.
  zfar          *:float64                 ## The floating-point distance to the far clipping plane.
  znear         *:float64                 ## The floating-point distance to the near clipping plane.
  extensions    *:Extension               ## JSON object with extension-specific objects.
  extras        *:Extras                  ## Application-specific data.

type CameraType *{.pure.}= enum
  ## Specifies if the camera uses a perspective or orthographic projection.
  perspective  = "perspective"
  orthographic = "orthographic"

type Camera * = object
  ## A camera's projection.  A node **MAY** reference a camera to apply a transform to place the camera in the scene.
  orthographic  *:seq[CameraOrthographic] ## An orthographic camera containing properties to create an orthographic projection matrix. This property **MUST NOT** be defined when `perspective` is defined.
  perspective   *:seq[CameraPerspective]  ## A perspective camera containing properties to create a perspective projection matrix. This property **MUST NOT** be defined when `orthographic` is defined.
  `type`        *:CameraType              ## Specifies if the camera uses a perspective or orthographic projection.
  name          *:string                  ## The user-defined name of this object.
  extensions    *:Extension               ## JSON object with extension-specific objects.
  extras        *:Extras                  ## Application-specific data.

