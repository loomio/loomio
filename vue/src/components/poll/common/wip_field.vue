<script lang="coffee">
import Session from '@/shared/services/session'
import { startOfHour, addDays } from 'date-fns'
export default
  props:
    poll: Object

  data: ->
    isDisabled: !@poll.closingAt

  watch:
    isDisabled: (val) ->
      if val
        @poll.closingAt = null
      else
        @poll.closingAt = startOfHour(addDays(new Date, 3))
</script>

<template lang="pug">
.poll-common-wip-field
  v-checkbox(
    v-model="isDisabled"
    hide-details
    :disabled="poll.decidedVotersCount > 0"
  )
    div(slot="label")
      span {{$t('poll_common_wip_field.draft_mode')}}
      space
      | -
      space
      //- span.text-lowercase {{$t('poll_common_wip_field.title', {poll_type: poll.translatedPollType()})}}
      span.text-lowercase {{$t('poll_common_wip_field.disable_voting_during_development', {poll_type: poll.translatedPollType()})}}
</template>
