angular.module('loomioApp').directive 'adminMembershipsPanel', ->
  scope: {memberships: '=', group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/memberships_page/admin_memberships_panel/admin_memberships_panel.html'
  replace: true
  controller: 'AdminMembershipsPanelController'
