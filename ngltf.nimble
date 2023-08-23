#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
import std/[ os,strformat ]

#_____________________________
# Package
packageName   = "ngltf"
version       = "0.1.0"
author        = "sOkam"
description   = "n*glTF | Pure Nim glTF™ Reader"
license       = "MIT"
let gitURL    = &"https://github.com/heysokam/{packageName}"


#_____________________________
# Build Requirements
requires "nim >= 2.0.0"


#_____________________________
# Folders
srcDir          = "src"
binDir          = "bin"
let docDir      = "doc"
let cacheDir    = binDir/"nimcache"
let examplesDir = "examples"
let testsDir    = "tests"
let resDir      = testsDir/"res"


#_________________
# Helpers        |
const vlevel = when defined(debug): 2 else: 1
const mode   = when defined(debug): "-d:debug" elif defined(release): "-d:release" elif defined(danger): "-d:danger" else: ""
let nimcr = &"nim c -r --verbosity:{vlevel} {mode} --hint:Conf:off --hint:Link:off --hint:Exec:off --nimcache:{cacheDir} --outdir:{binDir}"
  ## Compile and run, outputting to binDir
proc runFile (file, dir, args :string) :void=  exec &"{nimcr} {dir/file} {args}"
  ## Runs file from the given dir, using the nimcr command, and passing it the given args
proc runFile (file :string) :void=  file.runFile( "", "" )
  ## Runs file using the nimcr command
proc runTest (file :string) :void=  file.runFile(testsDir, "")
  ## Runs the given test file. Assumes the file is stored in the default testsDir folder
proc runExample (file :string) :void=  file.runFile(examplesDir, "")
  ## Runs the given test file. Assumes the file is stored in the default testsDir folder
template example (name :untyped; descr,file :static string)=
  ## Generates a task to build+run the given example
  let sname = astToStr(name)  # string name
  taskRequires sname, "SomePackage__123"  ## Doc
  task name, descr:
    runExample file

#_____________________________
# Tasks
#_________
# Tests  |
task tests, "Internal:  Builds and runs all tests in the testsDir folder.":
  # Tests requirements
  cpDir(resDir, binDir/"res")  ## Copy the test resources to the bin resources folder
  for file in testsDir.listFiles():
    if file.lastPathPart.startsWith('t'):
      try: runFile file
      except: echo &" └─ Failed to run one of the tests from  {file}"
#____________
# Internal  |
task push, "Internal:  Pushes the git repository, and orders to create a new git tag for the package, using the latest version.":
  ## Does nothing when local and remote versions are the same.
  requires "https://github.com/beef331/graffiti.git"
  exec "git push"  # Requires local auth
  exec &"graffiti ./{packageName}.nimble"
#__________
# docgen  |
task docgen, "Internal:  Generates documentation using Nim's docgen tools.":
  echo &"{packageName}: Starting docgen..."
  exec &"nim doc --project --index:on --git.url:{gitURL} --outdir:{docDir}/gen src/{packageName}.nim"
  echo &"{packageName}: Done with docgen."


#_______________________________________
# Tasks
#_____________________________
#[ DEPRECATED
let genDir     = "gen"
let refDir     = "ref"
let gltfDir    = refDir/"gltf"
let specDir    = gltfDir/"specification"
let schemaDir  = specDir/"2.0"/"schema"
let schemaTrg  = genDir/"schema"
let schemaFile = schemaDir/"glTF.schema.json"
let j2nim      = binDir/"j2nim"
let j2nimSrc   = srcDir/packageName/"j2nim"
# Configuration
let verbose   = on

#_____________________________
# Helpers
proc compile (src :string; verb=verbose) :void=
  let cmd = &"nimble c --outDir:{binDir} --nimcache:{cacheDir} {j2nimSrc}"
  if verb: echo cmd
  exec cmd

#_____________________________
# File Generation
task gen, "Internal: Generates the gltf Json objects from the downloaded schema.":
  if not refDir.dirExists():
    refDir.mkDir()
    writeFile( refDir/".gitignore", "*\n" )
  if not gltfDir.dirExists: exec &"git clone https://github.com/KhronosGroup/glTF {gltfDir}"
  cpDir schemaDir, schemaTrg
  compile j2nimSrc
  exec &"{j2nim.absolutePath()} \"{schemaFile}\""
]#

