<script lang="coffee">
import { fieldFromTemplate, myLastStanceFor } from '@/shared/helpers/poll'
import {max, values, orderBy } from 'lodash'

export default
  props:
    poll: Object
  methods:
    countFor: (option) ->
      this.poll.stanceData[option.name] or 0
    barTextFor: (option) ->
      "#{option.name} - #{this.countFor(option)}".replace(/\s/g, '\u00a0')
    percentageFor: (option) ->
      max = max(values(this.poll.stanceData))
      return unless max > 0
      "#{100 * this.countFor(option) / max}%"
    backgroundImageFor: (option) ->
      "url(/img/poll_backgrounds/#{option.color.replace('#','')}.png)"
    styleData: (option) ->
      'background-image': this.backgroundImageFor(option)
      'background-size': "#{this.percentageFor(option)} 100%"
  computed:
    orderedPollOptions: ->
      orderBy(this.poll.pollOptions(), ['priority'])
</script>

<template lang="pug">
.poll-common-bar-chart
  .poll-common-bar-chart__bar(v-for="option in orderedPollOptions" :key="option.id" :style="styleData(option)")
    | {{barTextFor(option)}}
</template>
<style lang="sass">
.poll-common-bar-chart
	display: flex
	flex-direction: column
	width: 100%
.poll-common-bar-chart__bar
	transition: background-size 0.1s ease-in-out
	display: flex
	align-items: center
	min-width: 4px
	min-height: 30px
	margin-top: 8px
	background-repeat: no-repeat
	word-break: break-word
	white-space: normal
	line-height: 24px
	width: 100%
	padding: 0 8px

</style>
