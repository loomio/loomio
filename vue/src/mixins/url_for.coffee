LmoUrlService = require 'shared/services/lmo_url_service'

module.exports =
  methods:
    urlFor: (model, action) -> LmoUrlService.route(model: model, action: action)
