<script lang="coffee">
import Records           from '@/shared/services/records'
import Session           from '@/shared/services/session'
import EventBus          from '@/shared/services/event_bus'
import AbilityService    from '@/shared/services/ability_service'
import { first, last } from 'lodash-es'
import ahoy from 'ahoy.js'

export default
  data: ->
    discussion: null
    threadPercentage: 0
    position: 0
    group: null
    discussionFetchError: null

  mounted: -> @init()

  watch:
    '$route.params.key': 'init'
    '$route.params.comment_id': 'init'

  methods:
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
          focusHeading: false
          page: 'threadPage'
          discussion: @discussion
          group: @discussion.group()
          title: @discussion.title
      .catch (error) =>
        EventBus.$emit 'pageError', error
        EventBus.$emit 'openAuthModal' if error.status == 403 && !Session.isSignedIn()

    respondToRoute: ->
      return if @discussion.key != @$route.params.key
      return if @parentEvent.childCount == 0

      args = if parseInt(@$route.params.comment_id)
        {column: 'commentId', id: parseInt(@$route.params.comment_id)}
      else if parseInt(@$route.query.p)
        {column: 'position', id: parseInt(@$route.query.p)}
      else if parseInt(@$route.params.sequence_id)
        {column: 'sequenceId', id: parseInt(@$route.params.sequence_id)}
      else
        if @discussion.readItemsCount() > 0 && @discussion.unreadItemsCount() > 0
          {column: 'sequenceId', id: @discussion.firstUnreadSequenceId()}
        else
          if (@discussion.newestFirst && !@viewportIsBelow) || (!@discussion.newestFirst &&  @viewportIsBelow)
            {column: 'position', id: @parentEvent.childCount}
          else
            {column: 'position', id: 1}

      @fetchEvent(args.column, args.id).then (event) =>
        if event
          @focalEvent = event
          # @collection = prepareCollection()
        else
          Flash.error('thread_context.item_maybe_deleted')

    fetchEvent: (idType, id) ->
      if event = @findEvent(idType, id)
        Promise.resolve(event)
      else
        param = switch idType
          when 'sequenceId' then 'from'
          when 'commentId' then 'comment_id'
          when 'position' then 'from_sequence_id_of_position'

        @loader.fetchRecords(
          exclude_types: excludeTypes
          discussion_id: @discussion.id
          order: 'sequence_id'
          per: 20
          "#{param}": id
        ).then =>
          Promise.resolve(@findEvent(idType, id))

    findEvent: (column, id) ->
      return false unless isNumber(id)
      records = Records
      if id == 0
        @discussion.createdEvent()
      else
        args = switch camelCase(column)
          when 'position'
            discussionId: @discussion.id
            position: id
            depth: 1
          when 'sequenceId'
            discussionId: @discussion.id
            sequenceId: id
          when 'commentId'
            kind: 'new_comment'
            eventableId: id
        # console.log "finding: ", args
        Records.events.find(args)[0]

</script>

<template lang="pug">
.thread-page
  v-main
    loading(:until="discussion")
      v-container.thread-page.max-width-800(v-if="discussion" v-scroll="scrollThreadNav")
        thread-current-poll-banner(:discussion="discussion")
        discussion-fork-actions(:discussion='discussion' :key="'fork-actions'+ discussion.id")
        thread-card-new(:discussion='discussion' :focal-event="focalEvent" :collection="collection")
        v-btn.thread-page__open-thread-nav(fab fixed bottom right @click="openThreadNav()")
          v-progress-circular(color="accent" :value="threadPercentage")

  router-view(name="nav")
</template>
