angular.module('loomioApp').factory 'InstallSlackModal', ->
  templateUrl: 'generated/components/install_slack/modal/install_slack_modal.html'
  controller: ($scope, group, preventClose) ->
    $scope.$on '$close', $scope.$close
    $scope.group = group
    $scope.preventClose = preventClose
