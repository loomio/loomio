<script lang="coffee">
export default
  props:
    label: Object
</script>

<template lang="pug">
.strand-item__load-more
  v-btn.action-button(text block outlined @click="$emit('click')")
    v-icon(size="20") mdi-unfold-more-horizontal
    span(v-t="label")
</style>
