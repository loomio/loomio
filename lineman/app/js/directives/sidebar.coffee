angular.module('loomioApp').directive 'sidebar', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/templates/sidebar.html'
  replace: true
  controller: 'SidebarController'
  link: (scope, element, attrs) ->
