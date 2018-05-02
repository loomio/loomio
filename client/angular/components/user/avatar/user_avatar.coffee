angular.module('loomioApp').directive 'userAvatar', ->
  scope: {user: '=', coordinator: '=?', size: '@?', noLink: '=?', colors: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/user/avatar/user_avatar.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.mdColors = ->
      $scope.colors = $scope.colors or {}
      $scope.colors['border-color'] = 'primary-500' if $scope.coordinator
      $scope.colors

    return
  ]
