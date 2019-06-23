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
import { compact, snakeCase, camelCase, max } from 'lodash'
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
    lastSequenceId: 0
    event: null
    events: []
    positionItems: []
    renderModeItems: [
      {text: @$t('activity_card.chronological'), value: 'chronological'},
      {text: @$t('activity_card.nested'), value: 'nested'}
    ]
    currentAction: 'add-comment'

  watch:
    '$route.params.key': 'init'
    '$route.params.sequence_id': 'routeUpdated'

  created: -> @init()

  methods:
    init: ->
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

      EventBus.$on 'threadPositionRequest', (position) => @positionRequested(position)
      @sequenceIdRequested(parseInt(@$route.params.sequence_id) || @discussion.firstUnreadSequenceId() || 0)

    routeUpdated: ->
      @sequenceIdRequested(parseInt(@$route.params.sequence_id) || 0)

    findEvent: (column, id) ->
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
        Records.events.find(args)[0]

    fetchEvents: (column, id) ->
      args = switch snakeCase(column)
        when 'position'
          discussion_id: @discussion.id
          order: 'sequence_id'
          from_sequence_id_of_position: id
          from: null
          per: @per
        when 'sequence_id'
          discussion_id: @discussion.id
          order: 'sequence_id'
          from: id
          per: @per
      @loader.fetchRecords(args)

    # return immediately if first event found, always fetches
    findOrFetchEvent: (column, id) ->
      # if requesting by position, also request a sequence_id & depth 2
      event = @findEvent(column, id)
      if event
        console.log "event found: #{column}, #{id}"
        # @fetchEvents(column, id)
        Promise.resolve(event)
      else
        console.log "fetching event: #{column}, #{id}"
        @fetchEvents(column, id).then =>
          return @findEvent(column, id)

    sequenceIdRequested: (id) ->
      return if @eventWindow.focalEvent.sequenceId == id
      @findOrFetchEvent('sequenceId', id).then (event) =>
        console.log "event", event
        @alignWindowTo(event)

    positionRequested: (id) ->
      return if @eventWindow.focalEvent.position == id
      @findOrFetchEvent('position', id).then (event) =>
        @alignWindowTo(event)

    alignWindowTo: (event) ->
      console.log "aligning to event", event
      @eventWindow.focalEvent = event
      min = @parentPositionOf(event)
      @eventWindow.setMin(min)
      @eventWindow.setMax(min+@per)
      @events = @eventWindow.windowedEvents()
      @$router.replace(params: {sequence_id: event.sequenceId})
      EventBus.$emit 'threadPositionUpdated', event.position
      @$nextTick => @$nextTick => @$vuetify.goTo "#sequence-#{event.sequenceId || 0}"

    parentPositionOf: (event) ->
      # ensure that we set the min position of the window to bring the initialSequenceId to the top
      # if this is the outside window, then the initialEvent might be nested, in which case, position to the parent of initialEvent
      # if the initialEvent is not child of our parentEvent

      # if the initialEvent is a child of the parentEvent then min = initialEvent.position
      # if the initialEvent is a grandchild of the parentEvent then min = initialEvent.parent().position
      # if the initialEvent is not a child or grandchild, then min = 0
      console.log event
      if event == @discussion.createdEvent()
        0
      else if event.parentId == @eventWindow.parentEvent.id
        event.position
      else if event.parent().parentId == @eventWindow.parentEvent.id
        event.parent().position

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
    shouldLoadPrevious: (visible) ->
      @loadPrevious() if visible
  computed:
    canStartPoll: ->
      AbilityService.canStartPoll(@discussion)

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
  //-     v-select(text :items='positionItems', v-model='position', @change='init()', solo)
  //-   v-flex
  //-     v-select(text :items='renderModeItems', v-model='renderMode', @change='init()', solo)

  loading-content(v-if='loader.loading && eventWindow.numLoaded() == 0' :blockCount='2')

  .activity-panel__content(v-if='!loader.loadingFirst')
    a.activity-panel__load-more.lmo-flex.lmo-flex__center.lmo-no-print(v-show='eventWindow.anyPrevious() && !loader.loadingPrevious', @click='loadPrevious()', tabindex='0')
      i.mdi.mdi-autorenew
      span(v-t="{ path: 'discussion.load_previous', args: { count: eventWindow.numPrevious() }}")
    //- .activity-panel__load-more-sensor.lmo-no-print(v-observe-visibility="shouldLoadPrevious")
    loading.activity-panel__loading.page-loading(v-show='loader.loadingPrevious')
    thread-item(v-for='event in events' :key='event.id' :event='event' :event-window='eventWindow')
    .activity-panel__load-more-sensor.lmo-no-print(v-observe-visibility="shouldLoadMore")
    loading.activity-panel__loading.page-loading(v-show='loader.loadingMore')

  v-tabs.activity-panel__actions(centered icons-and-text v-model="currentAction")
    v-tab(href='#add-comment')
      span(v-t="'activity_card.add_comment'")
      v-icon mdi-comment
    v-tab.activity-panel__add-poll(href='#add-poll' v-if="canStartPoll")
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
/* @import 'mixins'; */

.add-comment-panel__sign-in-btn { width: 100% }
.add-comment-panel__join-actions button {
  width: 100%;
}

.activity-panel__load-more-sensor {
  height: 1px;
}

.activity-panel__load-more{
  /* @include fontSmall; */
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

</style>
