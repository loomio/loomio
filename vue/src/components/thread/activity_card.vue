<script lang="coffee">
import AppConfig                from '@/shared/services/app_config'
import EventBus                 from '@/shared/services/event_bus'
import RecordLoader             from '@/shared/services/record_loader'
import ChronologicalEventWindow from '@/shared/services/chronological_event_window'
import NestedEventWindow        from '@/shared/services/nested_event_window'
import ModalService             from '@/shared/services/modal_service'
import AbilityService           from '@/shared/services/ability_service'
import AuthModalMixin from '@/mixins/auth_modal'


import { print } from '@/shared/helpers/window'

export default
  mixins: [ AuthModalMixin ]
  props:
    discussion: Object
  data: ->
    per: AppConfig.pageSize.threadItems
    renderMode: 'nested'
    position: @positionForSelect()
    eventWindow: {}
    loader: new RecordLoader
      collection: 'events'
      params:
        discussion_id: @discussion.id
        order: 'sequence_id'
        from: @initialSequenceId(@initialPosition())
        per: @per
    positionItems: []
    renderModeItems: [
      {text: @$t('activity_card.chronological'), value: 'chronological'},
      {text: @$t('activity_card.nested'), value: 'nested'}
    ]
  created: ->
    # EventBus.listen $scope, 'fetchRecordsForPrint', ->
    #   if $scope.discussion.allEventsLoaded()
    #     print()
    #   else
    #     ModalService.open 'PrintModal', preventClose: -> true
    #     $scope.eventWindow.showAll().then ->
    #       $mdDialog.cancel()
    #       print()
    @init()
    # EventBus.listen $scope, 'initActivityCard', -> $scope.init()
  computed:
    canAddComment: -> AbilityService.canAddComment(@discussion)

  methods:
    signIn: -> @openAuthModal()
    isLoggedIn: -> AbilityService.isLoggedIn()
    positionForSelect: ->
      if _.includes(['requested', 'context'], @initialPosition())
        "beginning"
      else
        @initialPosition()

    debug: ->
      window.Loomio.debug

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

    init: (position = @initialPosition()) ->
      @loader = new RecordLoader
        collection: 'events'
        params:
          discussion_id: @discussion.id
          order: 'sequence_id'
          from: @initialSequenceId(position)
          per: @per

      @setupEventWindow(position)
      @loader.loadMore(@initialSequenceId(position)).then =>
        @setupEventWindow(position)
        # EventBus.$emit $scope, 'threadPageScrollToSelector', $scope.elementToFocus(position)
      @positionItems = [
        {text: @$t('activity_card.beginning'), value: 'beginning'},
        {text: @$t('activity_card.unread'), value: 'unread', disabled: !@eventWindow.anyUnread()},
        {text: @$t('activity_card.latest'), value: 'latest'}
      ]
</script>

<template lang="pug">
section.activity-card(aria-labelledby='activity-card-title')
  v-layout.activity-card__settings(justify-space-between v-show='eventWindow.anyLoaded()')
    v-flex
      v-select(flat :items='positionItems', v-model='position', @change='init(position)', solo='')
    v-flex
      v-select(flat :items='renderModeItems', v-model='renderMode', @change='init()', solo='')
  div(v-if='debug()')
    | first: {{eventWindow.firstInSequence()}}last: {{eventWindow.lastInSequence()}}total: {{eventWindow.numTotal()}}min: {{eventWindow.min}}max: {{eventWindow.max}}per: {{per}}firstLoaded: {{eventWindow.firstLoaded()}}lastLoaded: {{eventWindow.lastLoaded()}}loadedCount: {{eventWindow.numLoaded()}}read: {{discussion.readItemsCount()}}unread: {{discussion.unreadItemsCount()}}firstUnread {{discussion.firstUnreadSequenceId()}}initialSequenceId: {{initialSequenceId(initialPosition())}}requestedSequenceId: {{discussion.requestedSequenceId}}position: {{initialPosition()}}
  // <loading_content v-if="loader.loading" block-count="2" class="lmo-card-left-right-padding"></loading_content>
  .activity-card__content(v-if='!loader.loading')
    a.activity-card__load-more.lmo-flex.lmo-flex__center.lmo-no-print(v-show='eventWindow.anyPrevious() && !eventWindow.loader.loadingPrevious', @click='eventWindow.showPrevious()', tabindex='0')
      i.mdi.mdi-autorenew
      span(v-t="{ path: 'discussion.load_previous', args: { count: eventWindow.numPrevious() }}")
    loading.activity-card__loading.page-loading(v-show='eventWindow.loader.loadingPrevious')
    ul.activity-card__activity-list
      li.activity-card__activity-list-item(v-for='event in eventWindow.windowedEvents()', :key='event.id')
        thread-item(:event='event', :event-window='eventWindow')
    //
      <div
      in-view="$inview && !eventWindow.loader.loadingMore && eventWindow.anyNext() && eventWindow.showNext()"
      in-view-options="{throttle: 200}"
      class="activity-card__load-more-sensor lmo-no-print"
      ></div>
    loading.activity-card__loading.page-loading(v-show='eventWindow.loader.loadingMore')
  //- add-comment-panel(v-if='eventWindow', :event-window='eventWindow', :parent-event='discussion.createdEvent()')
  .add-comment-panel.lmo-card-padding
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
