<script lang="coffee">
export default
  props:
    stance: Object
    prompt: String
  computed:
    maxLength: ->
      if @stance.poll().allowLongReason
        undefined
      else
        500
</script>

<template lang="pug">
.poll-common-stance-reason
  lmo-textarea.poll-common-vote-form__reason(
    :model='stance'
    field="reason"
    :label="$t('poll_common.reason')"
    :placeholder="prompt || $t('poll_common.reason_placeholder')"
    :max-length='maxLength'
    autofocus
  )
  validation-errors(:subject="stance" field="reason")

</template>
