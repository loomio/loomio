angular.module('loomioApp').controller 'DiscussionsCardController', ($scope, $modal, Records, UserAuthService) ->
  nextPage = 1
  busy = false
  $scope.lastPage = false

  $scope.getNextPage = ->
    return false if busy or $scope.lastPage
    busy = true
    Records.discussions.fetchByGroupAndPage($scope.group, nextPage).then (data) ->
      discussions = data.discussions
      $scope.lastPage = true if discussions.length < 5
      nextPage = nextPage + 1
      busy = false

  $scope.getNextPage()
