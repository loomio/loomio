angular.module('loomioApp').controller 'DashboardPageController', ($scope, Records) ->
  $scope.sort = 'date'
  $scope.filter = 'all'

  Records.discussions.fetchInboxCurrent()
  Records.discussions.fetchInboxByGroup()

  $scope.setFilter = (filter) ->
    $scope.filter = filter

  $scope.setSort = (sort) ->
    $scope.sort = sort

  $scope.currentUserThreads = ->
    window.Loomio.currentUser.inboxDiscussions()

  $scope.currentUserGroups = ->
    window.Loomio.currentUser.groups()