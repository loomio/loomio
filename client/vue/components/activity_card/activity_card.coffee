AppConfig                = require 'shared/services/app_config'
EventBus                 = require 'shared/services/event_bus'
RecordLoader             = require 'shared/services/record_loader'
ChronologicalEventWindow = require 'shared/services/chronological_event_window'
NestedEventWindow        = require 'shared/services/nested_event_window'
ModalService             = require 'shared/services/modal_service'

{ print } = require 'shared/helpers/window'

module.exports =
  props:
    discussion: Object
  data: ->
    per: AppConfig.pageSize.threadItems
    renderMode: 'nested'
    position: @positionForSelect()
    loader: new RecordLoader
      collection: 'events'
      params:
        discussion_id: @discussion.id
        order: 'sequence_id'
        from: @initialSequenceId(@initialPosition())
        per: @per
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
  methods:
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

        # EventBus.emit $scope, 'threadPageScrollToSelector', $scope.elementToFocus(position)

  template:
    """
    <section aria-labelledby="activity-card-title" class="activity-card">
      <div v-show="eventWindow.anyLoaded()" class="activity-card__settings">
        <!-- <md-select ng-model="position" ng-change="init(position)" class="md-no-underline">
          <md-option value="beginning" translate="activity_card.beginning"></md-option>
          <md-option value="unread" translate="activity_card.unread" ng-disabled="!eventWindow.anyUnread()"></md-option>
          <md-option value="latest" translate="activity_card.latest"></md-option>
        </md-select> -->
        <!-- <md-select ng-model="renderMode" ng-change="init()" class="md-no-underline">
          <md-option value="chronological" translate="activity_card.chronological"></md-option>
          <md-option value="nested" translate="activity_card.nested"></md-option>
        </md-select> -->
      </div>

      <div v-if="debug()">first: {{eventWindow.firstInSequence()}}last: {{eventWindow.lastInSequence()}}total: {{eventWindow.numTotal()}}min: {{eventWindow.min}}max: {{eventWindow.max}}per: {{per}}firstLoaded: {{eventWindow.firstLoaded()}}lastLoaded: {{eventWindow.lastLoaded()}}loadedCount: {{eventWindow.numLoaded()}}read: {{discussion.readItemsCount()}}unread: {{discussion.unreadItemsCount()}}firstUnread {{discussion.firstUnreadSequenceId()}}initialSequenceId: {{initialSequenceId(initialPosition())}}requestedSequenceId: {{discussion.requestedSequenceId}}position: {{initialPosition()}}</div>

      <!-- <loading_content v-if="loader.loading" block-count="2" class="lmo-card-left-right-padding"></loading_content> -->
        {{ loader.loading }}
      <div v-if="!loader.loading" class="activity-card__content">
        <a
          v-show="eventWindow.anyPrevious() && !eventWindow.loader.loadingPrevious"
          @click="eventWindow.showPrevious()"
          tabindex="0"
          class="activity-card__load-more lmo-flex lmo-flex__center lmo-no-print"
        >
          <i class="mdi mdi-autorenew"></i>
          <span v-t="{ path: 'discussion.load_previous', args: { count: eventWindow.numPrevious() }}"></span>
        </a>
        <loading v-show="eventWindow.loader.loadingPrevious" class="activity-card__loading page-loading"></loading>
        <ul class="activity-card__activity-list">
          <li
            v-for="event in eventWindow.windowedEvents()"
            :key="event.id"
            class="activity-card__activity-list-item"
          >
            {{ event }}
            <!-- <thread_item event="event" event_window="eventWindow"></thread_item> -->
          </li>
        </ul>
        <!-- <div
          in-view="$inview && !eventWindow.loader.loadingMore && eventWindow.anyNext() && eventWindow.showNext()"
          in-view-options="{throttle: 200}"
          class="activity-card__load-more-sensor lmo-no-print"
        ></div> -->
        <loading v-show="eventWindow.loader.loadingMore" class="activity-card__loading page-loading"></loading>
      </div>
      <!-- <add_comment_panel v-if="eventWindow" event_window="eventWindow" parent_event="discussion.createdEvent()"></add_comment_panel> -->
    </section>
    """
