<script lang="coffee">
import { fieldFromTemplate, myLastStanceFor } from '@/shared/helpers/poll'
import { max, values, orderBy, compact } from 'lodash'

export default
  props:
    poll: Object

  created: ->
    @watchRecords
      collections: ['pollOptions']
      query: => @options = @poll.pollOptions()

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
</script>

<template lang="pug">
.poll-common-bar-chart
  table.mx-auto
    tbody
      tr( v-for="option in options" :key="option.id")
        td.pr-2.underlineme {{option.optionName()}}
        td.px-2.text-right.underlineme {{option.totalScore}}
        td.px-2.text-right.underlineme {{option.scorePercent()}}%
        td.pl-2(style="min-width: 40%")
          .poll-common-bar-chart__bar.rounded(:style="styleData(option)")
            user-avatar(v-for="voter in option.voters()" :key="voter.id" :user="voter" :size="20" no-link)
</template>
<style lang="sass">
.theme--dark
  .poll-common-bar-chart
    td.underlineme
      border-bottom: thin solid hsla(0,0%,100%,.12)

.theme--light
  .poll-common-bar-chart
    td.underlineme
      border-bottom: thin solid #eee

.poll-common-bar-chart
  th
    padding-right: 8px
    text-align: left

  table, td, tr, th
    border-collapse: collapse
    // border-left: 1px solid #ddd
    // border-right: 1px solid #ddd

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
