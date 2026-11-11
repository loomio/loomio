<script lang="js">
import Records  from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Flash   from '@/shared/services/flash';
import { sum, map, without } from 'lodash-es';
import { watchEffect } from 'vue';
import { useI18n } from 'vue-i18n';
import { scoresWithinRange, sliderTicks } from '../common/vote_form_helpers';

export default {
  setup() {
    const { t } = useI18n();
    return { t };
  },
  props: {
    stance: Object
  },

  data() {
    return {
      pollOptions: [],
      stanceChoices: [],
      loading: false
    };
  },

  created() {
    // Rebuild only when the poll's option set changes, so the voter's edits are kept.
    watchEffect(() => {
      if (this.stance.poll().optionsDiffer(this.pollOptions)) {
        this.pollOptions = this.stance.poll().pollOptionsForVoting();
        this.stanceChoices = map(this.pollOptions, option => {
          return {
            option,
            score: this.stance.scoreFor(option)
          };
        });
      }
    });
  },

  methods: {
    submit() {
      this.loading = true;
      this.stance.stanceChoicesAttributes = this.stanceChoices.map(choice => ({
        poll_option_id: choice.option.id,
        score: Number(choice.score)
      }));
      const actionName = !this.stance.castAt ? 'created' : 'updated';
      this.stance.save().then(() => {
        Flash.success(`poll_${this.stance.poll().pollType}_vote_form.stance_${actionName}`);
        EventBus.$emit("closeModal");
      }).catch((err) => {
        Flash.serverError(err, ['stanceChoices']);
      }).finally(() => this.loading = false);
    },

    rulesForChoice(choice) {
      return [v => (v <= this.maxForChoice(choice)) || this.$t('poll_dot_vote_vote_form.too_many_dots')];
    },

    percentageFor(choice) {
      const max = pointsPerVoter;
      if (!(max > 0)) { return; }
      return `${(100 * choice.score) / max}% 100%`;
    },

    backgroundImageFor(option) {
      return `url(/img/poll_backgrounds/${option.color.replace('#','')}.png)`;
    },

    styleData(choice) {
      return {
        'border-color': choice.option.color,
        'background-image': this.backgroundImageFor(choice.option),
        'background-size': this.percentageFor(choice)
      };
    },

    adjust(choice, amount) {
      return choice.score += amount;
    },

    maxForChoice(choice) {
      return this.pointsPerVoter - sum(map(without(this.stanceChoices, choice), 'score'));
    }
  },

  computed: {
    poll() { return this.stance.poll(); },

    dotsRemaining() {
      return this.pointsPerVoter - sum(this.stanceChoices.map(choice => Number(choice.score)));
    },

    pointsPerVoter() {
      return this.stance.poll().pointsPerVoter;
    },

    allocationTicks() {
      return sliderTicks(0, this.pointsPerVoter);
    },

    voteGuidance() {
      if (!scoresWithinRange(this.stanceChoices, 0)) return this.t('poll_common.check_allocation');
      if (this.dotsRemaining < 0) return this.t('poll_common.reduce_allocation_by_points', {count: -this.dotsRemaining});
      return '';
    }
  }
};

</script>

<template lang="pug">
div
  v-form.poll-dot-vote-vote-form(ref="form" @submit.prevent="submit()")
    p.poll-dot-vote-vote-form__dots-remaining.text-medium-emphasis.mb-4 {{ t('poll_dot_vote_vote_form.dots_remaining', {count: dotsRemaining}) }}
    .poll-dot-vote-vote-form__options
      v-list-item.poll-dot-vote-vote-form__option.mb-2.px-0(
        v-for='choice in stanceChoices'
        :key='choice.option.id'
        :title="choice.option.name"
        :subtitle="choice.option.meaning"
      )
        .d-flex.align-center.ga-4.mt-4.mb-6
          v-slider.poll-dot-vote-vote-form__slider.mx-4(
            :disabled="!poll.isVotable()"
            v-model='choice.score'
            color="info"
            :step="1"
            :height="4"
            :min="0"
            :max="pointsPerVoter"
            show-ticks="always"
            :ticks="allocationTicks"
            :tick-size="4"
            thumb-label
            hide-details
          )
          poll-common-score-input.poll-dot-vote-vote-form__score-input.mb-1(
            v-if="pointsPerVoter > 10"
            :label="choice.option.name"
            :maximum="pointsPerVoter"
            v-model="choice.score")
      validation-errors(:subject='stance' field='stanceChoices')
    poll-common-stance-reason(:stance='stance', :poll='poll')
    v-card-actions.poll-common-form-actions
      poll-common-submit-button(
        :stance="stance"
        :guidance="voteGuidance"
        :loading="loading"
      )
</template>

<style lang="css">
.poll-dot-vote-vote-form__option-label {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>
