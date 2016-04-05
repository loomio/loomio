angular.module('loomioApp').factory 'GroupWelcomeModal', ->
  shownToGroup: {}
  templateUrl: 'generated/components/group_page/group_welcome_modal/group_welcome_modal.html'
  size: 'group-welcome-modal'
  controller: ($scope, $sce, AppConfig, UserHelpService) ->
    $scope.showVideo = AppConfig.loadVideos

    $scope.helpVideo = ->
      $sce.trustAsResourceUrl(UserHelpService.helpVideo())
