<script lang="coffee">
{ fieldFromTemplate, myLastStanceFor } = require 'shared/helpers/poll'
urlFor                                 = require 'vue/mixins/url_for'

import BarChart from 'vue/components/poll/common/bar_chart.vue'
import ProcessChart from 'vue/components/poll/common/progress_chart.vue'
import PollProposalChartPreview from 'vue/components/poll/proposal/chart_preview.vue'
import MatrixChart from 'vue/components/poll/meeting/matrix_chart.vue'

module.exports =
  components:
    BarChart: BarChart
  mixins: [urlFor]
  props:
    poll: Object
  computed:
    chartType: -> fieldFromTemplate(this.poll.pollType, 'chart_type')
    myStance: -> myLastStanceFor(this.poll)
</script>

<template lang="pug">
.poll-common-chart-preview
  bar-chart(v-if="chartType == 'bar'", :stance-counts='this.poll.stanceCounts', size='50')
  progress-chart(v-if="chartType == 'progress'", :stance-counts='this.poll.stanceCounts', :goal='this.poll.goal()', size='50')
  poll-proposal-chart-preview(v-if="chartType == 'pie'", :stance-counts='this.poll.stanceCounts', :my-stance='this.myStance')
  matrix-chart(v-if="chartType == 'matrix'", :matrix-counts='this.poll.matrixCounts', size='50')
</template>
