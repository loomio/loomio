<script lang="coffee">
import svg from 'svg.js'
import AppConfig from '@/shared/services/app_config'
import { each, max, sum } from 'lodash-es'

export default
  props:
    stanceCounts: Array
    goal: Number
    size: Number
  data: ->
    svgEl: null
  methods:
    draw: ->
      y = 0
      each @stanceCounts, (count, index) =>
        height = (@size * max([parseInt(count), 0])) / @goal
        @svgEl.rect(@size, height)
            .fill(AppConfig.pollColors.count[index])
            .x(0)
            .y(@size - height - y)
        y += height

      @svgEl.circle(@size / 2)
          .fill("#fff")
          .x(@size / 4)
          .y(@size / 4)
      @svgEl.text((sum(@stanceCounts) || 0).toString())
          .font(size: @fontSize, anchor: 'middle')
          .x(@size / 2)
          .y((@size / 4) + 3)
  watch:
    stanceCounts: -> @draw()

  computed:
    fontSize: -> @size * 0.33

  mounted: ->
    @svgEl = svg(@$el).size('100%', '100%')
    @draw()

</script>

<template lang="pug">
div(:style="{width: size+'px', height: size+'px'}" class="progress-chart")
</template>
<style lang="sass">
.progress-chart
	background-color: #ccc

</style>
