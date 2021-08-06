<script lang="coffee">

export default
  props:
    stance: Object
    poll: Object
    size:
      type: Number
      default: 20

</script>

<template lang="pug">
.poll-common-stance-icon(:style="{width: size+'px', height: size+'px'}" aria-hidden="true")
  template(v-if='stance && stance.castAt')
    .poll-common-chart-preview__stance(v-if="poll.pollType == 'proposal'" :class='`poll-proposal-chart-preview__stance--${this.stance.pollOption().name}`')
    .poll-common-chart-preview__stance(v-if="poll.pollType == 'count'")
      v-icon(small :color="stance.pollOption().color" v-if="stance.pollOption().name == 'yes'") mdi-check
      v-icon(small :color="stance.pollOption().color" v-if="stance.pollOption().name == 'no'") mdi-close
    .poll-common-chart-preview__stance(v-if="poll.pollType == 'poll'")
      v-icon(small :color="stance.pollOption().color") mdi-check
    .poll-common-chart-preview__stance(v-if="poll.pollType == 'ranked_choice'")
      v-icon(small :color="stance.pollOption().color") mdi-check
    .poll-common-chart-preview__stance(v-if="poll.pollType == 'score'")
      v-icon(small :color="stance.pollOption().color") mdi-check
    .poll-common-chart-preview__stance(v-if="poll.pollType == 'dot_vote'")
      v-icon(small :color="stance.pollOption().color") mdi-check
    .poll-common-chart-preview__stance(v-if="poll.pollType == 'meeting'")
      v-icon(small) mdi-check
  .poll-common-chart-preview__stance.poll-proposal-chart-preview__stance--undecided(v-else)
    v-icon(:size="size" color="primary" small) mdi-help
</template>

<style lang="sass">
.poll-common-stance-icon
  position: relative

.poll-common-stance-icon
  border-radius: 100%

.theme--dark
  .poll-common-stance-icon
    background-color: #000

.theme--light
  .poll-common-stance-icon
    background-color: #fff

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
