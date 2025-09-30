{
  // call this method in your method definition
  // to validate input!
  // !important! must be able to render in order to validate
  compose(objs): std.prune(
    {
      valid: std.foldl(
        function(acc, o) acc + o,
        objs,
        {}
      ),
    }
  ),

  // support normal expressions
  require(cond, msg):
    if cond then {} else error msg
  ,

  // validate string
  string(value, label='value', allowEmpty=true):
    if std.isString(value) then
      if !allowEmpty && value == '' then error label + ' must be non-empty string'
      else {}
    else error label + ' must be type string',

  // validate number
  number(value, label='value'):
    if std.isNumber(value) then {}
    else error label + ' must be a number',

  // validate array
  array(value, allowEmpty=true):
    if std.type(value) == 'array'
    then
      if !allowEmpty && std.length(value) == 0
      then error 'array must not be empty'
      else {}
    else error 'must be array',
}
