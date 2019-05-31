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
# window.Loomio.debug= 1
export default
  mixins: [ AuthModalMixin, WatchRecords ]

  props:
    discussion: Object
    loader: Object

  data: ->
    canAddComment: false
    per: AppConfig.pageSize.threadItems
    renderMode: 'nested'
    position: @positionForSelect()
    eventWindow: null
    events: []
    positionItems: []
    renderModeItems: [
      {text: @$t('activity_card.chronological'), value: 'chronological'},
      {text: @$t('activity_card.nested'), value: 'nested'}
    ]

  created: ->
    @init()
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

    @positionItems = [
      {text: @$t('activity_card.beginning'), value: 'beginning'},
      {text: @$t('activity_card.unread'), value: 'unread', disabled: !@eventWindow.anyUnread()},
      {text: @$t('activity_card.latest'), value: 'latest'}
    ]


  methods:
    init: ->
      @setupEventWindow(@position)
      # @eventWindow.setMinMax()
      # @events = @eventWindow.windowedEvents()
      # unless @eventWindow.allLoaded()
      #   @loader.fetchRecords().then =>
      #     @eventWindow.setMinMax()
      #     @events = @eventWindow.windowedEvents()


    loadPrevious: ->
      if @eventWindow.anyPrevious()
        @eventWindow.decreaseMin()
        @loader.loadPrevious(@eventWindow.min) # unless @eventWindow.allLoaded()

    loadNext: ->
      if @eventWindow.anyNext()
        @eventWindow.increaseMax()
        @loader.loadMore() #unless @eventWindow.allLoaded()

    positionForSelect: ->
      if _.includes(['requested', 'context'], @initialPosition())
        "beginning"
      else
        @initialPosition()

    signIn:     -> @openAuthModal()
    isLoggedIn: -> Session.isSignedIn()
    debug:      -> window.Loomio.debug

    initialPosition: ->
      switch
        when @discussion.requestedSequenceId
          "requested"
        when (!@discussion.lastReadAt) || @discussion.itemsCount == 0
          'context'
        when @discussion.readItemsCount() == 0
          'beginning'
        when @discussion.isUnread()
          'unread'
        else
          'latest'

    initialSequenceId: (position) ->
      switch position
        when "requested"            then @discussion.requestedSequenceId
        when "beginning", "context" then @discussion.firstSequenceId()
        when "unread"               then @discussion.firstUnreadSequenceId()
        when "latest"               then @discussion.lastSequenceId() - @per + 2

    elementToFocus: (position) ->
      switch position
        when "context"   then ".context-panel h1"
        when "requested" then "#sequence-#{@discussion.requestedSequenceId}"
        when "beginning" then "#sequence-#{@discussion.firstSequenceId()}"
        when "unread"    then "#sequence-#{@discussion.firstUnreadSequenceId()}"
        when "latest"    then "#sequence-#{@discussion.lastSequenceId()}"

    setupEventWindow: (position) ->
      if @renderMode == "chronological"
        @eventWindow = new ChronologicalEventWindow
          discussion: @discussion
          initialSequenceId: @initialSequenceId(position)
          per: @per
      else
        @eventWindow = new NestedEventWindow
          discussion: @discussion
          parentEvent: @discussion.createdEvent()
          initialSequenceId: @initialSequenceId(position)
          per: @per

</script>

<template lang="pug">
section.activity-card(aria-labelledby='activity-card-title')
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
    p initialSequenceId: {{initialSequenceId(initialPosition())}}
    p requestedSequenceId: {{discussion.requestedSequenceId}}
    p position: {{initialPosition()}}
    p loader.loadingFirst {{loader.loadingFirst}}
    p loader.loadingPrevious {{loader.loadingPrevious}}

  v-layout.activity-card__settings(justify-space-between)
    v-flex
      v-select(flat :items='positionItems', v-model='position', @change='init()', solo)
    v-flex
      v-select(flat :items='renderModeItems', v-model='renderMode', @change='init()', solo)

  loading-content(v-if='loader.loadingFirst' :blockCount='2')

  .activity-card__content(v-if='!loader.loadingFirst')
    a.activity-card__load-more.lmo-flex.lmo-flex__center.lmo-no-print(v-show='eventWindow.anyPrevious() && !loader.loadingPrevious', @click='loadPrevious()', tabindex='0')
      i.mdi.mdi-autorenew
      span(v-t="{ path: 'discussion.load_previous', args: { count: eventWindow.numPrevious() }}")
    loading.activity-card__loading.page-loading(v-show='loader.loadingPrevious')
    ul.activity-card__activity-list
      li.activity-card__activity-list-item(v-for='event in events', :key='event.id')
        thread-item(:event='event', :event-window='eventWindow')
    //
      <div
      in-view="$inview && !eventWindow.loader.loadingMore && eventWindow.anyNext() && eventWindow.showNext()"
      in-view-options="{throttle: 200}"
      class="activity-card__load-more-sensor lmo-no-print"
      ></div>
    loading.activity-card__loading.page-loading(v-show='loader.loadingMore')
  //- add-comment-panel(v-if='eventWindow', :event-window='eventWindow', :parent-event='discussion.createdEvent()')
  .add-comment-panel.lmo-card-padding(v-if="eventWindow")
    comment-form(v-if='canAddComment' :discussion='discussion')
    .add-comment-panel__join-actions(v-if='!canAddComment')
      join-group-button(:group='eventWindow.discussion.group()', v-if='isLoggedIn()', :block='true')
      v-btn.md-primary.md-raised.add-comment-panel__sign-in-btn(v-t="'comment_form.sign_in'", @click='signIn()', v-if='!isLoggedIn()')

</template>
<style lang="scss">
@import 'variables';
@import 'mixins';

.add-comment-panel__sign-in-btn { width: 100% }
.add-comment-panel__join-actions button {
  width: 100%;
}


.activity-card__load-more-sensor {
  height: 1px;
}
.activity-card__load-more{
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

.activity-card__last-read-activity {
  visibility: hidden; /* can't display none because scrolling won't work */
  line-height: 0px;
  margin: -10px 0;
}

.activity-card__new-activity {
  visibility: visible;
  margin: 0px 0 25px 0;
  padding-bottom: 3px;
  border-bottom: 1px solid $loomio-orange;
  text-align: right;
  font-size: 10px;
  line-height: 12px;
  letter-spacing: 0.3px;
  color: $loomio-orange;

}

.activity-card__activity-list{
  list-style: none;
  padding: 0;
}

</style>
