<script lang="js">
import EventBus from '@/shared/services/event_bus';
import Flash   from '@/shared/services/flash';
import { sortBy, take, map } from 'lodash-es';
import WatchRecords from '@/mixins/watch_records';

export default {
  mixins: [WatchRecords],
  props: {
    stance: Object
  },

  data() {
    return {pollOptions: []};
  },

  created() {
    this.watchRecords({
      collections: ['pollOptions'],
      query: records => {
        if (this.stance.poll().optionsDiffer(this.pollOptions)) {
          this.pollOptions = this.sortPollOptions();
        }
      }
    });
  },

  methods: {
    submit() {
      if (this.stance.noneOfTheAbove) {
        this.stance.stanceChoicesAttributes = []
      } else {
        const selected = take(this.pollOptions, this.numChoices);
        this.stance.stanceChoicesAttributes = map(selected, (option, index) => {
          return {
            poll_option_id: option.id,
            score:         this.numChoices - index
          };
        });
      }
      const actionName = !this.stance.castAt ? 'created' : 'updated';
      this.stance.save().then(() => {
        Flash.success(`poll_${this.stance.poll().pollType}_vote_form.stance_${actionName}`);
        EventBus.$emit("closeModal");
      }).catch((err) => {
        Flash.custom(err.error || Object.values(err.errors).join(", "));
      });
    },

    sortPollOptions() {
      if (this.stance && this.stance.castAt) {
        return sortBy(this.stance.poll().pollOptions(), o => -this.stance.scoreFor(o));
      } else {
        return this.stance.poll().pollOptionsForVoting();
      }
    }
  },

  computed: {
    poll() { return this.stance.poll(); },
    numChoices() { return this.stance.poll().minimumStanceChoices; }
  }
};
</script>

<template lang='pug'>
.poll-ranked-choice-vote-form
  .lmo-relative(style="position: relative")
    p.text-medium-emphasis.py-4(v-t="{ path: 'poll_ranked_choice_vote_form.helptext', args: { count: numChoices } }")
    v-overlay.rounded(:model-value="stance.noneOfTheAbove" contained persistent :opacity="0.1")
    sortable-list.pb-2(v-model:list="pollOptions" lock-axis="y" axis="y" append-to=".app-is-booted")
      sortable-item(
        v-for="(option, index) in pollOptions"
        :index="index"
        :key="option.id"
        :item="option"
      )
        //v-sheet.mb-2.rounded.poll-ranked-choice-vote-form__option(:class="stance.noneOfTheAbove && 'poll-option-disabled'" outlined :style="{'border-color': option.color}")
        //  v-list-item
        //    v-list-item-icon
        .mb-2.poll-ranked-choice-vote-form__option
          v-list-item.rounded(variant="tonal" :disabled="stance.noneOfTheAbove")
            template(v-slot:prepend)
              common-icon(style="cursor: pointer", :color="option.color" name="mdi-drag")
            v-list-item-title {{option.name}}
            v-list-item-subtitle {{option.meaning}}
            template(v-slot:append)
              span.text-medium-emphasis(v-show="!stance.noneOfTheAbove" style="font-size: 1.2rem" v-if="index+1 <= numChoices") # {{index+1}}

  v-checkbox.ml-4.none-of-the-above(
    v-if="poll.showNoneOfTheAbove"
    v-model="stance.noneOfTheAbove"
    :label="$t('poll_common_form.none_of_the_above')"
  )

  validation-errors(:subject='stance' field='stanceChoices')
  poll-common-stance-reason(:stance='stance', :poll='poll')
  v-card-actions.poll-common-form-actions
    v-btn.poll-common-vote-form__submit(
      block
      variant="elevated"
      :disabled="!poll.isVotable()"
      @click='submit()'
      :loading="stance.processing"
      color="primary"
    )
      span(v-t="stance.castAt? 'poll_common.update_vote' : 'poll_common.submit_vote'")
</template>

<style lang="sass">
.poll-option-disabled
  opacity: 0.4

.poll-ranked-choice-vote-form__option
  user-select: none

.app-is-booted > .sortable-list-item
  z-index: 10000
</style>
