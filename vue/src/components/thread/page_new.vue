<script lang="coffee">
import Records           from '@/shared/services/records'
import Session           from '@/shared/services/session'
import EventBus          from '@/shared/services/event_bus'
import AbilityService    from '@/shared/services/ability_service'
import ThreadLoader      from '@/shared/loaders/thread_loader'
import { first, last } from 'lodash-es'
import ahoy from 'ahoy.js'

export default
  data: ->
    discussion: null
    loader: null
    threadPercentage: 0
    position: 0
    group: null
    discussionFetchError: null

  mounted: -> @init()

  watch:
    '$route.params.key': 'init'
    '$route.params.comment_id': 'init'
    '$route.params.sequence_id': 'respondToRoute'
    '$route.params.comment_id': 'respondToRoute'
    '$route.query.p': 'respondToRoute'

  methods:
    init: ->
      Records.samlProviders.authenticateForDiscussion(@$route.params.key)
      Records.discussions.findOrFetchById(@$route.params.key, exclude_types: 'poll outcome')
      .then (discussion) =>
        @discussion = discussion
        @loader = new ThreadLoader(@discussion)
        @respondToRoute()
        ahoy.trackView
          discussionId: @discussion.id
          groupId: @discussion.groupId
          organisationId: @discussion.group().parentOrSelf().id
          pageType: 'threadPage'
        EventBus.$emit 'currentComponent',
          focusHeading: false
          page: 'threadPage'
          discussion: @discussion
          group: @discussion.group()
          title: @discussion.title
      .catch (error) =>
        EventBus.$emit 'pageError', error
        EventBus.$emit 'openAuthModal' if error.status == 403 && !Session.isSignedIn()

    respondToRoute: ->
      return unless @discussion
      return if @discussion.key != @$route.params.key
      return if @discussion.createdEvent.childCount == 0
      @loader.reset()

      console.log "heeelloo"
      args = if parseInt(@$route.params.comment_id)
        {column: 'commentId', id: parseInt(@$route.params.comment_id)}
      else if parseInt(@$route.query.p)
        {column: 'position', id: parseInt(@$route.query.p)}
      else if parseInt(@$route.params.sequence_id)
        {column: 'sequenceId', id: parseInt(@$route.params.sequence_id)}
      else
        # new to me
        if @discussion.readItemsCount() > 0 && @discussion.unreadItemsCount() > 0
          {column: 'sequenceId', id: @discussion.firstUnreadSequenceId()}
        else
          # latest
          if @discussion.newestFirst
            {column: 'position', id: @parentEvent.childCount}
          else
            # beginning
            {column: 'position', id: 1}
      
      @loader.request(args).then (event) =>
        if event
          @focalEvent = event
        else
          Flash.error('thread_context.item_maybe_deleted')

</script>

<template lang="pug">
.thread-page
  v-main
    h1.title hi
    v-container.thread-page.max-width-800(v-if="discussion")
      thread-current-poll-banner(:discussion="discussion")
      discussion-fork-actions(:discussion='discussion' :key="'fork-actions'+ discussion.id")
      thread-card-new(v-if="loader" :discussion='discussion' :loader="loader")
      v-btn.thread-page__open-thread-nav(fab fixed bottom right @click="openThreadNav()")
        v-progress-circular(color="accent" :value="threadPercentage")

  router-view(name="nav")
</template>
