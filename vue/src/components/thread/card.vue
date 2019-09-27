<script lang="coffee">
export default
  props:
    discussion: Object
  data: ->
    viewportIsBelow: false
</script>

<template lang="pug">
v-card.thread-card(elevation="1")
  context-panel(:discussion="discussion")
  thread-actions-panel(v-if="discussion.newestFirst" :discussion="discussion")
  activity-panel(:discussion="discussion" :viewport-is-below="viewportIsBelow")
  thread-actions-panel(v-if="!discussion.newestFirst" :discussion="discussion" v-observe-visibility="(isVisible) => viewportIsBelow = isVisible")
</template>
