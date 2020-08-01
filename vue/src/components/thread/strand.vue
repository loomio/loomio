<script lang="coffee">
# import Records from '@/shared/services/records'
# import EventBus from '@/shared/services/event_bus'

export default
  props:
    collection: Array
    focalEvent: Object

  methods:
    componentForKind: (kind) ->
      camelCase if ['stance_created', 'new_comment', 'outcome_created', 'poll_created'].includes(kind)
        kind
      else
        'thread_item'
</script>

<template lang="pug">
.thread-strand
  component(v-for="obj in collection" :is="componentForKind(obj.event.kind)" :event='obj.event')
  thread-strand(v-if='obj.children.length' :focal-event='focalEvent')
</template>
