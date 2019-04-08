<style lang="scss">
</style>
<script lang="coffee">
export default
  props:
    stanceChoice: Object
</script>
<template lang="pug">
.poll-common-stance-choice.poll-common-stance-choice--poll
  poll-common-stance-icon(:stance-choice="stanceChoice")
  //- span(v-if="hasVariableScore") > {{stanceChoice.score}} -
  span {{stanceChoice.pollOption().name}}
</template>
