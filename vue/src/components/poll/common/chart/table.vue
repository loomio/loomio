<script lang="coffee">
import Records from '@/shared/services/records'
import { fieldFromTemplate, myLastStanceFor } from '@/shared/helpers/poll'
import { max, values, orderBy, compact } from 'lodash'
import BarIcon from '@/components/poll/common/icon/bar.vue'
import CountIcon from '@/components/poll/common/icon/count.vue'
import PieIcon from '@/components/poll/common/icon/pie.vue'
import GridIcon from '@/components/poll/common/icon/grid.vue'

export default
  components: {BarIcon, CountIcon, PieIcon, GridIcon}
  props:
    poll: Object

  data: ->
    votersByOptionId: {}

  created: ->
    @watchRecords
      collections: ['users']
      query: =>
        @poll.results.forEach (option) =>
          @votersByOptionId[option.id] = Records.users.find(option.voter_ids)

</script>

<template lang="pug">
.poll-common-chart-table
  v-simple-table(dense)
    thead
      tr
        template(v-for="col in poll.resultColumns")
          th.text-left(v-if="col == 'chart'" v-t='poll.closed_at ? "poll_common.results" : "poll_common.current_results"')
          th.text-left(v-if="col == 'name'" v-t='"common.option"')
          th.text-right(v-if="col == 'score_percent'" v-t='"poll_ranked_choice_form.pct_of_points"')
          th.text-right(v-if="col == 'voter_percent'" v-t='"poll_ranked_choice_form.pct_of_voters"')
          th.text-right(v-if="col == 'score'" v-t='"poll_ranked_choice_form.points"')
          th.text-right(v-if="col == 'rank'" v-t='"poll_ranked_choice_form.rank"')
          th.text-right(v-if="col == 'average'" v-t='"poll_ranked_choice_form.average"')
          th.text-right(v-if="col == 'voter_count'" v-t='"membership_card.voters"')
          th(v-if="col == 'voters'")
    tbody
      tr(v-for="option, index in poll.results" :key="option.id")
        template(v-for="col in poll.resultColumns")
          td.pr-2.py-2(v-if="col == 'chart' && poll.chartType == 'pie' && index == 0" :rowspan="poll.results.length")
            pie-icon(:poll="poll" :size='128')
          td.pr-2.py-2(v-if="col == 'chart' && poll.chartType == 'bar'" style="width: 128px; padding: 0 8px 0 0")
            div.rounded(:style="{width: option.max_score_percent+'%', height: '24px', 'background-color': option.color}")
          td(v-if="col == 'name' && poll.pollOptionNameFormat == 'iso8601'")
            // poll-meeting-time(:name='option.name')
          td(v-if="col == 'name' && poll.pollOptionNameFormat == 'i18n'" v-t="option.name")
          td(v-if="col == 'name' && poll.pollOptionNameFormat == 'none'") {{option.name}}
          td.text-right(v-if="col == 'rank'") {{option.rank}}
          td.text-right(v-if="col == 'score'") {{option.score}}
          td.text-right(v-if="col == 'voter_count'") {{option.voter_count}}
          td.text-right(v-if="col == 'average'") {{option.average}}
          td.text-right(v-if="col == 'voter_percent'") {{option.voter_percent.toFixed(0)}}
          td.text-right(v-if="col == 'score_percent'") {{option.score_percent.toFixed(0)}}%
          td.text-right(v-if="col == 'voters'")
            | {{option.voter_ids}}
            user-avatar.float-left(v-for="voter in votersByOptionId[option.id]" :key="voter.id" :user="voter" :size="24" no-link)
</template>
<style lang="sass">
.poll-common-chart-table
  table
    width: 100%

</style>
