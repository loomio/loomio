<script lang="js">
import ThreadService  from '@/shared/services/thread_service';
import EventBus from '@/shared/services/event_bus';
import openModal      from '@/shared/helpers/open_modal';

export default {
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

<template>

<div class="thread-title">
  <h1 class="text-h4 context-panel__heading pt-2 mb-4" id="sequence-0" tabindex="-1" v-observe-visibility="{callback: titleVisible}"><span v-if="!discussion.translation.title">{{discussion.title}}</span><span v-if="discussion.translation.title">
      <translation :model="discussion" field="title"></translation></span><i class="mdi mdi-pin-outline context-panel__heading-pin" v-if="status == 'pinned'"></i></h1>
</div>
</template>
