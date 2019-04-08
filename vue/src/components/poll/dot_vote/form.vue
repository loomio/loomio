<style lang="scss">
.text-field-container {
  max-width: 30px;
}
</style>
<script lang="coffee">
export default
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
  v-layout.poll-common-checkbox-option__text(align-center)
    v-subheader(v-t="'poll_dot_vote_form.dots_per_person'")
    help-bubble(helptext="poll_dot_vote_form.dots_per_person_helptext")
    validation-errors(:subject="poll", field="dotsPerPerson")
    div.text-field-container
      v-text-field(type="number", min="1", v-model="poll.customFields.dots_per_person", single-line)
  poll-common-settings(:poll="poll")
</template>
