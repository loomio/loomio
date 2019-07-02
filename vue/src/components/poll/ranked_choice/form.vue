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
  poll-common-form-options-field(:poll="poll")
  //- v-combobox(v-model="poll.pollOptionNames" multiple chips deletable-chips :label="$t('poll_common_form.options')" :placeholder="$t('poll_common_form.options_placeholder')")
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
