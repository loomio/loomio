<script lang="coffee">
export default
  props:
    event: Object

  computed:
    eventable: -> @event.model()
</script>

<template lang="pug">
.strand-other-kind(:event="event")
  formatted-text.thread-item__body(:model="eventable" column="statement")
</template>
