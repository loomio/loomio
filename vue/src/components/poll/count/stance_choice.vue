<style lang="scss">
</style>

<script lang="coffee">
module.exports =
  props:
    stanceChoice: Object
</script>

<template>
    <div class="poll-common-stance-choice poll-common-stance-choice--count">
      <poll-common-stance-icon :stance-choice="stanceChoice"></poll-common-stance-icon>
      <span v-t="'poll_count_options.' + stanceChoice.pollOption().name" class="poll-common-stance-choice__option-name"></span>
    </div>
</template>
