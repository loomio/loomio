AppConfig                = require 'shared/services/app_config'
EventBus                 = require 'shared/services/event_bus'
RecordLoader             = require 'shared/services/record_loader'
ChronologicalEventWindow = require 'shared/services/chronological_event_window'
NestedEventWindow        = require 'shared/services/nested_event_window'
ModalService             = require 'shared/services/modal_service'

{ print } = require 'shared/helpers/window'

angular.module('loomioApp').directive 'activityCard', ['$mdDialog', ($mdDialog) ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/activity_card/activity_card.html'
  controller: ['$scope', ($scope) ->
    $scope.debug = -> window.Loomio.debug

    $scope.setDefaults = ->
      $scope.per = AppConfig.pageSize.threadItems
      $scope.renderMode = 'nested'
      $scope.position = $scope.positionForSelect()

    $scope.positionForSelect = ->
      if _.includes(['requested', 'context'], $scope.initialPosition())
        "beginning"
      else
        $scope.initialPosition()

    $scope.initialPosition = ->
      switch
        when $scope.discussion.requestedSequenceId
          "requested"
        when (!$scope.discussion.lastReadAt) || $scope.discussion.itemsCount == 0
          'context'
        when $scope.discussion.readItemsCount() == 0
          'beginning'
        when $scope.discussion.isUnread()
          'unread'
        else
          'latest'

    $scope.initialSequenceId = (position) ->
      switch position
        when "requested"            then $scope.discussion.requestedSequenceId
        when "beginning", "context" then $scope.discussion.firstSequenceId()
        when "unread"               then $scope.discussion.firstUnreadSequenceId()
        when "latest"               then $scope.discussion.lastSequenceId() - $scope.per + 2

    $scope.elementToFocus = (position) ->
      switch position
        when "context"   then ".context-panel h1"
        when "requested" then "#sequence-#{$scope.discussion.requestedSequenceId}"
        when "beginning" then "#sequence-#{$scope.discussion.firstSequenceId()}"
        when "unread"    then "#sequence-#{$scope.discussion.firstUnreadSequenceId()}"
        when "latest"    then "#sequence-#{$scope.discussion.lastSequenceId()}"

    EventBus.listen $scope, 'fetchRecordsForPrint', ->
      if $scope.discussion.allEventsLoaded()
        print()
      else
        ModalService.open 'PrintModal', preventClose: -> true
        $scope.eventWindow.showAll().then ->
          $mdDialog.cancel()
          print()

    $scope.init = (position = $scope.initialPosition()) ->
      $scope.loader = new RecordLoader
        collection: 'events'
        params:
          discussion_id: $scope.discussion.id
          order: 'sequence_id'
          from: $scope.initialSequenceId(position)
          per: $scope.per

      $scope.loader.loadMore($scope.initialSequenceId(position)).then ->
        if $scope.renderMode == "chronological"
          $scope.eventWindow = new ChronologicalEventWindow
            discussion: $scope.discussion
            initialSequenceId: $scope.initialSequenceId(position)
            per: $scope.per
        else
          $scope.eventWindow = new NestedEventWindow
            discussion: $scope.discussion
            parentEvent: $scope.discussion.createdEvent()
            initialSequenceId: $scope.initialSequenceId(position)
            per: $scope.per

        EventBus.emit $scope, 'threadPageScrollToSelector', $scope.elementToFocus(position)

    $scope.setDefaults()
    $scope.init()
    EventBus.listen $scope, 'initActivityCard', -> $scope.init()

    return
  ]
]
