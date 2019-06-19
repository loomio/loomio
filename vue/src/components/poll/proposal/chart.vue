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

export default
  props:
    stanceCounts: Array
    diameter: Number
  data: ->
    svgEl: null
    shapes: []
    pollColors: AppConfig.pollColors
  computed:
    radius: ->
      @diameter / 2.0
    uniquePositionsCount: ->
      _.compact(@stanceCounts).length
  methods:
    arcPath: (startAngle, endAngle) ->
      rad = Math.PI / 180
      x1 = @radius + (@radius * Math.cos(-startAngle * rad))
      x2 = @radius + (@radius * Math.cos(-endAngle * rad))
      y1 = @radius + (@radius * Math.sin(-startAngle * rad))
      y2 = @radius + (@radius * Math.sin(-endAngle * rad))
      ["M", @radius, @radius, "L", x1, y1, "A", @radius, @radius, 0, +(endAngle - startAngle > 180), 0, x2, y2, "z"].join(' ')
    draw: ->
      _.each @shapes, (shape) -> shape.remove()
      start = 90

      switch @uniquePositionsCount
        when 0
          @shapes.push @svgEl.circle(@diameter).attr
            'stroke-width': 0
            fill: '#aaa'
        when 1
          @shapes.push @svgEl.circle(@diameter).attr
            'stroke-width': 0
            fill: AppConfig.pollColors.proposal[_.findIndex(@stanceCounts, (count) -> count > 0)]
        else
          _.each @stanceCounts, (count, index) =>
            return unless count > 0
            angle = 360/_.sum(@stanceCounts)*count
            @shapes.push @svgEl.path(@arcPath(start, start + angle)).attr
              'stroke-width': 0
              fill: AppConfig.pollColors.proposal[index]
            start += angle
  watch:
    stanceCounts: -> @draw()
  mounted: ->
    @svgEl = svg(@$el).size('100%', '100%')
    @draw()
</script>

<template lang="pug">
.poll-proposal-chart
</template>
