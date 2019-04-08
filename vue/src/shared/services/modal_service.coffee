export default class ModalService
  @forceSignIn: ->
    return if @forcedSignIn
    @forcedSignIn = true
    @open 'AuthModal', preventClose: -> true
