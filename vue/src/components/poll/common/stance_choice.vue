<script lang="coffee">
import { fieldFromTemplate } from '@/shared/helpers/poll'
import AppConfig from '@/shared/services/app_config'

export default
  props:
    stanceChoice: Object
    size:
      type: Number
      default: 24
  computed:
    poll: ->
      @stanceChoice.poll()

    color: ->
      @pollOption.color

    pollOption: ->
      @stanceChoice.pollOption()

    pollType: ->
      @poll.pollType

    optionName: ->
      if @poll.translateOptionName()
        @$t('poll_' + @pollType + '_options.' + stanceChoice.pollOption().name)
      else
        @stanceChoice.pollOption().name

  methods:
    colorFor: (score) ->
      if score == 2
        AppConfig.pollColors.proposal[0]
      else
        AppConfig.pollColors.proposal[1]

</script>

<template lang="pug">
.poll-common-stance-choice(:class="'poll-common-stance-choice--' + pollType" row)
  span(v-if="!poll.datesAsOptions()")
    v-avatar(tile :size="size" v-if='poll.hasOptionIcons()')
      img(:src="'/img/' + pollOption.name + '.svg'", alt='optionName')
    v-chip(small  v-if='!poll.hasOptionIcons()' :color="pollOption.color")
      span {{ optionName }}
      span(v-if="poll.hasVariableScore()")
        mid-dot
        span {{stanceChoice.score}}
  span(v-if="poll.datesAsOptions()")
    v-chip(outlined :color="colorFor(stanceChoice.score)")
      poll-meeting-time(:name="optionName")
</template>
