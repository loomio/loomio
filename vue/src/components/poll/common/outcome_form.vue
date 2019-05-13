<script lang="coffee">
export default
  props:
    outcome: Object
  methods:
    datesAsOptions: ->
      fieldFromTemplate @outcome.poll().pollType, 'dates_as_options'
</script>
<template lang="pug">
.poll-common-outcome-form
  .lmo-disabled-form(v-if='isDisabled')
  .md-block
    label(v-t="'poll_common.statement'")
    lmo-textarea.poll-common-outcome-form__statement.lmo-primary-form-input(:model='outcome', field='statement', :placeholder="$t('poll_common_outcome_form.statement_placeholder')")
    poll-common-calendar-invite(:outcome='outcome', v-if='datesAsOptions()')
</template>
