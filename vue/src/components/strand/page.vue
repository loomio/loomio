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
      # .catch (error) =>
      #   EventBus.$emit 'pageError', error
      #   EventBus.$emit 'openAuthModal' if error.status == 403 && !Session.isSignedIn()

    respondToRoute: ->
      # return unless @discussion
      # return if @discussion.key != @$route.params.key
      # return if @discussion.createdEvent.childCount == 0
      # @loader.reset()
      #
      # rules = []
      #
      # if @$route.params.comment_id
      #   rules.push
      #     name: "comment from url"
      #     local:
      #       discussionId: @discussion.id
      #       commentId: {$gte: parseInt(@$route.params.comment_id)}
      #     remote:
      #       order: 'sequence_id'
      #       discussion_id: @discussion.id
      #       comment_id: @$route.params.comment_id
      #
      # if @$route.query.p
      #   rules.push
      #     name: "position from url"
      #     local:
      #       discussionId: @discussion.id
      #       depth: 1
      #       position: {$gte: parseInt(@$route.query.p)}
      #     remote:
      #       discussion_id: @discussion.id
      #       from_sequence_id_of_position: @$route.query.p
      #       order: 'sequence_id'
      #
      # if @$route.params.sequence_id
      #   rules.push
      #     name: "sequenceId from url"
      #     local:
      #       discussionId: @discussion.id
      #       sequenceId: {$gte: parseInt(@$route.params.sequence_id)}
      #     remote:
      #       from: parseInt(@$route.params.sequence_id)
      #       order: 'sequence_id'
      #
      # if rules.length == 0
      #   # never read, or all read?
      #   if @discussion.lastReadAt == null or @discussion.unreadItemsCount() == 0
      #     if @discussion.newestFirst
      #       rules.push
      #         name: 'first time newest first'
      #         local:
      #           discussionId: @discussion.id
      #           position: {$gte: @discussion.createdEvent.childCount - 10}
      #         remote:
      #           discussion_id: @discussion.id
      #           from_sequence_id_of_position: @discussion.createdEvent.childCount - 10
      #           order: 'sequence_id'
      #     else
      #       rules.push
      #         name: 'context'
      #         local:
      #           id: @discussion.createdEvent().id
      #       rules.push
      #         name: 'first time oldest first'
      #         local:
      #           discussionId: @discussion.id
      #           sequenceId: {$gte: 1}
      #         remote:
      #           discussion_id: @discussion.id
      #           from_sequence_id_of_position: 1
      #           order: 'sequence_id'
      #   else
      #     # returning reader
      rules = []
      # if @discussion.updatedAt > @discussion.lastReadAt
      rules.push
        name: "context updated"
        local:
          id: @discussion.createdEvent().id



      # if @discussion.readItemsCount() > 0 && @discussion.unreadItemsCount() > 0
      rules.push
        name: "since last time"
        local:
          discussionId: @discussion.id
          sequenceId: {$gte: @discussion.firstUnreadSequenceId()}
        remote:
          discussion_id: @discussion.id
          from: @discussion.firstUnreadSequenceId()
          order: 'sequence_id'

      rules.forEach (rule) => @loader.addRule(rule)

</script>

<template lang="pug">
.strand-page
  v-main
    v-container.max-width-800(v-if="discussion")
      | {{loader.rules}}
      strand-card(v-if="loader" :discussion='discussion' :loader="loader")
</template>
