<script lang="coffee">
import Records           from '@/shared/services/records'
import Session           from '@/shared/services/session'
import EventBus          from '@/shared/services/event_bus'
import AbilityService    from '@/shared/services/ability_service'
import ThreadLoader      from '@/shared/loaders/thread_loader'
import ahoy from '@/shared/services/ahoy'

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
    '$route.query.k': 'respondToRoute'

  methods:
    init: ->
      Records.samlProviders.authenticateForDiscussion(@$route.params.key)
      Records.discussions.findOrFetchById(@$route.params.key, exclude_types: 'poll outcome')
      .then (discussion) =>
        window.location.host = discussion.group().newHost if discussion.group().newHost
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
      .catch (error) =>
        EventBus.$emit 'pageError', error
        EventBus.$emit 'openAuthModal' if error.status == 403 && !Session.isSignedIn()

    respondToRoute: ->
      return unless @discussion
      return if @discussion.key != @$route.params.key
      return if @discussion.createdEvent.childCount == 0
      @loader.reset()

      if @$route.query.k
        @loader.addLoadPositionKeyRule(@$route.query.k)
        @loader.focusAttrs = {positionKey: @$route.query.k}

      if @$route.query.p
        @loader.addLoadPositionRule(parseInt(@$route.params.p))
        @loader.focusAttrs = {position: @$route.query.p}

      if @$route.params.sequence_id
        @loader.addLoadSequenceIdRule(parseInt(@$route.params.sequence_id))
        @loader.focusAttrs = {sequenceId: parseInt(@$route.params.sequence_id)}

      if @$route.query.comment_id
        @loader.addLoadCommentRule(parseInt(@$route.params.comment_id))
        @loader.focusAttrs = {commentId: parseInt(@$route.query.comment_id)}

      if @loader.rules.length == 0
        # # never read, or all read?
        # # console.log "0 rules"
        # console.log "ranges", @discussion.ranges
        # console.log "readRanges", @discussion.readRanges
        # console.log "@discussion.unreadItemsCount()", @discussion.unreadItemsCount()
        if @discussion.lastReadAt
          if @discussion.unreadItemsCount() == 0
            @loader.addLoadNewestRule()
            @loader.focusAttrs = {newest: 1}
          else
            @loader.addLoadUnreadRule()
            @loader.focusAttrs = {unread: 1}
        else
          @loader.addLoadOldestRule()
          @loader.focusAttrs = {oldest: 1}

      @loader.addContextRule()
      # @loader.addLoadPinnedRule()
      if @discussion.itemsCount <= @loader.padding
        @loader.rules = []
        @loader.loadEverything()

      # console.log 'fetching', @loader.focusAttrs
      @loader.fetch().finally =>
        setTimeout =>
          if @loader.focusAttrs.newest
            if @discussion.lastSequenceId()
              @scrollTo ".sequenceId-#{@discussion.lastSequenceId()}"
            else
              @scrollTo ".context-panel"

          if @loader.focusAttrs.unread
            # how do we know when the context was updated?
            if @loader.firstUnreadSequenceId()
              # console.log 'scroll to unread items'
              @scrollTo ".sequenceId-#{@loader.firstUnreadSequenceId()}"
            else
              # console.log 'scroll to unread context'
              @scrollTo '.context-panel'

          if @loader.focusAttrs.oldest
            # console.log 'scroll to oldest, context'
            @scrollTo '.context-panel'

          if @loader.focusAttrs.commentId
            # console.log 'scroll to comment'
            @scrollTo ".commendId-#{@loader.focusAttrs.commentId}"

          if @loader.focusAttrs.sequenceId
            # console.log 'scroll to sequenceId'
            @scrollTo ".sequenceId-#{@loader.focusAttrs.sequenceId}"

          if @loader.focusAttrs.position
            @scrollTo ".position-#{@loader.focusAttrs.position}"

          if @loader.focusAttrs.positionKey
            @scrollTo ".positionKey-#{@loader.focusAttrs.positionKey}"
      .catch (res) =>
        console.log 'promises failed', res

</script>

<template lang="pug">
.strand-page
  v-main
    v-container.max-width-800(v-if="discussion")
      //- p(v-for="rule in loader.rules") {{rule}}
      //- p loader: {{loader.focusAttrs}}
      //- p ranges: {{discussion.ranges}}
      //- p read ranges: {{loader.readRanges}}
      //- p first unread {{loader.firstUnreadSequenceId()}}
      //- p test: {{rangeSetSelfTest()}}
      thread-current-poll-banner(:discussion="discussion")
      discussion-fork-actions(:discussion='discussion' :key="'fork-actions'+ discussion.id")
      strand-card(v-if="loader" :discussion='discussion' :loader="loader")
  strand-nav(v-if="loader" :discussion="discussion" :loader="loader")
</template>
