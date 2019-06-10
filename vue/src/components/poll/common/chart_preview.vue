<script lang="coffee">
import { fieldFromTemplate, myLastStanceFor } from '@/shared/helpers/poll'
import UrlFor                                 from '@/mixins/url_for'

import BarChart from '@/components/poll/common/bar_chart.vue'
import ProcessChart from '@/components/poll/common/progress_chart.vue'
import PollProposalChartPreview from '@/components/poll/proposal/chart_preview.vue'
import MatrixChart from '@/components/poll/meeting/matrix_chart.vue'

export default
  components:
    BarChart: BarChart
  mixins: [UrlFor]
  props:
    poll: Object
    size:
      type: String
      default: 'medium'
  computed:
    width: ->
      switch this.size
        when 'tiny'     then 20
        when 'small'    then 24
        when 'forty'    then 40
        when 'medium'   then 48
        when 'large'    then 64
        when 'featured' then 200
    chartType: -> fieldFromTemplate(this.poll.pollType, 'chart_type')
    myStance: -> myLastStanceFor(this.poll)
</script>

<template lang="pug">
.poll-common-chart-preview
  bar-chart(v-if="chartType == 'bar'", :stance-counts='this.poll.stanceCounts', :size='width')
  progress-chart(v-if="chartType == 'progress'", :stance-counts='this.poll.stanceCounts', :goal='this.poll.goal()', :size='width')
  poll-proposal-chart-preview(v-if="chartType == 'pie'", :stance-counts='this.poll.stanceCounts', :my-stance='this.myStance' :size='width')
  matrix-chart(v-if="chartType == 'matrix'", :matrix-counts='this.poll.matrixCounts', :size='width')
</template>
