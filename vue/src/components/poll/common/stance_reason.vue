<script lang="coffee">
export default
  props:
    stance: Object
</script>

<template lang="pug">
.poll-common-stance-reason
  lmo-textarea.poll-common-vote-form__reason(:model='stance' field="reason" :placeholder="'poll_common.reason_placeholder'" maxlength='500')

</template>
