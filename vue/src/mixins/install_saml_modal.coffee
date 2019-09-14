import EventBus from '@/shared/services/event_bus'

export default
  methods:
    openInstallSamlModal: (group, preventClose) ->
      EventBus.$emit('openModal',
                      component: 'InstallSamlModal',
                      props: {
                        group: group,
                        preventClose: preventClose
                        close: -> EventBus.$emit 'closeModal'
                      })
