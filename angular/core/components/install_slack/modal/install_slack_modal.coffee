angular.module('loomioApp').factory 'InstallSlackModal', ->
  templateUrl: 'generated/components/install_slack/modal/install_slack_modal.html'
  controller: ($scope, preventClose) ->

    $scope.$on '$close', $scope.$close
    $scope.preventClose = preventClose
