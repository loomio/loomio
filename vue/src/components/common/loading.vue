<script lang="js">
export default {
  props: {
    until: null,
    diameter: {
      type: Number,
      default: 30
    }
  }
}
</script>

<template>

<div>
  <v-layout class="my-4 page-loading" justify-center="justify-center" v-if="!until">
    <v-progress-circular indeterminate="indeterminate" color="primary"></v-progress-circular>
  </v-layout>
  <slot v-if="until"></slot>
</div>
</template>
