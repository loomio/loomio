angular.module('loomioApp').directive 'userAvatar', ->
  scope: {user: '=', coordinator: '=?', size: '@?'}
  restrict: 'E'
  templateUrl: 'generated/components/user_avatar/user_avatar.html'
  replace: true
  controller: ($scope) ->
    sizes = ['small', 'medium', 'large', 'featured']
    unless _.contains(sizes, $scope.size)
      $scope.size = 'small'
