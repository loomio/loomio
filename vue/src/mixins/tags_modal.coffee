import EventBus from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import Records        from '@/shared/services/records'

export default
  methods:
    openTagsModal: (discussion) ->
      EventBus.$emit('openModal',
                      component: 'TagsModal',
                      props: {
                        discussion: discussion
                      })

    closeModal: ->
      EventBus.$emit('closeModal')
