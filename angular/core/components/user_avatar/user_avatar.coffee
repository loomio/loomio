angular.module('loomioApp').directive 'userAvatar', ($window) ->
  scope: {user: '=', coordinator: '=?', size: '@?', noLink: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/user_avatar/user_avatar.html'
  replace: true
  controller: ($scope) ->
    unless _.contains(['small', 'medium', 'large', 'featured'], $scope.size)
      $scope.size = 'medium'

    _2x = -> $window.devicePixelRatio >= 2

    $scope.gravatarSize = ->
      size = switch $scope.size
        when 'small'    then 30
        when 'medium'   then 50
        when 'large'    then 80
        when 'featured' then 175
      if _2x() then 2*size else size

    $scope.uploadedAvatarUrl = ->
      return unless $scope.user.avatarKind == 'uploaded'
      return $scope.user.avatarUrl if typeof $scope.user.avatarUrl is 'string'
      size = switch $scope.size
        when 'small'
          if _2x() then 'medium' else 'small'
        when 'medium'
          if _2x() then 'large' else 'medium'
        when 'large', 'featured'
          'large'
      $scope.user.avatarUrl[size]

    return
