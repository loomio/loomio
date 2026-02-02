<script lang="js">
import AppConfig      from '@/shared/services/app_config';
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import WatchRecords   from '@/mixins/watch_records';
import { marked }     from 'marked';

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
        // we need to maintain a clone of our stance, so live updates don't clobber our form.
        if (this.poll.myStance()) {
          // we have been issued a vote for this poll
          if (!this.stance) {
            // we have not made a clone yet. clone the vote for use in the form
            this.makeCloneStance();
          } else {
            // we've already made a clone, which may need replacing in these cases:
            // clone is not cast, but real is cast
            // clone is cast but the real is not
            // both are cast, but real is newer
            if (
              (!this.stance.castAt && this.poll.myStance().castAt) ||
              (this.stance.castAt  && !this.poll.myStance().castAt) ||
              (this.stance.castAt  && this.poll.myStance().castAt && this.stance.updatedAt < this.poll.myStance().updatedAt)
            ) {
              this.makeCloneStance();
            }
          }
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
    makeCloneStance() {
      this.stance = this.poll.myStance().clone();
      if (this.$route.params.poll_option_id) {
        this.stance.choose(this.$route.params.poll_option_id);
      }
    }
  }
};

</script>

<template lang="pug">
.poll-common-action-panel(style="position: relative")
  template(v-if="poll.isVotable()")
    v-alert.poll-common-action-panel__anonymous-message.my-4(
      v-if='poll.anonymous'
      density="compact"
      variant="tonal"
      type="info"
    )
      span(v-t="'poll_common_action_panel.anonymous'")

    .poll-common-vote-form(v-if="stance && !stance.castAt")
      h3.text-title-large.py-3.text-high-emphasis(v-t="'poll_common.have_your_say'")
      poll-common-directive(:stance='stance' name='vote-form' :key="poll.id")

    .poll-common-unable-to-vote(v-if='!stance')
      v-alert.my-4(
        color="warning"
        variant="tonal"
      )
        span(v-t="{path: 'poll_common_action_panel.unable_to_vote', args: {poll_type: poll.translatedPollType()}}")

  template(v-if="stance && stance.castAt && poll.pollType != 'meeting'")
    v-alert.poll-common-current-vote(variant="tonal" color="primary" border :title="$t('poll_common.you_voted')")
      .mt-2
        poll-common-stance-choice(
          v-if="poll.singleChoice()"
          :size="28"
          :poll="poll"
          :stance-choice="stance.stanceChoice()"
          verbose
        )
        poll-common-stance-choices(v-else :stance='stance')
      .d-flex.align-center
        span.text-truncate.text-medium-emphasis {{strippedReason}}
        v-spacer
        action-button.float-right(v-if="poll.isVotable()" :action="editStanceAction" variant="tonal")

</template>
