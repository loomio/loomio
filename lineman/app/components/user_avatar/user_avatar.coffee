angular.module('loomioApp').directive 'userAvatar', ->
  scope: {user: '=', size: '@?'}
  restrict: 'E'
  templateUrl: 'generated/components/user_avatar/user_avatar.html'
  replace: true
