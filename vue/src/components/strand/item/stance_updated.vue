<script setup lang="js">
import StanceUpdated from '@/components/strand/item/stance_created.vue';

const props = defineProps({
  event: Object,
  eventable: Object,
  collapsed: Boolean
});
</script>

<template lang="pug">
stance-updated(:event="event" :eventable="eventable" :collapsed="collapsed")
</template>