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
  <v-card class="thread-card">
    <context-panel :discussion="discussion"></context-panel>
    <activity-card :discussion="discussion" v-if="discussion.createdEvent()"></activity-card>
  </v-card>
</template>
