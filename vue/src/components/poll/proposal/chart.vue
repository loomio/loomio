<style lang="scss">
.poll-proposal-chart {
  border: 0;
  margin: 0;
  padding: 0;
}

.poll-proposal-chart svg {
   height: 100%;
   width: 100%;
}

</style>

<script lang="coffee">
import svg from 'svg.js'
import AppConfig from '@/shared/services/app_config'
import { sum, values, compact, keys, each } from 'lodash'

export default
  props:
    stanceData: Object
    diameter: Number
  data: ->
    svgEl: null
    shapes: []
    pollColors: AppConfig.pollColors
    positionColors:
      'agree': AppConfig.pollColors.proposal[0]
      'abstain': AppConfig.pollColors.proposal[1]
      'disagree': AppConfig.pollColors.proposal[2]
      'block': AppConfig.pollColors.proposal[3]
  computed:
    radius: ->
      @diameter / 2.0

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

      switch values(@stanceData).filter((v) -> v > 0).length
        when 0
          @shapes.push @svgEl.circle(@diameter).attr
            'stroke-width': 0
            fill: '#aaa'
        when 1
          each @stanceData, (count, position) =>
            return unless count > 0
            @shapes.push @svgEl.circle(@diameter).attr
              'stroke-width': 0
              fill: @positionColors[position]
        else
          each @stanceData, (count, position) =>
            return unless count > 0
            angle = 360/sum(values(@stanceData))*count
            @shapes.push @svgEl.path(@arcPath(start, start + angle)).attr
              'stroke-width': 0
              fill: @positionColors[position]
            start += angle
  watch:
    stanceData: -> @draw()

  mounted: ->
    @svgEl = svg(@$el).size('100%', '100%')
    @draw()
</script>

<template lang="pug">
.poll-proposal-chart
</template>
