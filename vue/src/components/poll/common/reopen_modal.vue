<script lang="coffee">
import Records from '@/shared/services/records'
import { submitForm } from '@/shared/helpers/form'
import { addDays } from 'date-fns'

export default
  props:
    poll: Object
    close: Function

  created: ->
    @poll.closingAt = addDays(new Date, 7)
    @submit = submitForm @, @poll,
      submitFn: @poll.reopen
      flashSuccess: "poll_common_reopen_form.#{@poll.pollType}_reopened"
      successCallback: => @close()
  data: ->
    isDisabled: false
</script>

<template lang="pug">
v-card.poll-common-modal
  submit-overlay(:value='poll.processing')
  v-card-title
    h1.headline(v-t="'poll_common_reopen_form.title'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text.poll-common-reopen-form
    span.lmo-hint-text(v-t="'poll_common_reopen_form.helptext'")
    poll-common-closing-at-field(:poll='poll')
  v-card-actions
    v-btn.poll-common-reopen-form__submit(color="primary" @click='submit' v-t="'common.action.reopen'")
</template>
