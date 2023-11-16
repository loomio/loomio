<script lang="js">
import AppConfig from '@/shared/services/app_config';
import AbilityService from '@/shared/services/ability_service';
import { find } from 'lodash-es';

export default {
  props: {
    discussion: Object
  },

  data() {
    return {poll: null};
  },

  created() {
    this.watchRecords({
      collections: ['polls', 'stances'],
      query: store => {
        this.poll = find(this.discussion.activePolls().filter(poll => poll.pollOptionNames.length), poll => poll.closingAt && AbilityService.canParticipateInPoll(poll) && !poll.iHaveVoted());
      }
    });
  },

  computed: {
    styles() {
      const { bar, top } = this.$vuetify.application;
      return{
        display: 'flex',
        position: 'sticky',
        top: `${bar + top}px`,
        zIndex: 1
      };
    },
    event() {
      return this.poll && this.poll.createdEvent();
    }
  }
};


</script>
<template lang="pug">
v-card.current-poll-banner.mb-4.py-2.px-4.lmo-no-print(:style="styles" v-if="event && $route.params.sequence_id != event.sequenceId" :elevation="3" :aria-label="$t('thread_context.current_poll_type_banner', {pollType: poll.translatedPollType()})")
  v-avatar.mr-4(:size="36" tile)
    poll-common-icon-panel(:poll='poll' :size="36")
  .current-poll-banner__title.mr-4
    span {{poll.title}}
  v-spacer
  v-btn(color="primary" :to="urlFor(event)" v-t="'common.view'")
</template>

<style lang="sass">
.current-poll-banner
  display: flex
  align-items: center
.current-poll-banner__title
  white-space: nowrap
  overflow: hidden
  text-overflow: ellipsis

  // position: sticky top: 64px
  // z-index: 1
//   .v-banner__content
//     overflow: visible
// .v-banner--single-line
//   .v-banner__text
// overflow: visible !important
</style>
