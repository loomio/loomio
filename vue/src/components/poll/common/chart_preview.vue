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
.poll-common-chart-preview(aria-hidden="true")
  bar-chart(v-if="chartType == 'bar'" :poll="poll" :stance-counts='poll.stanceCounts' :my-stance='myStance' :show-my-stance="showMyStance" :size='size')
  progress-chart(v-if="chartType == 'progress'" :poll="poll" :stance-counts='poll.stanceCounts' :goal='poll.votersCount' :my-stance='myStance' :show-my-stance="showMyStance"  :size='size')
  poll-proposal-chart-preview(v-if="chartType == 'pie'" :poll="poll" :stance-data='poll.stanceData' :my-stance='myStance' :show-my-stance="showMyStance" :size='size')
  matrix-chart(v-if="chartType == 'matrix'" :poll="poll" :matrix-counts='poll.matrixCounts' :my-stance='myStance' :show-my-stance="showMyStance"  :size='size')
</template>
