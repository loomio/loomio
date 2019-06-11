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
    coverUrl: "https://loomio-uploads.s3.amazonaws.com/groups/cover_photos/000/000/002/largedesktop/IMG_6150.JPG?1551260138"
    discussion: null
    activePolls: []
    requestedSequenceId: 0
    loader: null

  created: -> @init()

  watch:
    $route: 'init'
    discussion: (currentDiscussion, prevDiscussion) ->
      @init() if prevDiscussion && currentDiscussion && (currentDiscussion.id != prevDiscussion.id)

  methods:
    init: ->
      @discussion = Records.discussions.findOrNull(@$route.params.key)

      @requestedSequenceId = parseInt(@$route.params.sequence_id)
      @requestedCommentId = parseInt(@$route.params.comment_id)

      @loader = new RecordLoader
        collection: 'events'
        params:
          discussion_id: @$route.params.key
          from: @requestedSequenceId
          comment_id: @requestedCommentId
          order: 'sequence_id'
          per: @per


      @loader.fetchRecords().then =>
        Records.discussions.findOrFetchById(@$route.params.key).then (discussion) =>
          @discussion = discussion

          if @requestedCommentId
            @requestedSequenceId = Records.events.find(
              discussionId: @discussion.id
              kind: 'new_comment'
              eventableId: @requestedCommentId
              )[0].sequenceId

          if @requestedSequenceId
            @discussion.update({requestedSequenceId: @requestedSequenceId})

          @discussion.markAsSeen()

          # Records.documents.fetchByDiscussion(@discussion)

          @watchRecords
            key: @discussion.id
            collections: ["polls"]
            query: (records) =>
              @activePolls = @discussion.activePolls() if @discussion

          if @discussion.forkedEvent()
            Records.discussions.findOrFetchById(@discussion.forkedEvent().discussionId, simple: true)

          EventBus.$emit 'currentComponent',
            page: 'threadPage'
            breadcrumbs: compact([@discussion.group().parent(), @discussion.group(), @discussion])

      # , (error) =>
      #   debugger
      #   EventBus.$emit 'pageError', error
</script>

<template lang="pug">
loading(:until="discussion")
  group-cover-image(:group="discussion.group()")
  v-container.thread-page(grid-list-lg)
    discussion-fork-actions(:discussion='discussion', v-show='discussion.isForking()')
    //- .thread-page__main-content(:class="{'thread-page__forking': discussion.isForking()}")
    v-layout
      v-flex(md8)
        thread-card(:loader='loader' :discussion='discussion')
      v-flex(md4)
        v-layout(column)
          v-flex(v-for="poll in activePolls", :key="poll.id")
            poll-common-card(:poll="poll")
          v-flex
            decision-tools-card(:discussion='discussion')
          v-flex
            membership-card(:group='discussion.guestGroup()')
          v-flex
            membership-card(:group='discussion.guestGroup()', :pending='true')
          v-flex
            poll-common-index-card(:model='discussion')
</template>
