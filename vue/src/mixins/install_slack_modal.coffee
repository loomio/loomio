import EventBus from '@/shared/services/event_bus'

export default
  methods:
    openInstallSlackModal: (group, preventClose) ->
      EventBus.$emit('openModal',
                      component: 'InstallSlackModal',
                      props: {
                        group: group,
                        preventClose: preventClose
                      })
    closeModal: ->
      EventBus.$emit('closeModal')
