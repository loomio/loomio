angular.module('loomioApp').directive 'userAvatar', ->
  scope: {user: '='}
  restrict: 'E'
  templateUrl: 'generated/components/user_avatar/user_avatar.html'
  replace: true
