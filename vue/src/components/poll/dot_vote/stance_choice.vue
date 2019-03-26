<style lang="scss">
</style>
<script lang="coffee">
module.exports =
  props:
    stanceChoice: Object
</script>
<template lang="pug">
.poll-common-stance-choice.poll-common-stance-choice--dot-vote
  poll-common-stance-icon(:stance-choice="stanceChoice")
  span {{stanceChoice.score}} - {{stanceChoice.pollOption().name}}
</template>
