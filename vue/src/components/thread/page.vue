<script lang="coffee">
import Records           from '@/shared/services/records'
import Session           from '@/shared/services/session'
import EventBus          from '@/shared/services/event_bus'
import AbilityService    from '@/shared/services/ability_service'
import { first, last } from 'lodash'
import ahoy from 'ahoy.js'

export default
  data: ->
    discussion: null
    threadPercentage: 0
    position: 0
    group: null
    discussionFetchError: null

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
      Records.samlProviders.authenticateForDiscussion(@$route.params.key)
      Records.discussions.findOrFetchById(@$route.params.key, exclude_types: 'poll outcome')
      .then (discussion) =>
        @discussion = discussion
        ahoy.trackView
          discussionId: @discussion.id
          groupId: @discussion.groupId
          organisationId: @discussion.group().parentOrSelf().id
          pageType: 'threadPage'
        EventBus.$emit 'currentComponent',
          page: 'threadPage'
          discussion: @discussion
          group: @discussion.group()
          title: @discussion.title
      .catch (error) =>
        EventBus.$emit 'pageError', error
        EventBus.$emit 'openAuthModal' if error.status == 403 && !Session.isSignedIn()

</script>

<template lang="pug">
.thread-page
  v-content
    loading(:until="discussion")
      v-container.thread-page.max-width-800(v-if="discussion")
        thread-current-poll-banner(:discussion="discussion")
        discussion-fork-actions(:discussion='discussion' :key="'fork-actions'+ discussion.id")
        thread-card(:discussion='discussion' :key="discussion.id")
        v-btn.thread-page__open-thread-nav(fab fixed bottom right @click="openThreadNav()")
          v-progress-circular(color="accent" :value="threadPercentage")

  router-view(name="nav")
</template>
