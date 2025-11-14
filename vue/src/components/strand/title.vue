<script setup lang="js">
import { computed } from 'vue';
import ThreadService from '@/shared/services/thread_service';
import EventBus from '@/shared/services/event_bus';
import openModal from '@/shared/helpers/open_modal';

const props = defineProps({
  discussion: Object
});

const status = computed(() => {
  if (props.discussion.pinned) { return 'pinned'; }
});

// Note: titleVisible is referenced in template but not defined in original
// This may need to be implemented based on how intersect directive works
const titleVisible = () => {
  // Implementation depends on what the intersect directive expects
};
</script>

<template lang="pug">
.thread-title
  h1.text-h4.context-panel__heading#sequence-0.pt-2.mb-4(tabindex="-1" v-intersect="{handler: titleVisible}")
    plain-text(:model='discussion' field='title')
    i.mdi.mdi-pin-outline.context-panel__heading-pin(v-if="status == 'pinned'")
</template>