<script lang="js">
import PollService    from '@/shared/services/poll_service';
import AbilityService from '@/shared/services/ability_service';
import EventBus       from '@/shared/services/event_bus';
import EventService from '@/shared/services/event_service';
import { pickBy, assign } from 'lodash-es';

export default {
  props: {
    event: Object,
    collapsed: Boolean,
    eventable: Object
  },

  created() {
    EventBus.$on('stanceSaved', () => EventBus.$emit('refreshStance'));
    this.watchRecords({
      collections: ["stances", "polls"],
      query: records => {
        this.pollActions = PollService.actions(this.poll, this, this.event);
        this.eventActions = EventService.actions(this.event, this);
        this.myStance = this.poll.myStance();
      }
    });
  },

  beforeDestroy() {
    EventBus.$off('stanceSaved');
  },

  data() {
    return {
      buttonPressed: false,
      myStance: null,
      pollActions: null,
      eventActions: null
    };
  },

  computed: {
    poll() { return this.eventable; },

    menuActions() {
      return assign(
        pickBy(this.pollActions, v => v.menu)
      ,
        pickBy(this.eventActions, v => v.menu)
      );
    },
    dockActions() {
      return pickBy(this.pollActions, v => v.dock);
    }
  }
};

</script>

<template>

<section class="strand-item poll-created">
  <v-layout justify-space-between="justify-space-between">
    <div class="poll-common-card__title headline pb-1" tabindex="-1">
      <space></space>
      <router-link :to="urlFor(poll)" v-if="!poll.translation.title">{{poll.title}}</router-link>
      <translation v-if="poll.translation.title" :model="poll" field="title"></translation>
    </div>
  </v-layout>
  <div class="pt-2" v-if="!collapsed">
    <poll-common-set-outcome-panel :poll="poll" v-if="!poll.outcome()"></poll-common-set-outcome-panel>
    <poll-common-outcome-panel :outcome="poll.outcome()" v-if="poll.outcome()"></poll-common-outcome-panel>
    <div class="poll-common-details-panel__started-by text--secondary mb-4"><span v-t="{ path: 'poll_card.poll_type_by_name', args: { name: poll.authorName(), poll_type: poll.translatedPollTypeCaps() } }"></span>
      <mid-dot></mid-dot>
      <poll-common-closing-at class="ml-1" :poll="poll"></poll-common-closing-at>
      <tags-display class="ml-2" :tags="poll.tags" :group="poll.group()" smaller="smaller"></tags-display>
    </div>
    <formatted-text class="poll-common-details-panel__details" :model="poll" column="details"></formatted-text>
    <link-previews :model="poll"></link-previews>
    <attachment-list :attachments="poll.attachments"></attachment-list>
    <document-list :model="poll"></document-list>
    <poll-common-chart-panel :poll="poll"></poll-common-chart-panel>
    <poll-common-action-panel :poll="poll"></poll-common-action-panel>
    <action-dock class="my-2" :actions="dockActions" :menu-actions="menuActions"></action-dock>
  </div>
</section>
</template>
