<script lang="coffee">
import Records from '@/shared/services/records'
import { fieldFromTemplate, myLastStanceFor } from '@/shared/helpers/poll'
import { max, values, orderBy, compact } from 'lodash'

export default
  props:
    poll: Object
    noBars: Boolean

  data: ->
    votersByOptionId: {}
    options: {}

  created: ->
    @watchRecords
      collections: ['pollOptions']
      query: =>
        @options = @poll.pollOptionsForResults()
        @options.forEach (option) =>
          Records.users.fetchAnyMissingById(option.voterIds())

    @watchRecords
      collections: ['users']
      query: =>
        @options.forEach (option) =>
          @votersByOptionId[option.id] = option.voters()

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
      if @noBars
        {}
      else
        'background-image': @backgroundImageFor(option)
        'background-size': "#{@percentageFor(option)} 100%"
</script>

<template lang="pug">
.poll-common-bar-chart
  div.d-flex.rounded
    div.rounded.text-truncate.text-caption(
      v-for="option in options"
      :key="option.id"
      :style="{width: option.rawScorePercent()+'%', 'background-color': option.color}"
    )
      span.pa-1 {{option.optionName()}} {{option.scorePercent()}}%
  table
    thead
      tr
        th.text-left Option
        th.text-right.numcol Total Score
        th.text-right.numcol Voter Count
        th.text-right.numcol Average Score
        th Voters
    tbody
      tr(v-for="option in options" :key="option.id")
        td.pa-1.underlineme(:style="'border-left: solid 4px '+option.color")  {{option.optionName()}}
        td.pa-1.text-right.underlineme {{option.totalScore}}
        td.pa-1.text-right.underlineme {{option.voterIds().length}}
        td.pa-1.text-right.underlineme {{option.averageScore().toFixed(1)}}
        td.pl-1.underlineme(style="min-width: 40%")
          div(v-if="noBars")
            user-avatar.float-left(v-for="voter in votersByOptionId[option.id]" :key="voter.id" :user="voter" :size="24" no-link)
          //- .poll-common-bar-chart__bar.rounded( v-else :style="styleData(option)") {{option.scorePercent()}}%
          user-avatar.float-left(v-for="voter in votersByOptionId[option.id]" :key="voter.id" :user="voter" :size="24" no-link)
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
    padding-left: 4px
  table
    width: 100%
  .numcol
    width: 25px

  table, td, tr, th
    border-collapse: collapse
    // border-left: 1px solid #ddd
    // border-right: 1px solid #ddd

  // display: flex
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
