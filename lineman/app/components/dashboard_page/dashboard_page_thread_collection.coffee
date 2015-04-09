angular.module('loomioApp').directive 'dashboardPageThreadCollection', ->
  scope: {threads: '=', filter: '=', name: '@'}
  restrict: 'E'
  templateUrl: 'generated/components/dashboard_page/dashboard_page_thread_collection.html'
  replace: true
  controllerAs: 'collection'
  controller: ($scope) ->
    filteredThreads: ->
      @filter @threads

    any: ->
      @filteredThreads().length > 0
