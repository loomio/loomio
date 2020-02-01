<script lang="coffee">
import { convertToHtml } from '@/shared/services/format_converter'

export default
  props:
    model: Object
    field: String
    label: String
    placeholder: String
    shouldReset: Boolean
    maxLength: Number
    autoFocus:
      type: Boolean
      default: false
  methods:
    convertToHtml: convertToHtml
</script>

<template lang="pug">
div
  v-textarea(v-model="model[field]")
  v-btn(@click="convertToHtml(model, field)") HTML
  slot(name="actions")
</template>
