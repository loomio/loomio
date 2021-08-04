<script lang="coffee">
import Records from '@/shared/services/records'
import {slice} from 'lodash'
import PollCommonChartBar from '@/components/poll/common/chart/bar'

export default
  components: {PollCommonChartBar}
  props:
    poll: Object

  data: ->
    options: []
    optionVoters: {}

  created: ->
    @watchRecords
      collections: ['pollOptions', 'users']
      query: (records) =>
        @options = @poll.pollOptions()
        @optionVoters = {}
        @options.forEach (o) =>
          @optionVoters[o.id] = Records.users.find(slice(o.voterIds(), 0, 100))

</script>

<template lang="pug">
.poll-proposal-chart-panel
  .poll-proposal-chart-panel__chart-container
    poll-common-icon-panel.poll-proposal-chart-panel__chart.ma-2(:poll="poll" :size="110")
    poll-common-chart-bar(:poll="poll")
    //- table.poll-proposal-chart-panel__legend(role="presentation")
    //-   tbody
    //-     tr(v-for="option in options" :key="option.id")
    //-       td
    //-         .poll-proposal-chart-panel__label(:class="'poll-proposal-chart-panel__label--' + option.name")
    //-           | {{ option.totalScore }}
    //-           | {{ option.optionName() }}
    //-       td
    //-         user-avatar(:user="voter" v-for="voter in optionVoters[option.id]" :size="24")
    //-       td.text-right
    //-         |{{ option.scorePercent() }}%
</template>

<style lang="sass">
@import '@/css/variables.scss'

.poll-proposal-chart-panel__chart-container
  display: flex

.poll-proposal-chart-panel__label
  border-width: 2px
  padding-left: 4px
  border-left-style: solid

.poll-proposal-chart-panel__legend
  margin-left: 16px
  min-width: 80px

.poll-proposal-chart-panel__legend td
  padding-bottom: 10px

.poll-proposal-chart-panel__label--agree
  border-color: $agree-color

.poll-proposal-chart-panel__label--consent
  border-color: $agree-color

.poll-proposal-chart-panel__label--abstain
  border-color: $abstain-color

.poll-proposal-chart-panel__label--disagree
  border-color: $disagree-color

.poll-proposal-chart-panel__label--block
  border-color: $block-color

.poll-proposal-chart-panel__label--objection
  border-color: $block-color

</style>
