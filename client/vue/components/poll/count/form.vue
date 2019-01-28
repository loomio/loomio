<style lang="scss">
</style>
<script lang="coffee">
module.exports =
  props:
    poll: Object
    back: Boolean
</script>
<template lang="pug">
.poll-count-form
  poll-common-form-fields(:poll="poll")
  poll-common-closing-at-field(:poll="poll")
  poll-common-settings(:poll="poll")
</template>
