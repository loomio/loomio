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

excludeTypes = 'group discussion author'

export default
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
.strand-card.mb-8.pr-4
  strand-title(:discussion="discussion")
  thread-actions-panel(v-if="discussion.newestFirst" :discussion="discussion")
  //- p(v-for="rule in loader.rules") {{rule.name}}
  strand-list(:loader="loader" :collection="loader.collection")
  //- thread-actions-panel(v-if="!discussion.newestFirst" :discussion="discussion")
</template>
<style lang="sass">
.strand-card
  padding: 0 8px
</style>
