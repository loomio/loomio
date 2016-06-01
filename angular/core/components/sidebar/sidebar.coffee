angular.module('loomioApp').directive 'sidebar', (SidebarController)->
  scope: false
  restrict: 'E'
  templateUrl: 'generated/components/sidebar/sidebar.html'
  replace: true
  controller: SidebarController
