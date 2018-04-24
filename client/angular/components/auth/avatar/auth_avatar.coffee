angular.module('loomioApp').directive 'authAvatar', ->
  scope: {user: '=?'}
  templateUrl: 'generated/components/auth/avatar/auth_avatar.html'
  controller: ['$scope', ($scope) ->
    $scope.user = $scope.user or {avatarKind: 'initials'}
    if _.contains(['initials', 'mdi-email-outline'], $scope.user.avatarKind)
      $scope.avatarUser =
        constructor: {singular: 'user'}
        avatarKind:  'uploaded'
        avatarUrl:
          small:  '/img/mascot.png'
          medium: '/img/mascot.png'
          large:  '/img/mascot.png'
    else
      $scope.avatarUser = $scope.user
  ]
