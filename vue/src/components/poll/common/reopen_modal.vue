<script lang="coffee">
import Records from '@/shared/services/records'
import Flash   from '@/shared/services/flash'
import { addDays } from 'date-fns'

export default
  props:
    poll: Object
    close: Function

  created: ->
    @poll.closingAt = addDays(new Date, 7)
    
  methods:
    submit: ->
      @poll.reopen().then =>
        @poll.processing = false
        Flash.success "poll_common_reopen_form.#{@poll.pollType}_reopened"
        @close()
  data: ->
    isDisabled: false
</script>

<template lang="pug">
v-card.poll-common-reopen-modal
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
