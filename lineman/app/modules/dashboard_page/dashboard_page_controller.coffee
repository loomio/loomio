angular.module('loomioApp').controller 'DashboardPageController', ($scope, Records) ->

  $scope.refresh = ->
    switch $scope.sort
      when 'date'
        Records.discussions.fetchInboxByDate  filter: $scope.filter
      when 'group'
        Records.discussions.fetchInboxByGroup filter: $scope.filter

  $scope.setOptions = (options = {}) ->
    $scope.filter = options['filter'] if options['filter']
    $scope.sort   = options['sort']   if options['sort']
    $scope.refresh()
  $scope.setOptions sort: 'date', filter: 'all'

  $scope.dashboardDiscussions = ->
    window.Loomio.currentUser.inboxDiscussions()

  $scope.dashboardGroups = ->
    window.Loomio.currentUser.groups()

