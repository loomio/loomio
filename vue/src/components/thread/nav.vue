<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import UrlFor from '@/mixins/url_for'
import Records from '@/shared/services/records'
import WatchRecords from '@/mixins/watch_records'
import AnnouncementModalMixin from '@/mixins/announcement_modal'
import ChangeVolumeModalMixin from '@/mixins/change_volume_modal'
import { debounce, truncate } from 'lodash'

export default
  mixins: [UrlFor, WatchRecords, AnnouncementModalMixin, ChangeVolumeModalMixin]
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
      @inversePosition = 0 - position
    ,
      250

    EventBus.$on 'currentComponent', (options) =>
      @discussion = options.discussion
      return unless @discussion

      Records.events.fetch
        params:
          discussion_id: @discussion.id
          pinned: true
          per: 200

      @watchRecords
        key: @discussion.id
        collections: ["events"]
        query: (records) =>
          return unless @discussion
          @keyEvents = records.events.collection.chain()
                        .find({
                          pinned: true
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
      truncate (model.title || model.statement || model.body).replace(///<[^>]*>?///gm, ''), 50

    refreshThread: debounce ->
      EventBus.$emit('updateThreadPosition', 0 - @requestedPosition)
    ,
      250

    addPeople: ->
      records = Records
      announcement = Records.announcements.buildFromModel(@discussion)
      @openAnnouncementModal(Records.announcements.buildFromModel(@discussion))

</script>

<template lang="pug">
v-navigation-drawer(v-if="discussion" v-model="open" :permanent="$vuetify.breakpoint.mdAndUp" width="210px" app fixed right clipped)
  .thread-nav
    v-list(dense)
      v-list-item(:to="urlFor(discussion)" @click="scrollTo('#context')")
        v-list-item-avatar(:size="20")
          v-icon(:size="20") mdi-format-vertical-align-top
        v-list-item-title(v-t="'activity_card.context'")
      //- v-slider(color="accent" track-color="accent" thumb-color="accent" thumb-size="64" v-model="inversePosition" vertical :max="0" :min="0 - discussion.createdEvent().childCount" thumb-label @change="emitPosition()")
      //-   template(v-slot:thumb-label)
      //-     | {{thumbLabel}}
      v-list-item(:to="urlFor(discussion)+'/'+(discussion.firstUnreadSequenceId() || '')" :disabled="!discussion.isUnread()")
        v-list-item-avatar(:size="20")
          v-icon(:size="20") mdi-bookmark-outline
        v-list-item-title(v-t="{path: 'activity_card.unread', args: {count: discussion.unreadItemsCount()}}")
      v-list-item(v-for="event in keyEvents" :key="event.id" :to="urlFor(discussion)+'/'+event.sequenceId")
        v-list-item-avatar(:size="20")
          user-avatar(v-if="event.kind == 'new_comment'" :user="event.actor()" :size="20")
          poll-common-chart-preview(v-if="event.kind == 'poll_created'" :poll='event.model()' :size="20" :showMyStance="false")
        v-list-item-title
          span {{title(event.model())}}
      v-list-item(:to="urlFor(discussion)+'/'+discussion.lastSequenceId()")
        v-list-item-avatar(:size="20")
          v-icon(:size="20") mdi-format-vertical-align-bottom
        v-list-item-title(v-t="'activity_card.latest'")
    v-divider
    v-list(dense)
      v-list-item(@click="addPeople()")
        v-list-item-title(v-t="'invitation_form.invite_people'")
      v-list-item(@click="scrollTo('#add-comment')")
        v-list-item-title(v-t="'activity_card.add_comment'")
      v-list-item(@click="openChangeVolumeModal(discussion)")
        v-list-item-title(v-t="'thread_context.email_settings'")
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
