import EventBus from '@/shared/services/event_bus'

export default
  methods:
    openAuthModal: ->
      EventBus.$emit('openModal', component: 'AuthModal')
