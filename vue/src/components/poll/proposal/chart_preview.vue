<style lang="css">
.poll-proposal-chart-preview {
  position: relative;
}

.poll-proposal-chart-preview__stance-container {
  width: 23px;
  height: 23px;
  position: absolute;
  left: -3px;
  bottom: -5px;
  background-color: #fff;
  border-radius: 100%;
  box-shadow: 0 2px 1px rgba(0,0,0,.15);
}

.poll-proposal-chart-preview__stance {
  background-repeat: no-repeat;
  height: 21px;
  width: 21px;
  margin: 1px 0 0 1px;
}

.poll-proposal-chart-preview__stance--agree {
  background-image: url(/img/agree.svg);
}

.poll-proposal-chart-preview__stance--disagree {
  background-image: url(/img/disagree.svg);
}

.poll-proposal-chart-preview__stance--block {
  background-image: url(/img/block.svg);
}

.poll-proposal-chart-preview__stance--abstain {
  background-image: url(/img/abstain.svg);
}

.poll-proposal-chart-preview__stance--undecided {
  color: #ccc;
  font-weight: bold;
  font-size: 16px;
  margin-top: 2px;
  text-align: center;
}

</style>

<script lang="coffee">
export default
  props:
    size: Number
    stanceData: Object
    myStance: Object
    showMyStance: Boolean

</script>

<template lang="pug">
.poll-proposal-chart-preview(:style="{width: size+'px', height: size+'px'}")
  poll-proposal-chart.poll-common-collapsed__pie-chart(:stance-data='stanceData', :diameter='size')
  .poll-proposal-chart-preview__stance-container(v-if='showMyStance')
    div(v-if='myStance', :class='`poll-proposal-chart-preview__stance poll-proposal-chart-preview__stance--${this.myStance.pollOption().name}`')
    .poll-proposal-chart-preview__stance.poll-proposal-chart-preview__stance--undecided(v-if='!myStance') ?
</template>
