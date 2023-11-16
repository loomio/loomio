<script lang="js">
import PollService    from '@/shared/services/poll_service';
import AbilityService from '@/shared/services/ability_service';
import EventBus       from '@/shared/services/event_bus';
import EventService from '@/shared/services/event_service';
import { pick, pickBy, assign } from 'lodash-es';

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

<template lang="pug">
section.strand-item.poll-created
  v-layout(justify-space-between)
    .poll-common-card__title.headline.pb-1(tabindex="-1")
      //- poll-common-type-icon(:poll="poll")
      space
      router-link(:to="urlFor(poll)" v-if='!poll.translation.title') {{poll.title}}
      translation(v-if="poll.translation.title", :model='poll', field='title')
  .pt-2(v-if="!collapsed")
    poll-common-set-outcome-panel(:poll='poll' v-if="!poll.outcome()")
    poll-common-outcome-panel(:outcome='poll.outcome()' v-if='poll.outcome()')
    .poll-common-details-panel__started-by.text--secondary.mb-4
      span(v-t="{ path: 'poll_card.poll_type_by_name', args: { name: poll.authorName(), poll_type: poll.translatedPollTypeCaps() } }")
      mid-dot
      poll-common-closing-at.ml-1(:poll='poll')
      tags-display.ml-2(:tags="poll.tags" :group="poll.group()" smaller)
    formatted-text.poll-common-details-panel__details(:model="poll" column="details")
    link-previews(:model="poll")
    attachment-list(:attachments="poll.attachments")
    document-list(:model='poll')
    poll-common-chart-panel(:poll='poll')
    poll-common-action-panel(:poll='poll')
    action-dock.my-2(:actions="dockActions", :menu-actions="menuActions")
</template>
