<script lang="js">
import OutcomeService from '@/shared/services/outcome_service';
import TopicItemService from '@/shared/services/topic_item_service';

import { pick } from 'lodash-es';

export default {
  props: {
    topic_item: Object,
    itemable: Object
  },

  computed: {
    dockActions() {
      return OutcomeService.actions(this.itemable, this);
    },
    menuActions() {
      return pick(TopicItemService.actions(this.topic_item, this), ['pin_event', 'unpin_event', 'notification_history']);
    }
  }
};

</script>

<template lang="pug">
section.outcome-created.topic-item__outcome-created(id="'outcome-'+ itemable.id")
  topic-item-headline(:topic_item="topic_item" :itemable="itemable")
  //- formatted-text.thread-item__body.new-comment__body(:model="itemable" field="body")
  //- link-previews(:model="poll")
  //- attachment-list(:attachments="itemable.attachments")
  //- action-dock(:model='itemable' :actions='dockActions' :menu-actions='menuActions' icons)
</template>
