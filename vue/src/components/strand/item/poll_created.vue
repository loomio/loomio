<script lang="js">
import PollService    from '@/shared/services/poll_service';
import Session    from '@/shared/services/session';
import AbilityService from '@/shared/services/ability_service';
import EventBus       from '@/shared/services/event_bus';
import EventService from '@/shared/services/event_service';
import { pickBy, assign, omit } from 'lodash-es';
import WatchRecords from '@/mixins/watch_records';
import UrlFor from '@/mixins/url_for';

export default {
  mixins: [WatchRecords, UrlFor],
  props: {
    event: Object,
    collapsed: Boolean,
    eventable: Object
  },

  data() {
    return {
      buttonPressed: false,
      myStance: null,
      dockActions: [],
      menuActions: []
    };
  },

  created() {
    EventBus.$on('stanceSaved', () => EventBus.$emit('refreshStance'));
    this.watchRecords({
      collections: ["stances", "polls"],
      query: () => {
        this.rebuildActions();
      }
    });
  },

  beforeDestroy() {
    EventBus.$off('stanceSaved');
  },

  methods: {
    rebuildActions() {
      let pollActions = PollService.actions(this.poll, this, this.event);
      this.editStanceAction = pollActions["edit_stance"]
      if (this.poll.pollType != 'meeting') {
        pollActions = omit(pollActions, "edit_stance");
      }
      const eventActions = EventService.actions(this.event, this);
      this.myStance = this.poll.myStance();
      this.menuActions = assign( pickBy(pollActions, v => v.menu) , pickBy(this.eventActions, v => v.menu) );
      this.dockActions = pickBy(pollActions, v => v.dock);
    },

    viewed(seen) {
      if (seen &&
          Session.isSignedIn() &&
          Session.user().autoTranslate &&
          this.dockActions['translate_poll'].canPerform()) {
        this.dockActions['translate_poll'].perform().then(() => this.rebuildActions());
      }
    },
  },

  computed: {
    poll() { return this.eventable; },
  }
};

</script>

<template lang="pug">
section.strand-item.poll-created(v-intersect.once="{handler: viewed}")
  .d-flex.justify-space-between
    .poll-common-card__title.text-h6.pb-1(tabindex="-1")
      router-link.underline-on-hover.text-high-emphasis(:to="urlFor(poll)" )
        plain-text(:model="poll" field="title")
  div(v-if="!collapsed")
    poll-common-set-outcome-panel(:poll='poll' v-if="!poll.outcome()")
    poll-common-outcome-panel(:outcome='poll.outcome()' v-if='poll.outcome()')
    .poll-common-details-panel__started-by.text-medium-emphasis.text-body-2.mb-4
      span(v-t="{ path: 'poll_card.poll_type_by_name', args: { name: poll.authorName(), poll_type: poll.translatedPollTypeCaps() } }")
      mid-dot
      poll-common-closing-at.ml-1(:poll='poll')
      tags-display.ml-2(:tags="poll.tags" :group="poll.group()" smaller)
    formatted-text.poll-common-details-panel__details(:model="poll" field="details")
    link-previews(:model="poll")
    attachment-list(:attachments="poll.attachments")
    document-list(:model='poll')
    poll-common-chart-panel(v-if="poll.isOpened()" :poll='poll')
    poll-common-action-panel(:poll='poll' :editStanceAction :key="poll.id")
    action-dock.my-2(:actions="dockActions" :menu-actions="menuActions" variant="tonal" color="primary")
</template>
