<script lang="coffee">
import { fieldFromTemplate } from '@/shared/helpers/poll'

export default
  props:
    outcome: Object
  data: ->
    isDisabled: false
  methods:
    datesAsOptions: ->
      fieldFromTemplate @outcome.poll().pollType, 'dates_as_options'
</script>
<template lang="pug">
.poll-common-outcome-form
  .lmo-disabled-form(v-if='isDisabled')
  .md-block
    label(v-t="'poll_common.statement'")
    lmo-textarea.poll-common-outcome-form__statement.lmo-primary-form-input(:model='outcome', field='statement', :placeholder="'poll_common_outcome_form.statement_placeholder'")
    poll-common-calendar-invite(:outcome='outcome', v-if='datesAsOptions()')
</template>
