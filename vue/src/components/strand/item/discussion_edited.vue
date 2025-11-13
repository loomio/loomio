<script setup lang="js">
const props = defineProps({
  event: Object,
  eventable: Object
});
</script>

<template lang="pug">
section.strand-item__discussion-edited
  strand-item-headline(:event="event" :eventable="eventable", :dateTime="event.createdAt")
  p {{event.recipientMessage}}
</template>