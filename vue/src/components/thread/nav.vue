<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import UrlFor from '@/mixins/url_for'
import Records from '@/shared/services/records'
import WatchRecords from '@/mixins/watch_records'
import { debounce } from 'lodash'

export default
  mixins: [UrlFor, WatchRecords]
  data: ->
    discussion: null
    open: null
    keyEvents: []
    inversePosition: 0

  mounted: ->
    # threadPositionRequest (use slides the slider, tell others)
    # threadPositionUpdated (slider position needs updating)
    EventBus.$on 'toggleThreadNav', => @open = !@open
    EventBus.$on 'threadPositionUpdated', (position) =>
      @inversePosition = 0 - position

    EventBus.$on 'currentComponent', (options) =>
      @discussion = options.discussion
      return unless @discussion

      Records.events.fetch
        params:
          discussion_id: @discussion.id
          kind: ['poll_created', 'outcome_created']
          per: 200

      @watchRecords
        key: @discussion.id
        collections: ["events"]
        query: (records) =>
          @keyEvents = records.events.collection.chain()
                        .find(kind: {$in: ['poll_created']})
                        .simplesort('sequenceId')
                        .data()
  computed:
    childCount: -> @discussion.createdEvent().childCount
    position: -> 0 - @inversePosition
    thumbLabel: -> "#{@position} / #{@childCount}"

  methods:
    emitPosition: ->
      EventBus.$emit 'threadPositionRequest', @position

    scrollTo: (selector) ->
      @$vuetify.goTo(selector)

    title: (model) ->
      model.title || model.statement

    refreshThread: debounce ->
      EventBus.$emit('updateThreadPosition', 0 - @requestedPosition)
    ,
      250

  watch:
    open: (val) ->
      console.log 'sidebar open', val

</script>

<template lang="pug">
v-navigation-drawer(v-if="discussion" :permanent="$vuetify.breakpoint.mdAndUp" width="210px" app fixed right clipped)
  .thread-nav
    v-subheader Jump to
    v-slider(color="accent" track-color="accent" thumb-color="accent" thumb-size="64" v-model="inversePosition" vertical :max="0" :min="0 - discussion.createdEvent().childCount" thumb-label @change="emitPosition()")
      template(v-slot:thumb-label)
        | {{thumbLabel}}
    v-btn(color="accent" :to="urlFor(discussion)+'/'+discussion.firstUnreadSequenceId()") {{discussion.unreadItemsCount()}} Unread {{discussion.firstUnreadSequenceId()}}
    //- v-list(dense)
    //-   v-subheader Navigation
    //-   v-list-item(:to="urlFor(discussion)")
    //-     v-list-item-title Context
    //-   v-list-item(:to="urlFor(discussion)+'/'+discussion.firstSequenceId()" :disabled="!discussion.firstSequenceId()")
    //-     v-list-item-title First
    //-   v-list-item(:disabled="!discussion.firstUnreadSequenceId()" :to="urlFor(discussion)+'/'+discussion.firstUnreadSequenceId()")
    //-     v-list-item-title Unread
    //-   v-list-item(:to="urlFor(discussion)+'/'+discussion.lastSequenceId()" :disabled="!discussion.lastSequenceId()")
    //-     v-list-item-title Latest
    //-   v-list-item(@click="scrollTo('.activity-panel__actions')")
    //-     v-list-item-title Add comment
    v-subheader(v-if="keyEvents.length" v-t="'group_page.polls'")
    v-list-item(v-for="event in keyEvents" :key="event.id" :to="urlFor(discussion)+'/'+event.sequenceId")
      v-list-item-avatar
        poll-common-chart-preview(:poll='event.model()' :size="28" :showMyStance="false")
      v-list-item-title
        span {{title(event.model())}}
</template>
