<script lang="coffee">
export default
  props:
    onClick: {
      type: Function
      default: null
    }
    elevation: {
      type: Number
      default: 0
    }
    group: Object
    size:
      default: '28px'
</script>

<template lang="pug">
v-avatar(:size="size" tile :class="'elevation-' + elevation")
  img(:alt="group.name" :src="group.logoUrl() || 'https://www.loomio.org/theme/icon.png'" @click="onClick()")
</template>
