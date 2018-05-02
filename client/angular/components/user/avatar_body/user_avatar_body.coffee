{ is2x } = require 'shared/helpers/window.coffee'

angular.module('loomioApp').directive 'userAvatarBody', ->
  scope: {user: '=', size: '=', colors: '='}
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

    $scope.gravatarSize = ->
      size = switch $scope.size
        when 'small'    then 30
        when 'medium'   then 50
        when 'large'    then 80
        when 'featured' then 175
      if is2x() then 2*size else size

    $scope.uploadedAvatarUrl = ->
      $scope.user.uploadedAvatarUrl($scope.imageSize) if $scope.user.avatarKind == 'uploaded'

    return
  ]
