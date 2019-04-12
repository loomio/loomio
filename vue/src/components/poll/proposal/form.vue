<style lang="scss">
</style>

<script lang="coffee">
export default
  props:
    poll: Object
</script>

<template>
  <div class="poll-proposal-form">
    <poll-common-form-fields :poll="poll"></poll-common-form-fields>
    <poll-common-closing-at-field :poll="poll"></poll-common-closing-at-field>
    <poll-common-settings :poll="poll"></poll-common-settings>
  </div>
</template>
