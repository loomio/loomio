<script lang="coffee">
import Vue from 'vue'
import AppConfig                from '@/shared/services/app_config'
import EventBus                 from '@/shared/services/event_bus'
import RecordLoader             from '@/shared/services/record_loader'
import ModalService             from '@/shared/services/modal_service'
import AbilityService           from '@/shared/services/ability_service'
import Session from '@/shared/services/session'
import Records from '@/shared/services/records'
import { print } from '@/shared/helpers/window'
import ThreadService  from '@/shared/services/thread_service'

import { pickBy, identity, camelCase, first, last, isNumber } from 'lodash'

export default
  components:
    ThreadRenderer: -> import('@/components/thread/renderer.vue')

  props:
    discussion: Object
    viewportIsBelow: Boolean
    viewportIsAbove: Boolean

  data: ->
    parentEvent: @discussion.createdEvent()
    focalEvent: null
    loader: null
    initialSlots: []

  mounted: ->
    @loader = new RecordLoader
      collection: 'events'

    @watchRecords
      key: @discussion.id
      collections: ['groups', 'memberships']
      query: =>
        @canAddComment = AbilityService.canAddComment(@discussion)

    @respondToRoute()

  methods:
    respondToRoute: ->
      return if @discussion.key != @$route.params.key
      return if @parentEvent.childCount == 0

      args = if parseInt(@$route.params.comment_id)
        {column: 'commentId', id: parseInt(@$route.params.comment_id), scrollTo: true}
      else if parseInt(@$route.query.p)
        {column: 'position', id: parseInt(@$route.query.p), scrollTo: true}
      else if parseInt(@$route.params.sequence_id)
        {column: 'sequenceId', id: parseInt(@$route.params.sequence_id), scrollTo: true}
      else
        if (@discussion.newestFirst && !@viewportIsBelow) || (!@discussion.newestFirst &&  @viewportIsBelow)
          {column: 'position', id: @parentEvent.childCount}
        else
          {column: 'position', id: 1}

      @fetchEvent(args.column, args.id).then (event) =>
        @focalEvent = event
        if args.scrollTo
          @scrollTo "#sequence-#{event.sequenceId}", =>
            setTimeout =>
              @focalEvent = null
            , 1000


    fetchEvent: (idType, id) ->
      if event = @findEvent(idType, id)
        Promise.resolve(event)
      else
        param = switch idType
          when 'sequenceId' then 'from'
          when 'commentId' then 'comment_id'
          when 'position' then 'from_sequence_id_of_position'

        @loader.fetchRecords(
          discussion_id: @discussion.id
          order: 'sequence_id'
          per: 5
          "#{param}": id
        ).then =>
          # console.log "fetched: #{idType}, #{id}"
          Promise.resolve(@findEvent(idType, id))

    findEvent: (column, id) ->
      return false unless isNumber(id)
      records = Records
      if id == 0
        @discussion.createdEvent()
      else
        args = switch camelCase(column)
          when 'position'
            discussionId: @discussion.id
            position: id
            depth: 1
          when 'sequenceId'
            discussionId: @discussion.id
            sequenceId: id
          when 'commentId'
            kind: 'new_comment'
            eventableId: id
        # console.log "finding: ", args
        Records.events.find(args)[0]

    fetch: (slots) ->
      return unless slots.length
      @loader.fetchRecords
        comment_id: null
        from: null
        from_unread: null
        discussion_id: @discussion.id
        order: 'sequence_id'
        from_sequence_id_of_position: first(slots)
        until_sequence_id_of_position: last(slots)
        per: @padding * 2

    openArrangementForm: ->
      ThreadService.actions(@discussion, @)['edit_arrangement'].perform()

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
.activity-panel
  .text-center.py-2
    v-btn.action-button.grey--text(text small @click="openArrangementForm()" v-if="canEditThread")
      span(v-t="{path: 'activity_card.count_responses', args: {count: parentEvent.childCount}}")
      space
      span(v-if="discussion.newestFirst" v-t="'poll_common_votes_panel.newest_first'")
      span(v-if="!discussion.newestFirst" v-t="'poll_common_votes_panel.oldest_first'")
  thread-renderer(v-if="parentEvent" :newest-first="discussion.newestFirst" :parent-event="parentEvent" :fetch="fetch" :focal-event="focalEvent")
</template>
