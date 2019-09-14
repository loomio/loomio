import EventBus from '@/shared/services/event_bus'

export default
  methods:
    openAuthModal: (props) ->
      EventBus.$emit('openModal', component: 'AuthModal', props: props)

    closeModal: ->
      EventBus.$emit('closeModal')
