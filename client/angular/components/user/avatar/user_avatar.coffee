angular.module('loomioApp').directive 'userAvatar', ->
  scope: {user: '=', coordinator: '=?', size: '@?', noLink: '=?', colors: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/user/avatar/user_avatar.html'
  replace: true
