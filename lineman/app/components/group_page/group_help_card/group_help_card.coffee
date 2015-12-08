angular.module('loomioApp').directive 'groupHelpCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_help_card/group_help_card.html'
  replace: true
  controller: ($scope, CurrentUser, AppConfig) ->
    $scope.showVideo = AppConfig.loadVideos

    $scope.showHelpCard = ->
      CurrentUser.isMemberOf($scope.group)
