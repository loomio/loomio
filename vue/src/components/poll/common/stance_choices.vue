<script lang="js">
import AppConfig from '@/shared/services/app_config';

export default {
  props: {
    stance: Object
  },

  computed: {
    poll() { return this.stance.poll(); },
    variableScore() { return this.poll.hasVariableScore(); },
    pollType() { return this.poll.pollType; },
    datesAsOptions() { return this.poll.datesAsOptions(); },
    choices() { return this.stance.sortedChoices(); }
  },

  methods: {
    emitClick() { this.$emit('click'); },

    colorFor(score) {
      switch (score) {
        case 2: return AppConfig.pollColors.proposal[0];
        case 1: return AppConfig.pollColors.proposal[1];
        case 0: return AppConfig.pollColors.proposal[2];
      }
    }
  }
};

</script>

<template lang="pug">
.poll-common-stance-choices.pb-2.pt-2(v-if="poll.pollType != 'question' && !poll.hasOptionIcon()")
  span.caption(v-if='stance.castAt && stance.totalScore() == 0' v-t="'poll_common_votes_panel.none_of_the_above'" )
  template(v-else)
    template(v-if="!datesAsOptions")
      .poll-common-stance-choice.text-truncate(
        v-for="choice in choices"
        v-if="choice.score > 0 || pollType == 'score'"
        :key="choice.id"
        :class="'poll-common-stance-choice--' + pollType")
        common-icon(small :color="choice.pollOption.color" v-if="!variableScore" name="mdi-check-circle")
        span(:style="{color: choice.pollOption.color}" v-if="variableScore") {{choice.rank || choice.score}}
        span.ml-2.text--secondary
          | {{ choice.pollOption.optionName() }}
</template>
<style lang="sass">
.poll-common-stance-choices
  overflow: hidden

</style>

