{ is2x } = require 'shared/helpers/window'

angular.module('loomioApp').directive 'userAvatarBody', ->
  scope: {user: '=', size: '=', colors: '=', coordinator: '='}
  restrict: 'E'
  templateUrl: 'generated/components/user/avatar_body/user_avatar_body.html'
  replace: false
  controller: ['$scope', ($scope) ->

    $scope.imageSize = switch $scope.size
      when 'small'
        if is2x() then 'medium' else 'small'
      when 'large', 'featured'
        'large'
      else
        if is2x() then 'large' else 'medium'

    $scope.mdiSize = if $scope.size == 'small' then 'mdi-18px' else 'mdi-24px'

    $scope.mdColors = ->
      $scope.colors = $scope.colors or {}
      if $scope.coordinator
        $scope.colors['border-color'] = 'primary-500'
      else if $scope.colors['border-color'] == 'primary-500'
        $scope.colors['border-color'] = 'grey-300'
      $scope.colors

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
      $scope.user.avatarUrl[$scope.imageSize]

    return
  ]
