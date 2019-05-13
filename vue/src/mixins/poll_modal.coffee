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

    openEditVoteModal: (stance) ->
      EventBus.$emit('openModal',
                      component: 'PollCommonEditVoteModal',
                      props: {
                        stance: stance
                      })

    openEditPollModal: (poll) ->
      EventBus.$emit('openModal',
                      component: 'PollCommonEditModal',
                      props: {
                        poll: poll
                      })

    openPollOutcomeModal: (outcome) ->
      EventBus.$emit('openModal',
                      component: 'PollCommonOutcomeModal',
                      props: {
                        outcome: outcome
                      })

    openClosePollModal: (poll) ->
      EventBus.$emit('openModal',
                      component: 'PollCommonCloseModal',
                      props: {
                        poll: poll
                      })
    closeModal: ->
      EventBus.$emit('closeModal')
