<script lang="coffee">
import Records           from '@/shared/services/records'
import Session           from '@/shared/services/session'
import EventBus          from '@/shared/services/event_bus'
import AbilityService    from '@/shared/services/ability_service'
import ThreadLoader      from '@/shared/loaders/thread_loader'

import ahoy from 'ahoy.js'

export default
  data: ->
    discussion: null
    loader: null
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

        @watchRecords
          key: 'strand'+@discussion.id
          collections: ['events']
          query: => @loader.updateCollection()
      # .catch (error) =>
      #   EventBus.$emit 'pageError', error
      #   EventBus.$emit 'openAuthModal' if error.status == 403 && !Session.isSignedIn()

    respondToRoute: ->
      return unless @discussion
      return if @discussion.key != @$route.params.key
      return if @discussion.createdEvent.childCount == 0
      @loader.reset()

      rules = []

      # @loader.addLoadPinnedRule()
      if @$route.params.comment_id
        @loader.addLoadCommentRule(parseInt(@$route.params.comment_id))

      if @$route.query.p
        @loader.addLoadPositionRule(parseInt(@$route.params.comment_id))

      if @$route.params.sequence_id
        @loader.addLoadSequenceIdRule(@$route.params.sequence_id)

      if rules.length == 0
        # # never read, or all read?
        # # console.log "0 rules"
        # console.log "ranges", @discussion.ranges
        # console.log "readRanges", @discussion.readRanges
        # console.log "@discussion.unreadItemsCount()", @discussion.unreadItemsCount()
        if @discussion.lastReadAt
          if @discussion.unreadItemsCount() == 0
            @loader.addLoadNewestFirstRule()
          else
            @loader.addLoadUnreadRule()
        else
          if @discussion.newestFirst
            @loader.addLoadNewestFirstRule()
          else
            @loader.addLoadOldestFirstRule()

      @loader.fetch()

</script>

<template lang="pug">
.strand-page
  v-main
    v-container.max-width-800(v-if="discussion")
      strand-nav(v-if="loader" :discussion="discussion" :loader="loader")
      strand-card(v-if="loader" :discussion='discussion' :loader="loader")
</template>
