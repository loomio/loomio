<script lang="js">
export default {
  props: {
    stance: Object,
    poll: Object,
    size: {
      type: Number,
      default: 20
    }
  },

  computed: {
    hasOptionIcon() { return this.poll.config().has_option_icon; },
    pollOption() { return this.stance.pollOption(); }
  }
};

</script>

<template lang="pug">
.poll-common-stance-icon(:style="{width: size+'px', height: size+'px'}" aria-hidden="true")
  template(v-if='stance && stance.castAt && pollOption')
    .poll-common-chart-preview__stance(
      v-if="hasOptionIcon"
      :class="'poll-proposal-chart-preview__stance--'+pollOption.icon"
    )
    .poll-common-chart-preview__stance(v-else)
      common-icon(v-if="poll.pollType != 'meeting'" size="small" :color="pollOption.color" name="mdi-check")
      common-icon(v-else size="small" name="mdi-check")
  .poll-common-chart-preview__stance.poll-proposal-chart-preview__stance--undecided(v-else :title="$t('poll_common.your_vote_is_requested')")
    common-icon(style="margin-top: 2px" :size="size - (size/5)" name="mdi-help" color="primary")
</template>

<style lang="sass">
.poll-common-stance-icon
  position: relative
  border-radius: 100%
  background-color: #fff

.v-theme--dark, .v-theme--darkBlue
  .poll-common-stance-icon
    background-color: #000

@keyframes wobble
  0%, 70%
    transform: rotate(0deg)
  75%
    transform: rotate(-10deg)
  78%
    transform: rotate(10deg)
  81%
    transform: rotate(-6deg)
  84%
    transform: rotate(3deg)
  87%, 100%
    transform: rotate(0deg)

.poll-proposal-chart-preview__stance--undecided
  animation: wobble 2.5s ease-in-out infinite
</style>
