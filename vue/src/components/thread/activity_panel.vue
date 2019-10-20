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

import { pickBy, identity, camelCase, first, last, isNumber } from 'lodash'

export default
  props:
    discussion: Object
    viewportIsBelow: Boolean
    viewportIsAbove: Boolean

  data: ->
    parentEvent: @discussion.createdEvent()
    focusedEvent: null
    loader: null

  created: ->
    @loader = new RecordLoader
      collection: 'events'

    @watchRecords
      key: @discussion.id
      collections: ['groups', 'memberships']
      query: =>
        @canAddComment = AbilityService.canAddComment(@discussion)

    EventBus.$on 'threadPositionRequest', (position) =>
      @fetchEvent('position', position).then @focusOnEvent

    @respondToRoute()


  methods:
    respondToRoute: ->
      if parseInt(@$route.params.comment_id)
        @fetchEvent('commentId', parseInt(@$route.params.comment_id)).then @focusOnEvent

      if parseInt(@$route.params.sequence_id)
        @fetchEvent('sequenceId', parseInt(@$route.params.sequence_id)).then @focusOnEvent

    fetchEvent: (idType, id) ->
      if event = @findEvent(idType, id)
        console.log 'have event', idType, id, event
        Promise.resolve(event)
      else
        console.log 'fetching event', idType, id
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
          console.log 'received event', idType, id, @findEvent(idType, id)
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

    focusOnEvent: (event) ->
      waitFor = (selector, fn) ->
        if document.querySelector(selector)
          fn()
        else
          setTimeout ->
            waitFor(selector, fn)
          , 250

      EventBus.$emit('focusedEvent', event)
      waitFor "#sequence-#{event.sequenceId || 0}", =>
        @$vuetify.goTo "#sequence-#{event.sequenceId || 0}", offset: 96, duration: 0

  watch:
    '$route.params.sequence_id': 'respondToRoute'
    '$route.params.comment_id': 'respondToRoute'

  computed:
    canStartPoll: ->
      AbilityService.canStartPoll(@discussion)

</script>

<template lang="pug">
.activity-panel.pr-4.py-4
  thread-renderer(:discussion="discussion" :parent-event="parentEvent" :fetch="fetch" :viewport-is-below="viewportIsBelow" :viewport-is-above="viewportIsAbove")
</template>
