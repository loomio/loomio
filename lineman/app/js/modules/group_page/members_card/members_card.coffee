angular.module('loomioApp').directive 'membersCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/js/modules/group_page/members_card/members_card.html'
  replace: true
  controller: 'MembersCardController'
  link: (scope, element, attrs) ->
