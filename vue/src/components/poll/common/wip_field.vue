<script lang="coffee">
import Session from '@/shared/services/session'
import { startOfHour, addDays } from 'date-fns'

export default
  props:
    poll: Object

  data: ->
    draft: !@poll.closingAt

  watch:
    draft: (val) ->
      if val
        @poll.closingAt = null
      else
        @poll.closingAt = startOfHour(addDays(new Date, 3))

</script>

<template lang="pug">
.poll-common-wip-field
  v-checkbox(hide-details v-model="draft")
    div(slot="label")
      span(v-t="'poll_common_wip_field.title'")
      .caption(v-t="{path: 'poll_common_wip_field.helptext', args: {poll_type: poll.translatedPollType()}}")
</template>
