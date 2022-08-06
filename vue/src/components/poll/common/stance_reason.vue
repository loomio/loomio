<script lang="coffee">
export default
  props:
    poll: Object
    stance: Object
    prompt: String
  computed:
    maxLength: ->
      if @poll.limitReasonLength
        500
      else
        undefined
</script>

<template lang="pug">
.poll-common-stance-reason
  lmo-textarea.poll-common-vote-form__reason(
    :focus-id="'poll-'+poll.id"
    v-if="poll.stanceReasonRequired != 'disabled'"
    :model='stance'
    field="reason"
    :label="$t('poll_common.reason')"
    :placeholder="prompt || poll.reasonPrompt || $t('poll_common.reason_placeholder')"
    :max-length='maxLength'
    autofocus
  )
  validation-errors(:subject="stance" field="reason")

</template>
