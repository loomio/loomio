<script lang="coffee">
import { fieldFromTemplate } from '@/shared/helpers/poll'
import AppConfig from '@/shared/services/app_config'

export default
  props:
    stanceChoice: Object
    size:
      type: Number
      default: 24
    hideScore:
      type: Boolean
      default: false
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
    emitClick: -> @$emit('click')

    colorFor: (score) ->
      switch score
        when 2 then AppConfig.pollColors.proposal[0]
        when 1 then AppConfig.pollColors.proposal[1]
        when 0 then AppConfig.pollColors.proposal[2]

</script>

<template lang="pug">
.poll-common-stance-choice.mr-1(:class="'poll-common-stance-choice--' + pollType" row)
  span(v-if="!poll.datesAsOptions()")
    v-avatar(tile :size="size" v-if='poll.hasOptionIcons()')
      img(:src="'/img/' + pollOption.name + '.svg'", :alt='optionName')
    v-chip(v-if='!poll.hasOptionIcons()' :color="pollOption.color")
      span {{ optionName }}
      span(v-if="!hideScore && poll.hasVariableScore()")
        mid-dot
        span {{stanceChoice.rankOrScore}}
  span(v-if="poll.datesAsOptions()")
    v-chip(outlined :color="colorFor(stanceChoice.score)" @click="emitClick")
      poll-meeting-time(:name="optionName")
</template>
