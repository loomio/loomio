<script lang="coffee">
import AppConfig         from '@/shared/services/app_config'
import RecordLoader from '@/shared/services/record_loader'

import { debounce, first, last } from 'lodash-es'

export default
  components:
    ThreadRenderer: -> import('@/components/thread/renderer.vue')

  props:
    parentEvent: Object
    focalEvent: Object
    isReturning: Boolean

  created: ->
    @loader = new RecordLoader
      collection: 'events'

  methods:
    fetch: (slots) ->
      # console.log "fetch parent pid #{@parentEvent.id}, missing: #{slots}"
      return unless slots.length
      @loader.fetchRecords(
        exclude_types: 'group discussion'
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
  thread-renderer(:parent-event="parentEvent" :fetch="fetch" :focal-event="focalEvent" :is-returning="isReturning")
</template>
