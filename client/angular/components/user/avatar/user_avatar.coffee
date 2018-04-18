angular.module('loomioApp').directive 'userAvatar', ->
  scope: {user: '=', coordinator: '=?', size: '@?', noLink: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/user/avatar/user_avatar.html'
  replace: true
  controller: ['$scope', ($scope) ->
    unless _.contains(['small', 'medium', 'large', 'featured'], $scope.size)
      $scope.size = 'medium'
    return
  ]
