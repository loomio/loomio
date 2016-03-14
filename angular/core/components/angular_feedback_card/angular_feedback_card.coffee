angular.module('loomioApp').directive 'angularFeedbackCard', ->
  scope: {}
  restrict: 'E'
  replace: true
  templateUrl: 'generated/components/angular_feedback_card/angular_feedback_card.html'
  controller: ($scope, AppConfig) ->
    $scope.feedbackUrl = "https://github.com/loomio/loomio/blob/master/CONTRIBUTING.md"
    $scope.angularUrl = "/angular"
    $scope.version = "v#{AppConfig.version}"
    $scope.versionUrl = "http://www.github.com/loomio/loomio/releases"

    $scope.expand = ->   $scope.expanded = true
    $scope.collapse = -> $scope.expanded = false
