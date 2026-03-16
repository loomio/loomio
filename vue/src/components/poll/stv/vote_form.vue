<script lang="js">
import EventBus from '@/shared/services/event_bus';
import Flash   from '@/shared/services/flash';
import { sortBy } from 'lodash-es';
import WatchRecords from '@/mixins/watch_records';

const DIVIDER = { id: 'divider', isDivider: true };

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
        const realOptions = this.pollOptions.filter(o => !o.isDivider);
        if (this.stance.poll().optionsDiffer(realOptions)) {
          this.pollOptions = this.sortPollOptions();
        }
      }
    });
  },

  methods: {
    submit() {
      const dividerIndex = this.pollOptions.findIndex(o => o.isDivider);
      const ranked = this.pollOptions.slice(0, dividerIndex);
      this.stance.stanceChoicesAttributes = ranked.map((option, index) => ({
        poll_option_id: option.id,
        score: index + 1
      }));
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
        const allOptions = this.stance.poll().pollOptions();
        const scores = this.stance.optionScores;
        const ranked = sortBy(allOptions.filter(o => scores[o.id] !== undefined), o => scores[o.id]);
        const unranked = allOptions.filter(o => scores[o.id] === undefined);
        return [...ranked, DIVIDER, ...unranked];
      } else {
        return [DIVIDER, ...this.stance.poll().pollOptionsForVoting()];
      }
    },

    isAboveDivider(index) {
      const dividerIndex = this.pollOptions.findIndex(o => o.isDivider);
      return index < dividerIndex;
    },

    rankFor(index) {
      return index + 1;
    }
  },

  computed: {
    poll() { return this.stance.poll(); },
    numOptions() { return this.pollOptions.length; }
  }
};
</script>

<template lang='pug'>
.poll-stv-vote-form
  .lmo-relative(style="position: relative")
    p.text-medium-emphasis.py-4(v-t="'poll_stv_vote_form.helptext'")
    sortable-list.pb-2(v-model:list="pollOptions" lock-axis="y" axis="y" append-to=".app-is-booted")
      sortable-item(
        v-for="(option, index) in pollOptions"
        :index="index"
        :key="option.id"
        :item="option"
      )
        template(v-if="option.isDivider")
          .poll-stv-vote-form__divider.my-2
            v-divider
            .poll-stv-vote-form__divider-text.text-medium-emphasis
              common-icon(name="mdi-drag" style="cursor: pointer")
              span(v-t="'poll_stv_vote_form.divider_text'")
            v-divider
        template(v-else)
          .mb-2.poll-stv-vote-form__option(:class="{'poll-stv-vote-form__option--unranked': !isAboveDivider(index)}")
            v-list-item.rounded(variant="tonal")
              template(v-slot:prepend)
                common-icon(style="cursor: pointer", :color="option.color" name="mdi-drag")
              v-list-item-title {{option.name}}
              v-list-item-subtitle(v-if="option.meaning") {{option.meaning}}
              template(v-slot:append)
                span.text-medium-emphasis(v-if="isAboveDivider(index)" style="font-size: 1.2rem") # {{rankFor(index)}}

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
.poll-stv-vote-form__option
  user-select: none

.poll-stv-vote-form__option--unranked
  opacity: 0.5

.poll-stv-vote-form__divider
  display: flex
  align-items: center
  gap: 8px
  user-select: none
  cursor: pointer
  .v-divider
    flex: 1

.poll-stv-vote-form__divider-text
  display: flex
  align-items: center
  gap: 4px
  white-space: nowrap
  font-size: 0.85rem

.app-is-booted > .sortable-list-item
  z-index: 10000
</style>
