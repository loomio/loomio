<script lang="coffee">
module.exports =
  props:
    query: Object
    limit:
      type: Number
      default: 25
    order:
      type: String
      default: '-lastActivityAt'
  data: ->
    threads: @query.threads()
  computed:
    orderedThreads: ->
      _.slice(_.orderBy(@threads, @order), 0, @limit)
</script>

<template lang="pug">
v-list.thread-previews(two-line)
  thread-preview(v-for="thread in orderedThreads", :key="thread.id", :thread="thread")
</template>
