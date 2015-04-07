angular.module('loomioApp').controller 'DiscussionsCardController', ($scope, $modal, Records, DiscussionFormService, KeyEventService, LoadingService) ->
  $scope.loaded = 0
  $scope.perPage = 25

  $scope.loadMore = ->
    options =
      group_id: $scope.group.id
      from:     $scope.loaded
      per:      $scope.perPage
    $scope.loaded += $scope.perPage
    Records.discussions.fetchByGroup options
  LoadingService.applyLoadingFunction $scope, 'loadMore'
  $scope.loadMore()

  $scope.openDiscussionForm = ->
    DiscussionFormService.openNewDiscussionModal($scope.group)
  KeyEventService.registerKeyEvent $scope, 'pressedT', $scope.openDiscussionForm