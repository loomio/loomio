<style lang="scss">
</style>

<script lang="coffee">
export default
  props:
    poll: Object
</script>

<template lang="pug">
.poll-proposal-form
  poll-common-form-fields(:poll="poll")
  poll-common-closing-at-field(:poll="poll")
  poll-common-settings(:poll="poll")
</template>
