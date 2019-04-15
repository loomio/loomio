import EventBus from '@/shared/services/event_bus'

export default
  methods:
    # canEditComment: (eventable) ->
    #   AbilityService.canEditComment(@eventable)

    openStartPollModal: (poll) ->
      EventBus.$emit('openModal',
                      component: 'PollCommonStartModal',
                      props: {
                        poll: poll
                      })
