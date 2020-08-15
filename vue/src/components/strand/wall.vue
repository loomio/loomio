<script lang="coffee">
import ThreadLoader from '@/shared/loaders/thread_loader'
import RangeSet from '@/shared/services/range_set'
import { camelCase, first, last, some } from 'lodash-es'

export default
  props:
    threads: Array

  data: ->
    loaders: []

  mounted: ->
    @threads.forEach (thread) =>
      loader = new ThreadLoader(thread)
      loader.addLoadUnreadRule()
      loader.fetch()
      @loaders.push(loader)

</script>

<template lang="pug">
.strand-wall
  v-card(v-for="loader in loaders" :key="loader.id")
    strand-card(:loader="loader")
</template>

<style lang="sass">
.strand-wall
  cool: 1
</style>
