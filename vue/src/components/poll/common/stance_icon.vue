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

<template>

<div class="poll-common-stance-icon" :style="{width: size+'px', height: size+'px'}" aria-hidden="true">
  <template v-if="stance && stance.castAt && pollOption">
    <div class="poll-common-chart-preview__stance" v-if="hasOptionIcon" :class="'poll-proposal-chart-preview__stance--'+pollOption.icon"></div>
    <template v-if="!hasOptionIcon">
      <div class="poll-common-chart-preview__stance">
        <common-icon v-if="poll.pollType != 'meeting'" small="small" :color="pollOption.color" name="mdi-check"></common-icon>
        <common-icon v-else small="small" name="mdi-check"></common-icon>
      </div>
    </template>
  </template>
  <div class="poll-common-chart-preview__stance poll-proposal-chart-preview__stance--undecided" v-else>
    <common-icon :size="size - (size/4)" color="primary" name="mdi-help"></common-icon>
  </div>
</div>
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


</style>
