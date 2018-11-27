LmoUrlService = require 'shared/services/lmo_url_service.coffee'

LmoUrlService.tag = (tag, params = {}, options = {}) ->
  LmoUrlService.buildModelRoute('tags', tag.id, tag.name.toLowerCase(), params, options)
