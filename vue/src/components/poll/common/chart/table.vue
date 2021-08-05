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
  v-simple-table(dense)
    thead
      tr
        th Option
        th(v-if="!simple" v-t="'poll_ranked_choice_form.rank'")
        th.text-right(v-t="'poll_ranked_choice_form.points'")
        th.text-right(v-if="!simple" v-t="'membership_card.voters'")
        th.text-right(v-if="!simple" v-t="'poll_ranked_choice_form.average'")
        th.text-right(v-t="'poll_ranked_choice_form.pct_of_points'")
        th(v-if="poll.pollType != 'ranked_choice'") Voters
    tbody
      tr(v-for="option, index in options" :key="option.id")
        td(:style="'border-left: solid 4px '+option.color")  {{option.optionName()}}
        td.text-right(v-if="!simple") {{index+1}}
        td.text-right {{option.totalScore}}
        td.text-right(v-if="!simple") {{option.voterIds().length}}
        td.text-right(v-if="!simple") {{option.averageScore().toFixed(1)}}
        td.text-right {{option.scorePercent()}}%
        td.py-1(v-if="poll.pollType != 'ranked_choice'")
          user-avatar.float-left(v-for="voter in votersByOptionId[option.id]" :key="voter.id" :user="voter" :size="24" no-link)
</template>
<style lang="sass">
.poll-common-chart-table
  table
    width: 100%
//   .numcol
//     width: 25px
//
//   table, td, tr, th
//     border-collapse: collapse
//     // border-left: 1px solid #ddd
//     // border-right: 1px solid #ddd
//
//   // display: flex
//   flex-direction: column
//   width: 100%
//   td
//     vertical-align: center

</style>
