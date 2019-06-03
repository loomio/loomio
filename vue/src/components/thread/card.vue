<style lang="scss">
.thread-card {
  order: 10;
}
</style>

<script lang="coffee">
export default
  props:
    loader: Object
    discussion: Object
</script>

<template>
  <v-card class="thread-card">
    <context-panel :discussion="discussion"></context-panel>
    <activity-card :loader="loader" :discussion="discussion"></activity-card>
  </v-card>
</template>
