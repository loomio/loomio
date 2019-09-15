<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import { find } from 'lodash'

export default
  props:
    discussion: Object

  data: ->
    poll: null

  created: ->
    @watchRecords
      collections: ['polls', 'stances']
      query: (store) =>
        @poll = find @discussion.activePolls(), (poll) ->
          !store.stances.findOrNull(latest: true, pollId: poll.id, participantId: AppConfig.currentUserId)

  computed:
    styles: ->
      { bar, top } = @$vuetify.application
      return
        display: 'flex'
        position: 'sticky'
        top: "#{bar + top}px"
        zIndex: 1
    event: ->
      @poll && @poll.createdEvent()

</script>
<template lang="pug">
v-card.current-poll-banner.mb-4.py-2.px-4(:style="styles" v-if="event && $route.params.sequence_id != event.sequenceId" :elevation="3")
  v-avatar.mr-4(:size="36")
    poll-common-chart-preview(:poll='poll' :size="36")
  .current-poll-banner__title.mr-4
    span {{poll.title}}
  v-spacer
  poll-common-closing-at.caption.mr-4(approximate :poll="poll")
  v-btn(color="primary" :to="urlFor(event)" v-t="'poll_common.vote'")
</template>

<style lang="sass">
.current-poll-banner
  display: flex
  align-items: center
.current-poll-banner__title
  white-space: nowrap
  overflow: hidden
  text-overflow: ellipsis

  // position: sticky top: 64px
  // z-index: 1
//   .v-banner__content
//     overflow: visible
// .v-banner--single-line
//   .v-banner__text
// overflow: visible !important
</style>
