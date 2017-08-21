angular.module('loomioApp').directive 'userAvatar', ->
  scope: {user: '=', coordinator: '=?', size: '@?'}
  restrict: 'E'
  templateUrl: 'generated/components/user_avatar/user_avatar.html'
  replace: true
  controller: ($scope) ->
    unless _.contains(['small', 'medium', 'medium-circular', 'large', 'large-circular', 'featured'], $scope.size)
      $scope.size = 'small'

    $scope.gravatarSize = ->
      switch $scope.size
        when 'small'                     then 30
        when 'medium', 'medium-circular' then 50
        when 'large', 'large-circular'   then 80
        when 'featured'                  then 175

    $scope.uploadedAvatarUrl = ->
      return unless $scope.user.avatarKind == 'uploaded'
      switch $scope.size
        when 'small'                               then $scope.user.avatarUrl.small
        when 'medium', 'medium-circular'           then $scope.user.avatarUrl.medium
        when 'large', 'large-circular', 'featured' then $scope.user.avatarUrl.large

    return
