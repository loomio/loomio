<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import Records   from '@/shared/services/records'
import { max, values, orderBy, map, find } from 'lodash-es'

export default
  props:
    poll: Object
  computed:
    rankedOptions: ->
      sortedByScore = orderBy map(@poll.stanceData, (score, name) =>
        name: name
        score: score
        poll: => @poll
        pollOption: => find(@poll.pollOptions(), (option) -> option.name == name)
      )
      ,
        'score', 'desc'

      sortedByScore.forEach (option, index) =>
        option.rank = index+1
        option.rankOrScore = index+1

      sortedByScore

</script>
<template lang="pug">
.poll-common-ranked-choice-chart
  v-simple-table
    thead
      tr
        th.min(v-t="'poll_ranked_choice_form.rank'")
        th(v-t="'common.option'")
        th(v-t="'poll_ranked_choice_form.points'")
    tbody
      tr(v-for='option in rankedOptions' :key="option.name")
        td.min {{option.rank}}
        td
          poll-common-stance-choice(:poll="poll" :stance-choice="option" hide-score)
        td {{option.score}}
</template>
<style lang="sass">
.poll-common-ranked-choice-chart
  .min
    width: 1%
    white-space: nowrap
</style>
