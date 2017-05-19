angular.module('loomioApp').directive 'installSlackProgress', (Session) ->
  scope: {slackProgress: '='}
  templateUrl: 'generated/components/install_slack/progress/install_slack_progress.html'
  controller: ($scope) ->
    $scope.progressPercent = -> "#{$scope.slackProgress}%"
