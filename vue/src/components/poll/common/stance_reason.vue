<style lang="scss">
</style>

<script lang="coffee">
module.exports =
  props:
    stance: Object
</script>

<template lang="pug">
.poll-common-stance-reason
  lmo-textarea.poll-common-vote-form__reason(:model='stance' field="reason" :placeholder="$t('poll_common.reason_placeholder')" maxlength='500')

</template>
