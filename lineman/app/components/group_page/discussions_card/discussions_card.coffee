angular.module('loomioApp').directive 'discussionsCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/discussions_card/discussions_card.html'
  replace: true
  controller: 'DiscussionsCardController'
  link: (scope, element, attrs) ->
