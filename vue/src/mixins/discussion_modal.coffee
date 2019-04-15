import EventBus from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import Records        from '@/shared/services/records'
import Session        from '@/shared/services/session'

import _some from 'lodash/some'

export default
  methods:
    canStartThreads: ->
      Session.user().id &&
      _some(Session.user().groups(), (group) => AbilityService.canStartThread(group))

    openStartDiscussionModal: (groupId) ->
      EventBus.$emit('openModal',
                      component: 'DiscussionForm',
                      props: {
                        discussion: Records.discussions.build(groupId: @currentGroup().id)
                      }
                      titleKey: 'group_form.new_organization')

    openForkedDiscussionModal: (groupId, isPrivate, forkedEventIds) ->
      EventBus.$emit('openModal',
                      component: 'DiscussionForm',
                      props: {
                        discussion: Records.discussions.build
                          groupId:        groupId
                          private:        isPrivate
                          forkedEventIds: forkedEventIds
                      }
                      titleKey: 'group_form.new_organization')
