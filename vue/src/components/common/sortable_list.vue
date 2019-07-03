<script lang="coffee">
import { ContainerMixin } from 'vue-slicksort'

export default
  mixins: [ContainerMixin]
</script>
<template lang="pug">
v-list.list
  slot
</template>
