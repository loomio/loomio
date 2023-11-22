<script lang="js">
import Session  from '@/shared/services/session';
import Records  from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import PollCommonDirective from '@/components/poll/common/directive';
import PollTemplateBanner from '@/components/poll/template_banner';
import PollService from '@/shared/services/poll_service';
import { pickBy } from 'lodash-es';

export default
{
  components: { PollCommonDirective, PollTemplateBanner},

  props: {
    poll: Object,
    isPage: Boolean
  },

  created() {
    EventBus.$on('stanceSaved', () => EventBus.$emit('refreshStance'));
    this.watchRecords({
      collections: ["stances", "outcomes"],
      query: records => {
        this.actions = PollService.actions(this.poll);
        this.myStance = this.poll.myStance() || Records.stances.build();
        return this.outcome = this.poll.outcome();
      }
    });
  },

  data() {
    return {
      actions: {},
      buttonPressed: false,
      myStance: null,
      outcome: this.poll.outcome()
    };
  },

  methods: {
    titleVisible(visible) {
      if (this.isPage) { EventBus.$emit('content-title-visible', visible); }
    }
  },

  computed: {
    menuActions() {
      return pickBy(this.actions, v => v.menu);
    },

    dockActions() {
      return pickBy(this.actions, v => v.dock);
    }
  }
};


</script>

<template>

<v-sheet>
  <poll-common-card-header :poll="poll"></poll-common-card-header>
  <div v-if="poll.discardedAt">
    <v-card-text>
      <div class="text--secondary" v-t="'poll_common_card.deleted'"></div>
    </v-card-text>
  </div>
  <div class="px-2 pb-4 px-sm-4" v-else>
    <poll-template-banner :poll="poll"></poll-template-banner>
    <h1 class="poll-common-card__title text-h4 py-2" tabindex="-1" v-observe-visibility="{callback: titleVisible}">
      <poll-common-type-icon class="mr-2" :poll="poll"></poll-common-type-icon><span v-if="!poll.translation.title">{{poll.title}}</span>
      <translation :model="poll" field="title" v-if="poll.translation.title"></translation>
    </h1>
    <poll-common-set-outcome-panel :poll="poll" v-if="!outcome"></poll-common-set-outcome-panel>
    <poll-common-outcome-panel :outcome="outcome" v-if="outcome"></poll-common-outcome-panel>
    <poll-common-details-panel :poll="poll"></poll-common-details-panel>
    <poll-common-chart-panel :poll="poll"></poll-common-chart-panel>
    <poll-common-action-panel :poll="poll"></poll-common-action-panel>
    <action-dock class="mt-4" :menu-actions="menuActions" :actions="dockActions"></action-dock>
    <div class="poll-common-card__results-shown mt-4">
      <poll-common-votes-panel :poll="poll"></poll-common-votes-panel>
    </div>
  </div>
</v-sheet>
</template>
<style lang="sass">
.v-card__title .poll-common-card__title
  word-break: normal
</style>
