<script lang="coffee">
import svg from 'svg.js'
import AppConfig from '@/shared/services/app_config'
import { sum, values, compact, keys, each } from 'lodash'
import { optionColors, optionImages } from '@/shared/helpers/poll'

export default
  props:
    poll: Object
    size: Number

  data: ->
    svgEl: null
    shapes: []

  computed:
    radius: ->
      @size / 2.0

    results: ->
      @poll.results.filter((r) => r[@poll.chartColumn])

  methods:
    arcPath: (startAngle, endAngle) ->
      rad = Math.PI / 180
      x1 = @radius + (@radius * Math.cos(-startAngle * rad))
      x2 = @radius + (@radius * Math.cos(-endAngle * rad))
      y1 = @radius + (@radius * Math.sin(-startAngle * rad))
      y2 = @radius + (@radius * Math.sin(-endAngle * rad))
      ["M", @radius, @radius, "L", x1, y1, "A", @radius, @radius, 0, +(endAngle - startAngle > 180), 0, x2, y2, "z"].join(' ')

    draw: ->
      @shapes.forEach (shape) -> shape.remove()
      start = 90

      switch @results.length
        when 0
          @shapes.push @svgEl.circle(@size).attr
            'stroke-width': 0
            fill: '#BBBBBB'
        when 1
          each @results, (option) =>
            @shapes.push @svgEl.circle(@size).attr
              'stroke-width': 0
              fill: option.color
        else
          each @results, (option) =>
            angle = 360 * option[@poll.chartColumn] / 100
            @shapes.push @svgEl.path(@arcPath(start, start + angle)).attr
              'stroke-width': 0
              fill: option.color
            start += angle
  watch:
    'poll.stanceCounts': -> @draw()

  mounted: ->
    @svgEl = svg(@$el).size('100%', '100%')
    @draw()

  beforeDestroy: ->
    @svgEl.clear()
    delete @shapes
</script>

<template lang="pug">
.poll-proposal-chart(:style="{width: size+'px', height: size+'px'}")
</template>
<style lang="sass">
.poll-proposal-chart
  border: 0
  margin: 0
  padding: 0
  svg
    height: 100%
    width: 100%

</style>
