<script lang="js">
export default{
  props: {
    elevation: {
      type: Number,
      default: 0
    },
    group: Object,
    size: {
      type: Number,
      default: 24
    }
  }
};
</script>

<template lang="pug">
v-avatar(:size="size" tile @click="$emit('click')")
  v-img(:alt="group.name" cover v-if="group.logoUrl" :src="group.logoUrl")
  common-icon(v-if="!group.logoUrl" name="mdi-account-group")
</template>
