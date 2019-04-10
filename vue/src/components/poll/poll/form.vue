<style lang="scss">
</style>
<script lang="coffee">
module.exports =
  props:
    poll: Object
    back: Boolean
</script>
<template lang="pug">
.poll-poll-form
  poll-common-form-fields(:poll="poll")
  poll-common-form-options(:poll="poll")
  poll-common-closing-at-field.md-input-compensate.md-block(:poll="poll")
  poll-common-settings(:poll="poll")
</template>
