<script lang="js">
import Records  from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Flash   from '@/shared/services/flash';
import { sum, map, without } from 'lodash-es';
import WatchRecords from '@/mixins/watch_records';

export default {
  mixins: [WatchRecords],
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
    this.watchRecords({
      collections: ['pollOptions'],
      query: records => {
        if (this.stance.poll().optionsDiffer(this.pollOptions)) {
          this.pollOptions = this.stance.poll().pollOptionsForVoting();
          this.stanceChoices = map(this.pollOptions, option => {
            return {
              option,
              score: this.stance.scoreFor(option)
            };
          });
        }
      }
    });
  },

  methods: {
    submit() {
      this.loading = true;
      if (sum(map(this.stanceChoices, 'score')) > 0) {
        this.stance.stanceChoicesAttributes = map(this.stanceChoices, choice => {
          return {
            poll_option_id: choice.option.id,
            score: choice.score
          };
        });
      }
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
      const max = dotsPerPerson;
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
      return this.dotsPerPerson - sum(map(without(this.stanceChoices, choice), 'score'));
    }
  },

  computed: {
    poll() { return this.stance.poll(); },

    dotsRemaining() {
      return this.dotsPerPerson - sum(map(this.stanceChoices, (c) => parseInt(c.score) || 0));
    },

    dotsPerPerson() {
      return this.stance.poll().dotsPerPerson;
    },

    alertColor() {
      if (this.dotsRemaining === 0) { return 'success'; }
      if (this.dotsRemaining > 0) { return 'primary'; }
      if (this.dotsRemaining < 0) { return 'error'; }
    }
  }
};

</script>

<template lang="pug">
div
  v-form.poll-dot-vote-vote-form(ref="form")
    v-alert.poll-dot-vote-vote-form__dots-remaining.mb-4(density="compact" variant="tonal" :color="alertColor" )
      span(v-t="{ path: 'poll_dot_vote_vote_form.dots_remaining', args: { count: dotsRemaining } }")
    .poll-dot-vote-vote-form__options
      v-list-item.poll-dot-vote-vote-form__option(
        v-for='choice in stanceChoices'
        :key='choice.option.id'
        :title="choice.option.name"
        :subtitle="choice.option.meaning"
      )
        template(v-slot:append)
          input.vote-form-number-input(
            :style="{'background-color': choice.option.color}"
            type="text"
            inputmode="numeric"
            v-model="choice.score")
        v-slider.poll-dot-vote-vote-form__slider.mb-6.px-3(
          :disabled="!poll.isVotable()"
          v-model='choice.score'
          :color="choice.option.color"
          :step="1"
          track-color="grey"
          :height="4"
          :min="0"
          :max="dotsPerPerson"
          :readonly="false")
      validation-errors(:subject='stance' field='stanceChoices')
    poll-common-stance-reason(:stance='stance', :poll='poll')
    v-card-actions.poll-common-form-actions
      v-btn.poll-common-vote-form__submit(
        block
        variant="elevated"
        @click="submit()"
        :disabled="(dotsRemaining < 0) || !poll.isVotable()"
        :loading="loading"
        color="primary"
      )
        span(v-t="stance.castAt? 'poll_common.update_vote' : 'poll_common.submit_vote'")
</template>

<style lang="css">
.poll-dot-vote-vote-form__option-label {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>
