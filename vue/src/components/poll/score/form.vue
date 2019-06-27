<script lang="coffee">
export default
  props:
    poll: Object
  created: ->
    @poll.customFields.max_score = @poll.customFields.max_score or 9
</script>

<template lang="pug">
.poll-score-form
  poll-common-form-fields(:poll="poll")
  v-combobox(v-model="poll.pollOptionNames" multiple chips deletable-chips :label="$t('poll_common_form.options')" :placeholder="$t('poll_common_form.options_placeholder')")
  poll-common-closing-at-field.md-input-compensate.md-block(:poll="poll")

  .md-input-compensate
    poll-common-settings(:poll="poll")
</template>
