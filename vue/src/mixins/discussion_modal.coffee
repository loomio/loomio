import EventBus from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import Records        from '@/shared/services/records'
import Session        from '@/shared/services/session'

import { some } from 'lodash'

export default
  methods:
    canStartThreads: ->
      Session.user().id &&
      some(Session.user().groups(), (group) => AbilityService.canStartThread(group))

    openStartDiscussionModal: (group) ->
      EventBus.$emit('openModal',
                      component: 'DiscussionForm',
                      props: {
                        discussion: Records.discussions.build(groupId: group.id)
                      }
                      titleKey: 'group_form.new_organization')

    openForkedDiscussionModal: (discussion) ->
      EventBus.$emit('openModal',
                      component: 'DiscussionForm',
                      props: {
                        discussion: Records.discussions.build
                          groupId:        discussion.groupId
                          private:        discussion.private
                          forkedEventIds: discussion.forkedEventIds
                          description: discussion.description
                          descriptionFormat: discussion.descriptionFormat
                      }
                      titleKey: 'group_form.new_organization')

    openEditDiscussionModal: (discussion) ->
      EventBus.$emit('openModal',
                      component: 'DiscussionForm',
                      props: {
                        discussion: discussion.clone()
                      }
                      titleKey: 'group_form.new_organization')
