angular.module('loomioApp').directive 'navbarStartDiscussion', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/js/modules/navbar/navbar_start_discussion.html'
  replace: true
  controller: 'NavbarController'
  link: (scope, element, attrs) ->
