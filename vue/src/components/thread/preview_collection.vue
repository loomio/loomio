<script lang="coffee">
import {slice, orderBy} from 'lodash'

export default
  props:
    threads: Array
    limit:
      type: Number
      default: 25
    order:
      type: String
      default: '-lastActivityAt'

  computed:
    orderedThreads: ->
      slice(orderBy(@threads, @order), 0, @limit)

</script>

<template lang="pug">
v-list.thread-previews(three-line)
  thread-preview(v-for="thread in orderedThreads", :key="thread.id", :thread="thread")
</template>
