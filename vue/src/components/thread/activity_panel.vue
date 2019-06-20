<script lang="coffee">
import AppConfig                from '@/shared/services/app_config'
import EventBus                 from '@/shared/services/event_bus'
import RecordLoader             from '@/shared/services/record_loader'
import ChronologicalEventWindow from '@/shared/services/chronological_event_window'
import NestedEventWindow        from '@/shared/services/nested_event_window'
import ModalService             from '@/shared/services/modal_service'
import AbilityService           from '@/shared/services/ability_service'
import Session from '@/shared/services/session'
import AuthModalMixin from '@/mixins/auth_modal'
import Records from '@/shared/services/records'
import WatchRecords from '@/mixins/watch_records'
import { print } from '@/shared/helpers/window'
import { compact } from 'lodash'
import RangeSet from '@/shared/services/range_set'

# window.Loomio.debug= 1
export default
  mixins: [ AuthModalMixin, WatchRecords ]
  props:
    loader: Object
    discussion: Object

  data: ->
    canAddComment: false
    per: AppConfig.pageSize.threadItems
    renderMode: 'nested'
    eventWindow: null
    events: []
    positionItems: []
    renderModeItems: [
      {text: @$t('activity_card.chronological'), value: 'chronological'},
      {text: @$t('activity_card.nested'), value: 'nested'}
    ]
    currentAction: 'add-comment'

  created: ->
    @init()

  updated: ->

  watch:
    '$route.params.comment_id': ->
      # if event = Records.events.find(discussionId: @discussion.id kind: 'new_comment' eventableId: @requestedCommentId)[0]
      # else
      #   Records.events.findOrFetchByCommentId
      #   parseInt(@$route.params.comment_id)find
      #
      # .sequenceId
      # else fetch it and then update url to be seqence_id
    '$route.params.sequence_id': -> @goToRequestedSequenceId()

  computed:
    requestedElement: ->

    canStartPoll: ->
      AbilityService.canStartPoll(@discussion)

  methods:
    goToRequestedSequenceId: ->
      if RangeSet.includesValue(@discussion.ranges, parseInt(@$route.params.sequence_id))
        @requestedSequenceId = parseInt(@$route.params.sequence_id)
      else
        @requestedSequenceId = 0

      min = @positionFromSequenceId(@requestedSequenceId)
      console.log "rsid #{@requestedSequenceId} setting min to #{min} and max to #{min+@per}"
      @eventWindow.setMin(min)
      @eventWindow.setMax(min+@per)

      if @requestedSequenceId == 0 || Records.events.find(discussionId: @discussion.id, sequenceId: @requestedSequenceId)[0]
        console.log "already loaded #{@requestedSequenceId}"
        @scrollToRequestedSequenceId()
      else
        console.log "loading #{@requestedSequenceId}"
        @loader.loadMore(@requestedSequenceId).then =>
          @scrollToRequestedSequenceId()

    scrollToRequestedSequenceId: ->
      @$nextTick =>
        @$vuetify.goTo if @requestedSequenceId
          "#sequence-#{@requestedSequenceId}"
        else
          ".context-panel h1"

    init: ->
      # if @renderMode == "chronological"
      #   @eventWindow = new ChronologicalEventWindow
      #     discussion: @discussion
      #     initialSequenceId: @requestedSequenceId
      #     per: @per
      # else
      @eventWindow = new NestedEventWindow
        discussion: @discussion
        parentEvent: @discussion.createdEvent()
        per: @per

      @watchRecords
        key: @discussion.id
        collections: ['groups', 'memberships']
        query: (store) =>
          @canAddComment = AbilityService.canAddComment(@discussion)

      @watchRecords
        key: @discussion.id
        collections: ['events']
        query: (store) =>
          @events = @eventWindow.windowedEvents()

      @goToRequestedSequenceId()


    positionFromSequenceId: (sequenceId) ->
      event = Records.events.find(discussionId: @discussion.id, sequenceId: sequenceId)[0]
      # ensure that we set the min position of the window to bring the initialSequenceId to the top
      # if this is the outside window, then the initialEvent might be nested, in which case, position to the parent of initialEvent
      # if the initialEvent is not child of our parentEvent

      # if the initialEvent is a child of the parentEvent then min = initialEvent.position
      # if the initialEvent is a grandchild of the parentEvent then min = initialEvent.parent().position
      # if the initialEvent is not a child or grandchild, then min = 0
      console.log "found event for #{sequenceId}", event
      console.log "parent for #{sequenceId}", event.parent()
      return 0 if event == undefined

      if event.parentId == @eventWindow.parentEvent.id
        event.position
      else if event.parent().parentId == @eventWindow.parentEvent.id
        event.parent().position
      else
        0

    loadPrevious: ->
      if @eventWindow.anyPrevious()
        @eventWindow.decreaseMin()
        @loader.loadPrevious(@eventWindow.min) # unless @eventWindow.allLoaded()

    loadNext: ->
      if @eventWindow.anyNext() && !@loader.loadingMore
        @eventWindow.increaseMax()
        @loader.loadMore() #unless @eventWindow.allLoaded()

    signIn:     -> @openAuthModal()
    isLoggedIn: -> Session.isSignedIn()
    debug:      -> window.Loomio.debug

    shouldLoadMore: (visible) ->
      @loadNext() if visible

</script>

<template lang="pug">
.activity-panel(v-if="discussion" aria-labelledby='activity-panel-title')
  div(v-if='debug()')
    p first: {{eventWindow.firstInSequence()}}
    p last: {{eventWindow.lastInSequence()}}
    p total: {{eventWindow.numTotal()}}
    p min: {{eventWindow.min}}
    p max: {{eventWindow.max}}
    p per: {{per}}
    p firstLoaded: {{eventWindow.firstLoaded()}}
    p lastLoaded: {{eventWindow.lastLoaded()}}
    p numLoaded: {{eventWindow.numLoaded()}}
    p windowLength: {{eventWindow.windowLength()}}
    p allLoaded: {{eventWindow.allLoaded()}}
    p read: {{discussion.readItemsCount()}}
    p unread: {{discussion.unreadItemsCount()}}
    p firstUnread {{discussion.firstUnreadSequenceId()}}
    p initialSequenceId: {{eventWindow.initialSequenceId}}
    p position: {{initialPosition()}}
    p loader.loadingFirst {{loader.loadingFirst}}
    p loader.loadingPrevious {{loader.loadingPrevious}}

  //- v-layout.activity-panel__settings(justify-space-between)
  //-   v-flex
  //-     v-select(flat :items='positionItems', v-model='position', @change='init()', solo)
  //-   v-flex
  //-     v-select(flat :items='renderModeItems', v-model='renderMode', @change='init()', solo)

  loading-content(v-if='eventWindow.numLoaded() == 0' :blockCount='2')

  .activity-panel__content(v-if='!loader.loadingFirst')
    a.activity-panel__load-more.lmo-flex.lmo-flex__center.lmo-no-print(v-show='eventWindow.anyPrevious() && !loader.loadingPrevious', @click='loadPrevious()', tabindex='0')
      i.mdi.mdi-autorenew
      span(v-t="{ path: 'discussion.load_previous', args: { count: eventWindow.numPrevious() }}")
    loading.activity-panel__loading.page-loading(v-show='loader.loadingPrevious')
    ul.activity-panel__activity-list
      li.activity-panel__activity-list-item(v-for='event in events', :key='event.id')
        thread-item(:event='event' :event-window='eventWindow')
    .activity-panel__load-more-sensor.lmo-no-print(v-observe-visibility="shouldLoadMore")
    loading.activity-panel__loading.page-loading(v-show='loader.loadingMore')

  v-tabs.activity-panel__actions(centered icons-and-text v-model="currentAction")
    v-tab(href='#add-comment')
      span(v-t="'activity_card.add_comment'")
      v-icon mdi-comment
    v-tab(href='#add-poll' v-if="canStartPoll")
      span(v-t="'activity_card.add_poll'")
      v-icon mdi-thumbs-up-down
    v-tab(href='#add-outcome')
      span(v-t="'activity_card.add_outcome'")
      v-icon mdi-flag-checkered
  v-tabs-items(v-model="currentAction")
    v-tab-item(value="add-comment")
      .add-comment-panel.lmo-card-padding(v-if="eventWindow")
        comment-form(v-if='canAddComment' :discussion='discussion')
        .add-comment-panel__join-actions(v-if='!canAddComment')
          join-group-button(:group='eventWindow.discussion.group()', v-if='isLoggedIn()', :block='true')
          v-btn.md-primary.md-raised.add-comment-panel__sign-in-btn(v-t="'comment_form.sign_in'", @click='signIn()', v-if='!isLoggedIn()')
    v-tab-item(value="add-poll")
      v-subheader(v-t="'decision_tools_card.title'")
      poll-common-start-form(:discussion='discussion')
    v-tab-item(value="add-outcome")

</template>
<style lang="scss">
@import 'variables';
@import 'mixins';

.add-comment-panel__sign-in-btn { width: 100% }
.add-comment-panel__join-actions button {
  width: 100%;
}

.activity-panel__load-more-sensor {
  height: 1px;
}

.activity-panel__load-more{
  @include fontSmall;
  display: flex;
  align-items: center;
  color: $grey-on-grey;
  line-height: 30px;
  padding: 0 10px;
  background-color: $background-color;
  margin-bottom: 20px;
  margin-left: $cardPaddingSize;
  margin-right: $cardPaddingSize;
  cursor: pointer;
  i {
    margin-right: 4px;
    font-size: 16px;
  }
}

.activity-panel__last-read-activity {
  visibility: hidden; /* can't display none because scrolling won't work */
  line-height: 0px;
  margin: -10px 0;
}

.activity-panel__activity-list{
  list-style: none;
  padding: 0;
}

</style>
