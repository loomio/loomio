<script lang="coffee">
import { fieldFromTemplate, myLastStanceFor } from '@/shared/helpers/poll'
import { max, values, orderBy, compact } from 'lodash'

export default
  props:
    poll: Object
  methods:
    countFor: (option) ->
      return null unless @poll.closingAt
      @poll.stanceData[option.name] or 0
    barTextFor: (option) ->
      compact([option.name, @countFor(option)]).join(" - ").replace(/\s/g, '\u00a0')
    percentageFor: (option) ->
      max_val = max(values(@poll.stanceData))
      return unless max_val > 0
      "#{100 * @countFor(option) / max_val}%"
    backgroundImageFor: (option) ->
      "url(/img/poll_backgrounds/#{option.color.replace('#','')}.png)"
    styleData: (option) ->
      'background-image': @backgroundImageFor(option)
      'background-size': "#{@percentageFor(option)} 100%"
  computed:
    pollOptions: -> @poll.pollOptions()
</script>

<template lang="pug">
.poll-common-bar-chart
  .poll-common-bar-chart__bar.rounded(v-for="option in pollOptions" :key="option.id" :style="styleData(option)")
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
