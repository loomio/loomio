ImplementationService = require 'shared/services/implementation_service'

module.exports = class ModalService
  ImplementationService.requireMethod @, 'open', 'setOpenMethod'

  @forceSignIn: ->
    return if @forcedSignIn
    @forcedSignIn = true
    @open 'AuthModal', preventClose: -> true
