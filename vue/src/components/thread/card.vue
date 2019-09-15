<script lang="coffee">
export default
  props:
    discussion: Object
</script>

<template lang="pug">
v-card.thread-card(elevation="1")
  context-panel(:discussion="discussion")
  activity-panel(:discussion="discussion")
</template>
