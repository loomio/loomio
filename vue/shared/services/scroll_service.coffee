ImplementationService = require 'shared/services/implementation_service'

module.exports = class ScrollService
  ImplementationService.requireMethod @, 'scrollTo',   'setScrollMethod'
