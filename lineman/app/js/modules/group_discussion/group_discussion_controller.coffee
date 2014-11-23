angular.module('loomioApp').controller 'DiscussionsController', ($scope, DiscussionService) ->
  DiscussionService.fetchByGroup $scope.group

  nextPage = 1
  busy = false
  $scope.lastPage = false

  $scope.getNextPage = ->
    return false if busy or $scope.lastPage
    busy = true
    DiscussionService.fetchByGroup $scope.group, nextPage, (discussions) ->
      $scope.lastPage = true if discussions.length < 5
      nextPage = nextPage + 1
      busy = false
  $scope.getNextPage()
