<script lang="js">
import Records  from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Flash   from '@/shared/services/flash';
import { sum, map, without } from 'lodash-es';

export default {
  props: {
    stance: Object
  },

  data() {
    return {
      pollOptions: [],
      stanceChoices: []
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
      }).catch(() => true);
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
      return this.dotsPerPerson - sum(map(this.stanceChoices, 'score'));
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
    v-banner.poll-dot-vote-vote-form__dots-remaining(sticky rounded dense :color="alertColor" )
      span(v-t="{ path: 'poll_dot_vote_vote_form.dots_remaining', args: { count: dotsRemaining } }")
    .poll-dot-vote-vote-form__options
      v-list-item.poll-dot-vote-vote-form__option(v-for='choice in stanceChoices', :key='choice.option.id')
        v-list-item-content
          v-list-item-title {{ choice.option.name }}
          v-list-item-subtitle(style="white-space: inherit") {{ choice.option.meaning }}
          v-slider.poll-dot-vote-vote-form__slider.mt-4(
            :disabled="!poll.isVotable()"
            v-model='choice.score'
            :color="choice.option.color"
            track-color="grey"
            :height="4"
            :min="0"
            :max="dotsPerPerson"
            :readonly="false")
        v-list-item-action(style="max-width: 128px")
          v-text-field(
            type="number"
            max-width="20px"
            filled
            rounded
            dense
            v-model="choice.score"
          )
      validation-errors(:subject='stance' field='stanceChoices')
    poll-common-stance-reason(:stance='stance', :poll='poll')
    v-card-actions.poll-common-form-actions
      v-btn.poll-common-vote-form__submit(
        block
        @click="submit()"
        :disabled="(dotsRemaining < 0) || !poll.isVotable()"
        :loading="stance.processing"
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
