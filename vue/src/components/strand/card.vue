<script lang="coffee">
import Vue from 'vue'
import AppConfig                from '@/shared/services/app_config'
import EventBus                 from '@/shared/services/event_bus'
import RecordLoader             from '@/shared/services/record_loader'
import AbilityService           from '@/shared/services/ability_service'
import Session from '@/shared/services/session'
import Records from '@/shared/services/records'
import Flash   from '@/shared/services/flash'
import { print } from '@/shared/helpers/window'
import ThreadService  from '@/shared/services/thread_service'
import StrandActionsPanel from './actions_panel'

excludeTypes = 'group discussion author'

export default
  components:
    StrandActionsPanel: StrandActionsPanel

  props:
    loader: Object

  computed:
    discussion: -> @loader.discussion

    canStartPoll: ->
      AbilityService.canStartPoll(@discussion)

    canEditThread: ->
      AbilityService.canEditThread(@discussion)

</script>

<template lang="pug">
.strand-card.mb-8
  //- p(v-for="rule in loader.rules") {{rule.name}}
  strand-list.pt-3.px-3(:loader="loader" :collection="loader.collection")
  strand-actions-panel(:discussion="discussion")
  //- thread-actions-panel(v-if="!discussion.newestFirst" :discussion="discussion")
</template>
