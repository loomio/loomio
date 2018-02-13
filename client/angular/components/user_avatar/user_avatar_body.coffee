{ is2x } = require 'shared/helpers/window.coffee'

angular.module('loomioApp').directive 'userAvatarBody', ->
  scope: {user: '=', coordinator: '=?', size: '@?'}
  restrict: 'E'
  templateUrl: 'generated/components/user_avatar/user_avatar_body.html'
  replace: false
  controller: ['$scope', ($scope) ->
    unless _.contains(['small', 'medium', 'large', 'featured'], $scope.size)
      $scope.size = 'medium'

    $scope.mdColors = ->
      if $scope.coordinator
        {'border-color': 'primary-500'}
      else
        {}

    $scope.gravatarSize = ->
      size = switch $scope.size
        when 'small'    then 30
        when 'medium'   then 50
        when 'large'    then 80
        when 'featured' then 175
      if is2x() then 2*size else size

    $scope.uploadedAvatarUrl = ->
      return unless $scope.user.avatarKind == 'uploaded'
      return $scope.user.avatarUrl if typeof $scope.user.avatarUrl is 'string'
      size = switch $scope.size
        when 'small'
          if is2x() then 'medium' else 'small'
        when 'medium'
          if is2x() then 'large' else 'medium'
        when 'large', 'featured'
          'large'
      $scope.user.avatarUrl[size]

    return
  ]
