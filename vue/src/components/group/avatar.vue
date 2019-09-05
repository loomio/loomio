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
  img(:alt="group.name" v-if="group.logoUrl()" :src="group.logoUrl()" @click="onClick()")
  v-icon(v-if="!group.logoUrl()") mdi-group
</template>
