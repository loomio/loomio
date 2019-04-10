import EventBus from '@/shared/services/event_bus'

service = new class ModalService
  # open: (->
  #   true
  # @forceSignIn: ->
  #   return if @forcedSignIn
  #   @forcedSignIn = true
  #   @open 'AuthModal', preventClose: -> true

EventBus.$on('open', service.open)

export default service
