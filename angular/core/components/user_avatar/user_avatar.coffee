angular.module('loomioApp').directive 'userAvatar', ($window) ->
  scope: {user: '=', coordinator: '=?', size: '@?', noLink: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/user_avatar/user_avatar.html'
  replace: true
  controller: ($scope) ->
    unless _.contains(['small', 'medium', 'medium-circular', 'large', 'large-circular', 'featured'], $scope.size)
      $scope.size = 'small'

    _2x = -> $window.devicePixelRatio >= 2

    $scope.gravatarSize = ->
      size = switch $scope.size
        when 'small', 'small-circular'   then 30
        when 'medium', 'medium-circular' then 50
        when 'large', 'large-circular'   then 80
        when 'featured'                  then 175
      if _2x() then 2*size else size

    $scope.uploadedAvatarUrl = ->
      return unless $scope.user.avatarKind == 'uploaded'
      return $scope.user.avatarUrl if typeof $scope.user.avatarUrl is 'string'
      size = switch $scope.size
        when 'small'
          if _2x() then 'medium' else 'small'
        when 'medium', 'medium-circular'
          if _2x() then 'large' else 'medium'
        when 'large', 'large-circular'
          'large'
        when 'featured'
          'original'
      $scope.user.avatarUrl[size]

    return
