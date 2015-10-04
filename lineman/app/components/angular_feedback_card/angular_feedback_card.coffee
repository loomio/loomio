angular.module('loomioApp').directive 'angularFeedbackCard', ->
  scope: {}
  restrict: 'E'
  replace: true
  templateUrl: 'generated/components/angular_feedback_card/angular_feedback_card.html'
  controller: ($scope, AppConfig) ->
    $scope.feedbackUrl = "/angular/feedback"
    $scope.angularUrl = "/angular"
    $scope.version = "v#{AppConfig.version}"
    $scope.versionUrl = "http://www.github.com/loomio/loomio/releases"

    $scope.$on 'hideFeedbackForm', -> $scope.hidden = true
    $scope.$on 'showFeedbackForm', -> $scope.hidden = false
