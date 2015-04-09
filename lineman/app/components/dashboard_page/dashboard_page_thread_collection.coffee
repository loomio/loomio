angular.module('loomioApp').directive 'dashboardPageThreadCollection', ->
  scope: {threads: '=', filter: '=', group: '=?', name: '@'}
  restrict: 'E'
  templateUrl: 'generated/components/dashboard_page/dashboard_page_thread_collection.html'
  replace: true
  controller: ($scope) ->

    COLLAPSED_GROUP_SIZE = 5
    EXPANDED_GROUP_SIZE = 10

    $scope.filteredThreads = ->
      _.filter $scope.threads(), $scope.filter

    $scope.limit = ->
      if $scope.group
        $scope.expanded ? EXPANDED_GROUP_SIZE : COLLAPSED_GROUP_SIZE
      else
        Number.MAX_VALUE

    $scope.canExpand = ->
      $scope.group and
      !$scope.expanded and
      $scope.filteredThreads().length > COLLAPSED_GROUP_SIZE

    $scope.any = ->
      $scope.filteredThreads().length > 0
