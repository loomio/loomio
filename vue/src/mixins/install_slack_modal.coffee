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

    openInstallSlackInstallForm: () ->
      console.log 'openInstallSlackInstallForm'
      EventBus.$emit('openModal',
                      component: 'InstallSlackInstallForm')

    closeModal: ->
      EventBus.$emit('closeModal')
