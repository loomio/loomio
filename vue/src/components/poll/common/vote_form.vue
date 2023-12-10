<script lang="js">
import EventBus from '@/shared/services/event_bus';
import Flash   from '@/shared/services/flash';
import Records   from '@/shared/services/records';
import { compact } from 'lodash-es';

export default {
  props: {
    stance: Object
  },

  data() {
    return {
      selectedOptionIds: compact((this.stance.pollOptionIds().length && this.stance.pollOptionIds()) || [parseInt(this.$route.query.poll_option_id)]),
      selectedOptionId: this.stance.pollOptionIds()[0] || parseInt(this.$route.query.poll_option_id),
      options: []
    };
  },

  created() {
    this.watchRecords({
      collections: ['pollOptions'],
      query: records => {
        if (this.poll.optionsDiffer(this.options)) {
          if (this.poll) { this.options = this.poll.pollOptionsForVoting(); }
        }
      }
    });
  },

  computed: {
    singleChoice() { return this.poll.singleChoice(); },
    hasOptionIcon() { return this.poll.config().has_option_icon; },
    poll() { return this.stance.poll(); },
    optionSelected() { return this.selectedOptionIds.length || this.selectedOptionId; },
    optionPrompt() { return (this.selectedOptionId && Records.pollOptions.find(this.selectedOptionId).prompt) || ''; },
    submitText() {
      if (this.stance.castAt) {
        if (this.poll.config().has_options) {
          return 'poll_common.update_vote';
        } else {
          return 'poll_common.update_response';
        }
      } else {
        if (this.poll.config().has_options) {
          return 'poll_common.submit_vote';
        } else {
          return 'poll_common.submit_response';
        }
      }
    },
    optionCountAlertColor() {
      if (!this.singleChoice && this.selectedOptionIds.length && ((this.selectedOptionIds.length < this.poll.minimumStanceChoices) || (this.selectedOptionIds.length > this.poll.maximumStanceChoices))) { return 'warning'; }
    },
    optionCountValid() {
      return (this.singleChoice && this.selectedOptionId) || ((this.selectedOptionIds.length >= this.poll.minimumStanceChoices) && (this.selectedOptionIds.length <= this.poll.maximumStanceChoices));
    }
  },

  watch: {
    selectedOptionId() { 
      // if reason is not disabled, focus on the reson for this poll
      EventBus.$emit('focusEditor', 'poll-'+this.poll.id);
    }
  },

  methods: {
    submit() {
      if (this.singleChoice) {
        this.stance.stanceChoicesAttributes = [{poll_option_id: this.selectedOptionId}];
      } else {
        this.stance.stanceChoicesAttributes = this.selectedOptionIds.map(id => {
          return {poll_option_id: id};
        });
      }
      const actionName = !this.stance.castAt ? 'created' : 'updated';
      this.stance.save().then(() => {
        Flash.success(`poll_${this.stance.poll().pollType}_vote_form.stance_${actionName}`);
        EventBus.$emit('closeModal');
      }).catch(() => true);
    },

    isSelected(option) {
      if (this.singleChoice) { 
        return this.selectedOptionId === option.id;
      } else {
        return this.selectedOptionIds.includes(option.id);
      }
    },

    classes(option) {
      let votingStatus;
      if (this.poll.isVotable()) {
        votingStatus = 'voting-enabled';
      } else {
        votingStatus = 'voting-disabled';
      }

      if (this.optionSelected) {
        if (this.isSelected(option)) {
          return ['elevation-2', votingStatus];
        } else {
          return ['poll-common-vote-form__button--not-selected', votingStatus];
        }
      } else {
        return [votingStatus];
      }
    }
  }
};


</script>

<template lang="pug">
form.poll-common-vote-form(@keyup.ctrl.enter="submit()", @keydown.meta.enter.stop.capture="submit()")
  submit-overlay(:value="stance.processing")

  v-alert(v-if="poll.config().has_options && !poll.singleChoice()", :color="optionCountAlertColor")
    span(
      v-if="poll.minimumStanceChoices == poll.maximumStanceChoices"
      v-t="{path: 'poll_common.select_count_options', args: {count: poll.minimumStanceChoices}}")
    span(
      v-else 
      v-t="{path: 'poll_common.select_minimum_to_maximum_options', args: {minimum: poll.minimumStanceChoices, maximum: poll.maximumStanceChoices}}")
  v-sheet.poll-common-vote-form__button.mb-2.rounded(
    outlined
    :style="(isSelected(option) && {'border-color': option.color}) || {}"
    v-for='option in options'
    :key='option.id'
    :class="classes(option)"
  )
    label
      input(
        v-if="singleChoice"
        v-model="selectedOptionId"
        :value="option.id"
        :aria-label="option.optionName()"
        type="radio"
        name="name"
      )
      input(
        v-if="!singleChoice"
        v-model="selectedOptionIds"
        :value="option.id"
        :aria-label="option.optionName()"
        type="checkbox"
        name="name"
      )
      v-list-item
        v-list-item-icon
          template(v-if="hasOptionIcon")
            v-avatar(size="48")
              img( aria-hidden="true", :src="'/img/' + option.icon + '.svg'")
          template(v-else)
            common-icon(name="mdi-radiobox-blank" v-if="singleChoice && !isSelected(option)" :color="option.color")
            common-icon(name="mdi-radiobox-marked" v-if="singleChoice && isSelected(option)" :color="option.color")
            common-icon(name="mdi-checkbox-blank-outline" v-if="!singleChoice && !isSelected(option)" :color="option.color")
            common-icon(name="mdi-checkbox-marked" v-if="!singleChoice && isSelected(option)" :color="option.color")
        v-list-item-content
          v-list-item-title.poll-common-vote-form__button-text {{option.optionName()}}
          v-list-item-subtitle.poll-common-vote-form__allow-wrap {{option.meaning}}

  poll-common-stance-reason(
    :stance='stance'
    :poll='poll'
    :selectedOptionId="selectedOptionId"
    :prompt="optionPrompt")
  v-card-actions.poll-common-form-actions
    v-btn.poll-common-vote-form__submit(
      @click='submit()'
      :disabled='!optionCountValid || !poll.isVotable()'
      :loading="stance.processing"
      color="primary"
      block
    )
      span(v-t="submitText")
</template>

<style lang="sass">
.poll-common-vote-form__allow-wrap
  white-space: normal

.poll-common-vote-form__button--not-selected
  opacity: 0.33 !important

.poll-common-vote-form__button.voting-enabled label
  cursor: pointer

.poll-common-vote-form__button label
  input
    position: absolute
    opacity: 0
    width: 0
    height: 0

.poll-common-vote-form__button.voting-enabled
  &:hover
    border: 1px solid var(--v-primary-base)

</style>
