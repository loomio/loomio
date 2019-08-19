import EventBus from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import Records        from '@/shared/services/records'

export default
  methods:
    canStartGroup: -> AbilityService.canStartGroups()

    openStartGroupModal: ->
      EventBus.$emit('openModal',
                      component: 'GroupNewForm',
                      props: {
                        group: Records.groups.build()
                      })

    openEditGroupModal: (group) ->
      EventBus.$emit('openModal',
                      component: 'GroupForm',
                      props: {
                        group: group.clone()
                      })

    openStartSubgroupModal: (group) ->
      EventBus.$emit('openModal',
                      component: 'GroupNewForm',
                      props: {
                        group: Records.groups.build(parentId: group.id)
                      })

    openMembershipRequestModal: (group) ->
      EventBus.$emit('openModal',
                      component: 'MembershipRequestForm',
                      props: {
                        group: group
                      })

    openGroupWizard: (group) ->
      EventBus.$emit('openModal',
                      component: 'GroupWizard',
                      props: {
                        group: group
                      })
                      
    closeModal: ->
      EventBus.$emit('closeModal')
