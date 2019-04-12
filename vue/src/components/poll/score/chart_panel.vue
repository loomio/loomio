<style lang="scss">
</style>
<script lang="coffee">
export default
  props:
    poll: Object
</script>
<template lang="pug">
.poll-dot-vote-chart-panel
  poll-common-bar-chart-panel(:poll="poll")
</template>
