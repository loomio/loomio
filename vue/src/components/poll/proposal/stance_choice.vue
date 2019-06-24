<script lang="coffee">
export default
  props:
    stanceChoice: Object
</script>
<template lang="pug">
.poll-common-stance-choice.poll-common-stance-choice--proposal
  poll-common-stance-icon(:stance-choice="stanceChoice")
</template>
