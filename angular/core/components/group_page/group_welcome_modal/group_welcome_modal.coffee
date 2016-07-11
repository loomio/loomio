angular.module('loomioApp').factory 'GroupWelcomeModal', ->
  templateUrl: 'generated/components/group_page/group_welcome_modal/group_welcome_modal.html'
  size: 'group-welcome-modal'
  controller: ($scope, group, AppConfig, UserHelpService, AbilityService) ->
    $scope.group = group
    $scope.showVideo = AppConfig.loadVideos

    $scope.helpVideo = ->
      UserHelpService.helpVideoUrl()

    $scope.userIsGroupCreator = ->
      AbilityService.isCreatorOf($scope.group)

    $scope.membershipStatus = ->
      if AbilityService.isCreatorOf($scope.group)
        'creator'
      else
        'member'
