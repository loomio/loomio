<script lang="coffee">
import Session from '@/shared/services/session'
import { startOfHour, addDays } from 'date-fns'
export default
  props:
    poll: Object
  data: ->
    enabled: @poll.closingAt
  watch:
    enabled: (val) ->
      if val
        @poll.closingAt = startOfHour(addDays(new Date, 3))
      else
        @poll.closingAt = null
</script>

<template lang="pug">
.poll-common-wip-field
  v-checkbox(
    v-model="enabled"
    hide-details
    :disabled="poll.decidedVotersCount > 0"
  )
    div(slot="label")
      template(v-if="enabled")
        span(v-t="'poll_common_wip_field.enable_voting'")
      template(v-if="!enabled")
        span(v-t="'poll_common_wip_field.enable_voting'")
</template>
