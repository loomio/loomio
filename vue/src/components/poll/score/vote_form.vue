<script lang="js">
import Records  from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Flash   from '@/shared/services/flash';
import { map } from 'lodash-es';
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
      loading: false,
      pollOptions: [],
      stanceChoices: []
    };
  },

  created() {
    // Rebuild only when the poll's option set changes, so the voter's edits are kept.
    watchEffect(() => {
      if (this.stance.poll().optionsDiffer(this.pollOptions)) {
        this.pollOptions = this.poll.pollOptionsForVoting();
        this.stanceChoices = map(this.pollOptions, option => {
          return {
            score: this.stance.scoreFor(option),
            option
          };
        });
      }
    });
  },
  methods: {
    submit() {
      this.loading = true
      this.stance.stanceChoicesAttributes = map(this.stanceChoices, choice => {
        return {
          poll_option_id: choice.option.id,
          score: choice.score
        };
      });
      const actionName = !this.stance.castAt ? 'created' : 'updated';
      this.stance.save().then(() => {
        Flash.success(`poll_${this.stance.poll().pollType}_vote_form.stance_${actionName}`);
        EventBus.$emit("closeModal");
      }).catch((err) => {
        Flash.serverError(err, ['stanceChoices']);
      }).finally(() => this.loading = false);
    }
  },

  computed: {
    poll() { return this.stance.poll(); },
    scoreTicks() {
      return sliderTicks(this.poll.scoreMin, this.poll.scoreMax);
    },
    voteGuidance() {
      return scoresWithinRange(this.stanceChoices, this.poll.scoreMin, this.poll.scoreMax) ? '' : this.t('poll_common.check_scores');
    }
  }
};
</script>

<template lang='pug'>
form.poll-score-vote-form(@submit.prevent='submit()')
  .poll-score-vote-form__options
    v-list-item.poll-score-vote-form__option.mb-2.px-0(v-for='choice in stanceChoices', :key='choice.option.id')
      v-list-item-title {{ choice.option.name }}
      v-list-item-subtitle(style="white-space: inherit") {{ choice.option.meaning }}
      .d-flex.align-center.ga-4.mt-4.mb-6
        v-slider.poll-score-vote-form__score-slider.mx-4(
          :disabled="!poll.isVotable()"
          v-model='choice.score'
          color="info"
          :height="4"
          :min="poll.scoreMin"
          :max="poll.scoreMax"
          :step="1"
          show-ticks="always"
          :ticks="scoreTicks"
          :tick-size="4"
          thumb-label
          hide-details
        )
        poll-common-score-input.poll-score-vote-form__score-input.mb-1(
          v-if="poll.scoreMax > 10"
          :label="choice.option.name"
          :minimum="poll.scoreMin"
          :maximum="poll.scoreMax"
          v-model="choice.score")

  validation-errors(:subject='stance', field='stanceChoices')
  poll-common-stance-reason(:stance='stance', :poll='poll')
  v-card-actions.poll-common-form-actions
    poll-common-submit-button(
      :stance="stance"
      :guidance="voteGuidance"
      :loading="loading"
    )
</template>
