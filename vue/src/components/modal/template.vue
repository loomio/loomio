<script lang="coffee">
export default
  props:
    title: String
</script>

<template lang="pug">
span {{title}}
  slot(name="content")
  slot(name="actions")
</template>
