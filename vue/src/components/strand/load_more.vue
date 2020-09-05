<script lang="coffee">
export default
  props:
    label: Object
</script>

<template lang="pug">
.strand-item__load-more
  v-btn.action-button(text block depressed v-t="label" @click="$emit('click')")
</style>
