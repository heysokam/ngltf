#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/os
import std/sugar
import std/strformat
import std/strutils
import std/sequtils
import std/json as stdjson
import std/sets
# External dependencies
import pkg/jsony
# ngltf dependencies
import ./gen
import ./j2nim/opts
import ./j2nim/helper
import ./j2nim/parse

#_________________________________________________
# Configuration
#_____________________________


#_________________________________________________
# Entry Point
#_____________________________
proc run=
  # Get the core file from the first argument given in CLI
  var jsonPath = opts.getArg(0)
  if not jsonPath.fileExists(): err &"First argument of the app must be a valid json file. Input:\n  {jsonPath}"
  # Get all files in the same folder as the file
  var dir   = jsonPath.splitFile.dir
  var files = collect(for k in dir.walkDir(): k.path).filterIt(it.endsWith(".schema.json"))
  # var files = collect(for k in dir.walkDir(): k.path).filterIt(it != jsonPath and it.endsWith(".schema.json"))
  var tstp  = files.filterIt("glTFid" in it).join("")
  var id    = tstp.readFile.fromJson()

  #_____________________________________________________
  # Key References
  var keys                    = initHashSet[string]()
  var hasType                 = initHashSet[string]()
  var hasAllOf                = initHashSet[string]()
  var hasSectionDescription   = initHashSet[string]()
  var hasWebGL                = initHashSet[string]()
  var hasAdditionalProperties = initHashSet[string]()
  var hasRequired             = initHashSet[string]()
  var hasDependencies         = initHashSet[string]()
  var hasProperties           = initHashSet[string]()
  var hasMinimum              = initHashSet[string]()
  var hasSchema               = initHashSet[string]()
  var hasOneOf                = initHashSet[string]()
  var hasId                   = initHashSet[string]()
  var hasDescription          = initHashSet[string]()
  var hasNot                  = initHashSet[string]()
  var hasTypename             = initHashSet[string]()


  #_____________________________________________________
  # Add contents
  var typesRoot   = initHashSet[string]()
  for file in files:
    let json  = file.readFile.fromJson
    typesRoot.incl parse.rootType(json)
    keys      = keys + parse.schemaKeys(json)


  #_____________________________________________________
  # TODO list generation
  for file in files:
    let json  = file.readFile.fromJson
    for key,val in json.pairs:
      if key == "$id"                     : hasId.incl file
      if key == "$schema"                 : hasSchema.incl file
      if key == "title"                   : hasTypename.incl file
      if key == "type"                    : hasType.incl file
      if key == "description"             : hasDescription.incl file
      if key == "allOf"                   : hasAllOf.incl file
      if key == "oneOf"                   : hasOneOf.incl file
      if key == "properties"              : hasProperties.incl file
      if key == "gltf_sectionDescription" : hasSectionDescription.incl file
      if key == "gltf_webgl"              : hasWebGL.incl file
      if key == "additionalProperties"    : hasAdditionalProperties.incl file

      if key == "required"                : hasRequired.incl file
      if key == "dependencies"            : hasDependencies.incl file
      if key == "minimum"                 : hasMinimum.incl file
      if key == "not"                     : hasNot.incl file

  #_____________________________________________________
  # TODO: Current
  # report hasNot, "hasNot"
  # report typesRoot, "RootTypes"
  # REMEMBER: Change the const list to be computed instead
  # for T in hasTypename:
  #   echo &"  \"{T.lastPathPart}\","
  # for file in hasTypename:
  #   echo &"  of \"{file.lastPathPart}\": \"{file.readFile.fromJson.getTypename.toNimSpelling}\""
  "./gtlfGenerated.nim".writeFile( typesRoot.toSeq.join("\n\n") )

  #_____________________________________________________
  # Done.
  var done = initHashSet[string]()
  done.incl "$id"                     # Stores the id of the file itself
  done.incl "$schema"                 # Stores the schema version used by the  file
  done.incl "title"                   # Stores the TypeName of the gltf component
  done.incl "type"                    # Stores the TypeKind of the gltf component
  done.incl "description"             # Stores the comment that documents the Type
  done.incl "allOf"                   # Probably just for actual validation. I believe its not needed for type declaration
  done.incl "oneOf"                   # Probably just for actual validation. I believe its not needed for type declaration
  done.incl "properties"              # Defines the fields of each type
  done.incl "gltf_sectionDescription" # Long Comment of the component
  done.incl "gltf_webgl"              # WebGL specific comment of the component
  done.incl "additionalProperties"    # Stores extra information for the `object` TypeKind
  report keys-done, "TODO"

when isMainModule: run()

