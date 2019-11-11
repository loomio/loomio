<script lang="coffee">
export default
  props:
    poll: Object
  created: ->
    @poll.customFields.max_score = @poll.customFields.max_score or 9
    @poll.customFields.min_score = @poll.customFields.min_score or 0
</script>

<template lang="pug">
.poll-score-form
  poll-common-form-fields(:poll="poll")
  poll-common-form-options-field(:poll="poll")
  v-layout
    v-text-field.poll-score-form__min(v-model="poll.customFields.min_score" type="number" :step="1" :label="$t('poll_common.min_score')")
    v-spacer
    v-text-field.poll-score-form__max(v-model="poll.customFields.max_score" type="number" :step="1" :label="$t('poll_common.max_score')")
  poll-common-closing-at-field(:poll="poll")
  poll-common-settings(:poll="poll")
</template>
