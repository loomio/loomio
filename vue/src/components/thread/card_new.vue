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

import { pickBy, identity, camelCase, first, last, isNumber } from 'lodash-es'

excludeTypes = 'group discussion author'

export default
  components:
    ThreadStrand: -> import('@/components/thread/strand.vue')

  props:
    discussion: Object
    focalEvent: Object
    collection: Array

  data: ->
    parentEvent: @discussion.createdEvent()
    focalEvent: null
    loader: null

  mounted: ->
    @loader = new RecordLoader
      collection: 'events'
        params:
          exclude_types: excludeTypes

    @watchRecords
      key: @discussion.id
      collections: ['groups', 'memberships']
      query: =>
        @canAddComment = AbilityService.canAddComment(@discussion)

    @respondToRoute()

  methods:



    fetch: (slots, padding) ->
      return unless slots.length
      @loader.fetchRecords(
        exclude_types: excludeTypes
        comment_id: null
        from: null
        from_unread: null
        discussion_id: @discussion.id
        order: 'sequence_id'
        from_sequence_id_of_position: first(slots)
        until_sequence_id_of_position: last(slots)
        per: padding * 4).then @refocus

  watch:
    '$route.params.sequence_id': 'respondToRoute'
    '$route.params.comment_id': 'respondToRoute'
    '$route.query.p': 'respondToRoute'
    'parentEvent.childCount': (newVal, oldVal) ->
      @respondToRoute() if oldVal == 0 and newVal != 0

  computed:
    canStartPoll: ->
      AbilityService.canStartPoll(@discussion)

    canEditThread: ->
      AbilityService.canEditThread(@discussion)




</script>

<template lang="pug">
v-card.thread-card(outlined)
  context-panel(:discussion="discussion")
  thread-actions-panel(v-if="discussion.newestFirst" :discussion="discussion")
  thread-strand(:collection="collection" :focal-event="focalEvent")
  thread-actions-panel(v-if="!discussion.newestFirst" :discussion="discussion")
</template>
