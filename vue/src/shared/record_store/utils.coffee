import parseISO from 'date-fns/parseISO'
import { each, keys, map, camelCase, isArray} from 'lodash'

transformKeys = (attributes, transformFn) ->
  result = {}
  each keys(attributes), (key) ->
    result[transformFn(key)] = attributes[key]
    true
  result

isTimeAttribute = (attributeName) ->
  /At$/.test(attributeName)

export default new class Utils
  deserialize: (json) ->
    result = {}
    attributes = transformKeys(json, camelCase)
    each keys(attributes), (name) =>
      if isArray(attributes[name])
        result[name] = map(attributes[name], @parseJSON)
      else
        result[name] = attributes[name]
    result

  parseJSON: (json) -> # parse a single record
    attributes = transformKeys(json, camelCase)
    each keys(attributes), (name) ->
      if attributes[name]?
        if isTimeAttribute(name)
          attributes[name] = parseISO(attributes[name])
        else
          attributes[name] = attributes[name]
      true
    attributes

  isTimeAttribute: (attributeName) ->
    isTimeAttribute(attributeName)
