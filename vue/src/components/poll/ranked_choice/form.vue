<script lang="coffee">
export default
  props:
    poll: Object
  created: ->
    @poll.setMinimumStanceChoices()
  watch:
    'poll.pollOptionNames': ->
      @poll.setMinimumStanceChoices()
</script>

<template lang="pug">
.poll-ranked-choice-form
  poll-common-form-fields(:poll="poll")
  poll-common-form-options-field(:poll="poll")
  //- v-combobox(v-model="poll.pollOptionNames" multiple chips deletable-chips :label="$t('poll_common_form.options')" :placeholder="$t('poll_common_form.options_placeholder')")
  poll-common-wip-field(:poll="poll")
  poll-common-closing-at-field(:poll="poll")

  .lmo-flex.lmo-flex__center(layout="row")
    .poll-common-checkbox-option__text.md-list-item-text.lmo-flex__grow
      validation-errors(:subject="poll", field="minimumStanceChoices")
    v-text-field.lmo-number-input(:label="$t('poll_ranked_choice_form.minimum_stance_choices_helptext')" type="number" :min="1" :max="poll.pollOptionNames.length" v-model="poll.customFields.minimum_stance_choices")

  poll-common-settings(:poll="poll")
  common-notify-fields(:model="poll")
</template>
