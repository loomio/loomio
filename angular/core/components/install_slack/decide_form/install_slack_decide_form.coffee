angular.module('loomioApp').directive 'installSlackDecideForm', (Session, Records, PollService) ->
  templateUrl: 'generated/components/install_slack/decide_form/install_slack_decide_form.html'
  controller: ($scope) ->
    $scope.poll = Records.polls.build groupId: Session.currentGroupId()
    PollService.applyPollStartSequence $scope
