{
  // support normal expressions
  require(cond, msg):
    if cond then {} else error msg
  ,

  // validate string
  string(value, label='value', allowEmpty=false):
    if std.isString(value) then
      if !allowEmpty && value == '' then error label + ' must be non-empty string'
      else {}
    else error label + ' must be type string',

  // validate number
  number(value, label='value', allowNull=false):
    if allowNull && value == null then {}
    else if std.isNumber(value) then {}
    else error label + ' must be a number',

  // validate array
  array(value, label, allowEmpty=false):
    if std.isArray(value)
    then
      if !allowEmpty && std.length(value) == 0
      then error 'array must not be empty'
      else {}
    else error 'must be array',

  boolean(value, label):
    if std.isBoolean(value) then {}
    else error label + ' must be type boolean',

  object(value, label, allowEmpty=false):
    if std.isObject(value) then
      if !allowEmpty && std.length(std.objectFields(value)) == 0
      then error label + ' object must not be empty'
      else {}
    else error label + ' must be object',
}
