<script lang="coffee">
import { fieldFromTemplate } from '@/shared/helpers/poll'

export default
  props:
    stanceChoice: Object
    size:
      type: Number
      default: 24
  computed:
    color: ->
      @pollOption.color

    pollOption: ->
      @stanceChoice.pollOption()

    pollType: ->
      @stanceChoice.poll().pollType

    optionName: ->
      if @translateOptionName
        @$t('poll_' + @pollType + '_options.' + stanceChoice.pollOption().name)
      else
        @stanceChoice.pollOption().name

    translateOptionName: ->
      return unless @stanceChoice.poll()
      fieldFromTemplate(@pollType, 'translate_option_name')

    datesAsOptions: ->
      return unless @stanceChoice.poll()
      fieldFromTemplate(@pollType, 'dates_as_options')

    hasVariableScore: ->
      fieldFromTemplate(@stanceChoice.poll().pollType, 'has_variable_score')

    useOptionIcon: ->
      fieldFromTemplate(@stanceChoice.poll().pollType, 'has_option_icons')

</script>

<template lang="pug">
.poll-common-stance-choice(:class="'poll-common-stance-choice--' + pollType" row)
  span(v-if="!datesAsOptions")
    v-avatar(tile :size="size" v-if='useOptionIcon')
      img(:src="'/img/' + pollOption.name + '.svg'", alt='optionName')
    v-chip(v-if='!useOptionIcon' :color="pollOption.color")
      span(v-if="hasVariableScore")
        | {{stanceChoice.score}}
        mid-dot
      span {{ optionName }}
  span(v-if="datesAsOptions")
    v-chip(pill)
      v-avatar(left)
        img(src="/img/abstain.svg" v-if="stanceChoice.score == 1")
        img(src="/img/agree.svg" v-if="stanceChoice.score == 2")
      poll-meeting-time(:name="optionName")
</template>
