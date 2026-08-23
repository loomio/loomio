<script lang="js">
import { eventHeadline, eventTitle, eventPollType } from '@/shared/helpers/helptext';
import Records        from '@/shared/services/records';

export default {
  props: {
    topic_item: Object,
    itemable: Object
  },

  computed: {
    headline() {
      const actor = this.topic_item.actor();
      return this.$t(eventHeadline(this.topic_item, true ), { // useNesting
        author:   actor.nameWithTitle(this.itemable.group()),
        username: actor.username,
        key:      this.topic_item.model().key,
        title:    eventTitle(this.topic_item),
        polltype: this.topic_item.isPollTopicItem() ? this.$t(eventPollType(this.topic_item)).toLowerCase() : null
      });
    }
  }
};
</script>

<template lang="pug">
strand-item-headline(:topic_item="topic_item" :itemable="itemable")
</template>

<style>
.strand-other-kind .actor-link {

}

</style>
