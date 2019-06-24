<script lang="coffee">
export default
  props:
    stanceChoice: Object
    size:
      type: Number
      default: 24
</script>
<template lang="pug">
.poll-common-stance-choice.poll-common-stance-choice--proposal
  poll-common-stance-icon(:size="size" :stance-choice="stanceChoice")
</template>
