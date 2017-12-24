ImplementationService = require 'shared/services/implementation_service.coffee'

module.exports = new class ModalService
  ImplementationService.requireMethod @, 'open', 'setOpenMethod'
