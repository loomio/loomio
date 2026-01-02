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
    template(v-if="!hasOptionIcon")
      .poll-common-chart-preview__stance
        common-icon(v-if="poll.pollType != 'meeting'" size="small" :color="pollOption.color" name="mdi-check")
        common-icon(v-else size="small" name="mdi-check")
  .poll-common-chart-preview__stance.poll-proposal-chart-preview__stance--undecided(v-else)
    common-icon(:size="size - (size/4)" color="primary" name="mdi-help")
</template>

<style lang="sass">
.poll-common-stance-icon
  position: relative
  border-radius: 100%
  background-color: #fff

.v-theme--dark, .v-theme--darkBlue
  .poll-common-stance-icon
    background-color: #000
</style>
