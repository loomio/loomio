<script lang="js">
import BarIcon from '@/components/poll/common/icon/bar.vue';
import PieIcon from '@/components/poll/common/icon/pie.vue';
import GridIcon from '@/components/poll/common/icon/grid.vue';

export default {
    components: {BarIcon, PieIcon, GridIcon},
    props: {
      poll: Object,
      showMyStance: Boolean,
      stanceSize: Number({
        default: 20}),
      size: {
        type: Number,
        default: 40
      }
    },
    data() {
      return {slices: this.poll.pieSlices()};
    },

    watch: {
      'poll.stanceCounts'() { this.slices = this.poll.pieSlices(); }
    },

    computed: {
      myStance() { return this.poll.myStance(); },
      showPosition() { return 'proposal count'.split(' ').includes(this.poll.pollType); }
    }
};
</script>

<template lang="pug">
.poll-common-chart-preview(:style="{width: size+'px', height: size+'px'}" aria-hidden="true")
  bar-icon(v-if="poll.chartType == 'bar'", :poll="poll", :size='size')
  pie-icon(v-if="poll.chartType == 'pie'", :slices="slices", :size='size')
  grid-icon(v-if="poll.chartType == 'grid'", :poll="poll", :size='size')
  .poll-common-chart-preview__stance-container(v-if='showMyStance && (myStance || poll.iCanVote())')
    poll-common-stance-icon(:poll="poll", :stance="myStance", :size="stanceSize")

</template>

<style lang="sass">
.poll-common-chart-preview__stance-container
  position: absolute
  left: -3px
  bottom: -4px
  border-radius: 100%
  box-shadow: 0 2px 1px rgba(0,0,0,.15)

.poll-common-chart-preview__stance
  width: 100%
  height: 100%
  background-repeat: no-repeat
  line-height: 0.9

.poll-common-chart-preview
  position: relative
</style>
