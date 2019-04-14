import EventBus from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import Records        from '@/shared/services/records'

export default
  methods:
    canStartGroup: -> AbilityService.canStartGroups()

    openStartGroupModal: ->
      EventBus.$emit('openModal',
                      component: 'GroupForm',
                      props: {
                        group: Records.groups.build()
                      }
                      titleKey: 'group_form.new_organization')
