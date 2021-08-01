<script lang="coffee">
import svg from 'svg.js'
import AppConfig from '@/shared/services/app_config'
import { take, map, max, each} from 'lodash'

export default
  props:
    size: Number
    poll: Object
  data: ->
    svgEl: null
    shapes: []
  computed:
    stanceCounts: -> @poll.stanceCounts
    scoreData: ->
      take(map(@stanceCounts, (score, index) ->
        { color: AppConfig.pollColors.poll[index], index: index, score: score }), 5)
    scoreMaxValue: ->
      max map(this.scoreData, (data) -> data.score)
  methods:
    draw: ->
      if @scoreData.length > 0 and @scoreMaxValue > 0
        @drawChart()
      else
        @drawPlaceholder()
    drawPlaceholder: ->
      each @shapes, (shape) -> shape.remove()
      barHeight = @size / 3
      barWidths =
        0: @size
        1: 2 * @size / 3
        2: @size / 3
      each barWidths, (width, index) =>
        @svgEl.rect(width, barHeight - 2)
            .fill("#ebebeb")
            .x(0)
            .y(index * barHeight)
    drawChart: ->
      each @shapes, (shape) -> shape.remove()
      barHeight = @size / @scoreData.length
      map @scoreData, (scoreDatum) =>
        barWidth = max([(@size * scoreDatum.score) / @scoreMaxValue, 2])
        @svgEl.rect(barWidth, barHeight-2)
            .fill(scoreDatum.color)
            .x(0)
            .y(scoreDatum.index * barHeight)
  watch:
    stanceCounts: ->
      @draw()
  mounted: ->
    @svgEl = svg(@$refs.svg).size('100%', '100%')
    @draw()
</script>

<template lang="pug">
.bar-chart(ref="svg" :style="{height: size+'px', width: size+'px'}")
</template>

<style lang="sass">
.bar-chart
	border: 0
	margin: 0
	padding: 0
	svg
		height: 100%
		width: 100%

</style>
