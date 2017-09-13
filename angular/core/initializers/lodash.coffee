# backport of functions from lodash 4.x
_.fromPairs = (pairs) ->
  index = -1
  length = if pairs == null then 0 else pairs.length
  result = {}
  while ++index < length
    pair = pairs[index]
    result[pair[0]] = pair[1]
  result

_.pickBy = (object, fn) ->
  result = {}
  for key in _.keys(object)
    result[key] = object[key] if fn(object[key])
  result
