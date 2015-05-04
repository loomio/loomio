angular.module('loomioApp').directive 'dashboardPageGroupCollection', ->
  scope: {threads: '=', group: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/dashboard_page/dashboard_page_group_collection.html'
  replace: true
  controller: ($scope) ->

    COLLAPSED_GROUP_SIZE = 5
    EXPANDED_GROUP_SIZE = 10
    $scope.limit = COLLAPSED_GROUP_SIZE

    $scope.filteredThreads = ->
      $scope.threads($scope.group)

    $scope.expand = ->
      $scope.limit = EXPANDED_GROUP_SIZE

    $scope.canExpand = ->
      $scope.limit == COLLAPSED_GROUP_SIZE and
      $scope.filteredThreads().length > COLLAPSED_GROUP_SIZE

    $scope.any = ->
      $scope.filteredThreads().length > 0
