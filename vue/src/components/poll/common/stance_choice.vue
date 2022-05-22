<script lang="coffee">
import { fieldFromTemplate } from '@/shared/helpers/poll'
import AppConfig from '@/shared/services/app_config'
import { optionColors, optionImages } from '@/shared/helpers/poll'

export default
  props:
    poll:
      type: Object
      required: true
    stanceChoice:
      type: Object
      required: true
    size:
      type: Number
      default: 24
  data: ->
    optionColors: optionColors()
    optionImages: optionImages()

  computed:
    color: ->
      @pollOption.color

    pollOption: ->
      @stanceChoice.pollOption

    pollType: ->
      @poll.pollType

    optionName: ->
      if AppConfig.pollTypes[@poll.pollType].poll_option_name_format == 'i18n'
        @$t('poll_' + @pollType + '_options.' + @stanceChoice.pollOption.name)
      else
        @stanceChoice.pollOption.name

  methods:
    emitClick: -> @$emit('click')

    colorFor: (score) ->
      switch score
        when 2 then AppConfig.pollColors.proposal[0]
        when 1 then AppConfig.pollColors.proposal[1]
        when 0 then AppConfig.pollColors.proposal[2]

</script>

<template lang="pug">
.poll-common-stance-choice.mr-1.mb-1(:class="'poll-common-stance-choice--' + pollType" row)
  v-avatar(tile :size="size" v-if='poll.config().poll_option_name_format == "i18n"')
    img(:src="'/img/' + optionImages[pollOption.name] + '.svg'", :alt='optionName')
  span.body-2(v-if='$pollTypes[poll.pollType].poll_option_name_format == "none"')
    v-icon.mr-2(small :color="pollOption.color") mdi-check
    span {{ optionName }}
  v-chip(v-if='$pollTypes[poll.pollType].poll_option_name_format == "iso8601"'
    outlined :color="colorFor(stanceChoice.score)" @click="emitClick")
    poll-meeting-time(:name="optionName")
</template>
