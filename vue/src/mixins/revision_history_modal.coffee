import EventBus from '@/shared/services/event_bus'

export default
  methods:
    openRevisionHistoryModal: (model) ->
      EventBus.$emit('openModal',
                      component: 'RevisionHistoryModal',
                      props: {
                        model: model
                      })
