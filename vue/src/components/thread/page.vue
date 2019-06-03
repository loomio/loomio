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

export default
  mixins: [WatchRecords]
  data: ->
    discussion: null
    activePolls: []
    requestedSequenceId: 0
    loader: null

  created: -> @init()

  watch:
    $route: 'init'

  methods:
    init: ->
      @requestedSequenceId = parseInt(@$route.params.sequence_id)
      @requestedCommentId = parseInt(@$route.params.comment_id)

      Records.discussions.findOrFetchById(@$route.params.key).then (discussion) =>
        @discussion = discussion

      @loader = new RecordLoader
        collection: 'events'
        params:
          discussion_id: @$route.params.key
          from: @requestedSequenceId
          comment_id: @requestedCommentId
          order: 'sequence_id'
          per: @per

      @loader.fetchRecords().then =>
        if @requestedCommentId
          @discussion.requestedSequenceId = Records.events.find(
            discussionId: discussion.id
            kind: 'new_comment'
            eventableId: @requestedCommentId
            ).sequenceId

        if @requestedSequenceId
          @discussion.requestedSequenceId = @requestedSequenceId

        @discussion.markAsSeen()

        # Records.documents.fetchByDiscussion(@discussion)

        @watchRecords
          key: @discussion.id
          collections: ["polls"]
          query: (records) =>
            @activePolls = @discussion.activePolls()

        if @discussion.forkedEvent()
          Records.discussions.findOrFetchById(@discussion.forkedEvent().discussionId, simple: true)

        EventBus.$emit 'currentComponent',
          title: @discussion.title
          page: 'threadPage'
          group: @discussion.group()
          discussion: @discussion

      , (error) ->
        EventBus.$emit 'pageError', error
</script>

<template lang="pug">
v-container.lmo-main-container.thread-page(grid-list-lg)
  loading(v-if='!discussion')
  div(v-if='discussion')
    group-theme(:group='discussion.group()', :compact='true')
    discussion-fork-actions(:discussion='discussion', v-show='discussion.isForking()')
    //- .thread-page__main-content(:class="{'thread-page__forking': discussion.isForking()}")
    v-layout
      v-flex(md8)
        thread-card(:loader='loader' :discussion='discussion')
      v-flex(md4)
        v-layout(column)
          // <outlet name="before-thread-page-column-right" model="discussion" class="before-column-right lmo-column-right"></outlet>
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
          // <outlet name="thread-page-column-right" class="after-column-right lmo-column-right"></outlet>
</template>
<style lang="scss">
@import 'variables';
@import 'boxes';
.thread-notification-level {
  display: inline-block;
}

.thread-group{
  margin: 14px 22px;
  padding-top: 10px;
}

.thread-group__name a{
  font-weight: bold;
  color: $grey-on-grey;
  line-height: 30px;
}

.thread-group__icon img{
  @include smallIcon;
}

.thread-page__forking .action-dock {
  visibility: hidden;
}

.attachments {
  margin: 0 10px;
}

.attachment-new {
  width: 34px;
  height: 34px;
  border: 1px solid $border-color;
  @include roundedCorners;
}

.attachment-new input {
  width: 34px;
  opacity: 0;
  padding: 5px;
  cursor: pointer;
  display: block;
  overflow: hidden;
}

.cover-file-upload {
  pointer-events: none;
  position: relative;
  bottom: 38px;
  padding: 0px;
  left: 4px;
}

.progress.active {
  float: left;
}

@media (min-width: $small-max-px) {
  .lmo-column-left {
    display: inline-block;
    width: 52%;
  }

  .lmo-column-right {
    float: right;
    clear: right;
    width: calc(48% - 10px);
  }
}

@media (min-width: $medium-max-px) {
  .lmo-column-left {
    display: inline-block;
    width: 60%;
  }

  .lmo-column-right {
    float: right;
    clear: right;
    width: calc(40% - 10px);
  }
}

@media (max-width: $small-max-px) {
  .thread-page__main-content {
    display: flex;
    flex-direction: column;
  }
  .context-panel           { order: 10; }

  .poll-common-card        { order: 20; }
  .activity-card           { order: 30; }

  .comment-form            { order: 40; }
  .decision-tools-card     { order: 50; }
  membership_card          { order: 55; }
  .poll-common-index-card  { order: 60; }
  .document-card           { order: 75; }
  .before-column-right     { order: 80; }
  .after-column-right      { order: 90; }
}
</style>
