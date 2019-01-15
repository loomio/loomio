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
  template:
    """
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
    """
