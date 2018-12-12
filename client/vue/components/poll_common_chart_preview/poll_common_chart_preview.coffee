{ fieldFromTemplate, myLastStanceFor } = require 'shared/helpers/poll'
LmoUrlService = require 'shared/services/lmo_url_service'

module.exports = Vue.component 'PollCommonChartPreview',
  props:
    poll: Object
  methods:
    urlFor: (model) -> LmoUrlService.route(model: model)
  computed:
    chartType: -> fieldFromTemplate(this.poll.pollType, 'chart_type')
    myStance: -> myLastStanceFor(this.poll)
  template: """
<div class="poll-common-chart-preview">
  <bar-chart
    v-if="chartType == 'bar'"
    :stance-counts="this.poll.stanceCounts"
    size="50"
  ></bar-chart>
  <progress-chart
    v-if="chartType == 'progress'"
    :stance-counts="this.poll.stanceCounts"
    :goal="this.poll.goal()"
    size="50"
  ></progress-chart>
  <poll-proposal-chart-preview
    v-if="chartType == 'pie'"
    :stance-counts="this.poll.stanceCounts"
    :my-stance="this.myStance"
  ></poll-proposal-chart-preview>
  <!--  <matrix_chart ng-if="chartType() == \'matrix\'" matrix_counts="poll.matrixCounts" size="50"></matrix_chart> -->
</div>
"""
