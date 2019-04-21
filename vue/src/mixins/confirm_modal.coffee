import EventBus from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import Records        from '@/shared/services/records'
import Session        from '@/shared/services/session'

import _some from 'lodash/some'

export default
  methods:
    openConfirmModal: (opts) ->
      EventBus.$emit('openModal',
                      component: 'ConfirmModal',
                      props: {
                        confirm: opts
                      })
