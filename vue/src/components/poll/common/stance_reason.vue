<style lang="scss">
</style>

<script lang="coffee">
module.exports =
  props:
    stance: Object
</script>

<template>
    <div class="poll-common-stance-reason">
      <v-textarea
        v-model="stance.reason"
        :label="$t('poll_common.reason')"
        :placeholder="$t('poll_common.reason_placeholder')"
        maxlength="500"
        class="poll-common-vote-form__reason"
      ></v-textarea>
    </div>
</template>
