<script lang="coffee">
export default
  props:
    discussion: Object
    loader: Object
</script>

<template lang="pug">
v-card.thread-card(elevation="1")
  context-panel(:discussion="discussion")
  activity-panel(:loader="loader" :discussion="discussion")
</template>
