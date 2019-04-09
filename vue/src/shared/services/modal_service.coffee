export default class ModalService
  open: ->
    true
  @forceSignIn: ->
    return if @forcedSignIn
    @forcedSignIn = true
    @open 'AuthModal', preventClose: -> true
