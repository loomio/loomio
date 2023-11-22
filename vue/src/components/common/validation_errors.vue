<script lang="js">
export default {
  props: {
    subject: Object,
    field: String
  }
};
</script>

<template>

<div class="lmo-validation-error">
  <div class="lmo-validation-error__message error--text caption" v-if="subject.errors[field]" for="field + '-error'"><span role="status" aria-live="polite">{{subject.errors[field].join(', ')}}</span></div>
</div>
</template>
<style lang="sass">
.lmo-validation-error__message
	position: relative
	margin-top: -16px

</style>
