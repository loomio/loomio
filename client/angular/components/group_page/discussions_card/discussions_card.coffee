Records            = require 'shared/services/records.coffee'
AbilityService     = require 'shared/services/ability_service.coffee'
RecordLoader       = require 'shared/services/record_loader.coffee'
ThreadQueryService = require 'shared/services/thread_query_service.coffee'

angular.module('loomioApp').directive 'discussionsCard', ($q, $location, $timeout, ModalService, KeyEventService, LoadingService) ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/discussions_card/discussions_card.html'
  replace: true
  controller: ($scope) ->

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

    $scope.init($location.search().filter)
    $scope.$on 'subgroupsLoaded', -> $scope.init($scope.filter)

    $scope.searchThreads = ->
      return $q.when() unless $scope.fragment
      Records.discussions.search($scope.group.key, $scope.fragment, per: 10).then (data) ->
        $scope.searched = ThreadQueryService.queryFor
          name: "group_#{$scope.group.key}_searched"
          group: $scope.group
          ids: _.pluck(data.discussions, 'id')
          overwrite: true
    LoadingService.applyLoadingFunction $scope, 'searchThreads'

    $scope.openDiscussionModal = ->
      ModalService.open 'DiscussionModal', discussion: -> Records.discussions.build(groupId: $scope.group.id)

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
