angular.module('loomioApp').directive 'membershipsPanel', ->
  scope: {memberships: '=', group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/memberships_page/memberships_panel/memberships_panel.html'
  replace: true
  controller: 'AdminMembershipsPanelController'
