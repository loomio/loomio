angular.module('loomioApp').directive 'dashboardPageThreadCollection', ->
  scope: {threads: '=', filter: '=', name: '@'}
  restrict: 'E'
  templateUrl: 'generated/components/dashboard_page/dashboard_page_thread_collection.html'
  replace: true
  controller: ($scope) ->

    $scope.filteredThreads = ->
      _.filter $scope.threads(), $scope.filter

    $scope.any = ->
      $scope.filteredThreads().length > 0
