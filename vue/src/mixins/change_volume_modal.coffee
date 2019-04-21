import EventBus from '@/shared/services/event_bus'

export default
  methods:
    # canEditComment: (eventable) ->
    #   AbilityService.canEditComment(@eventable)

    openChangeVolumeModal: (model) ->
      EventBus.$emit('openModal',
                      component: 'ChangeVolumeForm',
                      props: {
                        model: model
                      })
