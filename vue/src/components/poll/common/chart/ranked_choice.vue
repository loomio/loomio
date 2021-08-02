<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import Records   from '@/shared/services/records'
import { max, values, orderBy, map, find } from 'lodash'

export default
  props:
    poll: Object
  computed:
    rankedOptions: -> orderBy @poll.pollOptions(), 'totalScore', 'desc'

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
      tr(v-for='option, index in rankedOptions' :key="option.name")
        td.min {{index + 1}}
        td {{option.optionName()}}
        td {{option.totalScore}}
</template>
<style lang="sass">
.poll-common-ranked-choice-chart
  .min
    width: 1%
    white-space: nowrap
</style>
