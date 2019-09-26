<script lang="coffee">
export default
  props:
    discussion: Object

  data: ->
    topVisible: false
    bottomVisible: false
</script>

<template lang="pug">
v-card.thread-card(elevation="1")
  context-panel(:discussion="discussion" v-observe-visibility="(isVisible) => topVisible = isVisible")
  thread-actions-panel(v-if="discussion.newestFirst" :discussion="discussion")
  | topVisible {{topVisible}} bottomVisible {{bottomVisible}}
  activity-panel(:discussion="discussion" :topVisible="topVisible" :bottomVisible="bottomVisible")
  | topVisible {{topVisible}} bottomVisible {{bottomVisible}}
  div.visibilitySensor(v-observe-visibility="(isVisible) => bottomVisible = isVisible")
  thread-actions-panel(v-if="!discussion.newestFirst" :discussion="discussion" )
</template>

<style lang="css">

.visibilitySensor{
  display: block;
  height: 1px;
}

</style>
