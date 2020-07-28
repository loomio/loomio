import EventBus from '@/shared/services/event_bus'

export default
  methods:
    openAuthModal: (preventClose = false) ->
      EventBus.$emit('openModal', component: 'AuthModal', props: {preventClose: preventClose} )
