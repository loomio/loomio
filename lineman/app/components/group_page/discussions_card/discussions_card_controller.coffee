angular.module('loomioApp').controller 'DiscussionsCardController', ($scope, $modal, Records, DiscussionFormService, KeyEventService, LoadingService) ->
  $scope.loaded = 0
  $scope.perPage = 25

  $scope.loadMore = ->
    Records.discussions.fetchByGroup(
      group_id: $scope.group.id
      from:     $scope.loaded
      per:      $scope.perPage).then -> $scope.loaded += $scope.perPage
  LoadingService.applyLoadingFunction $scope, 'loadMore'

  $scope.loadMore()

  $scope.openDiscussionForm = ->
    DiscussionFormService.openNewDiscussionModal($scope.group)

  KeyEventService.registerKeyEvent $scope, 'pressedT', ->
    $scope.openDiscussionForm()