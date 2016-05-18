angular.module('loomioApp').factory 'GroupWelcomeModal', ->
  templateUrl: 'generated/components/group_page/group_welcome_modal/group_welcome_modal.html'
  size: 'group-welcome-modal'
  controller: ($scope, group, AppConfig, UserHelpService, AbilityService) ->
    $scope.group = group
    $scope.showVideo = true

    $scope.helpVideo = ->
      UserHelpService.helpVideoUrl()

    $scope.userIsGroupCreator = ->
      AbilityService.isCreatorOf($scope.group)

    $scope.translationKey = (key) ->
      if key == 'heading'
        if AbilityService.isCreatorOf($scope.group)
          'group_welcome_modal.creator_heading'
        else
          'group_welcome_modal.member_heading'
      else
        if AbilityService.isCreatorOf($scope.group)
          'group_welcome_modal.creator_first_step'
        else
          'group_welcome_modal.member_steps'

