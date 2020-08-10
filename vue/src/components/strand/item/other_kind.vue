<script lang="coffee">
export default
  props:
    event: Object
  computed:
    eventable: -> object.model()

</script>

<template lang="pug">
.strand-item
  p {{ event.kind }}
  //- formatted-text.thread-item__body(:model="eventable" column="statement")
</template>
