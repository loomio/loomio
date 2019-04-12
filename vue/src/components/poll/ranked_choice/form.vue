<style lang="scss">
@import 'mixins';
.poll-ranked-choice-form__add-option-field,
.poll-ranked-choice-form__option-text {
  flex-grow: 1;
  width: 100%;
  @include truncateText;
}

.poll-ranked-choice-form__option-button {
  display: flex;
  min-width: 24px;
  margin: 0 16px;
}

.poll-ranked-choice-form__option-icon {
  margin: auto;
}
</style>

<script lang="coffee">
export default
  props:
    poll: Object
  created: ->
    @poll.setMinimumStanceChoices()
</script>

<template lang="pug">
.poll-ranked-choice-form
  poll-common-form-fields(:poll="poll")
  poll-common-form-options(:poll="poll")
  poll-common-closing-at-field.md-input-compensate.md-block(:poll="poll")

  .md-input-compensate
    .lmo-flex.lmo-flex__center(layout="row")
      .poll-common-checkbox-option__text.md-list-item-text.lmo-flex__grow
        h3(v-t="'poll_ranked_choice_form.minimum_stance_choices'")
        p(v-t="'poll_ranked_choice_form.minimum_stance_choices_helptext'")
        validation-errors(:subject="poll", field="minimumStanceChoices")
      v-text-field.lmo-number-input(type="number", min="1", v-model="poll.customFields.minimum_stance_choices")

  poll-common-settings(:poll="poll")
</template>
