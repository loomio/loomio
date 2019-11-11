import {map, keys} from 'lodash'

export encodeParams = (params) ->
  map(keys(params), (key) ->
    encodeURIComponent(key) + "=" + encodeURIComponent(params[key])
  ).join('&')
