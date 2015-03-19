angular.module('loomioApp').directive 'sidebar', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/sidebar/sidebar.html'
  replace: true
  controller: 'SidebarController'
  link: (scope, element, attrs) ->
