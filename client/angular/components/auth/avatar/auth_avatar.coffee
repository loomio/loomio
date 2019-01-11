Records = require 'shared/services/records'

angular.module('loomioApp').directive 'authAvatar', ->
  scope: {user: '=?'}
  template: require('./auth_avatar.haml')
  controller: ['$scope', ($scope) ->
    $scope.user = $scope.user or {avatarKind: 'initials'}
    if _.includes(['initials', 'mdi-email-outline'], $scope.user.avatarKind)
      $scope.avatarUser = Records.users.build
        avatarKind:  'uploaded'
        avatarUrl:
          small:  '/img/mascot.png'
          medium: '/img/mascot.png'
          large:  '/img/mascot.png'
    else
      $scope.avatarUser = $scope.user
  ]
