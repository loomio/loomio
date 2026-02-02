<script lang="js">
export default {
  props: {
    subject: Object,
    field: String
  }
};
</script>

<template lang="pug">
.lmo-validation-error.mt-n4.mb-4
  .lmo-validation-error__message.error--text.text-body-small(v-if="subject.errors[field]" for="field + '-error'")
    span(role="status" aria-live="polite") {{subject.errors[field].join(', ')}}
</template>

<style lang="sass">
.lmo-validation-error
  color: rgb(var(--v-theme-error))

.lmo-validation-error__message
  position: relative
</style>
