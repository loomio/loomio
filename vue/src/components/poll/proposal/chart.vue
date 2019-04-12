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
    dStanceCounts: @stanceCounts
  computed:
    radius: ->
      this.diameter / 2.0
    uniquePositionsCount: ->
      _.compact(this.stanceCounts).length
  methods:
    arcPath: (startAngle, endAngle) ->
      rad = Math.PI / 180
      x1 = this.radius + (this.radius * Math.cos(-startAngle * rad))
      x2 = this.radius + (this.radius * Math.cos(-endAngle * rad))
      y1 = this.radius + (this.radius * Math.sin(-startAngle * rad))
      y2 = this.radius + (this.radius * Math.sin(-endAngle * rad))
      ["M", this.radius, this.radius, "L", x1, y1, "A", this.radius, this.radius, 0, +(endAngle - startAngle > 180), 0, x2, y2, "z"].join(' ')
    draw: ->
      _.each this.shapes, (shape) -> shape.remove()
      start = 90

      switch this.uniquePositionsCount
        when 0
          this.shapes.push this.svgEl.circle(this.diameter).attr
            'stroke-width': 0
            fill: '#aaa'
        when 1
          this.shapes.push this.svgEl.circle(this.diameter).attr
            'stroke-width': 0
            fill: AppConfig.pollColors.proposal[_.findIndex(this.stanceCounts, (count) -> count > 0)]
        else
          _.each this.stanceCounts, (count, index) =>
            return unless count > 0
            angle = 360/_.sum(this.stanceCounts)*count
            this.shapes.push this.svgEl.path(this.arcPath(start, start + angle)).attr
              'stroke-width': 0
              fill: AppConfig.pollColors.proposal[index]
            start += angle
  watch:
    stanceCounts: -> this.draw()
  mounted: ->
    this.svgEl = svg(this.$el).size('100%', '100%')
    this.draw()
</script>

<template>
<div class="poll-proposal-chart"></div>
</template>
