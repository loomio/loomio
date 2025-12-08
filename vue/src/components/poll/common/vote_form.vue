<script lang="js">
import EventBus from '@/shared/services/event_bus';
import Flash   from '@/shared/services/flash';
import { I18n } from '@/i18n';
import { compact } from 'lodash-es';
import WatchRecords from '@/mixins/watch_records';

export default {
  mixins: [WatchRecords],
  props: {
    stance: Object
  },

  data() {
    const queryId = [parseInt(this.$route.query.poll_option_id)].filter(id => this.stance.poll().pollOptionIds.includes(id))[0]
    return {
      selectedOptionIds: compact((this.stance.pollOptionIds().length && this.stance.pollOptionIds()) || [queryId]),
      selectedOptionId: this.stance.pollOptionIds()[0] || queryId,
      loading: false,
      options: []
    };
  },

  created() {
    this.watchRecords({
      collections: ['pollOptions'],
      query: () => {
        if (this.poll.optionsDiffer(this.options)) {
          this.options = this.poll.pollOptionsForVoting();
        }
      }
    });
  },

  computed: {
    singleChoice() { return this.poll.singleChoice(); },
    hasOptionIcon() { return this.poll.config().has_option_icon; },
    poll() { return this.stance.poll(); },
    optionSelected() { return this.selectedOptionIds.length || this.selectedOptionId; },
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
      return this.stance.noneOfTheAbove ||
             (this.singleChoice && this.selectedOptionId) ||
             ((this.selectedOptionIds.length >= this.poll.minimumStanceChoices) && (this.selectedOptionIds.length <= this.poll.maximumStanceChoices));
    }
  },

  watch: {
    'stance.noneOfTheAbove'(val) {
      if (val) {
        this.selectedOptionIds = []
        this.selectedOptionId = null
      }
    },
    selectedOptionId() {
      // if reason is not disabled, focus on the reson for this poll
      EventBus.$emit('focusEditor', 'poll-'+this.poll.id);
    }
  },

  methods: {
    submit() {
      this.loading = true;
      if (!this.stance.noneOfTheAbove && this.singleChoice) {
        this.stance.stanceChoicesAttributes = [{poll_option_id: this.selectedOptionId}];
      } else {
        this.stance.stanceChoicesAttributes = this.selectedOptionIds.
                                                   filter(id => this.stance.poll().pollOptionIds.includes(id) ).
                                                   map(id => { return {poll_option_id: id}; });
      }
      const actionName = !this.stance.castAt ? 'created' : 'updated';
      this.stance.save().then(() => {
        Flash.success(`poll_${this.stance.poll().pollType}_vote_form.stance_${actionName}`);
        EventBus.$emit('closeModal');
      }).catch((err) => {
        if (err.error) {
          Flash.custom(err.error);
        } else if (err.errors) {
          Flash.custom(Object.values(err.errors).join(", "));
        } else {
          Flash.error('poll_common_form.please_review_the_form');
        }
      }).finally(() => this.loading = false);
    },

    discardDraft() {
      if (confirm(I18n.global.t('formatting.confirm_discard'))) {
        EventBus.$emit('resetDraft', 'stance', this.stance.id, 'pollOptionIds', this.stance.pollOptionIds());
      }
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
      if (this.poll.isVotable() && !this.stance.noneOfTheAbove) {
        votingStatus = 'voting-enabled';
      } else {
        votingStatus = 'voting-disabled';
      }

      if (this.optionSelected && this.isSelected(option)) {
          return ['elevation-2', votingStatus];
      } else {
        return ['poll-common-vote-form__button--none-selected', votingStatus];
      }
    }
  }
};


</script>

<template lang="pug">
form.poll-common-vote-form(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()")
  v-alert(v-if="poll.config().has_options && !poll.singleChoice()" :color="optionCountAlertColor")
    span(
      v-if="poll.minimumStanceChoices == poll.maximumStanceChoices"
      v-t="{path: 'poll_common.select_count_options', args: {count: poll.minimumStanceChoices}}")
    span(
      v-else
      v-t="{path: 'poll_common.select_minimum_to_maximum_options', args: {minimum: poll.minimumStanceChoices, maximum: poll.maximumStanceChoices}}")

  v-card.poll-common-vote-form__button.mb-2.rounded(
    variant="tonal"
    :color="(isSelected(option) && option.color) || null"
    v-for='option in options'
    :key='option.id'
    :class="classes(option)"
  )
    label.text-on-surface
      input(
        v-if="singleChoice"
        v-model="selectedOptionId"
        :value="option.id"
        :aria-label="option.optionName()"
        type="radio"
        :disabled="stance.noneOfTheAbove"
      )
      input(
        v-if="!singleChoice"
        v-model="selectedOptionIds"
        :value="option.id"
        :aria-label="option.optionName()"
        type="checkbox"
        :disabled="stance.noneOfTheAbove"
      )
      v-list-item(lines="two")
        template(v-slot:prepend)
          template(v-if="hasOptionIcon")
            v-avatar(size="48")
              img( aria-hidden="true", :src="'/img/' + option.icon + '.svg'")
          template(v-else)
            common-icon(name="mdi-radiobox-blank" v-if="singleChoice && !isSelected(option)" :color="isSelected(option) ? 'primary' : 'undefined'")
            common-icon(name="mdi-radiobox-marked" v-if="singleChoice && isSelected(option)" :color="isSelected(option) ? 'primary' : 'undefined'")
            common-icon(name="mdi-checkbox-blank-outline" v-if="!singleChoice && !isSelected(option)" :color="isSelected(option) ? 'primary' : 'undefined'")
            common-icon(name="mdi-checkbox-marked" v-if="!singleChoice && isSelected(option)" :color="isSelected(option) ? 'primary' : 'undefined'")
        v-list-item-title.poll-common-vote-form__button-text {{option.optionName()}}
        v-list-item-subtitle
          plain-text.poll-common-vote-form__allow-wrap(:model="option" field="meaning")
  v-checkbox.ml-2.none-of-the-above(
    v-if="poll.showNoneOfTheAbove"
    v-model="stance.noneOfTheAbove"
    :label="$t('poll_common_form.none_of_the_above')"
  )

  poll-common-stance-reason(
    :stance='stance'
    :poll='poll'
    :selectedOptionId="selectedOptionId"
  )

  v-card-actions.poll-common-form-actions
    v-btn.mr-2(
      @click="discardDraft"
      variant="text"
      :title="$t('common.discard_changes_to_this_text')"
    )
      span(v-t="'common.reset'")

    v-spacer
    v-btn.poll-common-vote-form__submit(
      @click='submit()'
      :disabled='!optionCountValid || !poll.isVotable()'
      :loading="loading"
      color="primary"
      variant="elevated"
    )
      span(v-t="submitText")
</template>

<style lang="sass">
.none-of-the-above label
  margin-left: 24px

.poll-common-vote-form__allow-wrap
  white-space: normal
  -webkit-line-clamp: none !important;

.poll-common-vote-form__button--none-selected
  opacity: 0.88 !important

.poll-common-vote-form__button--none-selected:hover
  opacity: 1 !important

.poll-common-vote-form__button--not-selected
  opacity: 0.44 !important

.poll-common-vote-form__button--not-selected:hover
  opacity: 0.66 !important

.poll-common-vote-form__button.voting-enabled label
  cursor: pointer

.poll-common-vote-form__button label
  input
    position: absolute
    opacity: 0
    width: 0
    height: 0


.poll-common-vote-form__button.voting-disabled
  opacity: 0.33 !important

</style>
