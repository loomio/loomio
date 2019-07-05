<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import UrlFor from '@/mixins/url_for'
import Records from '@/shared/services/records'
import WatchRecords from '@/mixins/watch_records'
import AnnouncementModalMixin from '@/mixins/announcement_modal'
import { debounce } from 'lodash'

export default
  mixins: [UrlFor, WatchRecords, AnnouncementModalMixin]
  data: ->
    discussion: null
    open: null
    keyEvents: []
    inversePosition: 0

  mounted: ->
    # threadPositionRequest (use slides the slider, tell others)
    # threadPositionUpdated (slider position needs updating)
    EventBus.$on 'toggleThreadNav', => @open = !@open
    EventBus.$on 'threadPositionUpdated', debounce (position) =>
      console.log position
      @inversePosition = 0 - position
    ,
      250

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
          return unless @discussion
          @keyEvents = records.events.collection.chain()
                        .find({
                          kind: {$in: ['poll_created']}
                          discussionId: @discussion.id
                        })
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

    addPeople: ->
      @openAnnouncementModal(Records.announcements.buildFromModel(@discussion))

  watch:
    open: (val) ->
      console.log 'sidebar open', val

</script>

<template lang="pug">
v-navigation-drawer(v-if="discussion" v-model="open" :permanent="$vuetify.breakpoint.mdAndUp" width="210px" app fixed right clipped)
  .thread-nav
    v-list(dense)
      v-list-item(:to="urlFor(discussion)" @click="scrollTo('#context')")
        v-list-item-avatar
          v-icon mdi-format-vertical-align-top
        v-list-item-title Context
      //- v-slider(color="accent" track-color="accent" thumb-color="accent" thumb-size="64" v-model="inversePosition" vertical :max="0" :min="0 - discussion.createdEvent().childCount" thumb-label @change="emitPosition()")
      //-   template(v-slot:thumb-label)
      //-     | {{thumbLabel}}
      v-list-item(:to="urlFor(discussion)+'/'+(discussion.firstUnreadSequenceId() || '')" :disabled="!discussion.isUnread()")
        v-list-item-avatar
          v-icon mdi-bookmark-outline
        v-list-item-title {{discussion.unreadItemsCount()}} Unread
      v-list-item(v-for="event in keyEvents" :key="event.id" :to="urlFor(discussion)+'/'+event.sequenceId")
        v-list-item-avatar
          poll-common-chart-preview(:poll='event.model()' :size="28" :showMyStance="false")
        v-list-item-title
          span {{title(event.model())}}
      v-list-item(:to="urlFor(discussion)+'/'+discussion.lastSequenceId()")
        v-list-item-avatar
          v-icon mdi-format-vertical-align-bottom
        v-list-item-title Latest
      v-list-item(:to="urlFor(discussion)+'#add-comment'" @click="scrollTo('#add-comment')")
        v-list-item-avatar
          v-icon mdi-comment
        v-list-item-title Add comment
    v-divider
    v-list(dense)
      v-list-item
        v-list-item-avatar
          v-icon mdi-account-plus
        v-list-item-title Add people
    v-subheader Notification settings
    v-list(dense)
      v-list-item
        v-list-item-avatar
          v-icon mdi-email-outline
        v-list-item-title All activity
        //- v-list-item-subtitle You will be emailed whenever there is activity in this thread.
    v-divider


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
</template>
