<script lang="js">
import DiscussionService  from '@/shared/services/discussion_service';
import EventBus from '@/shared/services/event_bus';
import openModal      from '@/shared/helpers/open_modal';
import FormatDate from '@/mixins/format_date';

export default {
  mixins: [FormatDate],
  props: {
    discussion: Object
  },

  computed: {
    status() {
      if (this.discussion.pinned) { return 'pinned'; }
    }
  }
};

</script>

<template lang="pug">
.thread-title
  h1.text-headline-large.context-panel__heading#sequence-0.pt-2.mb-4(tabindex="-1" v-intersect="{handler: titleVisible}")
    plain-text(:model='discussion' field='title')
    i.mdi.mdi-pin-outline.context-panel__heading-pin(v-if="status == 'pinned'")
</template>
