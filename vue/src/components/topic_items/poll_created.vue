<script lang="js">
import PollService    from '@/shared/services/poll_service';
import Session    from '@/shared/services/session';
import AbilityService from '@/shared/services/ability_service';
import TopicItemService from '@/shared/services/topic_item_service';
import { pickBy, assign, omit } from 'lodash-es';
import UrlFor from '@/mixins/url_for';
import ItemTags from '@/components/tags/item_tags.vue';

export default {
  components: { ItemTags },
  mixins: [UrlFor],
  props: {
    topic_item: Object,
    collapsed: Boolean,
    itemable: Object
  },

  data() {
    return {
      buttonPressed: false
    };
  },

  methods: {
    viewed(seen) {
      if (seen &&
          Session.isSignedIn() &&
          Session.user().autoTranslate &&
          this.dockActions['translate_poll'].canPerform()) {
        this.dockActions['translate_poll'].perform();
      }
    },
  },

  computed: {
    poll() { return this.itemable; },
    allPollActions() { return PollService.actions(this.poll, this, this.topic_item); },
    editStanceAction() { return this.allPollActions["edit_stance"]; },
    pollActions() {
      if (this.poll.pollType != 'meeting') {
        return omit(this.allPollActions, "edit_stance");
      }
      return this.allPollActions;
    },
    eventActions() {
      const topic = this.poll.topic();
      const allEventActions = TopicItemService.actions(this.topic_item, this);
      return topic.topicableType === 'Discussion' ? {edit_item_tags: allEventActions.edit_item_tags} : allEventActions;
    },
    myStance() { return this.poll.myStance(); },
    menuActions() { return assign( pickBy(this.pollActions, v => v.menu) , pickBy(this.eventActions, v => v.menu) ); },
    dockActions() { return pickBy(this.pollActions, v => v.dock); },
  }
};

</script>

<template lang="pug">
section.topic-item.poll-created(v-intersect.once="{handler: viewed}")
  topic-header.pt-3(v-if="poll.isTopicable()" :topicable="poll")
  .d-flex.flex-wrap.align-center.justify-space-between(v-if="!poll.isTopicable()")
    .poll-common-card__title.text-title-large.pb-1(tabindex="-1")
      plain-text(:model="poll" field="title")
    item-tags.ml-auto(v-if="collapsed" :topic-item="topic_item")
  div(v-if="!collapsed")
    poll-common-details-meta(:poll="poll")
      item-tags.ml-auto(v-if="!poll.isTopicable()" :topic-item="topic_item")
    poll-common-set-outcome-panel(:poll='poll' v-if="!poll.outcome()")
    poll-common-outcome-panel(:outcome='poll.outcome()' v-if='poll.outcome()')
    formatted-text.poll-common-details-panel__details(:model="poll" field="details")
    link-previews(:model="poll")
    attachment-list(:attachments="poll.attachments")
    poll-common-chart-panel(v-if="poll.isOpened()" :poll='poll')
    action-dock.my-2(:actions="dockActions" :menu-actions="menuActions" variant="tonal")
    poll-common-action-panel(:poll='poll' :editStanceAction :key="poll.id")
</template>
