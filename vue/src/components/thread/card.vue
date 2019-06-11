<script lang="coffee">
export default
  props:
    loader: Object
    discussion: Object
</script>

<template lang="pug">
v-card.thread-card(elevation="1")
  context-panel(:discussion="discussion")
  activity-card(:loader="loader" :discussion="discussion")
</template>
