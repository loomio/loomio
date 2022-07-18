<script lang="coffee">
import Session from '@/shared/services/session'
import { startOfHour, addDays } from 'date-fns'
export default
  props:
    poll: Object

  data: ->
    isDisabled: !@poll.closingAt
    isEnabled: !!@poll.closingAt

  watch:
    isDisabled: (val) ->
      if val
        @poll.closingAt = null
      else
        @poll.closingAt = startOfHour(addDays(new Date, 3))

    isEnabled: (val) ->
      if val
        @poll.closingAt = startOfHour(addDays(new Date, 3))
      else
        @poll.closingAt = null
</script>

<template lang="pug">
.poll-common-wip-field
  v-checkbox(
    :disabled="poll.decidedVotersCount > 0"
    v-model="isEnabled"
    hide-details
  )
    div(slot="label")
      span {{$t('poll_common_wip_field.voting_open')}}
      space
      | -
      space
      span.text-lowercase {{$t('poll_common_wip_field.this_is_ready_for_voting', {poll_type: poll.translatedPollType()})}}
</template>
