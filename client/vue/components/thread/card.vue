<style lang="scss">
.thread-card {
  order: 10;
}
</style>

<script lang="coffee">
module.exports =
  props:
    discussion: Object
</script>

<template>
    <div class="thread-card lmo-card--no-padding">
      <context-panel :discussion="discussion"></context-panel>
      <activity-card :discussion="discussion" v-if="discussion.createdEvent()"></activity-card>
    </div>
</template>
