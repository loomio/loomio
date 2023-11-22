<script lang="js">
import StanceUpdated from '@/components/strand/item/stance_created.vue';

export default {
  components: {StanceUpdated},
  props: {
    event: Object,
    eventable: Object,
    collapsed: Boolean
  }
};
</script>

<template>

<stance-updated :event="event" :eventable="eventable" :collapsed="collapsed"></stance-updated>
</template>
