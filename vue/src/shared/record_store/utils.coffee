import parseISO from 'date-fns/parseISO'
import { each, keys, map, camelCase } from 'lodash'

export default new class Utils
  parseJSONList: (data) -> map(data, @parseJSON)
  parseJSON: (json) ->
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

transformKeys = (attributes, transformFn) ->
  result = {}
  each keys(attributes), (key) ->
    result[transformFn(key)] = attributes[key]
    true
  result

isTimeAttribute = (attributeName) ->
  /At$/.test(attributeName)
