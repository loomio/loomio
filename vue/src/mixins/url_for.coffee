import LmoUrlService from '@/shared/services/lmo_url_service'
import { pickBy, identity, isEqual } from 'lodash'

# this is a vue mixin
export default
  methods:
    urlFor: (model, action, params) -> LmoUrlService.route(model: model, action: action, params: params)
    mergeQuery: (obj) ->
      {query: pickBy(Object.assign({}, @$route.query, obj), identity)}
