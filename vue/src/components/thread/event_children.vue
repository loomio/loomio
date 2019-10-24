<script lang="coffee">
import AppConfig         from '@/shared/services/app_config'
import RecordLoader from '@/shared/services/record_loader'

import { debounce, first, last } from 'lodash'

export default
  props:
    parentEvent: Object
    discussion: Object

  data: ->
    initialSlots: [1]

  created: ->
    @loader = new RecordLoader
      collection: 'events'

  methods:
    fetch: (slots) ->
      # console.log "fetch parent pid #{@parentEvent.id}, missing: #{slots}"
      return unless slots.length
      @loader.fetchRecords(
        comment_id: null
        from_unread: null
        discussion_id: @parentEvent.discussionId
        parent_id: @parentEvent.id
        order: 'position'
        from: first(slots)
        per: (last(slots) - first(slots))+1)

  computed:
    negativeMargin: ->
      if @$vuetify.breakpoint.xsOnly
        {'margin-left': '-64px'}
      else
        {}
</script>

<template lang="pug">
.event-children
  thread-renderer(:style="negativeMargin" :discussion="discussion" :parent-event="parentEvent" :fetch="fetch" :initial-slots="initialSlots")
</template>
