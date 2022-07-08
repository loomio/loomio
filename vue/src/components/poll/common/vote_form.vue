<script lang="javascript">
import EventBus from '@/shared/services/event_bus';
import Flash   from '@/shared/services/flash';
import Records   from '@/shared/services/records';
import { optionColors, optionImages } from '@/shared/helpers/poll';
import { isEqual, map } from 'lodash';

export default {
  props: {
    stance: Object
  },

  data() {
    return {
      selectedOptionId: this.stance.pollOptionId(),
      options: []
    };
  },

  created() {
    this.watchRecords({
      collections: ['pollOptions'],
      query: records => {
        if (this.stance.poll().optionsDiffer(this.pollOptions)) {
          this.options = this.stance.poll().pollOptions();
        }
      }
    });
  },
          
  watch: {
    selectedOptionId() {
      EventBus.$emit('focusEditor');
    }
  },
    
  computed: {
    poll() { return this.stance.poll(); },
    selectedOption() { return Records.pollOptions.find(this.selectedOptionId); }
  },

  methods: {
    submit() {
      const actionName = !this.stance.castAt ? 'created' : 'updated';
      this.stance.stanceChoicesAttributes = [{poll_option_id: this.selectedOptionId}];
      this.stance.save().then(() => {
        Flash.success(`poll_${this.stance.poll().pollType}_vote_form.stance_${actionName}`);
        EventBus.$emit("closeModal");
      }).catch(() => true);
    },

    isSelected(option) {
      return this.selectedOptionId === option.id;
    },

    classes(option) {
      if (this.selectedOptionId) {
        if (this.selectedOptionId === option.id) {
          return ['elevation-5'];
        } else {
          return ['poll-proposal-vote-form__button--not-selected', 'elevation-3'];
        }
      } else {
        return ['elevation-1'];
      }
    }
  }
}
</script>

<template lang="pug">
form.poll-common-vote-form(
  @keyup.ctrl.enter="submit()"
  @keydown.meta.enter.stop.capture="submit()"
)
  submit-overlay(:value="stance.processing")
  label.poll-proposal-vote-form__button(
    v-for='option in options'
    :key='option.id'
    :class="classes(option)"
    
  )
    v-sheet.rounded(outlined :style="(option.id == selectedOptionId && {'border-color': option.color}) || {}")
      v-list-item
        v-list-item-icon.my-3
          v-avatar(size="48")
            img(
              aria-hidden="true"
              :src="'/img/' + option.icon + '.svg'"
            )
        input(
          v-model="selectedOptionId"
          :value="option.id"
          :aria-label="$t('poll_' + stance.poll().pollType + '_options.' + option.name)"
          type="radio"
          name="name"
        )
        v-list-item-content
          v-list-item-title
            span(
              v-if="poll.pollOptionNameFormat == 'i18n'"
              v-t="'poll_' + stance.poll().pollType + '_options.' + option.name"
              aria-hidden="true"
            )
            span(
              v-if="poll.pollOptionNameFormat == 'plain'"
              aria-hidden="true"
            ) {{option.name}}
          v-list-item-subtitle(v-if="option.meaning") {{option.meaning}}
  poll-common-stance-reason(:stance='stance' v-if='stance && selectedOptionId', :prompt="selectedOption.prompt")
  v-btn.poll-common-vote-form__submit(
    @click='submit()'
    :loading="stance.processing"
    :disabled='stance.saveDisabled || !selectedOptionId'
    color="primary"
    block
    large
  )
    span(v-t="stance.castAt? 'poll_common.update_vote' : 'poll_common.submit_vote'")
</template>

<style lang="sass">
.poll-proposal-vote-form__button--not-selected
  opacity: 0.33 !important

.poll-proposal-vote-form__button
  display: block
  margin-bottom: 8px
  cursor: pointer
  input[type=radio]
    position: absolute
    opacity: 0
    width: 0
    height: 0
.poll-proposal-vote-form__button
  .v-sheet
    &:hover
      border: 1px solid var(--v-primary-base)

</style>
