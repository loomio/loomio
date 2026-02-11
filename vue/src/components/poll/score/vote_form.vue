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
      loading: false,
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
    poll() { return this.stance.poll(); }
  }
};
</script>

<template lang='pug'>
form.poll-score-vote-form(@submit.prevent='submit()')
  .poll-score-vote-form__options
    v-list-item.poll-dot-vote-vote-form__option(v-for='choice in stanceChoices', :key='choice.option.id')
      v-list-item-title {{ choice.option.name }}
      v-list-item-subtitle(style="white-space: inherit") {{ choice.option.meaning }}
      v-slider.poll-score-vote-form__score-slider.mt-4(
        :disabled="!poll.isVotable()"
        v-model='choice.score'
        :color="choice.option.color"
        :thumb-color="choice.option.color"
        :height="4"
        :min="poll.minScore"
        :max="poll.maxScore"
        :step="1"
      )
      template(v-slot:append)
        input.vote-form-number-input(
          :style="{'background-color': choice.option.color}"
          type="number"
          :min="poll.minScore"
          :max="poll.maxScore"
          v-model="choice.score")

  validation-errors(:subject='stance', field='stanceChoices')
  poll-common-stance-reason(:stance='stance', :poll='poll')
  v-card-actions.poll-common-form-actions
    v-btn.poll-common-vote-form__submit(
      block
      :disabled="!poll.isVotable()"
      :loading="loading"
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
input.vote-form-number-input[type='number']::-webkit-inner-spin-button,
input.vote-form-number-input[type='number']::-webkit-outer-spin-button {
    -webkit-appearance: none;
    margin: 0;
}
input.vote-form-number-input[type=number] {
    -moz-appearance:textfield;
    appearance:textfield;
}
.vote-form-number-input {
  text-align: center;
  width: 48px;
  height: 48px;
  border-radius: 100%;
  color: #000;
}
</style>
