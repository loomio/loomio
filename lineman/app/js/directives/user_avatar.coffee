angular.module('loomioApp').directive 'userAvatar', ->
  scope: {user: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/user_avatar.html'
  replace: true
  link: (scope, element, attrs) ->
