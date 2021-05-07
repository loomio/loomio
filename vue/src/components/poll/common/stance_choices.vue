<script lang="coffee">
import { fieldFromTemplate } from '@/shared/helpers/poll'
import AppConfig from '@/shared/services/app_config'
import { optionColors, optionImages } from '@/shared/helpers/poll'

export default
  props:
    stance: Object

  data: ->
    optionColors: optionColors()
    optionImages: optionImages()

  computed:
    poll: -> @stance.poll()
    variableScore: -> @poll.hasVariableScore()
    color: ->
      @pollOption.color

    pollType: ->
      @poll.pollType

    stanceChoices: ->
      @stance.orderedStanceChoices().filter (c) -> c.score > 0

    datesAsOptions: -> @poll.datesAsOptions()

  methods:
    emitClick: -> @$emit('click')

    colorFor: (score) ->
      switch score
        when 2 then AppConfig.pollColors.proposal[0]
        when 1 then AppConfig.pollColors.proposal[1]
        when 0 then AppConfig.pollColors.proposal[2]

</script>

<template lang="pug">
.poll-common-stance-choices(v-if="!poll.singleChoice()")
  span.caption(v-if='stance.castAt && stance.totalScore() == 0' v-t="'poll_common_votes_panel.none_of_the_above'" )
  template(v-if="datesAsOptions")
    v-chip.mr-1.my-1(v-if="choice.show()" v-for="choice in stanceChoices" :key="choice.id" outlined :color="colorFor(choice.score)" @click="emitClick")
      poll-meeting-time(:name="choice.pollOption().name")
  template(v-else)
    .poll-common-stance-choice.mt-1(:class="'poll-common-stance-choice--' + pollType" v-if="choice.show()" v-for="choice in stanceChoices" :key="choice.id")
      v-icon(small :color="choice.pollOption().color" v-if="!variableScore") mdi-check
      span(:style="{color: choice.pollOption().color}" v-if="variableScore") {{choice.rankOrScore}}
      span.ml-2.text--secondary
        |{{ choice.pollOption().optionName() }}

</template>
