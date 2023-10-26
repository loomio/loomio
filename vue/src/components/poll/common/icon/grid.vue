<script lang="js">
import {sum, map, sortBy, find, compact, uniq, slice, parseInt} from 'lodash';

export default
  ({
    props: {
      poll: Object,
      size: Number
    },

    created() {
      this.watchRecords({
        collections: ['pollOptions'],
        query: store => {
          const max = 10;
          this.results = slice(this.poll.results, 0, max);
          this.voterIds = slice(this.poll.decidedVoterIds(), 0, max);
        }
      });
    },

    computed: {
      cellHeight() { return this.size / this.results.length; },
      cellWidth() { return this.size / this.voterIds.length; },
      cellSize() { if (this.cellHeight > this.cellWidth) { return this.cellWidth; } else { return this.cellHeight; } }
    },

    methods: {
      classForScore(score) {
        switch (score) {
          case 2: return 'poll-meeting-chart__cell--yes';
          case 1: return 'poll-meeting-chart__cell--maybe';
          case 0: return 'poll-meeting-chart__cell--no';
          default:
            return 'poll-meeting-chart__cell--empty';
        }
      }
    }
  });

</script>

<template lang="pug">
div.poll-common-icon-grid.d-flex.align-center.justify-center
  table(v-if="voterIds.length")
    tr(v-for="option in results" :key="option.id")
      td( v-for="id in voterIds" :key="id")
        .poll-meeting-icon__cell(:style="{height: cellSize+'px', width: cellSize +'px'}" :class="classForScore(option.voter_scores[id])")
          | &nbsp;
  table(v-if="voterIds.length == 0")
    tr(v-for="option in results" :key="option.id")
      td(v-for="option in results" :key="option.id")
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
