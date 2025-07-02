<script lang="js">
import AppConfig      from '@/shared/services/app_config';
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import WatchRecords   from '@/mixins/watch_records';

export default
{
  mixins: [WatchRecords],
  props: {
    poll: Object
  },

  data() {
    return {
      stance: null
    };
  },

  created() {
    if (parseInt(this.$route.query.set_outcome) === this.poll.id) {
      EventBus.$emit('openModal', {
        component: 'PollCommonOutcomeModal',
        props: {
          outcome: Records.outcomes.build({pollId: this.poll.id})
        }
      });
    }

    if (parseInt(this.$route.query.change_vote) === this.poll.id) {
      EventBus.$emit('openModal', {
        component: 'PollCommonEditVoteModal',
        props: {
          stance: this.poll.myStance()
        }
      }
      );
    }

    EventBus.$on('deleteMyStance', pollId => {
      if (pollId === this.poll.id) {
        return this.stance = null;
      }
    });

    this.watchRecords({
      collections: ["stances"],
      query: () => {
        console.log("watched stances change");
        if (this.stance && !this.stance.castAt && this.poll.myStance() && this.poll.myStance().castAt) {
          this.stance = this.lastStanceOrNew().clone();
        }

        if (this.stance && this.stance.castAt && this.poll.myStance() && !this.poll.myStance().castAt) {
          this.stance = this.lastStanceOrNew().clone();
        }

        if (this.stance && this.stance.castAt && this.poll.myStance() && this.poll.myStance().castAt && this.stance.updatedAt < this.poll.myStance().updatedAt) {
          this.stance = this.lastStanceOrNew().clone();
        }

        if (!this.stance && AbilityService.canParticipateInPoll(this.poll)) {
          this.stance = this.lastStanceOrNew().clone();
        }
      }
    });
  },

  methods: {
    lastStanceOrNew() {
      const stance = this.poll.myStance() || Records.stances.build({
        reasonFormat: Session.defaultFormat(),
        pollId:    this.poll.id,
        userId:    AppConfig.currentUserId
      });
      if (this.$route.params.poll_option_id) {
        stance.choose(this.$route.params.poll_option_id);
      }
      return stance;
    }
  }
};

</script>

<template lang="pug">
.poll-common-action-panel(v-if="!poll.closedAt" style="position: relative")
  v-alert.poll-common-action-panel__anonymous-message.mt-6(
    v-if='poll.anonymous'
    density="compact"
    variant="tonal"
    type="info"
  )
    span(v-t="'poll_common_action_panel.anonymous'")

  .poll-common-vote-form(v-if="stance && !stance.castAt")
    h3.text-h6.py-3(v-t="'poll_common.have_your_say'")
    poll-common-directive(:stance='stance' name='vote-form')

  v-alert.poll-common-current-vote(color="info" variant="tonal" v-if="stance && stance.castAt")
    .text-subtitle1.mb-2
      span(v-t="'poll_common.you_voted'")
    poll-common-stance-choice(
      v-if="poll.hasOptionIcon()"
      :size="28"
      :poll="poll"
      :stance-choice="stance.stanceChoice()"
      verbose)
    poll-common-stance-choices(:stance='stance')

  .poll-common-unable-to-vote(v-if='!stance')
    v-alert.my-4(
      type="warning"
      variant="tonal"
      density="compact"
      v-t="{path: 'poll_common_action_panel.unable_to_vote', args: {poll_type: poll.translatedPollType()}}"
    )

</template>
