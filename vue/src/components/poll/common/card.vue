<script lang="js">
import Records  from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import PollCommonDirective from '@/components/poll/common/directive';
import PollTemplateBanner from '@/components/poll/template_banner';
import PollService from '@/shared/services/poll_service';
import { pickBy, omit } from 'lodash-es';
import WatchRecords from '@/mixins/watch_records';
import FormatDate from '@/mixins/format_date';

export default
{
  mixins: [WatchRecords, FormatDate],
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
        const actions = PollService.actions(this.poll, this)
        if (this.poll.pollType == 'meeting') {
          this.actions = actions
        } else {
          this.actions = omit(actions, "edit_stance");
        }
        this.editStanceAction = actions['edit_stance'];
        this.myStance = this.poll.myStance() || Records.stances.build();
        return this.outcome = this.poll.outcome();
      }
    });
  },

  data() {
    return {
      actions: {},
      editStanceAction: null,
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

<template lang="pug">
v-card
  poll-common-card-header(:poll='poll')
  div(v-if="poll.discardedAt")
    v-card-text
      .text-medium-emphasis(v-t="'poll_common_card.deleted'")
  div.px-2.pb-4.px-sm-4(v-else)
    poll-template-banner(:poll="poll")
    h1.poll-common-card__title.text-h4.py-2(tabindex="-1" v-intersect="{handler: titleVisible}")
      span(v-if='!poll.translation.title') {{poll.title}}
      translation(:model='poll' field='title' v-if="poll.translation.title")
    poll-common-set-outcome-panel(:poll='poll' v-if="!outcome")
    poll-common-outcome-panel(:outcome='outcome' v-if="outcome")
    poll-common-details-panel(:poll='poll')
    poll-common-chart-panel(:poll='poll')
    poll-common-action-panel(:poll='poll' :editStanceAction)
    action-dock.mt-4(
      color="primary"
      variant="tonal"
      :menu-actions="menuActions"
      :actions="dockActions")
    .poll-common-card__results-shown.mt-4
      poll-common-votes-panel(:key="poll.id" :poll='poll')
</template>
<style lang="sass">
.v-card__title .poll-common-card__title
  word-break: normal
</style>
