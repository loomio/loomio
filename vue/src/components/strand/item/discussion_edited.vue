<script lang="coffee">
export default
  props:
    event: Object

  computed:
    eventable: -> @event.model()
</script>

<template lang="pug">
section.strand-item__discussion-edited(id="'outcome-'+ eventable.id")
  strand-item-headline(:event="event" :eventable="eventable")
  p {{event.recipientMessage}}
</template>
