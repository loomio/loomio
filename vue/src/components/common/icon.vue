<script lang="js">
export default {
  props: {
    color: {
      type: String,
      default: undefined
    },
    dense:  {
      type: Boolean,
      default: false
    },
    disabled:  {
      type: Boolean,
      default: false
    },
    large:  {
      type: Boolean,
      default: false
    },
    left:  {
      type: Boolean,
      default: false
    },
    light:  {
      type: Boolean,
      default: false
    },
    right:  {
      type: Boolean,
      default: false
    },
    size: {
      type: [Number, String],
      default: undefined
    },
    small: {
      type: Boolean,
      default: false
    },
    tag: String,
    XLarge:  {
      type: Boolean,
      default: false
    },
    XSmall: {
      type: Boolean,
      default: false
    },
    name: String
  }
};
</script>

<template lang="pug">
v-icon(
  color="color"
  :dense="dense"
  :large="large"
  :left="left"
  :light="light"
  :right="right"
  :small="small"
  :tag="tag"
  :x-large="XLarge"
  :x-small="XSmall"
  :size="size"
) {{name}}
</template>
