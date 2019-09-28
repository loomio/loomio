<script lang="coffee">
import AppConfig         from '@/shared/services/app_config'
import RecordLoader from '@/shared/services/record_loader'

import { debounce, first, last } from 'lodash'

export default
  props:
    parentEvent: Object
    discussion: Object

  created: ->
    @loader = new RecordLoader
      collection: 'events'

  methods:
    fetch: (slots) ->
      return unless slots.length
      @loader.fetchRecords(
        comment_id: null
        from_unread: null
        discussion_id: @parentEvent.discussionId
        parent_id: @parentEvent.id
        order: 'position'
        from: first(slots)
        per: (last(slots) - first(slots))+1)

</script>

<template lang="pug">
.event-children
  thread-renderer(:discussion="discussion" :parent-event="parentEvent" :fetch="fetch")
</template>
