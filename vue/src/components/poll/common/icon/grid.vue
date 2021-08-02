<script lang="coffee">
import {sum, map, sortBy, find, compact, uniq, slice, parseInt} from 'lodash'

export default
  props:
    poll: Object
    zone: Object
    size: Number
  data: ->
    pollOptions: []

  created: ->
    @watchRecords
      collections: ['poll_options']
      query: (store) =>
        max = 10
        @pollOptions = slice @poll.pollOptions(), 0, max
        @decidedVoterIds = slice @poll.decidedVoterIds(), 0, max

  computed:
    cellHeight: -> @size / @pollOptions.length
    cellWidth: -> @size / @decidedVoterIds.length
    cellSize: -> if (@cellHeight > @cellWidth) then @cellWidth else @cellHeight

  methods:
    classForScore: (score) ->
      switch score
        when 2 then 'poll-meeting-chart__cell--yes'
        when 1 then 'poll-meeting-chart__cell--maybe'
        when 0 then 'poll-meeting-chart__cell--no'
        else
          'poll-meeting-chart__cell--empty'

</script>

<template lang="pug">
div.poll-common-icon-grid.d-flex.align-center.justify-center
  table(v-if="decidedVoterIds.length")
    tr(v-for="option in pollOptions" :key="option.id")
      td( v-for="id in decidedVoterIds" :key="id")
        .poll-meeting-icon__cell(:style="{height: cellSize+'px', width: cellSize +'px'}" :class="classForScore(option.voterScores[id])")
          | &nbsp;
  table(v-if="decidedVoterIds.length == 0")
    tr(v-for="option in pollOptions" :key="option.id")
      td(v-for="option in pollOptions" :key="option.id")
        .poll-meeting-icon__cell.poll-meeting-chart__cell--empty(:style="{height: cellSize+'px', width: cellSize +'px'}")
          | &nbsp;
</template>

<style lang="sass">
.poll-meeting-chart__cell--empty
  background-color: #ddd
.poll-meeting-icon__cell
  border-radius: 50%
  max-height: 8px
  max-width: 8px
.poll-common-icon-grid
  table, tbody, th, td
    border-collapse: collapse
    border: 0
</style>
