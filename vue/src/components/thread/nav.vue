<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import UrlFor from '@/mixins/url_for'

export default
  mixins: [UrlFor]
  data: ->
    discussion: null
    open: null

  mounted: ->
    EventBus.$on 'currentComponent', (options) =>
      @discussion = options.discussion
    EventBus.$on 'toggleThreadNav', => @open = !@open

    # load any key events for the discussion
    # events where kind in 'poll_created', 'outcome_created', announced?
    # and dislpay them
    # @watchRecords
    #   key: @discussion.id
    #   collections: ["polls"]
    #   query: (records) =>
    #     @activePolls = @discussion.activePolls() if @discussion

  methods:
    scrollTo: (selector) ->
      @$vuetify.goTo(selector)

  watch:
    open: (val) ->
      console.log 'sidebar open', val

</script>

<template lang="pug">
v-navigation-drawer(v-if="discussion" :permanent="$vuetify.breakpoint.mdAndUp" width="210px" app fixed right clipped)
  | {{open}}
  .thread-nav
    v-list
      v-subheader Jump to:
      v-list-tile(:to="urlFor(discussion)")
        v-list-tile-title Context
      v-list-tile(:to="urlFor(discussion)+'/'+discussion.firstSequenceId()")
        v-list-tile-title First
      v-list-tile(:disabled="!discussion.firstUnreadSequenceId()" :to="urlFor(discussion)+'/'+discussion.firstUnreadSequenceId()")
        v-list-tile-title Unread
      v-list-tile(:to="urlFor(discussion)+'/'+discussion.lastSequenceId()")
        v-list-tile-title Last
      v-list-tile(@click="scrollTo('.activity-panel__actions')")
        v-list-tile-title Add comment

</template>
