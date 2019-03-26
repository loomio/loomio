Records            = require 'shared/services/records'
AbilityService     = require 'shared/services/ability_service'
EventBus           = require 'shared/services/event_bus'
RecordLoader       = require 'shared/services/record_loader'
ThreadQueryService = require 'shared/services/thread_query_service'
ModalService       = require 'shared/services/modal_service'
LmoUrlService      = require 'shared/services/lmo_url_service'

{ applyLoadingFunction } = require 'shared/helpers/apply'

angular.module('loomioApp').directive 'discussionsCard', ['$timeout', ($timeout) ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/discussions_card/discussions_card.html'
  replace: true
  controller: ['$scope', ($scope) ->

    $scope.init = (filter) ->
      $scope.filter = filter or 'show_opened'
      $scope.pinned = ThreadQueryService.queryFor
        name: "group_#{$scope.group.key}_pinned"
        group: $scope.group
        filters: ['show_pinned', $scope.filter]
        overwrite: true
      $scope.discussions = ThreadQueryService.queryFor
        name: "group_#{$scope.group.key}_unpinned"
        group: $scope.group
        filters: ['hide_pinned', $scope.filter]
        overwrite: true
      $scope.loader = new RecordLoader
        collection: 'discussions'
        params:
          group_id: $scope.group.id
          filter:   $scope.filter
      $scope.loader.fetchRecords()

    $scope.init(LmoUrlService.params().filter)
    EventBus.listen $scope, 'subgroupsLoaded', -> $scope.init($scope.filter)

    $scope.searchThreads = ->
      return Promise.resolve(true) unless $scope.fragment
      Records.discussions.search($scope.group.key, $scope.fragment, per: 10).then (data) ->
        $scope.searched = ThreadQueryService.queryFor
          name: "group_#{$scope.group.key}_searched"
          group: $scope.group
          ids: _.map(data.discussions, 'id')
          overwrite: true
    applyLoadingFunction($scope, 'searchThreads')

    $scope.startDiscussion = ->
      ModalService.open 'DiscussionStartModal', discussion: -> Records.discussions.build(groupId: $scope.group.id)

    $scope.loading = ->
      $scope.loader.loadingFirst || $scope.searchThreadsExecuting

    $scope.isEmpty = ->
      return if $scope.loading()
      if $scope.fragment
        !$scope.searched || !$scope.searched.any()
      else
        !$scope.discussions.any() && !$scope.pinned.any()

    $scope.canViewPrivateContent = ->
      AbilityService.canViewPrivateContent($scope.group)

    $scope.openSearch = ->
      $scope.searchOpen = true
      $timeout -> document.querySelector('.discussions-card__search input').focus()

    $scope.closeSearch = ->
      $scope.fragment = null
      $scope.searchOpen = false

    $scope.canStartThread = ->
      AbilityService.canStartThread($scope.group)
  ]
]
