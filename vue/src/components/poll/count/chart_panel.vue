<style lang="scss">
@import 'variables';
.poll-count-chart-panel__chart-container {
  width: 200px;
  height: 200px;
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
  background-color: $background-color;
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
AppConfig = require 'shared/services/app_config'
Records   = require 'shared/services/records'

module.exports =
  props:
    poll: Object
  data: ->
    colors: AppConfig.pollColors.count
  methods:
    percentComplete: (index) ->
      "#{100 * @poll.stanceCounts[index] / @poll.goal()}%"
</script>

<template>
    <div class="poll-count-chart-panel">
      <h3 v-t="'poll_common.results'" class="lmo-card-subheading"></h3>
      <div class="poll-count-chart-panel__chart-container">
        <div class="poll-count-chart-panel__progress">
          <div class="poll-count-chart-panel__incomplete"></div>
          <div :style="{'flex-basis': percentComplete(1), 'background-color': colors[1]}" class="poll-count-chart-panel__no"></div>
          <div :style="{'flex-basis': percentComplete(0), 'background-color': colors[0]}" class="poll-count-chart-panel__yes"></div>
        </div>
        <div class="poll-count-chart-panel__data">
          <div class="poll-count-chart-panel__numerator">{{poll.stancesCount}}</div>
          <div v-t="{ path: 'poll_count_chart_panel.out_of', args: { goal: poll.goal() } }" class="poll-count-chart-panel__denominator"></div>
        </div>
      </div>
    </div>
</template>
