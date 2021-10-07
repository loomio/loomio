<script lang="coffee">
import { fieldFromTemplate, myLastStanceFor } from '@/shared/helpers/poll'

import BarIcon from '@/components/poll/common/icon/bar.vue'
import CountIcon from '@/components/poll/common/icon/count.vue'
import PieIcon from '@/components/poll/common/icon/pie.vue'
import GridIcon from '@/components/poll/common/icon/grid.vue'

export default
  components: {BarIcon, CountIcon, PieIcon, GridIcon}
  props:
    poll: Object
    showMyStance: Boolean
    stanceSize: Number
      default: 20
    size:
      type: Number
      default: 40
  computed:
    chartType: -> @poll.chartType()
    myStance: -> myLastStanceFor(@poll)
    showPosition: -> 'proposal count'.split(' ').includes(@poll.pollType)
</script>

<template lang="pug">
.poll-common-chart-preview(:style="{width: size+'px', height: size+'px'}" aria-hidden="true")
  bar-icon(v-if="chartType == 'bar'" :poll="poll" :size='size')
  count-icon(v-if="chartType == 'count'" :poll="poll" :size='size')
  pie-icon(v-if="chartType == 'pie'" :poll="poll" :size='size')
  grid-icon(v-if="chartType == 'grid'" :poll="poll" :size='size')
  .poll-common-chart-preview__stance-container(v-if='showMyStance && myStance || poll.iCanVote()')
    poll-common-stance-icon(:poll="poll" :stance="myStance" :size="stanceSize")

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
