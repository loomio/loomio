angular.module('loomioApp').directive 'pollCommonShareGroupForm', (Session, AbilityService, PollService) ->
  scope: {poll: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/share/group_form/poll_common_share_group_form.html'
  controller: ($scope) ->
    $scope.groupId = $scope.poll.groupId

    $scope.submit = PollService.submitPoll $scope, $scope.poll,
      flashSuccess: 'poll_common_share_form.group_set'
      successCallback: -> $scope.groupId = $scope.poll.groupId

    $scope.groups = ->
      _.filter Session.user().groups(), (group) ->
        AbilityService.canStartPoll(group)
