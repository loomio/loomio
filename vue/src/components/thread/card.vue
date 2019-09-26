<script lang="coffee">
export default
  props:
    discussion: Object

  data: ->
    topVisible: false
</script>

<template lang="pug">
v-card.thread-card(elevation="1")
  context-panel(:discussion="discussion" v-observe-visibility="(isVisible) => topVisible = isVisible")
  thread-actions-panel(v-if="discussion.newestFirst" :discussion="discussion")
  activity-panel(:discussion="discussion" :topVisible="topVisible")
  thread-actions-panel(v-if="!discussion.newestFirst" :discussion="discussion" )
</template>

<style lang="css">

.visibilitySensor{
  display: block;
  height: 1px;
}

</style>
