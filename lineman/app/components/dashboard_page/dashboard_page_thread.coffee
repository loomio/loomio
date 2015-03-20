angular.module('loomioApp').directive 'dashboardPageThread', ->
  scope: {discussion: '=', showGroupLogo: '@'}
  restrict: 'E'
  templateUrl: 'generated/components/dashboard_page/dashboard_page_thread.html'
  replace: true
