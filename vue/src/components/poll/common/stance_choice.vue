<style lang="scss">
@import 'variables';
.poll-common-stance-choice {
  color: $primary-text-color;
  line-height: 32px;
  margin-right: 8px;
}
</style>

<script lang="coffee">
import { fieldFromTemplate } from '@/shared/helpers/poll'

export default
  props:
    stanceChoice: Object
  methods:
    translateOptionName: ->
      return unless @stanceChoice.poll()
      fieldFromTemplate(@stanceChoice.poll().pollType, 'translate_option_name')

    hasVariableScore: ->
      return unless @stanceChoice.poll()
      fieldFromTemplate(@stanceChoice.poll().pollType, 'has_variable_score')

    datesAsOptions: ->
      return unless @stanceChoice.poll()
      fieldFromTemplate(@stanceChoice.poll().pollType, 'dates_as_options')
</script>

<template lang="pug">
.poll-common-stance-choice(:class="'poll-common-stance-choice--' + stanceChoice.poll().pollType")
  poll-common-stance-icon(:stance-choice="stanceChoice")
  span(v-if="hasVariableScore()")
    | > {{stanceChoice.score}} -
  span.poll-common-stance-choice__option-name(v-if="translateOptionName()", v-t="'poll_' + stanceChoice.poll().pollType + '_options.' + stanceChoice.pollOption().name")
  poll-meeting-time(v-if="!translateOptionName() && datesAsOptions()", name="stanceChoice.pollOption().name")
  span(v-if="!translateOptionName() && !datesAsOptions()")
    |{{stanceChoice.pollOption().name}}
</template>
