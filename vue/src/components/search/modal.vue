<script lang="coffee">
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import Flash   from '@/shared/services/flash'

export default
  props:
    group: Object
    discussion: Object

  data: ->
    query: null

  methods:
    fetch: ->
      Records.remote.get('search', query: @query).then (data) =>
        console.log "data:", data



</script>
<template lang="pug">
v-card.search-modal
  .d-flex
    v-text-field(v-model="query" placeholder="search for something", @change="fetch")

</template>
