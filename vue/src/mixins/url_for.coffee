import LmoUrlService from '@/shared/services/lmo_url_service'

export default
  methods:
    urlFor: (model, action) -> LmoUrlService.route(model: model, action: action)
