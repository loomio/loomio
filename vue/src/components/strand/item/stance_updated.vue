<script lang="coffee">
import StanceUpdated from '@/components/strand/item/stance_created.vue'

export default
  components: {StanceUpdated}
  props:
    event: Object
    eventable: Object
    collapsed: Boolean
</script>

<template lang="pug">
stance-updated(:event="event" :eventable="eventable" :collapsed="collapsed")
</template>
