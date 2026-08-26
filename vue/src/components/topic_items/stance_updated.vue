<script lang="js">
import StanceUpdated from '@/components/topic_items/stance_created.vue';

export default {
  components: {StanceUpdated},
  props: {
    topic_item: Object,
    itemable: Object,
    collapsed: Boolean
  }
};
</script>

<template lang="pug">
stance-updated(:topic_item="topic_item" :itemable="itemable" :collapsed="collapsed")
</template>
