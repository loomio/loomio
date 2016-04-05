angular.module('loomioApp').directive 'groupHelpCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_help_card/group_help_card.html'
  replace: true
  controller: ($scope, $sce, CurrentUser, AppConfig, UserHelpService) ->
    $scope.showVideo = AppConfig.loadVideos

    $scope.helpLink = ->
      UserHelpService.helpLink()

    $scope.helpVideo = ->
      $sce.trustAsResourceUrl(UserHelpService.helpVideo())

    $scope.showHelpCard = ->
      CurrentUser.isMemberOf($scope.group)
