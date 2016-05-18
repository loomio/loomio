angular.module('loomioApp').factory 'GroupWelcomeModal', ->
  templateUrl: 'generated/components/group_page/group_welcome_modal/group_welcome_modal.html'
  size: 'group-welcome-modal'
  controller: ($scope, AppConfig, UserHelpService) ->
    $scope.showVideo = AppConfig.loadVideos

    $scope.helpVideo = ->
      UserHelpService.helpVideoUrl()
