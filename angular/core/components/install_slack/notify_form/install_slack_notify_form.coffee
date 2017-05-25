angular.module('loomioApp').directive 'installSlackNotifyForm', (Session, Records, CommunityService) ->
  scope: {group: '='}
  templateUrl: 'generated/components/install_slack/notify_form/install_slack_notify_form.html'
  controller: ($scope) ->
    $scope.submit = ->
      $scope.$emit 'processing'
      Session.currentGroup.publish($scope.identifier).then ->
        $scope.$emit 'notifyComplete'
      .finally ->
        $scope.$emit 'doneProcessing'
