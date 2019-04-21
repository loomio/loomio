import EventBus from '@/shared/services/event_bus'

export default
  methods:
    openContactRequestModal: (user) ->
      EventBus.$emit('openModal',
                      component: 'ContactRequestForm',
                      props: {
                        user: user
                      })
