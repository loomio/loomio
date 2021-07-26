<script lang="coffee">
export default
  props:
    poll: Object
    size: Number
    stanceData: Object
</script>

<template lang="pug">
poll-proposal-chart.poll-common-collapsed__pie-chart(:stance-data='stanceData' :diameter='size')
</template>
<style lang="sass">
.poll-proposal-chart-preview__stance--agree
  background-image: url(/img/agree.svg)
.poll-proposal-chart-preview__stance--yes
  background-image: url(/img/yes.svg)
.poll-proposal-chart-preview__stance--no
  background-image: url(/img/no.svg)
.poll-proposal-chart-preview__stance--disagree
  background-image: url(/img/disagree.svg)
.poll-proposal-chart-preview__stance--block
  background-image: url(/img/block.svg)
.poll-proposal-chart-preview__stance--abstain
  background-image: url(/img/abstain.svg)

</style>
