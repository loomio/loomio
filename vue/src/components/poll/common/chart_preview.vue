<script lang="coffee">
import { fieldFromTemplate, myLastStanceFor } from '@/shared/helpers/poll'

import BarChart from '@/components/poll/common/bar_chart.vue'
import ProcessChart from '@/components/poll/common/progress_chart.vue'
import PollProposalChartPreview from '@/components/poll/proposal/chart_preview.vue'
import MatrixChart from '@/components/poll/meeting/matrix_chart.vue'

export default
  components:
    BarChart: BarChart
  props:
    poll: Object
    showMyStance:
      type: Boolean
      default: true
    size:
      type: Number
      default: 48
  computed:
    chartType: -> fieldFromTemplate(@poll.pollType, 'chart_type')
    myStance: -> myLastStanceFor(@poll)
</script>

<template lang="pug">
.poll-common-chart-preview
  bar-chart(v-if="chartType == 'bar'", :stance-counts='poll.stanceCounts' :showMyStance="showMyStance"  :size='size')
  progress-chart(v-if="chartType == 'progress'", :stance-counts='poll.stanceCounts', :goal='this.poll.goal()' :showMyStance="showMyStance"  :size='size')
  poll-proposal-chart-preview(v-if="chartType == 'pie'", :stance-data='poll.stanceData', :my-stance='myStance' :showMyStance="showMyStance" :size='size')
  matrix-chart(v-if="chartType == 'matrix'", :matrix-counts='poll.matrixCounts' :showMyStance="showMyStance"  :size='size')
</template>
