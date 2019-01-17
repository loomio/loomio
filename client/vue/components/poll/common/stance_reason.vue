<style>
</style>

<script lang="coffee">
module.exports =
  props:
    stance: Object
</script>

<template>
    <div class="poll-common-stance-reason">
      <textarea
        v-model="stance"
        field="reason"
        :label="$t('poll_common.reason')"
        :placeholder="$t('poll_common.reason_placeholder')"
        maxlength="500"
        class="poll-common-vote-form__reason"
      ></textarea>
    </div>
</template>
