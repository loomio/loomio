module.exports =
  new class Utils
    parseJSONList: (data) -> _.map(data, @parseJSON)
    parseJSON: (json) ->
      attributes = transformKeys(json, _.camelCase)
      _.each _.keys(attributes), (name) =>
        if attributes[name]?
          if isTimeAttribute(name) and moment(attributes[name]).isValid()
            attributes[name] = moment(attributes[name])
          else
            attributes[name] = attributes[name]
        true
      attributes

    isTimeAttribute: (attributeName) ->
      isTimeAttribute(attributeName)

transformKeys = (attributes, transformFn) ->
  result = {}
  _.each _.keys(attributes), (key) ->
    result[transformFn(key)] = attributes[key]
    true
  result

isTimeAttribute = (attributeName) ->
  /At$/.test(attributeName)
