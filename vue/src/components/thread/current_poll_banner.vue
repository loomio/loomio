<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import { find } from 'lodash'

export default
  props:
    discussion: Object

  data: ->
    poll: null
    event: null

  created: ->
    @watchRecords
      collections: ['polls', 'stances']
      query: (store) =>
        @poll = find @discussion.activePolls(), (poll) ->
          !store.stances.findOrNull(latest: true, pollId: poll.id, participantId: AppConfig.currentUserId)
        @event = @poll.createdEvent() if @poll

</script>
<template lang="pug">

v-banner.current-poll-banner.mb-4(v-if="event && $route.params.sequence_id != event.sequenceId" single-line sticky :elevation="3")
  v-layout(align-center)
    v-avatar.mr-4(:size="36")
      poll-common-chart-preview(:poll='poll' :size="36")
    span {{poll.title}}
    mid-dot
    poll-common-closing-at.caption(approximate :poll="poll")
  template(v-slot:actions)
    v-btn(text color="primary" :to="urlFor(event)") vote
</template>

<style lang="sass">
.current-poll-banner
  .v-banner__content
    overflow: visible
.v-banner--single-line
  .v-banner__text
    overflow: visible !important
</style>
