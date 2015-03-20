angular.module('loomioApp').directive 'navbarStartDiscussion', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar_start_discussion.html'
  replace: true
  controller: 'NavbarController'
  link: (scope, element, attrs) ->
