<style>
</style>

<script lang="coffee">
{ fieldFromTemplate, myLastStanceFor } = require 'shared/helpers/poll'
urlFor                                 = require 'vue/mixins/url_for'

module.exports =
  mixins: [urlFor]
  props:
    poll: Object
  computed:
    chartType: -> fieldFromTemplate(this.poll.pollType, 'chart_type')
    myStance: -> myLastStanceFor(this.poll)
</script>

<template>
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
  <matrix-chart
    v-if="chartType == 'matrix'"
    :matrix-counts="this.poll.matrixCounts"
    size="50"
  ></matrix-chart>
</div>
</template>
