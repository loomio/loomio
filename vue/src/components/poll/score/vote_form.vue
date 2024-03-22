<script lang="js">
import Records  from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Flash   from '@/shared/services/flash';
import { map } from 'lodash-es';
import WatchRecords from '@/mixins/watch_records';

export default {
  mixins: [WatchRecords],
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
    v-list-item.poll-dot-vote-vote-form__option(
      :title="choice.option.name"
      :subtitle="choice.option.meaning"
      v-for='choice in stanceChoices'
      :key='choice.option.id')
      template(v-slot:append)
        v-text-field.number-input.ml-2(
          v-model="choice.score"
          type="number"
          density="compact"
          variant="outlined"
        )
      v-slider.poll-score-vote-form__score-slider.mb-6.px-3(
        :disabled="!poll.isVotable()"
        v-model='choice.score'
        :color="choice.option.color"
        :height="4"
        :min="poll.minScore"
        :max="poll.maxScore"
        :step="1"
      )

  validation-errors(:subject='stance', field='stanceChoices')
  poll-common-stance-reason(:stance='stance', :poll='poll')
  v-card-actions.poll-common-form-actions
    v-btn.poll-common-vote-form__submit(
      block
      :disabled="!poll.isVotable()"
      :loading="stance.processing"
      variant="elevated"
      color="primary"
      type='submit'
    )
      span(v-t="'poll_common.submit_vote'")
</template>
<style>
.poll-dot-vote-vote-form__option {
  padding-left: 0;
  padding-right: 0;
}
.v-text-field.number-input input {
  width: 80px;
  text-align: right;
}
</style>
