<script lang="coffee">
import LmoUrlService     from '@/shared/services/lmo_url_service'
import Session           from '@/shared/services/session'
import Records           from '@/shared/services/records'
import RecordLoader      from '@/shared/services/record_loader'
import EventBus          from '@/shared/services/event_bus'
import AbilityService    from '@/shared/services/ability_service'
import PaginationService from '@/shared/services/pagination_service'
import WatchRecords from '@/mixins/watch_records'

import { scrollTo }         from '@/shared/helpers/layout'
import { registerKeyEvent } from '@/shared/helpers/keyboard'
import {compact} from 'lodash'
export default
  mixins: [WatchRecords]
  data: ->
    discussion: null
    activePolls: []
    loader: null
    per: 25

  created: -> @init()

  watch:
    '$route.params.key': 'init'

  methods:
    init: ->
      @discussion = Records.discussions.findOrNull(@$route.params.key)

      @loader = new RecordLoader
        collection: 'events'
        params:
          discussion_id: @$route.params.key
          from: parseInt(@$route.params.sequence_id)
          comment_id: parseInt(@$route.params.comment_id)
          order: 'sequence_id'
          per: @per

      @loader.fetchRecords().then =>
        @discussion = Records.discussions.findOrNull(@$route.params.key)

        if @discussion.forkedEvent()
          Records.discussions.findOrFetchById(@discussion.forkedEvent().discussionId)

        EventBus.$emit 'currentComponent',
          page: 'threadPage'
          discussion: @discussion
          breadcrumbs: compact([@discussion.group().parent(), @discussion.group(), @discussion])
</script>

<template lang="pug">
loading(:until="discussion")
  div(v-if="discussion")
    group-cover-image(:group="discussion.group()")
    v-container.thread-page(style="max-width: 800px")
      discussion-fork-actions(:discussion='discussion', v-show='discussion.isForking()')
      thread-card(:loader='loader' :discussion='discussion')
</template>
