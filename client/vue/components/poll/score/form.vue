<style lang="scss">
.poll-score-form__poll-option-names {
  width: 100%;
  display: flex;
  justify-content: space-between;
}

.poll-score-form__add-option {
  align-items: flex-start;
}

.poll-score-form__add-option-field {
  width: 100%;
}
</style>

<script lang="coffee">
module.exports =
  props:
    poll: Object
  created: ->
    @poll.customFields.max_score = @poll.customFields.max_score or 9
</script>

<template lang="pug">
.poll-score-form
  poll-common-form-fields(:poll="poll")
  poll-common-form-options(:poll="poll")
  poll-common-closing-at-field.md-input-compensate.md-block(:poll="poll")

  .md-input-compensate
    poll-common-settings(:poll="poll")
</template>
