<style lang="scss">
.lmo-validation-error__message {
  display: block;
}

md-input-container label.lmo-validation-error__message {
  font-size: 11px;
  // color: $highlight-red !important;
}

</style>

<script lang="coffee">
module.exports =
  props:
    subject: Object
    field: String
</script>

<template>
    <div class="lmo-validation-error">
      <label v-if="subject.errors[field]" for="field + '-error'" class="md-container-ignore md-no-float lmo-validation-error__message">
        <span>{{subject.errors[field].join(', ')}}</span>
      </label>
    </div>
</template>
