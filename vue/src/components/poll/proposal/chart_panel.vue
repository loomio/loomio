<style lang="scss">
@import 'variables';
@import 'mixins';
.poll-proposal-chart-panel__chart-container {
  display: flex;
}

.poll-proposal-chart-panel__chart {
  height: 200px;
  width: 200px;
  flex-shrink: 0;
}

.poll-proposal-chart-panel__label{
  border-width: 2px;
  border-bottom-style: solid;
  @include fontSmall;
}

.poll-proposal-chart-panel__legend {
  margin-left: 16px;
  min-width: 80px;
}

.poll-proposal-chart-panel__legend td {
  padding-bottom: 10px;
}

.poll-proposal-chart-panel__label--agree {
  border-color: $agree-color;
}

.poll-proposal-chart-panel__label--abstain{
  border-color: $abstain-color;
}

.poll-proposal-chart-panel__label--disagree {
  border-color: $disagree-color;
}

.poll-proposal-chart-panel__label--block{
  border-color: $block-color;
}

</style>
<script lang="coffee">
import Records from '@/shared/services/records'

export default
  props:
    poll: Object
  data: ->
    pollOptionNames: ['agree', 'abstain', 'disagree', 'block']
  methods:
    countFor: (name) ->
      @poll.stanceData[name] or 0

    percentFor: (name) ->
      parseInt(parseFloat(@countFor(name)) / parseFloat(@poll.stancesCount) * 100) || 0

    translationFor: (name) ->
      I18n.t("poll_proposal_options.#{name}")

</script>
<template lang="pug">
.poll-proposal-chart-panel
  h3.lmo-card-subheading(v-t="'poll_common.results'")
  .poll-proposal-chart-panel__chart-container
    poll-proposal-chart.poll-proposal-chart-panel__chart(:stance_counts="poll.stanceCounts", :diameter="200")
    table.poll-proposal-chart-panel__legend(role="presentation")
      tbody
        tr(v-for="(name, index) in pollOptionNames" :key="index")
          td
            .poll-proposal-chart-panel__label(:class="'poll-proposal-chart-panel__label--' + name")
              | {{ countFor(name) }} ({{ percentFor(name) }}%) {{ translationFor(name) }}
</template>
