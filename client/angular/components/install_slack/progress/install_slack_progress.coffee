angular.module('loomioApp').directive 'installSlackProgress', ->
  scope: {slackProgress: '='}
  template: require('./install_slack_progress.haml')
  controller: ['$scope', ($scope) ->
    $scope.progressPercent = -> "#{$scope.slackProgress}%"
  ]
