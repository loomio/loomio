ImplementationService = require 'shared/services/implementation_service.coffee'

module.exports = class ScrollService
  ImplementationService.requireMethod @, 'scrollTo',   'setScrollMethod'
