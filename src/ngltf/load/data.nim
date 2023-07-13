#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/os
import std/strformat
import std/tables
# ngltf dependencies
import ../types/base
import ../types/accessor
import ../types/buffer
import ../types/mesh
import ../types/material
import ../types/gltf
import ../validate
import ../tool/paths
import ./binary as loadBinary
import ./json   as loadJson


#_____________________________________________________
# Types
#_______________________________________
# Intermediate Data types
type f32          = float32
type f64          = float64
type Pixel      * = tuple[r,g,b,a :byte]
type Color      * = tuple[r,g,b,a :float32]
type ColorRGB   * = tuple[r,g,b   :float32]
type Vector2    * = tuple[x,y     :float32]
type Vector3    * = tuple[x,y,z   :float32]
type Vector4    * = tuple[x,y,z,w :float32]
type UVector2   * = tuple[x,y     :uint32]
type UVector3   * = tuple[x,y,z   :uint32]
type U16Vector3 * = tuple[x,y,z   :uint16]
type Matrix3    * = tuple[e00,e01,e02, e10,e11,e12, e20,e21,e22 :float32]
type Matrix4    * = tuple[e00,e01,e02,e03, e10,e11,e12,e13, e20,e21,e22,e23, e30,e31,e32,e33 :float32]
type SomeIntermediate * = Pixel | Color | ColorRGB | Vector2 | Vector3 | Vector4 | UVector2 | UVector3 | U16Vector3 | Matrix3 | Matrix4
#_______________________________________
# Textures
# type TextureType *{.pure.}= enum
#   none
#   diffuse, specular, ambient, emissive,
#   height, normals, shininess, opacity,
#   displacement, lightmap, reflection, unknown
# type TextureData * = ref object
#   format  *:string
#   size    *:UVector2
#   pixels  *:seq[Pixel]
#_______________________________________
# type TextureInfo * = ref object
#   path  *:string
#   data  *:TextureData
# type TextureList * = array[TextureType, seq[TextureInfo]]

#_______________________________________
# Materials
type MaterialData * = ref object
#   id   *:int
#   tex  *:TextureList

#_______________________________________
# Meshes and Models
type MeshData * = ref object
  primitives  *:MeshType ## Types of primitives contained in the mesh
  name        *:string            ## Mesh name
  inds        *:seq[U16Vector3]   ## Face indices
  pos         *:seq[Vector3]      ## Vertex Positions
  colors      *:seq[Color]        ## Vertex colors
  uvs         *:seq[Vector2]      ## Texture coordinates
  norms       *:seq[Vector3]      ## Normal vectors
  # tans        *:seq[Vector3]      ## Tangents
  # bitans      *:seq[Vector3]      ## Bitangents
  material    *:MaterialData
#_______________________________________
type ModelData * = seq[MeshData]  # Models are a list of meshes

#_______________________________________
# Scene: Cameras
# type CameraData * = ref object
#   name   *:string
#   pos    *:Vector3
#   up     *:Vector3
#   lookat *:Vector3
#   fovx   *:float32
#   near   *:float32
#   far    *:float32
#   ratio  *:float32
#   width  *:float32 # OrthographicWidth
#_______________________________________
# Scene: Lights
# type LightData * = ref object
#   kind                 *:ai.LightSource
#   name                 *:string
#   position             *:Vector3
#   direction            *:Vector3
#   attenuationConst     *:float32
#   attenuationLinear    *:float32
#   attenuationQuadratic *:float32
#   colorDiffuse         *:ColorRGB
#   colorSpecular        *:ColorRGB
#   colorAmbient         *:ColorRGB
#   innerCone            *:float32
#   outerCone            *:float32
#_______________________________________
# Scene: All Data
type SceneData * = ref object
#   models *:seq[ModelData]
#   cams   *:seq[CameraData]
#   lights *:seq[LightData]

type SomeData * = ModelData | SceneData



#_____________________________________________________
# Procs
#_______________________________________
# Validation
#_____________________________
func onlyTriangles *(mesh :Mesh) :void=
  ## Checks that the given primitive contains Triangles. Raises an ImportError exception otherwise
  ## ngltf does not support non-Triangle data for Data objects.
  ## If you need other types of primitives, get the raw glTF object from the internal functions and extract the information from there.
  if not (mesh.mode == MeshType.Triangles): raise newException(ImportError, &"""\n
  Tried to get MeshData from a Mesh that contains non-Triangle primitives.
  ngltf does not support non-Triangle data.
  Get the raw gltf object and extract its contents directly if you need other types of primitives.""")
#_____________________________
func onlyTriangles *(mdl :Model) :void=
  ## Checks that all of the meshes in the given list contain only Triangles. Raises an ImportError exception otherwise.
  ## ngltf does not support non-Triangle data for Data objects.
  ## If you need other types of primitives, get the raw glTF object from the internal functions and extract the information from there.
  for mesh in mdl.meshes: mesh.onlyTriangles()
#_____________________________
func hasPositions *(mesh :Mesh)  :void=
  if not mesh.hasAttr( MeshAttribute.pos ): raise newException(ImportError, "Tried to load a Mesh (spec.MeshPrimtive) that has no vertex position information.")
func hasPositions *(mdl  :Model) :void=
  for mesh in mdl.meshes:
    if not mesh.hasAttr( MeshAttribute.pos ): raise newException(ImportError, "Tried to load a Model (spec.Mesh) that has no vertex position information in one or more of its meshes (spec.primitives).")
#_______________________________________
# Buffer: Data Access
#_____________________________
func get *[T :typedesc[SomeIntermediate]](buf :Buffer; t :T; accs :Accessor; view :BufferView; id :SomeInteger) :t=
  ## Returns the `id`th T object pointed by the accessor from the given buffer.
  let start = view.offset+accs.offset + accs.itemSize*id  # Start byte to read
  copyMem(result.addr, buf.data.bytes[start].addr, accs.itemSize)
#_____________________________
func get *[T :typedesc[SomeIntermediate]](buf :Buffer; t :T; accs :Accessor; view :BufferView; size,id :SomeInteger) :t=
  ## Returns the `id`th T object pointed by the accessor from the given buffer.
  let start = view.offset+accs.offset + size*id  # Start byte to read
  copyMem(result.addr, buf.data.bytes[start].addr, size)
#_______________________________________
# Mesh: Data Access
#_____________________________
iterator indices *(gltf :GLTF; mesh :Mesh) :data.U16Vector3=
  # note: Currently only accepts triangles data with uint16 components
  let accs = gltf.accessors[ mesh.indices ]
  let view = gltf.bufferViews[accs.bufferView]
  let buff = gltf.buffers[ view.buffer ]
  for id in 0..<accs.count div 3: yield buff.get(data.U16Vector3, accs, view, accs.itemSize*3, id)
#_____________________________
iterator positions *(gltf :GLTF; mesh :Mesh) :data.Vector3=
  let accs = gltf.accessors[ mesh.attributes[ $MeshAttribute.pos ] ]
  let view = gltf.bufferViews[accs.bufferView]
  let buff = gltf.buffers[ view.buffer ]
  for id in 0..<accs.count: yield buff.get(data.Vector3, accs, view, id)
#_____________________________
iterator colors *(gltf :GLTF; mesh :Mesh) :data.Color=
  let accs = gltf.accessors[ mesh.attributes[ $MeshAttribute.color ] ]
  let view = gltf.bufferViews[accs.bufferView]
  let buff = gltf.buffers[ view.buffer ]
  for id in 0..<accs.count: yield buff.get(data.Color, accs, view, id)
#_____________________________
iterator uvs *(gltf :GLTF; mesh :Mesh) :data.Vector2=
  let accs = gltf.accessors[ mesh.attributes[ $MeshAttribute.uv ] ]
  let view = gltf.bufferViews[accs.bufferView]
  let buff = gltf.buffers[ view.buffer ]
  for id in 0..<accs.count: yield buff.get(data.Vector2, accs, view, id)
#_____________________________
iterator normals *(gltf :GLTF; mesh :Mesh) :data.Vector3=
  let accs = gltf.accessors[ mesh.attributes[ $MeshAttribute.norm ] ]
  let view = gltf.bufferViews[accs.bufferView]
  let buff = gltf.buffers[ view.buffer ]
  for id in 0..<accs.count: yield buff.get(data.Vector3, accs, view, id)
#_______________________________________
# Mesh: ExportData Convert to *Data types
#_____________________________
template dbg () :void {.dirty.}=
  for id,it in result.pairs: debugEcho id," ",it
  debugEcho result.len
  debugEcho "\nAccessors:"
  for name,val in accs.fieldPairs:
    debugEcho "  ",name," ",val
  debugEcho "\nBufferViews:"
  for name,val in view.fieldPairs:
    debugEcho "  ",name," ",val
#_____________________________
func getPositions *(gltf :GLTF; mesh :Mesh) :seq[data.Vector3]=
  let accs = gltf.accessors[ mesh.attributes[ $MeshAttribute.pos ] ]
  let view = gltf.bufferViews[accs.bufferView]
  validate.sameLength(accs, view)
  result = newSeqOfCap[result[0].type](accs.count)
  for pos in gltf.positions(mesh): result.add pos
  # dbg
#_____________________________
func getIndices *(gltf :GLTF; mesh :Mesh) :seq[data.U16Vector3]=
  let accs = gltf.accessors[ mesh.indices ]
  let view = gltf.bufferViews[accs.bufferView]
  validate.sameLength(accs, view)
  result = newSeqOfCap[result[0].type](accs.count)
  for ind in gltf.indices(mesh): result.add ind
  # dbg
#_____________________________
func getColors *(gltf :GLTF; mesh :Mesh) :seq[data.Color]=
  let accs = gltf.accessors[ mesh.attributes[ $MeshAttribute.color ] ]
  let view = gltf.bufferViews[accs.bufferView]
  validate.sameLength(accs, view)
  result = newSeqOfCap[result[0].type](accs.count)
  for color in gltf.colors(mesh): result.add color
  # dbg
#_____________________________
func getUVs *(gltf :GLTF; mesh :Mesh) :seq[data.Vector2]=
  let accs = gltf.accessors[ mesh.attributes[ $MeshAttribute.uv ] ]
  let view = gltf.bufferViews[accs.bufferView]
  validate.sameLength(accs, view)
  result = newSeqOfCap[result[0].type](accs.count)
  for uv in gltf.uvs(mesh): result.add uv
  # dbg
#_____________________________
func getNormals *(gltf :GLTF; mesh :Mesh) :seq[data.Vector3]=
  let accs = gltf.accessors[ mesh.attributes[ $MeshAttribute.norm ] ]
  let view = gltf.bufferViews[accs.bufferView]
  validate.sameLength(accs, view)
  result = newSeqOfCap[result[0].type](accs.count)
  for norm in gltf.normals(mesh): result.add norm
  # dbg
#_____________________________
func getMaterial  *(gltf :GLTF; mesh :Mesh) :MaterialData=   discard # mesh.material

#_______________________________________
# Mesh: Convert to Export Data
#_____________________________
func getData *(gltf :GLTF; mesh :Mesh; name :string) :MeshData=
  ## Converts the given mesh into a MeshData object.
  new result
  onlyTriangles( mesh )
  validate.hasPositions( mesh )
  result.primitives = Triangles
  result.name       = name
  result.pos        = gltf.getPositions(mesh)
  if mesh.hasIndices:  result.inds     = gltf.getIndices(mesh)
  if mesh.hasColors:   result.colors   = gltf.getColors(mesh)
  if mesh.hasUVs:      result.uvs      = gltf.getUVs(mesh)
  if mesh.hasNormals:  result.norms    = gltf.getNormals(mesh)
  if mesh.hasMaterial: result.material = gltf.getMaterial(mesh)
#_____________________________
func getData *(gltf :GLTF; mdl :Model) :ModelData=
  ## Converts all meshes in the input model into a ModelData object (aka seq[MeshData])
  for id,mesh in mdl.meshes.pairs:  result.add gltf.getData(mesh, &"{mdl.name}_mesh{id}")
func getData *(gltf :GLTF; mdls :Models) :ModelData=
  ## Converts all meshes in the input model list into a single ModelData object (aka seq[MeshData])
  ## Completely ignores the structure of the gltf file, and assumes every mesh in the file is part of a single model.
  for mdl in mdls:
    for id,mesh in mdl.meshes.pairs:  result.add gltf.getData(mesh, &"{mdl.name}_mesh{id}")

##[
type MeshData * = ref object
  # name        *:string            ## Mesh name
  # inds        *:seq[UVector3]     ## Face indices
  # pos         *:seq[Vector3]      ## Vertex Positions
  # colors      *:seq[Color]        ## Vertex colors
  # uvs         *:seq[Vector2]      ## Texture coordinates
  # norms       *:seq[Vector3]      ## Normal vectors
  tans        *:seq[Vector3]      ## Tangents
  bitans      *:seq[Vector3]      ## Bitangents
  material    *:MaterialData
#_______________________________________
# type ModelData * = seq[MeshData]  # Models are a list of meshes

#_______________________________________
# type MeshAttributes * = Table[string, GltfId]

type MeshPrimitive * = object
  ## Geometry to be rendered with the given material.
  # attributes  *:MeshAttributes     ## Table where each key corresponds to a mesh attribute semantic and each value is the index of the accessor containing attribute's data.
  # indices     *:GltfId             ## The index of the accessor that contains the vertex indices.
  material    *:GltfId             ## The index of the material to apply to this primitive when rendering.
  # mode        *:MeshType           ## The topology type of primitives to render.
  targets     *:JsonStringList     ## An array of morph targets.
  # extensions  *:Extension          ## JSON object with extension-specific objects.
  # extras      *:Extras             ## Application-specific data.
type MeshPrimitives * = seq[MeshPrimitive]

type Mesh * = object
  ## A set of primitives to be rendered.  Its global transform is defined by a node that references it.
  # primitives  *:MeshPrimitives     ## An array of primitives, each defining geometry to be rendered.
  weights     *:seq[float64]       ## Array of weights to be applied to the morph targets. The number of array elements **MUST** match the number of morph targets.
  # name        *:string             ## The user-defined name of this object.
  # extensions  *:Extension          ## JSON object with extension-specific objects.
  # extras      *:Extras             ## Application-specific data.
# type Meshes * = seq[Mesh]

]##


#_____________________________________________________
# Json File Access
#_____________________________
proc jsonModel *(buffer :string; dir :Path) :ModelData=
  ## Loads a Model object from a string bytebuffer.
  ## Doesn't do any checks, assumes that the input buffer contains a `.gltf` json.
  var gltf = loadJson.gltf(buffer, dir)
  result   = gltf.getData(gltf.models)
proc jsonModelMem *(buffer :string; dir :Path) :ModelData=  buffer.jsonModel(dir)
  ## (alias) Loads a Model object from a string bytebuffer.
  ## Doesn't do any checks, assumes that the input buffer contains a `.gltf` json.
#_____________________________________________________
proc jsonModel *(file :Path) :ModelData=  file.readFile.jsonModel( file.splitFile.dir.Path )
  ## Loads a Model object from the given file path.
  ## Doesn't do any checks, assumes that the input is a `.gltf` json.
proc jsonModelFile *(file :Path) :ModelData=  file.jsonModel()
  ## (alias) Loads a Model object from the given file path.
  ## Doesn't do any checks, assumes that the input is a `.gltf` json.
#_____________________________________________________
proc jsonScene *(buffer :string; dir :Path) :SceneData=
  ## Loads a Model object from the given string bytebuffer.
  var gltf = loadJson.gltf(buffer, dir)
proc jsonSceneMem *(buffer :string; dir :Path) :SceneData=  buffer.jsonScene(dir)
  ## (alias) Loads a Model object from the given string bytebuffer.
#_____________________________________________________
proc jsonScene *(file :Path) :SceneData=  file.readFile.jsonScene( file.splitFile.dir.Path )
  ## Loads a Model object from the given file path.
proc jsonSceneFile *(file :Path) :SceneData=  file.jsonScene()
  ## (alias) Loads a Model object from the given file path.


#_____________________________________________________
# Binary File Access
#_____________________________
proc binModel *(buffer :string; dir :Path) :ModelData=
  ## Loads a Model object from the given string bytebuffer.
  var gltf = loadBinary.gltf(buffer, dir)
proc binModelMem *(buffer :string; dir :Path) :ModelData=  buffer.binModel(dir)
  ## (alias) Loads a Model object from the given string bytebuffer.
#_____________________________________________________
proc binModel *(file :Path) :ModelData=  file.readFile.binModel( file.splitFile.dir.Path )
  ## Loads a Model object from the given file path.
proc binModelFile *(file :Path) :ModelData=  file.binModel()
  ## (alias) Loads a Model object from the given file path.
#_____________________________________________________
proc binScene *(buffer :string; dir :Path) :SceneData=
  ## Loads a Model object from the given string bytebuffer.
  var gltf = loadBinary.gltf(buffer, dir)
proc binSceneMem *(buffer :string; dir :Path) :SceneData=  buffer.binScene(dir)
  ## (alias) Loads a Model object from the given string bytebuffer.
#_____________________________________________________
proc binScene *(file :Path) :SceneData=  file.readFile.binScene( file.splitFile.dir.Path )
  ## Loads a Model object from the given file path.
proc binSceneFile *(file :Path) :SceneData=  file.binScene()
  ## (alias) Loads a Model object from the given file path.


#_____________________________________________________
# Smart Load
#_____________________________
proc loadFile *[T :typedesc[SomeData]](
    path    : Path;
    t       : T;
    verbose : bool = false;
  ) :t=
  ## Smart load a gltf file into the specified type of Data object.
  ## Reads it as a .glb or .gltf file depending on its extension.
  const getBinary =
    when t is ModelData: binModelFile
    elif t is SceneData: binSceneFile
  const getJson =
    when t is ModelData: jsonModelFile
    elif t is SceneData: jsonSceneFile
  validate.isGLTF( path )
  if   verbose: echo &"Loading glTF file into a {$t} object from:  {path.string}  "
  if   path.splitFile.ext == ".gltf": result = getJson(path)
  elif path.splitFile.ext == ".glb":  result = getBinary(path)
  else:
    echo &"WRN: Loading a gltf.Model from {path.string} but its extension {path.string.splitFile.ext} is not known by loadFile(). Treating it as a .glb binary."
    result = getBinary(path)
#_____________________________________________________
proc loadMem *[T :typedesc[SomeData]](
    buffer  : string;
    t       : T;
    verbose : bool = false;
    dir     : Path = getAppDir().Path;
  ) :t=
  ## Loads a glb file from the given string bytebuffer into the specified type of Data object.
  ## The input must be self-contained, and not reference any external resources in its buffers.
  ##   eg: Having an URI to load an image not stored in the given glb buffer is not allowed with this function.
  ##       If this limitation is ignored, external files will be searched relative to the main application binary location, unless specified otherwise.
  ##       This path will most likely be incorrect, and lead to an application crash if the glb file does reference external files.
  if verbose: echo &"Loading a glTF from Memory into a {$t} object"
  const getBinary =
    when t is ModelData: binModelMem
    elif t is SceneData: binSceneMem
  result = getBinary(buffer, dir)

#_____________________________________________________
proc load *[T :typedesc[SomeData]](file :Path; t:typedesc[T]; verbose :bool= false) :t=  file.loadFile( t, verbose )
  ## Loads a gltf file and returns the specified type of Data object.
proc load *[T :typedesc[SomeData]](input :string; t:typedesc[T]; verbose :bool= false; dir = getAppDir().Path) :t=
  ## Smart load a gltf file and returns the specified type of Data object.
  ## Reads it as a file if it exists, or as a bytebuffer if it doesn't.
  ## When the input is a bytebuffer, the data must be self-contained, and not reference any external resources in its buffers.
  ##   eg: Having an URI to load an image not stored in the given glb buffer is not allowed with this function.
  ##       If this limitation is ignored, external files will be searched relative to the main application binary location, unless specified otherwise.
  ##       This default path will most likely be incorrect, and lead to an application crash if the glb file does actually reference external files.
  if input.isFile(): Path(input).loadFile( t, verbose )
  else:              input.loadMem( t, verbose, dir )
#_____________________________________________________
proc load *(file :Path; verbose :bool= false) :SceneData=  file.load( SceneData, verbose )
  ## Loads a gltf file into a SceneData object.
proc load *(input :string; verbose :bool= false; dir = getAppDir().Path) :SceneData=  input.load( SceneData, verbose, dir )
  ## Smart load a gltf into a SceneData object.
  ## Reads it as a file if it exists, or as a bytebuffer if it doesn't.
  ## When the input is a bytebuffer, the data must be self-contained, and not reference any external resources in its buffers.
  ##   eg: Having an URI to load an image not stored in the given glb buffer is not allowed with this function.
  ##       If this limitation is ignored, external files will be searched relative to the main application binary location, unless specified otherwise.
  ##       This default path will most likely be incorrect, and lead to an application crash if the glb file does actually reference external files.

