LmoUrlService = require 'shared/services/lmo_url_service'

module.exports =
  methods:
    urlFor: (model) -> LmoUrlService.route(model: model)
