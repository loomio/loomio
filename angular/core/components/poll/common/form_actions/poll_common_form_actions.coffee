angular.module('loomioApp').directive 'pollCommonFormActions', (PollService, KeyEventService) ->
  scope: {poll: '='}
  replace: true
  templateUrl: 'generated/components/poll/common/form_actions/poll_common_form_actions.html'
  controller: ($scope) ->
    $scope.submit = PollService.submitPoll($scope, $scope.poll)
    KeyEventService.submitOnEnter $scope
