<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import Records   from '@/shared/services/records'
import { max, values, sortBy, map, find } from 'lodash'

export default
  props:
    poll: Object
  methods:
    rankFor: (score) ->
      @poll.customFields.minimum_stance_choices - score + 1

  computed:
    rankedOptions: ->
      sortBy map(@poll.stanceData, (score, name) =>
        name: name
        score: score
        rank: @rankFor(score)
        rankOrScore: @rankFor(score)
        poll: => @poll
        pollOption: => find(@poll.pollOptions(), (option) -> option.name == name)
      )
      ,
        'rank'
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
          poll-common-stance-choice(:stance-choice="option" hide-score)
        td {{option.score}}

</template>
<style lang="scss">
.poll-common-ranked-choice-chart {
  .min {
    width: 1%;
    white-space: nowrap;
  }
}
</style>
