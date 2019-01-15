angular.module('loomioApp').directive 'userAvatar', ->
  scope: {user: '=', coordinator: '=?', size: '@?', noLink: '=?', colors: '=?'}
  restrict: 'E'
  template: require('./user_avatar.haml')
  replace: true
