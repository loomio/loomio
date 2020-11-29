<script lang="coffee">
import Records from '@/shared/services/records'
import Flash   from '@/shared/services/flash'
import { addDays } from 'date-fns'
import { onError } from '@/shared/helpers/form'

export default
  props:
    poll: Object
    close: Function

  created: ->
    @poll.closingAt = addDays(new Date, 7)

  methods:
    submit: ->
      @poll.reopen()
      .then =>
        @poll.processing = false
        Flash.success("poll_common_reopen_form.success", {poll_type: @poll.translatedPollType()})
        @close()
      .catch onError(@poll)
  data: ->
    isDisabled: false
</script>

<template lang="pug">
v-card.poll-common-reopen-modal
  submit-overlay(:value='poll.processing')
  v-card-title
    h1.headline(tabindex="-1" v-t="{path: 'poll_common_reopen_form.title', args: {poll_type: poll.translatedPollType()}}")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text.poll-common-reopen-form
    span.lmo-hint-text(v-t="{path: 'poll_common_reopen_form.helptext', args: {poll_type: poll.translatedPollType()}}")
    poll-common-closing-at-field(:poll='poll')
  v-card-actions
    v-spacer
    v-btn.poll-common-reopen-form__submit(color="primary" @click='submit' :loading="poll.processing")
      span(v-t="'common.action.reopen'")
</template>
