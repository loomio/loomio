angular.module('loomioApp').directive 'groupHelpCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_help_card/group_help_card.html'
  replace: true
  controller: ($scope, Session, AppConfig, UserHelpService) ->
    $scope.showVideo = AppConfig.loadVideos

    $scope.helpLink = ->
      UserHelpService.helpLink()

    $scope.helpVideo = ->
      UserHelpService.helpVideoUrl()

    $scope.showHelpCard = ->
      Session.user().isMemberOf($scope.group)

    $scope.tenTipsArticleLink = ->
      UserHelpService.tenTipsArticleLink()

    $scope.nineWaysArticleLink = ->
      UserHelpService.nineWaysArticleLink()
