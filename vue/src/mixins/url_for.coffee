import LmoUrlService from '@/shared/services/lmo_url_service'

# this is a vue mixin
export default
  methods:
    urlFor: (model, action, params) -> LmoUrlService.route(model: model, action: action, params: params)
