<script lang="coffee">
import { ContainerMixin } from 'vue-slicksort'

export default
  mixins: [ContainerMixin]
</script>
<template lang="pug">
.list(:transitionDuration="250" lockAxis="y")
  slot
</template>
