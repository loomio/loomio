<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import AnnouncementModalMixin from '@/mixins/announcement_modal'
import ChangeVolumeModalMixin from '@/mixins/change_volume_modal'
import { debounce, truncate } from 'lodash'

export default
  mixins: [AnnouncementModalMixin, ChangeVolumeModalMixin]
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
      @$vuetify.goTo(selector, duration: 0)

    title: (model) ->
      if model.title or model.statement
        truncate (model.title || model.statement || model.body).replace(///<[^>]*>?///gm, ''), 50
      else
        parser = new DOMParser()
        doc = parser.parseFromString(model.statement || model.body, 'text/html')
        if el = doc.querySelector('h1,h2,h3')
          el.textContent
        else
          truncate (model.body).replace(///<[^>]*>?///gm, ''), 50

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
v-navigation-drawer.lmo-no-print(v-if="discussion" v-model="open" :permanent="$vuetify.breakpoint.mdAndUp" width="210px" app fixed right clipped)
  .thread-nav
    v-list(dense)
      v-list-item(:to="urlFor(discussion)" @click="scrollTo('#context')")
        v-list-item-avatar(:size="20")
          v-icon(:size="20") mdi-format-vertical-align-top
        v-list-item-title(v-t="'activity_card.beginning'")
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
      v-list-item(@click="scrollTo('#add-comment')")
        v-list-item-avatar(:size="20")
          v-icon(:size="20") mdi-format-vertical-align-bottom
        v-list-item-title(v-t="'activity_card.end'")
    v-divider
    v-subheader(v-t="'thread_nav.participants'")
      //- revent discussion event authors
    v-list(dense)
      v-list-item(@click="addPeople()")
        v-list-item-title(v-t="'invitation_form.invite_people'")
    v-divider

    v-list(dense)
      v-list-item(two-line @click="openChangeVolumeModal(discussion)")
        v-list-item-content
          v-list-item-title(v-t="'change_volume_form.simple.label'")
          v-list-item-subtitle
            span(v-t="'change_volume_form.simple.' + discussion.volume()")
          //- v-list-item-subtitle
          //-   span(v-t="'change_volume_form.simple.' + discussion.volume() + '_explain'")



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
