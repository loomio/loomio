<script lang="coffee">
import { ContainerMixin } from 'vue-slicksort'

export default
  mixins: [ContainerMixin]
</script>
<template lang="pug">
v-list.list(:transitionDuration="250" :lockAxis="'y'")
  slot
</template>
