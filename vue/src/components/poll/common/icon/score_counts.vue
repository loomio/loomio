<script lang="coffee">
import {range, max, compact} from 'lodash'

export default
  props:
    poll: Object
    size: Number

  data: ->
    scoreStrings: range(@poll.minScore, @poll.maxScore+1, 1).map (s) -> s.toString()
    maxCount: max(@poll.results.map((o) -> max(Object.values(o.score_counts))))

  methods:
    pct: (option, score) -> 
      num = parseFloat(option.score_counts[score.toString()] || 0) / parseFloat(@maxCount)
      Math.round(num * 100) / 100

  computed:
    cellHeight: -> @size / @poll.results.length
    cellWidth: -> @size / @scoreStrings.length
  	
</script>

<template lang="pug">
div.poll-common-icon-grid.d-flex.align-center.justify-center
  table
    tbody
      tr(:key="option.id" v-for="option in poll.results")
        td(
        	v-for="score in scoreStrings"
        	:key="score"
        	:style="{'backgroundColor': 'rgba(0,90,250,'+pct(option, score)+')'}"
      	)
          .poll-meeting-icon__cell(:style="{height: cellHeight+'px', width: cellWidth +'px'}")
            | &nbsp;
</template>

<style lang="sass">
table.poll-common-chart-score-counts
  max-width: 100%
  max-height: 100%
</style>
