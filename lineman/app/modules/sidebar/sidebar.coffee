angular.module('loomioApp').directive 'sidebar', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/modules/sidebar/sidebar.html'
  replace: true
  controller: 'SidebarController'
  link: (scope, element, attrs) ->
