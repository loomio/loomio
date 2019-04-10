<style lang="scss">
</style>
<script lang="coffee">
module.exports =
  props:
    poll: Object
</script>
<template lang="pug">
.poll-poll-chart-panel
  poll-common-bar-chart-panel(:poll="poll")
</template>
