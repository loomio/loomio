angular.module('loomioApp').directive 'installSlackTableau', (Session) ->
  scope: {progress: '='}
  templateUrl: 'generated/components/install_slack/progress/install_slack_progress.html'
  controller: ($scope) ->
