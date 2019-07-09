<style lang="css">
.poll-count-chart-panel__chart-container {
  width: 140px;
  height: 140px;
  position: relative;
}

.poll-count-chart-panel__progress {
  display: flex;
  flex-direction: column;
  height: 100%;
  width: 100%;
}

.poll-count-chart-panel__incomplete {
  flex-grow: 1;
  background-color: #ccc;
}

.poll-count-chart-panel__data {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  top: 0;
  position: absolute;
  height: 100%;
  width: 100%;
}

.poll-count-chart-panel__numerator {
  font-size: 72px;
  line-height: 72px;
}
</style>

<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import Records   from '@/shared/services/records'

export default
  props:
    poll: Object
  data: ->
    colors: AppConfig.pollColors.count
  methods:
    percentComplete: (index) ->
      "#{100 * @poll.stanceCounts[index] / @poll.goal()}%"
</script>

<template lang="pug">
.poll-count-chart-panel
  v-subheader(v-t="'poll_common.results'")
  .poll-count-chart-panel__chart-container
    .poll-count-chart-panel__progress
      .poll-count-chart-panel__incomplete
      .poll-count-chart-panel__no(:style="{'flex-basis': percentComplete(1), 'background-color': colors[1]}")
      .poll-count-chart-panel__yes(:style="{'flex-basis': percentComplete(0), 'background-color': colors[0]}")
    .poll-count-chart-panel__data
      .poll-count-chart-panel__numerator {{poll.stancesCount}}
      .poll-count-chart-panel__denominator(v-t="{ path: 'poll_count_chart_panel.out_of', args: { goal: poll.goal() } }")
</template>
