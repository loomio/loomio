<script lang="coffee">
export default
  props:
    poll: Object
</script>
<template lang="pug">
.poll-poll-chart-panel
  poll-common-bar-chart-panel(:poll="poll")
</template>
