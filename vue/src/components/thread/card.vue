<script lang="coffee">
export default
  props:
    discussion: Object
  data: ->
    viewportIsAbove: false
    viewportIsBelow: false
</script>

<template lang="pug">
v-card.thread-card(elevation="1")
  context-panel(:discussion="discussion" v-observe-visibility="(isVisible) => viewportIsAbove = isVisible")
  thread-actions-panel(v-if="discussion.newestFirst" :discussion="discussion")
  activity-panel(:discussion="discussion" :viewport-is-below="viewportIsBelow" :viewport-is-above="viewportIsAbove")
  div.visibility-sensor(style="min-height: 1px"  v-observe-visibility="(isVisible) => viewportIsBelow = isVisible")
    thread-actions-panel(v-if="!discussion.newestFirst" :discussion="discussion")
</template>
