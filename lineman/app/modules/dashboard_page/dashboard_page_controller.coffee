angular.module('loomioApp').controller 'DashboardPageController', ($scope, Records) ->
  $scope.sort = 'date'
  $scope.filter = 'all'

  Records.discussions.fetchInboxCurrent()
  Records.discussions.fetchInboxByGroup()

  $scope.setFilter = (filter) ->
    $scope.filter = filter

  $scope.setSort = (sort) ->
    $scope.sort = sort

  $scope.groups = ->
    window.Loomio.currentUser.groups()
