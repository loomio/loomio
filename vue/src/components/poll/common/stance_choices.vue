<script lang="js">
export default {
  props: {
    stance: Object
  },

  computed: {
    poll() { return this.stance.poll(); },
    variableScore() { return this.poll.hasVariableScore(); },
    pollType() { return this.poll.pollType; },
    datesAsOptions() { return this.poll.datesAsOptions(); },
    choices() { return this.stance.sortedChoices().filter(choice => choice.score > 0 || this.pollType == 'score'); }
  },

  methods: {
    emitClick() { this.$emit('click'); }
  }
};

</script>

<template lang="pug">
.poll-common-stance-choices.pb-2.pt-2(v-if="!datesAsOptions && poll.pollType != 'question' && !poll.hasOptionIcon()")
  span.text-body-small(v-if='stance.castAt && stance.totalScore() == 0' v-t="'poll_common_form.none_of_the_above'" )
  template(v-else)
    .poll-common-stance-choice.text-truncate.mb-1(
      v-for="choice in choices"
      :key="choice.id"
      :class="'poll-common-stance-choice--' + pollType")
      common-icon(size="small" color="primary" v-if="!variableScore" name="mdi-check-circle")
      span.text-medium-emphasis(v-if="choice.rank")
        span {{choice.rank}}
        mid-dot
        span.text-high-emphasis {{ choice.pollOption.optionName() }}
      span.text-medium-emphasis(v-else)
        span.text-high-emphasis| {{ choice.pollOption.optionName() }}
        mid-dot
        span {{choice.score}}
</template>
<style lang="sass">
.poll-common-stance-choices
  overflow: hidden

</style>
