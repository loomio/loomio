import LmoUrlService from '@/shared/services/lmo_url_service'
import { pickBy, identity } from 'lodash'

# this is a vue mixin
export default
  methods:
    urlFor: (model, action, params) -> LmoUrlService.route(model: model, action: action, params: params)
    mergeRouteQuery: (obj) -> {query: pickBy(Object.assign({}, @$route.query, obj), identity)}
