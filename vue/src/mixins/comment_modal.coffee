import EventBus from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import Records        from '@/shared/services/records'
import Session        from '@/shared/services/session'

import _some from 'lodash/some'

export default
  methods:
    canEditComment: (eventable) ->
      AbilityService.canEditComment(@eventable)

    openEditCommentModal: (eventable) ->
      EventBus.$emit('openModal',
                      component: 'EditCommentForm',
                      props: {
                        comment: eventable
                      })
