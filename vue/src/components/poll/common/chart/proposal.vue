<script lang="coffee">
import Records from '@/shared/services/records'
import {slice} from 'lodash'
import PollCommonChartTable from '@/components/poll/common/chart/table'

export default
  components: {PollCommonChartTable}
  props:
    poll: Object
    options: Array

</script>

<template lang="pug">
.poll-proposal-chart-panel
  .poll-proposal-chart-panel__chart-container.d-flex.align-center
    poll-common-icon-panel.poll-proposal-chart-panel__chart.mr-4(:poll="poll" :size="128")
    poll-common-chart-table(:poll="poll" :options="options")
</template>

<style lang="sass">
@import '@/css/variables.scss'

.poll-proposal-chart-panel__chart-container
  display: flex

.poll-proposal-chart-panel__label
  border-width: 2px
  padding-left: 4px
  border-left-style: solid

.poll-proposal-chart-panel__legend
  margin-left: 16px
  min-width: 80px

.poll-proposal-chart-panel__legend td
  padding-bottom: 10px

.poll-proposal-chart-panel__label--agree
  border-color: $agree-color

.poll-proposal-chart-panel__label--consent
  border-color: $agree-color

.poll-proposal-chart-panel__label--abstain
  border-color: $abstain-color

.poll-proposal-chart-panel__label--disagree
  border-color: $disagree-color

.poll-proposal-chart-panel__label--block
  border-color: $block-color

.poll-proposal-chart-panel__label--objection
  border-color: $block-color

</style>
