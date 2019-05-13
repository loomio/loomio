<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import Records   from '@/shared/services/records'
import { max, values, sortBy } from 'lodash'

export default
  props:
    poll: Object
  methods:
    countFor: (option) ->
      (@poll.stanceData or {})[option.name] or 0

    rankFor: (score) ->
      @poll.customFields.minimum_stance_choices - score + 1

    votesFor: (option, score) ->
      option.scoreCounts[score] || 0

    scores: ->
      [@poll.customFields.minimum_stance_choices..1]

    pollOptions: ->
      sortBy @poll.pollOptions(), (option) => -@countFor(option)

    barTextFor: (option) ->
      option.name

    percentageFor: (option) ->
      maxVal = max(values(@poll.stanceData))
      return unless maxVal > 0
      "#{100 * @countFor(option) / maxVal}%"

    backgroundImageFor: (option) ->
      "url(/img/poll_backgrounds/#{option.color.replace('#','')}.png)"

    styleData: (option) ->
      'background-image': @backgroundImageFor(option)
      'background-size': "#{@percentageFor(option)} 100%"
</script>
<template lang="pug">
.poll-common-ranked-choice-chart.lmo-flex(layout='row')
  .lmo-flex.lmo-flex__grow(layout='column')
    .poll-common-ranked-choice-chart__cell
    .poll-common-ranked-choice-chart__cell.poll-common-ranked-choice-chart__cell--name(v-for='option in pollOptions()', :key="option.id", :style='styleData(option)') {{option.name}}
  .poll-common-ranked-choice-chart__table(layout='row')
    .poll-common-ranked-choice-chart__cell.poll-common-ranked-choice-chart__cell-column(layout='column', v-for='score in scores()')
      .poll-common-ranked-choice-chart__cell.lmo-flex__horizontal-center(layout='column')
        strong(v-t="'ordinal._' + rankFor(score)")
        //- md-tooltip
        //-   span(translate='common.points_abbrev', translate-value-score='{{score}}')
      .poll-common-ranked-choice-chart__cell(v-for='option in pollOptions()', :key="option.id") {{votesFor(option, score)}}
    .lmo-flex(layout='column')
      .poll-common-ranked-choice-chart__cell
        strong(v-t="'common.total'")
      .poll-common-ranked-choice-chart__cell(v-for='option in pollOptions()', :key="option.id") {{countFor(option)}}

</template>
<style lang="scss">
@import 'variables.scss';
.poll-common-ranked-choice-chart {
  width: 100%;
  text-align: left;
  position: relative;
}

.poll-common-ranked-choice-chart__cell {
  display: flex;
  align-items: center;
  justify-content: flex-start;
  min-height: 72px;
  padding: 4px;
  &.poll-common-ranked-choice-chart__cell--name {
    justify-content: flex-start;
    background-repeat:no-repeat;
  }
}

.poll-common-ranked-choice-chart__cell-column {
  padding: 0 4px;
}

@media (max-width: $tiny-max-px) {
  .poll-common-ranked-choice-chart__table {
    position: absolute;
    right: 0;
    background: rgba(255,255,255,0.7);
    box-shadow: 0 0 32px 6px white;
  }
}
</style>
