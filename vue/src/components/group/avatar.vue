<script lang="coffee">
export default
  props:
    elevation:
      type: Number
      default: 0
    group: Object
    size:
      type: Number
      default: 28
</script>

<template lang="pug">
v-avatar(:size="size" tile :class="'rounded elevation-' + elevation" @click="$emit('click')")
  img(:alt="group.name" v-if="group.logoUrl" :src="group.logoUrl")
  v-icon(v-if="!group.logoUrl") mdi-account-group
</template>
