import EventBus from '@/shared/services/event_bus'

export default
  methods:
    openMembershipModal: (membership) ->
      EventBus.$emit('openModal',
                      component: 'MembershipModal',
                      props: {
                        membership: membership
                      })

    closeModal: ->
      EventBus.$emit('closeModal')
