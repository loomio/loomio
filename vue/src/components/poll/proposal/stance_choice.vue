<style lang="scss">
</style>
<script lang="coffee">
export default
  props:
    stanceChoice: Object
</script>
<template lang="pug">
.poll-common-stance-choice.poll-common-stance-choice--proposal
  poll-common-stance-icon(:stance-choice="stanceChoice")
  span.poll-common-stance-choice__option-name(v-t="'poll_' + stanceChoice.poll().pollType + '_options.' + stanceChoice.pollOption().name")
</template>
