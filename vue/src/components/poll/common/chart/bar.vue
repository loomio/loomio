<script lang="coffee">
import { fieldFromTemplate, myLastStanceFor } from '@/shared/helpers/poll'
import { max, values, orderBy, compact } from 'lodash'

export default
  props:
    poll: Object
  methods:
    barTextFor: (option) ->
      compact([option.name, option.totalScore]).join(" - ").replace(/\s/g, '\u00a0')
    percentageFor: (option) ->
      max_val = max @options.map((o) -> o.totalScore)
      return unless max_val > 0
      "#{100 * option.totalScore / max_val}%"
    backgroundImageFor: (option) ->
      "url(/img/poll_backgrounds/#{option.color.replace('#','')}.png)"
    styleData: (option) ->
      'background-image': @backgroundImageFor(option)
      'background-size': "#{@percentageFor(option)} 100%"
  computed:
    options: -> @poll.pollOptions()
</script>

<template lang="pug">
.poll-common-bar-chart
  table
    tbody
      tr(v-for="option in options" :key="option.id")
        td(style="min-width: 20%") {{option.optionName()}}
        td.px-1(style="width: 0") {{option.totalScore}}
        td.poll-common-bar-chart__bar.rounded(:style="styleData(option)")
          user-avatar(v-for="voter in option.voters()" :key="voter.id" :user="voter" :size="24" no-link)
        td(style="width: 0") {{option.scorePercent()}}%
</template>
<style lang="sass">
.poll-common-bar-chart
  display: flex
  flex-direction: column
  width: 100%
  td
    vertical-align: center

.poll-common-bar-chart__bar
  display: flex
  align-items: center
  min-width: 4px
  min-height: 30px
  background-repeat: no-repeat
  word-break: break-word
  white-space: normal
  line-height: 24px
  width: 100%
  padding: 0 4px
  .user-avatar
    opacity: 0.85

</style>
