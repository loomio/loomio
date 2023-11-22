<script lang="js">
import { ContainerMixin } from 'vue-slicksort';

export default
  ({mixins: [ContainerMixin]});
</script>
<template>

<div class="list" :transitionDuration="250" lockAxis="y">
  <slot></slot>
</div>
</template>
