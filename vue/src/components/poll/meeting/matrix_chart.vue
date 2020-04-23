<script lang="coffee">
import svg from 'svg.js'
import { each, isEmpty, max, times } from 'lodash-es'

export default
  props:
    matrixCounts: Array
    size: Number
  data: ->
    svgEl: null
    shapes: []
  mounted: ->
    this.svgEl = svg(this.$el).size(@size, @size)
    this.draw()
  methods:
    draw: ->
      each this.shapes, (shape) -> shape.remove()
      if isEmpty(this.matrixCounts)
        this.drawPlaceholder()
      else
        this.drawChart()
    drawChart: ->
      width = this.size / max([this.matrixCounts.length, this.matrixCounts[0].length])
      each this.matrixCounts, (values, row) =>
        each values, (value, col) =>
          this.drawShape(row, col, width, value)
    drawPlaceholder: ->
      each times(5), (row) =>
        each times(5), (col) =>
          this.drawShape(row, col, this.size / 5, 0)
    drawShape: (row, col, width, value) ->
      color = ['#ebebeb','#f3b300','#00e572'][value]
      this.shapes.push(this.svgEl.circle(width-1)
        .fill(color)
        .x(width * row)
        .y(width * col))
  watch:
    stanceCounts: ->
      this.draw()
</script>

<template>
<div class="matrix-chart"></div>
</template>
