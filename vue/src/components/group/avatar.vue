<script lang="coffee">
export default
  props:
    group: Object
    size:
      default: '28px'
</script>

<template lang="pug">
v-avatar(:size="size" tile)
  img(:alt="group.name" src="https://www.loomio.org/theme/icon.png")
</template>
