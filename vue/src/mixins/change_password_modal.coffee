import EventBus from '@/shared/services/event_bus'

export default
  methods:
    openChangePasswordModal: (user) ->
      EventBus.$emit('openModal',
                      component: 'ChangePasswordForm',
                      props: {
                        user: user
                    })

    closeModal: ->
      EventBus.$emit('closeModal')
