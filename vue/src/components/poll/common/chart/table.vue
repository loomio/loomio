<script lang="coffee">
import Records from '@/shared/services/records'
import { fieldFromTemplate, myLastStanceFor } from '@/shared/helpers/poll'
import { max, values, orderBy, compact } from 'lodash'

export default
  props:
    poll: Object
    options: Array

  data: ->
    votersByOptionId: {}

  computed:
    simple: ->
      ['proposal', 'count', 'poll'].includes(@poll.pollType)

  created: ->
    @watchRecords
      collections: ['users']
      query: =>
        @options.forEach (option) =>
          @votersByOptionId[option.id] = option.voters()

</script>

<template lang="pug">
.poll-common-chart-table
  table
    thead(v-if="!simple")
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
        td.pa-1.text-right.underlineme(v-if="!simple") {{option.voterIds().length}}
        td.pa-1.text-right.underlineme(v-if="!simple") {{option.averageScore().toFixed(1)}}
        td.pa-1.text-right.underlineme {{option.scorePercent()}}%
        td.pl-1.underlineme(style="min-width: 40%")
          user-avatar.float-left(v-for="voter in votersByOptionId[option.id]" :key="voter.id" :user="voter" :size="24" no-link)
</template>
<style lang="sass">
.theme--dark
  .poll-common-chart-table
    td.underlineme
      border-bottom: thin solid hsla(0,0%,100%,.12)

.theme--light
  .poll-common-chart-table
    td.underlineme
      border-bottom: thin solid #eee

.poll-common-chart-table
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

</style>
