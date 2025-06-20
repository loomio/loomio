<script lang="js">
import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash   from '@/shared/services/flash';
import WatchRecords from '@/mixins/watch_records';

export default {
  mixins: [WatchRecords],
  props: {
    stance: Object
  },

  data() {
    return {
      stanceChoices: [],
      pollOptions: [],
      zone: null,
      stanceValues: [],
      loading: false
    };
  },

  beforeDestroy() {
    EventBus.$off('timeZoneSelected', this.setTimeZone);
  },

  created() {
    EventBus.$on('timeZoneSelected', this.setTimeZone);
    this.watchRecords({
      collections: ['pollOptions'],
      query: records => {
        this.stanceValues = this.poll.canRespondMaybe ? [2,1,0] : [2, 0];
        if (this.stance.poll().optionsDiffer(this.pollOptions)) {
          this.pollOptions = this.stance.poll().pollOptionsForVoting();
          this.stanceChoices = this.pollOptions.map(option => {
            return {
              pollOption: option,
              poll_option_id: option.id,
              score: this.stance.scoreFor(option)
            };
          });
        }
      }
    });
  },

  methods: {
    setTimeZone(e, zone) {
      this.zone = zone;
    },

    submit() {
      this.loading = true
      this.stance.stanceChoicesAttributes = this.stanceChoices.map(choice => ({
        poll_option_id: choice.poll_option_id,
        score: choice.score
      }));

      const actionName = !this.stance.castAt ? 'created' : 'updated';
      this.stance.save().then(() => {
        EventBus.$emit("closeModal");
        Flash.success(`poll_${this.stance.poll().pollType}_vote_form.stance_${actionName}`);
      }).catch((err) => {
        Flash.error('poll_common_form.please_review_the_form');
        console.log(err);
      }).finally(() => this.loading = false);
    },

    buttonStyleFor(choice, score) {
      if (choice.score === score) {
        return {opacity: 1};
      } else {
        return {opacity: 0.3};
      }
    },

    imgForScore(score) {
      const name = (() => { switch (score) {
        case 2: return 'agree';
        case 1: return 'abstain';
        case 0: return 'disagree';
      } })();
      return `/img/${name}.svg`;
    },

    incrementScore(choice) {
      if (this.poll.canRespondMaybe) {
        return choice.score = (choice.score + 5) % 3;
      } else {
        return choice.score = choice.score === 2 ? 0 : 2;
      }
    }
  },

  computed: {
    poll() { return this.stance.poll(); },
    currentUserTimeZone() {
      return Session.user().timeZone;
    }
  }
};

</script>

<template lang='pug'>
form.poll-meeting-vote-form(@submit.prevent='submit()')
  p.text-medium-emphasis(
    v-t="{path: 'poll_meeting_vote_form.local_time_zone', args: {zone: currentUserTimeZone}}"
  )
  .poll-common-vote-form__options
    v-layout.poll-common-vote-form__option(
      v-for='choice in stanceChoices'
      :key='choice.id'
      wrap 
    )
      poll-common-stance-choice(
        :poll="stance.poll()"
        :stance-choice='choice'
        :zone='zone'
        @click="incrementScore(choice)"
      )
      v-spacer
      v-btn.poll-meeting-vote-form--box(
        v-for='i in stanceValues'
        :key='i'
        @click='choice.score = i'
        :style="buttonStyleFor(choice, i)"
        variant="flat"
        icon
      )
        v-avatar(:size="32")
          img.poll-common-form__icon(:src="imgForScore(i)")
  validation-errors(:subject='stance', field='stanceChoices')
  poll-common-stance-reason(:stance='stance', :poll='poll')
  v-card-actions.poll-common-form-actions
    v-btn.poll-common-vote-form__submit(
      block
      variant="elevated"
      :disabled="!poll.isVotable()"
      :loading="loading"
      color="primary"
      type='submit'
    )
      span(v-t="stance.castAt? 'poll_common.update_vote' : 'poll_common.submit_vote'")
</template>
