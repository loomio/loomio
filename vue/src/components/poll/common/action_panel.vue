<script lang="js">
import AppConfig      from '@/shared/services/app_config';
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import LmoUrlService  from '@/shared/services/lmo_url_service';

export default
{
  props: {
    poll: Object
  },

  data() {
    return {stance: null};
  },

  created() {
    if (parseInt(this.$route.query.set_outcome) === this.poll.id) {
      EventBus.$emit('openModal', {
        component: 'PollCommonOutcomeModal',
        props: {
          outcome: Records.outcomes.build({pollId: this.poll.id})
        }
      }
      );
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
      query: records => {
        if (this.stance && !this.stance.castAt && this.poll.myStance() && this.poll.myStance().castAt) {
          this.stance = this.lastStanceOrNew().clone();
        }

        if (this.stance && this.stance.castAt && this.poll.myStance() && !this.poll.myStance().castAt) {
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

<template>

<div class="poll-common-action-panel" v-if="!poll.closedAt" style="position: relative">
  <v-alert class="poll-common-action-panel__anonymous-message mt-6" dense="dense" outlined="outlined" type="info" v-if="poll.anonymous"><span v-t="'poll_common_action_panel.anonymous'"></span></v-alert>
  <v-overlay class="rounded elevation-1" absolute="absolute" v-if="!poll.closingAt" :opacity="0.33" :z-index="2">
    <v-alert class="poll-common-action-panel__results-hidden-until-vote my-2 elevation-5" dense="dense" type="info"><span v-t="{path: 'poll_common_action_panel.draft_mode', args: {poll_type: poll.translatedPollType()}}"></span></v-alert>
  </v-overlay>
  <template v-else>
    <div class="poll-common-vote-form" v-if="stance && !stance.castAt">
      <h3 class="title py-3" v-t="'poll_common.have_your_say'"></h3>
    </div>
  </template>
  <poll-common-directive :class="{'pa-2': !poll.closingAt}" v-if="stance && !stance.castAt" :stance="stance" name="vote-form"></poll-common-directive>
  <div class="poll-common-unable-to-vote" v-if="!stance">
    <v-alert class="my-4" type="warning" outlined="outlined" dense="dense" v-t="{path: 'poll_common_action_panel.unable_to_vote', args: {poll_type: poll.translatedPollType()}}"></v-alert>
  </div>
</div>
</template>
