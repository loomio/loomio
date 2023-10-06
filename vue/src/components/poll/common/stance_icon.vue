<script lang="coffee">
export default
  props:
    stance: Object
    poll: Object
    size:
      type: Number
      default: 20

  computed:
    hasOptionIcon: -> @poll.config().has_option_icon
    pollOption: -> @stance.pollOption()

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
        v-icon(v-if="poll.pollType != 'meeting'" small :color="pollOption.color") mdi-check
        v-icon(v-else small) mdi-check
  .poll-common-chart-preview__stance.poll-proposal-chart-preview__stance--undecided(v-else)
    v-icon(:size="size - (size/4)" color="primary") mdi-help
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
