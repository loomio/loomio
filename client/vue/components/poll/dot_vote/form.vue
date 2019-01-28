<style lang="scss">
</style>
<script lang="coffee">
module.exports =
  props:
    poll: Object
  created: ->
    @poll.customFields.dots_per_person = @poll.customFields.dots_per_person or 8
</script>
<template lang="pug">
.poll-dot-vote-form
  poll-common-form-fields(:poll="poll")
  poll-common-form-options(:poll="poll")
  poll-common-closing-at-field(:poll="poll")

  .md-input-compensate
    .lmo-flex.lmo-flex__center
      .poll-common-checkbox-option__text.md-list-item-text.lmo-flex__grow
        .lmo-flex--row
          h3(v-t="'poll_dot_vote_form.dots_per_person'")
          help-bubble(helptext="poll_dot_vote_form.dots_per_person_helptext")
        validation-errors(:subject="poll", field="dotsPerPerson")
      v-text-field.lmo-number-input(type="number", min="1", v-model="poll.customFields.dots_per_person")
    poll-common-settings(:poll="poll")
</template>
