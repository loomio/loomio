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
      default: 40
  computed:
    chartType: -> fieldFromTemplate(@poll.pollType, 'chart_type')
    myStance: -> myLastStanceFor(@poll)
    showPosition: -> 'proposal count'.split(' ').includes(@poll.pollType)
</script>

<template lang="pug">
.poll-common-chart-preview(:style="{width: size+'px', height: size+'px'}" aria-hidden="true")
  bar-chart(v-if="chartType == 'bar'" :poll="poll" :stance-counts='poll.stanceCounts' :size='size')
  progress-chart(v-if="chartType == 'progress'" :poll="poll" :stance-counts='poll.stanceCounts' :goal='poll.votersCount' :size='size')
  poll-proposal-chart-preview(v-if="chartType == 'pie'" :poll="poll" :stance-data='poll.stanceData' :size='size')
  matrix-chart(v-if="chartType == 'matrix'" :poll="poll" :matrix-counts='poll.matrixCounts' :size='size')
  .poll-common-chart-preview__stance-container(v-if='showMyStance && poll.iCanVote()')
    poll-common-stance-icon(:poll="poll" :stance="myStance")

</template>

<style lang="sass">
.poll-common-chart-preview__stance-container
  width: 20px
  height: 20px
  position: absolute
  left: -4px
  bottom: -4px
  border-radius: 100%
  box-shadow: 0 2px 1px rgba(0,0,0,.15)

.poll-common-chart-preview__stance
  width: 100%
  height: 100%
  background-repeat: no-repeat

.poll-common-chart-preview
  position: relative
</style>
