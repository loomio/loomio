<script lang="coffee">
export default
  props:
    result: Object
</script>

<template lang="pug">
v-list-item.thread-preview.thread-preview__link(:to="urlFor(result)")
  v-list-item-content
    v-list-item-title {{result.title}}
    v-list-item-subtitle
      span(v-html="result.resultGroupName")
      | &nbsp;
      | ·
      | &nbsp;
      time-ago(:date='result.lastActivityAt')
      | &nbsp;
      | ·
      | &nbsp;
      span(v-html="result.blurb")
</template>
