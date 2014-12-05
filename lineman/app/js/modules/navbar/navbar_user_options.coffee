angular.module('loomioApp').directive 'navbarUserOptions', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/js/modules/navbar/navbar_user_options.html'
  replace: true
  controller: 'NavbarController'
  link: (scope, element, attrs) ->
