<script lang="js">
import Records  from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Flash   from '@/shared/services/flash';
import { map } from 'lodash-es';

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
          this.pollOptions = this.poll.pollOptionsForVoting();
          this.stanceChoices = map(this.pollOptions, option => {
            return {
              score: this.stance.scoreFor(option),
              option
            };
          });
        }
      }
    });
  },
  methods: {
    submit() {
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
      }).catch(() => true);
    }
  },

  computed: {
    poll() { return this.stance.poll(); }
  }
};
</script>

<template lang='pug'>
form.poll-score-vote-form(@submit.prevent='submit()')
  .poll-score-vote-form__options
    v-list-item.poll-dot-vote-vote-form__option(v-for='choice in stanceChoices', :key='choice.option.id')
      v-list-item-content
        v-list-item-title {{ choice.option.name }}
        v-list-item-subtitle(style="white-space: inherit") {{ choice.option.meaning }}
        v-slider.poll-score-vote-form__score-slider.mt-4(
          :disabled="!poll.isVotable()"
          v-model='choice.score'
          :color="choice.option.color"
          :height="4"
          :min="poll.minScore"
          :max="poll.maxScore"
        )
      v-list-item-action(style="max-width: 128px")
        v-text-field.text-right(
          type="number"
          max-width="20px"
          filled
          rounded
          dense
          v-model="choice.score"
        )

  validation-errors(:subject='stance', field='stanceChoices')
  poll-common-stance-reason(:stance='stance', :poll='poll')
  v-card-actions.poll-common-form-actions
    v-btn.poll-common-vote-form__submit(
      block
      :disabled="!poll.isVotable()"
      :loading="stance.processing"
      color="primary"
      type='submit'
    )
      span(v-t="'poll_common.submit_vote'")
</template>
