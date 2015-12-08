angular.module('loomioApp').factory 'GroupWelcomeModal', ->
  shownToGroup: {}
  templateUrl: 'generated/components/group_page/group_welcome_modal/group_welcome_modal.html'
  size: 'group-welcome-modal'
  controller: ($scope, AppConfig) ->
    $scope.showVideo = AppConfig.loadVideos
