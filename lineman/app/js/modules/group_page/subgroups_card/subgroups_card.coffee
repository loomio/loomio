angular.module('loomioApp').directive 'subgroupsCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/js/modules/group_page/subgroups_card/subgroups_card.html'
  replace: true
  controller: 'SubgroupsCardController'
  link: (scope, element, attrs) ->
