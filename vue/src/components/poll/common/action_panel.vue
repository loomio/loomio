<script lang="js">
import AppConfig      from '@/shared/services/app_config';
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import WatchRecords   from '@/mixins/watch_records';
import { marked }    from 'marked';

export default
{
  mixins: [WatchRecords],
  props: {
    poll: Object,
    editStanceAction: Object
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

  computed: {
    strippedReason() {
      if (!this.stance || this.stance.reason.length === 0) { return null };
      let html = '';
      if (this.stance.reasonFormat == 'md') {
        html = marked(this.stance.reason);
      } else {
        html = this.stance.reason
      }
      let doc = new DOMParser().parseFromString(html, 'text/html');
      return doc.body.textContent || "";
    }
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
    h3.text-h6.py-3.text-high-emphasis(v-t="'poll_common.have_your_say'")
    poll-common-directive(:stance='stance' name='vote-form')

  template(v-if="stance && stance.castAt && poll.pollType != 'meeting'")
    template(v-if="poll.singleChoice()")
      v-alert.poll-common-current-vote(variant="tonal" color="primary" border :title="$t('poll_common.you_voted')")
        p.mt-2
          poll-common-stance-choice(
            :size="28"
            :poll="poll"
            :stance-choice="stance.stanceChoice()"
            verbose)
        .d-flex.align-center
          span.text-truncate.text-medium-emphasis {{strippedReason}}
          v-spacer
          action-button.float-right(:action="editStanceAction" variant="tonal")
    template(v-else)
      v-alert.poll-common-current-vote(variant="tonal" color="primary" border :title="$t('poll_common.you_voted')")
        poll-common-stance-choices(:stance='stance')
        .d-flex
          v-spacer
          action-button.float-right(:action="editStanceAction" variant="tonal")

  .poll-common-unable-to-vote(v-if='!stance')
    v-alert.my-4(
      color="warning"
      variant="tonal"
    )
      span(v-t="{path: 'poll_common_action_panel.unable_to_vote', args: {poll_type: poll.translatedPollType()}}")

</template>
