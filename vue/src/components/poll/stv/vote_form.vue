<script lang="js">
import EventBus from '@/shared/services/event_bus';
import Flash   from '@/shared/services/flash';
import { sortBy, map } from 'lodash-es';
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
      // For STV, rank all dragged options. Score = numOptions - index (higher = more preferred)
      const numOptions = this.pollOptions.length;
      this.stance.stanceChoicesAttributes = map(this.pollOptions, (option, index) => {
        return {
          poll_option_id: option.id,
          score:         numOptions - index
        };
      });
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
        .mb-2.poll-stv-vote-form__option
          v-list-item.rounded(variant="tonal")
            template(v-slot:prepend)
              common-icon(style="cursor: pointer", :color="option.color" name="mdi-drag")
            v-list-item-title {{option.name}}
            v-list-item-subtitle(v-if="option.meaning") {{option.meaning}}
            template(v-slot:append)
              span.text-medium-emphasis(style="font-size: 1.2rem") # {{index+1}}

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

.app-is-booted > .sortable-list-item
  z-index: 10000
</style>
