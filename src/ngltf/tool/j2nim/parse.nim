#:_____________________________________________________
#  ngltf  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# std dependencies
import std/strutils
import std/strformat
import std/sets
import std/json as stdjson
# External dependencies
import pkg/jsony
# j2nim dependencies
import ./types as j2n
import ./helper

#_________________________________________________
# GLTF Spec: Schema Fields Access
#_____________________________
# Ergonomic property access
func getId          *(json :JsonNode) :string=
  if json.hasKey(Key.id): return json[Key.id].getStr
func getSchemaVers  *(json :JsonNode) :string=    json[Key.schema].getStr
func getTypename    *(json :JsonNode) :string=    json[Key.typename].getStr
func getTypeKind    *(json :JsonNode) :string=    json[Key.kind].getStr
func getComment     *(json :JsonNode) :string=    json[Key.cmtShort].getStr
func getFieldName   *(json :JsonNode) :string=    json[Key.kind].getStr
func getFields      *(json :JsonNode) :JsonNode=  json[Key.filds]
func getAllOf       *(json :JsonNode) :JsonNode=  json[Key.allOf]
func getRef         *(json :JsonNode) :string=    json[Key.refer].getStr  #  $ref
func getItems       *(json :JsonNode) :JsonNode=  json[Key.item]
func getObjectType  *(json :JsonNode) :string=    json[Key.extras].getStr  # When an array item is an object, its type is contained as an additionalProperies $ref entry
func getObjectEntry *(json :JsonNode) :JsonNode=  json[Key.extras]
# Check properties
func has            *(json :JsonNode; key :Key) :bool=  json.hasKey($key)
func hasId          *(json :JsonNode) :bool=  json.has(Key.id)
func hasSchema      *(json :JsonNode) :bool=  json.has(Key.schema)
func hasValidSchema *(json :JsonNode) :bool=  json.hasSchema and json.getSchemaVers == j2n.SchemaVersion
func hasTypeName    *(json :JsonNode) :bool=  json.has(Key.typename)
func hasTypeKind    *(json :JsonNode) :bool=  json.has(Key.kind)
func hasComment     *(json :JsonNode) :bool=  json.has(Key.cmtShort)
func hasFields      *(json :JsonNode) :bool=  json.has(Key.filds)
func hasRef         *(json :JsonNode) :bool=  json.has(Key.refer)
func hasAllOf       *(json :JsonNode) :bool=  json.has(Key.allOf)
func hasItems       *(json :JsonNode) :bool=  json.has(Key.item)
func hasMinimum     *(json :JsonNode) :bool=  json.has(Key.minimum)
func hasMaximum     *(json :JsonNode) :bool=  json.has(Key.maximum)
func hasEnum        *(json :JsonNode) :bool=  json.has(Key.someEnum) # anyOf alias
# Unique exception checks
func isExtras       *(json :JsonNode) :bool=  json.getTypename == "Extras"
func isChildOf      *(json :JsonNode) :bool=  json.getId == "glTFChildOfRootProperty.schema.json"
func isProperty     *(json :JsonNode) :bool=  json.getId == "glTFProperty.schema.json"
func isId           *(json :JsonNode) :bool=  json.getId == "glTFid.schema.json"
func isTexNormal    *(json :JsonNode) :bool=  json.getId == "material.normalTextureInfo.schema.json"
func isTexOccl      *(json :JsonNode) :bool=  json.getId == "material.occlusionTextureInfo.schema.json"
func noComment      *(json :JsonNode) :bool=  json.isChildOf() or json.isProperty() or json.isId() or json.isTexNormal() or json.isTexOccl
func isEmpty        *(json :JsonNode) :bool=  json.getStr == "" or not json.hasKeys
# TypeFields
func isBaseType   *(json :JsonNode) :bool=    json.getId in j2n.BaseTypeIDs
func getMinimum   *(json :JsonNode) :float=   json["minimum"].getFloat

#_________________________________________________
# GLTF Spec: Schema Validation
#_____________________________
template chkId (json :JsonNode)=
  if not json.hasId(): raise newException(SchemaError, &"Tried to parse {json.getId}, but it has no FileId.")
template chkTypename (json :JsonNode)=
  if not json.hasTypeName(): raise newException(SchemaError, &"Tried to parse {json.getId}, but it has no TypeName.")
template chkTypeKind (json :JsonNode)=
  if not json.hasTypeKind(): raise newException(SchemaError, &"Tried to parse {json.getId}, but it has no TypeKind.")
template chkSchema (json :JsonNode)=
  if not json.hasValidSchema(): raise newException(SchemaError, &"Tried to parse {json.getId}, but its Schema version is incorrect.\n  is: {json.getSchemaVers}\n  should: {j2n.SchemaVersion}")
template chkComment (json :JsonNode)=
  if not json.hasComment():  raise newException(SchemaError, &"Tried to parse {json.getId}, but it is missing its description entry.")
template chkFields (json :JsonNode)=
  if not json.hasFields():  raise newException(SchemaError, &"Tried to parse the fields of {json.getId}, but it is a core type without fields.")
template chkTypeIsInt (json :JsonNode)=
  json.chkTypeKind
  if json.getTypeKind != "integer": raise newException(SchemaError, &"Tried to parse the fields of {json.getTypeKind} as an int, but its schema is not marked as one.")


#_________________________________________________
# GLTF Schema : Parsing specific types
#_____________________________
func getIntegerType *(json :JsonNode) :string=
  json.chkTypeIsInt()
  if json.hasMinimum and json.getMinimum < 0:
    result = "int32"
  else: result = "uint32"
#_____________________________
func getArrayType *(json :JsonNode) :string=
  # GIGANTIC mess. But really couldn't untangle this better :_(
  # There must be a lot of redundancy here, but don't know how to avoid it
  if json.hasItems:
    let itms = json.getItems
    if itms.hasTypeKind: return &"seq[{itms.getTypeKind.toTypeName}]"
    else:                return &"seq[{itms.getRef.refToGLTF()}]"
  elif json.hasAllOf:  return &"seq[{json.getAllOf.getRef.refToGLTF()}]"
  elif json.hasRef:    return &"seq[{json.getRef.refToGLTF()}]"
  elif json.hasTypeKind:
    let kind = json.getTypeKind
    case kind
    of "number"  : return &"seq[float64]"
    of "$ref"    : return &"seq[{kind.refToGLTF()}]"
    of "object"  : return &"seq[{json.getObjectType.refToGLTF}]"
    of "integer" : return &"seq[{json.getIntegerType}]"
    of "string"  : return &"seq[kind]"
    else: raise newException(SchemaError, &"Tried to get the FieldType of {kind}, but it is not registered as a case type.")
  else: raise newException(SchemaError, &"Tried to find an array item from a json node, but it has no known item fields.")


#_________________________________________________
# GLTF Schema : Parsing Root objects
#_____________________________
func getFieldType *(name :string; json :JsonNode) :string=
  # GIGANTIC mess. But really couldn't untangle this better :_(
  # There must be a lot of redundancy here, but don't know how to avoid it
  let comment = if json.hasComment and not json.noComment(): &"  ## {json.getComment}" else: ""
  case name  # Hardcoded cases where the contents are optional in the schema, so they are missing.
  of   "name"       : return &"\n  {name} *:string  ## The user-defined name of this object."
  of   "extensions" : return &"\n  {name} *:Extension  ## JSON object with extension-specific objects."
  of   "extras"     : return &"\n  {name} *:Extras  ## Application-specific data."
  of   "index"      : return &"\n  {name} *:uint32  ## The index of the texture."
  of   "texCoord"   : return &"\n  {name} *:uint32  ## The set index of texture's TEXCOORD attribute used for texture coordinate mapping."
  else: discard

  # Add the field name
  result.add &"\n  {name.toFieldName} *:"
  # Search for the correct type of this field
  # and add it to the result, followed by its comment
  if not json.hasTypeKind:
    if json.hasAllOf: 
      let tmp = json.getAllOf()[0].getArrayType
      return &"{result}{tmp}{comment}"
    elif json.hasEnum:
      return &"{result}enum of  {comment}"
  var kind = ""
  try: kind = json.getTypeKind
  except:
    debugEcho "\n---------- Should have a TypeKind, but doesnt -----------"
    for key,val in json:
      debugEcho key," : ", val
  case kind
  of "array"   : result.add &"{json.getArrayType()}"
  of "number"  : result.add "float64"
  of "$ref"    : result.add &"{kind.refToGLTF()}"
  of "object"  : result.add &"{json.getObjectEntry.getRef.refToGLTF}{comment}"
  of "integer" : result.add "uint32"
  of "string"  : result.add kind
  of "boolean" : result.add "bool"
  else:
    debugEcho "\n-----------"
    for key,val in json:
      debugEcho key," : ", val.getStr
    raise newException(SchemaError, &"Tried to get the FieldType of {name}:{kind}, but it is not registered as a case type.")
  result.add comment
#_____________________________
proc toFieldTypes *(json :JsonNode) :string=
  for name,typData in json:
    try:
      result.add getFieldType( name, typData )
    except:
      debugEcho &"getFieldType failed for {name}"
      let e = getCurrentException()
      debugEcho e.msg
      debugEcho e.getStackTrace()
      debugEcho &"Contents:\n{typData.toJson}"

#_________________________________________________
# GLTF Spec: Schema Parsing
#_____________________________
proc rootType *(json :JsonNode) :string=
  ## Returns the root type contained in the input json node
  # Validate fields
  json.chkSchema()
  json.chkTypename()
  if not json.isExtras():   json.chkTypeKind()
  if not json.noComment():  json.chkComment()
  if not json.isBaseType(): json.chkFields()

  # Store the root comment text
  let comment = if not json.noComment(): &"\n  ## {json.getComment}" else: ""

  # Extras exception case, and exit early
  if json.isExtras(): return &"type Extras * = RawJson{comment}"

  # Add the TypeName, TypeKind and TypeComment
  result = "type " & json.getTypename.toNimSpelling
  result.add &" * = {json.getTypeKind.toTypeName}"
  result.add comment

  # Add the type fields
  if json.isBaseType() and json.hasFields():
    result.add json.getFields().toFieldTypes


#_____________________________
proc schemaKeys *(json :JsonNode) :HashSet[string]=
  ## Returns all of the given schema keys from the input json node
  json.chkSchema()
  for key,val in json.pairs: result.incl key

