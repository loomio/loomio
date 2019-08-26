<script lang="coffee">
import LmoUrlService     from '@/shared/services/lmo_url_service'
import Session           from '@/shared/services/session'
import Records           from '@/shared/services/records'
import RecordLoader      from '@/shared/services/record_loader'
import EventBus          from '@/shared/services/event_bus'
import AbilityService    from '@/shared/services/ability_service'
import WatchRecords from '@/mixins/watch_records'

import { registerKeyEvent } from '@/shared/helpers/keyboard'
import {compact} from 'lodash'

export default
  mixins: [WatchRecords]

  data: ->
    discussion: null
    activePolls: []
    per: 25
    threadPercentage: 0

  created: -> @init()

  watch:
    '$route.params.key': 'init'
    '$route.params.comment_id': 'init'

  methods:
    openThreadNav: -> EventBus.$emit('toggleThreadNav')

    init: ->
      EventBus.$on 'threadPositionUpdated', (position) =>
        @threadPercentage = parseInt(position / @discussion.createdEvent().childCount * 100)

      Records.discussions.findOrFetchById(@$route.params.key).then (discussion) =>
          @discussion = discussion
          EventBus.$emit 'currentComponent',
            page: 'threadPage'
            discussion: @discussion
            group: @discussion.group()

            title: @discussion.title
      ,
        (error) -> EventBus.$emit 'pageError', error


</script>

<template lang="pug">
loading(:until="discussion")
  v-container.thread-page.max-width-800(v-if="discussion")
    thread-current-poll-banner(:discussion="discussion")
    discussion-fork-actions(:discussion='discussion', v-show='discussion.isForking()')
    thread-card(:discussion='discussion' :key="discussion.id")
    v-btn.thread-page__open-thread-nav(fab fixed bottom right @click="openThreadNav()")
      v-progress-circular(color="accent" :value="threadPercentage")
</template>
