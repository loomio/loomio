<script lang="coffee">
import Records           from '@/shared/services/records'
import EventBus          from '@/shared/services/event_bus'
import AbilityService    from '@/shared/services/ability_service'
import { first, last } from 'lodash'

export default
  data: ->
    discussion: null
    threadPercentage: 0
    position: 0

  created: ->
    EventBus.$on 'visibleSlots', (slots) =>
      return unless @discussion
      unless slots.length == 0
        @position = if @discussion.newestFirst
          last(slots) || @discussion.createdEvent().childCount
        else
          last(slots) || 1
        @threadPercentage = @position / @discussion.createdEvent().childCount * 100

  mounted: -> @init()

  watch:
    '$route.params.key': 'init'
    '$route.params.comment_id': 'init'

  methods:
    openThreadNav: -> EventBus.$emit('toggleThreadNav')

    init: ->
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
.thread-page
  v-content
    loading(:until="discussion")
      v-container.thread-page.max-width-800(v-if="discussion")
        thread-current-poll-banner(:discussion="discussion")
        discussion-fork-actions(:discussion='discussion' v-show='discussion.isForking' :key="'fork-actions'+ discussion.id")
        thread-card(:discussion='discussion' :key="discussion.id")
        v-btn.thread-page__open-thread-nav(fab fixed bottom right @click="openThreadNav()")
          v-progress-circular(color="accent" :value="threadPercentage")

  router-view(name="nav")
</template>
