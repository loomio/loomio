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
    focusedEvent: null
    loader: null
    initialSlots: []

  created: ->
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
      if parseInt(@$route.params.comment_id)
        @fetchEvent('commentId', parseInt(@$route.params.comment_id)).then @focusOnEvent
      else if parseInt(@$route.query.p)
        @fetchEvent('position', parseInt(@$route.query.p)).then @focusOnEvent
      else if parseInt(@$route.params.sequence_id)
        @fetchEvent('sequenceId', parseInt(@$route.params.sequence_id)).then @focusOnEvent
      else
        @fetchEvent('position', first(@initialSlots))

        if (@discussion.newestFirst && !@viewportIsBelow) || (!@discussion.newestFirst &&  @viewportIsBelow)
          @fetchEvent('position', @parentEvent.childCount)
        else
          @fetchEvent('position', 1)

        @scrollTo(0)


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

    waitFor: (selector, fn) ->
      if document.querySelector(selector)
        fn()
      else
        setTimeout =>
          @waitFor(selector, fn)
        , 100

    focusOnEvent: (event) ->
      @initialSlots = [event.position]
      @$nextTick =>
        @waitFor "#sequence-#{event.sequenceId}", =>
          @scrollTo("#sequence-#{event.sequenceId}")

    openArrangementForm: ->
      ThreadService.actions(@discussion, @)['edit_arrangement'].perform()

  watch:
    '$route.params.sequence_id': 'respondToRoute'
    '$route.params.comment_id': 'respondToRoute'
    '$route.query.p': 'respondToRoute'

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
  thread-renderer(:newest-first="discussion.newestFirst" :parent-event="parentEvent" :fetch="fetch" :initial-slots="initialSlots")
</template>
